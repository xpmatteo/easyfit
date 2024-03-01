/********************************************************************************/
/*																				*/
/*	File:			GrabberTracker.r		 									*/
/*																				*/
/*	Description:	Resource File for the GrabberTracker Unit.					*/
/*																				*/
/*																				*/
/*	Copyright © 1989 by Apple Computer, Inc.  All rights reserved.  			*/
/********************************************************************************/

/* ¥ Auto-Include the requirements for this source */

#ifndef __TYPES.R__
#include "Types.r"
#endif



#Define kGrabberHand		9				/* ID for the GrabberHand cursor */


resource 'CURS' (kGrabberHand,
#if qNames
"kGrabberHand",
#endif
purgeable) {
	$"01 80 1A 70 26 48 26 4A 12 4D 12 49 68 09 98 01"
	$"88 02 40 02 20 02 20 04 10 04 08 08 04 08 04 08",
	$"01 80 1B F0 3F F8 3F FA 1F FF 1F FF 7F FF FF FF"
	$"FF FE 7F FE 3F FE 3F FC 1F FC 0F F8 07 F8 07 F8",
	{9, 8}
};
