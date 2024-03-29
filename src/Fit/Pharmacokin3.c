/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	----------------
	Pharmacokinetics computations: Two compartments, oral.

	Created Luned�, 30 aprile 1990 14:41
*/

#include <stdio.h>
#include <math.h>
#include <SANE.h>
#include "fit.h"
#include "nrecipes.h"
#include "MacApp.h"
#include "m_indep.h"

#define MIN(aaa, bbb) ((aaa) < (bbb) ? (aaa) : (bbb))

/* --------------------------------------------------------------------------- */
/*
	Newton - finds the zero of a function "f" via Newton (tangent) method.
	If no convergence is reached, it returns the value of nan(38).
*/
	
#pragma segment CallFit

#define TOLERANCE 1.0e-7
#define MAX_IT		50

extended Newton(extended p[],				/* parameters only to pass to f and df */ 
								extended x0, 				/* starting point */
								extended (*f)(),
								extended (*df)())			/* the solution, if any */
{
	int i;
	extended x;
	
	for (x=x0, i=0; i<MAX_IT; i++) {
		x = x - f(p, x)/df(p, x);
		if (f(p,x) < TOLERANCE)
			return x;
	}
	return nan(38);		/* convergence not reached */
}

/* --------------------------------------------------------------------------- */
/*
	Analytical derivate of the three_exp_minus model
*/
#pragma segment CallFit

extended deriv_three_exp_minus(extended p[], extended x)
{
	return    p[0] * p[1] * exp(-p[1]*x)
		   		- p[2] * p[3] * exp(-p[3]*x)
		   		- p[4] * p[5] * exp(-p[5]*x);
}

/* --------------------------------------------------------------------------- */
/*
	Analytical second derivate of the three_exp_minus model
*/
#pragma segment CallFit

extended second_deriv_three_exp_minus(extended p[], extended x)
{
	return  - p[0] * p[1] * p[1] * exp(-p[1]*x)
		   		+ p[2] * p[3] * p[3] * exp(-p[3]*x)
		   		+ p[4] * p[5] * p[5] * exp(-p[5]*x);
}


/* --------------------------------------------------------------------------- */
/*
	other functions we need to pass to numerical_integration();
*/

extended AUC_first_area1_3m(extended x0,
														extended y0, 
														extended p[], 
														extended lagtime)
{
#pragma unused (p, lagtime)
	return TRIANGLE(x0, y0);
}

extended AUC_first_area2_lag_neg_3m(extended x0, extended y0, extended p[],
																		extended lagtime)
{
#pragma unused (lagtime)
	return trapezoid(x0, three_exp_minus(p, 0.0), y0);
}

extended AUC_first_area2_lag_pos_3m(extended x0, extended y0, extended p[],
																		extended lagtime)
{
#pragma unused (p)
	return TRIANGLE(x0 - lagtime, y0);
}

extended S1_first_area1_3m(extended x0, extended y0, extended p[],
													extended lagtime)
{
#pragma unused (p, lagtime)
	return TRIANGLE(x0, y0*x0);
}

extended S1_first_area2_lag_pos_3m(extended x0, extended y0, extended p[],
																	 extended lagtime)
{
#pragma unused (p)
	return TRIANGLE(x0 - lagtime, y0*x0);
}

extended S2_first_area_3m(extended x0, extended y0, extended p[],
											 extended lagtime)
{
#pragma unused (p, lagtime)
	return TRIANGLE(x0, x0*x0*y0);
}

extended AUC_last_area_3m(extended p[], extended xn)
{
	return integrate_AUC(p[4], p[5], xn);
}

extended S1_last_area_3m(extended p[], extended xn)
{
	return integrate_MRT(p[4], p[5], xn);
}

extended S2_last_area_3m(extended p[], extended xn)
{
	return integrate_VRT(p[4], p[5], xn);
}

/* --------------------------------------------------------------------------- */
/*
	three_exp_minus_pharmacokin_data
*/
#pragma segment CallFit

void three_exp_minus_pharmacokin_data(extended	X[], 
																			extended	Y[], 
																			int				NObservations, 
																			extended	p[], 
																			extended	dose)
{
	extended	teorAUC, 					/* Theoretical Area Under the Curve */
						teorMRT,
						teorVRT,
						expAUC1,
						expAUC2, 					/* experimental AUC computed with 1st and 2nd method */
						expMRT1,
						expMRT2,
						expVRT,
						teorCentralVol,		/* Theoretical volume of the central compartment */
						expCentralVol1, 
						expCentralVol2, 	/* experimental vol. of the central compartment,
																 computed using expAUC1 or expAUC2. */
						lagtime, 					/* Where model function hits the X axis */
						peaktime,					/* Point where the model func is maximum */
						Kpc;							/* Rate constant from peripheral to central 
																 compartment */
	
	/* Pharmacokinetic interpretation of the model */
	writeln("Two compartments model, oral administration.");
	newline;
	
	Kpc = (p[2]*p[5]*p[1] + p[4]*p[3]*p[1] - p[0]*p[3]*p[5]) / 
				(p[2]*(p[1]-p[3]) + p[4]*(p[1]-p[5]));
	
	/* We have no analytical solution for the lagtime here. So, we use
			a numerical approximation of the zero of the model function. */
	lagtime = Newton(p, X[0], three_exp_minus, deriv_three_exp_minus);
	
	if (classextended(lagtime) != QNAN) {

		/* Theoretical moments */
		if (lagtime > 0.0) {
			extended tmp;
			
			teorAUC = 	(p[2]/p[3]) * exp(-p[3]*lagtime)
								+ (p[4]/p[5]) * exp(-p[5]*lagtime)
								- (p[0]/p[1]) * exp(-p[1]*lagtime);										/* ??? */

			tmp			= 	integrate_MRT(p[2], p[3], lagtime)
								+ integrate_MRT(p[4], p[5], lagtime)
								- integrate_MRT(p[0], p[1], lagtime);
			teorMRT = tmp/teorAUC;

			tmp			= 	integrate_VRT(p[2], p[3], lagtime)
								+ integrate_VRT(p[4], p[5], lagtime)
								- integrate_VRT(p[0], p[1], lagtime);
			teorVRT = tmp/teorAUC - SQR(teorMRT);
		}
		else {
			extended tmp;
			
			teorAUC = p[2] / p[3] + p[4] / p[5] - p[0] / p[1];
			
			tmp			= p[2]/SQR(p[3]) + p[4]/SQR(p[5]) - p[0]/SQR(p[1]);
			teorMRT = tmp/teorAUC;
			
			tmp			= 2.0 * (p[2]/CUBE(p[3]) + p[4]/CUBE(p[5]) - p[0]/CUBE(p[1]));
			teorMRT = tmp/teorAUC - SQR(teorMRT);
		}
		sprintf(msgStr, "Theoretical AUC              : %g", teorAUC);
		writeln(msgStr);
		sprintf(msgStr, "Theoretical MRT              : %g", teorMRT);
		writeln(msgStr); 
		sprintf(msgStr, "Theoretical VRT              : %g", teorVRT);
		writeln(msgStr);
		newline;
	
		/* Experimental AUC; approximated with trapezoids */
		writeln("Experimental AUC:");
		numerical_integration2(X,
													 Y,
													 NObservations,
													 p,
													 compute_AUC,
													 AUC_first_area1_3m,
													 lagtime < 0.0 ? 
															AUC_first_area2_lag_neg_3m : AUC_first_area2_lag_pos_3m,
													 AUC_last_area_3m,
													 lagtime,
													 &expAUC1,
													 &expAUC2,
													 lagtime < 0.0 ? 
													 		"(0, y(0))" : "(lagtime, 0)");

		/* Experimental MRT */
		{
			extended S1;
			
			writeln("Experimental MRT:");
			numerical_integration(X, Y, NObservations, p,
														compute_S1,					/* F */
														S1_first_area1_3m,
														S1_last_area_3m,
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
															S1_first_area2_lag_pos_3m,
															S1_last_area_3m,
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
														S2_first_area_3m,
														S2_last_area_3m,
														lagtime,
														&S2,
														0,									/* verbose */
														"");
			expVRT = S2/expAUC1 - SQR(expMRT1);
			sprintf(msgStr, "  computed with first point in (x,y)=(0,0) : %g", expVRT);
			writeln(msgStr);
		}	/* print VRT */
		newline;

	}			/* moments */
	
	/* print lagtime */
	if (classextended(lagtime) == QNAN)
		writeln("Couldn't compute lag time.");
	else {
		sprintf(msgStr, "Lag time                     : %g", lagtime);
		writeln(msgStr);
		newline;
	}
	
	/* Find experimental conc. max and peak time */
	{
		int peak_obs = get_index_of_max(Y, 0, NObservations-1);

		sprintf(msgStr, "Experimental Peak time       : %g", X[peak_obs]);
		writeln(msgStr);
		sprintf(msgStr, "Experimental Conc. max       : %g", Y[peak_obs]);
		writeln(msgStr);
		newline;

		/* Find an approximation for peak time too */
		peaktime = Newton(p, 
											X[peak_obs],
											deriv_three_exp_minus, 
											second_deriv_three_exp_minus);
	}
	
	if (classextended(peaktime) == QNAN)
		writeln("Couldn't compute theoretical peak time.");
	else {
		sprintf(msgStr, "Theoretical Peak time        : %g", peaktime);
		writeln(msgStr);
		sprintf(msgStr, "Theoretical Conc. max        : %g", three_exp_minus(p, peaktime));
		writeln(msgStr);
		newline;
	}

	sprintf(msgStr, "Conc. at time 0 = p3 + p5 - p1    : %g", p[2] + p[4] - p[0]);
	writeln(msgStr);

	writeln("Half life");
	sprintf(msgStr, "  alpha phase: %g", LN2 / p[3]);
	writeln(msgStr);
	sprintf(msgStr, "  beta  phase: %g", LN2 / p[5]);
	writeln(msgStr);
	newline;

	writeln("Rate constants");
	sprintf(msgStr, " Rate of elimination     Kel : %g",
									(p[3]*p[5])/Kpc);												/* ??? */
	writeln(msgStr);
	sprintf(msgStr, " Central-peripheral rate Kcp : %g", 
									 p[3] + p[5] - Kpc - (p[3]*p[5])/Kpc );	/* ??? */
	writeln(msgStr);
	sprintf(msgStr, " Peripheral-central rate Kpc : %g", Kpc);
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
	
	teorCentralVol = dose / (((p[3] * p[5]) / Kpc) * teorAUC); /* ??? */
	expCentralVol1 = dose / (((p[3] * p[5]) / Kpc) * expAUC1);
	expCentralVol2 = dose / (((p[3] * p[5]) / Kpc) * expAUC2);

	writeln("Volumes of distribution");
	writeln("  central compartment");
	sprintf(msgStr, "    theoretical  : %g", teorCentralVol);
	writeln(msgStr);
	sprintf(msgStr, "    experimental : %g | %g", expCentralVol1, expCentralVol2);
	writeln(msgStr);
	writeln("  peripheral compartment");
	sprintf(msgStr, "    theoretical  : %g", dose / (p[5] * teorAUC));
	writeln(msgStr);
	sprintf(msgStr, "    experimental : %g | %g", dose / (p[5] * expAUC1),
																								dose / (p[5] * expAUC2));
	writeln(msgStr);
	newline;
	
	/* Total body clearance */
	writeln("Total body clearance CL = dose/AUC");
	sprintf(msgStr, "  theoretical  : %g", dose / teorAUC);
	writeln(msgStr);
	sprintf(msgStr, "  experimental : %g | %g", dose / expAUC1, dose / expAUC2);
	writeln(msgStr);
}
