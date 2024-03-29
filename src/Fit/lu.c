
#include <math.h>
#include "MacApp.h"
#include "fit.h"

#define TINY	1.0e-20

int ludcmp(a, n, indx, d)
int n;
short *indx;
extended **a, *d;
/*
**	Decompone una matrice a[1..n][1..n] in forma triangolare.
**
**	Codice preso da Press (1988) con alcune modifiche:
**		- tutti i tipi float qui sono extended
**		- non esce con "exit" se capita un errore, ma restituisce
**			NO_SOLUTIONS;
**		se non ci sono errori rest. NO_ERROR.
		
		Il valore NO_SOLUTIONS viene restituito solo se esiste almeno una colonna
		tutta composta di zeri.
*/
{
	int i, imax, j, k;
	extended big, dum, sum, temp;
	extended *vv, *evector();
	void free_evector();

	vv = evector(1, n);
	FailNIL((Ptr) vv);

	*d = 1.0;
	for (i=1; i <= n; i++) {
		big = 0.0;
		for (j=1; j <= n; j++)
			if ((temp = fabs(a[i][j])) > big)
				big = temp;
		if (big == 0.0)
			return NO_SOLUTIONS;
		/* no nonzero largest element */
		vv[i] = 1.0/big;   /* save the scaling */
	}
	for (j=1; j <= n; j++) {
		for (i=1; i<j; i++) {
			sum = a[i][j];
			for (k=1; k<i; k++) sum -= a[i][k] * a[k][j];
			a[i][j] = sum;
		}

		big = 0.0;
		for (i=j; i<=n; i++) {
			sum = a[i][j];
			for(k=1; k<j; k++)
				sum -= a[i][k] * a[k][j];
			a[i][j] = sum;
			if ( (dum = vv[i]*fabs(sum)) >= big) {
				big = dum;
				imax = i;
			}
		}

		if (j != imax) {
			for (k=1; k <= n; k++) {
				dum = a[imax][k];
				a[imax][k] = a[j][k];
				a[j][k] = dum;
			}
			*d = -(*d);
			vv[imax]=vv[j];
		}

		indx[j] = imax;
		if (a[j][j] == 0.0) a[j][j] = TINY;
		if (j != n) {
			dum = 1.0/(a[j][j]);
			for (i=j+1; i<=n; i++) a[i][j] *= dum;
		}
	}

	free_evector(vv, 1, n);
	return NO_ERROR;
}


void lubksb(a, n, indx, b)
extended **a, b[];
int n;
short *indx;
{
	int i, ii=0, ip, j;
	extended sum;

	for (i=1; i<=n; i++) {
		ip = indx[i];
		sum = b[ip];
		b[ip] = b[i];
		if (ii)
			for (j=ii; j <= i-1; j++) sum -= a[i][j] * b[j];
		else if (sum) ii = i;
		b[i] = sum;
	}
	for (i=n; i >= 1; i--) {
		sum = b[i];
		for (j=i+1; j<=n; j++) sum -= a[i][j] * b[j];
		b[i] = sum/a[i][i];
	}
}

