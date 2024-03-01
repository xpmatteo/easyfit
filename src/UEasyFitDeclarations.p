{
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}
{
	
	Global declarations, shared by more than one unit.
	Also global (application-wide) variables are declared here.
	Globals pertaining to sub-modules such as the fitting module
	or the compint module are declared in their modules.
}

{$SETC qConstraints := TRUE} 	{ We allow to put two-sided constraints on 
																parameter values }

{$SETC MacApp20Def := TRUE}		{ÊSet true to mean we're using definitive MacApp 2.0 }

{$SETC qELS := FALSE}					{ Set true to allow code for ELS fitting -- it doesn't
																work yet. }

{$SETC qDebugFiles := TRUE}		{ÊAllow more debugging output }

{$SETC qXMDLs := TRUE}				{ÊAllow use of External Models (XMDLs) }

UNIT  UEasyFitDeclarations;
INTERFACE

USES
	UMacApp, Fonts, TextEdit;
	
CONST
	kSignature = 'ESFT';
	kFileType = 'ESFd';
	
	{$IFC qNeedsFPU}
	kVersion = '1.4 FPU';
	{$ELSEC}
	kVersion = '1.4';
	{$ENDC}
	
	{ the creator for EasyFit text files is MacWrite. }
	kTextCreator = 'MACA';

	{ÊThe resource & file type for external models }
	kXMDLType = 'XMDL';

	{ dimensioni degli array }
	kMaxParams = 20;
	kMaxObservations = 200;
	kMaxSubjects = 30;

	kTextScrapType		= 'TEXT';
	kTableScrapType		= 'Esft';

	kCellWidth				= 90;							{ default width of each cell }
	kCellHeight 			= 17;							{ default height of each cell }
	kCellHBorder			= 2;							{ pixels separating cell contents from
															  				left/right edge }

	kCellFont						= applFont;
	kCellFontSize				= 10;
	kRowTitleWidth			= 32;						{ width of row titles }
	kColumnTitleHeight	= 20;						{ height of column titles }
	kTitlesFont 				= applFont;			{ font for column/row titles }
	kTitlesFontSize 		= 10;						{ font size for column/row titles }

	kEntryFont			= applFont;					{ default font of cell contents }
	kEntryFontSize		= 10;							{ default font size of cell contents }
	kEntryHeight		= 20;								{ height of the cell entry view }

	kDefaultJustification = TEJustCenter;	{ default cell justification }
	kNoJustification	= 2;							{ constant representing no justification }
	kUnknownJustification = 3;					{ justification of selection isn't known }

	kValuePrecision 	= 20;							{ digits of precision in our values }
	kTELength			= (80 * 5); 					{ number of characters in the text edit field }

	{ Command Constants }
	cAboutIRFMN										= 1000;

	cPrintSelection								= 1010;
	cPrintAll											= 1020;
	
	cClearMessages								= 1050;
		
	cDefineUserModel							= 1108;	{ !!!! Not in sequence !!!! }
	cDataAndFuncPlotOptions				= 1102;
	cStdResPlotOptions						= 1103;
	cFitOptions										= 1104;
	cPeel													= 1105;
	cFit													= 1106;
	cFitSelection									= 1107;

	cNoWeights										= 1200;
	cOneOverObsValue							= 1210;
	cOneOverSqObsValue						= 1220;
	cOneOverEstimatedValue				= 1225;
	cOneOverSqEstimatedValue			= 1230;
	cELSWeights										=	1240;
	cInputByHand									= 1250;

	cDataWindow										= 1309;
	cParamsWindow									= 1310;
	cWeightsWindow								= 1311;
	cMsgsWindow										= 1312;
	cDosesWindow									= 1316;	{ not in sequence !!! }
{$IFC qConstraints}
	cConstraintsWindow						= 1317;	{ not in sequence !!! }
{$ENDC}
	cStdResWindow									= 1313;
	cDataAndFuncPlotWindow				= 1314;
	cStdResPlotWindow							= 1315;

	cSelection			= 1400;
	cSizeColumn 		= 1401;
	
	cCutText				= 1500;
	cCopyText				= 1501;
	cClearText			= 1502;
	cCutCells				= 1503;
	cCopyCells			= 1504;
	cClearCells 		= 1505;
	cStandardCut		= 1506;
	cStandardCopy		= 1507;
	cStandardClear	= 1508;
	
	cGeneral				= 1601;
	cDecimal				= 1604;
	cScientific 		= 1605;
	cLeftJustify		= 1607;
	cRightJustify		= 1608;
	cCenter 				= 1609;
	cNoDigits				= 1610;
	c1Digit					= 1611;
	c2Digits				= 1612;
	c3Digits				= 1613;
	c4Digits				= 1614;
	c5Digits				=	1615;
	c6Digits				=	1616;
	c7Digits				=	1617;
	c8Digits				=	1618;
	c9Digits				=	1619;
	c10Digits				=	1620;
	c11Digits				=	1621;
	c12Digits				=	1622;
	
	cSingleExp			= 1800;
	cTwoExpPlus			= 1810;
	cTwoExpMinus		= 1820;
	cThreeExpPlus		= 1830;
	cThreeExpMinus	= 1840;
	cUserDefined		= 1850;

{Êmiscellanea resources }
	
	{ IDs of menus }
	mFit = 4;
	mWeights = 5;
	mWindows = 6;
	mFormat = 7;
	mModel = 8;
	
	kAboutAppTextRes		= 3000;		{ÊThe res ID of the text and the styles that go }
	kAboutAppStylesRes	= 3000;		{Êin the "about EasyFit" window }
	kAboutAppElementsRes = 3001;

	kExpDataWindowType	= 1001;
	kParamsWindowType		= 1002;
	kWeightsWindowType	= 1003;
	kStdResWindowType		= 1004;
	kWorkingWindowType	= 1020;
	kDosesWindowType		= 1050;
{$IFC qConstraints}
	kConstraintsWindowType = 1060;
{$ENDC}

	kDataAndFuncOptionsDlog		= 1101;
	kStdREsPlotOptionsDlog		= 1102;
	
	{ IDs of 'STR#' resources }
	kGenericMsgs 					= 1001;
	kCompilerMsgs					= 1002;
	kCompilerTokenNames		= 1003;
	kMiscellaneaStr				= 1004;
	
	{ÊIndexes of msgs in kGenericMsgs }
	eNotEnoughObservations		= 1;
	eBadInitialEstimate				= 2;
	eMissingParam							= 3;
	ePeelingFailed						= 4;
	eComputeWeightsFailed			= 5;
	eNotEnoughMemoryForFitting	= 6;
	eSumIsNan									= 7;
{$IFC qConstraints}
	eInvalidInitialEstimate		= 8;
	eConstraintsLoopError			= 9;
{$ENDC}
	eCantPeelUserModel				= 10;
	eTooManyIterations				= 11;
	eFileIsDamaged						= 12;
	eOutOfStackSpace					= 13;
	eNonRectangularScrap			= 14;
	eScrapTableTooBig					= 15;
	eTooManyParametersForELS	= 16;
	eFileCreatedByOldVersion	= 17;
	eWrongDomain							= 18;
	eWrongDomainForSemilog		= 19;
	eNoSolutions							= 20;
	eXMDLFailed								= 21;
	eFailedXMDLInitialization = 22;
	
	{ÊOur own failure explanation messages }
	kFileIsDamaged						= -24000;
	kFormulaTooComplex				= -24001;
	kUserInterruptedFit				= -24002;
	kNonRectangularScrap			= -24003;
	kScrapTableTooBig					= -24004;
	kTooManyParametersForELS 	=	-24005;
	kFileCreatedByOldVersion 	=	-24006;
	kXMDLNotPresent						=	-24007;
	kXMDLFailed								= -24008;
	kFailedXMDLInitialization = -24009;
	
	{Êil numero di cifre di precisione per ottenere una stringa da
		un numero extended, nei casi in cui e' preferibile mostrare
		poche cifre (ad esempio viene usata per le cifre sugli assi nei
		grafici. }
	kSmallPrecision = 3;
	
	{Êil numero di cifre di precisione per ottenere una stringa da
		un numero extended, nei casi in cui si vuole usare la
		"massima" precisione, ad esempio per esibire i risultati
		del fitting.  Anche se un extended conta 20 cifre 
		significative, non ha molto senso mostrarne piu' di 8. 
		infatti non solo le cifre piu' lontane sono inficiate 
		dall' accumulo degli arrotondamenti, ma anche quelle non tanto
		lontane non sono accurate data la precisione con cui ci si
		puo' aspettare che vengano misurati i dati. }
	kLargePrecision = 8;
	
	{ÊIl numero di cifre che vengono mostrate per default nelle tabelle,
		quando l'utente sceglie lo stile 'decimal' o 'scientific' }
	kDefaultPrecision = 8;
	
	{ Max. length of a value as a string, taking into account the max number of
		significant digits (20), a leading sign, a dot, and a 'e±xxxx' epilog. }
	kMaxValueLength 	= 28;
	
	{ÊMax length of the fFormula field in a cell; 
		IMPORTANT: _this_constant_must_be_the_same_as_the_one_declared_in_declarations.r_ }
	kMaxFormulaLength = 40;

		{ costanti che riguardano i "ticks" sugli assi delle finestre
			grafiche }
	
	{ numero massimo e minimo di suddivisioni maggiori sugli assi }
	kMinNumOfIntervals = 0;
	kMaxNumOfIntervals = 50;
	
	kDefaultNumXIntervals = 5;
	kDefaultNumYIntervals = 5;
	
	{ default per le suddivisioni minori }
	kDefaultNumSmallTicks = 6;

	{ La lunghezza del trattino delle suddivisioni maggiori }
	kLargeTickLen = 5;
	
	{Êla lunghezza del trattino delle sudd. minori }
	kSmallTicklen = 3;
	
		{ Costanti che corrispondono ai vari modelli.
			Controlla sempre la corrispondenza con le costanti dichiarate
			in FIT.H !!!
			Nota che il il primo modello precompilato deve 
			corrispondere al numero 1 }
	kSingleExp 			= 1;
	kTwoExpPlus			= 2;
	kTwoExpMinus		= 3;
	kThreeExpPlus		= 4;
	kThreeExpMinus	= 5;
	kUserDefined		= 6;
	kXMDL						= 7;
	
	{ The number of models }
	kTheNumberOfModels = 7;
	
	{ chars and sets of chars }
	chDot = '.';
	chPlus = '+';
	chMinus ='-';
	kControlCharSet = [chHome, chEnd, chPageUp, chPageDown];
	kRealNumberCharSet = ['0'..'9', chDot, 'e', 'E', chPlus, chMinus, chBackSpace, 
												chClear, chFwdDelete, chEscape] + kControlCharSet;

	
	{ Window size data }
	kDosesWindowHeight = 84;
	kTableWindowDefaultHorSize = 317;
	kTableWindowDefaultVertSize = 237;
	kSpaceFromScreenCorners = 4; { dist in pixels of the first window from the
																 screen corners }

	{ These constants must have the same value as the ones declared in file
		ConstraintsWindow.r }
	kConstraintsMaxRows = kMaxParams;
	kConstraintsMaxCols = 2;
	kScBarWidth = 16;	
	kConstraintsSizeH = kRowTitleWidth 
											+ kConstraintsMaxCols*kCellWidth 
											+ kScBarWidth - 1;
	kConstraintsSizeV = kColumnTitleHeight
											+ kConstraintsMaxRows*kCellHeight
											+ 30
											+ kScBarWidth;

	kGoldenRatio = 0.618;
	kPlotWindowDefaultWidth = 448;
	kPlotWindowDefaultHeight = 277 + kScBarWidth; { 277 = 448 * kGoldenRatio }
	

TYPE	
	PExtended = ^EXTENDED;
	
	ValueType				= Extended;
	DiskValueType		= Double;				{ Extendeds are for internal use only}

	ValueString 		= STRING[kMaxValueLength];
	FormulaString		= STRING[kMaxFormulaLength];

	WeightOption    = (noWeights, oneOverYObserved, oneOverSquaredYObserved,
											oneOverYEstimated, oneOverSquaredYEstimated,
											ELS, inputByUser);

	ModelNumber			= 1..kTheNumberOfModels;

	SubjectNumber		= 1..kMaxSubjects;
	SubjectSet			= SET OF SubjectNumber;

	ObsNumber				= 1..kMaxObservations;
	
	EDataArray = array [ObsNumber] of extended;
	EDataPtr = ^EDataArray;
	EDataHdl = ^EDataPtr;
	
	PlacesArray = ARRAY[ObsNumber] of INTEGER;
	
	ParamsArray = array [1..kMaxParams] of extended;
	ParamsPtr = ^ParamsArray;

	
VAR
	gMissing:					Extended;		{ÊIt contains a Nan that's used conventionally to mean
																	a missing value }
	
	gWatchHdl:				CursHandle; {ÊA handle to the watch cursor }
	
	{ÊUsed when fitting. Some are allocated in IEasyFitApplication. }

		gX:								EDataPtr;
		gY:								EDataPtr;
		gSqrtWeights:			EDataPtr;
		gParams:					ParamsArray;
		gLowConstraints:	ParamsArray;
		gHiConstraints:		ParamsArray;
		
	{Êthe meaning of these is: gX[i] corresponds to row gPlace[i] in the
		experimental data window; same is true for gY.
		??? Perhaps this should be an implementation private of UEasyFit ??? }
	gPlaces:						PlacesArray;
	
	{ Set to TRUE when we are performing a fit; so every procedure that
		may be called when processing events during the fit can know it }
	gWorking:					BOOLEAN;
	
	{ The dose for the current subject. This is used during fitting, to pass
		dose information to the ÄÐpascal interpreter or an external model. }
	gDose:						EXTENDED;
	
	{ This is set to a number in the 1..kMaxSubject range when a subject gets modified,
		and is set to zero when	the subject is redrawn in the data & model plot window.
		If it is set to a negative number, then it means that the data & model plot
		window needs to be redrawn no matter what the currently displayed subject is. }
	gSubjectModified:	INTEGER;
	
	{Êusata per passare il numero del soggetto all'interprete di ÄÐpascal }
	gExtendedCurrentSubject: EXTENDED;

	{$IFC qXMDLs}
	{ A handle to the code of the external model. This is valid only
		after model is loaded via LoadXMDL function }
	gXMDL:	Handle;
	
	gApplicationWD:	INTEGER;	{ÊThe application's Working Directory. }
	
	gLastOpenedResFile:	INTEGER;
	{$ENDC}
	
END.
