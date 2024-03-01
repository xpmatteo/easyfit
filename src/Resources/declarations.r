/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989 Matteo Vaccari & Mario Negri Institute

	----------------------
	
	EasyFit - General declarations to be used in C and Rez files.
*/

/* We allow to put two-sided constraints on parameter values */
#define qConstraints 1		

/* enable experimental speedup - it should work fine.
	see remarks in computeParams.c for this */
#define SPEEDUP 1

/* Set if we are using MacApp 2.0 the Final Version */
#define MacApp20Def 1

/* Set if we want to use the code for ELS fitting -- unfortunately, it doesn't
	work. */
#define qELS 0

#define qXMDLs 1

#if qNeedsFPU
#define kVersion "1.4 FPU"
#else
#define kVersion "1.4"
#endif

#define kAppName "EasyFit"

#define kSignature 'ESFT'
#define kFileType 'ESFd'

/* Costanti molto importanti - devono corrispondere a quelle dichiarate in pascal */
#define kMaxParams 20
#define kMaxSubjects 30
#define kMaxObservations 200
#define kMaxFormulaLength 40

/* Constants for model numbers. Must be the same as those in UEasyFitDeclarations.p */
#define kSingleExp 			1
#define kTwoExpPlus			2
#define kTwoExpMinus		3
#define kThreeExpPlus		4
#define kThreeExpMinus	5
#define kUserDefined		6
#define kXMDL						7	

/* Our own error codes, to be passed to Failure */
#define kFileIsDamaged 			-24000
#define kFormulaTooComplex 	-24001
#define kUserInterruptedFit	-24002
#define kNonRectangularScrap -24003
#define kScrapTableTooBig		-24004
#define kTooManyParametersForELS -24005

/* IDs of 'STR#' resources */
#define kGenericMsgs 1001
#define kCompilerMsgs 1002
#define kCompilerTokenNames 1003
#define kMiscellaneaStr 1004

/* IDs of menu commands */
#define cAboutIRFMN										1000

#define cPrintSelection								1010
#define cPrintAll											1020

#define cClearMessages								1050

#define cDataAndFuncPlotOptions				1102
#define cStdResPlotOptions						1103
#define cFitOptions										1104
#define cPeel													1105
#define cFit													1106
#define cFitSelection									1107

#define cNoWeights										1200
#define cOneOverObsValue							1210
#define cOneOverSqObsValue						1220
#define cOneOverEstimatedValue				1225
#define cOneOverSqEstimatedValue			1230
#define cELSWeights										1240
#define cInputByHand									1250

#define cDataWindow										1309
#define cParamsWindow									1310
#define cWeightsWindow								1311
#define cDosesWindow									1316	/* not in sequence !!! */
#if qConstraints
#define cConstraintsWindow						1317	/* not in sequence !!! */
#endif
#define cMsgsWindow										1312
#define cStdResWindow									1313
#define cDataAndFuncPlotWindow				1314
#define cStdResWindowPlotWindow				1315

#define cSelection										1400
#define cSizeColumn										1401

#define cCutText											1500
#define cCopyText											1501
#define cClearText										1502
#define cCutCells											1503
#define cCopyCells										1504
#define cClearCells										1505
#define cStandardCut									1506
#define cStandardCopy									1507
#define cStandardClear								1508

#define cGeneral				 1601
#define cDecimal				 1604
#define cScientific 		 1605
#define cLeftJustify		 1607
#define cRightJustify		 1608
#define cCenter 				 1609
#define cNoDigits				 1610
#define c1Digit					 1611
#define c2Digits				 1612
#define c3Digits				 1613
#define c4Digits				 1614
#define c5Digits				 1615
#define c6Digits				 1616
#define c7Digits				 1617
#define c8Digits				 1618
#define c9Digits				 1619
#define c10Digits				 1620
#define c11Digits				 1621
#define c12Digits				 1622

#define cSingleExp				1800
#define cTwoExpPlus				1810
#define cTwoExpMinus			1820
#define cThreeExpPlus			1830
#define cThreeExpMinus		1840
#define cUserDefined			1850

/* IDs of alerts & dialogs */
#define phPlainAlert		2000
#define phSplash				2010
#define phWeNeedSystem6 2020
#define phWeNeedFPUAndSystem6 2030

/* IDs of menus */
#define mFit 4
#define mWeights 5
#define mWindows 6
#define mFormat 7
#define mModel 8

/* static variables to initialize view templates */
#define	kCellWidth					90					/* default width of each cell */
#define	kCellHeight					17					/* height of each cell */
#define	kRowInset						4						/* pixels separating cell contents from top/bottom edge */
#define	kColumnInset				4						/* pixels separating cell contents from left/right edge */
#define	kRowTitleWidth			32					/* width of row titles */
#define kRowTitleHeight			kCellHeight		/* height of the row titles */
#define	kColumnTitleWidth		kCellWidth		/* width of column titles */
#define	kColumnTitleHeight	20					/* height of column titles */
#define kFontSize						10
#define kMaxChars						kMaxFormulaLength	/* number of characters in the text edit field */

/* IDs of the view templates */
#define kExpDataWindowType	1001
#define kParamsWindowType		1002
#define kWeightsWindowType	1003
#define kStdResWindowType		1004
#define kMultiTEWindowType	1010
#define kWorkingWindowType	1020
#define kDataAndFuncPlotWindowType			1030
#define kStdResPlotWindowType			1040
#define kDosesWindowType		1050
#if qConstraints
#define kConstraintsWindowType 1060
#endif

#define kFitOptionsDlog								1100
#define kDataAndFuncPlotOptionsDlog		1110
#define kStdResPlotOptionsDlog				1120
#define kChooseModelDlog							1130
#define kUserDefinedModelDlog					1140
#define kSaveTextDlog									1150

#define kAboutAppView				2000
#define kAboutMarioNegri		2001

#define kAlertChangingDomainOption	2002
#define kAlertXMDLNotPresent				2003

/* Cursors */
#define kColumnSizingCursor	1020		/* ID of the column sizing cursor resource */

/* PICTs */
#define kSplashPict	1111
#define kAboutMarioNegriPict	1112

/* TEXT */
#define kAboutAppTextRes			3000
#define kAboutAppStylesRes		3000
#define kAboutAppElementsRes	3001
