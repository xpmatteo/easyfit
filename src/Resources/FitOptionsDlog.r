/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989 Matteo Vaccari & Mario Negri Institute
*/

#ifndef __ViewTypes__
#include "ViewTypes.r"
#endif

/* include my definitions */
#include "Declarations.r"


resource 'view' (kFitOptionsDlog, 
#if qNames
"Fit Options", 
#endif
purgeable) { {
	root, 'wind', {50, 40}, {256, 320}, sizeVariable, sizeVariable, shown, enabled, 
	Window {"TWindow", dBoxProc, noGoAwayBox, notResizable, modal, ignoreFirstClick, 
		freeOnClosing, disposeOnFree, doesntCloseDocument, dontOpenWithDocument, 
		dontAdaptToScreen, dontStagger, forceOnScreen, centerHorizontally, 'LAMB', "Fit Options"}, 

	'wind', 'DLOG', {0, 0}, {256, 320}, sizeFixed, sizeFixed, shown, enabled, 
	DialogView {"TDialogView", 'ok  ', 'cncl'}, 

	'DLOG', 'UNAT', {84, 16}, {20, 144}, sizeFixed, sizeFixed, shown, enabled, 
	CheckBox {"TCheckBox", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, off, "Work Unattended"}, 

	'DLOG', 'FUOU', {135, 16}, {20, 160}, sizeFixed, sizeFixed, shown, enabled, 
	CheckBox {"TCheckBox", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, off, "Output Each Iteration"}, 

	'DLOG', 'AUPE', {110, 16}, {20, 240}, sizeFixed, sizeFixed, shown, enabled, 
	CheckBox {"TCheckBox", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, on, "Automatic Peeling of Parameters"}, 

	'DLOG', 'MXIT', {196, 208}, {20, 96}, sizeFixed, sizeFixed, shown, enabled, 
	NumberText {"TNumberText", adnFrame, {1, 1}, sizeable, notDimmed, notHilited, 
		doesntDismiss, {2, 2, 2, 2}, systemFont, justRight, "50", unlimited,
		arrowsAndBackspace, 50, 0, 10000}, 

	'DLOG', 'VW06', {164, 16}, {20, 176}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TStaticText", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, justSystem, "Starting Lambda"}, 

	'DLOG', 'VW07', {196, 16}, {20, 176}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TStaticText", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, justSystem, "Maximum Iterations"}, 

	'DLOG', 'LAMB', {164, 208}, {20, 96}, sizeFixed, sizeFixed, shown, enabled, 
	EditText {"TRealText", adnFrame, {1, 1}, notSizeable, notDimmed, notHilited, 
		doesntDismiss, {2, 2, 2, 2}, systemFont, justRight, "", unlimited,
		arrowsAndBackspace}, 

	'DLOG', 'ok  ', {224, 223}, {26, 82}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", adnRRect, {3, 3}, sizeable, notDimmed, notHilited, 
		dismisses, {4, 4, 4, 4}, systemFont, "OK"}, 

	'DLOG', 'cncl', {228, 133}, {18, 74}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", noAdornment, sizeable, notDimmed, notHilited, 
		dismisses, noInset, systemFont, "Cancel"}, 

	'DLOG', 'VW03', {8, 72}, {16, 144}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TStaticText", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, justCenter, "Fit Options"}, 

	'DLOG', 'demo', {56, 16}, {20, 226}, sizeFixed, sizeFixed, shown, enabled, 
	CheckBox {"TCheckBox", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, off, "Refresh Plot at Each Iteration"}, 

	'DLOG', 'beep', {32, 16}, {16, 152}, sizeFixed, sizeFixed, shown, enabled, 
	CheckBox {"TCheckBox", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, on, "Beep When Finished"}
	}
};