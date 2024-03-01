/*
		This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
		Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
		All rights reserved.
*/

#include <Types.h>
#include <Math.h>
#include <StdIO.h>
#include <strings.h>
#include "MacApp.h"

#pragma segment CallFit

/*
	ComputeEstimatedY - calcola la Y usando il modello e le stime 
	dei parametri; l'output e' il vettore EstimatedY, che deve essere
	allocato prima della chiamata.
*/

void ComputeEstimatedY(X,
											 NObservations,
											 params,
											 model,
											 EstimatedY)
extended 	X[];
short 		NObservations;
extended 	params[], 
					(*model)();
extended	EstimatedY[];
{
	short i;
	
	for (i=0; i<NObservations; i++)
		EstimatedY[i] = (*model)(params,X[i]);
}


/* 
	ComputeStdResiduals - Calcola i residui standardizzati mediante
	la formula:
		stdResiduals[i] = (residuals[i] - mean) / stdDeviation
	
	NOTA: per risparamiare tempo di esecuzione e memoria,
	bisogna passare alla chiamate nel vettore "stdResiduals"
	il vettore delle Y calcolate, ottenuto dalla 
	"ComputeEstimatedY".
	
	L'output viene fornito nel vettore "stdResiduals" che deve
	essere opportunamente allocato prima della chiamata.
*/

void ComputeStdResiduals(Y,
												 NObservations,
												 stdResiduals)
extended 	Y[];
short 		NObservations;
extended	stdResiduals[];
{
	short i;
	extended mean, stdDeviation, tmp;

	/* per prima cosa computa i residui NON standardizzati e mettili
		nell' array stdResiduals;  Questo array viene usato come
		memoria di lavoro prima che come output. 
		Nota che mi aspetto che l'array stdResiduals contenga
		alla chiamata le Y calcolate. */
	for (i=0; i<NObservations; i++)
		stdResiduals[i] -= Y[i];
		
	/* ora calcola la media e la varianza dei residui */
	for (i=0, mean = 0.0; i<NObservations; i++)
		mean += stdResiduals[i];
	mean /= NObservations;
	
	for (i=0, stdDeviation = 0.0; i<NObservations; i++) {
		tmp = stdResiduals[i] - mean;
		stdDeviation += tmp * tmp;
	}
	stdDeviation = sqrt(stdDeviation/NObservations);
	
	/* standardizza i residui */
	for(i=0; i< NObservations; i++)
		stdResiduals[i] = (stdResiduals[i] - mean) / stdDeviation;
	
	#if qDebug
	{
		char s[100];
		
		sprintf(s, "ComputeStdResiduals: mean is %g, std dev is %g", mean, stdDeviation);
		DEBUGWRITELN(c2pstr(s));
	}
	#endif
}



/*
	ComputePercentageResiduals - calcola i residui percentuali
	mediante la formula
		Resperc = ((Ycalc - Yoss) / Yoss) * 100 =
						= (Res / Yoss) * 100
	
	NOTA : bisogna passare i residui standardizzati (non percentuali)
	nell'array PercentualResidual;
	
	L'output e' sempre l'array PercentualResidual, che deve ovviamente
	esseres allocato prima.
*/

void ComputePercentageResiduals(Y,
																NObservations,
																PercentualResiduals)
extended Y[];
short NObservations;
extended PercentualResiduals[];
{
	short i;
	
	for (i=0; i<NObservations; i++)
		PercentualResiduals[i] = (PercentualResiduals[i] / Y[i]) * 100;
}


