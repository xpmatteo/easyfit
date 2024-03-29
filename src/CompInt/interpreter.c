/*
	File CodeSeg.c
	
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include <stdio.h>
#include <math.h>
#include <errors.h>
#include <OSUtils.h>
#include "macapp.h"
#include "compint.h"
#include "declarations.r"
#include "m_indep.h"

/* Used here and there. */
#define CHECK_FOR_INTERRUPT	\
	if (POLLEVENT()) Failure(kUserInterruptedFit,0);

/*
	Do not change this segment!!! we need to make sure that "interpret" never gets 
	purged.
*/
#pragma segment ARes

#define OneOverLogOf10		0.43429448190325182760
#define log10(x)					(log(x) * OneOverLogOf10)

/* variabili   --- p u b b l i c h e --- */

/* lo spazio per le variabili */
extended dataseg[DATASEG_SIZE];

/* variabili   --- p r i v a t e --- */

/* lo stack */
static extended stack[STACK_SIZE];

/* lo stack pointer */
static short sp;

/* il program counter */
static pc;

#if qFuncDefs
/* the block base */
static bb;
#endif

#define INC_STACK if (++sp >= STACK_SIZE) Failure(kFormulaTooComplex, 0)

/* esegue una istruzione.  restituisce != 0 se la esecuzione del
	programma deve per qualche motivo finire */
short interpret_instr()
{
#if xqDebug
	{
		Str255 s;
		extern char *instr_name[];
		sprintf(s, "interpret_instr: pc=%d, instr=%8s, sp=%d, bb=%d, x=%g, p1=%g, p2=%g, y=%g",
						pc, instr_name[codeseg[pc]], sp, bb, dataseg[21], dataseg[1], dataseg[2],
						dataseg[0]);
		DEBUGWRITELN((Str255) c2pstr(s));
		
		if (pc<0 || sp<0 || pc>CODESEG_SIZE || sp>STACK_SIZE)
			PROGRAMBREAK("\pinterpret_instr: illegal value in register pc and/or sp");
	}
#endif
	
	switch(codeseg[pc]) {
		case PUSHC: /* prendi il valore direttamente dal codice */
			pc++;
			INC_STACK;
			stack[sp] = *((extended *) (codeseg + pc));
			pc += sizeof(extended)/sizeof(short);
			break;
		case PUSH:	/* spingi il valore della variabile */
			pc++;
			INC_STACK;
			stack[sp] = dataseg[codeseg[pc++]];
			break;
		case COPY:	/* copia lo stack senza abbassarlo */
			pc++;
			dataseg[codeseg[pc++]] = stack[sp];
			break;
		case EXIT:	/* termina l'esecuzione */
			return 1;
		case POP:
			pc++;
			dataseg[codeseg[pc++]] = stack[sp--];
			break;
		case POP1:	/* abbassa lo stack senza copiare il valore */
			sp--;
			pc++;
			break;
		case BNZ:
			CHECK_FOR_INTERRUPT
			if (stack[sp--] != 0)
				pc = codeseg[pc+1];
			else
				pc += 2;
			break;
		case BLT:
			CHECK_FOR_INTERRUPT
			sp--;
			if (stack[sp] < stack[sp+1])
				pc = codeseg[pc+1];
			else
				pc += 2;
			break;
		case GOTO:
			CHECK_FOR_INTERRUPT
			pc = codeseg[pc+1];
			break;
		case BZ:
			CHECK_FOR_INTERRUPT
			if (stack[sp--] == 0)
				pc = codeseg[pc+1];
			else
				pc += 2;
			break;
		case INCR:
			pc++;
			/* incrementa la var */
			dataseg[codeseg[pc]]++;
			/* spingi il valore sullo stack */
			INC_STACK;
			stack[sp] = dataseg[codeseg[pc]];
			pc++;
			break;
		case ADD:
			sp--;
			stack[sp] += stack[sp+1];
			pc++;
			break;
		case SUB:
			sp--;
			stack[sp] -= stack[sp+1];
			pc++;
			break;
		case UMINUS:
			stack[sp] *= -1.0;
			pc++;
			break;
		case MULT:
			sp--;
			stack[sp] *= stack[sp+1];
			pc++;
			break;
		case DIV:
			sp--;
			stack[sp] /= stack[sp+1];
			pc++;
			break;
		case EXP:
			stack[sp] = exp(stack[sp]);
			pc++;
			break;
		case SIN:
			stack[sp] = sin(stack[sp]);
			pc++;
			break;
		case COS:
			stack[sp] = cos(stack[sp]);
			pc++;
			break;
		case TAN:
			stack[sp] = tan(stack[sp]);
			pc++;
			break;
		case XPWRY:
			sp--;
			stack[sp] = pow(stack[sp], stack[sp+1]);
			pc++;
			break;
		case SQRT:
			stack[sp] = sqrt(stack[sp]);
			pc++;
			break;
		case GT:
			sp--;
			stack[sp] = (stack[sp] > stack[sp+1]) ? 1.0 : 0.0;
			pc++;
			break;
		case GTE:
			sp--;
			stack[sp] = (stack[sp] >= stack[sp+1]) ? 1.0 : 0.0;
			pc++;
			break;
		case LT:
			sp--;
			stack[sp] = (stack[sp] < stack[sp+1]) ? 1.0 : 0.0;
			pc++;
			break;
		case LTE:
			sp--;
			stack[sp] = (stack[sp] <= stack[sp+1]) ? 1.0 : 0.0;
			pc++;
			break;
		case NEQ:
			sp--;
			stack[sp] = (stack[sp] != stack[sp+1]) ? 1.0 : 0.0;
			pc++;
			break;
		case EQ:
			sp--;
			stack[sp] = (stack[sp] == stack[sp+1]) ? 1.0 : 0.0;
			pc++;
			break;
		case ABS:
			stack[sp] = fabs(stack[sp]);
			pc++;
			break;
		case SIGN:
			stack[sp] = (stack[sp] > 0.0) ? 1.0 :
										((stack[sp] < 0.0) ? -1.0 : 0.0);
			pc++;
			break;
		case LOG:
			stack[sp] = log10(stack[sp]);
			pc++;
			break;
		case LN:
			stack[sp] = log(stack[sp]);
			pc++;
			break;
		case ATN:
			stack[sp] = atan(stack[sp]);
			pc++;
			break;
		case OR:
			sp--;
			stack[sp] = stack[sp]!=0.0 || stack[sp+1]!=0.0 ? 1.0 : 0.0;
			pc++;
			break;
		case AND:
			sp--;
			stack[sp] = stack[sp]!=0.0 && stack[sp+1]!=0.0 ? 1.0 : 0.0;
			pc++;
			break;
		case NOT:
			stack[sp] = stack[sp] == 0.0 ? 1.0 : 0.0;
			pc++;
			break;
		case BEEP:
			SysBeep(50);		/* Mac OS utility */
			pc++;
			break;
		case SQR:
			stack[sp] *= stack[sp];
			pc++;
			break;
		case CUBE:
			{
				extended tmp;
				tmp = stack[sp];
				stack[sp] = tmp*tmp*tmp;
				pc++;
			}
			break;
		case PRINT:
			{
				union {
					extended e;
					char s[sizeof(extended)];
				} var_name;
				
				var_name.e = stack[sp--];						/* get var name from stack */
				pc++;
				sprintf(error_msg, 
								"User Model: %s = %.20g",
								var_name.s,
								dataseg[codeseg[pc++]]);		/* get var addr from argument */
				writeln(error_msg);
				synch;
			}
			break;
		case INT:
#if macintosh													/* use SANE functions */
			{
				rounddir d = getround();			/* save current rounding direction */
				setround(TOWARDZERO);					/* set rounding dir toward zero */
				stack[sp] = rint(stack[sp]);	/* round to integer value */
				setround(d);									/* restore original rounding dir */
			}
#else																	/* use std C lib funcs for compatibility */
			if (stack[sp] < 0.0)
				stack[sp] = ceil(stack[sp]);
			else
				stack[sp] = floor(stack[sp]);
#endif
			pc++;
			break;

#if qFuncDefs
		case PUSHBB:
			/* push into stack value found relative to bb */
			pc++;
			INC_STACK;
			stack[sp] = stack[bb + codeseg[pc++]];
			break;
		case POPBB:
			/* pop top value of stack into address found relative to bb */
			pc++;
			stack[bb + codeseg[pc++]] = stack[sp--];
			break;
		case POPN:
			/* POP n times without copying values */
			sp -= codeseg[++pc];
			if (sp>STACK_SIZE)
				Failure(kFormulaTooComplex, 0);
#if qDebug
			if (sp<0)
				PROGRAMBREAK("\ppopn: sp < 0");
#endif
			pc++;
			break;
		case JSR:
			#if qDebug
			{
				char s[150];
				sprintf(s, "jsr: push return address %d at stack position %d", pc+2, sp+1);
				DEBUGWRITELN(c2pstr(s));
			}
			#endif
			INC_STACK;								/* push return addr */
			stack[sp] = pc+2;
			INC_STACK;								/* push old bb value */
			stack[sp] = bb;
			bb = sp;									/* set new value of bb */
			pc = codeseg[pc+1];				/* jump to subroutine */
			break;

		case RTS:			
			#if xqDebug
			{
				char s[200];
				sprintf(s, "rts: entering, pc = %d, bb = %d", pc, bb);
				DEBUGWRITELN(c2pstr(s));
				dump_stack();
			}
			#endif
			{
				extended e;
				e = stack[bb-1];				/* restore pc */
				pc = e;					
				e = stack[bb];					/* restore old value of bb */
				bb = e;
			}
			sp -= 2;									/* clean ret addr and old bb from stack */
			#if xqDebug
			{
				char s[200];
				sprintf(s, "rts: exiting, pc = %d, bb = %d", pc, bb);
				PROGRAMBREAK(c2pstr(s));
			}
			#endif
			break;
			
		case JSRBB:
			/* JSR, with func address found relative to bb */
			{
				extended e;
				
				INC_STACK;										/* push return addr */
				stack[sp] = pc+2;
				INC_STACK;										/* push old bb value */
				stack[sp] = bb;
				e = stack[bb+codeseg[pc+1]];	/* jump to subroutine */
				pc = e;
				bb = sp;											/* set new value of bb */
				break;
			}
		case PRINTBB:
			{
				union {
					extended e;
					char s[sizeof(extended)];
				} var_name;
				
				var_name.e = stack[sp--];						/* get var name from stack */
				pc++;
				sprintf(error_msg, 
								"User Model: %s = %.20g",
								var_name.s,
								stack[bb+codeseg[pc++]]);		/* get var addr from argument */
				writeln(error_msg);
				synch;
			}
			break;
			
		case INCRBB:
			pc++;
			stack[bb+codeseg[pc]]++;							/* incrementa la var */
			INC_STACK;														/* spingi il valore sullo stack */
			stack[sp] = stack[bb+codeseg[pc]];
			pc++;
			break;
#endif

		default:
#if qDebug
		{
			char s[100];
			sprintf(s, "Compint: unimplemented instruction %d", codeseg[pc]);
			PROGRAMBREAK(c2pstr(s));
		}
#else
			Failure(-32768, 0);  /* minerr */
#endif
			return 2;
			break;
	}
	return 0;
}

extern pascal extended gExtendedCurrentSubject;
extern pascal extended gDose;

/* questa e' la funzione da chiamare per evocare il modello
	utente; si comporta come i modelli precompilati. 
	Naturalmente e' necessario prima avere invocato il compilatore,
	e che questo abbia lavorato senza intoppi. */
extended interpret(params, x)
extended params[], x;
{
	int i;
	FocusRec savedFocus;
	
	CHECK_FOR_INTERRUPT

#if qFuncDefs
	bb = -1;		/* -1 means we are not into a subroutine */
#endif

	/* copia i valori dei parametri */
	for (i=0; i < user_model_params; i++)
		dataseg[i+1] = params[i];
	
	/* copia il valore della var indipendente	*/
	dataseg[MAX_PARAMS + 1] = x;
	
	/* copia i valori di subject e dose */
	dataseg[MAX_PARAMS + 2] = gExtendedCurrentSubject;
	dataseg[MAX_PARAMS + 3] = gDose;
	
	pc = 0;
	sp = 0;

	#if xqDebug
	dump_stack();
	#endif
	
	if (model_may_change_focus) {			/* true iff the model contains a PRINT instr. */
		savedFocus.clip = MakeNewRgn();
		GetFocus(&savedFocus);					/* preserve the focus */
	}
	
	while(interpret_instr() == 0)
			#if xqDebug
			dump_stack()
			#endif
		;

	if (model_may_change_focus) {
		SetFocus(&savedFocus);
		DisposeRgn(savedFocus.clip);
	}

#if xqDebug
	{
		Str255 s;
		sprintf(s, "interpret: exiting, pc=%d, sp=%d, bb=%d, x=%g, p1=%g, p2=%g, y=%g",
						pc, sp, bb, dataseg[21], dataseg[1], dataseg[2], dataseg[0]);
		DEBUGWRITELN((Str255) c2pstr(s));
	}
#endif	
	
	/* restituisci il valore di y */
	return dataseg[0];
}

#if qDebug
dump_stack()
{
	int i;
	char s[200];
	
	DEBUGWRITELN("\p..stack dump:");
	for (i=sp; i>=0; i--) {
		sprintf(s, "..%2d) %g", i, stack[i]);
		DEBUGWRITELN(c2pstr(s));
	}
}
#endif