/*
	File compint_globals.c
	
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "compint.h"

short instr_len[] = {
	LONG,		/* pushc */
	MED,		/* push	*/
	MED,		/* copy	*/
	SHORT,	/* exit */
	MED,		/* pop */
	SHORT,	/* pop1 */
	MED, 		/* bnz */
	MED, 		/* blt */
	MED, 		/* goto */
	MED,		/* bz */
	MED, 		/* incr */
	
	SHORT, SHORT, SHORT, SHORT,
	SHORT, SHORT, SHORT, SHORT, SHORT,
	SHORT, SHORT, SHORT, SHORT, SHORT,
	SHORT, SHORT, SHORT, SHORT, SHORT,
	SHORT, SHORT, SHORT, SHORT, SHORT,
	
	SHORT,	/* not */
	SHORT,	/* beep */
	SHORT,	/* sqr */
	SHORT,	/* cube */
	MED,		/* print */
	SHORT		/* int */
#if qFuncDefs
	,
	MED,		/* pushbb */
	MED,		/* popbb */
	MED,		/* popn */
	MED,		/* jsr */
	SHORT,	/* rts */
	MED,		/* jsrbb */
	MED, 		/* printbb */
	MED,		/* incrbb */
#endif
	};

/* puntatore all'input ancora da riconoscere */
char *input;

/* serve alla setjmp */
jmp_buf env;

/* il numero di parametri nel modello utente */
int user_model_params;

/* Regard this as a Boolean value, true iff the user model contains a PRINT
	instruction.*/ 
int model_may_change_focus;

/* usata dalle routine in compiler_error.c per passare una stringa appropriata
	alla routine "compiler" in caso di errore */
Str255 error_msg;

#if qDebug
	char *instr_name[] = {
	"PUSHC",
	"PUSH",
	"COPY",
	"EXIT",
	"POP",
	"POP1",
	"BNZ",
	"BLT",
	"GOTO",
	"BZ",
	"INCR",
	"ADD",
	"SUB",
	"UMINUS",
	"MULT",
	"DIV",
	"EXP",
	"SIN",
	"COS",
	"TAN",
	"XPWRY",
	"SQRT",
	"GT",
	"GTE",
	"LT",
	"LTE",
	"NEQ",
	"EQ",
	"ABS",
	"SIGN",
	"LOG",
	"LN",
	"ATN",
	"OR",
	"AND",
	"NOT",
	"BEEP",
	"SQR",
	"CUBE",
	"PRINT",
	"INT"
#if qFuncDefs
	,
	"PUSHBB",
	"POPBB",
	"POPN",
	"JSR",
	"RTS",
	"JSRBB",
	"PRINTBB",
	"INCRBB"
#endif
	} ;
#endif qDebug
