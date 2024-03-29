/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "fit.h"

/*
	marquardt -- applica la modificazione di Marquardt
	alla matrice HessMatessiana
*/
void marquardt(void)
{
	int i;

	for(i=1; i <= NParams; i++)
		HessMat[i][i] += lambda;
}

