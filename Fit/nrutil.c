/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	----------------
	
	Utilities tratte (e eventualmente modificate) dal libro
	di Press (1988)

	History
		Giovedi', 12 ottobre 1989 18:05:55
		Modificate le routines free_vector varie per fargli
		prendere un parametro in piu', come sul libro.
*/

#include <memory.h>
#include "nrecipes.h"
#include "MacApp.h"
#if macintosh
	#pragma segment ARes
#endif

extended *evector(start, end)
int start, end;
{
	extended *v;

	v = (extended *) NewPermPtr((unsigned) (end - start + 1) *
			sizeof(extended));
	if (!v) return v;
	return (v - start);
}

short *svector(start, end)
int start, end;
{
	short *v;

	v = (short *) NewPermPtr((unsigned) (end - start + 1) * sizeof(short));
	if (!v) return v;
	return (v - start);
}

int *ivector(start, end)
int start, end;
{
	int *v;

	v = (int *) NewPermPtr((unsigned) (end - start + 1) * sizeof(short));
	if (!v) return v;
	return (v - start);
}

extended **ematrix(nrl, nrh, ncl, nch)
/*
**	alloca una matrice di dimensioni [nrl..nrh][ncl..nch]
**	come array di puntatori alle righe della matrice.
*/
{
	int i;
	extended **m;

	/* alloca l' array di puntatori */
	m=(extended **)NewPermPtr((unsigned)(nrh-nrl+1)*sizeof(extended *));
	if (!m) return m;  /* allocazione fallita; restituisce il vettore
						  					nullo. */
	m -= nrl;

	/* alloca le righe e le connette ai puntatori */
	for (i=nrl; i <= nrh; i++) {
		m[i]=(extended*)NewPermPtr((unsigned)(nch-ncl+1)*sizeof(extended));
		if (!m[i]) return (extended **) 0;
		m[i] -= ncl;
	}
	return m;
}

void free_vector(p, start, end)
float *p;
int start, end;
{
#if macintosh
	#pragma unused(end)
#endif
	DisposPtr((Ptr) (p + start));
}

void free_evector(p, start, end)
extended *p;
int start, end;
{
#if macintosh
	#pragma unused(end)
#endif
	DisposPtr((Ptr) (p + start));
}

void free_svector(p, start, end)
short *p;
int start, end;
{
#if macintosh
	#pragma unused(end)
#endif
	DisposPtr((Ptr) (p + start));
}

void free_ivector(p, start, end)
int *p;
int start, end;
{
#if macintosh
	#pragma unused(end)
#endif
	DisposPtr((Ptr) (p + start));
}

void free_ematrix(m, nrl, nrh, ncl, nch)
extended **m;
/*
	dealloca una matrice allocata con "ematrix"
*/
{
#if macintosh
	#pragma unused(nch)
#endif
	int i;

	for (i=nrh; i >= nrl; i--)
		DisposPtr((Ptr) (m[i] + ncl));
	DisposPtr((Ptr) (m + nrl));
}

