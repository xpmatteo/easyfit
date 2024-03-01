/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	----------------

	Modelli precompilati.  Ogni volta che ne aggiungi o togli o
	cambi uno devi:
		- aggiornare la costante intera che lo identifica in
			FitGlob.p e fit.h
		- aggiornare lo switch di inizializzazione della variabile
			"model" del C, nell'inizio della procedure C "fit"
		- fornire la dichiarazione all'inizio del file "fit.c"


	13/12/89: Added a peeling function to each model, that knows
	how to call the general peeling function for thta model.
	This is the interface to that peeling function:

		int peel_model(X, Y, NObservations, params, sqrtWeights, weightsOption, cutPoint)
		extended X[], Y[], params[], sqrtWeights[];
		int NObservations, weightsOption, *cutPoint;

	X, Y, NObservations, sqrtWeights, weightsOption are INPUT, with obvious meaning.
	params is OUTPUT, and contains the estiamates.
	cutPoint is OUTPUT, and contains the chosen cut point.
	The function result is zero if the peeling worked, or non-zero if it didn't.
	Note: if it doesn't work, it's because of bad fit of the model to the data.
	There isn't much you can do, apart from changing either.
	
	21/1/90: Added "interpret" entry to gModelFunc; 
	added SetUserModelNParams function
	
	24/1/90: Corrected bug: gPeelFunction was declared as an array of func_ptr
		i.e. ptr to function that returns extended. Wrong!!! they return a short !!!
	20/9/90: Now they return an int.
	
	21/9/90: Added PollEvent call in all models
*/

#include <math.h>
#include <memory.h>
#include "MacApp.h"
#include "fit.h"

/*
 	NOTE: NEVER change this segment !!! we need to make sure that the addresses of
	these functions never change.
*/
#pragma segment ARes

typedef int (*int_function)();

/* we declare that an "interpret" function exists somewhere */
extended interpret();

extended single_exp(par, x)
extended par[], x;
{
	CHECK_FOR_INTERRUPT
	return par[0] * exp(x * -par[1]);
}

int
peel_single_exp(X, Y, NObservations, params, sqrtWeights, weightsOption, cutPoint)
extended X[], Y[], params[], sqrtWeights[];
int NObservations, weightsOption, *cutPoint;
{
			return	 Peeling(X,
											 Y,
											 NObservations,
											 1,			/* number of exponentials */
											 1,			/* sign of fastest exp. */
											 params,
											 cutPoint,
											 sqrtWeights,
											 weightsOption);
}

extended two_exp_plus(par, x)
extended par[], x;
{
	CHECK_FOR_INTERRUPT
	return par[0] * exp(x * -par[1])
			+
		   par[2] * exp(x * -par[3]);
}

int
peel_two_exp_plus(X, Y, NObservations, params, sqrtWeights, weightsOption, cutPoint)
extended X[], Y[], params[], sqrtWeights[];
int NObservations, weightsOption, *cutPoint;
{
			return	 Peeling(X,
											 Y,
											 NObservations,
											 2,							/* number of exponentials */
											 1,							/* sign of fastest exp. */
											 params,
											 cutPoint,
											 sqrtWeights,
											 weightsOption);
}


extended two_exp_minus(par, x)
extended par[], x;
{
	CHECK_FOR_INTERRUPT
	return -par[0] * exp(x * -par[1])
			+
		   par[2] * exp(x * -par[3]);
}

int
peel_two_exp_minus(X, Y, NObservations, params, sqrtWeights, weightsOption, cutPoint)
extended X[], Y[], params[], sqrtWeights[];
int NObservations, weightsOption, *cutPoint;
{
			return	 Peeling(X,
											 Y,
											 NObservations,
											 2,							/* number of exponentials */
											 -1,							/* sign of fastest exp. */
											 params,
											 cutPoint,
											 sqrtWeights,
											 weightsOption);
}


extended three_exp_plus(par, x)
extended par[], x;
{
	CHECK_FOR_INTERRUPT
	return par[0] * exp(x * -par[1])
			+
		   par[2] * exp(x * -par[3])
		   	+
		   par[4] * exp(x * -par[5]);
}

int
peel_three_exp_plus(X, Y, NObservations, params, sqrtWeights, weightsOption, cutPoint)
extended X[], Y[], params[], sqrtWeights[];
int NObservations, weightsOption, *cutPoint;
{
			return 	 Peeling(X,
											 Y,
											 NObservations,
											 3,							/* number of exponentials */
											 1,							/* sign of fastest exp. */
											 params,
											 cutPoint,
											 sqrtWeights,
											 weightsOption);
}


extended three_exp_minus(par, x)
extended par[], x;
{
	CHECK_FOR_INTERRUPT
	return -par[0] * exp(x * -par[1])
			+
		   par[2] * exp(x * -par[3])
		   	+
		   par[4] * exp(x * -par[5]);
}

int
peel_three_exp_minus(X, Y, NObservations, params, sqrtWeights, weightsOption, cutPoint)
extended X[], Y[], params[], sqrtWeights[];
int NObservations, weightsOption, *cutPoint;
{
			return	 Peeling(X,
											 Y,
											 NObservations,
											 3,								/* number of exponentials */
											 -1,							/* sign of fastest exp. */
											 params,
											 cutPoint,
											 sqrtWeights,
											 weightsOption);
}


/*
	this one may be used when a peeling function is needed, but the model can't
	be peeled because it is not a sum of exponentials.
*/
int
cant_peel(X, Y, NObservations, params, sqrtWeights, weightsOption, cutPoint)
extended X[], Y[], params[], sqrtWeights[];
int NObservations, weightsOption, *cutPoint;
{
#pragma unused (X, Y, NObservations, params, sqrtWeights, weightsOption, cutPoint)

	return NO_PEELING_FUNC_AVAILABLE;
}


/* These vectors hold information about the models. The first element is just
	padding, since we want "single_exp" to be accessed as element number 1.
	The positions in these arrays correspond to the numbers of the models. */

func_ptr gModelFunc[] = { NULL, single_exp, two_exp_plus, two_exp_minus,
	three_exp_plus, three_exp_minus, interpret };

int_function gPeel_model[] = { NULL, peel_single_exp, peel_two_exp_plus, peel_two_exp_minus,
	peel_three_exp_plus, peel_three_exp_minus, cant_peel };

/* This one holds the number of parameters required by each subject.
	It is expected that the compiler of the user-defined function write the
	number of parameters in this vector after successfully compiling, 
	perhaps using the apposite SetUserModelNParams function. 
	This mechanism is not used when the model selected is external. */

int gNumberOfParams[] = { NULL, 2, 4, 4, 6, 6, 0 };

/* The following functions retrieve values from the above vectors,  for
	the benefit of Pascal */

int get_NumberOfParams(int modelNumber)
{
#if qXMDLs
	int NParams;
	int GetXMDLNParams(Handle);
	Boolean AwakeXMDL(Handle, Boolean);
	Boolean oldState;
	extern pascal Handle gXMDL;
	
	if (modelNumber == kXMDL) {
		oldState = AwakeXMDL(gXMDL, true);
		NParams = GetXMDLNParams(gXMDL);
		AwakeXMDL(gXMDL, oldState);
		return NParams;
	}
	else
#endif
	return gNumberOfParams[modelNumber];
}

func_ptr get_ModelFunc(int modelNumber)
{
#if qXMDLs
	extended CallXMDLModel(extended params[], extended x);

	if (modelNumber == kXMDL)
		return CallXMDLModel;
	else
#endif
	return gModelFunc[modelNumber];
}

/*
	CallPeel -- used to call the correct peeling procedure from pascal.
	It returns whatever the peeling function decides to return.
	Usually this should be:
		NO_ERROR when all's well
		PEELING_FAILED when the peeling procedure was executed and failed
		NO_PEELING_FUNC_AVAILABLE when there is no peeling proc available
			for the current model; usually this is returned when the model
			is the user defined one.
*/
int CallPeel(X, Y, NObservations, params, sqrtWeights, weightsOption, modelNumber,
								cutPoints)
extended X[], Y[], params[], sqrtWeights[];
int NObservations, modelNumber, weightsOption, *cutPoints;
{
	int_function peel_function = gPeel_model[modelNumber];
	
	return (*peel_function)(X, Y, NObservations, params, sqrtWeights, weightsOption,
													cutPoints);
}

void SetUserModelNParams(int n)
{
	gNumberOfParams[USER_MODEL] = n;
}

