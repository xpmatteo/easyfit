/*
		This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
		Copyright © 1989-1990 Matteo Vaccari & Mario Negri Institute. All rights
		reserved.

		Sample EasyFit External Model (XMDL).
*/
	
#include <SANE.h>
#include <Packages.h>
#include <Strings.h>
#include "EasyFitXMdl.h"

extended model(double *p, extended x);	/* declare this forward */


/* this MUST be the first function appearing in the file */
void	Dispatch(XMdlBlockPtr block)	
{
	switch(block->request) {
		case rInitialize:						
			EFWriteln(block, "rInitialize test XMDL!");
			block->initializeResult = kInitializeOK;
			break;

		case rModelName:						/* write our name */
			EFWriteln(block, "rModelName: This is the Krazy Test XMDL!");
			EFWriteln(block, "We just do a single exp, but writing on the Messages");
			break;

		case rGiveNParams:					/* we must say how many parameters we use */
			block->NParams = 2;
			EFWriteln(block, "rGiveNParams test XMDL!");
			break;

		case rPeeling:
			(block->params)[0] = 1.0;
			(block->params)[1] = 0.5;
			block->peelingResult = kPeelingOK;
			EFWriteln(block, "rPeeling XMDL!");
			break;

		case rModel:								/* do the real stuff */
			block->y = model(block->params, block->x);
			EFWriteln(block, "rModel test KMDL!"); /**/
			break;

		case rFinalComputations:		/* we ignore it */
			EFWriteln(block, "rFinalComputations test XMDL!");
			break;

		case rFinished:							/* we ignore it */
			EFWriteln(block, "rFinished test XMDL!");
			break;
	}
}


/* this is the "real" model code; remember that the parameters array is
	 indicized from zero! */
extended model(double *p, extended x)
{
	return p[0] * exp(-p[1] * x);
}

/*
	 This is a very important include! it contains the definitions for 
	 EasyFit callbacks. You must include it AFTER SampleModelShell;
	 SampleModelShell must always be the first function in the file.
*/
#include "EasyFitXMdl.glue.c"

