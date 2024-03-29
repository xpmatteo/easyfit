/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
*/

#include "fit.h"

/* stringa usata come buffer per i messaggi da mandare sulla
	finestra di solo testo */
char		msgStr[250];

/* usata da alcune macro (SQR e CUBE) */
extended scratch;

/* usata da setjmp/longjmp */
jmp_buf setjmp_env;

#if qXMDLs
/* usata per passare il numero del soggetto agli xmdls */
int gCurrentSubject;
#endif

/* The following globals are meant to avoid excessive parameter passing
	between functions */

/* These values are directly copied from the corresponding fit parameters at
	the beginning of the fit */
extended 		*X;
extended 		*Y;
int					NObservations;
int					NParams;
int					useWeights;
#if qELS
int					useELS;
#endif
extended		lambda;
extended 		tabataFactor;											/* il fattore di Tabata-Ito	*/
int					tabataInt = TABATA_INT_AT_START; 	/* l' intero che identifica
																								 il fattore di Tabata-Ito */
func_ptr		model;
extended		*low_constr;
extended		*hi_constr;
extended		*sqrtWeights;
#if qConstraints
int					useConstraints;
#endif

/* These are arrays and matrixes that are allocated and freed by the fit function */
extended    **HessMat;
extended		**tempMat;
extended    *gradient;
extended    *oldParams;
extended    *sqrtHessDiag;
extended		*derParz;
extended		*direction;
extended		*valOfTabataFactor;
extended		*tempParams;
short 			*indx;
short				*minimHistory;			/* storia recente della minimizzazione:
																	 l'indice 0 corrisponde al passo precedente;
																	 l' indice 1 al quello prima, eccetera */
