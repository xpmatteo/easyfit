/*
	File symbol_table.c
	
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	
	The data structures:
		"st" is an array of st_entry structures. It gets allocated dynamically
		at the start of the compilation, and de-allocated at compilation end.
		"lexemes" is an array of chars, that's used to hold the names of the variables.
*/

/* 
	Nota bene: la prima posizione dell' array "st" non viene usata: 
	questo perche' lookup restituisce 0 per indicare che non ha
	trovato il simbolo che cercava. 
*/
#if DEBUG
#	include <stdio.h>
#endif
#include <string.h>
#include <strings.h>
#include <memory.h>
#include "compint.h"
#include "MacApp.h"
#include "m_indep.h"

#pragma segment ACompileUserModel

#define LEXEMES_SIZE (3 * 1024)	

void dump_st(void);

#define value(c) ((c) - '0')

/* puntatore alla symbol table */
st_entry *st;

/* flag that tells us if when encountering an identifier the symbol
	table should regard it as a global or not. This is usually true, but
	gets set to false when reading function headers. A number of actions
	depend on this:
		1) when it is false, no memory gets allocated in the DataSeg for the symbol
		2) when it is false, every identifier read is regarded as NEW even
			if it already appeared earlier; this way we can handle local names masking
			global ones. */
int identifiers_are_global;

/* Flag that tells us if the next symbol should be regarded as a function name */
int identifier_is_func_name;

/* Flag that tells us wether the next identifier must necessarily be unique */
int identifier_must_be_unique;

/* per tenere conto degli indirizzi crescenti da assegnare alle
	variabili */
static short progressive_address;

/* l'ultima posizione usata nella sym table */
static short last_entry;

/* l'ultima posizione usata nell'array dei lexemi */
static short last_char;

/* puntatore a un array in cui conservo i la forma lessicale degli identificatori
	(nonche' delle parole riservate) */
static char *lexemes;

/* inizializza la symbol table e le var locali a questo modulo */
void init_st()
{
	progressive_address = 0;
	last_entry = 0;
	last_char = -1;
	identifiers_are_global = true;
	identifier_is_func_name = false;
	identifier_must_be_unique = false;
	
	st = (st_entry *) NewPermPtr(sizeof(st_entry) * ST_SIZE);
	FailNIL((Ptr) st);
	lexemes = NewPermPtr(LEXEMES_SIZE);
	if (!lexemes) {
		DisposPtr((Ptr) st);
		FailNIL(lexemes);
	}
}

/* dealloca la symbol table dopo la compilazione */
void free_st()
{
	DisposPtr((Ptr) st);
	DisposPtr(lexemes);
}

/* is_param - restituisce 1 se la stringa contiene un parametro 
	valido; e restituisce il numero del parametro nel parametro
	"num" */
short is_param(str, num)
char *str;
short *num;
{
	char c;
	
	if (*str != 'p') 
		return 0;
	
	str++;
	c = *str;
	if (!my_isdigit(c))
		return 0;
	
	*num = 0;
	while(my_isdigit(c)) {
		*num = *num * 10 + value(c);
		str++;
		c = *str;
	}

	if (*num > MAX_PARAMS || *num < 1)
		compiler_error(TOO_MANY_PARAMS);

	return 1;
}

/* ------------------------------------------------------------------------------- */
/* lookup - restituisce l'indice della entry del simbolo nella 
	symbol table, oppure zero se non c'e' */
short lookup(str)
char *str;
{
	short p, num;

	/* aggiorna se e' il caso "user_model_params" */
	if (is_param(str, &num))
		if (user_model_params < num)
			user_model_params = num;
			
	for (p = last_entry; p > 0; p--) {
		if (strcmp(st[p].name, str) == 0)
			return p;
	}
	return 0;
}

/* ------------------------------------------------------------------------------- */
/* lookup_address - restituisce la posizione nella st della variabile _globale_
	 di cui viene fornito l'indirizzo, oppure zero se non c'e' */
short lookup_address(int addr)
{
	short p;

	for (p = last_entry; p > 0; p--) {
		if (st[p].address == addr && st[p].global && !st[p].func_name)
			return p;
	}
	return 0;
}

/* ------------------------------------------------------------------------------- */
/* 
	inserisce un nuovo simbolo nella symbol table, assegnandogli il 
	token appropriato.  Se il token e' T_ID, e identifiers_are_global e' true,
	gli assegna anche un indirizzo progressivo.
	Restituisce il numero dell'entry nella symbol table.
*/
short insert(str, tok)
char *str;
short tok;
{
	int len;
	
	len = strlen(str);
	if (last_entry+1 > ST_SIZE)
		compiler_error(ST_FULL);
	if (last_char + len + 1 >= LEXEMES_SIZE)
		compiler_error(LEXEMES_FULL);
	
	last_entry++;
	st[last_entry].token = tok;
	st[last_entry].name = lexemes + last_char + 1;
	last_char += len + 1;
	strcpy(st[last_entry].name, str);
	
	/* se e' una variabile, aggiungi l'indirizzo */
	if (tok == T_ID && identifiers_are_global && !identifier_is_func_name) {
		if (progressive_address >= MAX_USER_VARS)
			compiler_error(TOO_MANY_VARS);
		st[last_entry].address = progressive_address++;
	}
	
#if qFuncDefs
	if (tok == T_ID) {
		st[last_entry].global = identifiers_are_global;
		st[last_entry].func_name = identifier_is_func_name;
		st[last_entry].n_args = 0;
		st[last_entry].function_being_defined = 0;
	}
	else {
		st[last_entry].global = 1;
		st[last_entry].func_name = 0;
		st[last_entry].n_args = 0;
		st[last_entry].function_being_defined = 0;
	}
#endif

	return last_entry;
}

#if qFuncDefs
		
/* ----------------------------------------------------------------------------- */
/*
	remove_non_globals_from_st -- The idea is to start from the beginning of the
	symbol table, and compact it removing every non-global symbol.
	The variable "cursor" jumps up exploring the array, while the variable "top"
	reminds the current top of the symbol table being rebuilt.
	
	A bug in this version is that the lexemes are not compacted. This
	issue will have to be resolved some day.
*/
void remove_non_globals_from_st()
{
	int cursor, top;
	p_st_entry a,b;
	
	/*
	writeln("remove_non_globals_from_st: entering");
	dump_st();
	*/
	for (cursor=1, top=0; cursor<=last_entry; cursor++)
		if (st[cursor].global) {
			top++;
			if (top != cursor) {
				#if xqDebug
					Str255 s;
					sprintf(s, 
						"remove_non_globals_from_st: top = %d, cursor = %d, about to assign",
						top, cursor);
					DEBUGWRITELN(c2pstr(s));
				#endif
				a = st+top;
				b = st+cursor;
				
				ASSIGN_ST_ENTRY(a,b)
			}
		}

	last_entry = top;
	/*
	writeln("remove_non_globals_from_st: exiting");
	dump_st();
	*/
}

#endif

/* stampa il contenuto della symbol table */

void dump_st(void)
{
	int i;
	char s[255];
	
	sprintf(s, "---Symbol table dump: last_entry: %d; last_char: %d\n",
				 last_entry, last_char);
	#if qDebug
	DEBUGWRITELN(c2pstr(s));
	#else
	writeln(s);
	#endif
	
	for (i=last_entry; i>0 ; i--) {
		if (st[i].token == T_ID)
			sprintf(s, 
				"%3d: %8s tok %2d, global %d, func_name %d, n_args %d, f_being_def %d, addr %3d, arg_map=%x",
				i, st[i].name, st[i].token, st[i].global, st[i].func_name, st[i].n_args,
				st[i].function_being_defined, st[i].address, st[i].arg_map);
		else
			sprintf(s, "%3d: %8s tok %2d", i, st[i].name, st[i].token);
			
	#if qDebug
	DEBUGWRITELN(c2pstr(s));
	#else
	writeln(s);
	#endif
	}
	
	#if !qDebug
	synch;
	#endif
}
