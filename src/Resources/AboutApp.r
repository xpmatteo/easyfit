/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989 Matteo Vaccari & Mario Negri Institute
*/

#ifndef __ViewTypes__
#include "ViewTypes.r"
#endif

/* include my definitions */
#include "Declarations.r"

resource 'view' (kAboutAppView, 
#if qNames
"AboutApp", 
#endif
purgeable) {{

	root, 'wind', {15, 15}, {312, 482}, sizeVariable, sizeVariable, shown, enabled, 
	Window {"TWindow", altDBoxProc, noGoAwayBox, notResizable, modal, ignoreFirstClick, 
		freeOnClosing, disposeOnFree, closesDocument, openWithDocument, 
		dontAdaptToScreen, dontStagger, dontForceOnScreen, center, 'text', "<<<>>>"}, 

	'wind', 'dlog', {0, 0}, {312, 482}, sizeFixed, sizeFixed, shown, enabled, 
	DialogView {"TDialogView", 'ok  ', noID}, 

	'dlog', 'ok  ', {280, 396}, {28, 76}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", adnRRect, {3, 3}, sizeable, notDimmed, notHilited, 
		dismisses, {4, 4, 4, 4}, 1, 0, black, "A", "OK"}, 

	'dlog', 'VW07', {288, 8}, {16, 64}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TStaticText", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, applFont12, justCenter, "Version:"}, 

	'dlog', 'VW08', {288, 176}, {16, 48}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TStaticText", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, applFont12, justCenter, "Date:"}, 

	'dlog', 'vers', {288, 72}, {16, 96}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TStaticText", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, applFont12, justCenter, ""}, 

	'dlog', 'date', {288, 224}, {16, 112}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TStaticText", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, applFont12, justCenter, ""}, 

	'dlog', 'brdr', {3, 3}, {274, 475}, sizeFixed, sizeFixed, shown, disabled, 
	Control {"TControl", 0b111, {1, 1}, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont}, 

	'brdr', 'scrl', {1, 1}, {272, 458}, sizeFixed, sizeFixed, shown, enabled, 
	Scroller {"TScroller", VertScrollBar, noHorzScrollBar, 256, 256, 16, 16, noVertConstrain, 
		noHorzConstrain, noInset}, 

	'scrl', 'text', {0, 0}, {272, 458}, sizeVariable, sizeFixed, shown, disabled, 
	TEView {"TTEView", withStyle, autoWrap, dontAcceptChanges, dontFreeText, cTyping, 
		unlimited, {4, 4, 4, 4}, justSystem, plain, 0, black, "Geneva"}
	}
};