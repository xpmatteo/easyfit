/*
	File compiler.c
	
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.

	This file contains one of the two entry points for the ÄÐpascal module. By the way, 
	this module was once called "compint".
	The entry points are the function "compile", defined here, and the function
	"interpret", defined in interpret.c .
	
	NOTES about the extensions not documented in my thesis.
	I decided to add the ability to define functions (subroutines) in f-pascal.
	The functions can have any number of arguments. The arguments are always
	passed by value. The arguments may be of two types: function arguments
	and real arguments. Real ones are the usual number type used throughout
	the language; function arguments are -must be- names of functions
	(actually what gets compiled is the function address.) This way we are
	able to define a function that has other functions as arguments; so we
	can for instance define a numerical_integration(function f, from, to)
	function. These functions have no local variables yet (though this should
	be a likely way to extend this work.) Adding locals should not be difficult, in
	a second time. These functions return a value of type real. The value to be
	returned is assigned to the function name, as in Pascal. It is not possible
	to define functons inside of functions, as in Pascal. It is possible to
	write recursive functions. It is not possible to pass to a function a
	function that has a function argument.
	
	The extensions added to the language syntax are:
	
		function_definition ::= FUNCTION <id> ( <formal_arg_list> ) ;
														[ÊVAR <var_list> ; ]
														<compound_statement>
		formal_arg_list ::= <formal_func_arg> | <formal_func_arg> , <formal_arg_list>
		formal_func_arg ::= FUNCTION <id> ( <simple_arg_list> ) | <id>
		simple_arg_list ::= <simple_arg_list> | <id> , <simple_arg_list>
		var_list ::= <identifier> | <identifier> , <var_list> 
				
		function_call ::= <id of function> ( <actual_arg_list> )
		actual_arg_list ::= <actual_func_arg> | <actual_func_arg> , <actual_arg_list>
		actual_func_arg ::= <id of function> | <expression>
		
	I didn't write yet all the code required to check properly actual arg lists
	against formal ones for type and length, but this work should eventually be done.
	
	The mechanism for function call, and result returning, is outlined below.
	The work is split between the compiler generated code, and the operations
	provided by the JSR and RTS pseudo assembler code. 
	First we push one empty position on the stack. This position is used to hold
	the return value of the function. Then we generate the code that pushes on
	the stack all of the arguments, from left to right. So the uppermost actual
	argument is the rightmost on the argument list. Then we call the JSR instruction,
	that pushes on the stack the current value +1 of the program counter 
	(that is, the return address) and then pushes on the stack the value of the
	bb register (see below.) After this, the current value of the stack pointer
	is copied into the register bb. At last, pc is set to the address passed
	as an argument to the JSR instruction. Follows a sketch of the stack
	after calling JSR:
	
				Old value of BB		<----- pointed to by current BB
				Return address
				argument n
				argument n-1
				[...]
				argument 2
				argument 1
				return value
				
	After executing JSR, execution proceeds with the first instruction of the
	function called. Functions end with RTS (they could also end with EXIT.)
	The RTS instruction restores the old value of bb and stores the return address
	into pc. The stack is lowered two positions, erasing the return address
	and the old bb. When execution returns to the instruction following JSR,
	we erase the function arguments from the stack. The return value is now
	the topmost position of the stack, just like it should be for any expression or
	subexpression. 
	Should we add local variables to functions, these would be reserved
	room for on the stack _above_ bb.
	
	Modifications to symbol table: I've added several new fields to the
	st_entry struct. 
		global: this is a boolean that tells us if the symbol is global, or
			local to a function. If it is local, it will be erased after function
			definition.
		func_name: tells if this symbol is an identifier of a function. Note
			that function identifiers can be local as well as global.
		n_args:	This is used for func_names, and holds the number of arguments
			that a function requires. It is used for checking the length of an
			actual argument list in fcuntion calls, but also to know where we should
			expect to find on the stack the room for the return value.
	
	Function definition mechanics:
		-- to be filled later --
		
	New pseudo assembler instructions:
	JSR and RTS are the basis for function call and return. Their workings have
	been outlined already.
	POPN accepts an integer argument, and pops (erases) that many position from
	the stack. The main use of this is to remove function arguments from the stack.
	If passed a negative number, positions are pushed instead of
	popped. No value is provided to fill these new positions that so are uninitialized.
	This is the trick we use for reserving a position on the stack for the return 
	value of a function.
	PUSHBB and POPBB are the same as push and pop, only the argument is looked for in
	the stack instead of the data segment; the address supplied as an argument
	to these instruction is intended to be bb-relative: the address must be
	added to the current bb value to obtain the correct stack position. These
	two instructions are needed to refer to function arguments and return value,
	and eventually will be used for local variables on the stack too.
	JSRBB is the same as JSR, only the address given is indirect and bb relative.
	This means that we first add the given address to the current value of bb,
	then read the stack at that position, and there we expect to find the "real"
	function address in the code segment. This is needed to use a function
	passed as an argument to a function.
	
	New register: bb. This is the "Block Base"; it is needed to refer to all the data 
	that are local to a function call. At interpreter activation it contains -1.
	When a function is called, it points to the "activation block" of the function
	call, that is, all the stuff you see in the sketch above.
	
	BUGS and Problems:
	- We don't check for argument types in function calls: we can pass a 
	functional parameter where a numeric is needed, or the reverse.
	- You can't pass a built in function, like sqrt, as a functional argument.
	- We don't even check that there are not duplicated symbols in function
	headers (eg, function f(a,a); ). These get compiled, with meaningless
	results.
*/

#include <stdio.h>
#include <setjmp.h>
#include <strings.h>
#include "compint.h"
#include "macapp.h"
#include "m_indep.h"

#pragma segment ACompileUserModel

/* globals + locals */
short compiler_state;
static short sym_lookahead;

/* arg fasulli da passare alla gen_instr() */
#define __ 0.0
#define _ 0

void compile_program();
void compile_statement();
void compile_assignment();
void compile_compound_statement();
void compile_if();
void compile_while();
void compile_repeat();
void compile_for();
void compile_expr();
void compile_simple_expr();
void compile_term();
void compile_super_term();
void compile_factor();
void compile_beep();
void compile_exit();
void compile_print();
void gen_pop(int st_pointer);
void gen_push(int st_pointer);
void gen_jsr(int st_pointer);
void gen_incr(int st_pointer);
#if qFuncDefs
void compile_function_call();
void compile_func_declaration();
#endif

#define qTraceCompiler 0						/* Enable tracing information of parse
																			 process to go to the Messages window */
	
#if qTraceCompiler
static int traceCount;

void enter(char *funcName)
{
	int i;
	
	traceCount++;
	for (i=0; i<traceCount; i++)
		write("  ");
	write("->");
	writeln(funcName);
}

void exi(char *funcName)
{
	int i;
	
	for (i=0; i<traceCount; i++)
		write("  ");
	write("<-");
	writeln(funcName);
	traceCount--;
}
#endif qTraceCount

/* 
	compile - prende una stringa che contiene il programma scritto 
	in Ä-pascal, e lo compila.
	se la compilazione va bene, restituisce 0; il codice 
	compilato si trovera' nell' array codeseg.
	Altrimenti restituisce un codice di errore.  L'argomento
	where conterra' allora il numero di caratteri letti fino ad
	allora. 
	In "n_params" passiamo il numero di parametri usati in questo modello.
	Se c'e' errore, n_params e' indefinito.
	Se _non_ c'e' errore, where e' indefinito.
*/

short compile(program, where, n_params, error_string)
char *program;
int *where;
short *n_params;
Str255 error_string;
{
	#if qTraceCompiler
	traceCount = 0;
	enter("compile");
	#endif

	init_st();							/* init the symbol table module */
	init_compiler();				/* init the compiler */

	input = program;
	
	if (setjmp(env) == 0) {
		/* inizializza sym_lookahead */
		sym_lookahead = scanner();
		
		compile_program();
		
		if (user_model_params == 0)
			compiler_error(NOT_USING_PARAMS);
		
		gen_instr(EXIT, _, __);
		*n_params = user_model_params;
	}
	else { /* error handling */
		if (compiler_state) {
			*where = charcount;
			sprintf(error_string, "%P", error_msg);
			c2pstr(error_string);
		}
		else
			*n_params = user_model_params;
	}
	
#if qDebug
	dump_codeseg();
#endif

	free_st();												/* we're done with the symbol table */
	
	#if qTraceCompiler
	exi("compile");
	synch;
	#endif

	/*
	{ char s[100];
		void DebugAlert(char *msg);
		sprintf(s, "Size of the code: %d", curr_addr);
		DebugAlert(s); }
	*/
	
	return compiler_state;
}

void init_compiler()
{
	char s[10];
	short i;
	
	#if qTraceCompiler
	enter("init_compiler");
	#endif

	compiler_state = 0;
	charcount = 0;
	user_model_params = 0;
	curr_addr = 0;
	model_may_change_focus = false;
	
	/* inserisci le parole riservate nella symb table */
	insert("begin", T_BEGIN);
	insert("end", T_END);
	insert("for", T_FOR);
	insert("do", T_DO);
	insert("if", T_IF);
	insert("to", T_TO);
	insert("exp", T_EXP);
	insert("sin", T_SIN);
	insert("cos", T_COS);
	insert("tan", T_TAN);
	insert("sqrt", T_SQRT);
	insert("abs", T_ABS);
	insert("sign", T_SIGN);
	insert("log", T_LOG);
	insert("ln", T_LN);
	insert("atn", T_ATN);
	insert("or", T_OR);
	insert("not", T_NOT);
	insert("and", T_AND);
	insert("then", T_THEN);
	insert("repeat", T_REPEAT);
	insert("until", T_UNTIL);
	insert("while", T_WHILE);
	insert("else", T_ELSE);
	insert("beep", T_BEEP);
	insert("sqr", T_SQR);
	insert("cube", T_CUBE);
	insert("int", T_INT);
	insert("exit", T_EXIT);
	insert("print", T_PRINT);
#if qFuncDefs
	insert("function", T_FUNCTION);
	insert("var", T_VAR);
#endif

	/* 
		inserisci ora le variabili con un significato speciale:
			"y"				e' la variabile numero 0;
			"p1"			fino a "p20" sono le variabili da 1 a MAX_PARAMS 
			"x"				e' la variabile numero MAX_PARAMS + 1
			"subject" e' la variabile numero MAX_PARAMS + 2
			"dose" 		e' la variabile numero MAX_PARAMS + 3
	*/
	insert("y", T_ID);
	for (i=1; i<=MAX_PARAMS; i++) {
		sprintf(s, "p%d", i);
		insert(s, T_ID);
	}
	insert("x", T_ID);
	insert("subject", T_ID);
	insert("dose", T_ID);

	#if qTraceCompiler
	exi("init_compiler");
	#endif
};

/* ------------------------------------------------------------------------------- */
/*
	match -- try to read a given symbol from input stream. If it doesn't find it,
	call error. If it finds it, return true.
*/
int match(what)
short what;
{
	if (sym_lookahead != what)
		match_error(what);
	sym_lookahead = scanner();
	return true;
}

void compile_statement()
{
	#if qTraceCompiler
	enter("compile_statement");
	#endif

	#if xqDebug
	{ char s[200];
		extern char *token_names[];
		sprintf(s, "compile_statement: sym_lookahead = %s", token_names[sym_lookahead]);
		DEBUGWRITELN(c2pstr(s));
		dump_st();
	}
	#endif
	
	switch (sym_lookahead) {
		/* prova a vedere se il simbolo e' nell'insieme di simboli
			che possono SEGUIRE uno statement; nel qual caso assumiamo
			statement nullo e non facciamo niente, manco 
			consumiamo il simbolo. */
		case T_SEMICOLON:
		case T_END:
		case T_EOSTR:
			/* do nothing */
			break;
		case T_BEGIN: compile_compound_statement(); break;
		case T_ID: compile_assignment(); break;
		case T_IF: compile_if(); break;
		case T_WHILE: compile_while(); break;
		case T_REPEAT: compile_repeat(); break;
		case T_FOR: compile_for(); break;
		case T_BEEP: compile_beep(); break;
		case T_EXIT: compile_exit(); break;
		case T_PRINT: compile_print(); break;
		
		/* Errore: non abbiamo ricevuto un simbolo legale */
		default: compiler_error(SYNTAX_ERROR); break;
	}

	#if qTraceCompiler
	exi("compile_statement");
	#endif
}

void compile_beep()
{
	#if qTraceCompiler
	enter("compile_beep");
	#endif

	match(T_BEEP);
	gen_instr(BEEP, _, __);

	#if qTraceCompiler
	exi("compile_beep");
	#endif
}

void compile_exit()
{
	#if qTraceCompiler
	enter("compile_exit");
	#endif

	match(T_EXIT);
	gen_instr(EXIT, _, __);

	#if qTraceCompiler
	exi("compile_exit");
	#endif
}

/* 
	print statement: allows to print the value and name of a variable at runtime.
	We push the first 7 char of the var name on the stack,
	then we pass as an argument to the PRINT instruction the address of the var.
*/
void compile_print()
{
	short	var_addr;
	char	format[20];
	union {
		extended	e;
		char			s[sizeof(extended)];
	}	var_name;
	
	#if qTraceCompiler
	enter("compile_print");
	#endif

	match(T_PRINT);
	match(T_ID);
	
	var_addr = st[last_var].address;
	sprintf(format, "%%.%ds", sizeof(extended) - 1);
	sprintf(var_name.s, format, st[last_var].name);
	
	gen_instr(PUSHC, _, var_name.e);
	if (st[last_var].global)
		gen_instr(PRINT, var_addr, __);
	else
		gen_instr(PRINTBB, var_addr, __);
	
	model_may_change_focus = true;
	
	#if qTraceCompiler
	exi("compile_print");
	#endif
}


/* cosi' compiliamo l'if:
	
					Compile(<expr>)
					BZ end
					Compile(<statement>)
		end
		
	e l' if-then-else
		
								Compile(<expr>)
								BZ else-part
								Compile(<statement1>)
								GOTO end
		else-part		Compile(<statement2>)
		end

*/
		
void compile_if()
{
	short bz_addr, goto_addr;
	
	#if qTraceCompiler
	enter("compile_if");
	#endif

	match(T_IF);
	compile_expr();
	bz_addr = curr_addr;
	gen_instr(BZ, _, __);
	match(T_THEN);
	compile_statement();
	if (sym_lookahead != T_ELSE)
		patch_address(bz_addr, curr_addr);
	else {
		goto_addr = curr_addr;
		gen_instr(GOTO, _, __);
		patch_address(bz_addr, curr_addr);
		match(T_ELSE);
		compile_statement();
		patch_address(goto_addr, curr_addr);
	}

	#if qTraceCompiler
	exi("compile_if");
	#endif
}

void compile_assignment()
{
	short var_address;
#if qFuncDefs
	short var_is_global;
	short var_is_func_name;
	short n_args;
#endif

	#if qTraceCompiler
	enter("compile_assignment");
	#endif

	match(T_ID);
	var_address = st[last_var].address;
#if qFuncDefs
	var_is_global = st[last_var].global;
	var_is_func_name = st[last_var].func_name;
	n_args = st[last_var].n_args;
	if (var_is_func_name && !(st[last_var].function_being_defined))
		compiler_error(ASSIGNMENT_TO_WRONG_NAME);
#endif

	match(T_ASSIGN);
	compile_expr();
	
#if qFuncDefs
	if (var_is_func_name)		/* assigning return value to current function */
		gen_instr(POPBB, -(n_args+2), __);
	else if (var_is_global)	/* assigning to global variable */
		gen_instr(POP, var_address, __);
	else										/* assigning to function parameter */
		gen_instr(POPBB, var_address, __);
#else
	gen_instr(POP, var_address, __);
#endif

	#if qTraceCompiler
	exi("compile_assignment");
	#endif
}

void compile_compound_statement()
{
	#if qTraceCompiler
	enter("compile_compound_statement");
	#endif

	match(T_BEGIN);
	compile_statement();
	while (sym_lookahead == T_SEMICOLON) {
		match(T_SEMICOLON);
		compile_statement();
	}
	match(T_END);

	#if qTraceCompiler
	exi("compile_compound_statement");
	#endif
}

void compile_program()
{
	#if qTraceCompiler
	enter("compile_program");
	#endif

	#if qFuncDefs
	if (sym_lookahead == T_FUNCTION)
		compile_func_declaration();
	else
	#endif
	compile_statement();
	while (sym_lookahead == T_SEMICOLON) {
		match(T_SEMICOLON);
	#if qFuncDefs
		if (sym_lookahead == T_FUNCTION)
			compile_func_declaration();
		else
	#endif
		compile_statement();
	}
	
	/* if we have more input, then there is an error (typically, a
		semicolon is missing. We call match(T_SEMICOLON) being sure
		it will fail, so we'll get the correct error message */
	if (sym_lookahead != T_EOSTR)
		match(T_SEMICOLON);

	#if qTraceCompiler
	exi("compile_program");
	#endif
}

/* cosi' compiliamo il WHILE:

	loop	Compile(<expr>)
				BZ end
				Compile(<statement>)
				GOTO loop
	end
*/

void compile_while()
{
	short loop_addr, bz_addr;
	
	#if qTraceCompiler
	enter("compile_while");
	#endif

	match(T_WHILE);
		loop_addr = curr_addr;
	compile_expr();
		bz_addr = curr_addr;
		gen_instr(BZ, _, __);
	match(T_DO);
	compile_statement();
		gen_instr(GOTO, loop_addr, __);
		patch_address(bz_addr, curr_addr);

	#if qTraceCompiler
	exi("compile_while");
	#endif
}

/* cosi' compiliamo il REPEAT:

	loop		Compile(<statement>)
					Compile(<expr>)
					BZ loop
*/
void compile_repeat()
{
	short loop_addr;
	
	#if qTraceCompiler
	enter("compile_repeat");
	#endif

	loop_addr = curr_addr;
	match(T_REPEAT);
	compile_statement();
	match(T_UNTIL);
	compile_expr();
	gen_instr(BZ, loop_addr, __);

	#if qTraceCompiler
	exi("compile_repeat");
	#endif
}

/* cosi' compiliamo il for:

	FOR <counter> := <start> TO <end> DO <statement>
	
					Compila(<start>)
					POP		<counter>			; conserviamo il valore di start
					Compila(<end>)
					PUSH	<counter>			; rimettiamolo sullo stack
	loop		BLT		endfor
				
					Compila(<statement>)
				
					INCR <counter>
					GOTO loop
	endfor	POP1

Va notato che:
	- la espressione che indica la fine del loop viene computata prima del primo
		passo del ciclo, e non a ogni passo.
		
	- ci si aspetta che eseguire uno statement non cambi la altezza
		dello stack, mentre eseguire una expression aumenti di uno
		la altezza dello stack (il valore dell'espressione)
	
	- BGT abbassa di uno lo stack.  
	- INCR aumenta di uno il valore della variabile, e la spinge
		sullo stack.
	
	- nelle operazioni non commutative, e in BLT, l'ordine degli
		operandi dal basso in alto.  Quindi il significato di BLT
		e' :
		
			if *(sp-1) < *sp then branch
*/
void compile_for()
{
	short counter_st_pointer, loop_addr, end_addr;
	
	#if qTraceCompiler
	enter("compile_for");
	#endif

	match(T_FOR);
	match(T_ID);
	counter_st_pointer = last_var;
	
	match(T_ASSIGN);
	compile_expr();		/* compila il valore iniziale */
	gen_pop(counter_st_pointer);
	
	match(T_TO);
	compile_expr();		/* compila il valore finale */
	
	match(T_DO);
	gen_push(counter_st_pointer);
	
	loop_addr = curr_addr;	/* salva l'indirizzo qui */
	gen_instr(BLT, _, __);
	
	compile_statement();
	
	gen_incr(counter_st_pointer);
	gen_instr(GOTO, loop_addr, __);
	
	end_addr = curr_addr;	/* salva l'indirizzo qui */
	gen_instr(POP1, _, __);
	
	/* ora dobbiamo andare ad appicciare l'argomento giusto alla
		BGT di prima */
	patch_address(loop_addr, end_addr);

	#if qTraceCompiler
	exi("compile_for");
	#endif
}

void compile_expr()
{
	#if qTraceCompiler
	enter("compile_expr");
	#endif

	compile_simple_expr();
	switch (sym_lookahead) {
		case T_EQ:
			match(T_EQ);
			compile_simple_expr();
			gen_instr(EQ, _, __);
			break;
		case T_NEQ:
			match(T_NEQ);
			compile_simple_expr();
			gen_instr(NEQ, _, __);
			break;
		case T_LT:
			match(T_LT);
			compile_simple_expr();
			gen_instr(LT, _, __);
			break;
		case T_LTE:
			match(T_LTE);
			compile_simple_expr();
			gen_instr(LTE, _, __);
			break;
		case T_GT:
			match(T_GT);
			compile_simple_expr();
			gen_instr(GT, _, __);
			break;
		case T_GTE:
			match(T_GTE);
			compile_simple_expr();
			gen_instr(GTE, _, __);
			break;
	}

	#if qTraceCompiler
	exi("compile_expr");
	#endif
}

void compile_simple_expr()
{
	short uminus_flag, remember_op;

	#if qTraceCompiler
	enter("compile_simple_expr");
	#endif

	uminus_flag = 0;

	if (sym_lookahead == T_PLUS) {
		match(T_PLUS); /* '+' unario: do nothing */
	}
	else if (sym_lookahead == T_MINUS) {
		match(T_MINUS);
		uminus_flag = 1;
	}

	compile_term();
	
	if (uminus_flag)
		gen_instr(UMINUS, _, __);
	
	while (sym_lookahead == T_PLUS || 
				 sym_lookahead == T_MINUS ||
				 sym_lookahead == T_OR) {
		remember_op = sym_lookahead;
		match(sym_lookahead);
		compile_term();
		
		if (remember_op == T_PLUS)
			gen_instr(ADD, _, __);
		else if (remember_op == T_MINUS)
			gen_instr(SUB, _, __);
		else 		/* remember_op == T_OR */
			gen_instr(OR, _, __);
	}	/* while */

	#if qTraceCompiler
	exi("compile_simple_expr");
	#endif
}		/* compile_simple_expression */

void compile_term()
{
	short remember_op;

	#if qTraceCompiler
	enter("compile_term");
	#endif

	compile_super_term();
	
	while (sym_lookahead == T_TIMES ||
				 sym_lookahead == T_DIV ||
				 sym_lookahead == T_AND ) {
		remember_op = sym_lookahead;
		match(sym_lookahead);
		compile_super_term();
		
		if (remember_op == T_TIMES)
			gen_instr(MULT, _, __);
		else if (remember_op == T_DIV)
			gen_instr(DIV, _, __);
		else	/* remember_op == T_AND */
			gen_instr(AND, _, __);
	}

	#if qTraceCompiler
	exi("compile_term");
	#endif
}

void compile_super_term()
{
	#if qTraceCompiler
	enter("compile_super_term");
	#endif

	compile_factor();
	if (sym_lookahead == T_XPWRY) {
		match(T_XPWRY);
		compile_factor();
		gen_instr(XPWRY, _, __);
	}

	#if qTraceCompiler
	exi("compile_super_term");
	#endif
}

void compile_factor()
{
	#if qTraceCompiler
	enter("compile_factor");
	#endif

	switch(sym_lookahead) {
		case T_CONST:
			match(T_CONST);
			gen_instr(PUSHC, _, numconst);
			break;
		case T_ID:
#if qFuncDefs
			match(T_ID);
			if (st[last_var].func_name)				/* parsing a function call */
				compile_function_call();
			else															/* it is a plain variable */
				gen_push(last_var);
#else
			match(T_ID);
			gen_instr(PUSH, st[last_var].address, __);
#endif
			break;
		case T_LPAR:
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			break;
		case T_NOT:
			match(T_NOT);
			compile_factor();
			gen_instr(NOT, _, __);
			break;
		case T_MACSQRT:
			match(T_MACSQRT);
			compile_expr();
			gen_instr(SQRT, _, __);
			break;

/* 8/2/90: Wrong!! it should be handled in compile_super_term.
		case T_XPWRY:
			match(T_XPWRY);
			compile_expr();
			gen_instr(XPWRY, _, __);
			break;
*/
		case T_EXP:
			match(T_EXP);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(EXP, _, __);
			break;
		case T_SIN:
			match(T_SIN);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(SIN, _, __);
			break;
		case T_COS:
			match(T_COS);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(COS, _, __);
			break;
		case T_TAN:
			match(T_TAN);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(TAN, _, __);
			break;
		case T_SQRT:
			match(T_SQRT);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(SQRT, _, __);
			break;
		case T_ABS:
			match(T_ABS);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(ABS, _, __);
			break;
		case T_SIGN:
			match(T_SIGN);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(SIGN, _, __);
			break;
		case T_LOG:
			match(T_LOG);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(LOG, _, __);
			break;
		case T_LN:
			match(T_LN);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(LN, _, __);
			break;
		case T_ATN:
			match(T_ATN);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(ATN, _, __);
			break;
		case T_SQR:
			match(T_SQR);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(SQR, _, __);
			break;
		case T_CUBE:
			match(T_CUBE);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(CUBE, _, __);
			break;
		case T_INT:
			match(T_INT);
			match(T_LPAR);
			compile_expr();
			match(T_RPAR);
			gen_instr(INT, _, __);
			break;
						
		default:
			compiler_error(SYNTAX_ERROR);
			break;
	}

	#if qTraceCompiler
	exi("compile_factor");
	#endif
}

#if qDebug 

	/* mostra il contenuto del segmento di codice */
	extern char *instr_name[];
	
	void dump_codeseg()
	{
		short i, instr;
		char s[500];

		for (i=0; i<curr_addr; i++) {
			switch (instr_len[instr=codeseg[i]]) {
				case SHORT:
					sprintf(s, "%-3d %-7s", i, instr_name[codeseg[i]]);
					break;

				case MED:
					if (instr == PUSH || instr == COPY || instr == POP || instr == INCR ||
							instr == PRINT)						
					/* take var name from the symbol table */
					{
						char *var_name;
						short st_position;
						
						st_position = lookup_address(codeseg[i+1]);
						var_name = st_position ? st[st_position].name : "???";
						sprintf(s, "%-3d %-7s %.20s", i, instr_name[codeseg[i]], var_name);
					}
					else
						sprintf(s, "%-3d %-7s %-3d", i, instr_name[codeseg[i]], codeseg[i+1]);					
					i++;
					break;

				default:	/* LONG */
					sprintf(s, "%-3d %-7s %g", i, instr_name[codeseg[i]], *((extended *) (codeseg+i+1)));
					i += sizeof(extended)/sizeof(short);
					break;
			}
			DEBUGWRITELN(c2pstr(s));
		}
	}

#endif qDebug

#if qFuncDefs
/* ------------------------------------------------------------------------------ */
/*	
	SET_BIT -- sets to 1 the "pos" bit of the "word"
*/
#define SET_BIT(word, pos)  ((word) |= 1 << (pos))

/* ------------------------------------------------------------------------------ */
/*	
	GET_BIT -- returns the value of the "pos" bit of the "word"
*/
#define GET_BIT(word, pos)  ((word) & (1 << (pos)))

/* ------------------------------------------------------------------------------ */
/*
	compile_func_declaration -- Unfortulately here we need to do rather
	complicated sym table manipulation. We create all function arguments as
	non-global symbol (ie. st[last_entry].global is turned off.) So we can
	erase them from the st when the function declaration ends. We need to
	remember in an array the positions in the symbol table of the 
	function arguments. This is needed because we can only back-patch the
	addresses of the arguments when we know how many arguments there are.
	This is a service that should eventually migrate in the symbol table
	code. 
*/
void compile_func_declaration()
{
	int goto_address;
	int n_args = 0;
	int n_locals=0;
	int func_name_pos_in_st;
	short func_args_pos_in_st[MAX_USER_FUNC_ARGS+1]; /* +1 is to allow to be used as a
																											1-offset vector */
	#if qTraceCompiler
	enter("compile_func_declaration");
	#endif

	identifier_is_func_name = true;
	identifier_must_be_unique = true;
	match(T_FUNCTION);
	match(T_ID);
	identifier_is_func_name = false;
	identifier_must_be_unique = false;
	st[last_var].function_being_defined = true;
	st[last_var].arg_map = 0;
	func_name_pos_in_st = last_var;
	
	/* parse function header */
	identifiers_are_global = false;				/* must change identifiers_are_global
																					 before calling match(T_LPAR) or
																					 the symbol lookahead will be global. */
	match(T_LPAR);
	n_args = 0;
	do {
		n_args++;
		if (n_args > MAX_USER_FUNC_ARGS)
			compiler_error(TOO_MANY_ARGS_IN_USER_FUNCTION);
		
		#if xqDebug
		{ char s[255];
			sprintf(s, "func_decl: parsing hdr, arg %d, pos. in st %d", n_args, 
				func_args_pos_in_st[n_args]);
			DEBUGWRITELN(c2pstr(s));
		}
		#endif
		
		if (sym_lookahead == T_FUNCTION) {	/* this arg is a function arg */
			int its_n_args, its_st_pos;

			/* Mark the type of this argument */			
			SET_BIT(st[func_name_pos_in_st].arg_map, n_args-1);

			#if xqDebug
			{ char s[255];
				sprintf(s, "func_decl: this is a func arg, arg %d, pos. in st %d", n_args, 
					func_args_pos_in_st[n_args]);
				DEBUGWRITELN(c2pstr(s));
			}
			#endif
			identifier_is_func_name = true;
			match(T_FUNCTION);
			func_args_pos_in_st[n_args] = last_var;
			match(T_ID);
			identifier_is_func_name = false;
			its_st_pos = last_var;
			
			/* parse arg list of function argument */
			match(T_LPAR);
			its_n_args = 0;
			do {
				its_n_args++;
				if (its_n_args > MAX_USER_FUNC_ARGS)
					compiler_error(TOO_MANY_ARGS_IN_USER_FUNCTION);
				match(T_ID);
			}	while (sym_lookahead == T_COMMA && match(T_COMMA));
			match(T_RPAR);
			st[its_st_pos].n_args = its_n_args;
			st[its_st_pos].arg_map = 0; /* functional argument cannot have functional
																		 arguments themselves */
		}
		else {														/* this arg is a plain simple numeric arg */
			func_args_pos_in_st[n_args] = last_var;
			match(T_ID);
		}
		
	} while (sym_lookahead == T_COMMA && match(T_COMMA));
	
	match(T_RPAR);
	match(T_SEMICOLON);
	st[func_name_pos_in_st].n_args = n_args;
	
	#if qDebug
	{
		char s[200];
		sprintf(s, "compile_f_decl: arg_map for %s function (pos_in_st=%d) is %d",
			st[func_name_pos_in_st].name, 
			func_name_pos_in_st, st[func_name_pos_in_st].arg_map);
		DEBUGWRITELN(c2pstr(s));
	}
	#endif
	
	/* Start compiling the function */
	/* goto is needed to make sure function is entered only with a JSR */
	goto_address = curr_addr;
	gen_instr(GOTO, _, __);
	st[func_name_pos_in_st].address = curr_addr;		/* func start is after the goto */
	
	/* compile local var list */
	if (sym_lookahead == T_VAR) {
		match(T_VAR);
		do {
			n_locals++;
			st[last_var].address = n_locals;
			match(T_ID);
		} while (sym_lookahead == T_COMMA && match(T_COMMA));
		match(T_SEMICOLON);
		gen_instr(POPN, -n_locals, __);		/* allocate stack space for locals */
	}
	
	identifiers_are_global = true;			/* don't move this from here! */

	#if xqDebug
	DEBUGWRITELN("\pBefore backpatching");
	dump_st();
	#endif

	/* Now that we know how many args there are, back-patch the addresses */
	{
		int i;
		for (i=1; i<=n_args; i++) {
			st[func_args_pos_in_st[i]].address = i - n_args - 2;
			#if xqDebug
			{ char s[255];
				sprintf(s, 
					"func_decl: backpatching addrs, arg %d, pos. in st. %d, its addr %d",
					i, func_args_pos_in_st[i], st[func_args_pos_in_st[i]].address);
				DEBUGWRITELN(c2pstr(s));
			}
			#endif
		}
	}
	
	#if xqDebug
	DEBUGWRITELN("\pafter backpatching");
	dump_st();
	#endif

	compile_compound_statement();							/* compile the function body */
	if (n_locals>0)
		gen_instr(POPN, n_locals, __);					/* clear locals from stack */
	gen_instr(RTS, _, __);
	patch_address(goto_address, curr_addr);
	st[func_name_pos_in_st].function_being_defined = false;
	
	remove_non_globals_from_st();
	#if xqDebug
	DEBUGWRITELN("\pAt funcdecl exit");
	dump_st();
	#endif

	#if qTraceCompiler
	exi("compile_func_declaration");
	#endif
}

void compile_function_call()
{
	int func_addr;
	int n_args = 0;
	int expected_n_args;
	int func_name_is_global;
	unsigned short arg_map;
	
	#if qTraceCompiler
	enter("compile_function_call");
	#endif

	/* match(T_ID); is already been called */
	func_addr = st[last_var].address;
	expected_n_args = st[last_var].n_args;
	arg_map = st[last_var].arg_map;
	func_name_is_global = st[last_var].global;
	
	#if qDebug
	{
		char s[200];
		sprintf(s, "compile_f_call: arg_map for %s function (pos_in_st=%d) is %d, arg_map=%d",
			st[last_var].name, last_var, st[last_var].arg_map, arg_map);
		DEBUGWRITELN(c2pstr(s));
	}
	#endif

	/* push one position to make room for return value */
	gen_instr(POPN, -1, __);
	
	/* parse arguments and push values onto stack */
	match(T_LPAR);
	n_args = 0;
	do {
		if (++n_args > expected_n_args)
			compiler_error(WRONG_NUMBER_OF_ARGS);
			
		if (GET_BIT(arg_map, n_args-1)) { 		/* push function address */
			match(T_ID);
			if (!st[last_var].func_name)
				compiler_error(FUNC_NAME_EXPECTED);
			if (st[last_var].global)
				gen_instr(PUSHC, _, st[last_var].address);
			else
				/* Take the address of the function from the stack */
				gen_instr(PUSHBB, st[last_var].address, __);
		}
		else
			compile_expr();
	} while (sym_lookahead == T_COMMA && match(T_COMMA));
	match(T_RPAR);
		
	if (n_args != expected_n_args)
		compiler_error(WRONG_NUMBER_OF_ARGS);	
	
	if (func_name_is_global)						/* jump to the function */
		gen_instr(JSR, func_addr, __);		/* func address is absolute */
	else
		gen_instr(JSRBB, func_addr, __);	/* func addr is bb-relative */
	gen_instr(POPN, n_args, __);				/* clear arguments from stack */

	#if qTraceCompiler
	exi("compile_function_call");
	#endif
}
#endif

void gen_pop(int st_pointer)
{
	if (st[st_pointer].global)
		gen_instr(POP, st[st_pointer].address, __);
	else
		gen_instr(POPBB, st[st_pointer].address, __);
}

void gen_push(int st_pointer)
{
	if (st[st_pointer].global)
		gen_instr(PUSH, st[st_pointer].address, __);
	else
		gen_instr(PUSHBB, st[st_pointer].address, __);
}

void gen_jsr(int st_pointer)
{
	if (st[st_pointer].global)
		gen_instr(JSR, st[st_pointer].address, __);
	else
		gen_instr(JSRBB, st[st_pointer].address, __);
}

void gen_incr(int st_pointer)
{
	if (st[st_pointer].global)
		gen_instr(INCR, st[st_pointer].address, __);
	else
		gen_instr(INCRBB, st[st_pointer].address, __);
}
