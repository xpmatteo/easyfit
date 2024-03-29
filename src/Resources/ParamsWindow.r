/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989 Matteo Vaccari & Mario Negri Institute
*/

/* --- See explanations in ExpDataWindow.r --- */

/* � Auto-Include the requirements for this source */
#ifndef __Types__
#include "Types.r"
#endif

#ifndef __ViewTypes__
#include "ViewTypes.r"
#endif

/* include my definitions */
#include "Declarations.r"

#define kParamsMaxRows kMaxParams
#define kParamsMaxCols kMaxSubjects

resource 'view' (kParamsWindowType,
#if qNames
"Parameters",
#endif
purgeable) {{

	root, 'WIND', { 40, 10 }, { 288, 447 }, sizeVariable, sizeVariable, notShown, enabled, 
	Window{ "TWindow", zoomDocProc, goAwayBox, resizable, modeless, ignoreFirstClick, 
		dontFreeOnClosing, disposeOnFree, doesntCloseDocument, openWithDocument, 
		dontAdaptToScreen, dontStagger, dontForceOnScreen, dontCenter, noID, "Parameters �<<<>>>�" };
	
	'WIND', 'prnt', {35-kCellHeight, 0}, {221+2*kCellHeight+kSBarSizeMinus1, 400+32+kSBarSizeMinus1},
	sizeRelSuperView, sizeRelSuperView,	shown, enabled, View {"TTablePrintView"},	
	
	'prnt', 'SCL1', { 2*kCellHeight, 32 }, { 221, 400 }, sizeRelSuperView, sizeRelSuperView, shown, enabled, 
	Scroller {"TTableScroller", VertScrollBar, HorzScrollBar, kCellHeight, kCellWidth, 0, 0, VertConstrain, 
		 HorzConstrain, {-16, -31, 0, 0 }}, 

	'SCL1', 'CELL', { 0, 0 }, { 0, 0 }, sizeVariable, sizeVariable, shown, enabled, 
	TextGridView {"TCellsView", kParamsMaxRows, kParamsMaxCols, kCellHeight, kCellWidth, kRowInset, kColumnInset, AdornRows, AdornCols, 
		multipleSelection, plain, kFontSize, { 0x0, 0x0, 0x0 }, "a" }, 

	'prnt', 'SCL2', { kCellHeight, 32 }, { kCellHeight, 400 }, sizeVariable, sizeRelSuperView, shown, enabled, 
	Scroller {"TScroller", noVertScrollBar, noHorzScrollBar, kCellHeight, kCellHeight, kCellHeight, kCellHeight, noVertConstrain, 
		 noHorzConstrain, noInset }, 

	'SCL2', 'COLS', { 0, 0 }, { kCellHeight, 400 }, sizeVariable, sizeVariable, shown, enabled, 
	TextGridView {"TColumnsView", 1, kParamsMaxCols, kColumnTitleHeight, kCellWidth, 0, kColumnInset, dontAdornRows, AdornCols, 
		multipleSelection, bold, kFontSize, { 0x0, 0x0, 0x0 }, "a" }, 

	'prnt', 'SCL3', { 2*kCellHeight, 0 }, { 221, 32 }, sizeRelSuperView, sizeVariable, shown, enabled, 
	Scroller {"TScroller", noVertScrollBar, noHorzScrollBar, kCellHeight, kCellWidth, 0, 0, noVertConstrain, 
		 noHorzConstrain, noInset }, 

	'SCL3', 'ROWS', { 0, 0 }, { 237, 32 }, sizeVariable, sizeVariable, shown, enabled, 
	TextGridView {"TRowsView", kParamsMaxRows, 1, kCellHeight, kRowTitleWidth, kRowInset, 0, AdornRows, dontAdornCols, 
		multipleSelection, bold, kFontSize, { 0x0, 0x0, 0x0 }, "a" }, 

	'WIND', 'ENTV', { 8, 16 }, { 20, 364 }, sizeFixed, sizeFixed, shown, enabled, 
	TEView {"TEntryView", withoutStyle, crOnly, acceptChanges, dontFreeText, cTyping, 
		kMaxChars, {2, 2, 2, 2}, justLeft, plain, kFontSize, { 0x0, 0x0, 0x0 }, "a"}
	}
};