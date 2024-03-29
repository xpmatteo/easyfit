/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989 Matteo Vaccari & Mario Negri Institute
*/

/* � Auto-Include the requirements for this source */
#ifndef __ViewTypes__
#include "ViewTypes.r"
#endif

/* include my definitions */
#include "Declarations.r"

#define qUnused 0

#define kScBarSize 16

#define kVWindSize 288
#define kHWindSize 447 
#define kHStatusBarSize 120


resource 'view' (kMultiTEWindowType, 
#if qNames
"MultiTE",
#endif
purgeable) {
	{	root, 'wind',
		{	40, 10 },
		{	kVWindSize, kHWindSize }, 
		sizeVariable, sizeVariable, notShown, enabled,
		Window {
			"TWindow",
			zoomDocProc,
			goAwayBox,
			resizable,
			modeless,
			ignoreFirstClick,
			dontFreeOnClosing,
			disposeOnFree,
			doesntCloseDocument,
			dontOpenWithDocument,
			dontAdaptToScreen,
			dontStagger,
			dontForceOnScreen,
			dontCenter,
			'TEVW',
			"Messages �<<<>>>�"
		},
		
		/* The Scroller */
		'wind', 'scrl',
		{	0, 0 },
		{	kVWindSize - kSBarSizeMinus1, kHWindSize - kSBarSizeMinus1 }, 
		sizeRelSuperView, sizeRelSuperView, shown, enabled,
		Scroller {
			"TScroller",
			VertScrollBar,
			HorzScrollBar,
			256,
			256,
			16,
			16,
			noVertConstrain,
			noHorzConstrain,
			{0, 0, 0, 0}
		},
		
		/* The TEView: TEVW */
		'scrl', 'TEVW', {	0, 0 }, {	kVWindSize - kSBarSizeMinus1, 1020 }, 
		sizeVariable, sizeFixed, shown, enabled,
		TEView {"TMultiTEView", withoutStyle, crOnly, dontAcceptChanges, freeText, cTyping,
			unlimited, {4, 4, 4, 4}, justLeft, plain, 12, { 0x0, 0x0, 0x0 }, "Monaco" },

#if qUnused
		/* The subject selector: SBSL */
		'wind', 'SBSL',
		{	kVWindSize - kSBarSizeMinus1, kHStatusBarSize }, 
		{	kScBarSize, kHWindSize - kHStatusBarSize }, 
		sizeFixed, sizeRelSuperView, shown, enabled,
		ScrollBar {
			"TScrollBar",
			0b0,
			{1, 1},
			sizeable,
			notDimmed,
			notHilited,
			doesntDismiss,
			{0, 0, 0, 0},
			plain,
			0,
			{	0x0, 0x0, 0x0 },
			"",
			1,
			1,
			1
		},
		
		/* Status Area: STTS */
		'wind', 'STTS',
		{	kVWindSize - kSBarSizeMinus1, 0 },
		{	kScBarSize, kHStatusBarSize }, 
		sizeFixed, sizeRelSuperView, shown, disabled,
		View {
			"TView"
		}
#endif qUnused		

	}
};
