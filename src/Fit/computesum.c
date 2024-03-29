/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "fit.h"

/* dichiarazioni forward */
static extended sumOfSquares();
static extended wSumOfSquares();

/*
	ComputeSum - La funzione da minimizzare: la somma dei quadrati
*/
extended ComputeSum(extended params[], int useWeights)
{
	if (useWeights)
		return wSumOfSquares(params);
	else
		return sumOfSquares(params);
}


/*
	ComputeELSSum - la funzione da minimizzare quando si usa ELS
*/
extended ComputeELSSum(X, Y, NObservations, params, NParams, model)
extended 	X[], Y[], params[], (*model)();
int 			NObservations;
{
	int i;
	extended sum, estimatedModel, estimatedVar;
	
	for (i=0, sum = 0.0; i<NObservations; i++) {
		estimatedModel = (*model)(params, X[i]);
		estimatedVar = params[NParams-2] * power(estimatedModel, params[NParams-1]);
		
		sum += SQR(estimatedModel - Y[i])/estimatedVar + log(estimatedVar);
	}
#if xqDebug
	sprintf(msgStr, "ComputeELSSum: a = %g, b = %g, sum = %.20g",
									params[NParams-2], params[NParams-1], sum);
	writeln(msgStr);
	synch;
#endif

	return sum;
}


/* ------------------------------------------------------------------------------- */
/*
	somma pesata dei quadrati
*/
static extended wSumOfSquares(extended params[])
{
	int i;
	extended tmp, sum;

	for (i=0, sum = 0.0; i<NObservations; i++) {
			tmp = sqrtWeights[i] * ((*model)(params, X[i]) - Y[i]);
			sum += tmp * tmp;
	}
	
#if qDebug
	if (IS_NAN(classextended(sum))) {
		sprintf(msgStr, "ComputeSum: sum is %f", sum);
		writeln(msgStr);
		writeln("first 4 params were");
		printVector(params, 0, 3);
		synch;
	}
#endif
	
	return sum;
}

/* -------------------------------------------------------------------------------- */
/*
	somma NON pesata dei qudrati
*/
static extended sumOfSquares(extended params[])
{
	int i;
	extended tmp, sum;

	for (i=0, sum = 0.0; i<NObservations; i++) {
			tmp = (*model)(params, X[i]) - Y[i];
			sum += tmp * tmp;
	}
	
#if qDebug
	if (IS_NAN(classextended(sum))) {
		sprintf(msgStr, "ComputeSum: sum is %f", sum);
		writeln(msgStr);
		writeln("first 4 params were");
		printVector(params, 0, 3);
		synch;
	}
#endif
	return sum;
}
