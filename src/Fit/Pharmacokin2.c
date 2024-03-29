/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	----------------
	Pharmacokinetics computations:	Two compartment, intravenous adm.

	Created Luned“, 30 aprile 1990 12:49:36
*/

#include <stdio.h>
#include <math.h>
#include "fit.h"
#include "nrecipes.h"
#include "MacApp.h"
#include "m_indep.h"

#pragma segment CallFit

extended AUC_first_area_2p(extended x0, extended y0, extended p[],
													 extended lagtime)
{
#pragma unused (lagtime)
	return trapezoid(x0, two_exp_plus(p, 0.0), y0);
}

extended AUC_last_area_2p(extended p[], extended xn)
{
	return integrate_AUC(p[2], p[3], xn);
}

extended S1_first_area_2p(extended x0, extended y0, extended p[],
													extended lagtime)
{
#pragma unused (lagtime, p)
	return TRIANGLE(x0, x0*y0);
}

extended S1_last_area_2p(extended p[], extended xn)
{
	return integrate_MRT(p[2], p[3], xn);
}

extended S2_first_area_2p(extended x0, extended y0, extended p[],
													extended lagtime)
{
#pragma unused (lagtime, p)
	return TRIANGLE(x0, x0*x0*y0);
}

extended S2_last_area_2p(extended p[], extended xn)
{
	return integrate_VRT(p[2], p[3], xn);
}


void two_exp_plus_pharmacokin_data(extended	X[], 
																	 extended	Y[], 
																	 int			NObservations, 
																	 extended	p[], 
																	 extended	dose)
{
	extended	expAUC,
						expMRT,
						expVRT,
						teorAUC,
						teorMRT,
						teorVRT,
						Kpc,
						teorCentralVol,
						expCentralVol;
	
	writeln("Two compartments model, intravenous administration.");
	newline;
	
	/* Theoretical moments */
	teorAUC = p[0] / p[1] + p[2] / p[3];
	teorMRT = (p[2]/SQR(p[3]) - p[0]/SQR(p[1])) / teorAUC;
	{
		extended tmp = 2.0*p[2]/CUBE(p[3]) - 2.0*p[0]/CUBE(p[1]);
		teorVRT = tmp/teorAUC - SQR(teorMRT);
	}
	sprintf(msgStr, "Theoretical AUC              : %g", teorAUC);
	writeln(msgStr);
	sprintf(msgStr, "Theoretical MRT              : %g", teorMRT);
	writeln(msgStr); 
	sprintf(msgStr, "Theoretical VRT              : %g", teorVRT);
	writeln(msgStr);
	newline;

	/* Experimental AUC */
	writeln("Experimental AUC:");
	writeln("  partial areas:");
	numerical_integration(X, Y, NObservations, p,
												compute_AUC,				/* F */
												AUC_first_area_2p,
												AUC_last_area_2p,
												0.0,								/* lagtime unused */
												&expAUC,
												1,									/* verbose */
												"(extrapolated)");
	newline;

	/* Experimental MRT */
	{
		extended S1;
		numerical_integration(X, Y, NObservations, p,
													compute_S1,					/* F */
													S1_first_area_2p,
													S1_last_area_2p,
													0.0,								/* lagtime unused */
													&S1,
													0,									/* not verbose */
													"");								/* unused */
		expMRT = S1/expAUC;
		sprintf(msgStr, "Experimental MRT: %g", expMRT);
		writeln(msgStr);
	}
	
	/* Experimental VRT */
	{
		extended S2;
		numerical_integration(X, Y, NObservations, p,
													compute_S2,
													AUC_first_area_2p,
													AUC_last_area_2p,
													0.0,								/* lagtime unused */
													&S2,
													0,									/* not verbose */
													"");								/* unused */
		expVRT = S2/expAUC - SQR(expMRT);
		sprintf(msgStr, "Experimental VRT: %g", expVRT);
		writeln(msgStr);
	}
	newline;
	
	writeln("Half life");
	sprintf(msgStr, "  alpha phase: %g", LN2 / p[1]);
	writeln(msgStr);
	sprintf(msgStr, "  beta  phase: %g", LN2 / p[3]);
	writeln(msgStr);
	newline;
	
	Kpc = p[1] - (p[0] * (p[1]-p[3]))/(p[0]+p[2]); /* ??? */

	writeln("Rate constants");
	sprintf(msgStr, " Rate of elimination     Kel : %g",
									(p[1]*p[3])/Kpc);												/* ??? */
	writeln(msgStr);
	sprintf(msgStr, " Central-peripheral rate Kcp : %g", 
									(p[1]+p[3]) - Kpc - (p[1]*p[3])/Kpc );	/* ??? */
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
	
	teorCentralVol = dose / (((p[1] * p[3]) / Kpc) * teorAUC); /* ??? */
	expCentralVol =  dose / (((p[1] * p[3]) / Kpc) * expAUC);

	writeln("Volumes of distribution");
	writeln("  central compartment");
	sprintf(msgStr, "    theoretical  : %g", teorCentralVol);
	writeln(msgStr);
	sprintf(msgStr, "    experimental : %g", expCentralVol);
	writeln(msgStr);
	writeln("  peripheral compartment");
	sprintf(msgStr, "    theoretical  : %g", dose / (p[3] * teorAUC));
	writeln(msgStr);
	sprintf(msgStr, "    experimental : %g", dose / (p[3] * expAUC));
	writeln(msgStr);
	newline;
	
	writeln("Concentration at time 0");
	sprintf(msgStr, "  theoretical  : %g", p[0] + p[2]);
	writeln(msgStr);
	sprintf(msgStr, "  experimental : %g", dose / expCentralVol);
	writeln(msgStr);
	newline;
	
	/* Total body clearance */
	writeln("Total body clearance CL = dose/AUC");
	sprintf(msgStr, "  theoretical  : %g", dose / teorAUC);
	writeln(msgStr);
	sprintf(msgStr, "  experimental : %g", dose / expAUC);
	writeln(msgStr);
}
