/*
	Dosaggi	multipli.
	Al soggetto	viene	somministrata	una	dose iniziale	per	endovena;
	quindi a intervalli	regolari viene somministrata una dose	di
	mantenimento per via orale.

	Parametri:
		i	parametri	p1-p3	si riferiscono alle	dosi di	mantenimento
		i	parametri	p4-p7	si riferiscono alla	dose iniziale
*/

#include <SANE.h>

#define	tau				60.0		/* intervallo	fra	due	dosi di	mantenimento */
#define	n_dosi		8				/* numero	delle	dosi di	mantenimento */


extended dosaggi_mult(p, x)
extended p[], x;
{
	extended tot, t;
	int i;

	/* dose	iniziale */
  tot	= p[3]*exp(-p[4]*x) + p[5]*exp(-p[6]*x);


  /* dosi	di mantenimento	*/
/*
	for (i=0; i<n_dosi; i++)
	  if (x > tau*i) {
			  t	= x-tau*i;
			  tot	+= p[0]*(exp(-p[1]*t)-exp(-p[2]*t));
		}
*/
	return tot;
}
