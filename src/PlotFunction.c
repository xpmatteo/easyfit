/*
		This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
		Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.

		----------------------
		Viene definita qui una collezione di funzioni usate nelle finestre
		dei grafici.
*/

#include <Types.h>
#include <Quickdraw.h>
#include <SANE.h>

pascal DRAWSMALLYTICK(x, y)
short x,y;
extern;

#pragma segment GrafWindObjs

#define OneOverLogOf10		0.43429448190325182760
#define log10(x)					(log(x) * OneOverLogOf10)

/* le macro MAPX e MAPY trasformano le coordinate della funzione
	nelle coordinate dello schermo */
#define MAPX(f_x) (((f_x - f_x_min) * scr_x_interval) / f_x_interval + scr_x_min)
#define MAPY(f_y) (((f_y - f_y_min) * scr_y_interval) / f_y_interval + scr_y_min)
										
pascal short int ExtToInteger(extended x) extern;

/* ------------------------------------------------------------------------------- */
/*
	PlotFunction - plot a diagram of a function on the current
	grafport.
*/
void PlotFunction(scr_x_min, scr_x_max, scr_y_min, scr_y_max,
								  f_x_min, f_x_max, f_y_min, f_y_max,
									steps,
									func,
									params)
						 
/* Questo e' il rettangolo del grafport che deve contenere il 
	grafico */
short scr_x_min, scr_x_max, scr_y_min, scr_y_max;

/* Questo rettangolo invece e' la porzione del piano reale in cui 
	devo calcolare la funzione */
extended f_x_min, f_x_max, f_y_min, f_y_max;

/* Questa e' una misura della accuratezza con cui devo fare il 
	disegno della funzione; e' che la funzione viene valutata.*/
short steps;

/* un puntatore alla funzione da plottare */
extended (*func)();

/* l'array di parametri da passare alla funzione */
extended params[];
{
		/* var dip e indip della f plottanda */
		extended x,y;
		
		/* il periodo cui la funzione deve essere campionata. */
		extended dx;
		
		/* var di servizio */
		extended f_x_interval, f_y_interval;
		short scr_x_interval, scr_y_interval;
		
		/* inizializza alcune var di servizio */
		f_x_interval = f_x_max - f_x_min;
		f_y_interval = f_y_max - f_y_min;
		scr_x_interval = scr_x_max - scr_x_min;
		scr_y_interval = scr_y_max - scr_y_min;

		dx = f_x_interval / steps;

		/* computa la locazione del primo punto. */
		x = f_x_min;
		y = func(params, x);
		
		/* Porta la penna al punto iniziale; se il punto iniziale e' Nan,
			avanza sull'asse x fino a che non trova un punto non-nan. */
		{
			extended tmp = MAPY(y);
			while (classextended(tmp)==QNAN || classextended(tmp)==SNAN) {
				x = x + dx;
				if (x > f_x_max)
					return;
				y = func(params, x);
				tmp = MAPY(y);
			}
			MoveTo(MAPX(x), ExtToInteger(tmp));
		}
		
		/*
			disegna il resto della funzione. Qui non abbiamo supporto contro i nan. 
		*/
		while (x < f_x_max) {
			x += dx;
			if (x > f_x_max)
				x = f_x_max;
			y = func(params, x);
			LineTo(ExtToInteger(MAPX(x)), ExtToInteger(MAPY(y)));
		}		/* while */
}				/* plotFunction */

/*
	PlotSemilogFunction - plot a diagram of a function on the current
	grafport, transforming y as log10(y).  Otherwise same as
	PlotFunction.
*/
void PlotSemilogFunction(scr_x_min, scr_x_max, scr_y_min, scr_y_max,
												 f_x_min, f_x_max, f_y_min, f_y_max,
												 steps,
												 func,
												 params)
short scr_x_min, scr_x_max, scr_y_min, scr_y_max;
extended f_x_min, f_x_max, f_y_min, f_y_max;
short steps;
extended (*func)();
extended params[];
{
		/* var dip e indip della f plottanda */
		extended x,y;
		
		/* il periodo cui la funzione deve essere campionata. */
		extended dx;
		
		/* var di servizio */
		extended f_x_interval, f_y_interval;
		short scr_x_interval, scr_y_interval;
		
		#if qDebug
		extern pascal long gFocusedView;
		long oldFocus = gFocusedView;
		#endif
		
		/* trasformo i limiti del dominio */
		f_y_min = log10(f_y_min);
		f_y_max = log10(f_y_max);
		
		/* inizializza alcune var di servizio */
		f_x_interval = f_x_max - f_x_min;
		f_y_interval = f_y_max - f_y_min;
		scr_x_interval = scr_x_max - scr_x_min;
		scr_y_interval = scr_y_max - scr_y_min;

		dx = f_x_interval / steps;

		/* computa la locazione del primo punto. */
		x = f_x_min;
		y = func(params, x);
		
		/* Porta la penna al punto iniziale; se il punto iniziale e' Nan,
			avanza sull'asse x fino a che non trova un punto non-nan. */
		{
			extended tmp = MAPY(log10(y));
			while (classextended(tmp)==QNAN || classextended(tmp)==SNAN) {
				x = x + dx;
				if (x > f_x_max)
					return;
				y = func(params, x);
				tmp = MAPY(log10(y));
			}
			MoveTo(MAPX(x), ExtToInteger(tmp));
		}
		
		/* Actually draw the plot */
		while (x < f_x_max) {
			x += dx;
			if (x > f_x_max)
				x = f_x_max;
			y = func(params, x);
			LineTo(ExtToInteger(MAPX(x)), ExtToInteger(MAPY(log10(y))));
		}		/* while */
}				/* PlotSemilogFunction */

/*
	PlotSemilogSmallTicks - plot small ticks on the Y axis, 
	transforming y as log10(y).
*/
void PlotSemilogSmallTicks(scr_x, scr_y_min, scr_y_max,
													 f_y_min, f_y_max,
													 num_intervals)
short scr_x, scr_y_min, scr_y_max;
extended f_y_min, f_y_max;
short num_intervals;
{		
		/* var di servizio */
		extended f_y_interval;
		short scr_y_interval;
		int i;
		extended y;
		extended step;
		
		y = f_y_min;
		step = (f_y_max - f_y_min) / num_intervals;
		
		/* trasformo i limiti del dominio */
		f_y_min = log10(f_y_min);
		f_y_max = log10(f_y_max);
		
		/* inizializza alcune var di servizio */
		f_y_interval = f_y_max - f_y_min;
		scr_y_interval = scr_y_max - scr_y_min;

		for(i=0; i < num_intervals; i++) {
			DRAWSMALLYTICK(scr_x, ExtToInteger(MAPY(log10(y))));
			y += step;
		}
}				/* PlotSemilogSmallTicks */


/*
	DrawCircle - Disegna un circoletto centrato nel punto x,y del
	grafport corrente.
*/
void DrawCircle(scr_x, scr_y)
short scr_x, scr_y;
{
	Rect theRect;
	
	SetRect(&theRect, scr_x, scr_y, scr_x, scr_y);
	InsetRect(&theRect, -3, -3);
	FrameOval(&theRect);
}
	
/*
	DrawCross - Disegna una crocetta centrata nel punto x,y del
	grafport corrente.  
	CROSS_SIZE e' la lunghezza della crocetta. E' bene che sia sempre
	dispari, cosi' puo' esseere centrata bene in un punto.
*/

#define CROSS_SIZE 7

void DrawCross(scr_x, scr_y)
short scr_x, scr_y;
{
	/* traccia il braccio orizzontale */
	MoveTo(scr_x - CROSS_SIZE / 2, scr_y);
	Line(CROSS_SIZE - 1, 0);
	
	/* traccia quello verticale */
	MoveTo(scr_x, scr_y - CROSS_SIZE / 2);
	Line(0, CROSS_SIZE - 1);
}

	
/*
	PlotPoint - plot a single point of the real plane on the current
	grafport.
*/

#define MAPX2(f_x) (((f_x - f_x_min) * (scr_x_max - scr_x_min)) / (f_x_max - f_x_min) + scr_x_min)
#define MAPY2(f_y) (((f_y - f_y_min) * (scr_y_max - scr_y_min)) / (f_y_max - f_y_min) + scr_y_min)

void PlotPoint(scr_x_min, scr_x_max, scr_y_min, scr_y_max,
							 f_x_min, f_x_max, f_y_min, f_y_max,
							 f_x,f_y)
						 
/* Questo e' il rettangolo del grafport che deve contenere il 
	grafico */
short scr_x_min, scr_x_max, scr_y_min, scr_y_max;

/* Questo rettangolo invece e' la porzione del piano reale cui 
	deve corrispondere il rettangolo di QuickDraw */
extended f_x_min, f_x_max, f_y_min, f_y_max;

/* il punto da plottare */
extended f_x,f_y;

{
	/* ExtToInteger e' una procedura pensata per il pascal, per cui dal
		 punto di vista del C restituisce uno short integer. */
	DrawCross(ExtToInteger(MAPX2(f_x)), ExtToInteger(MAPY2(f_y)));
}				


/*
	PlotSemilogPoint - plot a single point of the real plane on the 
	current grafport, transforming y as log10(y).  Otherwise same as 
	PlotPoint.
*/

void PlotSemilogPoint(scr_x_min, scr_x_max, scr_y_min, scr_y_max,
											f_x_min, f_x_max, f_y_min, f_y_max,
											f_x,f_y)

short scr_x_min, scr_x_max, scr_y_min, scr_y_max;
extended f_x_min, f_x_max, f_y_min, f_y_max;
extended f_x,f_y;

{
	/* trasformo i limiti del dominio */
	f_y_min = log10(f_y_min);
	f_y_max = log10(f_y_max);
	
	DrawCross(ExtToInteger(MAPX2(f_x)), ExtToInteger(MAPY2(log10(f_y))));
}				

/*
	DrawZeroLine - disegna un linea orizzontale tratteggiata in corris-
	pondenza dello zero, sul grafport corrente.  Serve per il grafico
	dei residui standardizzati.
*/

void DrawZeroLine(scr_x_min, scr_x_max, scr_y_min, scr_y_max,
									f_x_min, f_x_max, f_y_min, f_y_max)
						 
/* Questo e' il rettangolo del grafport che deve contenere il 
	grafico */
short scr_x_min, scr_x_max, scr_y_min, scr_y_max;

/* Questo rettangolo invece e' la porzione del piano reale cui 
	deve corrispondere il rettangolo di QuickDraw */
extended f_x_min, f_x_max, f_y_min, f_y_max;

{
#pragma unused(f_x_min,f_x_max)
	short y;
		 
	PenPat(qd.gray);
	y = ExtToInteger(MAPY2(0));
	MoveTo(scr_x_min, y);
	LineTo(scr_x_max, y);
	PenPat(qd.black);
}				
