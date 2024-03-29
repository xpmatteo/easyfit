/*
	File read_num.c
	
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.

	The purpose of the function supplied here is to read a floating constant
	from std input, and return the value of the constant together with
	the number of characters read. This is needed for the scanner, and
	could not be obtained from MPW scanf().
*/

#if DEBUG
#	include <stdio.h>
#endif
#include <SANE.h>

#pragma segment ACompileUserModel

/* gli stati dell'automa */
#define START 0					
#define MANTISSA 1
#define ESP_SIGN 2
#define ESP 3

/* macro */
#define isdigit(c) (c >= '0' && c <= '9')
#define value(c) (c - '0')

/* caratteri */
#define dot 	'.'
#define minus	'-'
#define plus	'+'
#define zero	'0'
#define nine	'9'
#define blank ' '

#define TRUE 1
#define FALSE 0

/* legge un numero extended senza segno dalla stringa di ingresso 
	"str", e restituisce il numero di caratteri letti. 
	Il valore viene lasciato nell' argomento "val".
	
	La funzione si ferma al primo carattere che non riesce a
	convertire, e non lo conta nel numero dei caratteri.  */
	
short read_num(str, val)
char *str;
extended *val;
{
	short state = START; 		/* lo stato dell' automa */
	
	short char_count = 0;		/* il n. di caratteri letti */
	
	extended base = 0.0; 		/* la parte del numero prima dell'esponente */
	int	esp = 0;						/* l' esponente */
			
	short mantix_len = 0;
	
	short esp_sign = 1;			/* segno dell' esponente */
	char c;
	
	short done = FALSE;
	
	while (!done) {
		c = *str++;
		char_count++;

#if DEBUG		
		/* printf("c %c, st %d, count %d, base %g, esp %d, esgn %d\n",
					 c,
					 char_count,
					 base,
					 esp,
					 esp_sign); */
#endif					

		switch (state) {
			case START:
				if (isdigit(c))
					base = base * 10 + value(c);
				else if (c == dot)
					state = MANTISSA;
				else if (c == 'e' || c == 'E')
					state = ESP_SIGN;
				else 
					done = TRUE;
				break;
				
			case MANTISSA:
				if (isdigit(c)) {
					mantix_len++;
					base = base + value(c) * ipower(10.0, -mantix_len);
				}
				else if (c == 'e' || c == 'E')
					state = ESP_SIGN;
				else 
					done = TRUE;
				break;
				
			case ESP_SIGN:
				if (c == '-')
					esp_sign = -1;
				else if (c == '+') 
					; /* do nothing */
				else if (isdigit(c)) {
					state = ESP;
					esp = esp * 10 + value(c);
				}
				else
					done = TRUE;
				break;
				
			case ESP:
				if (isdigit(c))
					esp = esp * 10 + value(c);
				else 
					done = TRUE;
				break;
		}			/* switch */
	}				/* while */
	
	char_count--;
	if (esp == 0)
		*val = base;
	else
		*val = base * ipower(10.0, esp_sign * esp);
	
	return char_count;
}					/* read_num */

#if DEBUG
/*
		main(argc, argv)
		int argc;
		char *argv[];
		{
			short cc;
			extended val;
			
			if (argc = 2) {
				cc = read_num(argv[1], &val);
				printf("str >%s<, read %g, ccount %d\n",
							 argv[1],
							 val,
							 cc);
			}
		}
*/
#endif