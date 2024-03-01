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

resource 'view' (kStdResPlotWindowType,
#if qNames
"Std. Res. Plot",
#endif
purgeable) {
	{	/* array viewArray: 4 elements */
		/* [1] */
		root, 'wind',
		{	/* array: 1 elements */
			/* [1] */
			50, 40
		},
		{	/* array: 1 elements */
			/* [1] */
			288, 448
		}, sizeVariable, sizeVariable, shown, enabled,
		Window {
			"TPlotWindow",
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
			'plot',
			"Std. Residuals Plot Ò<<<>>>Ó"
		},
		
		
		/* [2] */
		'wind', 'prnt',
		{	/* array: 1 elements */
			/* [1] */
			0, 0
		},
		{	/* array: 1 elements */
			/* [1] */
			288, 448
		}, sizeRelSuperView, sizeRelSuperView, shown, disabled,
		View {
			"TStdResPlotPrintView"
		},
		
		

		'prnt', 'plot',
		{	/* array: 1 elements */
			/* [1] */
			16, 2
		},
		{	/* array: 1 elements */
			/* [1] */
			270, 446
		}, sizeRelSuperView, sizeRelSuperView, shown, disabled,
		View {
			"TStdResPlotView"
		},
		
				
		'prnt', 'info',
		{	/* array: 1 elements */
			/* [1] */
			0, 0
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 144
		}, sizeFixed, sizeFixed, shown, disabled,
		StaticText {
			"TPlotWindowInfoView",
			0b0,
			{1, 1},
			sizeable,
			notDimmed,
			notHilited,
			doesntDismiss,
			{0, 0, 0, 0},
			plain,
			0,
			{	/* array: 3 elements */
				/* [1] */
				0x0,
				/* [2] */
				0x0,
				/* [3] */
				0x0
			},
			"A",
			justCenter,
			""
		},
	
		'wind', 'scbr',
		{	/* array: 1 elements */
			/* [1] */
			-1, 144
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 304
		}, sizeFixed, sizeRelSuperView, shown, enabled,
		ScrollBar {
			"TPlotWindowScrollBar",
			0b0,
			{1, 1},
			sizeable,
			notDimmed,
			notHilited,
			doesntDismiss,
			{0, 0, 0, 0},
			plain,
			0,
			{	/* array: 3 elements */
				/* [1] */
				0x0,
				/* [2] */
				0x0,
				/* [3] */
				0x0
			},
			"",
			0,
			0,
			100
		}	

	}
};

