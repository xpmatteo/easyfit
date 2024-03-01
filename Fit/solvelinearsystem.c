/*
	File SolveLinearSystem.c

	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.


	Soluzione di sistema lineare

	INTERFACE:
		La procedura "solveLinearSystem"

		La matrice dei coefficienti viene distrutta nel procedimento,
		per cui e' necessario passarne una copia nel caso si voglia
		conservarla integra.

		La soluzione viene lasciata nell' array "sol"

		Restituisce NO_ERROR se tutto e' andato bene;
		NO_SOLUTIONS se la mat. dei coeff. e' singolare

		NO_SOLUTIONS viene restituito quando non si riesce a trovare un
		elemento, come pivot, che sia non nullo.

	IMPLEMENTATION:
		Il metodo usato e' quello della decomposizione della matrice in
		forma bi-triangolare.  Piena documentazione dell' algoritmo
		puo' essere trovata nell libro di Press (1988).
*/

#include "fit.h"

int solveLinearSystem(sol, workMat, coeffMat, knownVector, dimension, indx)

extended **workMat;		/* punta a una matrice delle stesse dimensioni
												 di quella dei coefficienti; questa viene
												 usata come area di lavoro, e quello che
												 conteneva prime della  chiamata viene
												 cancellato. */
extended **coeffMat;	/* un puntatore a una matr. quadrata */
extended knownVector[];	/* deve puntare al vettore dei termini noti */
extended sol[];			/* deve puntare a un vettore lungo quanto
											 knownVector.  Alla uscita dalla procedura,
											 contiene la soluzione.	*/
int dimension;			/* la dimensione del problema */
short indx[];			/* vettore di sevizio; deve puntare a un vettore
										 di "dimension" elementi.  Viene passato
										 come un argomento per questi motivi:
										- voglio metterlo nello heap perche' non
											voglio far crescere troppo lo stack
										- non voglio dovere chiamare la NewPtr
											ogni volta che entra in questa procedura
										- voglio chiedere tutta la memoria che mi
											serve all' ingresso della procedura fit.
									*/

{
	extended nOfPerm;
	int retVal;

	int ludcmp();
	void lubksb();

	copyVector(sol, knownVector, dimension);
	copyMatrix(workMat, coeffMat, dimension);

	if(retVal = ludcmp(workMat, dimension, indx, &nOfPerm))
		return retVal;
	lubksb(workMat, dimension, indx, sol - 1);
	return NO_ERROR;
}

