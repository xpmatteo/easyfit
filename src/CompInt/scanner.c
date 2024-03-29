/*
	File scanner.c
	
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include <Stdio.h>
#include "compint.h"

#pragma segment ACompileUserModel

#define null			'\0'
#define tab 			'\t'
#define blank 		' '
#define ret				13
#define nl				10
#define vtab			11
#define ffeed			12
#define dot 			'.'
#define comma 		','
#define colon 		':'
#define semicolon ';'
#define lpar 			'('
#define rpar 			')'
#define newline		'\n'
#define lcurlpar	'{'
#define rcurlpar	'}'
#define star			'*'
#define slash			'/'
#define equal			'='
#define plus			'+'
#define minus			'-'
#define lt				'<'
#define gt				'>'
#define underscore '_'

#if macintosh
#	define mac_lte		'�'
#	define mac_gte		'�'
#	define mac_neq		'�'
# define mac_sqrt		'�'
#endif

#define STR_LEN 100

/* il puntatore nella symbol table dell' ultima var. letta dallo
	scanner */
short last_var;

/* il valore dell' ultima costante letta dall' anal. lessicale */
extended numconst;

/* il numero di caratteri letti */
int charcount;

short read_num();

char nextchar()
{
	charcount++;
	return *input++;
}

/* rispinge indietro il carattere */
void unnextchar()
{
	input--;
	charcount--;
}

short scanner1();

#if qDebug
char *token_names[] = {
		/* [0] */
		"",
		/* [1] */
		"end",
		/* [2] */
		"for",
		/* [3] */
		"do",
		/* [4] */
		"if",
		/* [5] */
		"to",
		/* [6] */
		"exp",
		/* [7] */
		"sin",
		/* [8] */
		"cos",
		/* [9] */
		"tan",
		/* [10] */
		"xpwry",
		/* [11] */
		"sqrt",
		/* [12] */
		"abs",
		/* [13] */
		"sign",
		/* [14] */
		"log",
		/* [15] */
		"T_IN",
		/* [16] */
		"atn",
		/* [17] */
		":=",
		/* [18] */
		";",
		/* [19] */
		"(",
		/* [20] */
		")",
		/* [21] */
		",",
		/* [22] T_EOSTR */
		"eostr",
		/* [23] */
		"<",
		/* [24] */
		">",
		/* [25] */
		"�",
		/* [26] */
		"�",
		/* [27] */
		"=",
		/* [28] */
		"�",
		/* [29] */
		"+",
		/* [30] */
		"-",
		/* [31] */
		"*",
		/* [32] */
		"/",
		/* [33] T_ID */
		"identifier",
		/* [34] */
		"begin",
		/* [35] */
		"ln",
		/* [36] */
		"or",
		/* [37] */
		"not",
		/* [38] */
		"and",
		/* [39] */
		"while",
		/* [40] */
		"repeat",
		/* [41] */
		"const",
		/* [42] */
		"then",
		/* [43] */
		"else",
		/* [44] */
		"�",
		/* 45 */ "until",
		/* 46 */ "beep",
		/* 47 */ "sqr",
		/* 48 */ "cube",
		/* 49 */ "exit",
		/* 50 */ "print",
		/* 51 */ "function"
	};
#endif

short scanner()
{
#if qDebug
	short tok;
	char s[250];
	
	tok = scanner1();
/*
	if (tok == T_CONST)
		sprintf(s, "-- token: %s: %g", token_names[tok], numconst);
	else if (tok == T_ID)
		sprintf(s, "-- token: %s: %s", token_names[tok], st[last_var].name);
	else
		sprintf(s, "-- token: %s", token_names[tok]);
	DEBUGWRITELN(c2pstr(s));
*/
	return tok;
	
#else
	return scanner1();
#endif
}

short scanner1()
{
	char c, str[STR_LEN];
	short tmp;
	
	while(1) {
		c = nextchar();
		
		if (my_isspace(c))
			; /* skip white space */
			
		else if (c == lcurlpar)
			/* skip comment until you see a "}" */
			while ((c = nextchar()) != rcurlpar)
				;
				
		else if (my_isdigit(c) || c == dot) {
			/* riconosci una costante numerica */
			short chars_read;
			
			unnextchar();
			chars_read = read_num(input, &numconst);
			input += chars_read;
			charcount += chars_read;
			return T_CONST;
		}
		
		else if (my_isalpha(c)) {
			int i;
			/* riconosci un identificatore o una parola riservata */

			/* copia l'identificatore in "str" */
			i = 0;
			while (my_isalnum(c)) {
				str[i++] = my_tolower(c); 
				c = nextchar();
			}
			str[i] = null;
			unnextchar();
			
			/* guarda se e' gia' nella symbol table; */
			tmp = lookup(str);
			if (tmp && st[tmp].token != T_ID)
				return st[tmp].token;
			
			if (identifier_must_be_unique && tmp)
				compiler_error(REDEFINED_NAME);

			if (identifiers_are_global) {
				if (tmp) {
					last_var = tmp;
					return T_ID;
				}
				else {
					last_var = insert(str, T_ID);
					return T_ID;
				}
			}
			else {�																/* new symbols are local */
				last_var = insert(str, T_ID);				/* insert it, never mind if it already
																							 was there */
				return T_ID;
			}
		}
		
		else if (c == null)
			return T_EOSTR;
		else if (c == semicolon)
			return T_SEMICOLON;
		else if (c == plus)
			return T_PLUS;
		else if (c == minus)
			return T_MINUS;
		else if (c == slash)
			return T_DIV;
		else if (c == equal)
			return T_EQ;
		else if (c == lpar)
			return T_LPAR;
		else if (c == rpar)
			return T_RPAR;
		else if (c == comma)
			return T_COMMA;

#if macintosh		/* Macintosh special characters */
		else if (c == mac_neq)
			return T_NEQ;
		else if (c == mac_lte)
			return T_LTE;
		else if (c == mac_gte)
			return T_GTE;
		else if (c == mac_sqrt)
			return T_MACSQRT;
#endif

		else if (c == star) {
			if (nextchar() == star)	/* distingui fra "*" e "**" */
				return T_XPWRY;
			else {
				unnextchar();
				return T_TIMES;
			}
		}
		
		else if (c == lt) {
			if ((c = nextchar()) == equal) {		/* forse "<=" ? */
				return T_LTE;
			}
			else if (c == gt)	{								/* forse "<>" ? */
				return T_NEQ;
			}
			else {
				unnextchar();
				return T_LT;									/* allora e' "<" */
			}
		}
		else if (c == gt) {
			if (nextchar() == equal) {		/* forse ">=" ? */
				return T_GTE;
			}
			else {
				unnextchar();
				return T_GT;									/* allora e' ">" */
			}
		}
		
		else if (c == colon) {
			if (nextchar() == equal) {		/* forse ":=" ? */
				return T_ASSIGN;
			}
			else 
				compiler_error(ILLEGAL_SYM);		/* allora errore */
		}
		else
			compiler_error(ILLEGAL_CHAR);
	}
}