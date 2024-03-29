/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989 Matteo Vaccari & Mario Negri Institute
*/


#ifndef __ViewTypes__
#include "ViewTypes.r"
#endif

/* include my definitions */
#include "Declarations.r"


resource 'view' (kStdResPlotOptionsDlog,
#if qNames
"Std. Res. Plot Options",
#endif
purgeable) {
	{	/* array viewArray: 27 elements */
		/* [1] */
		root, 'wind',
		{	/* array: 1 elements */
			/* [1] */
			50, 40
		},
		{	/* array: 1 elements */
			/* [1] */
			296, 424
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
			'dlog',
			""
		},
		/* [2] */
		'wind', 'dlog',
		{	/* array: 1 elements */
			/* [1] */
			0, 0
		},
		{	/* array: 1 elements */
			/* [1] */
			296, 424
		}, sizeVariable, sizeVariable, shown, enabled,
		DialogView {
			"TStdResPlotOptionsDialogView",
			'ok  ',
			'cncl'
		},
		/* [3] */
		'dlog', 'titl',
		{	/* array: 1 elements */
			/* [1] */
			0, 8
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 408
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
			"Standard Residuals Plot Options"
		},
		/* [4] */
		'dlog', 'dccl',
		{	/* array: 1 elements */
			/* [1] */
			24, 8
		},
		{	/* array: 1 elements */
			/* [1] */
			88, 256
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
			"How To Compute Domain"
		},
		/* [5] */
		'dccl', 'auss',
		{	/* array: 1 elements */
			/* [1] */
			16, 16
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
		/* [6] */
		'dccl', 'auoa',
		{	/* array: 1 elements */
			/* [1] */
			40, 16
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
		/* [7] */
		'dccl', 'udef',
		{	/* array: 1 elements */
			/* [1] */
			64, 16
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
			"User Defined"
		},
		/* [8] */
		'dlog', 'pacl',
		{	/* array: 1 elements */
			/* [1] */
			24, 272
		},
		{	/* array: 1 elements */
			/* [1] */
			88, 144
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
			"Plot Against�"
		},
		/* [9] */
		'pacl', 'agax',
		{	/* array: 1 elements */
			/* [1] */
			16, 16
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
			"X"
		},
		/* [10] */
		'pacl', 'aoby',
		{	/* array: 1 elements */
			/* [1] */
			40, 16
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
			"Observed Y"
		},
		/* [11] */
		'pacl', 'acoy',
		{	/* array: 1 elements */
			/* [1] */
			64, 16
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
			"Computed Y"
		},
		/* [12] */
		'dlog', 'cncl',
		{	/* array: 1 elements */
			/* [1] */
			224, 224
		},
		{	/* array: 1 elements */
			/* [1] */
			16, 80
		}, sizeFixed, sizeFixed, shown, enabled,
		Button {
			"TButton",
			0b0,
			{1, 1},
			notSizeable,
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
		/* [13] */
		'dlog', 'ok  ',
		{	/* array: 1 elements */
			/* [1] */
			260, 220
		},
		{	/* array: 1 elements */
			/* [1] */
			24, 88
		}, sizeFixed, sizeFixed, shown, enabled,
		Button {
			"TButton",
			0b1000000,
			{3, 3},
			notSizeable,
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
		/* [14] */
		'dlog', 'docl',
		{	/* array: 1 elements */
			/* [1] */
			120, 8
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
		/* [15] */
		'docl', 'VW02',
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
		/* [16] */
		'docl', 'VW03',
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
		/* [17] */
		'docl', 'VW04',
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
		/* [18] */
		'docl', 'VW05',
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
		/* [19] */
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
		/* [20] */
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
		/* [21] */
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
		/* [22] */
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
		/* [23] */
		'dlog', 'aicl',
		{	/* array: 1 elements */
			/* [1] */
			208, 8
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
		/* [24] */
		'aicl', 'VW11',
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
		/* [25] */
		'aicl', 'VW12',
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
		/* [26] */
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
		/* [27] */
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
		}
	}
};

