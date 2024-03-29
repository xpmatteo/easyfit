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

resource 'view' (kDataAndFuncPlotOptionsDlog,
#if qNames
"Data & Func Plot Options",
#endif
purgeable) {
	{	/* array viewArray: 25 elements */
		/* [1] */
		root, 'wind',
		{	/* array: 1 elements */
			/* [1] */
			50, 40
		},
		{	/* array: 1 elements */
			/* [1] */
			296, 368
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
			doesntCloseDocument,
			openWithDocument,
			dontAdaptToScreen,
			dontStagger,
			dontForceOnScreen,
			center,
			'slog',
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
			296, 368
		}, sizeSuperView, sizeSuperView, shown, enabled,
		DialogView {
			"TDataAndFuncPlotOptionsDialogView",
			'ok  ',
			'cncl'
		},
		/* [3] */
		'dlog', 'dccl',
		{	/* array: 1 elements */
			/* [1] */
			24, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			88, 248
		}, sizeFixed, sizeFixed, shown, disabled,
		Cluster {
			"TCluster",
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
			"How to Compute Domain"
		},
		/* [4] */
		'dccl', 'auss',
		{	/* array: 1 elements */
			/* [1] */
			20, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 224
		}, sizeFixed, sizeFixed, shown, enabled,
		Radio {
			"TRadio",
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
			off,
			"Automatic (Subject by Subject)"
		},
		/* [5] */
		'dccl', 'auoa',
		{	/* array: 1 elements */
			/* [1] */
			44, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 224
		}, sizeFixed, sizeFixed, shown, enabled,
		Radio {
			"TRadio",
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
			off,
			"Automatic (over All Subjects)"
		},
		/* [6] */
		'dccl', 'udef',
		{	/* array: 1 elements */
			/* [1] */
			68, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 112
		}, sizeFixed, sizeFixed, shown, enabled,
		Radio {
			"TRadio",
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
			off,
			"User Defined"
		},
		/* [7] */
		'dlog', 'docl',
		{	/* array: 1 elements */
			/* [1] */
			120, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			80, 336
		}, sizeFixed, sizeFixed, shown, disabled,
		Cluster {
			"TCluster",
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
			"Domain"
		},
		/* [8] */
		'docl', 'VW09',
		{	/* array: 1 elements */
			/* [1] */
			20, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 48
		}, sizeFixed, sizeFixed, shown, disabled,
		StaticText {
			"TStaticText",
			0b0,
			{1, 1},
			notSizeable,
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
			justCenter,
			"X Min:"
		},
		/* [9] */
		'docl', 'VW10',
		{	/* array: 1 elements */
			/* [1] */
			52, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 48
		}, sizeFixed, sizeFixed, shown, disabled,
		StaticText {
			"TStaticText",
			0b0,
			{1, 1},
			notSizeable,
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
			justCenter,
			"Y Min:"
		},
		/* [10] */
		'docl', 'VW12',
		{	/* array: 1 elements */
			/* [1] */
			20, 176
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 48
		}, sizeFixed, sizeFixed, shown, disabled,
		StaticText {
			"TStaticText",
			0b0,
			{1, 1},
			notSizeable,
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
			justCenter,
			"X Max:"
		},
		/* [11] */
		'docl', 'VW13',
		{	/* array: 1 elements */
			/* [1] */
			52, 176
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 48
		}, sizeFixed, sizeFixed, shown, disabled,
		StaticText {
			"TStaticText",
			0b0,
			{1, 1},
			notSizeable,
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
			justCenter,
			"Y Max:"
		},
		/* [12] */
		'docl', 'xmin',
		{	/* array: 1 elements */
			/* [1] */
			18, 64
		},
		{	/* array: 1 elements */
			/* [1] */
			20, 96
		}, sizeFixed, sizeFixed, shown, enabled,
		EditText {
			"TRealText",
			0b1111,
			{1, 1},
			notSizeable,
			notDimmed,
			notHilited,
			doesntDismiss,
			{2, 2, 2, 2},
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
			"",
			unlimited,
			0b11110000000000000000000100000000
		},
		/* [13] */
		'docl', 'xmax',
		{	/* array: 1 elements */
			/* [1] */
			18, 224
		},
		{	/* array: 1 elements */
			/* [1] */
			20, 96
		}, sizeFixed, sizeFixed, shown, enabled,
		EditText {
			"TRealText",
			0b1111,
			{1, 1},
			notSizeable,
			notDimmed,
			notHilited,
			doesntDismiss,
			{2, 2, 2, 2},
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
			"",
			unlimited,
			0b11110000000000000000000100000000
		},
		/* [14] */
		'docl', 'ymin',
		{	/* array: 1 elements */
			/* [1] */
			50, 64
		},
		{	/* array: 1 elements */
			/* [1] */
			20, 96
		}, sizeFixed, sizeFixed, shown, enabled,
		EditText {
			"TRealText",
			0b1111,
			{1, 1},
			notSizeable,
			notDimmed,
			notHilited,
			doesntDismiss,
			{2, 2, 2, 2},
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
			"",
			unlimited,
			0b11110000000000000000000100000000
		},
		/* [15] */
		'docl', 'ymax',
		{	/* array: 1 elements */
			/* [1] */
			50, 224
		},
		{	/* array: 1 elements */
			/* [1] */
			20, 96
		}, sizeFixed, sizeFixed, shown, enabled,
		EditText {
			"TRealText",
			0b1111,
			{1, 1},
			notSizeable,
			notDimmed,
			notHilited,
			doesntDismiss,
			{2, 2, 2, 2},
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
			"",
			unlimited,
			0b11110000000000000000000100000000
		},
		/* [16] */
		'dlog', 'aicl',
		{	/* array: 1 elements */
			/* [1] */
			208, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			80, 176
		}, sizeFixed, sizeFixed, shown, disabled,
		Cluster {
			"TCluster",
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
			"Number of Ticks"
		},
		/* [17] */
		'aicl', 'VW19',
		{	/* array: 1 elements */
			/* [1] */
			20, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 80
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
			justCenter,
			"X Axis:"
		},
		/* [18] */
		'aicl', 'VW20',
		{	/* array: 1 elements */
			/* [1] */
			52, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 80
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
			justCenter,
			"Y Axis:"
		},
		/* [19] */
		'aicl', 'xint',
		{	/* array: 1 elements */
			/* [1] */
			18, 96
		},
		{	/* array: 1 elements */
			/* [1] */
			20, 64
		}, sizeFixed, sizeFixed, shown, enabled,
		NumberText {
			"TNumberText",
			0b1111,
			{1, 1},
			sizeable,
			notDimmed,
			notHilited,
			doesntDismiss,
			{2, 2, 2, 2},
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
			"10",
			unlimited,
			0b11110000000000000000000100000000,
			10,
			1,
			100
		},
		/* [20] */
		'aicl', 'yint',
		{	/* array: 1 elements */
			/* [1] */
			50, 96
		},
		{	/* array: 1 elements */
			/* [1] */
			20, 64
		}, sizeFixed, sizeFixed, shown, enabled,
		NumberText {
			"TNumberText",
			0b1111,
			{1, 1},
			sizeable,
			notDimmed,
			notHilited,
			doesntDismiss,
			{2, 2, 2, 2},
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
			"10",
			unlimited,
			0b11110000000000000000000100000000,
			10,
			1,
			100
		},
		/* [21] */
		'dlog', 'cncl',
		{	/* array: 1 elements */
			/* [1] */
			224, 208
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
			"Cancel"
		},
		/* [22] */
		'dlog', 'ok  ',
		{	/* array: 1 elements */
			/* [1] */
			258, 204
		},
		{	/* array: 1 elements */
			/* [1] */
			24, 88
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
			"OK"
		},
		/* [23] */
		'dlog', 'titl',
		{	/* array: 1 elements */
			/* [1] */
			0, 16
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 336
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
			justCenter,
			"Data & Model Plot Options"
		},
		/* [24] */
		'dlog', 'slog',
		{	/* array: 1 elements */
			/* [1] */
			32, 272
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 80
		}, sizeFixed, sizeFixed, shown, enabled,
		CheckBox {
			"TCheckBox",
			0b0,
			{1, 1},
			notSizeable,
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
			off,
			"Semilog"
		},
		/* [25] */
		'dlog', 'fast',
		{	/* array: 1 elements */
			/* [1] */
			64, 272
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 80
		}, sizeFixed, sizeFixed, shown, enabled,
		CheckBox {
			"TCheckBox",
			0b0,
			{1, 1},
			sizeable,
			notDimmed,
			notHilited,
			doesntDismiss,
			{0, 0, 0, 0},
			32,
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
			on,
			"plot fast"
		}
	}
};

