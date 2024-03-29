/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	----------------
	Pharmacokinetics computations: one compartment, oral.
	
	Created 10/May/90
*/

#include <SANE.h>
#include <Math.h>
#include "fit.h"
#include "m_indep.h"

/* ------------------------------------------------------------------------------- */
/*
	Computations for two exp minus model
*/

extended AUC_first_area1_2m(extended x0,
														extended y0, 
														extended p[], 
														extended lagtime)
{
#pragma unused (p, lagtime)
	return TRIANGLE(x0, y0);
}

extended AUC_first_area2_lag_neg_2m(extended x0, extended y0, extended p[],
																		extended lagtime)
{
#pragma unused (lagtime)
	return trapezoid(x0, two_exp_minus(p, 0.0), y0);
}

extended AUC_first_area2_lag_pos_2m(extended x0, extended y0, extended p[],
																		extended lagtime)
{
#pragma unused (p)
	return TRIANGLE(x0 - lagtime, y0);
}

extended S1_first_area1_2m(extended x0, extended y0, extended p[],
													extended lagtime)
{
#pragma unused (p, lagtime)
	return TRIANGLE(x0, y0*x0);
}

extended S1_first_area2_lag_pos_2m(extended x0, extended y0, extended p[],
																	 extended lagtime)
{
#pragma unused (p)
	return TRIANGLE(x0 - lagtime, y0*x0);
}

/* This is the same as in the first way; we don't need to compute two ways here. */
/* extended S1_first_area2_lag_neg() */

extended S2_first_area_2m(extended x0, extended y0, extended p[],
											 extended lagtime)
{
#pragma unused (p, lagtime)
	return TRIANGLE(x0, x0*x0*y0);
}

extended AUC_last_area_2m(extended p[], extended xn)
{
	return integrate_AUC(p[2], p[3], xn);
}

extended S1_last_area_2m(extended p[], extended xn)
{
	return integrate_MRT(p[2], p[3], xn);
}

extended S2_last_area_2m(extended p[], extended xn)
{
	return integrate_VRT(p[2], p[3], xn);
}

/* ------------------------------------------------------------------------------ */

#pragma segment CallFit

void two_exp_minus_pharmacokin_data(extended	X[], 
																	  extended	Y[], 
																	  int				NObservations, 
																	  extended	p[], 
																	  extended	dose)
{	
	extended	expAUC1, expAUC2, 
						expMRT1, expMRT2,
						expVRT,
						teorAUC,
						teorMRT,
						teorVRT,
						lagtime,
						peaktime;
	
	writeln("One compartment model, oral administration.");
	newline;
	
	/* First of all, compute lagtime */
	lagtime = (log(p[0]) - log(p[2])) / (p[1] - p[3]);
	
	/* Theoretical moments */
	if (lagtime > 0.0) {
		extended tmp;

		teorAUC = (p[2] / p[3]) * exp(-p[3]*lagtime)
							- (p[0] / p[1]) * exp(-p[1]*lagtime);
		
		tmp			= integrate_MRT(p[2], p[3], lagtime)
							- integrate_MRT(p[0], p[1], lagtime);
		teorMRT = tmp / teorAUC;

		tmp			= integrate_VRT(p[2], p[3], lagtime)
							- integrate_VRT(p[0], p[1], lagtime);
		teorVRT = tmp/teorAUC - SQR(teorMRT);
	}
	else {
		extended tmp;
		
		teorAUC = p[2]/p[3] - p[0]/p[1];
		teorMRT = (p[2]/SQR(p[3]) - p[0]/SQR(p[1])) / teorAUC;
		tmp			= 2.0*p[2]/CUBE(p[3]) - 2.0*p[0]/CUBE(p[1]);
		teorVRT = tmp/teorAUC - SQR(teorMRT);
	}
	sprintf(msgStr, "Theoretical AUC              : %g", teorAUC);
	writeln(msgStr);
	sprintf(msgStr, "Theoretical MRT              : %g", teorMRT);
	writeln(msgStr); 
	sprintf(msgStr, "Theoretical VRT              : %g", teorVRT);
	writeln(msgStr);
	newline;

	/* Experimental AUC; approximated with trapezoids */
	{
		writeln("Experimental AUC:");
		
		numerical_integration2(X,
													 Y,
													 NObservations,
													 p,
													 compute_AUC,
													 AUC_first_area1_2m,
													 lagtime < 0.0 ? 
													 		AUC_first_area2_lag_neg_2m : AUC_first_area2_lag_pos_2m,
													 AUC_last_area_2m,
													 lagtime,
													 &expAUC1,
													 &expAUC2,
													 lagtime < 0.0 ? 
													 		"(0, y(0))" : "(lagtime, 0)");
	}	/* print AUC */
	newline;
	synch;
	
	/* Experimental MRT; approximated with trapezoids */
	{
		extended S1;
		
		writeln("Experimental MRT:");
		numerical_integration(X, Y, NObservations, p,
													compute_S1,					/* F */
													S1_first_area1_2m,
													S1_last_area_2m,
													lagtime,
													&S1,
													0,									/* verbose */
													"");
		expMRT1 = S1/expAUC1;
		sprintf(msgStr, "  computed with first point in (x,y)=(0,0) : %g", expMRT1);
		writeln(msgStr);
		
		/* Now compute expMRT2 */
		if (lagtime > 0.0) {
			/* trapezoid */
			numerical_integration(X, Y, NObservations, p,
														compute_S1,					/* F */
														S1_first_area2_lag_pos_2m,
														S1_last_area_2m,
														lagtime,
														&S1,
														0,									/* verbose */
														"");
			expMRT2 = S1/expAUC2;
			sprintf(msgStr, "  computed with first point in (x,y)=(lagtime,0) : %g", expMRT2);
			writeln(msgStr);
		}
		else
			expMRT2 = expMRT1;
	}	/* print MRT */

	/* Experimental VRT; approximated with trapezoids */
	{
		extended S2;
		
		writeln("Experimental VRT:");
		numerical_integration(X, Y, NObservations, p,
													compute_S2,					/* F */
													S2_first_area_2m,
													S2_last_area_2m,
													lagtime,
													&S2,
													0,
													"");
		expVRT = S2/expAUC1 - SQR(expMRT1);
		sprintf(msgStr, "  computed with first point in (x,y)=(0,0) : %g", expVRT);
		writeln(msgStr);
	}	/* print VRT */
	newline;
	
	/* Print lagtime */
	sprintf(msgStr, "Lag time                     : %g", lagtime);
	writeln(msgStr);

	/* Find experimental conc. max and peak time */
	{
		int peak_obs = get_index_of_max(Y, 0, NObservations-1);

		sprintf(msgStr, "Experimental Peak time       : %g", X[peak_obs]);
		writeln(msgStr);
		sprintf(msgStr, "Experimental Conc. max       : %g", Y[peak_obs]);
		writeln(msgStr);
	}

	peaktime = (log(p[0] * p[1]) - log(p[2] * p[3])) / 
						 (p[1] - p[3]);
	sprintf(msgStr, "Theoretical Peak time        : %g", peaktime);
	writeln(msgStr);
	sprintf(msgStr, "Theoretical Conc. max        : %g", two_exp_minus(p, peaktime));
	writeln(msgStr);

	sprintf(msgStr, "Half life                    : %g", LN2 / p[3]);
	writeln(msgStr);
	
	sprintf(msgStr, "Conc. at time 0 = p3 - p1    : %g", p[2] - p[0]);
	writeln(msgStr);

	sprintf(msgStr, "Rate of absorption  Ka  = p2 : %g", p[1]);
	writeln(msgStr);

	sprintf(msgStr, "Rate of elimination Kel = p4 : %g", p[3]);
	writeln(msgStr);
	newline;
	
	if (classextended(dose) == QNAN) {
		writeln("Couldn't compute further because dose value is unknown.");
		return;
	}
	
	sprintf(msgStr, "Dose                         : %g", dose);
	writeln(msgStr);
	newline;
	
	writeln("Further computations with experimental AUC will show");
	writeln("two values separated by �|�, using experimental AUC");
	writeln("as computed with first method and second method.");
	newline;
	
	/* Print volume of distribution */
	writeln("Volume of distribution V = dose/(Kel * AUC)");
	sprintf(msgStr, "  theoretical  : %g", dose/(teorAUC*p[3]));
	writeln(msgStr);
	sprintf(msgStr, "  experimental : %g | %g", dose/(expAUC1*p[3]),
																							dose/(expAUC2*p[3]));
	writeln(msgStr);
	newline;

	/* Total body clearance */
	writeln("Total body clearance CL = dose/AUC");
	sprintf(msgStr, "  theoretical  : %g", dose/teorAUC);
	writeln(msgStr);
	sprintf(msgStr, "  experimental : %g | %g", dose/expAUC1, dose/expAUC2);
	writeln(msgStr);
}
