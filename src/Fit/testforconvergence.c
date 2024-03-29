/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "fit.h"
#include <math.h>

#define DEBUG 0

/*
	rest. false se il test e' negativo, true viceversa.  Questo
	e' un test accurato, che prende in considerazione la variazione
	percentuale dei parametri fra le iterazioni.
*/
int testForConvergence(params, oldParams)
extended params[], oldParams[];
{
	int i;

#if DEBUG
	writeln ("Test for convergence: entering");
	/*
		writeln("    old par = "); printVector(oldParams, 0, NParams - 1);
		writeln("    new par = "); printVector(params, 0, NParams - 1);
	*/
	synch;
#endif

	for (i=0; i < NParams; i++)
		if (fabs((oldParams[i] - params[i]) / oldParams[i])
				> CONVERGENCE_TOLERANCE)
			return false;
	return true;
}
