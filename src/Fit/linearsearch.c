/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "fit.h"

static void computeTempParams();

#define ALL_INFINITY(n1, n2, n3)	(INF(n1) && INF(n2) && INF(n3))
#define ALL_NAN(n1, n2, n3)				(IS_NAN(n1) && IS_NAN(n2) && IS_NAN(n3))

int linearSearchStep1(
#if !SPEEDUP
				  				extended	params[],
#endif
									extended	*pSum)

/* ------------------------------------------------------------------
	Questa funzione esegue la prima parte della ricerca lungo la linea
	individuata dal vettore "direction".

	Come sottoprodotto, si ha il computo della somma.  Questo viene
	passato all' esterno attraverso la variabile "sum" che viene
	passata per indirizzo.

	Calcoliamo le tre somme
		COMPUTE_SUM(params + alfa * direction)
	per alfa = 1/3, 2/3, 1;

	Valori restituiti:
		OVERFLOW_IN_LIN_SEARCH:	tutte e tre le somme sono infinite;
		ONE_THIRD: 	il minimo e' per alfa = 1/3;
		TWO_THIRDS:  "   "    "   "   "   = 2/3;
		ONE:							  = 1.
		INVALID_FIRST_TRY: this means that with alfa=1/3 the parameters are not
			in the admissible region, with respect to the constraints. This
			means that for alfa>1/3 the params can't be valid either.
			
	Questo codice e' abbastanza complicato perche' deve tenere conto di 
	diverse cose:
		1) Non deve mai chiamare ComputeSum con dei parametri che escano dalla 
			regione di ammissibilita', percui ogni volta che computa tempParams,
			deve guardare bene che siano parametri ammissibili
		2) Deve tenere conto che la somma potrebbe essere NAN per qualche valore di alfa,
			o magari per tutti e tre i valori di alfa. Se la somma e' NAN per tutti e tre
			i valori di alfa, poniamo sum = NAN, e confidiamo che la procedura che 
			chiama linearSearch sappia quello che fa. La procedura che chiama
			linearSearch e' computeParams. La somma passata da linearSearch viene
			confrontata con quella vecchia. Se la somma nuova e' NAN, il confronto
			sum < oldSum fallisce sempre: infatti non c'e' una relazione d'ordine
			fra un NAN e un numero.
 ------------------------------------------------------------------*/

{
	extended sum1, sum2, sum3;
	extended min;
	int retValue;
	int classSum1, classSum2, classSum3;

#if SPEEDUP
	vectorSum(tempParams, direction, NParams);
#else
	computeTempParams(tempParams, params, direction, 1.0/3.0, NParams);
#endif
#if qConstraints
	if (useConstraints && invalid_point(tempParams)) {
		#if qDebug
		writeln("linear_search: alfa=1/3 leads to invalid point");
		synch;
		#endif
		return INVALID_FIRST_TRY;
	}
#endif
#if qELS
	if (useELS)
		sum1 = ComputeELSSum(X,Y,NObservations,tempParams,NParams,model);
	else
#endif
		sum1 = ComputeSum(tempParams, useWeights);


#if SPEEDUP
	vectorSum(tempParams, direction, NParams);
#else
	computeTempParams(tempParams, params, direction, 2.0/3.0, NParams);
#endif
#if qConstraints
	if (useConstraints && invalid_point(tempParams)) {
		/* We're entering the Forbidden Region: back up and give for good
			last point */
		#if qDebug
		writeln("linear_search: alfa=2/3 leads to invalid point");
		synch;
		#endif
		if (classextended(sum1) == INFINITE)
			return OVERFLOW_IN_LIN_SEARCH;
		*pSum = sum1;
		return ONE_THIRD;
	}
#endif
#if qELS
	if (useELS)
		sum2 = ComputeELSSum(X,Y,NObservations,tempParams,NParams,model);
	else
#endif
		sum2 = ComputeSum(tempParams, useWeights);

#if SPEEDUP
	vectorSum(tempParams, direction, NParams);
#else
	computeTempParams(tempParams, params, direction, 1.0, NParams);
#endif
#if qConstraints
	if (useConstraints && invalid_point(tempParams)) {
		/* We're entering the Forbidden Region */
		#if qDebug
		writeln("linear_search: alfa=3/3 leads to invalid point");
		synch;
		#endif
		if ((classSum1=classextended(sum1))==INFINITE
					&& (classSum2=classextended(sum2))==INFINITE)
			return OVERFLOW_IN_LIN_SEARCH;
		if (IS_NAN(classSum2) || sum1 < sum2) {
			*pSum = sum1;
			return ONE_THIRD;
		}
		else {
			*pSum = sum2;
			return TWO_THIRDS;
		}
	}
#endif
#if qELS
	if (useELS)
		sum3 = ComputeELSSum(X,Y,NObservations,tempParams,NParams,model);
	else
#endif
		sum3 = ComputeSum(tempParams, useWeights);

	if (ALL_INFINITY(sum1, sum2, sum3))
		return OVERFLOW_IN_LIN_SEARCH;
	
	classSum1 = classextended(sum1);
	classSum2 = classextended(sum2);
	classSum3 = classextended(sum3);
	
	if (ALL_NAN(classSum1, classSum2, classSum3)) {
		*pSum = sum1;
		return ONE_THIRD; /* any would do; we trust the NAN will be regarded 
												same as a non-decreasing sum */
	}

	/* Here we pick up the minimum, ignoring NANs, if any. */
	if (IS_NAN(classSum2) || sum1 < sum2) {
		min = sum1;
		retValue = ONE_THIRD;
	}
	else {
		min = sum2;
		retValue = TWO_THIRDS;
	}

	if (IS_NAN(classextended(min)) || sum3 < min) {
		min = sum3;
		retValue = ONE;
	}
	*pSum = min;

#if qDebug
	sprintf(msgStr, "linearSearch: exiting with %s, min = %f",
		retValue==ONE ? "ONE" : (retValue==TWO_THIRDS ? "TWO_THIRDS" : "ONE_THIRD"), min);
	writeln(msgStr);
#endif
	return retValue;
}

/* ----------------------------------------------------------------------------- */
/*
	Esegue il secondo passo della ricerca lineare nella direzione
	indicata da "direction".  Questa seconda parte viene eseguita
	solo se nella prima parte si e' trovato che il passo migliore
	era 1.  In questo caso si prosegue la ricerca lungo la
	direzione a passi di 1/3, fino a un massimo valore di 4.
	Ci fermiamo quando la somma cresce, o diventa NAN, o i parametri
	escono dalla regione delimitata dai constraints.
	La somma viene ancora una volta aggiornata da questa funzione,
	come side-effect.
-----------------------------------------------------------------*/

extended linearSearchStep2(
#if !SPEEDUP
						 							 extended params[],
#endif													 
													 extended *sum)

{
	extended alfa, alfaTemp;		/* la dimensione del passo */
	extended min;								/* la somma piu' bassa finora trovata */
	extended sumTemp;

	min = *sum;
	alfa = 1.0;

	for(alfaTemp=4.0/3.0; alfaTemp<=4.0; alfaTemp+=1.0/3.0) {

#if xqDebug
		sprintf(msgStr,
			"LinSearch2: loop: alfaTemp = %.3f, min = %.20g", alfa, min);
		writeln(msgStr);
		synch;
#endif

#if SPEEDUP
		vectorSum(tempParams, direction, NParams);
#else
		computeTempParams(tempParams, params, direction, alfaTemp, NParams);
#endif

#if qELS
		if (useELS)
			sumTemp = ComputeELSSum(X,Y,NObservations,tempParams,NParams,model);
		else
#endif
			sumTemp = ComputeSum(tempParams, useWeights);

		if (sumTemp > min
#if qConstraints
				||
				(useConstraints && invalid_point(tempParams))
#endif
				||
				IS_NAN(classextended(sumTemp)))
			break;
		else {
			min = sumTemp;
			alfa = alfaTemp; /* aggiorna alfa */
		}
	}

#if xqDebug
	sprintf(msgStr,
		"LinSearch2: exiting with alfa = %.3f and sum = %.20g", alfa, min);
	writeln(msgStr);
	synch;
#endif

	*sum = min;
	return alfa;
}

static void computeTempParams(tempParams, params, direction, alfa, dim)
extended *params, *direction, alfa, *tempParams;
{
	copyVector(tempParams, direction, dim);
	scalarMultiply(tempParams, alfa, dim);
	vectorSum(tempParams, params, dim);
}