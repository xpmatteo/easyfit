/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute. 
  All rights reserved.
	Portions Copyright � 1985 - 1990 by Apple Computer, Inc.  All rights reserved.

	---------------
	EasyFit.r - EasyFit's resources	
*/

/* � Auto-Include the requirements for this source */
#ifndef __TYPES.R__
#include "Types.r"
#endif

#ifndef __SYSTYPES.R__
#include "SysTypes.r"
#endif

#ifndef __MacAppTypes__
#include "MacAppTypes.r"
#endif

#ifndef __ViewTypes__
#include "ViewTypes.r"
#endif

/* include my definitions */
#include "Declarations.r"

#if qDebug
include "Debug.rsrc";
#endif

include "MacApp.rsrc";
include "Printing.rsrc";
include "Dialog.rsrc";

/* include the code from the application */
include $$Shell("ObjApp")kAppName 'CODE';

/* Include the separately compiled resources */
include $$Shell("ObjApp")"Picts.rsrc";
include $$Shell("ObjApp")"GrabberTracker.rsrc";
include $$Shell("ObjApp")"MultiTE.rsrc";
include $$Shell("ObjApp")"Working.rsrc";
include $$Shell("ObjApp")"Compint.rsrc";
include $$Shell("ObjApp")"DataAndFuncPlot.rsrc";
include $$Shell("ObjApp")"StdResPlot.rsrc";
include $$Shell("ObjApp")"DataAndFuncPlotOptions.rsrc";
include $$Shell("ObjApp")"AboutMarioNegri.rsrc";
include $$Shell("ObjApp")"AboutApp.rsrc";
include $$Shell("ObjApp")"SaveTextDlog.rsrc";
include $$Shell("ObjApp")"UserDefinedModelDlog.rsrc";
include $$Shell("ObjApp")"StdResPlotOptionsDlog.rsrc";
include $$Shell("ObjApp")"FitOptionsDlog.rsrc";
include $$Shell("ObjApp")"ExpDataWindow.rsrc";
include $$Shell("ObjApp")"ParamsWindow.rsrc";
include $$Shell("ObjApp")"DosesWindow.rsrc";
#if qConstraints
include $$Shell("ObjApp")"ConstraintsWindow.rsrc";
#endif
include $$Shell("ObjApp")"StdResWindow.rsrc";
include $$Shell("ObjApp")"WeightsWindow.rsrc";
include $$Shell("ObjApp")"MathChicago.rsrc";
include $$Shell("ObjApp")"Monaco12.rsrc";
include $$Shell("ObjApp")"AboutAppText.rsrc";

resource 'SIZE' (-1) {
	saveScreen,
	acceptSuspendResumeEvents,
	enableOptionSwitch,
	canBackground,
	MultiFinderAware,
	backgroundAndForeground,
	dontGetFrontClicks,
	ignoreChildDiedEvents,
	is32BitCompatible,
	reserved,
	reserved,
	reserved,
	reserved,
	reserved,
	reserved,
	reserved,
	(1024 + 512) * 1024,
	700 * 1024
};

/*--------------------------------------------------------------------------------
 Include here Memory usage info for MacApp�
--------------------------------------------------------------------------------*/

resource 'seg!' (256,
#if qNames
kAppName,
#endif
	purgeable) {
	{	"GTerminate";
		"GNonRes";
		"GOpen";
		"GWriteFile";
		"GFile";
		"GClose";
		"GClipboard";
		"GDoCommand";
		"GSelCommand";
		"ARes"
		"Fit"		/* the only "home made" segment.  Maybe we should not list it here,
							 together with GDoCommand, since they should never be both in memory */
	}
};

/* -------------------------------- ALRTs ---------------------------------------- */

resource 'ALRT' (phPlainAlert,
#if qNames
"phPlainAlert",
#endif
purgeable) {
	{90, 110, 238, 402},
	phPlainAlert,
	{	/* array: 4 elements */
		OK, visible, silent;
		OK, visible, silent;
		OK, visible, silent;
		OK, visible, silent
	}
};

/* -------------------------------- DITLs ---------------------------------------- */

resource 'DITL' (phPlainAlert,
#if qNames
"phPlainAlert",
#endif
purgeable) {
	{	/* array DITLarray: 3 elements */
		/* [1] */
		{120, 198, 138, 272},
		Button {
			enabled,
			"OK"
		},
		/* [2] */
		{10, 70, 115, 272},
		StaticText {
			disabled,
			"^0"
		},
		/* [3] */
		{10, 20, 42, 52},
		Icon {
			disabled,
			0
		}
	}
};

/* -------------------------------- MENUs ---------------------------------------- */

resource 'cmnu' (mApple,
#if qNames
"mApple",
#endif
nonpurgeable) {
	mApple,
	textMenuProc,
	0x7FFFFFFB,
	enabled,
	apple,
	{
	"About EasyFit�", noIcon, noKey, noMark, plain, cAboutApp;
	"About Mario Negri�", noIcon, noKey, noMark, plain, cAboutIRFMN;
	"-",		 noIcon, noKey, noMark, plain, nocommand
	}
};

resource 'cmnu' (mFile,
#if qNames
"mFile",
#endif
nonpurgeable) {
	mFile,
	textMenuProc,
	allEnabled,
	enabled,
	"File",
	{
	"New",				noIcon, "N",	noMark, plain, cNew;
	"Open�",			noIcon, "O",	noMark, plain, cOpen;
	"-",				noIcon, noKey,	noMark, plain, nocommand;
	"Close",			noIcon, "W",	noMark, plain, cClose;
	"Save",				noIcon, "S",	noMark, plain, cSave;
	"Save As�",			noIcon, noKey,	noMark, plain, cSaveAs;
	"Save a Copy In�",	noIcon, noKey,	noMark, plain, cSaveCopy;
	"Revert",			noIcon, noKey,	noMark, plain, cRevert;
	"-",				noIcon, noKey,	noMark, plain, nocommand;
	"Page Setup�",		noIcon, noKey,	noMark, plain, cPageSetup;
	"Print All Plots�",			noIcon, noKey,	noMark, plain, cPrintAll;
	"Print Window�",			noIcon, "P",	noMark, plain, cPrint;
	"-",				noIcon, noKey,	noMark, plain, nocommand;
	"Quit",				noIcon, "Q",	noMark, plain, cQuit
	}
};

resource 'cmnu' (mEdit,
#if qNames
"mEdit",
#endif
nonpurgeable) {
	mEdit,
	textMenuProc,
	allEnabled,
	enabled,
	"Edit",
	{
	"Undo",						noIcon, "Z",	noMark, plain, cUndo;
	"-",							noIcon, noKey,	noMark, plain, nocommand;
	"Cut",						noIcon, "X",	noMark, plain, cCut;
	"Copy",						noIcon, "C",	noMark, plain, cCopy;
	"Paste",					noIcon, "V",	noMark, plain, cPaste;
	"Clear",					noIcon, noKey,	noMark, plain, cClear;
	"-",							noIcon, noKey,	noMark, plain, nocommand;
	"Select All",			noIcon, "A",	noMark, plain, cSelectAll;
	"Show Clipboard",	noIcon, noKey,	noMark, plain, cShowClipboard
	}
};

resource 'cmnu' (mFit,
#if qNames
"mFit",
#endif
nonpurgeable) {
	mFit,
	textMenuProc,
	allEnabled,
	enabled,
	"Fit",
	{
		"Clear Messages", noIcon, noKey,	noMark, plain, cClearMessages;
		"Data & Model Plot Options�", noIcon, "D", noMark, plain, cDataAndFuncPlotOptions;
		"Standard Residuals Plot Options�", noIcon, "R", noMark, plain, cStdResPlotOptions;
		"Fit Options�", noIcon, noKey, noMark, plain, cFitOptions;
/* 	"Peel", noIcon, noKey, noMark, plain, cPeel;		*/
		"Fit", noIcon, "F", noMark, plain, cFit
	}
};

resource 'cmnu' (mModel,
#if qNames
"mModel",
#endif
nonpurgeable) {
	mModel,
	textMenuProc,
	allEnabled,
	enabled,
	"Model",
	{
		"y = p� exp(-p� x)", noIcon, noKey, noMark, plain, cSingleExp;
		"y = p� exp(-p� x) + p� exp(-p� x)", noIcon, noKey, noMark, plain, cTwoExpPlus;
		"y = - p� exp(-p� x) + p� exp(-p� x)", noIcon, noKey, noMark, plain, cTwoExpMinus;
		"y = p� exp(-p� x) + p� exp(-p� x) + p� exp(-p� x)", noIcon, noKey, noMark, plain, cThreeExpPlus;
		"y = - p� exp(-p� x) + p� exp(-p� x) + p� exp(-p� x)", noIcon, noKey, noMark, plain, cThreeExpMinus;
		"User Defined�", noIcon, "U", noMark, italic, cUserDefined;
	}
};

resource 'cmnu' (mWeights,
#if qNames
"mWeights",
#endif
nonpurgeable) {
	mWeights,
	textMenuProc,
	allEnabled,
	enabled,
	"Weights",
	{
		"No Weights", noIcon, noKey, noMark, plain, cNoWeights;
		"WLS w� = 1/y� (Observed Value)", noIcon, noKey, noMark, plain, cOneOverObsValue;
		"WLS w� = 1/y�� (Observed Value)", noIcon, noKey, noMark, plain, cOneOverSqObsValue;
		"IRLS w� = 1/y(x�) (Estimated Value)", noIcon, noKey, noMark, plain, cOneOverEstimatedValue;
		"IRLS w� = 1/y(x�)� (Estimated Value)", noIcon, noKey, noMark, plain, cOneOverSqEstimatedValue;
		/* "ELS w� = a/y(x�)b", noIcon, noKey, noMark, plain, cELSWeights; */
		"Input by Hand", noIcon, noKey, noMark, plain, cInputByHand;
	}
};


resource 'cmnu' (mWindows,
#if qNames
"mWindows",
#endif
nonpurgeable) {
	mWindows,
	textMenuProc,
	allEnabled,
	enabled,
	"Windows",
	{	
		"Data", 										noIcon, noKey, noMark, plain, cDataWindow;
		"Parameters", 							noIcon, noKey, noMark, plain, cParamsWindow;
		"Weights", 									noIcon, noKey, noMark, plain, cWeightsWindow;
		"Doses", 										noIcon, noKey, noMark, plain, cDosesWindow;
#if qConstraints
		"Constraints",							noIcon, noKey, noMark, plain, cConstraintsWindow;
#endif
		"Messages", 								noIcon, noKey, noMark, plain, cMsgsWindow;
		"Standard Residuals", 			noIcon, noKey, noMark, plain, cStdResWindow;
		"Data & Model Plot", 				noIcon, noKey, noMark, plain, cDataAndFuncPlotWindow;
		"Standard Residuals Plot",	noIcon, noKey, noMark, plain, cStdResWindowPlotWindow
	}
};

resource 'cmnu' (mFormat,
#if qNames
"mFormat",
#endif
nonpurgeable) {
	mFormat,
	textMenuProc,
	0x7FFFFFFF,
	enabled,
	"Format",
	 {
/* [1] */	"General",				noIcon, noKey, noMark, plain, cGeneral;
/* [2] */	"Decimal",				noIcon, noKey, noMark, plain, cDecimal;
/* [3] */	"Exponential",		noIcon, noKey, noMark, plain, cScientific;
/* [4] */	"-",							noIcon, noKey, noMark, plain, nocommand;
/* [5] */	"Left Justify",		noIcon, noKey, noMark, plain, cLeftJustify;
/* [6] */	"Center",					noIcon, noKey, noMark, plain, cCenter;
/* [7] */	"Right Justify",	noIcon, noKey, noMark, plain, cRightJustify;
/* [8] */	"-",							noIcon, noKey, noMark, plain, nocommand;
/* [9] */	"No Digits",			noIcon, noKey, noMark, plain, cNoDigits;
					"1 Digit",				noIcon, noKey, noMark, plain, c1Digit;
					"2 Digits",				noIcon, noKey, noMark, plain, c2Digits;
					"3 Digits",				noIcon, noKey, noMark, plain, c3Digits;
					"4 Digits",				noIcon, noKey, noMark, plain, c4Digits;
					"5 Digits",				noIcon, noKey, noMark, plain, c5Digits;
					"6 Digits",				noIcon, noKey, noMark, plain, c6Digits;
					"7 Digits",				noIcon, noKey, noMark, plain, c7Digits;
					"8 Digits",				noIcon, noKey, noMark, plain, c8Digits;
					"9 Digits",				noIcon, noKey, noMark, plain, c9Digits;
					"10 Digits",			noIcon, noKey, noMark, plain, c10Digits;
					"11 Digits",			noIcon, noKey, noMark, plain, c11Digits;
					"12 Digits",			noIcon, noKey, noMark, plain, c12Digits
  }
};


resource 'cmnu' (mBuzzwords) {
	mBuzzwords,
	textMenuProc,
	allEnabled,
	enabled,
	"Buzzwords",
	 {	/* array: 13 elements */
		"Page Setup Change",	noIcon,		noKey,	noMark, plain, cChangePrinterStyle;
		"Typing",							noIcon,		noKey,	noMark,	plain, cTyping;
		"Selection",					noIcon,		noKey,	noMark, plain, cSelection;
		"Column Resize",			noIcon,		noKey,	noMark, plain, cSizeColumn;
		"Cut Text",						noIcon,		"X",		noMark, plain, cCutText;
		"Copy Text",					noIcon,		"C",		noMark, plain, cCopyText;
		"Clear Text",					noIcon,		noKey,	noMark, plain, cClearText;
		"Cut Cells",					noIcon,		"X",		noMark, plain, cCutCells;
		"Copy Cells",					noIcon,		"C",		noMark, plain, cCopyCells;
		"Clear Cells",				noIcon,		noKey,	noMark, plain, cClearCells;
		"Cut",								noIcon,		"X",		noMark, plain, cStandardCut;
		"Copy",								noIcon,		"C",		noMark, plain, cStandardCopy;
		"Clear",							noIcon,		noKey,	noMark, plain, cStandardClear;
		"Fit Selection",			noIcon,		"F",		noMark, plain, cFitSelection
	}
};


resource 'MBAR' (kMBarDisplayed,
#if qNames
"kMBarDisplayed",
#endif
nonpurgeable) {
	{mApple; mFile; mEdit; mFormat; mFit; mModel; mWeights; mWindows}
};

/* the application icon */
resource 'ICN#' (128, 
#if qNames
"Application",
#endif
purgeable) {
	{	/* array: 2 elements */
		/* [1] */
		$"10 00 00 00 10 40 00 00 38 E0 00 00 7C 4E 10 00"
		$"10 11 38 00 10 20 90 00 10 00 80 00 13 FF 40 00"
		$"11 01 40 00 10 81 40 00 10 81 40 00 10 81 22 00"
		$"10 8F 27 00 10 81 22 00 10 87 20 00 10 81 10 00"
		$"10 87 10 00 10 81 10 00 10 87 08 00 10 81 08 00"
		$"10 8F 04 10 10 81 02 38 10 87 02 10 10 81 09 80"
		$"10 87 1C 60 10 81 08 08 10 87 00 0C 1E 81 7F FF"
		$"00 81 00 0C 00 42 00 08 00 3C",
		/* [2] */
		$"1F FF FF E0 3F FF FF F0 7F FF FF F8 FF FF FF FC"
		$"FF FF FF FC 3F FF FF FC 3F FF FF FC 3F FF FF FC"
		$"3F FF FF FC 3F FF FF FC 3F FF FF FC 3F FF FF FC"
		$"3F FF FF FC 3F FF FF FC 3F FF FF FC 3F FF FF FC"
		$"3F FF FF FC 3F FF FF FC 3F FF FF FC 3F FF FF FC"
		$"3F FF FF FC 3F FF FF FC 3F FF FF FC 3F FF FF FC"
		$"3F FF FF FC 3F FF FF FC 3F FF FF FF 3F FF FF FF"
		$"3F FF FF FF 01 FF 00 1C 00 FE 00 18 00 7C"
	}
};

/* the document icon */
resource 'ICN#' (129,
#if qNames
"Document", 
#endif
purgeable) {
	{	/* array: 2 elements */
		/* [1] */
		$"0F FF FE 00 08 40 03 00 08 E0 02 80 08 4E 12 40"
		$"08 11 3A 20 08 20 92 10 08 00 83 F8 0B FF 40 08"
		$"09 01 40 08 08 81 40 08 08 81 40 08 08 81 22 08"
		$"08 81 27 08 08 8F 22 08 08 81 20 08 08 87 10 08"
		$"08 81 10 08 08 87 10 08 08 81 08 08 08 87 08 08"
		$"08 81 04 18 08 8F 02 38 08 81 02 18 08 87 09 88"
		$"08 81 1C 68 08 87 08 08 08 81 00 08 08 87 00 08"
		$"08 81 00 08 08 42 00 08 08 3C 00 08 0F FF FF F8",
		/* [2] */
		$"0F FF FE 00 0F FF FF 00 0F FF FF 80 0F FF FF C0"
		$"0F FF FF E0 0F FF FF F0 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
	}
};

/* The External Models files icon */

resource 'ICN#' (130,
#if qNames
"XMDL icon", 
#endif
purgeable) {
	{	/* array: 2 elements */
		/* [1] */
		$"1FFF FC00 1080 0600 11C0 0500 109C 2480"
		$"1022 7440 1041 2420 1001 07F0 17FE 8010"
		$"1202 8010 7FFF FFF8 4000 000C 5FF0 000C"
		$"4C30 000C 4C10 008C 4C00 018C 4C27 BBCC"
		$"4FE3 118C 4C21 A18C 4C00 C18C 4C00 C18C"
		$"4C11 618C 4C32 31AC 5FF7 78CC 4000 000C"
		$"7FFF FFFC 3FFF FFFC 1102 0010 110E 0010"
		$"1102 0010 1084 0010 1078 0010 1FFF FFF0",
		/* [2] */
		$"1FFF FC00 1FFF FE00 1FFF FF00 1FFF FF80"
		$"1FFF FFC0 1FFF FFE0 1FFF FFF0 1FFF FFF0"
		$"1FFF FFF0 7FFF FFF8 7FFF FFFC 7FFF FFFC"
		$"7FFF FFFC 7FFF FFFC 7FFF FFFC 7FFF FFFC"
		$"7FFF FFFC 7FFF FFFC 7FFF FFFC 7FFF FFFC"
		$"7FFF FFFC 7FFF FFFC 7FFF FFFC 7FFF FFFC"
		$"7FFF FFFC 3FFF FFFC 1FFF FFF0 1FFF FFF0"
		$"1FFF FFF0 1FFF FFF0 1FFF FFF0 1FFF FFF0"
	}
};


/* a small version of the application's icon. Do not make purgeable!!! it
	could break the notification manager. */
data 'SICN' (1000) {
	$"40 00 E6 20 49 80 5F 80 49 50 49 40 4B 40 49 48"
	$"4B 20 49 22 4B 10 49 48 4B 02 79 FF 09 02 06 00"
};


/* FREFs and Bundles */

resource 'FREF' (128,
#if qNames
"Application",
#endif
	purgeable) {
	'APPL',
	0,
	""
};

resource 'FREF' (129,
#if qNames
"Document",
#endif
	purgeable) {
	kFileType,
	1,
	""
};

resource 'FREF' (130,
#if qNames
"XMDL",
#endif
	purgeable) {
	'XMDL',
	2,
	""
};

resource 'BNDL' (128,
#if qNames
"Eas",
#endif
	purgeable) {
	kSignature,
	0,
	{	/* array TypeArray: 2 elements */
		/* [1] */
		'FREF',
		{	/* array IDArray: 3 elements */
			/* [1] */
			0, 128,
			/* [2] */
			1, 129,
			/* [3] */
			2, 130
		},
		/* [2] */
		'ICN#',
		{	/* array IDArray: 3 elements */
			/* [1] */
			0, 128,
			/* [2] */
			1, 129,
			/* [3] */
			2, 130
		}
	}
};

type kSignature as 'STR ';
resource kSignature (0,
#if qNames
"Signature",
#endif
	purgeable) {
	kVersion " - � 1989-1991 Matteo Vaccari & Mario Negri Institute."
};

resource 'DLOG' (phSplash,
#if qNames
"Splash screen",
#endif
purgeable) {
	{40, 40, 224, 486},
	altDBoxProc,
	visible,
	noGoAway,
	0x0,
	phSplash,
	""
};



resource 'DITL' (phSplash,
#if qNames
"Splash screen",
#endif
purgeable) {
	{{10, 8, 170, 438},
		Picture {
			enabled,
			kSplashPict
		}
	}
};

resource 'ALRT' (phWeNeedFPUAndSystem6,
#if qNames
"phWeNeedFPUAndSystem6",
#endif
purgeable) {
	{90, 110, 238, 454},
	2030,
	{	/* array: 4 elements */
		/* [1] */
		OK, visible, silent,
		/* [2] */
		OK, visible, silent,
		/* [3] */
		OK, visible, silent,
		/* [4] */
		OK, visible, silent
	}
};

resource 'DITL' (phWeNeedFPUAndSystem6,
#if qNames
"phWeNeedFPUAndSystem6",
#endif
purgeable) {
	{	/* array DITLarray: 3 elements */
		/* [1] */
		{120, 258, 138, 332},
		Button {
			enabled,
			"OK"
		},
		/* [2] */
		{10, 70, 116, 331},
		StaticText {
			disabled,
			"This version of EasyFit needs a Macintos"
			"h with a Floating Point Unit, and System"
			" Software version 6.0 or higher. In the "
			"EasyFit distribution disk you will find "
			"a version of EasyFit that runs without F"
			"loating Point Unit."
		},
		/* [3] */
		{10, 20, 42, 52},
		Icon {
			disabled,
			0
		}
	}
};

resource 'ALRT' (phWeNeedSystem6,
#if qNames
"phWeNeedSystem6",
#endif
purgeable) {
	{90, 110, 238, 402},
	phWeNeedSystem6,
	{	/* array: 4 elements */
		/* [1] */
		OK, visible, silent,
		/* [2] */
		OK, visible, silent,
		/* [3] */
		OK, visible, silent,
		/* [4] */
		OK, visible, silent
	}
};

resource 'DITL' (phWeNeedSystem6,
#if qNames
"phWeNeedSystem6",
#endif
purgeable) {
	{	/* array DITLarray: 3 elements */
		/* [1] */
		{120, 198, 138, 272},
		Button {
			enabled,
			"OK"
		},
		/* [2] */
		{10, 70, 115, 272},
		StaticText {
			disabled,
			"EasyFit needs System Software version 6.0 or higher."
		},
		/* [3] */
		{10, 20, 42, 52},
		Icon {
			disabled,
			0
		}
	}
};


resource 'STR#' (kGenericMsgs, 
#if qNames
"Generic Error Msgs",
#endif
purgeable) {
	{	
		/* 1 */
		"Sorry, but there are not enough observations for this subject.  "
		"You must input at least as many observations as the number of "
		"parameters in the model.",

		/* 2 */
		"The initial estimate of the parameters is not accurate enough.",

		/* 3 */
		"You must input an initial estimate for all of the parameters of each subject.",

		/* 4 */
		"I'm sorry, but the peeling failed on this subject.  "
		"You'll have to figure out an estimate for the parameters by yourself.",

		/* 5 */
		"Couldn't compute weights for this subject.",
		
		/* 6 */
		"There is not enough memory for fitting.",

		/* 7 */
		"The value of the model is Not a Number.",

#if qConstraints
		/* 8 */
		"The initial estimate of the parameters is out of the constraints.",
		/* 9 */
		"Can't satisfy constraints.",
#else
		/* 8 + 9 */
		"", "",
#endif
		/* 10 */
		"You didn't specify an initial estimate for the parameters. "
		"I can't use the peeling procedure since the model we are "
		"using is user defined.",
		/* 11 */
		"Too many iterations.",
		/* 12 */
		"it is damaged",
		/* [13] */  
		"out of stack space while evaluating the user defined model",
		/* [14] */	
		"the clipboard contains a table that is not rectangular",
		/* [15] */	
		"the clipboard contains a table that is too big to paste in this position",
		/* 16 */
#if qELS
		"the model uses more parameters than allowed for ELS fitting",
#else
		"",
#endif
		/* 17 */
		"it was created by an old version of EasyFit",
		/* 18 */
		"The domain you specified is wrong.",
		/* 19 */
		"The domain you specified is not acceptable for a semilog plot. "
		"You must set both Y Min and Y Max to be greater then zero.",
		/* 20 */
		"Fit failed because of NANs in the Hessian matrix.",
		/* 21 */
		#if qXMDLs
		"of an error reported by the External Model",
		#else
		"",
		#endif
		/* 22 */
		#if qXMDLs
		"the External Model is incompatible with this version of EasyFit, or with this "
		"HW/SW configuration"
		#else
		""
		#endif
	}
};

resource 'STR#' (kMiscellaneaStr,
#if qNames
"Miscellanea strings",
#endif
purgeable) {
	{	/* array StringArray */
		/* [1] */ "Data";
		/* [2] */ "Parameters";
		/* [3] */ "Weights";
		/* [4] */ "Standard Residuals";
		/* [5] */ "Messages";
		/* [6] */ "Data & Model Plot";
		/* [7] */ "Standard Residuals Plot";
		/* [8] */ "this application handles one document only at a time";
	}
};


/* Column Sizing Cursor */
resource 'CURS' (kColumnSizingCursor,
#if qNames
"ColSizing",
#endif
	purgeable) {
	$"00 00 00 00 02 40 02 40 02 40 0A 50 1E 78 22 44"
	$"42 42 22 44 1E 78 0A 50 02 40 02 40 02 40",
	$"00 00 07 E0 07 E0 07 E0 0F F0 1F F8 3F FC 7F FE"
	$"FF FF 7F FE 3F FC 1F F8 0F F0 07 E0 07 E0 07 E0",
	{8, 8}
};

resource 'view' (kAlertChangingDomainOption,
#if qNames
"Alert changing domain option",
#endif
purgeable) {{

	root, 'wind', {50, 40}, {120, 336}, sizeVariable, sizeVariable, shown, enabled, 
	Window {"TWindow", dBoxProc, noGoAwayBox, notResizable, modal, ignoreFirstClick, 
		freeOnClosing, disposeOnFree, closesDocument, openWithDocument, 
		dontAdaptToScreen, dontStagger, dontForceOnScreen, center, 'ok  ', "<<<>>>"}, 

	'wind', 'dlog', {0, 0}, {120, 336}, sizeFixed, sizeFixed, shown, enabled, 
	DialogView {"TDialogView", 'ok  ', 'cncl'}, 

	'dlog', 'icon', {13, 23}, {32, 32}, sizeFixed, sizeFixed, shown, disabled, 
	Icon {"TIcon", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, dontPreferColor, 1}, 

	'dlog', 'text', {13, 78}, {51, 242}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TStaticText", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, justSystem,
		"I need to compute all subjects over the "
		"same domain. OK to change the domain option?"}, 

	'dlog', 'ok  ', {80, 240}, {28, 81}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", adnRRect, {3, 3}, sizeable, notDimmed, notHilited, 
		dismisses, {4, 4, 4, 4}, systemFont, "Change"}, 

	'dlog', 'cncl', {84, 155}, {20, 73}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", noAdornment, sizeable, notDimmed, notHilited, 
		dismisses, noInset, systemFont, "Cancel"}
	}
};

#if qXMDLs

resource 'view' (kAlertXMDLNotPresent,
#if qNames
"Alert XMDL not present",
#endif
purgeable) {{

	root, 'wind', {50, 40}, {184, 400}, sizeVariable, sizeVariable, shown, enabled, 
	Window {"TWindow", dBoxProc, noGoAwayBox, notResizable, modal, ignoreFirstClick, 
		freeOnClosing, disposeOnFree, closesDocument, openWithDocument, 
		dontAdaptToScreen, dontStagger, dontForceOnScreen, center, 'ok  ', "<<<>>>"}, 

	'wind', 'dlog', {0, 0}, {184, 400}, sizeFixed, sizeFixed, shown, enabled, 
	DialogView {"TDialogView", 'ok  ', 'cncl'}, 

	'dlog', 'icon', {13, 23}, {32, 32}, sizeFixed, sizeFixed, shown, disabled, 
	Icon {"TIcon", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, dontPreferColor, 1}, 

	'dlog', 'text', {13, 78}, {123, 298}, sizeFixed, sizeFixed, shown, disabled, 
	StaticText {"TStaticText", noAdornment, sizeable, notDimmed, notHilited, 
		doesntDismiss, noInset, systemFont, justSystem, ""}, 

	'dlog', 'ok  ', {144, 264}, {28, 112}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", adnRRect, {3, 3}, sizeable, notDimmed, notHilited, 
		dismisses, {4, 4, 4, 4}, systemFont, "Open Anyway"}, 

	'dlog', 'cncl', {148, 171}, {20, 73}, sizeFixed, sizeFixed, shown, enabled, 
	Button {"TButton", noAdornment, sizeable, notDimmed, notHilited, 
		dismisses, noInset, systemFont, "Cancel"}
	}
};
#endif qXMDLs
