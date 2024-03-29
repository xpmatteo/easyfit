/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989 Matteo Vaccari & Mario Negri Institute
*/

#ifndef __ViewTypes__
#include "ViewTypes.r"
#endif

/* include my definitions */
#include "Declarations.r"

resource 'view' (kAboutMarioNegri, 
#if qNames
"About Mario Negri", 
#endif
purgeable) {{

	root, 'wind', {50, 40}, {192, 448}, sizeVariable, sizeVariable, shown, enabled, 
	Window {"TWindow", altDBoxProc, noGoAwayBox, notResizable, modal, ignoreFirstClick, 
		freeOnClosing, disposeOnFree, doesntCloseDocument, openWithDocument, 
		dontAdaptToScreen, dontStagger, dontForceOnScreen, center, 'ok  ', "<<<>>>"}, 

	'wind', 'dlog', {0, 0}, {192, 448}, sizeVariable, sizeVariable, shown, enabled, 
	DialogView {"TDialogView", 'ok  ', noID}, 

	'dlog', 'pict', {16, 16}, {128, 416}, sizeFixed, sizeFixed, shown, disabled, 
	Picture {"TPicture", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, 1112}, 

	'dlog', 'ok  ', {154, 357}, {28, 76}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", adnRRect, {3, 3}, sizeable, notDimmed, notHilited, 
		dismisses, {4, 4, 4, 4}, plain, 14, black, "Times", "OK"}
	}
};