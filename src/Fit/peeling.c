/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	---------------------

	La procedura Peeling permette di ottenere delle stime iniziali
	dei parametri. Funziona solo se il modello e' una somma di
	esponenziali.

	History:
	Scritta da Stefano Cermignani nell' estate '89

	Modificazioni minori per adattarla al resto di EasyFit
	sono state eseguite da Matteo Vaccari

	2/11/89, introdotta la variabile NParams, per migliorare la
	leggibilita' e per velocizzare di un epsilon i cicli for.

	2/11/89, apportata modifica alla procedura Peeling1, su
	una idea di Paolo Martinelli, da lui implementata e verificata
	sulla sua versione fortran dell peeling.	Per utilizzare
	questa modifica, #definire il simbolo qPaolo a 1.
	La modifica consiste nel non rifiutare una combinazione
	qualora dopo la sottrazione di una esponenziale si presenti
	un punto negativo, ma semplicemente di ignorare quel punto.
	Lo scopo di questa modifica e' di permettere all'algoritmo
	di esaminare un numero maggiore di combinazioni, mettendolo
	in condizione di trovare stime piu' accurate.  La efficacia
	di questa modifica e' stata verificata empiricamente da
	Paolo su un grandissimo numero di casi, ed e' tanto maggiore
	quante piu' esponenziali fanno parte del modello da fittare.

	2/11/89 - aggiunti due nuovi argomenti: W e UseWeights.
	Modificata la funzione PeelingSSE, per farle usare
	il vettore dei pesi.

	13/12/89 - Changed memory allocation function, from NewPtr to NewPermPtr,
	for use with MacApp. Changed BIGBADERROR with FailNIL.
	
	20/9/90 - Cambiati tutti i tipi da short a int, per coerenza.
	Aggiunti i prototipi.
*/

#include <Memory.h>
#include <Math.h>
#if macintosh
#	include <SANE.h>
#endif
#include "m_indep.h"
#include "MacApp.h"
#include "fit.h"

#define qPaolo 1

#if macintosh
	#pragma segment Fit
#endif macintosh

#if qPaolo
	static int num_of_nans;
#endif

/* funzioni locali */

static	int Peeling1 (extended X[],
											extended WorkY[],
											int NObs,
											int NExps,
											int FastestSignum,
											extended Param[],
											int Cuts[]);
static	extended PeelingSSE (extended X[],
														 extended Y[],
														 int NObs,
														 int NExps,
														 int FastestSignum,
														 extended Param[],
														 extended W[],
														 Boolean UseWeights);
static	int NextCutsConfig (int Cuts[],
														int NCuts,
														int NObs);
static	void LinRegr (extended X[],
											extended Y[],
											int NObs,
											extended *RegrCoeff,
											extended *YZero);

/*
	Sono input:
		X, Y, Nobs, Nexps, FastestSignum, Param, W, UseWeights;
		ove W e' il vettore delle RADICI QUADRATE dei pesi.
	Sono output:
		Cuts (il vettore dei tagli: le scelte che l'algoritmo ha fatto)
		Param (le stime)
	Valori restituiti:
		se non riesce a fare il peeling restituisce PEELING_FAILED,
		altrimenti NO_ERROR.
*/
int Peeling (X, Y, NObs, NExps, FastestSignum, Param, Cuts, W,
							UseWeights)
extended X[], Y[], Param[], W[];
int NObs, NExps, FastestSignum, Cuts[];
Boolean UseWeights;
{
	extended	*WorkY, *CurrParam, *BestParam;
	int				*CurrCuts, *BestCuts;
	extended	CurrSSE;
	extended	BestSSE = -1.0;
	int				NParams = 2 * NExps;
	int				NCuts = NExps - 1;
	int				i;

	WorkY 		= (extended *) NewPermPtr (NObs * sizeof (extended));
	FailNIL((Ptr) WorkY);
	CurrParam = (extended *) NewPermPtr (2 * NExps * sizeof (extended));
	FailNIL((Ptr) CurrParam);
	BestParam = (extended *) NewPermPtr (2 * NExps * sizeof (extended));
	FailNIL((Ptr) BestParam);
	CurrCuts	= (int *) NewPermPtr (NCuts * sizeof (int));
	FailNIL((Ptr) CurrCuts);
	BestCuts	= (int *) NewPermPtr (NCuts * sizeof (int));
	FailNIL((Ptr) BestCuts);

	for (i = 0; i < NCuts; i++)
		CurrCuts [i] = 1 + 2 * i;

	do {
		for (i = 0; i < NObs; i++)
			WorkY [i] = Y [i];
		if (Peeling1 (X, WorkY, NObs, NExps, FastestSignum,
									CurrParam, CurrCuts) == 0) {
			CurrSSE =
				PeelingSSE(X, Y, NObs, NExps, FastestSignum, CurrParam,
					W, UseWeights);

			if ((BestSSE == -1.0) || (CurrSSE < BestSSE)) {
				BestSSE = CurrSSE;
				for (i = 0; i < 2 * NExps; i++)
					BestParam [i] = CurrParam [i];
				for (i = 0; i < NCuts; i++)
					BestCuts [i] = CurrCuts [i];
			}
		}
	} while (NextCutsConfig (CurrCuts, NCuts, NObs) == 0);

	if (BestSSE != -1.0) {
		for (i = 0; i < 2 * NExps; i++)
			Param [i] = BestParam [i];
		for (i = 0; i < NCuts; i++)
			Cuts [i] = BestCuts [i];
	}

	DisposPtr ((Ptr) WorkY);
	DisposPtr ((Ptr) CurrParam);
	DisposPtr ((Ptr) BestParam);
	DisposPtr ((Ptr) CurrCuts);
	DisposPtr ((Ptr) BestCuts);
	return ((BestSSE == -1.0) ? PEELING_FAILED : NO_ERROR);
}

/*
	Peeling1 - esegue il peeling per una data configurazione di
	tagli.  Restituisce 1 se riesce a fare il peeling, zero altrimenti.
*/
static int Peeling1 (X, WorkY, NObs, NExps, FastestSignum, Param, Cuts)
extended X[], WorkY[], Param[];
int NObs, NExps, FastestSignum, Cuts [];
{
	int First, Last, e, i;
	extended RegrCoeff, YZero;

	for (e = NExps - 1; e >= 0; e--) {

		First = ((e == 0) 					? 0 			 : Cuts [e - 1] + 1);
		Last	= ((e == (NExps - 1)) ? NObs - 1 : Cuts [e]);

#if qPaolo
		num_of_nans = 0;
		/* Marca come NaN i punti negativi */
		for (i = First; i <= Last; i++)
			if (WorkY[i] <= 0.0) {
				WorkY[i] = nan(36);
				num_of_nans++;
			}
			else
				WorkY[i] = log(WorkY[i]);

		/* ctrl che ci siano almeno due punti per poter fare la
			regr. lineare */
		if ((Last - First + 1) - num_of_nans < 2) {
#			if TOOL
			printf("Config. rejected because of not enough non-nan points\n");
#			endif TOOL
			return 1;
		}
#else qPaolo
		for (i = First; i <= Last; i++) {
			if (WorkY[i] < 0)
				return 1;
			WorkY[i] = log(WorkY[i]);
		}
#endif qPaolo

		LinRegr(&X[First], &WorkY[First], Last-First+1, &RegrCoeff, &YZero);

		if (RegrCoeff > 0)
			return (1);

		Param [2 * e + 1] = - RegrCoeff;
		Param [2 * e] 		= exp (YZero);

		for (i = 0; i < First; i++) {
			WorkY[i] -= exp(RegrCoeff * X[i] + YZero);
			if (e == 1 && FastestSignum < 0)
				WorkY[i] = - WorkY[i];
		}
	}
	return (0);
}

/*
	PeelingSSE - calcola il SSE (Sum of sq. errors)
*/
extended PeelingSSE (X, Y, NObs, NExps, FastestSignum, Param, W,
		UseWeights)
extended X[], Y[], Param[], W[];
int NObs, NExps, FastestSignum;
Boolean UseWeights;
{
	extended ExtimatedY, SSE, Error;
	int i, j;

	SSE = 0.0;

	for (i = 0; i < NObs; i++) {
		
		CHECK_FOR_INTERRUPT
	
		ExtimatedY = 0.0;
		for (j = 0; j < NExps; j++)
			ExtimatedY +=
				((j == 0 && FastestSignum < 0) ? -Param[0] : Param[2*j]) *
					 exp(-Param[2*j+1] * X[i]);

		Error = Y[i] - ExtimatedY;
		if (UseWeights)
			Error *= W[i];
		SSE += Error * Error;
	}
	return (SSE);
}

/*
	Genera le possibili combinazioni di tagli, una per invocazione
*/
int NextCutsConfig (Cuts, NCuts, NObs)
int Cuts [], NCuts, NObs;
{
	int i, j;

	for (i = 1; i <= NCuts; i++) {
		if (Cuts [NCuts - i] < NObs - 1 - 2 * i)
			break;
	}

	if (i > NCuts)
		return (1);

	Cuts [NCuts - i] += 1;

	for (j = NCuts - i + 1; j < NCuts; j++)
		Cuts [j] = Cuts [j - 1] + 2;

	return (0);
}

void LinRegr (X, Y, NObs, RegrCoeff, YZero)
extended X [], Y [], *RegrCoeff, *YZero;
int NObs;
{
	extended XSum, YSum, X2Sum, XYSum;
	int i;

	XSum = YSum = X2Sum = XYSum = 0.0;

	for (i = 0; i < NObs; i++)
#if qPaolo
		if (classextended(Y[i]) != QNAN)
#endif qPaolo
		{
			XSum	+= X [i];
			YSum	+= Y [i];
			X2Sum += X [i] * X [i];
			XYSum += X [i] * Y [i];
		}

#if qPaolo
	*RegrCoeff = ((NObs-num_of_nans) * XYSum - XSum * YSum) /
								((NObs-num_of_nans) * X2Sum - XSum * XSum);
	*YZero		 = (YSum - *RegrCoeff * XSum) / (NObs-num_of_nans);
#else
	*RegrCoeff = (NObs * XYSum - XSum * YSum) /
								(NObs * X2Sum - XSum * XSum);
	*YZero		 = (YSum - *RegrCoeff * XSum) / NObs;
#endif qPaolo
}

#if TOOL
# include <time.h>
# include <StdIO.h>

	extended X[30], Y[30], Param[10];
	extended seed;

	extended drand48 ()
	{
		return randomx(&seed) / 2147483646.0;
	}

	main ()
	{
		int Cuts [4], i;

		seed = (unsigned int) time(NULL);

#if UNUSED
		printf("testing drand48\n");
		for (i = 0; i<30; i++)
			printf("%g\n", drand48());

		{
			int i;
			extended x;
			printf("testing random error factor\n");
			for (i = 0; i < 30; i++) {
				x = (1 + 0.5 * (2 * drand48() - 1));
				printf("x = %f\n", x);
		}
	}
#endif

		for (i = 0; i < 30; i++) {
			X[i] = (extended) i;
			Y[i] = (10.0 * exp(-0.1	* X[i]) + 10.0 * exp(-0.9 * X[i])) *
							(1 + 0.5 * (2 * drand48() - 1));
			printf ("X = %f, Y = %f\n", X[i], Y[i]);
		}

		/* chiama peeling e mostra i risultati */
		if (Peeling (X, Y, 30, 2, 1, Param, Cuts) == 1)
			printf ("Peeling failed\n");
		else {
			for (i = 0; i < 2; i++)
				printf ("A%-2hd = %7.2f,\talpha%-2hd = %7.2f\n",
						i, Param [2 * i], i, Param [2 * i + 1]);
			printf ("Chosen Cuts: ");
			for (i = 0; i < 3; i++)
				printf ("%3hd ", Cuts [i]);
			printf ("\n");
		}
		exit(0);
	}

#endif TOOL
