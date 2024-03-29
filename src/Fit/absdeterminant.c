/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "fit.h"
#include <math.h>

extended absDeterminant(workMat, mat, dim, indx)
extended **mat, **workMat;
short indx[];
int dim;
/*
**	Restituisce il valore assoluto del determinante della matrice.
*/
{
	extended d;
	int i, ludcmp();
	void copyMatrix();

	copyMatrix(workMat, mat, dim);
	if (ludcmp(workMat, dim, indx, &d) != NO_ERROR)
		return 0.0;
	for (i=1; i <= dim; i++)
		d *= mat[i][i];

	/* "d" ora contiene il determinante */

#if qDebug
	sprintf(msgStr, "absDet: exiting with %f", fabs(d));
	writeln(msgStr);
	synch;
#endif
	return fabs(d);
}

