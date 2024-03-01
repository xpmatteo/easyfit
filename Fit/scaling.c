/*
	File scaling.c

	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "fit.h"

void scaleSolution(extended solution[])
{
	int i;

	for (i = 0; i < NParams; i++)
		solution[i] /= sqrtHessDiag[i];
}

void scaleHessianAndGradient(void)
{
	int i, j;

	for (i=0; i < NParams; i++) {
		for (j=0; j < NParams; j++) {
			HessMat[i+1][j+1] /= (sqrtHessDiag[i] * sqrtHessDiag[j]);
		}
		gradient[i] /= sqrtHessDiag[i];
	}
}

