/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "fit.h"
#include "nrecipes.h"
#include "MacApp.h"
#include "m_indep.h"

#if qConstraints

Boolean invalid_point(extended params[])
{
	int i;
	
	for (i=0; i<NParams; i++)
		if (params[i] < low_constr[i] || params[i] > hi_constr[i])
			return true;

	return false;
}

void print_constraints(NParams, low_constr, hi_constr)
extended low_constr[], hi_constr[];
int NParams;
{
	int i;
	
	writeln("Two-sided constraints:");
	writeln("----------------------------------");
	
	for(i=0 ; i < NParams ; i++) {
		/* We assume sprintf knows how to print an infinite number. */
		sprintf(msgStr, "%.4g < p%d < %.4g", low_constr[i], i+1, hi_constr[i]);
		writeln(msgStr);
	}
}

/* ------------------------------------------------------------------------------- */
/*
	constraints_in_use -- tells wether there is a constraints that's not infinite
*/
Boolean constraints_in_use()
{
	int i;
	
	for (i=0; i<NParams; i++)
		if (classextended(low_constr[i])!=INFINITE
				|| classextended(hi_constr[i])!=INFINITE)
			return true;

	return false;
}	

#endif qContraints
