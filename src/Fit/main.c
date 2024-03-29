/* 
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	main program - serve a testare la procedura di fitting
*/

#include <stdio.h>
#include <math.h>
#include "fit.h"

#define FULLOUTPUT 1
#define MAXIT 30
#define UNATTENDED 1

/* ------------- Data set 1 */

#define NOBS1 5
#define NPAR1 2
#define USEWEIGHTS1 0

extended Y1[] = { 9.0, 8.0, 7.0, 6.0, 5.0 };
extended X1[] = { 1.0, 2.0, 3.0, 4.0, 5.0 };
extended P1[] = { 8.4241725 , 0.3912023 };
extended W1[NOBS1];

/* ------------- Data set 2 */

#define NOBS2 10
#define NPAR2 4
#define USEWEIGHTS2 0

extended Y2[] = { 9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.2 };
extended X2[] = { 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0};
extended P2[] = { 66.555375, 0.6895231, 69.329959, 0.50412911};
extended W2[NOBS2];

/* ------------- Data set 3 */

#define NOBS3 15
#define NPAR3 4
#define USEWEIGHTS3 0

extended Y3[] = { 1.003102,  2.980955,  4.547371,  9.645778,  
	9.783547, 8.304315,  3.639395,  2.745873,  2.893957,  1.766034,  
	0.9923531, 1.489665,  0.5314651,  0.5611367,  0.2072775 };
extended X3[] = { 0.1166, .25, .5, 1.0, 2.0, 4.0, 8.0, 12.0, 16.0,
	24.0, 28.0, 32.0, 36.0, 48.0, 72.0 };
extended P3[] = { 7.9149046, 2.2733099, 7.3350359, 0.05550319 };

extended W3[NOBS3];

/* ------------- Main */

main()
{
	short result;
	extended sum, lambda = 0.1;

	writeln(" DATA SET 111111111111111111111111111");
	result = fit(X1, Y1, NOBS1,
							 P1, NPAR1,
							 SINGLE_EXP,
							 USEWEIGHTS1,
							 W1,
							 lambda,
							 MAXIT,
							 FULLOUTPUT,
							 UNATTENDED,
							 1);		/* subject number */
	sprintf(msgStr, "Fit error code %d", result); writeln(msgStr);
	writeln("params at the end are:"); printVector(P1, 0, 1);

#if UNUSED	
	writeln(" DATA SET 22222222222222222222222222");
	result = fit(X2, Y2, NOBS2,
							 P2, NPAR2,
							 TWO_EXP_MINUS,
							 USEWEIGHTS2,
							 W2,
							 lambda,
							 MAXIT,
							 FULLOUTPUT,
							 UNATTENDED,
							 2);		/* subject number */
	sprintf(msgStr, "Fit error code %d", result); writeln(msgStr);
	writeln("params at the end are:"); printVector(P2, 0, 3);

	writeln(" DATA SET 33333333333333333333333333");
	result = fit(X3, Y3, NOBS3,
							 P3, NPAR3,
							 TWO_EXP_MINUS,
							 USEWEIGHTS3,
							 W3,
							 lambda,
							 MAXIT,
							 FULLOUTPUT,
							 UNATTENDED,
							 3);		/* subject number */
	sprintf(msgStr, "Fit error code %d", result); writeln(msgStr);
	writeln("params at the end are:"); printVector(P3, 0, 3);
#endif

	exit(0);
}
