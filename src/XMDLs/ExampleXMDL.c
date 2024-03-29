/*
		This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
		Copyright © 1989-1990 Matteo Vaccari & Mario Negri Institute. All rights
		reserved.

		Example EasyFit External Model (XMDL).
*/
	
#include <SANE.h>
#include "EasyFitXMdl.h"

extended model(double *p, extended x);	/* declare this forward */


/* this MUST be the first function appearing in the file */
void	Dispatch(XMdlBlockPtr block)	
{
	switch(block->request) {
		case rInitialize:						
			/* We simply return kInitializeOK. But if we wanted to compile
				 this XMDL with the -mc68881 option, then
				 it would be a good idea to check here for the
				 presence of the floating point unit. 
				 We could do it like this: 
				 
				 if (EFGetConfigRecord(block)->hasFPU)
				 		block->initializeResult = kInitializeOK;
				 else
				 		block->initializeResult = kInitializeFailed;

				 Remember that if you return kInitializeFailed, the xmdl will
				 immediately be purged from memory, and you'll
				 NOT receive a rFinished message.

				 If you want to check for a particular version of the System
				 Software, do it for instance like this:
				 
				 if (EFGetConfigRecord(block)->systemVersion >= 0x700)
				 		block->initializeResult = kInitializeOK;
				 else
				 		block->initializeResult = kInitializeFailed;
						
				 This code ensures that the XMDL will only run with System Software
				 version 7.0 or higher. Remember, EasyFit forces the user to
				 use at least version 6.0, so you don't need to check for that.

				 If you return kInitializeFailed, EasyFit will cancel the fitting
				 and issue an alert saying: "Fit failed because the external model
				 is incompatible." or something similar. If your
				 initialization went wrong because of a lack of memory, it is better
				 to call FailNIL. This way the message will be more appropriate.
				 Simlarly, if you failed to load a resource of yours, call FailNILResource
				 or FailResError.
			*/
			block->initializeResult = kInitializeOK;
			break;

		case rModelName:						/* write our name */
			EFWriteln(block, "This is the Example XMDL!");
			EFWriteln(block, " y := p1*exp(-p2*x) ");
			break;

		case rGiveNParams:					/* we must say how many parameters we use */
			block->NParams = 2;
			break;

		case rPeeling:							/* We don't provide a peeling service */
			block->peelingResult = kPeelingFailed;
			break;

		case rModel:								/* do the real stuff */
			block->y = model(block->params, block->x);
			break;

		case rFinalComputations:		/* we ignore it */
			break;

		case rFinished:							/* we ignore it */
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
	 EasyFit callbacks. You must include it AFTER Dispatch;
	 Dispatch must always be the first function in the file, so
	 that it is executed first.
*/
#include "EasyFitXMdl.glue.c"

