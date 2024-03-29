/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

/* local procs. */
static extended enforce_constraints(
						   extended params[],
						   extended direction[],
						   extended tempParams[]);

/* ----------------------------------------------------------------------------- */
/*
		computeParams
			Calcola i nuovi valori dei parametri, salvando i vecchi in oldParams.
			Calcola la grandezza del passo.
			Calcola la nuova somma e la confronta somma con la somma
			precedente.
			Restituisce
				SUM_LOWER_OR_EQUAL se la somma e' migliorata,
				SUM_GREATER viceversa.

			6/11/89: corretto baco: quando il primo passo della ricerca
			fallisce, applica marquardt e deve ricalcolare sqrtHessDiag.
			Prima non lo faceva, ora si'.
			
			14/09/90: Se capita NO_SOLUTIONS ora fa una longjmp anziche' restituire
			NO_SOLUTIONS			
*/

#include <OSUtils.h>		/* sysbeep() */
#include "fit.h"

int computeParams(extended		params[],
									extended 		*pSum,
									extended 		oldSum,
									extended		oldParams[])
{
	int resultOfLinearSearch1;
	extended stepSize;			/* contiene la dimensione del passo.  */

#if qDebug
		newline;
		writeln("CompParams: entering, HessMat =");
		printMatrix(HessMat, NParams);
#endif

	for(;;) {
		/* otteniamo la direzione della ricerca mediante la risoluzione
			del sistema lineare H*g = dir.  Il sistema dovrebbe
			essere sempre risolubile, dato che abbiamo gia'
			fatto un test sulla grandezza del determinante della H.
			L'unico caso in cui solveLinearSystem dovrebbe poter restituire
			un errore e' se ci sono dei NAN nella matrice hessiana. */
		if (solveLinearSystem(direction, tempMat, HessMat, gradient, NParams, indx))
			longjmp(setjmp_env, NO_SOLUTIONS);

#if qELS		
		if (!useELS)
#endif
			scaleSolution(direction);

#if xqDebug
		newline;
		writeln("XX CompParams: direction is:");
		printVector(direction, 0, NParams -1);
#endif
		
		/* ora applichiamo un trucchetto per velocizzare al max
			questa procedura: dato che la ricerca lineare viene
			fatta esaminando in successione i punti
					params + alfa * direction,
			ove alfa e' uno scalare che vale 1/3, 2/3, 3/3, ...
			e cresce sempre di un terzo, noi risparmiamo
			un sacco di moltiplicazioni floating point con il
			seguente schema:
				tempParams := params;
				direction := direction * 1/3;

				[...]

				tempParams := tempParams + direction;
				[...]
				tempParams := tempParams + direction;
				[...]
				tempParams := tempParams + direction;
				[...]

			Cioe' noi moltiplichiamo solo una volta il vettore
			direction per 1/3, dopodiche' continuiamo a sommare
			direction a tempParams.
			Cio' rende meno modulari le procedure linearSearch step 1 e 2,
			perche' devono confidare che qui tempParams e direction
			vengano opportunamente inizializzati qui. D'altronde questo
			codice viene eseguito tante volte da giustificare
			la perdita di chiarezza in cambio di una maggiore efficienza.
			Questo trucchetto puo' essere tolto eliminando la
			#define SPEEDUP 1 all'inizio. */

#if SPEEDUP
		copyVector(tempParams, params, NParams);
		scalarMultiply(direction, 1.0/3.0, NParams);
#endif

		resultOfLinearSearch1	=	linearSearchStep1(
#if !SPEEDUP
																							params,
#endif
																							pSum);

#if xqDebug
		{
			char s[255];
			switch(resultOfLinearSearch1) {
				case INVALID_FIRST_TRY:				sprintf(s, "INVALID_FIRST_TRY"); break;
				case OVERFLOW_IN_LIN_SEARCH:	sprintf(s, "OVERFLOW_IN_LIN_SEARCH"); break;
				case ONE_THIRD:								sprintf(s, "ONE_THIRD"); break;
				case TWO_THIRDS: 							sprintf(s, "TWO_THIRDS"); break;
				case ONE: 										sprintf(s, "ONE"); break;
				default: 											sprintf(s, "??? (%d)", resultOfLinearSearch1); break;
			}	
			sprintf(msgStr, "XX CompParams: resultOfLinearSearch1 is %s", s);
			writeln(msgStr);
			newline;
		}
#endif
		
		if (resultOfLinearSearch1 == OVERFLOW_IN_LIN_SEARCH) {
			lambda = 100.0;
			marquardt();
			computeSqrtHessDiag();
		}
		else {
			break;
		}
	}

	switch (resultOfLinearSearch1) {
#if qConstraints
		case INVALID_FIRST_TRY:
			stepSize =
				enforce_constraints(params,
														direction,
														tempParams);
			break;
#endif
		case ONE_THIRD:
			stepSize = 1.0/3.0;
			break;
		case TWO_THIRDS:
			stepSize = 2.0/3.0;
			break;
		case ONE:
			stepSize =
				linearSearchStep2(
#if !SPEEDUP
													params,
#endif
													pSum);
			break;
	}

/*
**	mette da parte i parametri dell' iterazione precedente.
**	Cio' per poterli riprendere
**	nel caso che in questo passo la somma non risulti decrescere.
*/
	copyVector(oldParams, params, NParams);

#if SPEEDUP
	stepSize *= 3.0;
#endif

	updateParams(params, direction, stepSize, NParams);

#if xqDebug
	sprintf(msgStr, "XX CompParams exiting; new sum: %.19g; old sum: %.19g",*pSum, oldSum);
	writeln(msgStr);
#endif

	/* It is VERY important that the test *pSum <= oldSum is spelled exactly 
		 this way. Because if *pSum is NAN, the value returned will be SUM_GREATER,
		 and the algorythm will try to go closer to the gradient. This gives no
		 guarantee that the model will evaluate non-nan; but it is often so.
		 This way the fitting is more robust for cases where the model sometimes
		 gets evaluated NAN. Typical example: subtraction between exponentials.
		 If both exponential get evaluated as INF, the result will be NAN. Of
		 course it would be best for the user to avoid these conditions with
		 tests in the user model code. */
	return (*pSum <= oldSum ? SUM_LOWER_OR_EQUAL : SUM_GREATER);
}


#if qConstraints
/* ------------------------------------------------------------------------------- */
/*
	This function is called when the first step of the linear search fails 
	because the first try is invalid (that is, oldParams +alfa*1/3 is invalid).
	This function must be passed
		- the original, valid parameters of the previous iteration
		- the direction of the linear search
	This functions outputs
		- a valid, point between the oldParams and the oldParams+alfa*1/3,
			on the direction of the search. If it can't find any such point, an
			error is called and the function is exited via longjmp.
		- the sum at such a point.
		
	The tempParams vector is used as a scratch vector.
*/
extended enforce_constraints(
						   extended params[],
						   extended direction[],
						   extended tempParams[])
{
	extended step, i;
	
	step = 1.0/3.0;
	copyVector(tempParams, params, NParams);
	updateParams(tempParams, direction, step, NParams);
	for(i=2.0; invalid_point(tempParams); i += 1.0) {

		/* Retry with a shorter step */
		updateParams(tempParams, direction, step/i, NParams);

		if (i>50.0)
			longjmp(setjmp_env, CONSTRAINTS_LOOP_ERROR);
	}
	
	return step/i;
}
#endif qConstraints

