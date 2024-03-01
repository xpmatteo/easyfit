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

resource 'view' (kDataAndFuncPlotWindowType,
#if qNames
"Data & Func Plot",
#endif
purgeable) {{

	root, 'wind', {50, 40}, {288, 448}, sizeVariable, sizeVariable, shown, enabled, 
	Window {"TPlotWindow", zoomDocProc, goAwayBox, resizable, modeless, ignoreFirstClick, 
		dontFreeOnClosing, disposeOnFree, doesntCloseDocument, dontOpenWithDocument, 
		dontAdaptToScreen, dontStagger, dontForceOnScreen, dontCenter, 'plot', "Data & Model plot Ò<<<>>>Ó"}, 

	'wind', 'prnt', {0, 0}, {288, 448}, sizeRelSuperView, sizeRelSuperView, shown, disabled, 
	View {"TDataAndFuncPlotPrintView"}, 

	'prnt', 'info', {0, 8}, {16, 96}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TPlotWindowInfoView", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, applFont12, justCenter, ""}, 

	'prnt', 'plot', {16, 2}, {270, 446}, sizeRelSuperView, sizeRelSuperView, shown, disabled, 
	View {"TDataAndFuncPlotView"}, 

	'wind', 'xpr1', {0, 112}, {16, 88}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, applFont12, "Export ThisÉ"}, 

	'wind', 'xpra', {0, 204}, {16, 80}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, applFont12, "Export AllÉ"}, 

	'wind', 'scbr', {-1, 288}, {16, 160}, sizeFixed, sizeRelSuperView, shown, enabled, 
	ScrollBar {"TPlotWindowScrollBar", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, 0, 0, 100}
	}
};