/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/
#include <types.h>

main(argv, argc)
char **argv;
{
	Str255 err;
	int nParams, where;
	short result, compile();
	
	printf("argv[1] is %s\n", argv[1]);
	
	result = compile(argv[1], &where, err, &nParams);
	
	printf("result %d; where %d, msg %s, nPars %d\n", result, where, err, nParams);
	
	exit(0);
}

void match_error(what)
short what;
{
	Str255 IWasExpecting, tokenName;
	
	/* forma la stringa del tipo "mi aspettavo ..." */
	GetIndString(IWasExpecting, kCompilerMsgs, SYNTAX_ERROR);
	GetIndString(tokenName, kCompilerTokenNames, what);
	sprintf(error_msg, "%P %P", IWasExpecting, tokenName);
	c2pstr(error_msg);
	
	compiler_state = SYNTAX_ERROR;
	longjmp(env, 1);
}
