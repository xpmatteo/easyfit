{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}
{
	Segmentation strategy: we usually follow MacApp's segmenting conventions.
		The Fit command and all of its stuff follow a different strategy.
		Due to code size, we divide Fit code in two segments, called "Fit" and
		"CallFit". In "CallFit" we put everything that is needed to call
		the Fit function, and everything that needs to stay around while
		we make several calls to the Fit function in response to a single "Fit"
		command. Thus we place in "CallFit" most of the stuff in UEasyFit.DoFit.p,
		UWorkingDlog.p, pharmacokin.c, etc.  
		
		We place in the "Fit" segment most of the code of the "fit" C module.
		
		We place the models in the resident segment "ARes".
	
}

UNIT UEasyFit;

INTERFACE

USES
	{ � MacApp }
	UMacApp,
	
	{ � Required by UTable }
	Sane, UPrinting, UTEView,

	{ � Required by UFitOptions }
	UDialog,

	{ � Required by UEasyFitDeclarations }
	Fonts, QuickDraw,

	{ � Building blocks }
	UList, UGridView, {�UBusyCursor, }
	
	{ � Required by the interface part }
	UEasyFitDeclarations, UTable,
	
	{ � Required by the implementation part }
	Packages, ToolUtils, Errors, Resources, UEasyFitUtilities, URealText,
	UMultiTE, UPercDoneBarView, UWorkingDialog;


CONST 
	kStdResColsPerSubj		= 5;
	kXCol									= 0;
	kObservedY						= 1;
	kEstimatedY						= 2;
	kStdResiduals					= 3;
	kStdPercResiduals			= 4;
	
	kEasyFitIdleFreq			= 50;
	
TYPE

	DomainType = RECORD
		dLeft, dRight, dTop, dBottom: Extended;
	END;
	
	DiskDomainType = RECORD
		ddLeft, ddRight, ddTop, ddBottom: DiskValueType;
	END;
	
	DomainOptionType = (autoSubjectBySubject, autoOverAllSubjects, userDefined);

	PlotAgainstOption = (againstTime, againstObservedConc, againstEstimatedConc);
	
	{ used to store various dialog options on the disk }	
	Miscellanea = RECORD
		beepWhenFitDone:								BOOLEAN;
		refreshPlots:										BOOLEAN;
		unattended:											BOOLEAN;
		fullOutput:											BOOLEAN;
		automaticPeeling:								BOOLEAN;
		maxIterations:									INTEGER;
		lambdaAtStart:									DiskValueType;
		format:													FormatRecord;
	END;

	PlotOptionsMiscellanea = RECORD
		dataAndFuncPlotDomainOption:		domainOptionType;
		semilog:												BOOLEAN;
		plotFast:												BOOLEAN;
		dataAndFuncPlotDomain:					DiskDomainType;
		dataAndFuncPlotXTicks:					INTEGER;
		dataAndFuncPlotYTicks:					INTEGER;
		stdResPlotDomainOption:					DomainOptionType;
		stdResPlotDomain:								DiskDomainType;
		stdResPlotAgainstOption:				PlotAgainstOption;
		stdResPlotXTicks:								INTEGER;
		stdResPlotYTicks:								INTEGER;
	END;
	
	{�This was used when I didn't realize that writing extendeds on disk
		would have brought problems with the floating point versions of EasyFit.
		I retain this data structure for compatibility with pre-1.0b3 documents }
	OldPlotOptionsMiscellanea = RECORD
		oldDataAndFuncPlotDomainOption:		domainOptionType;
		oldSemilog:												BOOLEAN;
		oldPlotFast:											BOOLEAN;
		oldDataAndFuncPlotDomain:					DomainType;
		oldDataAndFuncPlotXTicks:					INTEGER;
		oldDataAndFuncPlotYTicks:					INTEGER;
		oldStdResPlotDomainOption:				DomainOptionType;
		oldStdResPlotDomain:							DomainType;
		oldStdResPlotAgainstOption:				PlotAgainstOption;
		oldStdResPlotXTicks:							INTEGER;
		oldStdResPlotYTicks:							INTEGER;
	END;

	{�This is an old version: it happened that I decided that I wanted to
		store the lambda as a double instead of a single. }
	OldMiscellanea = RECORD
		oldBeepWhenFitDone:								BOOLEAN;
		oldRefreshPlots:									BOOLEAN;
		oldUnattended:										BOOLEAN;
		oldFullOutput:										BOOLEAN;
		oldAutomaticPeeling:							BOOLEAN;
		oldMaxIterations:									INTEGER;
		oldLambdaAtStart:									REAL;
		oldFormat:												FormatRecord;
	END;

	
	WindowShapeData = RECORD
		shown:				BOOLEAN;
		globalBounds: Rect;
	END;
		
	
{ ------------------------------------------------------------------------------- }

	TEasyFitApplication = OBJECT(TApplication)

		fEasyFitDocument: TEasyFitDocument;
		
		PROCEDURE TEasyFitApplication.IEasyFitApplication (itsMainFileType: OSType);
		
		FUNCTION TEasyFitApplication.DoMakeDocument (itsCmdNumber: CmdNumber): TDocument; 
			OVERRIDE;
		
		PROCEDURE TEasyFitApplication.AboutToLoseControl(convertClipboard: BOOLEAN); 
			OVERRIDE;
			
			{�Menu handling }
			
		PROCEDURE TEasyFitApplication.DoSetupMenus; OVERRIDE;
			
		FUNCTION TEasyFitApplication.DoMenuCommand(aCmdNumber: cmdNumber): TCommand; OVERRIDE;

			{ Miscellanea }
		
		FUNCTION TEasyFitApplication.CanOpenDocument(itsCmdNumber: CmdNumber;
									  VAR anAppFile: AppFile): BOOLEAN; OVERRIDE;
		PROCEDURE TEasyFitApplication.ShowError(error: OSErr; message: LONGINT); OVERRIDE;
								 
		FUNCTION TEasyFitApplication.MakeViewForAlienClipboard: TView; OVERRIDE;
		{�Create a view for our own type of scrap }
		
		PROCEDURE TEasyFitApplication.OpenOld(itsOpenCmd: CmdNumber; 
				anAppFile: AppFile); OVERRIDE;
		PROCEDURE TEasyFitApplication.OpenNew(itsCmdNumber: CmdNumber); OVERRIDE;
		
		PROCEDURE TEasyFitApplication.DoShowAboutApp; OVERRIDE;

		PROCEDURE TEasyFitApplication.DoShowAboutMarioNegri;
		
		PROCEDURE TEasyFitApplication.Fields(PROCEDURE DoToField(fieldName: Str255;
			fieldAddr: Ptr; fieldType: INTEGER)); OVERRIDE;

	END;

{ ------------------------------------------------------------------------------- }
	
	TEasyFitDocument = OBJECT(TDocument)
		{�tables of data }
		fExpDataTable: TExpDataTable;
		fParamsTable: TParamsTable;
		fStdResTable: TStdResTable;
		fWeightsTable: TWeightsTable;
		fDosesTable:	TDosesTable;
{$IFC qConstraints}
		fConstraintsTable:	TConstraintsTable;
{$ENDC}

		{�Other windows }
		fMessagesWindow: TMultiTE;

		{�The appropriate choice of classes is done in the view template }
		fDataAndFuncPlotWindow: TPlotWindow;
		fStdResPlotWindow: TPlotWindow;

		fTablesList: TList;		{ a list of all of the tables belonging to this doc }
		
		fWeightsOption: WeightOption;
	
		fFormat:		FormatRecord;			{�the format we are using in the tables }
		
		fModelNumber:	ModelNumber;		{�The current model chosen by the user }
		
		{$IFC qXMDLs}
		fXMDLName:	Str255;						{�Used only if the current model is an XMDL }
		{$ENDC}
		
		fMessagesText:	Handle;				{�Used temporarily to reference the
																		msgs window text when opening an old doc. }
		
		{ Used to store what we read from the document about the plot windows;
			after DoMakeViews we can then copy this info to the plot views }
		fPlotOptionsMiscellanea:	PlotOptionsMiscellanea;
		
		{�Used to store data about the window position and size when opening
			a document }
		fExpDataWindowShape:					WindowShapeData;
		fParamsWindowShape:						WindowShapeData;
		fWeightsWindowShape:					WindowShapeData;
		fStdResWindowShape:						WindowShapeData;
		fDosesWindowShape:						WindowShapeData;
		{$IFC qConstraints}
		fConstraintsWindowShape:			WindowShapeData;
		{$ENDC}
		fMessagesWindowShape:					WindowShapeData;
		fDataAndFuncPlotWindowShape:	WindowShapeData;
		fStdResPlotWindowShape:				WindowShapeData;
		
				{	Fit options }
	
		{�Can be set to true for demonstrative or didactical purposes }
		fRefreshPlotsEachIteration: BOOLEAN;

		{�Beeps when fit is finished }
		fBeepWhenFitDone: BOOLEAN;

		{ Se unattended e' true, non manda fuori gli alert che
			bloccano l'esecuzione.  Utile per esecuzioni batch.
			Var usata localmente, e passata a "fit". }
		fUnattended: boolean;
		
		{ Se full output e' true, stampa parecchio output per ogni
			iterazione sulla finestra di output testuale. 
			Var passata a "fit" }
		fFullOutput: boolean;
		
		{�automaticPeeling - se vale TRUE, fai il peeling ogni volta che
			esegui il fitting; se no, solo se la finestra parametri e' 
			vuota. }
		fAutomaticPeeling: boolean;
		
		{ Il numero di iterazioni che l'utente vuole che il programma 
			faccia prima di arrendersi e passare al prossimo soggetto
			o chiedere quante altre iterazioni l'utente vuole che 
			si facciano (il comportamento dipende dal valore di 
			"unattended") .
			Var passata a "fit". }
		fMaxIterations: integer;
		
		{ the value of lambda at start of fitting procedure }
		fLambdaAtStart: extended;
		
			{ The text of the user model; must be an handle to a C-style string }
		
		fUserModelText: Handle;

			{�Init & Free }
			
		PROCEDURE TEasyFitDocument.IEasyFitDocument;
		PROCEDURE TEasyFitDocument.FreeData;	OVERRIDE;
		PROCEDURE TEasyFitDocument.Free;	OVERRIDE;

		PROCEDURE TEasyFitDocument.DoInitialState; OVERRIDE;
		PROCEDURE TEasyFitDocument.DoMakeViews(forPrinting: BOOLEAN); OVERRIDE;

		{�Override to make sure we don't close a document while still fitting }
		PROCEDURE TEasyFitDocument.Close; OVERRIDE;

			{�Fitting }
		
		{ Chiamando questa in seguito alla richiesta dell' utente di
			fare il fitting, fatta scegliendo la apposita voce del menu fit,
			si mette in moto il Grande Meccanismo: viene
			chiamata la funzione FIT per tutti i soggetti che l'utente
			ha chiesto di fittare. }
		PROCEDURE TEasyFitDocument.DoFit;
				
			{�Miscellanea }
		
		FUNCTION TEasyFitDocument.CompileUserModel(modelHandle: Handle; 
									VAR where: LONGINT; VAR NParams: INTEGER;
									VAR errString: Str255): INTEGER;
			
		FUNCTION TEasyFitDocument.DoIdle(phase: IdlePhase): BOOLEAN; OVERRIDE;
	
			{�Handling the menus }
			
		FUNCTION TEasyFitDocument.DoMenuCommand(aCmdNumber: cmdNumber): TCommand; OVERRIDE;
		PROCEDURE TEasyFitDocument.DoSetupMenus; OVERRIDE;

			{ Disk operations }

		PROCEDURE TEasyFitDocument.DoNeedDiskSpace(VAR dataForkBytes,
												rsrcForkBytes: LONGINT); OVERRIDE;

		PROCEDURE TEasyFitDocument.DoRead(aRefNum: INTEGER; rsrcExists,
										 		forPrinting: BOOLEAN); OVERRIDE;

		PROCEDURE TEasyFitDocument.DoWrite(aRefNum: INTEGER; makingCopy: BOOLEAN); OVERRIDE;
		
		PROCEDURE TEasyFitDocument.Revert; OVERRIDE;
		
			{�Dialog posing methods }
		
		FUNCTION TEasyFitDocument.MakeUserModelDlog: BOOLEAN;
		
		PROCEDURE TEasyFitDocument.MakeFitOptionsDlog;
		
			{�Debug }
		
		PROCEDURE TEasyFitDocument.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
													 				fieldType: INTEGER)); OVERRIDE;
	END;

{ ------------------------------------------------------------------------------- }

	TExpDataTable = OBJECT(TTable)
		
		fEasyFitDocument: TEasyFitDocument;
		
		PROCEDURE TExpDataTable.IExpDataTable(itsEasyFitDocument: TEasyFitDocument;
																					itsFormat: FormatRecord);

		{�Provide the string for the horizontal titles }
		PROCEDURE TExpDataTable.CoordToString(coord: INTEGER; VAR theString: Str255);
			OVERRIDE;
		
		{�Tells us which 'subjects' columns are selected.  If none are selected,
			it returns [1..kMaxSubjects] }
		PROCEDURE TExpDataTable.GetSelectedSubjects(VAR selection: SubjectSet);
		
		{�Check wether the plot windows' scroll bars needs redrawing }
		PROCEDURE TExpDataTable.AddColumn(theColumn: TColumn);	OVERRIDE;
		PROCEDURE TExpDataTable.AddCell(theCell: TCell; r: RowNumber; c: ColumnNumber);
			OVERRIDE;

		PROCEDURE TExpDataTable.ChangedColumn(all: BOOLEAN; column: ColumnNumber);
			OVERRIDE;

	END;	

{ ------------------------------------------------------------------------------- }

	TParamsTable = OBJECT(TTable)
		
		fEasyFitDocument: TEasyFitDocument;
		
		PROCEDURE TParamsTable.IParamsTable(itsEasyFitDocument: TEasyFitDocument;
																				itsFormat: FormatRecord);

		{�Provide the string for the horizontal titles }
		PROCEDURE TParamsTable.CoordToString(coord: INTEGER; VAR theString: Str255);
			OVERRIDE;

		PROCEDURE TParamsTable.ChangedColumn(all: BOOLEAN; column: ColumnNumber);
			OVERRIDE;

	END;	

{--------------------------------------------------------------------------------------------------}

	TWeightsTable = OBJECT(TTable)
		
		fEasyFitDocument: TEasyFitDocument;
		
		PROCEDURE TWeightsTable.IWeightsTable(itsEasyFitDocument: TEasyFitDocument;
																					itsFormat: FormatRecord);

		{�Provide the string for the horizontal titles }
		PROCEDURE TWeightsTable.CoordToString(coord: INTEGER; VAR theString: Str255);
			OVERRIDE;

	END;	

{--------------------------------------------------------------------------------------------------}

	TStdResTable = OBJECT(TTable)
		
		fEasyFitDocument: TEasyFitDocument;
		
		PROCEDURE TStdResTable.IStdResTable(itsEasyFitDocument: TEasyFitDocument;
																					itsFormat: FormatRecord);

		{�Provide the string for the horizontal titles }
		PROCEDURE TStdResTable.CoordToString(coord: INTEGER; VAR theString: Str255);
			OVERRIDE;

	END;	

{--------------------------------------------------------------------------------------------------}

	TDosesTable = OBJECT(TTable)
		
		fEasyFitDocument: TEasyFitDocument;
		
		PROCEDURE TDosesTable.IDosesTable(itsEasyFitDocument: TEasyFitDocument;
																			itsFormat: FormatRecord);

		{�Provide the string for the horizontal titles }
		PROCEDURE TDosesTable.CoordToString(coord: INTEGER; VAR theString: Str255);
			OVERRIDE;
		
		{�Override to modify resize limits }
		PROCEDURE TDosesTable.DoMakeViews(forPrinting: BOOLEAN); OVERRIDE;
		
		PROCEDURE TDosesTable.GetDose(theSubject: INTEGER; VAR theDose: EXTENDED);
		
		{�Since the user model may depend from the dose, when the user edits
			this table the data & model plot may need to be redrawn. }
		PROCEDURE TDosesTable.ChangedColumn(all: BOOLEAN; column: ColumnNumber);
			OVERRIDE;
		
	END;	

{--------------------------------------------------------------------------------------------------}
{$IFC qConstraints}

	TConstraintsTable = OBJECT(TTable)
		
		fEasyFitDocument: TEasyFitDocument;
		
		PROCEDURE TConstraintsTable.IConstraintsTable(
			itsEasyFitDocument: TEasyFitDocument; itsFormat: FormatRecord);

		{�Provide the string for the horizontal titles }
		PROCEDURE TConstraintsTable.CoordToString(coord: INTEGER; VAR theString: Str255);
			OVERRIDE;
		
		{�Override to modify resize limits }
		PROCEDURE TConstraintsTable.DoMakeViews(forPrinting: BOOLEAN); OVERRIDE;
		
		PROCEDURE TConstraintsTable.GetLowConstraints(p: PExtended; NParams: INTEGER);
		PROCEDURE TConstraintsTable.GetHiConstraints(p: PExtended; NParams: INTEGER);
		
	END;
	
{$ENDC}
{--------------------------------------------------------------------------------------------------}

TPlotWindow = OBJECT(TWindow)
	
	fEasyFitDocument:				TEasyFitDocument;
	fSubject:								INTEGER;		{�The subject displayed }
	fInfoView:							TStaticText;
	fScBarView:							TScrollBar;
	fPlotView:							TDataAndFuncPlotView;
	fPrintView:							TPlotPrintView;
	
	PROCEDURE TPlotWindow.IRes(itsDocument: TDocument; itsSuperView: TView;
			VAR itsParams: Ptr);	OVERRIDE;
	
	PROCEDURE TPlotWindow.IPlotWindow;
	
	{ so we can handle a click in the scroll bar or export button }
	PROCEDURE TPlotWindow.DoChoice(origView: TView; itsChoice: INTEGER); OVERRIDE;
	
	PROCEDURE TPlotWindow.Draw(area: Rect); OVERRIDE;
	
	{�Restituisce il numero di soggetti (per il max dello scroll bar) }
	FUNCTION TPlotWindow.GetNumberOfPages: INTEGER;
	
	{ Force the window to show a particular subject }
	PROCEDURE TPlotWindow.ShowSubject(subject: INTEGER; redraw: BOOLEAN);

	{�Use to set up the scroll bar correctly }
	PROCEDURE TPlotWindow.NumberOfPagesHasChanged(redraw: BOOLEAN);

	PROCEDURE TPlotWindow.MakeDialog;
	
		{�Menu handling for the "print all plots" command }
	
	PROCEDURE TPlotWindow.DoSetupMenus; OVERRIDE;
	
	FUNCTION TPlotWindow.DoMenuCommand(aCmdNumber: cmdNumber): TCommand; OVERRIDE;
	
		{�Debug }
	
	PROCEDURE TPlotWindow.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
											fieldType: INTEGER)); OVERRIDE;
END;

{--------------------------------------------------------------------------------------------------}
TDataAndFuncPlotView = OBJECT(TView)

	fEasyFitDocument:				TEasyFitDocument;
	fExpDataTable:					TExpDataTable;
	fPlotWindow:						TPlotWindow;

	fExtent:								Rect;
	fPlotRect:							Rect;
	fFontAscent:						INTEGER;
	fFontDescent:						INTEGER;
	fHorSpace:							INTEGER;		{ The width of the largest possible tick
																				intestation }

	fDomainOption:					DomainOptionType;
	
	{�Grafico semilogaritmico, o no ? }
	fSemilog:								BOOLEAN;
	
	{�Plot fast & inaccurate, or slow and accurate ? }
	fPlotFast:							BOOLEAN;
	
	{ il numero di intervalli da disegnare sul grafico }
	fXIntervals, fYIntervals: integer;
	
	{ I confini del grafico sul piano reale }
	fDomain: domainType;
	
	{�Quante tacchette piccole deve fare nel grafico semilog }
	fNumSmallTicks: INTEGER;
	
		{ initialization }
	PROCEDURE TDataAndFuncPlotView.IRes(itsDocument: TDocument; itsSuperView: TView;
			VAR itsParams: Ptr);	OVERRIDE;
	
		{ Needed because when this view changes size, it must be recomputed and 
			redrawn }
	PROCEDURE TDataAndFuncPlotView.Resize(width, height: VCoordinate; 
			invalidate: BOOLEAN); OVERRIDE;
	
	PROCEDURE TDataAndFuncPlotView.ComputeDomain;

	PROCEDURE TDataAndFuncPlotView.ComputePlotRect;
	
	{�Export the data to a text document, to be opened by graphics or
		statistical packages }
		
	PROCEDURE TDataAndFuncPlotView.ExportData(allSubjects: BOOLEAN);
	
		{�Options dialog stuff }
		
	PROCEDURE TDataAndFuncPlotView.MakeDialog;
	PROCEDURE TDataAndFuncPlotView.LoadDomain;
	PROCEDURE TDataAndFuncPlotView.GetDomain;
	PROCEDURE TDataAndFuncPlotView.EnableDomain(state: BOOLEAN; reDraw: BOOLEAN);
	PROCEDURE TDataAndFuncPlotView.ShowDomain(state: BOOLEAN; reDraw: BOOLEAN);
	PROCEDURE TDataAndFuncPlotView.EnableYTicks(state: BOOLEAN);
	
		{�Insulating the functions that get to the data, we can exploit the 
			ComputeDomain method also in specialized versions of this View.
			Note that we prefer passing arguments as VAR rather than using
			pascal FUNCTIONs because of improved speed (with EXTENDEDs) }
			
	PROCEDURE TDataAndFuncPlotView.GetX(VAR x: EXTENDED; obs: INTEGER);
	PROCEDURE TDataAndFuncPlotView.GetY(VAR y: EXTENDED; obs: INTEGER);
	PROCEDURE TDataAndFuncPlotView.GetMinX(VAR minimum: EXTENDED);
	PROCEDURE TDataAndFuncPlotView.GetMinY(VAR minimum: EXTENDED; subject: INTEGER);
	PROCEDURE TDataAndFuncPlotView.GetMaxX(VAR maximum: EXTENDED);
	PROCEDURE TDataAndFuncPlotView.GetMaxY(VAR maximum: EXTENDED; subject: INTEGER);
	FUNCTION TDataAndFuncPlotView.GetNumberOfPages: INTEGER;
	FUNCTION TDataAndFuncPlotView.GetNumberOfPoints: INTEGER;
	FUNCTION TDataAndFuncPlotView.GetCurrentSubject: INTEGER;
	
		{ Drawing stuff }
	
	PROCEDURE TDataAndFuncPlotView.PlotTheData;
	PROCEDURE TDataAndFuncPlotView.PlotTheFunction;
	PROCEDURE TDataAndFuncPlotView.DrawXTicks;
	PROCEDURE TDataAndFuncPlotView.DrawYTicks;
	PROCEDURE TDataAndFuncPlotView.DrawAxis;
	PROCEDURE TDataAndFuncPlotView.Draw(area: Rect); OVERRIDE;
	
	{ Gives the number of function evaluations used to plot the function.
		It depends on the size of the view. }
	FUNCTION TDataAndFuncPlotView.ComputeSteps: INTEGER;

	PROCEDURE TDataAndFuncPlotView.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
											fieldType: INTEGER)); OVERRIDE;	
END;

{--------------------------------------------------------------------------------------------------}

{ Per comodita' questa view e' una discendente di TDataAndFuncPlotView.  Risparmio
	un po' di codice. }
	
TStdResPlotView = OBJECT(TDataAndFuncPlotView)
	
	{ la finestra che contiene i valori numerici dei residui std }
	fStdResTable: TStdResTable;

	fPlotAgainstOption: PlotAgainstOption;

	PROCEDURE TStdResPlotView.IRes(itsDocument: TDocument; itsSuperView: TView;
			VAR itsParams: Ptr);	OVERRIDE;

	PROCEDURE TStdResPlotView.MakeDialog; OVERRIDE;
	
	PROCEDURE TStdResPlotView.ComputeDomain; OVERRIDE;

	PROCEDURE TStdResPlotView.GetX(VAR x: EXTENDED; obs: INTEGER); OVERRIDE;
	PROCEDURE TStdResPlotView.GetY(VAR y: EXTENDED; obs: INTEGER); OVERRIDE;
	PROCEDURE TStdResPlotView.GetMinX(VAR minimum: EXTENDED); OVERRIDE;
	PROCEDURE TStdResPlotView.GetMinY(VAR minimum: EXTENDED; subject: INTEGER); OVERRIDE;
	PROCEDURE TStdResPlotView.GetMaxX(VAR maximum: EXTENDED); OVERRIDE;
	PROCEDURE TStdResPlotView.GetMaxY(VAR maximum: EXTENDED; subject: INTEGER); OVERRIDE;

	PROCEDURE TStdResPlotView.Draw(area: Rect); OVERRIDE;
	
	PROCEDURE TStdResPlotView.PlotTheFunction; OVERRIDE;

	PROCEDURE TStdResPlotView.Fields(PROCEDURE DoToField(fieldName: Str255; 
			fieldAddr: Ptr; fieldType: INTEGER)); OVERRIDE;
END;

{--------------------------------------------------------------------------------------------------}

TFormatter	= OBJECT (TCommand)
{ TFormatter is a command object created to change the style or justification
 of the EasyFitDocument tables. It is undoable. }
	
	fOldFormat:			FormatRecord;
	fNewFormat:			FormatRecord;
	fTablesList:		TList;
	
	PROCEDURE TFormatter.IFormatter(itsEasyFitDocument: TEasyFitDocument; 
																	itsCommand: INTEGER);
		
	PROCEDURE TFormatter.DoIt; OVERRIDE;
	PROCEDURE TFormatter.UndoIt; OVERRIDE;
	PROCEDURE TFormatter.RedoIt; OVERRIDE;
	
	PROCEDURE TFormatter.Fields(PROCEDURE
									DoToField(fieldName: Str255; fieldAddr: Ptr;
											fieldType: INTEGER)); OVERRIDE;
 
END;									{ TFormatter }

{ ----------------------------------------------------------------------------------- }

{�TPlotPrintView -- It is the view in the plot windows that is used for printing
	the parts of the plot that need to be printed, or copied to the scrap.
	These parts are the plot and the info view, but _not_ the scroll bar.
	The definition of a subclass of TView is needed only to provide support
	for the copy menuitem. Thus it is possible to copy the window to the scrap as
	a pict. }

TPlotPrintView = OBJECT(TView)
	PROCEDURE TPlotPrintView.DoSetupMenus; OVERRIDE;
			
	FUNCTION TPlotPrintView.DoMenuCommand(aCmdNumber: cmdNumber): TCommand; OVERRIDE;
END;

TDataAndFuncPlotPrintView = OBJECT(TPlotPrintView)
	PROCEDURE TDataAndFuncPlotPrintView.GetInspectorName(VAR inspectorName: Str255); OVERRIDE;
END;

TStdResPlotPrintView = OBJECT(TPlotPrintView)
	PROCEDURE TStdResPlotPrintView.GetInspectorName(VAR inspectorName: Str255); OVERRIDE;
END;

{ ------------------------------------------------------------------------------- }

{	TAdornedScroller -- it is a TScroller that draws an adornment around itself.
	It is commented out because it doesn't function properly. }
{$IFC FALSE}
TAdornedScroller = OBJECT(TScroller)
	PROCEDURE TAdornedScroller.Draw(area: Rect); OVERRIDE;
END;
{$ENDC}
{ ------------------------------------------------------------------------------- }

	{�Utility functions }
	PROCEDURE RefreshPlots(subject: LONGINT; params: PExtended; NParams: LONGINT);
	
	PROCEDURE MessagesWriteln(cString: Str255);

	PROCEDURE MessagesWrite(cString: Str255);

	PROCEDURE MessagesNewLine;
	
	PROCEDURE MessagesSynch;

	PROCEDURE SetWDlogText(pString: Str255);

	FUNCTION PollEvent: BOOLEAN;

	FUNCTION AskMoreIterations(VAR howMany:integer): BOOLEAN;
		
	{ This one is called when user tries to do bad things during the fitting,
		like trying to edit tables or closing the document. }
	PROCEDURE RemindUserWeAreWorking;

	PROCEDURE ReportFileDamaged(aRefNum: INTEGER);
	
{ ------------------------------------------------------------------------------- }

IMPLEMENTATION

VAR

	{�These are public references to object that need to be referred to from
		C functions. Actually C functions do not refer to them directly, but
		through calls to MessagesWriteln etc.
		PMessagesWindow is set up in TEasyFitDocument.DoMakeViews, and set to NIL in 
		TEasyFitDocument.Free and in TEasyFitApplication.IEasyFitApplication. 
		PWorkingDialog is set up whe entering TEasyFitDocument.DoFit, and set to NIL
		when exiting the same method, and in TEasyFitApplication.IEasyFitApplication.
		So we make sure that when the object they refer to doesn't exist, these
		variables are NIL. }	
	pMessagesWindow:	TMultiTE;
	pWorkingDialog:		TWorkingDialog;
	
	{$I UEasyFit.plots.p}
	{$I UEasyFit.dlogs.p}
	{$I UEasyFit.DoFit.p}
	{$I UEasyFit.inc1.p}
	
END.