/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	----------------
	Pharmacokinetics computations.
	
	In this file some utility functions are contained. Their purpose is
	to simplify work in the various pharmacokinetic computations.

	Created 10/May/90
*/

#include <SANE.h>
#include <Math.h>
#include "fit.h"
#include "m_indep.h"

/* ----------------------------------------------------------------------------- */
/*
	trapezoid - compute the area of a trapezoid
*/

#pragma segment CallFit

extended trapezoid(extended base, extended h1, extended h2)
{
	return base * MIN(h1, h2) + base * fabs(h1-h2) / 2.0;
}


/* ----------------------------------------------------------------------------- */
/*
	Integrate from T to infinite the formula a*exp(-b*x) in dx
*/
#pragma segment CallFit

extended integrate_AUC(extended a, extended b, extended T) 
{
	return ( a/b ) * exp(-b*T);
}

/* ----------------------------------------------------------------------------- */
/*
	Integrate from T to infinite the formula a*x*exp(-b*x) in dx
*/
#pragma segment CallFit

extended integrate_MRT(extended a, extended b, extended T) 
{
	return ( a/(b*b) + a*T/b ) * exp(-b*T);
}

/* ----------------------------------------------------------------------------- */
/*
	Integrate from T to infinite the formula a*x*x*exp(-b*x) in dx
*/
#pragma segment CallFit

extended integrate_VRT(extended a, extended b, extended T) 
{
		return ( 2.0*a / (b*b*b) + 2.0*a*T / (b*b) + a*T*T / b ) * exp(-b*T) ;
}

extended compute_AUC(extended X[], extended Y[], int i)
{
#pragma unused (X)
	return Y[i];
}

extended compute_S1(extended X[], extended Y[], int i)
{
	return (X[i] * Y[i]);
}

extended compute_S2(extended X[], extended Y[], int i)
{
	return (X[i]*X[i]*Y[i]);
}



/* ----------------------------------------------------------------------------- */
/*
	Numerically integrate an arbitrary formula, with trapezoid method.
	
	F is the formula to be integrated.
	First_area and last_area must be functions capable of computing those
	areas.
*/

#pragma segment CallFit

void numerical_integration(
			extended	X[],
			extended	Y[],
			int				NObservations,
			extended	p[],
			extended	(*F)(extended *, extended *, int), 
			extended	(*first_area)(extended, extended, extended *, extended), 
			extended	(*last_area)(extended *, extended),
			extended	lagtime,
			extended	*total_area,
			int				verbose,
			char			*last_area_message)
{
	extended base, area;
	int i;
	
	area = first_area(X[0], Y[0], p, lagtime);
	*total_area = area;

	if (verbose) {
		sprintf(msgStr, "      area  0: %-10g  cum.: %g", area, *total_area);
		writeln(msgStr);
	}
	
	for(i=0; i<(NObservations-1); i++) {
		base = X[i+1] - X[i];
		area = trapezoid(base, F(X, Y, i), F(X, Y, i+1));
		*total_area += area;

		if (verbose) {
			sprintf(msgStr, "      area %2d: %-10g  cum.: %g", i+1, area, *total_area);
			writeln(msgStr);
		}
	}
	
	area = last_area(p, X[NObservations-1]);
	*total_area += area;

	if (verbose) {
		sprintf(msgStr, "      area %2d: %-10g  cum.: %g %s",
										NObservations, area, *total_area, last_area_message);
		writeln(msgStr);
	
		sprintf(msgStr, "  total area: %g", *total_area);
		writeln(msgStr);
	}
}

/* ----------------------------------------------------------------------------- */
/*
	numerical_integration2 -- same as numerical_integration, but we 
	compute the first area in two ways. Other areas are computed as usual.
	This is always verbose.
*/

#pragma segment Fit

char linestr[] = "----------------------------|------------------------";

void numerical_integration2(
			extended	X[],
			extended	Y[],
			int				NObservations,
			extended	p[],
			extended	(*F)(extended *, extended *, int), 
			extended	(*first_area1)(extended, extended, extended *, extended), 
			extended	(*first_area2)(extended, extended, extended *, extended), 
			extended	(*last_area)(extended *, extended),
			extended	lagtime,
			extended	*total_area1,
			extended	*total_area2,
			char			*first_area_msg)
{
	extended base, area1, area2, area;
	int i;
	
	/* Print header */
	sprintf(msgStr, "      first point computed  | first point computed");
	writeln(msgStr);
	sprintf(msgStr, "      in (x,y) = (0,0)      | in (x,y) = %s", first_area_msg);
	writeln(msgStr);
	sprintf(msgStr, "     %10s  %10s |  %10s  %10s", "area", "cum.", "area", "cum.");
	writeln(msgStr);
	writeln(linestr);

	*total_area1 = area1 = first_area1(X[0], Y[0], p, lagtime);
	*total_area2 = area2 = first_area2(X[0], Y[0], p, lagtime);

	sprintf(msgStr, "%2d)  %10g  %10g |  %10g  %10g",
		0, area1, *total_area1, area2, *total_area2);
	writeln(msgStr);
	
	for(i=0; i<(NObservations-1); i++) {
		base = X[i+1] - X[i];
		area = trapezoid(base, F(X, Y, i), F(X, Y, i+1));
		*total_area1 += area;
		*total_area2 += area;

		sprintf(msgStr, "%2d)  %10g  %10g |  %10g  %10g",
			i+1, area, *total_area1, area, *total_area2);
		writeln(msgStr);
	}
	
	area = last_area(p, X[NObservations-1]);
	*total_area1 += area;
	*total_area2 += area;

	sprintf(msgStr, "%2d)  %10g  %10g |  %10g  %10g (extrap.)",
		NObservations, area, *total_area1, area, *total_area2);
	writeln(msgStr);
	writeln(linestr);
	sprintf(msgStr, "     total area: %-10g |  total area: %-10g",
		*total_area1, *total_area2);
	writeln(msgStr);
}

