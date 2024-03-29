/*
	File compiler_error.c
	
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

/* 
	questo file contiene la procedura "compiler_error", che deve
	notificare all'utente che il modulo compilatore-interprete ha 
	dato un errore.  Siccome questa procedura e' l'unica
	parte non portabile del modulo, l'ho messa in un file a se'.
*/

#include <ToolUtils.h>
#include <setjmp.h>
#include <stdio.h>
#include <strings.h>
#include "macapp.h"
#include "compint.h"
#include "Declarations.r"		/* resources stuff */

#pragma segment ACompileUserModel

void compiler_error(code)
short code;
{
	#if qDebug
	/*
		dump_st();
		PROGRAMBREAK("\p");
	*/
	#else
	/* dump_st();
		 	Debugger(); */
	#endif

	GetIndString(error_msg, kCompilerMsgs, code);
	compiler_state = code;	
	longjmp(env, 1);
}

void match_error(what)
short what;
{
	Str255 IWasExpecting, tokenName;
	
	if (what == T_ID)
		compiler_error(EXPECTING_NAME);
	
	#if qDebug
	/*
		dump_st();
		PROGRAMBREAK("\p");
	*/
	#else
	/*	dump_st();
		Debugger(); */
	#endif

	/* forma la stringa del tipo "mi aspettavo ..." */
	GetIndString(IWasExpecting, kCompilerMsgs, I_WAS_EXPECTING);
	GetIndString(tokenName, kCompilerTokenNames, what);
	sprintf(error_msg, "%P �%P�", IWasExpecting, tokenName);
	c2pstr(error_msg);
	
	compiler_state = SYNTAX_ERROR;
	longjmp(env, 1);
}
