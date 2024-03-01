/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989 Matteo Vaccari & Mario Negri Institute
*/

#ifndef __ViewTypes__
#include "ViewTypes.r"
#endif

/* include my definitions */
#include "Declarations.r"

resource 'view' (kUserDefinedModelDlog, 
#if qNames
"User Function", 
#endif
purgeable) { {

	root, 'wind', {50, 40}, {272, 432}, sizeFixed, sizeFixed, shown, enabled, 
	Window {"TWindow", zoomDocProc, noGoAwayBox, resizable, modal, ignoreFirstClick, 
		freeOnClosing, disposeOnFree, doesntCloseDocument, dontOpenWithDocument, 
		dontAdaptToScreen, dontStagger, dontForceOnScreen, dontCenter, 'prgm', "User Defined Model"}, 

	'wind', 'dlog', {0, 0}, {272, 432}, sizeSuperView, sizeSuperView, shown, enabled, 
	DialogView {"TDialogView", 'ok  ', 'cncl'}, 

	'dlog', 'ok  ', {4, 8}, {24, 72}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", adnRRect, {3, 3}, sizeable, notDimmed, notHilited, 
		dismisses, {4, 4, 4, 4}, systemFont, "OK"}, 

	'dlog', 'scrl', {32, 0}, {225, 417}, sizeRelSuperView, sizeRelSuperView, shown, disabled, 
	Scroller {"TScroller", VertScrollBar, HorzScrollBar, 256, 256, 16, 16, noVertConstrain, 
		noHorzConstrain, noInset}, 

	'scrl', 'prgm', {0, 0}, {225, 1020}, sizeVariable, sizePage, shown, enabled, 
	TEView {"TTEView", withoutStyle, crOnly, acceptChanges, dontFreeText, cTyping, 
		unlimited, {4, 4, 4, 4}, justSystem, plain, 12, black, "Monaco"}, 

	'dlog', 'cncl', {8, 88}, {16, 64}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", noAdornment, sizeable, notDimmed, notHilited, 
		dismisses, noInset, systemFont, "Cancel"}, 

	'dlog', 'iprt', {8, 160}, {16, 40}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", noAdornment, sizeable, notDimmed, notHilited, 
		dismisses, noInset, applFont9, "Import"}, 

	'dlog', 'msgs', {8, 256}, {16, 228}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TStaticText", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, applFont12, justSystem, ""}, 

	'dlog', 'xprt', {8, 208}, {16, 40}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", noAdornment, sizeable, notDimmed, notHilited, 
		dismisses, noInset, applFont9, "Export"}
	}
};