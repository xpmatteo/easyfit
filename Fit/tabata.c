/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	----------------

	Contiene le procedure che forniscono i valori nuovi per
	il fattore e l'indice di Tabata-Ito.

	La modifica di Sacchi Landriani si attiva definendo il
	simbolo SACCHI_LANDRIANI a un valore <> 0.

	6/11/89 - Trovato un errore: in realta' la modifica di Tabata Ito
	non era stata implementata, a causa di un errore nel nesting
	degli IF.  Ora e' corretto e l'alg. sembra comportarsi meglio.
*/

#include "fit.h"

#define SACCHI_LANDRIANI 1

static void updateHistory();

int newTabataIntWhenIncreased(int oldInt)
{
#if xqDebug
	write("newTabataInt wh. inc.:");
	write_history(INCREASED, minimHistory);
#endif

	/* Controlla che esista una history abbastanza lunga */
	if (minimHistory[0] == UNDEFINED)
		return(oldInt);

	if (minimHistory[0] == INCREASED) {
		if (minimHistory[1] == INCREASED && oldInt < 3)
			return(3);
	}
	else if (minimHistory[0] == DECREASED && oldInt > 1)
		return(oldInt - 1);

	/* se i casi precedenti non si sono verificati, allora non
	   varia il parametro */

	return oldInt;
}

int newTabataIntWhenDecreased(int oldInt)
{
#if xqDebug
	write("newTabataInt wh. dec.:");
	write_history(DECREASED, minimHistory);
#endif

	/* Controlla che esista una history abbastanza lunga */
	if (minimHistory[0] == UNDEFINED)
		return(oldInt);

	if (minimHistory[0] == DECREASED) {
		if (minimHistory[1] == DECREASED &&
		    oldInt < 5)
			return(oldInt + 1);		/* DDD */
	}
	else
		if (minimHistory[0] == INCREASED) {
			if ((minimHistory[1] == INCREASED ||
			    minimHistory[1] == UNDEFINED) &&
			    oldInt > 1)
				return(oldInt - 1);		/* ID, IID */
#if SACCHI_LANDRIANI
			else {
				if (minimHistory[1] == DECREASED &&
						minimHistory[2] == INCREASED &&
						oldInt < 4)
					return(oldInt + 2);
			}
#endif SACCHI_LANDRIANI
	}
	return(oldInt);
}

extended newTabataFactorWhenDecreased(int *pTabataInt)
{
	*pTabataInt = newTabataIntWhenDecreased(*pTabataInt);
	updateHistory(DECREASED);
	return valOfTabataFactor[*pTabataInt];
}

extended newTabataFactorWhenIncreased(int *pTabataInt)
{
	*pTabataInt = newTabataIntWhenIncreased(*pTabataInt);
	updateHistory(INCREASED);
	return(valOfTabataFactor[*pTabataInt]);
}

static void updateHistory(int how)
{
#if SACCHI_LANDRIANI
	minimHistory[2] = minimHistory[1];
#endif SACCHI_LANDRIANI
	minimHistory[1] = minimHistory[0];
	minimHistory[0] = how;
}

#if qDebug
	write_history(recent, history)
	short recent, history[];
	{
		char *names[] = { ".", "I", "D" };
		
		write("History:");
		write(names[history[2]]);
		write(names[history[1]]);
		write(names[history[0]]);
		writeln(names[recent]);
		synch;
	}
#endif