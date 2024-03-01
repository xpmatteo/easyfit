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


resource 'view' (kSaveTextDlog,
#if qNames
"SaveTextDialog",
#endif
purgeable) {
	{	/* array viewArray: 5 elements */
		/* [1] */
		root, 'wind',
		{	/* array: 1 elements */
			/* [1] */
			50, 40
		},
		{	/* array: 1 elements */
			/* [1] */
			112, 368
		}, sizeVariable, sizeVariable, shown, enabled,
		Window {
			"TWindow",
			dBoxProc,
			noGoAwayBox,
			notResizable,
			modal,
			ignoreFirstClick,
			freeOnClosing,
			disposeOnFree,
			closesDocument,
			openWithDocument,
			dontAdaptToScreen,
			dontStagger,
			dontForceOnScreen,
			center,
			'ok  ',
			"<<<>>>"
		},
		/* [2] */
		'wind', 'dlog',
		{	/* array: 1 elements */
			/* [1] */
			0, 0
		},
		{	/* array: 1 elements */
			/* [1] */
			112, 368
		}, sizeVariable, sizeVariable, shown, enabled,
		DialogView {
			"TDialogView",
			'ok  ',
			'cncl'
		},
		/* [3] */
		'dlog', 'text',
		{	/* array: 1 elements */
			/* [1] */
			16, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			48, 336
		}, sizeFixed, sizeFixed, shown, disabled,
		StaticText {
			"TStaticText",
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
			justLeft,
			"The text in the messages window has reac"
			"hed its maximum size. Do you want to sav"
			"e it?"
		},
		/* [4] */
		'dlog', 'ok  ',
		{	/* array: 1 elements */
			/* [1] */
			76, 32
		},
		{	/* array: 1 elements */
			/* [1] */
			24, 86
		}, sizeFixed, sizeFixed, shown, enabled,
		Button {
			"TButton",
			0b1000000,
			{3, 3},
			sizeable,
			notDimmed,
			notHilited,
			dismisses,
			{4, 4, 4, 4},
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
			"Save it"
		},
		/* [5] */
		'dlog', 'cncl',
		{	/* array: 1 elements */
			/* [1] */
			80, 144
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 80
		}, sizeFixed, sizeFixed, shown, enabled,
		Button {
			"TButton",
			0b0,
			{1, 1},
			sizeable,
			notDimmed,
			notHilited,
			dismisses,
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
			"Erase it"
		}
	}
};

