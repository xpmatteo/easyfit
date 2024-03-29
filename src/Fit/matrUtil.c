/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "fit.h"

void copyVector(extended dest[], extended source[], int length)
/*
**	copia veloce di due array 0-offset
*/
{
	extended *end;

	for (end = source + length; source < end; *dest++ = *source++)
		;
}

void copyMatrix(extended **dest, extended **source, int len)
/*
**	copia di una matrice [1..len][1..len]
*/
{
	int i;

	for (i=1; i <= len; i++)
		copyVector(dest[i] + 1, source[i] + 1, len);
}


void scalarMultiply(vect, scalar, dim)
extended *vect, scalar;
int dim;
/*
**	moltiplica un array 0-offset per uno scalare.
*/
{
	extended *end;
	for (end = vect + dim; vect < end; *vect++ *= scalar)
		;
}

void vectorSum(dest, source, dim)
extended *dest, *source;
int dim;
/*
**	La somma degli array 0-offset "dest" e "source" viene posta
**	nell' array "dest".
*/
{
	extended *end;
	for (end = source + dim; source < end; *dest++ += *source++)
		;
}

void printMatrix(mat, dim)
extended **mat;
int dim;
{
	int i,j;

	for (i = 1; i <= dim ; i++) {
		for (j = 1; j <= dim ; j++) {
#if !qDebug
			if (classextended(mat[i][j]) == QNAN)
				sprintf(msgStr, " <missing> ");
			else
#endif
				sprintf(msgStr, " %.12G     ", mat[i][j]);
			write(msgStr);
		}
		newline;
	}
}

void printVector(v, start, end)
extended *v;
{
	int i;
	for(i=start ; i <= end ; i++) {
/*
	-- NANs may be significant; not all nans are missing values
		if (classextended(v[i]) == QNAN)
			sprintf(msgStr, "%2d)  <missing>", i+1);
		else
*/
		sprintf(msgStr, "%2d)  %.12G", i+1, v[i]);
		writeln(msgStr);
	}
	newline;
}

/*
	Same as printVector, only the numbers are squared before being printed.
	The original vector is left unchanged. This is used mainly for debug.
*/
void printSquaredVector(v, start, end)
extended *v;
{
	int i;
	for(i=start ; i <= end ; i++) {
		if (classextended(v[i]) == QNAN)
			sprintf(msgStr, "%2d)  <missing>", i+1);
		else
			sprintf(msgStr, "%2d)  %.12G", i+1, v[i] * v[i]);
		writeln(msgStr);
	}
	newline;
}


/* Print two vectors in two columns */

void WriteVectors(name1, v1, name2, v2, from, to)
char *name1, *name2;
extended v1[], v2[];
int from, to;
{
	int i;
	char s1[80], s2[80];
	
	sprintf(msgStr, "    %14s %14s", name1, name2);
	writeln(msgStr);
	writeln("----------------------------------");
	
	for(i=from ; i <= to ; i++) {
		if (classextended(v1[i]) == QNAN)
			sprintf(s1, "<missing>");
		else
			sprintf(s1, "%.8G", v1[i]);
			
		if (classextended(v2[i]) == QNAN)
			sprintf(s2, "<missing>");
		else
			sprintf(s2, "%.8G", v2[i]);
		
		sprintf(msgStr, "%2d) %14s %14s",i+1 , s1, s2);
		writeln(msgStr);
	}
}

void 	makeZeroVector(extended p[], int size)
/*
	p deve puntare a un array zero-offset;
	size deve essere la lunghezza dell' array.

	Questa procedura azzera tutti gli elementi.
*/
{
	extended *end;
	for(end = p + size; p < end; p++)
		*p = 0.0;
}


void makeZeroMatrix(mat, size)
extended **mat;
int size;
/*
	p deve puntare a una matrice [1..size][1..size]
	size deve essere la dimensione della matrice.

	Questa procedura azzera tutti gli elementi.
*/
{
	int i;
	for (i=1; i <= size ; i++)
		makeZeroVector((mat[i]) + 1, size);
}


int anyNull(v, start, end)
extended v[];
int start, end;		/* il primo e l'ultimo elemento del vettore */
/*
	Restituisce 1 se almeno uno degli elementi del vettore "v" e' nullo.
*/
{
	int i;

	for (i = start; i <= end ; i++)
		if (v[i] == 0.0)
			return 1;

	return 0;
}


/* 
	matrix inversion - the original matrix a[1..N][1..N] gets destroyed. The result
	goes in the "y" matrix.
*/
#include <math.h>
#include <nrecipes.h>

void InvertMatrix(extended **a, int N, short indx[], extended **y)
{
	extended d, *col;
	int i, j;
	
	col = evector(1, N);
	
	ludcmp(a, N, indx, &d);
	for (j=1; j <= N; j++) {
		for (i=1; i <= N; i++) 
			col[i] = 0.0;
		col[j] = 1.0;
		lubksb(a, N, indx, col);
		for (i=1; i <= N; i++)
			y[i][j] = col[i];
	}
	free_evector(col, 1, N); 
}

/* -------------------------------------------------------------------------------- */
/*
	get_index_of_max -- returns the index of the largest element of an array
*/
int get_index_of_max(extended v[], int from, int to)
{
	int i, curr_max_index;
	extended curr_max;
	
	for(curr_max_index=from, curr_max = v[from], i=from+1; i<=to ; i++)
		if (v[i] > curr_max) {
			curr_max = v[i];
			curr_max_index = i;
		}
	return curr_max_index;
}



