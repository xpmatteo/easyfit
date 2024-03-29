/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include <math.h>
#include "Fit.h"

#if macintosh
	#pragma segment Fit
#endif

#define EPSILON 1.0e-1000

/*
	normalizeWeights - procedura che migliora la stabilita' numerica del
	fitting.  Moltiplichiamo ciascun peso per uno stesso fattore, pari
	al numero di osservazioni che hanno peso non nullo diviso la somma dei pesi
	non normalizzati.
*/
void normalizeWeights(extended weights[], int NObservations)
{
	extended *Wi, factor, sum=0.0;
	int i, non_null=0;

	/* calcola la somma dei pesi e il numero di pesi non nulli */
	Wi = weights;
	for (i=0; i<NObservations; i++) {
		sum += *Wi;
		if (*Wi++ > EPSILON)
			non_null++;
	}

	/* normalizza */
	Wi = weights;
	factor = non_null / sum;
	for(i = 0 ; i < NObservations; i++)
		*Wi++ *= factor;
}

/*
	computeWeights1OverSqObs - calcola il vettore delle radici
	quadrate dei pesi in base alla formula 1/y2, normalizzandoli.
	Se c'e' una osservazione nulla, allora i pesi non possono essere calcolati
	in questa maniera, e restituisce NULL_OBSERVATION. Altrimenti restituisce
	NO_ERROR.
*/
int computeWeights1OverSqObs(extended Y[], int NObservations, extended sqrtWeights[])
{
	int i;
	extended *weights;
	extended *Wi, *Yi;

	/* All'inizio calcoliamo i pesi, e ci riferiamo all'array chiamandolo "weights";
		in seguito calcoliamo le radici quadrate dei pesi e lo chiameremo
		"sqrtWeights" */
	weights = sqrtWeights;

	/* controllo che nessuna osservazione sia nulla, altrimenti
		usciamo con un errore */
	if (anyNull(Y, 0, NObservations - 1))
		return(NULL_OBSERVATION);

	/* calcolo il vettore dei pesi */
	Wi = weights;
	Yi = Y;
	for(i = 0 ; i < NObservations; i++) {
		*Wi++ = 1.0 / (*Yi * *Yi);
		Yi++;
	}

	normalizeWeights(weights, NObservations);

	/* computa le radici quadrate dei pesi, che sono il risultato
		che ci interessa. */
	for(i = 0 ; i < NObservations; i++)
		sqrtWeights[i] = sqrt(weights[i]);

#if xqDebug
	writeln("computeWeights1OverSqObs: sqrtweights vale:");
	printVector(sqrtWeights, 0, NObservations - 1);
	synch;
#endif

	return NO_ERROR;
}

/*
	computeWeights1OverObs - calcola il vettore delle radici
	quadrate dei pesi in base alla formula 1/y, normalizzandoli.
	Se c'e' una osservazione nulla, allora i pesi non possono essere calcolati
	in questa maniera, e restituisce NULL_OBSERVATION. Altrimenti restituisce
	NO_ERROR.
*/
int computeWeights1OverObs(extended Y[], int NObservations, extended sqrtWeights[])
{
	int i;
	extended *weights;
	extended *Wi, *Yi;

	/* All'inizio calcoliamo i pesi, e ci riferiamo all'array chiamandolo "weights";
		in seguito calcoliamo le radici quadrate dei pesi e lo chiameremo
		"sqrtWeights" */
	weights = sqrtWeights;

	/* controllo che nessuna osservazione sia nulla, altrimenti
		usciamo con un errore */
	if (anyNull(Y, 0, NObservations - 1))
		return NULL_OBSERVATION;

	/* calcolo il vettore dei pesi */
	Wi = weights;
	Yi = Y;
	for(i = 0 ; i < NObservations; i++) {
		*Wi++ = 1.0 / *Yi;
		Yi++;
	}

	normalizeWeights(weights, NObservations);

	/* computa le radici quadrate dei pesi, che sono il risultato
		che ci interessa. */
	for(i = 0 ; i < NObservations; i++)
		sqrtWeights[i] = sqrt(weights[i]);

#if xqDebug
	writeln("computeWeights1OverObs: sqrtweights vale:");
	printVector(sqrtWeights, 0, NObservations - 1);
	synch;
#endif

	return NO_ERROR;
}


/*
	ComputeWeights1OverSqEstimated - calcola il vettore delle radici
	quadrate dei pesi in base alla formula 1/y, normalizzandoli.
	Se va tutto bene restituisce NO_ERROR;
	se c'e' una stima nulla, restituisce ERROR_IN_RECOMPUTEWEIGHTS.
	E' necessario lasciare questa funzione nel segmento Fit, perche'
	l'indirizzo di questa funzione viene preso da CallComputeWeights (interna a
	DoFit) che sta nel segmento CallFit. In questo modo l'indirizzo passato
	e' quello della jump table entry, che resta sempre valido.
*/
#pragma segment Fit
int ComputeWeights1OverEstimated(extended X[], 
																 int NObservations,
																 extended params[],
																 extended (*model)(extended *, extended),
																 extended sqrtWeights[])
{
	int i;
	extended *weights;
	extended Yi;

	/* All'inizio calcoliamo i pesi, e ci riferiamo all'array chiamandolo "weights";
		in seguito calcoliamo le radici quadrate dei pesi e lo chiameremo
		"sqrtWeights" */
	weights = sqrtWeights;

	/* calcolo il vettore dei pesi */
	for(i=0 ; i < NObservations; i++) {	
		Yi = (*model)(params, X[i]);
		if (Yi == 0.0)
			return ERROR_IN_RECOMPUTEWEIGHTS;
		weights[i] = 1.0 / Yi;
	}
	
	normalizeWeights(weights, NObservations);

	/* computa le radici quadrate dei pesi, che sono il risultato
		che ci interessa. */
	for(i = 0 ; i < NObservations; i++)
		sqrtWeights[i] = sqrt(weights[i]);

#if xqDebug
	writeln("computeWeights1OverEstimated: sqrtweights vale:");
	printVector(sqrtWeights, 0, NObservations - 1);
	synch;
#endif

	return NO_ERROR;
}

/*
	ComputeWeights1OverSqEstimated - calcola il vettore delle radici
	quadrate dei pesi in base alla formula 1/y2, normalizzandoli.
	Se va tutto bene restituisce NO_ERROR;
	se c'e' una stima nulla, restituisce ERROR_IN_RECOMPUTEWEIGHTS.
	E' necessario lasciare questa funzione nel segmento Fit, perche'
	l'indirizzo di questa funzione viene preso da CallComputeWeights (interna a
	DoFit) che sta nel segmento CallFit. In questo modo l'indirizzo passato
	e' quello della jump table entry, che resta sempre valido.
*/
#pragma segment Fit
int ComputeWeights1OverSqEstimated(extended X[], 
																	 int NObservations,
																	 extended params[],
																	 extended (*model)(extended *, extended),
																	 extended sqrtWeights[])
{
	int i;
	extended *weights;
	extended Yi;

	/* All'inizio calcoliamo i pesi, e ci riferiamo all'array chiamandolo "weights";
		in seguito calcoliamo le radici quadrate dei pesi e lo chiameremo
		"sqrtWeights" */
	weights = sqrtWeights;


	/* calcolo il vettore dei pesi */
	for(i=0 ; i < NObservations; i++) {	
		Yi = (*model)(params, X[i]);
		if (Yi == 0.0)
			return ERROR_IN_RECOMPUTEWEIGHTS;
		weights[i] = 1.0 / (Yi * Yi);
	}
	
	normalizeWeights(weights, NObservations);

	/* computa le radici quadrate dei pesi, che sono il risultato
		che ci interessa. */
	for(i = 0 ; i < NObservations; i++)
		sqrtWeights[i] = sqrt(weights[i]);

#if xqDebug
	writeln("computeWeights1OverSqEstimated: sqrtweights vale:");
	printVector(sqrtWeights, 0, NObservations - 1);
	synch;
#endif

	return NO_ERROR;
}


#if TOOL
#	include <stdio.h>

	char msgStr[500];

	main()
	{
		int i;
		extended W1[] = { 0.0, 1.0, 2.0, 3.0 };

		extended Y2[] = { 1.0, 2.0, 3.0 };
		extended W2[4];

		normalizeWeights(W1, 4);
		fprintf(stderr, "normalizing 0,1,2,3 :\n");
		for(i=0; i<=3; i++)
			fprintf(stderr, " %g, ", W1[i]);
		fprintf(stderr, "\n");

		computeWeights1OverSqObs(Y2, 3, W2);
		printf("sqrt weighting 1,2,3 :\n");
		for(i=0; i<=2; i++)
			fprintf(stderr, " %g, ", W2[i]);
		fprintf(stderr, "\n");
	}
#endif
