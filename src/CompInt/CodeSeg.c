/*
	File CodeSeg.c
	
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "compint.h"

#pragma segment ACompileUserModel

/* l' array che ospita il codice */
short codeseg[CODESEG_SIZE];

/* la posizione del codeseg in cui andra' scritta la prossima istr. */
short curr_addr = 0;

/* serve a correggere l'argomento di un goto rimasto pendente */
void patch_address(where, what)
short where, what;
{
	codeseg[where+1] = what;
}

/* gen_instr - genera una istruzione; si aspetta che 
	curr_addr punti alla cella di codice in cui deve scrivere */
void gen_instr(instr_code, int_arg, ext_arg)
short instr_code, int_arg;
extended ext_arg;
{
	short len;
	
	len = instr_len[instr_code];
	if (curr_addr + len >= CODESEG_SIZE)
		compiler_error(TOO_MUCH_CODE);
		
	codeseg[curr_addr++] = instr_code;
	
	/* aggiunge l'argomento */
	switch (len) {
		case SHORT: break;
		case MED: 	codeseg[curr_addr++] = int_arg;
								break;
		case LONG:	/* gabola per mettere un extended nel codice */
								*((extended *) (codeseg + curr_addr)) = ext_arg;
								curr_addr += sizeof(extended) / sizeof(short);
								break;
	}
}
