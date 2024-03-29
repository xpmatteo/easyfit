/*
	Difficult - generate "difficult" data sets for nl-fit
*/

#include <time.h>
#include <stdio.h>
#include <math.h>

#define N 30			/* size of the problem */
#define DELTA 0.5	/* variazione % dei dati */
#define A 11.0
#define B 10.0
#define alfa 0.58
#define beta 0.55

extended X[N], Y[N], Param[10];
extended seed;

extended drand48 ()
{
	return randomx(&seed) / 2147483646.0;
}

main()
{
	short i;
	extended rnd_error_factor;
	
	seed = (unsigned int) time(NULL);
	for (i = 0; i < N; i++) {
		X[i] = (extended) i;
		rnd_error_factor = 1 + DELTA * (2 * drand48() - 1);
		Y[i] = (-A * exp(-alfa	* X[i]) + B * exp(-beta * X[i])) *
						rnd_error_factor;
		/* printf ("X = %G, Y = %G\n", X[i], Y[i]); */
		printf ("%G\t%G\n", X[i], Y[i]);
	}
	exit(0);
}

/*
	codice usato per provare le funzioni random
		
		#if UNUSED
		printf("testing drand48\n");
		for (i = 0; i<N; i++)
			printf("%g\n", drand48());
		
		{
			short i;
			extended x;
			printf("testing random error factor\n");
			for (i = 0; i < N; i++) {
				x = (1 + 0.5 * (2 * drand48() - 1));
				printf("x = %f\n", x);
		}
	}
	#endif	UNUSED (test random functions)

*/