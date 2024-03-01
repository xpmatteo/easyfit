/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.

	Main of the Fit module.

	
	NOTE:
		Error handling in the fit module is a mess. Errors are reported in
		several inconsistent ways. Some are reported through calling 
		Failure; some are reported through calling longjmp; some
		(that happen in the fit function itself, not in called functions)
		are reported simply by setting the appropriate returnValue and issuing
		goto end. Sorry! Someone someday should clean up this bad code.

		History (largely out of date):
			- 26/10/89, ore 2:45: Aggiornamento generale delle dichiara-
			zioni per permettere una compilazione sulla SUN.
			Le dichiarazioni di funzioni esterne sono state spostate nei
			file "nrecipes.h" e "fit.h"

			- 10/1/90: added ANSI - compatible function definition headers so that the
			compiler checks for correctness in (at least some) functions calls.

			- 18/1/90: added calls to MESSAGESSYNCH since now the sending of lines
			to the messages window is sort of bufferized.  Nothing is seen until
			you call synch.

			- 24/1/90: Remade error handling: now we give two more entry points
			in this module: FitErrHdl, to be called inside a pascal error handler to
			be installed before calling fit, and FitClearVars, to be called
			before installing FitErrHdl.  This should allow fit to release all of
			its memory in case an error occurs.  E.g: there's not enough memory to
			write on the messages window.
*/

#include <math.h>
#include <OSUtils.h>		/* for time & date functions */
#include "fit.h"
#include "EasyFitXMDL.h"

pascal void SETWDLOGTEXT(Str255 txt) extern;
pascal void RefreshPlots(int subject, extended *params, int NParams) extern;

static void doThingsWhenSumGreater(extended *params,
																	 extended *oldParams);

static int doThingsWhenSumLower(extended *params,
																extended *oldParams,
																extended  sum,
																extended  oldSum);

/* We save some bytes by storing only once this string */
char ParamValuesWhenStopped[] = "Parameter values when stopped:";

#define MAX_GREATER_LOOP 5

#define SCALAR_MULT(mat, scal, dim) {	int i,j; \
																			for(i=1; i<=(dim); i++) \
																				for(j=1; j<=(dim); j++) \
																					(mat)[i][j] *= (scal); }

/* A macro to be used in the Fit function */
#if qELS
#define PRINT_PARAMS	printVector(params, 0, useELS ? NParams-3 : NParams-1)
#else
#define PRINT_PARAMS	printVector(params, 0, NParams-1)
#endif

/*
	FitErrHdl: to be called inside a pascal error handler, so that we can exit
	gracefully
*/
void FitErrHdl(int NParams)
{
	if (minimHistory)				free_svector(minimHistory, 0, 3);
	if (indx)								free_svector(indx, 1, NParams);
	if (valOfTabataFactor)	free_evector(valOfTabataFactor, 1, 5);
	if (direction)					free_evector(direction, 0, NParams - 1);
	if (derParz)						free_evector(derParz, 0, NParams - 1);
	if (sqrtHessDiag)				free_evector(sqrtHessDiag, 0, NParams - 1);
	if (tempParams)					free_evector(tempParams, 0, NParams - 1);
	if (oldParams)					free_evector(oldParams, 0, NParams - 1);
	if (gradient)						free_evector(gradient, 0, NParams - 1);
	if (tempMat)						free_ematrix(tempMat, 1, NParams, 1, NParams);
  if (HessMat)						free_ematrix(HessMat, 1, NParams, 1, NParams);
}

/*
	FitClearVars: to be called before installing FitErrHdl, so that FitErrHdl
	can work correctly
*/
void FitClearVars()
{
	/* Make sure we will exit gracefully in case of error */
  HessMat 					= NULL;
	tempMat 					= NULL;
	gradient 					= NULL;
	oldParams 				= NULL;
	tempParams 				= NULL;
	sqrtHessDiag 			= NULL;
	derParz 					= NULL;
	direction 				= NULL;
	valOfTabataFactor	= NULL;
	indx 							= NULL;
	minimHistory			= NULL;
}

#define CHECK(vvvv) if (!(vvvv)) {returnValue = INSUFFICIENT_MEMORY; goto end;}

/* ------------------------------------------------------------------------------ */
/*
		Fit

		Note about weights: we pass to "fit" the useWeights boolean flag, the
		weights vector, and a weights recomputing function. If useWeights is false,
		then we don't use weights (all weights = 1.0), and the contents of
		sqrtWeights and ReComputeWeights don't matter at all.
		If useWeights is true, then the following holds:
		If the weights recomputing function is NULL,
		then we assume that the weights vector contains the weights, and the weights
		are fixed. Otherwise, the weights need to be recomputed at each iteration
		by means of the ReComputeWeights function.  The weights vector
		must still be allocated before calling fit.
		Also note that the weights vector is called sqrtWeights because it's
		supposed to contain the square root of the weights. This is because
		it is convenient for us to have the sqr root of the weights, so we don't
		ever need to compute it.
		
		Now we add a complication: if the useELS flag is true, then we tell fit
		to apply the Extended Least Squares weighting scheme. The weights vector
		is not used.
		The handling of ELS weights adds some complications to the code. 
		We have to add two more parameters, that relate to the variance model.
		The variance model used in ELS is
			Vi = a y(xi)^-b ,
		where a and b are the parameters of the variance model. We MUST assume
		that the params vector passed to fit is in fact two positions longer
		than NParams. ALso the constraints vector must have two spaces more, to
		allow for constraints on variance parameters.
		We add two to NParams, so that parts of the fitting algorythm that don't 
		need to know about ELS will treat the variance parameters as any other
		parameter.
		We will then assume that "a" is NParams-2, and "b" is NParams-1.
		
		We need to use a different objective function, and so we will use a 
		variation of ComputeSum called ComputeELSSum. Ae also need to change
		the way we compute the hessian and the gradient, since the old
		computeHess function assumed the standard WLS ComputeSum was used.
		So we'll use ComputeELSHessian instead of ComputeHessian.
*/

int	fit (extended X_[],
				 extended Y_[],
				 int NObservations_,
				 extended params[],
				 int NParams_,
				 int modelNumber,
				 int useWeights_,
#if qELS
				 int useELS_,
#endif
				 extended sqrtWeights_[],
				 extended lambda_,
				 int maxIterations,
#if qConstraints
				 extended low_constr_[],
				 extended hi_constr_[],
#endif
				 int theSubject,
				 int fullOutput,
				 int (*ReComputeWeights)(extended *X, int NObservations, extended *params, extended (*model)(), extended *sqrtWeights),
				 int mustRefreshPlots)
{
#if qDebug
#pragma unused(fullOutput)
#endif

	/* These volatile declaration tell the compiler _not_ to
		store the variables in registers. This is because a longjmp call
		would trash them otherwise. */
	volatile int				returnValue;
	volatile int				iterCount = 0;			/* numero di iterazioni */
	volatile unsigned long timeAtStart;			/* time at start of fit */
	extended						sum, oldSum;

	/* INIZIALIZZAZIONI */
	
	GetDateTime(&timeAtStart);
	
	model = get_ModelFunc(modelNumber);

	/* We set up this global that will be used in interpret().
		 We convert the subject number to extended once and for all.
		 I didn't want the conversion to happen every time we called
		 interpret(). */
	gExtendedCurrentSubject = theSubject;
	
	#if qXMDLs
	/* This one will be used in external models; it is an integer. */
	gCurrentSubject = theSubject;
	#endif
	
	/* Copy the function args in globals, to avoid too much parameter passing */	
	X = X_;
	Y = Y_;
	NObservations = NObservations_;
	NParams = NParams_;
	useWeights = useWeights_;
#if qELS
	useELS = useELS_;
#endif
	sqrtWeights = sqrtWeights_;
	lambda = lambda_;
	low_constr = low_constr_;
	hi_constr = hi_constr_;

#if xqDebug
	{
		extended interpret();
		sprintf(msgStr, "model number is %d, model address is %p, interpret is %p",
			modelNumber, model, interpret);
		DEBUGWRITELN(c2pstr(msgStr));
	}
#endif

/*
** --------------- Controlli sui dati di input --------------
*/

	/* note that we need later (when computing the var-covar mat.)
			to be sure that there are at least MORE observations than params. */
	if (NParams >= NObservations)
		return TOO_FEW_OBSERVATIONS;
	
#if qELS
	if (useELS) {
		NParams += 2;
		if (NParams > kMaxParams)
			Failure(kTooManyParametersForELS, 0);
		
		/* Estimate an initial value for the variance parameters */
		params[NParams-2] = 1;
		params[NParams-1] = 2;
	}
#endif

/* Make sure we will exit gracefully in case of error. It should be
	called already, but you never know... */
	FitClearVars();

/* Allocate vectors and matrixes as needed */

  HessMat 					= ematrix(1, NParams, 1, NParams);
	CHECK(HessMat)
	tempMat 					= ematrix(1, NParams, 1, NParams);
	CHECK(tempMat)
	gradient 					= evector(0, NParams - 1);
	CHECK(gradient)
	oldParams 				= evector(0, NParams - 1);
	CHECK(oldParams)
	tempParams 				= evector(0, NParams - 1);
	CHECK(tempParams)
	sqrtHessDiag 			= evector(0, NParams - 1);
	CHECK(sqrtHessDiag)
	derParz 					= evector(0, NParams - 1);
	CHECK(derParz)
	direction 				= evector(0, NParams - 1);
	CHECK(direction)
	valOfTabataFactor	= evector(1, 5);
	CHECK(valOfTabataFactor)
	indx 							= svector(1, NParams);
	CHECK(indx)
	minimHistory			= svector(0,2);
	CHECK(minimHistory)

	/* Inizializzazioni */
	valOfTabataFactor[1] = 1.33;
	valOfTabataFactor[2] = 1.78;
	valOfTabataFactor[3] = 3.16;
	valOfTabataFactor[4] = 10.0;
	valOfTabataFactor[5] = 100.0;
	minimHistory[0] = minimHistory[1] = minimHistory[2] = UNDEFINED;

	if ((returnValue = setjmp(setjmp_env)) == NO_ERROR) {

#if qConstraints
#if qELS
		if (useELS) {
			low_constr[NParams-2] = 0.0;
			hi_constr[NParams-2] = inf();
			low_constr[NParams-1] = -inf();
			hi_constr[NParams-1] = inf();
		}
#endif qELS
		useConstraints = constraints_in_use();
		if (useConstraints && invalid_point(params)) {
			returnValue = INVALID_INITIAL_ESTIMATE;
			goto end;
		}
#endif qConstraints

		/* If using iteratively recomputed weights, we need to initialize
			 the weights vector. */
		if (useWeights && ReComputeWeights) {
			returnValue = (*ReComputeWeights)(X, NObservations, params, model, sqrtWeights);
			if (returnValue != NO_ERROR)
				goto end;
		}
		
		CHECK_FOR_INTERRUPT

		/* Computa la somma iniziale */
#if qELS
		if (useELS)
			sum = ComputeELSSum(X,Y,NObservations,params,NParams,model);
		else
#endif
			sum = ComputeSum(params, useWeights);

		CHECK_FOR_INTERRUPT

		if (INF(sum)) {
			returnValue = BAD_INITIAL_ESTIMATE;
			goto end;
		}
		
		if (IS_NAN(classextended(sum))) {
			returnValue = SUM_IS_NAN;
			goto end;
		}

		CHECK_FOR_INTERRUPT

		/*
			Non ci sono stati errori nella fase di inizializzazione.
			Copia un po' di dati sulla finestra di output
		*/
		writeln("Experimental data:");
		WriteVectors("X", X, "Y", Y, 0, NObservations - 1);
		newline;
		writeln("Starting parameters:");
#if qELS
		if (useELS) {
			printVector(params, 0, NParams - 3);
			sprintf(msgStr, "alpha = %g", params[NParams-2]);
			writeln(msgStr);
			sprintf(msgStr, "beta  = %g", params[NParams-1]);
			writeln(msgStr);
		}
		else
#endif
			printVector(params, 0, NParams - 1);

#if qConstraints
		newline;
#if qELS
		if (useELS)
			print_constraints(NParams-2, low_constr, hi_constr);
		else
#endif qELS
			print_constraints(NParams, low_constr, hi_constr);
#endif qConstraints

		CHECK_FOR_INTERRUPT

#if xqDebug
		if (useWeights) {
			newline;
			write("Weights: ");
			printSquaredVector(sqrtWeights, 0, NObservations - 1);
		}
#endif

		newline;
		if (useWeights) {
			extended unweightedSum;
	
			unweightedSum = ComputeSum(params, false);
			sprintf(msgStr, "Weighted sum at start:             %.12G", sum);
			writeln(msgStr);
			sprintf(msgStr, "Unweighted sum at start:           %.12G", unweightedSum);
			writeln(msgStr);
		} else {
			sprintf(msgStr, "Sum at start:                      %.12G", sum);
			writeln(msgStr);
		}
		sprintf(msgStr, "Lambda at start:                   %.12G", lambda);
		writeln(msgStr);
		synch;

/*
**	----------------- CICLO PRINCIPALE ------------------------
*/

		for (;;) {

			CHECK_FOR_INTERRUPT

			/* controlla che non abbiamo gia' fatto troppe iterazioni */
			if (iterCount == maxIterations) {
				returnValue = TOO_MANY_ITERATIONS;
				iterCount--;
				goto end;
			}

			/* aggiorna il messaggio sull "working" dialog */
			sprintf(msgStr,
							"Fitting subject %d, iteration %d",
							theSubject,
							iterCount + 1);
			SETWDLOGTEXT(c2pstr(msgStr));

			/* Stampa un po' di informazioni sulla finestra di testo */
#if !qDebug
			if (fullOutput)
#endif
			{
				sprintf(msgStr,
							"Iteration number %d",
							iterCount+1,
							sum);
				writeln(msgStr);
				synch;
			}

			/* Recompute the weights vector, if using iteratively recomputed
				weights. */
			if (useWeights && ReComputeWeights) {
				returnValue = (*ReComputeWeights)(X, NObservations, params, model, sqrtWeights);
				if (returnValue != NO_ERROR)
					goto end;
#if xqDebug
				newline;
				writeln("Fit: recomputing weights; squared values are:");
				printSquaredVector(sqrtWeights, 0, NObservations - 1);
				write("params are:");
				printVector(params, 0, NParams - 1);
				synch;
#endif
				/* Since we have changed the weights vector, we need to recompute the
					current sum. This is needed since changing the weights changes the
					magnitude of the sum. */
				sum = ComputeSum(params, useWeights);
			}
			
			CHECK_FOR_INTERRUPT

			/* calcola la matrice hessiana e il gradiente */
#if qELS
			if (useELS)
				computeELSHessianAndGradient (X, Y, NObservations, params,
									NParams, model, HessMat, gradient);
			else
#endif
				computeHessianAndGradient(params);

			CHECK_FOR_INTERRUPT
			
			/* se l'hessiana ha il det. nullo, applica Marquardt */
			if (absDeterminant(tempMat, HessMat, NParams, indx)
						< NULL_DETERMINANT_TOLERANCE)
					marquardt();

			CHECK_FOR_INTERRUPT

			/* calcola il vettore diagonale di H sotto radice */
			computeSqrtHessDiag();

			CHECK_FOR_INTERRUPT

			/* chiama la procedura di scaling per la H e il gradiente;
				se stiamo usando la pesatura ELS non chiama lo scaling, perche'
				lo scaling assume che la diagonale dell'hessiano sia tutta >0,
				cosa che non sempre e' con la pesatura elsFit. */
#if qELS
			if (!useELS)
#endif
				scaleHessianAndGradient();

			CHECK_FOR_INTERRUPT

			/* ricorda quanto era la somma alla iterazione precedente */
			oldSum = sum;

			{
				int counter = 0;
				
				/* cicla fino a che non riesce a fare decrescere la somma */
				while (computeParams(params, &sum, oldSum, oldParams) == SUM_GREATER) {
	
	#if qDebug
					newline;
					sprintf(msgStr, "Sum _greater_ = %g; lambda %g params =", sum, lambda);
					write(msgStr);					printVector(params, 0, NParams - 1);
					write("Gradient = ");		printVector(gradient, 0, NParams - 1);
					write("Direction = ");	printVector(direction, 0, NParams - 1);
					if (useWeights
	#if qELS
					&& !useELS
	#endif qELS
					) {
						write("Weights = ");
						printSquaredVector(sqrtWeights, 0, NObservations - 1);
					}
					synch;
	#endif qDebug

					if (++counter > MAX_GREATER_LOOP && IS_NAN(classextended(sum))) {
						returnValue = SUM_IS_NAN;
						goto end;
					}
					
					doThingsWhenSumGreater(params, oldParams);
				}
			}
			
			CHECK_FOR_INTERRUPT

			if (doThingsWhenSumLower(params, oldParams, sum, oldSum) == CONVERGENCE) {
				returnValue = NO_ERROR;
				goto end;
			}

			/* parte finale del ciclo; */

			iterCount++;

			/* stampa i dati sulla iterazione appena fatta sulla finestra
				di testo */
#if !qDebug
			if (fullOutput)
#endif
			{Ê
				newline;
				if (useWeights) {
					extended unweightedSum;
	
					unweightedSum = ComputeSum(params,false);
					sprintf(msgStr, "Weighted sum:                      %.12G", sum);
					writeln(msgStr);
					sprintf(msgStr, "Unweighted sum:                    %.12G", unweightedSum);
					writeln(msgStr);
				} else {
					sprintf(msgStr, "Sum:                               %.12G", sum);
					writeln(msgStr);
				}
				sprintf(msgStr, "Marquardt coefficient (lambda):    %G", lambda);
				writeln(msgStr);
				writeln("parameters are:");
				PRINT_PARAMS;
				synch;
			}
			
			if (mustRefreshPlots)
				RefreshPlots(theSubject, params, NParams);
		}		/* for(;;) */


/************************************************************************************/
/*	 E N D																																					*/
/************************************************************************************/

end:

		/*  *** No calls to working-dialog's methods ***
				*** no deallocating vectors              ***
				***	until past the next switch, please!  ***  */

		/*
			Stampa alcune informazioni alla fine del fitting
		*/
		newline;
		writeln("======================================");
		newline;

		/* Some errors are reported here, some in TEasyFitDocument.DoFit.
			It just depends on the way the error is called. Some errors
			are called in a way that doesn't let control pass from here. 
			This happens when errors are called with a longjmp or with Failure. */
		switch(returnValue) {
			case NO_ERROR:
				writeln("*** Convergence reached ***");
				sprintf(msgStr, "Computing results for subject %d", theSubject);
				SETWDLOGTEXT(c2pstr(msgStr));
				synch;
				break;
			case INSUFFICIENT_MEMORY:
				writeln("*** ERROR: not enough memory! ***");
				synch;
				break;
			case TOO_MANY_ITERATIONS:
				writeln("*** ERROR: too many iterations ***");
				sprintf(msgStr, "Computing results for subject %d", theSubject);
				SETWDLOGTEXT(c2pstr(msgStr));
				synch;
				break;
			case BAD_INITIAL_ESTIMATE:
				writeln("*** ERROR: bad initial estimate ***");
				synch;
				break;
			#if qConstraints
			case INVALID_INITIAL_ESTIMATE:
				writeln("*** ERROR: initial estimate out of constraints ***");
				break;
			#endif
			case SUM_IS_NAN:
				writeln("*** ERROR: the value of the model is Not a Number ***");
				writeln(ParamValuesWhenStopped);
				PRINT_PARAMS;
				synch;
				break;
			case ERROR_IN_RECOMPUTEWEIGHTS:
				writeln("*** ERROR: Couldn't compute weights. ***");
				writeln(ParamValuesWhenStopped);
				PRINT_PARAMS;
				synch;
				break;
		}
		newline;

		CHECK_FOR_INTERRUPT

		if (tempParams)
			free_evector(tempParams, 0, NParams - 1);
		if (oldParams)
			free_evector(oldParams, 0, NParams - 1);

		/* n. di iterazioni */
		sprintf(msgStr, "Number of iterations:                %d", iterCount+1);
		writeln(msgStr);

		CHECK_FOR_INTERRUPT

		/* time needed for the fit */
		{
			unsigned long timeAtEnd, timeNeeded;
			int mins;

			GetDateTime(&timeAtEnd);
			timeNeeded = timeAtEnd - timeAtStart;
			mins = timeNeeded / 60;
			sprintf(msgStr, "Time needed:                         %dÕ %dÓ",
				mins, timeNeeded % 60);
			writeln(msgStr);
		}

		CHECK_FOR_INTERRUPT

		if (returnValue == NO_ERROR
				|| returnValue == TOO_MANY_ITERATIONS) {

			/* sum */
			if (useWeights) {
				extended unweightedSum;

				unweightedSum = ComputeSum(params, false);
				sprintf(msgStr, "Weighted sum:                        %.12G", sum);
				writeln(msgStr);
				sprintf(msgStr, "Unweighted sum:                      %.12G", unweightedSum);
				writeln(msgStr);
			} else {
				sprintf(msgStr, "Sum:                                 %.12G", sum);
				writeln(msgStr);
			}

			CHECK_FOR_INTERRUPT

			/* compute var-covar matrix, and put it into "tempMat": */

			/* first compute the hessian/2 in the minimum */
#if qELS
			if (useELS)
				computeELSHessianAndGradient (X, Y, NObservations, params,
									NParams, model, HessMat, gradient);
			else
#endif
				computeHessianAndGradient(params);

			CHECK_FOR_INTERRUPT

			/* Then invert the hessian/2 and put it in "tempMat" */
			InvertMatrix(HessMat, NParams, indx, tempMat);

			CHECK_FOR_INTERRUPT

			/* now multiply tempMat by the mean square, and we're done */
			{
				extended tmp = sum / (NObservations - NParams);
				SCALAR_MULT(tempMat, tmp, NParams)
			}
#if xqDebug
			newline;
			writeln("fit: hessian matrix is:");
			printMatrix(HessMat, NParams);
			newline;
			newline;
			writeln("fit: covariance matrix is:");
			printMatrix(tempMat, NParams);
			synch;
#endif

			CHECK_FOR_INTERRUPT

			/* print r2 */
			{
				extended r2, sumOfY, sumOfY2;
				int i;

				for (i=0, sumOfY=0.0, sumOfY2=0.0; i<NObservations; i++) {
					sumOfY += Y[i];
					sumOfY2 += Y[i] * Y[i];
				}
				r2 = 1 - sum / (sumOfY2 - (sumOfY * sumOfY) / NObservations);

				sprintf(msgStr, "Squared correlation coefficient r2:  %.3f", r2);
				writeln(msgStr);
			}

			CHECK_FOR_INTERRUPT

			/* print parameters and variances */
			{
				extended std_dev;
				int i;

				newline;
				sprintf(msgStr, "%19s %15s %10s", "parameters", "std. dev.", "CV%");
				writeln(msgStr);
				writeln("----------------------------------------------");
				for (i=0; i<NParams; i++) {
					std_dev = sqrt(tempMat[i+1][i+1]);
					sprintf(msgStr, "%2d) % 14.8E % 14.8E % 10.2f",
						i+1, params[i], std_dev, (std_dev * 100.0) / params[i]);
					writeln(msgStr);
				}
			}

			CHECK_FOR_INTERRUPT

			/* compute correlation between parameters, and put it in "tempMat" */
			{
				int r,c;

				for (r=1; r<=NParams; r++)
					for (c=1; c<=NParams; c++)
						if (r>c)
							tempMat[r][c] /= sqrt(tempMat[r][r] * tempMat[c][c]);

				for (r=1; r<=NParams; r++)
					tempMat[r][r] = 1.0;

				CHECK_FOR_INTERRUPT

				/* print correlation matrix (lower triangle only) */
				newline;
				writeln("Estimated correlation between parameters:");
				for (c=1; c<=NParams; c++) {
					sprintf(msgStr, "%9d", c);
					write(msgStr);
				}
				newline;

				write("---");
				for (c=1; c<=NParams; c++)
					write("---------");
				newline;

				for (r=1; r<=NParams; r++) {
					sprintf(msgStr, "%2d ", r);
					write(msgStr);
					for (c=1; c<=NParams; c++) {
						if (r>=c) {
							sprintf(msgStr, "%9.3G", tempMat[r][c]);
							write(msgStr);
						}
					}
					newline;
				}
			}			/* end of compute correlation */
		}				/* if (returnValue != INSUFFICIENT_MEMORY) */

		/* flush msgs window */
		synch;

		CHECK_FOR_INTERRUPT

	} /* if setjmp */

	if (minimHistory)				free_svector(minimHistory, 0, 3);
	if (valOfTabataFactor)	free_evector(valOfTabataFactor, 1, 5);
	if (direction)					free_evector(direction, 0, NParams - 1);
	if (gradient)						free_evector(gradient, 0, NParams - 1);
	if (indx)								free_svector(indx, 1, NParams);
	if (derParz)						free_evector(derParz, 0, NParams - 1);
	if (sqrtHessDiag)				free_evector(sqrtHessDiag, 0, NParams - 1);
	if (tempMat)						free_ematrix(tempMat, 1, NParams, 1, NParams);
  if (HessMat)						free_ematrix(HessMat, 1, NParams, 1, NParams);

	return returnValue;
}



/* -------------------------------------------------------------------------------- */

static int doThingsWhenSumLower(extended params[],
																extended oldParams[],
																extended sum,
																extended oldSum)
{
	if (oldSum - sum < CONVERGENCE_TEST_FACTOR * oldSum
				&&
			testForConvergence(params, oldParams)) {
		return CONVERGENCE;
	}
	else {
		tabataFactor = newTabataFactorWhenDecreased(&tabataInt);
		lambda /= tabataFactor;
		return NO_CONVERGENCE_YET;
	}
}

/* -------------------------------------------------------------------------------- */

static void doThingsWhenSumGreater(extended *params, extended *oldParams)
{
	tabataFactor = newTabataFactorWhenIncreased(&tabataInt);
	lambda *= tabataFactor;
	/* restore the old parameters */
	copyVector(params, oldParams, NParams);
	marquardt();
}

/* -------------------------------------------------------------------------------- */
/*
	Calcola la radice quadrata della diagonale dell' hessiano,
	e la pone in "sqrtHessDiag"
*/
void computeSqrtHessDiag()
{
	int i;

	for (i=1; i <= NParams; i++)
		sqrtHessDiag[i-1] = sqrt(HessMat[i][i]);
}

#if qUnused
/* -------------------------------------------------------------------------------- */
/*
	Returns the address of a string containing an explanation for the given NAN
	code. NOTE: it may return the address of msgStr, so the string
	returned SHOULD NOT be pasted into msgStr again !!!
*/
char *explain_nan(int nan_code)
{
	switch(nan_code) {
		case 1:
			return "Invalid square root, such as Sqrt(-1)";
		case 2:
			return "Invalid addition, such as (+infinite) - (-infinite)";
		case 4:
			return "Invalid division, such as 0 / 0";
		case 8:
			return "Invalid multiplication, such as 0 * infinite";
		case 33:
			return "Invalid argument to trigonometric function";
		case 34:
			return "Invalid argument to inverse trigonometric function";
		case 36:
			return "Invalid argument to logarithm function";
		case 37:
			return "Invalid exponent to ** operator";
		default:
			sprintf(msgStr, "Unknown reason (code=%d)", nan_code);
			return msgStr;
	}
}
#endif