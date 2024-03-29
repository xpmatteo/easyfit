/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989 Matteo Vaccari & Mario Negri Institute
*/

/* � Auto-Include the requirements for this source */
#ifndef __Types__
#include "Types.r"
#endif

#ifndef __ViewTypes__
#include "ViewTypes.r"
#endif

/* include my definitions */
#include "Declarations.r"

#define kScBarWidth 16

#define kConstraintsMaxRows		kMaxParams
#define kConstraintsMaxCols		2

#define kConstraintsSizeH (kRowTitleWidth + kConstraintsMaxCols*kCellWidth + kScBarWidth-1)
#define kConstraintsSizeV (kColumnTitleHeight + kConstraintsMaxRows*kCellHeight + 30 + kScBarWidth)

#if qConstraints

resource 'view' (kConstraintsWindowType,
#if qNames
"Constraints",
#endif
purgeable) {{

	root, 'WIND', { 40, 10 }, { 288, kConstraintsSizeH }, sizeVariable, sizeVariable, notShown, enabled, 
	Window{ "TWindow", zoomDocProc, goAwayBox, resizable, modeless, ignoreFirstClick, 
		dontFreeOnClosing, disposeOnFree, doesntCloseDocument, openWithDocument, 
		dontAdaptToScreen, dontStagger, dontForceOnScreen, dontCenter, noID, "Constraints �<<<>>>�" };
	
	'WIND', 'prnt', {35-kCellHeight, 0}, {221+2*kCellHeight+kSBarSizeMinus1, 416},
	sizeRelSuperView, sizeRelSuperView,	shown, enabled, View {"TConstraintsTablePrintView"},	
	
	'prnt', 'SCL1', {2*kCellHeight, 32 }, { 221, kConstraintsMaxCols*kCellWidth }, sizeRelSuperView, sizeRelSuperView, shown, enabled, 
	Scroller {"TTableScroller", VertScrollBar, noHorzScrollBar, kCellHeight, kCellWidth, 0, 0, VertConstrain, 
		 HorzConstrain, {-16, -31, 0, 0 }}, 

	'SCL1', 'CELL', { 0, 0 }, { 0, 0 }, sizeVariable, sizeVariable, shown, enabled, 
	TextGridView {"TCellsView", kConstraintsMaxRows, kConstraintsMaxCols, kCellHeight, kCellWidth, kRowInset, kColumnInset, AdornRows, AdornCols, 
		multipleSelection, plain, kFontSize, { 0x0, 0x0, 0x0 }, "a" }, 

	'prnt', 'SCL2', { kCellHeight, 32 }, { kCellHeight, kConstraintsMaxCols*kCellWidth }, sizeVariable, sizeRelSuperView, shown, enabled, 
	Scroller {"TScroller", noVertScrollBar, noHorzScrollBar, kCellHeight, kCellHeight, kCellHeight, kCellHeight, noVertConstrain, 
		 noHorzConstrain, noInset }, 

	'SCL2', 'COLS', { 0, 0 }, { kCellHeight, kConstraintsMaxCols*kCellWidth }, sizeVariable, sizeVariable, shown, enabled, 
	TextGridView {"TColumnsView", 1, kConstraintsMaxCols, kColumnTitleHeight, kCellWidth, 0, kColumnInset, dontAdornRows, AdornCols, 
		multipleSelection, bold, kFontSize, { 0x0, 0x0, 0x0 }, "a" }, 

	'prnt', 'SCL3', { 2*kCellHeight, 0 }, { 221, kRowTitleWidth }, sizeRelSuperView, sizeVariable, shown, enabled, 
	Scroller {"TScroller", noVertScrollBar, noHorzScrollBar, kCellHeight, kCellWidth, 0, 0, noVertConstrain, 
		 noHorzConstrain, noInset }, 

	'SCL3', 'ROWS', { 0, 0 }, { 221, kRowTitleWidth }, sizeVariable, sizeVariable, shown, enabled, 
	TextGridView {"TRowsView", kConstraintsMaxRows, 1, kCellHeight, kRowTitleWidth, kRowInset, 0, AdornRows, dontAdornCols, 
		multipleSelection, bold, kFontSize, { 0x0, 0x0, 0x0 }, "a" }, 

	'WIND', 'ENTV', { 8, 8 }, { 20, kConstraintsSizeH - 24 }, sizeFixed, sizeFixed, shown, enabled, 
	TEView {"TEntryView", withoutStyle, crOnly, acceptChanges, dontFreeText, cTyping, 
		kMaxChars, {2, 2, 2, 2}, justLeft, plain, kFontSize, { 0x0, 0x0, 0x0 }, "a"}
	}
};

#endif qConstraints