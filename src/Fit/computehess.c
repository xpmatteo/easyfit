/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.

	----------------

	INTERFACE:
		computeHessianAndGradient():
			una funzione che computa il gradiente e una approssimazione
			della matrice hessiana.

	La matrice Hessiana e' la matrice delle derivate parziali seconde
	della funzione minmizzanda, cioe' della somma degli scarti quadra-
	tici pesati.  Questa matrice viene calcolata numericamente nel
	punto individuato dal vettore dei parametri (ci si rammenti che
	la somma di quadrati e' funzione unicamente del vettore dei
	parametri.)

	Questa procedura computa una approssimazione della matrice hessiana
	detta "metodo di Gauss."  Questa approssimazione presenta il
	vantaggio di non richiedere il calcolo delle derivate parziali
	seconde. Infatti sono sufficienti le der. parz. prime.
	
	In questa approssimazione, H(i,j) = 2 * dF/dxi * dF/dxj

	NOTA: L'output di questa procedura viene chiamato "matrice hessiana", ma
	contiene in realta' la matrice hessiana/2. Questa matrice contiene contiene 
	la stessa informazione della matrice hessiana,
	ma non e' a rigore la hessiana.

	Operativamente l' elemento i,j della matrice viene calcolato mediante

		H(i,j) := 0; { inizializzazione }
		for i := 1 to NObs do begin
			for j := 1 to NObs do begin
				H(i,j) := H(i,j) * df/dpar[i] * df/dpar[j]
			end
		end;

		ove f e' la funzione modello moltipl. per la radice q. dello
		scarto della osservazione.

	Le der. parz. prime vengono computate a loro volta mediante appros-
	simazioni numeriche (metodo delle differenze finite).
	
	Dato che la matrice hessiana e' simmetrica (deve esserlo, per come la 
	costruiamo, risparmiamo tempo di esecuzione se calcoliamo solo il triangolo
	inferiore, ad esempio. Questo e' il trucco che abbiamo usato sia nella 
	versione ELS che in quella non-ELS. Nella versione non-ELS, il trucco
	viene usato solo quando non si compila per il coprocessore matematico.
	Infatti col coprocessore presente, l'overhead potrebbe essere tale da
	non rendere conveniente il trucco.
	Ho eliminato questa modifica dalla versione non-ELS perche' peggiorava di
	molto il numero di iterazioni necessarie a raggiungere il minimo. Non capisco
	perche'.
*/

#include <OSUtils.h>		/* SysBeep */
#include "MathMacros.h"
#include "fit.h"


/* Local procedures */

static void 		computeDerParz(extended params[], int j_obs);
static void			wComputeDerParz(extended params[], int j_obs);
static extended	derive(extended (*f)(extended *, extended),
											 extended p[],
											 extended x,
											 int par_number,
											 extended fp);
#if qELS
static void 		ELSComputeJacobianRow(extended X[],
																			extended Y[],
																			extended params[],
																			int NParams,
																			int j_obs,
																			extended (*model)(extended *, extended),
																			extended jr[]);
#endif
/* --------------------------------------------------------------------------- */

void computeHessianAndGradient(extended params[])
{
	int i_param, j_obs, k_param;
	extended scarto, y;

	makeZeroMatrix(HessMat, NParams);
	makeZeroVector(gradient, NParams);

	if (!useWeights) {
		for (j_obs = 0; j_obs < NObservations; j_obs++) {
			computeDerParz(params, j_obs);
			y = model(params, X[j_obs]);
			scarto = (Y[j_obs] - y);

			for (i_param = 0; i_param < NParams; i_param++) {
				gradient[i_param] +=
					scarto * derParz[i_param];

				for(k_param = 0; k_param < NParams; k_param++) {
					HessMat[i_param + 1][k_param + 1] +=
						derParz[i_param] * derParz[k_param];
				}
			}
		}
	}
	else {
		/* useWeights = true */
		for (j_obs = 0; j_obs < NObservations; j_obs++) {
			wComputeDerParz(params, j_obs);
			y = model(params, X[j_obs]);
			scarto = sqrtWeights[j_obs] * (Y[j_obs] - y);

			for (i_param = 0; i_param < NParams; i_param++) {
				gradient[i_param] +=
					scarto * derParz[i_param];

				for(k_param = 0; k_param < NParams; k_param++) {
					HessMat[i_param + 1][k_param + 1] +=
						derParz[i_param] * derParz[k_param];
				}
			}
		}
	}
#if xqDebug
	newline;
	writeln("Comp. H and G: H =");
	printMatrix(HessMat, NParams);
	writeln("G = "); printVector(gradient, 0, NParams - 1);
	synch;
#endif
}

#define SIGN(a) 				((a) > 0.0 ? 1.0 : ((a) < 0.0 ? -1.0 : 0.0))
#define DELTA_DIFF			1.0e-5

static extended derive(extended (*f)(extended *, extended),
											 extended p[],
											 extended x,
											 int par_number,
											 extended fp)
/*
  Dato un punto p[1..n], e "x", il valore del tempo,
	deriva numericamente la funzione "f" nel punto "p",
	rispetto al parametro numero "par_number".
  "fp" deve contenere alla chiamata il valore di f(p, x).
  In questo modo risparmiamo molte chiamate alla "f".
*/
{
  extended yIncr, h, *var_par, abs_var_par;

  /* var_par deve puntare al par. da variare */
  var_par = &(p[par_number]);

  /* calcolo l'incremento del rapp. incrementale */
	abs_var_par = fabs(*var_par);
  h = abs_var_par < 1.0 ? DELTA_DIFF : DELTA_DIFF * abs_var_par;

	/*
		old way to compute h:
		I think it was bugged since if *var_par was = 0.0, then h was set to 0.0 too.
	
  	h = fabs(*var_par) < 1.0 ? DELTA_DIFF : DELTA_DIFF * (*var_par);
		h *= SIGN(*var_par);
	*/
	
  (*var_par) += h;
  yIncr = (*f)(p, x);
  (*var_par) -= h;    /* rimetto a posto il parametro */
	
	#if qDebug
	if (classextended((yIncr-fp)/h) == QNAN) {
		sprintf(msgStr, "derive: yIncr=%.20g, fp=%.20g, h=%.20g, result=%.20g",
			yIncr, fp, h, (yIncr-fp)/h);
		writeln(msgStr);
	}
	#endif
  return (yIncr-fp)/h;
}

/* ------------------------------------------------------------------------------- */
/*
	Questa funzione computa il vettore delle derivate parziali.
	L' elemento i-esimo di questo vettore e' la derivata parziale del
	MODELLO rispetto al parametro i-esimo, computata nel punto
	corrispondente alla "j_obs"-esima osservazione.
	Tutti gli elementi vengono poi moltiplicati per la radice quadrata
	del peso corrispondente a quella osservazione.
*/
static void wComputeDerParz(extended params[], int j_obs)
{
	int i_param;
	extended w, x, fp;

	x = X[j_obs];
	fp = (*model)(params, X[j_obs]);
	w = sqrtWeights[j_obs];
	for (i_param = 0 ; i_param < NParams; i_param++)
		derParz[i_param] =
			w * derive(model, params, x, i_param, fp);
}

/* ---------------------------------------------------------------------------- */
/*
	Idem, in versione non pesata.
*/
static void computeDerParz(extended params[], int j_obs)
{
	int i_param;
	extended fp, x;

	x = X[j_obs];
	fp = model(params, x);
	for (i_param = 0 ; i_param < NParams; i_param++)
		derParz[i_param] = derive(model, params, x, i_param, fp);
}

#if qELS
/* ------------------------------------------------------------------------------ */
/*
	Questa funzione computa la riga dello Jacobiano, a meno di
	un fattore pari a 1/(sqrt(Log(afb) + sqrfmy/(afb))), cioe'
	1/sqrt(termine della somma della funzione obiettivo ELS)
*/
static void 		ELSComputeJacobianRow(extended X[],
																			extended Y[],
																			extended params[],
																			int NParams,
																			int j_obs,
																			extended (*model)(extended *, extended),
																			extended jr[])
{
	int i_param;
	extended f, afb, Df, sqrfmy, x, y, alpha, beta, logf;
	
	x = X[j_obs];
	y = Y[j_obs];
	f = model(params, x);
	alpha = params[NParams-2];
	beta = params[NParams-1];
	afb = alpha * power(f, beta);
	sqrfmy = SQR(f-y);
	
	for (i_param = 0 ; i_param < NParams-2; i_param++) {
		Df = derive(model, params, x, i_param, f);
		
		jr[i_param] = 0.5 * (beta*Df/f + 2*(f-y)*Df/(afb) - beta*sqrfmy*Df/(f*afb));
	}
	
	/* La derivata della funzione obiettivo ELS ha una forma diversa
		quando si deriva rispetto ad alfa o beta */
	jr[NParams-2] = 1/alpha - sqrfmy/(alpha*afb);
	logf = log(f);
	jr[NParams-1] = logf - (logf * sqrfmy)/afb;
}

/* ------------------------------------------------------------------------------- */
#define EPSILON 1.0e-5
/* approximate hessian with finite differences method */
void computeELSHessianAndGradient(
															extended X[],
															extended Y[],
															int NObservations,
															extended p[],
															int NParams,
															extended (*model)(extended *, extended),
															extended **H,
															extended gradient[])
{
	int i,j;
	extended sum;
	extended h, hi, hj, term1, term2, term3;
	
	sum = ComputeELSSum(X,Y,NObservations,p,NParams,model);

	/* compute gradient first */
	for (i=0; i<NParams; i++) {
	  h = fabs(p[i]) < 1.0 ? EPSILON : EPSILON * p[i];
		h *= SIGN(p[i]);		/* BUG: if p[i] is null, h becomes null ! */
		p[i] += h;
		
		term1 = ComputeELSSum(X,Y,NObservations,p,NParams,model);
#if qDebug
		setexception(UNDERFLOW, false);
#endif
		gradient[i] = (term1 - sum) / h;
#if qDebug
		if (testexception(UNDERFLOW)) {
			SysBeep(2);
			writeln("computeELSHessianAndGradient:  UNDERFLOW");
			synch;
			setexception(UNDERFLOW, false);
		}
#endif
		p[i] -= h;
	}
	
	/* compute hessian now */
	for (i=0; i<NParams; i++) {
		hi = fabs(p[i]) < 1.0 ? EPSILON : EPSILON * p[i];
		hi *= SIGN(p[i]);		/* BUG: if p[i] is null, h becomes null ! */
		p[i] += hi;
		term2 = ComputeELSSum(X,Y,NObservations,p,NParams,model);
		p[i] -= hi;
		
		for (j=0; j<NParams; j++)
			if (i > j)
				H[i+1][j+1] = H[j+1][i+1];	/*�H is symmetrical */
			else {
				hj = fabs(p[j]) < 1.0 ? EPSILON : EPSILON * p[j];
				hj *= SIGN(p[j]);		/* BUG: if p[i] is null, h becomes null ! */
				p[i] += hi;
				p[j] += hj;
				term1 = ComputeELSSum(X,Y,NObservations,p,NParams,model);
				p[i] -= hi;
				term3 = ComputeELSSum(X,Y,NObservations,p,NParams,model);
				p[j] -= hj;
	
	#if qDebug
				setexception(UNDERFLOW, false);
	#endif
				H[i+1][j+1] = (term1 - term2 - term3 + sum) / (hi*hj);
	#if qDebug
				if (testexception(UNDERFLOW)) {
					SysBeep(2);
					writeln("ComputeELSHEssAndGrad:  UNDERFLOW");
					synch;
					setexception(UNDERFLOW, false);
				}
	#endif
			}
	}
#if qDebug
	newline;
	writeln("ComputeELSHessAndGrad: H =");
	printMatrix(H, NParams);
	writeln("G = "); printVector(gradient, 0, NParams - 1);
	synch;
#endif
}
#endif qELS