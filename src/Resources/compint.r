/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989 Matteo Vaccari & Mario Negri Institute
*/

/* � Auto-Include the requirements for this source */
#ifndef __TYPES.R__
#include "Types.r"
#endif

#ifndef __SYSTYPES.R__
#include "SysTypes.r"
#endif

#ifndef __ViewTypes__
#include "ViewTypes.r"
#endif

/* include my definitions */
#include "Declarations.r"

resource 'STR#' (kCompilerMsgs, 
#if qNames
"Compiler error msgs",
#endif
purgeable) {
	{
		/* 1 */ "Syntax error.",
		/* 2 */ "This model is too long.",
		/* 3 */ "Code ends before expected.",
		/* 4 */ "Syntax error.",
		/* 5 */ "Illegal character.",
		/* 6 */ "Too many names.",
		/* 7 */ "Variables names too long.",
		/* 8 */ "Too many parameters.",
		/* 9  */ "Too many variables.",
		/* 10 */ "I was expecting",
		/* 11 */ "No parameters in the model.",
		/* 12 */ "Wrong number of arguments.",
		/* 13 */ "Too many arguments.",
		/* 14 */ "Can't assign to this",
		/* 15 */ "I was expecting a name.", 
		/* 16 */ "Name already defined.",
		/* 17 */ "I was expecting a function name.",
	}
};

resource 'STR#' (kCompilerTokenNames,
#if qNames
"Compiler token names",
#endif
purgeable) {
	{	/* array StringArray: 44 elements */
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
		"***",
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
		"",
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
		"",
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
	}
};

