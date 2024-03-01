/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "fit.h"

#undef DEBUG

void updateParams(params, direction, stepSize, dim)
extended params[];
extended direction[];
extended stepSize;
int dim;
/*
	Computa il nuovo array di parametri e lo lascia
	nel vettore "params"
	NOTA: il vettore "direction" viene sporcato.
*/
{
	void scalarMultiply(), vectorSum();

#if DEBUG
	writeln("updateParams: direction is");
	printVector(direction, 0, dim-1);
	sprintf(msgStr, "And step size is: %f", stepSize);
	writeln(msgStr);
	synch;
#endif

	scalarMultiply	(direction, stepSize, dim);
	vectorSum		(params, direction, dim);

#if DEBUG
	writeln("updateParams: new params are :");
	printVector(params, 0, dim -1);
	sprintf(msgStr, "--and stepSize was %f", stepSize);
	writeln(msgStr);
	synch;
#endif
}

