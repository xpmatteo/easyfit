/*
	Here is some code that generates data according to a model,
	and then adds a random error to it.
	The errors are distributed uniformly.
*/

#include <stdio.h>
#include <osutils.h>
#include <stdlib.h>
#include <sane.h>

/* #include "dosaggi_multipli.c" */

#define ERR_PERCENTAGE	20.0

/*
	One compartment model, oral adm.
*/
extended TwoExpMinus(extended p[], extended x)
{
	return  p[2] * exp(-p[3] * x) - p[0] * exp(-p[1] * x);
}

/*
	One compartment model, IV adm.
*/
extended SingleExp(extended p[], extended x)
{
	return p[0] * exp(-p[1] * x);
}


/*
	return a random number uniformly chosen from 0 to 1
*/
extended rnd_0_1()
{
	return rand() / 32767.0;
}


output_data(from, to, period, model, concise, params)
extended from, to, period, (*model)(extended *, extended), params[];
int concise;
{
	int i;
	extended x, y, err, yerr;
	
	for (i=0, x = from; x <= to; i++, x += period) {
		y = model(params, x);
		
		/* add error */
		err = y * (ERR_PERCENTAGE/100.0) * rnd_0_1();
		yerr = y + (rnd_0_1() > 0.5 ? -err : err);
		
		/* output */
		if (concise)
			printf("%.3g\t%.3g\t%.3g\t%.3g\n", x, y, yerr, err);
		else
			printf("%2d)  x = %10.3g  y = %10.3g  yerr = %10.3g\n", i+1, x, y, yerr);
	}
}


/* -------------- M A I N -------------- */

extended params[] = { 10.0, 0.58 };

#define CONCISE 1

main()
{
	unsigned long secs;

	/* init rnd_seed */
	GetDateTime(&secs);
	srand(secs);
	
	output_data(0.2, 3.0, 0.4, SingleExp, CONCISE, params);
	output_data(4.0, 10.0, 1.5, SingleExp, CONCISE, params);
	
	exit(0);
}
