/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989 Matteo Vaccari & Mario Negri Institute
*/

/* ¥ Auto-Include the requirements for this source */
#ifndef __ViewTypes__
#include "ViewTypes.r"
#endif

/* include my definitions */
#include "Declarations.r"


resource 'view' (kWorkingWindowType, 
#if qNames
"Working", 
#endif
purgeable) {{

	root, 'WIND', {50, 40}, {80, 336}, sizeVariable, sizeVariable, shown, enabled, 
	Window {"TWindow", documentProc, noGoAwayBox, notResizable, modeless, doFirstClick, 
		freeOnClosing, disposeOnFree, doesntCloseDocument, openWithDocument, 
		dontAdaptToScreen, dontStagger, forceOnScreen, dontCenter, 'ABRT',
		"WorkingÉ"}, 

	'WIND', 'DLOG', {0, 0}, {80, 336}, sizeFixed, sizeFixed, shown, enabled, 
	DialogView {"TDialogView", noID, 'ABRT'}, 

	'DLOG', 'PERC', {48, 16}, {16, 208}, sizeFixed, sizeFixed, shown, disabled, 
	View {"TPercDoneBarView"}, 

	'DLOG', 'ABRT', {48, 240}, {16, 80}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", noAdornment, sizeable, notDimmed, notHilited, 
		dismisses, noInset, systemFont, "Stop"}, 

	'DLOG', 'TEXT', {16, 16}, {16, 304}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TStaticText", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, justSystem, ""}
	}
};