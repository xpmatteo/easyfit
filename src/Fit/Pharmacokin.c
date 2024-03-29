/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	----------------
	Pharmacokinetics computations: Single compartment, IV.

	Created Venerd“, 27 aprile 1990 14:40:19
*/

#include <stdio.h>
#include <math.h>
#include "fit.h"
#include "nrecipes.h"
#include "MacApp.h"
#include "m_indep.h"

#pragma segment CallFit

void print_pharmacokin_data(extended	X[],
														extended	Y[],
														int				NObservations,
														extended	p[],
														int				modelNumber,
														extended	dose)
{
	if (modelNumber == SINGLE_EXP ||
			modelNumber == TWO_EXP_PLUS ||
			modelNumber == TWO_EXP_MINUS ||
			modelNumber == THREE_EXP_MINUS) {

		newline;
		writeln("====================================");
		newline;
		writeln("*** Pharmacokinetic computations ***");
		newline;
		synch;
	}
	
#if xqDebug	
	WriteVectors("X", X, "Y", Y, 0, NObservations - 1);
#endif

	switch(modelNumber) {
		case SINGLE_EXP:
			single_exp_pharmacokin_data(X, Y, NObservations, p, dose);
			break;
		case TWO_EXP_PLUS:
			two_exp_plus_pharmacokin_data(X, Y, NObservations, p, dose);
			break;
		case TWO_EXP_MINUS:
			two_exp_minus_pharmacokin_data(X, Y, NObservations, p, dose);
			break;
		case THREE_EXP_MINUS:
			three_exp_minus_pharmacokin_data(X, Y, NObservations, p, dose);
			break;
		default: ;
			/* do nothing */
	}		/* switch */
	synch;
}

/* ----------------------------------------------------------------------------- */
/*
	Single exponential model computations
*/
#pragma segment CallFit

void single_exp_pharmacokin_data(extended	X[], 
																 extended	Y[], 
																 int			NObservations, 
																 extended	p[], 
																 extended	dose)
{
	extended expAUC, expMRT, expVRT, teorAUC, teorMRT, teorVRT;
	
	/* Pharmacokinetic interpretation of the single exp. model */
	writeln("One compartment model, intravenous administration.");
	newline;
	
	/* Theoretical moments */
	teorAUC = p[0]/p[1];
	teorMRT = p[0]/(SQR(p[1])*teorAUC);
	teorVRT = ( 2.0*p[0]/(CUBE(p[1])*teorAUC) ) - SQR(teorMRT); 
	
	sprintf(msgStr, "Theoretical AUC              : %g", teorAUC);
	writeln(msgStr);
	sprintf(msgStr, "Theoretical MRT              : %g", teorMRT);
	writeln(msgStr); 
	sprintf(msgStr, "Theoretical VRT              : %g", teorVRT);
	writeln(msgStr); 
	newline;
	
	/* Experimental AUC; approximated with trapezoids */
	{
		extended area, base;
		int i;
		
		writeln("Experimental AUC, computed with trapezoids:");
		writeln("  partial areas:");
		
		/* First area obtained with Theoretical value at 0.0 */
		base = X[0];
		area = trapezoid(base, single_exp(p, 0.0), Y[0]);
		expAUC = area;
		
		sprintf(msgStr, "    area  0: %-10g  computed with theor. value at x=0", area);
		writeln(msgStr);
		
		for(i=0; i<(NObservations-1); i++) {
			base = X[i+1] - X[i];
			area = trapezoid(base, Y[i], Y[i+1]);
			expAUC += area;
			sprintf(msgStr, "    area %2d: %-10g  cum.: %g", i+1, area, expAUC);
			writeln(msgStr);
		}
		
		/* last area obtained as last experimental value / p2 */
		area = Y[NObservations - 1] / p[1];		
		expAUC += area;
		sprintf(msgStr, "    area %2d: %-10g  cum.: %g (extrapolated)", 
			NObservations, area, expAUC);
		writeln(msgStr);
		
		/* print total AUC */
		sprintf(msgStr, "total AUC: %g", expAUC);
		writeln(msgStr);
	}	/* print AUC */
	newline;
	
	/* Experimental MRT; approximated with trapezoids */
	{
		extended area, base;
		int i;
		
		/* First area obtained as a triangle from point (0,0) */
		base = X[0];
		area = TRIANGLE(base, X[0]*Y[0]) / expAUC;
		expMRT = area;
		
		for(i=0; i<(NObservations-1); i++) {
			base = X[i+1] - X[i];
			area = trapezoid(base, X[i]*Y[i], X[i+1]*Y[i+1]) / expAUC;
			expMRT += area;
		}
		
		/* last area */
		area = integrate_MRT(p[0], p[1], X[NObservations-1]) / expAUC;
		expMRT += area;
		
		/* print total MRT */
		sprintf(msgStr, "Experimental MRT: %g", expMRT);
		writeln(msgStr);
	}	/* print MRT */
	
	/* Experimental VRT; approximated with trapezoids */
	{
		extended area, base, S2;
		int i;
		
		/* First area obtained as a triangle from point (0,0) */
		area = trapezoid(X[0],
										 0.0,
										 SQR(X[0])*Y[0]);
		S2 = area;
		
		for(i=0; i<(NObservations-1); i++) {
			base = X[i+1] - X[i];
			area = trapezoid(base, 
											 SQR(X[i])*Y[i],
											 SQR(X[i+1])*Y[i+1]);
			S2 += area;
		}
		
		/* last area */
		area = integrate_VRT(p[0], p[1], X[NObservations-1]);
		S2 += area;
		
		expVRT = S2/expAUC - SQR(expMRT);
		
		/* print total VRT */
		sprintf(msgStr, "Experimental VRT: %g", expVRT);
		writeln(msgStr);
	}	/* print VRT */
	newline;
	
	/* Print Kel (rate of elimination) */
	sprintf(msgStr, "Rate of elimination Kel = p2 : %g", p[1]);
	writeln(msgStr);
	
	/* Print C0 (concentration at time 0) */
	sprintf(msgStr, "Concentration at time 0 = p1 : %g", p[0]);
	writeln(msgStr);
	newline;
	
	if (classextended(dose) == QNAN) {
		writeln("Couldn't compute further because dose value is unknown.");
		return;
	}
	
	sprintf(msgStr, "Dose                         : %g", dose);
	writeln(msgStr);
	newline;
	
	/* Print volume of distribution */
	writeln("Volume of distribution V = dose/(Kel * AUC)");
	sprintf(msgStr, "  theoretical  : %g", dose/p[0]);
	writeln(msgStr);
	sprintf(msgStr, "  experimental : %g", dose/(expAUC*p[1]));
	writeln(msgStr);
	newline;
	
	/* Total body clearance */
	writeln("Total body clearance CL = dose/AUC");
	sprintf(msgStr, "  theoretical  : %g", dose/(p[0]/p[1]));
	writeln(msgStr);
	sprintf(msgStr, "  experimental : %g", dose/expAUC);
	writeln(msgStr);
	newline;
	
	/* half life */
	sprintf(msgStr, "Half life                    : %g", LN2 / p[1]);
	writeln(msgStr);
}

