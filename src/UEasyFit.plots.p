{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}
{
	Segmentation strategy:
	
	Almost all of the routines here belong in a separate segment, GrafWindObjs.
	This applies to the dialogs code also, since it needs to call ComputeDomain
	code, that is also needed when drawing the graphical windows.
}

CONST

	{�Room to make plots look neat. }
	kBorder = 4;

		{�Questa costante indica di quanto devono essere aumentati i 
			limiti del dominio per motivi estetici.  (non piu' usata) }
	kOffsetPercentage = 0.05;
	
		{�Identifiers of radio buttons in my dialog }
	autoSubBySubRadio = 'auss';
	autoOverAllSubRadio = 'auoa';
	userDefinedRadio = 'udef';
	
	kAlsoNegatives = FALSE;		{ parameter to GetMinOfCol & GetMaxOfCol }

{ ---------------------------------------------------------------------------------- }

TYPE

	TDataAndFuncPlotOptionsDialogView = OBJECT(TDialogView)
		PROCEDURE TDataAndFuncPlotOptionsDialogView.SetUpDomain(domainOption:
																														DomainOptionType);
		PROCEDURE TDataAndFuncPlotOptionsDialogView.DoChoice(origView: TView; 
			itsChoice: INTEGER); OVERRIDE;
		FUNCTION TDataAndFuncPlotOptionsDialogView.CanDismiss(dismissing: IDType):
			BOOLEAN; OVERRIDE;
	END;
	
	TPlotWindowScrollBar = OBJECT(TScrollBar)
		PROCEDURE TPlotWindowScrollBar.Draw(area: Rect); OVERRIDE;
	END;

	TPlotWindowInfoView = OBJECT(TStaticText)
		PROCEDURE TPlotWindowInfoView.Draw(area: Rect); OVERRIDE;
	END;
	
	TStdResPlotOptionsDialogView = OBJECT(TDataAndFuncPlotOptionsDialogView)
		PROCEDURE TStdResPlotOptionsDialogView.DoChoice(origView: TView; 
			itsChoice: INTEGER); OVERRIDE;
	END;
		
{ ----------------------------------------------------------------------------------- }

{ A few variables; these are used only when showing the dialog }
VAR
	pXMinField:							TRealText;
	pXMaxField:							TRealText;
	pYMinField:							TRealText;
	pYMaxField:							TRealText;
	pYTicksField:						TNumberText;
	pAutoOverAllSubRadio:		TRadio;
	pAutoSubBySubRadio:			TRadio;
	pUserDefRadio:					TRadio;
	pSemilogCheckBox:				TCheckBox;
	pPlotView:							TDataAndFuncPlotView;
	pDialog:								TDataAndFuncPlotOptionsDialogView;
	pAgainstTimeRadio:									TRadio;
	pAgainstObservedConcRadio:					TRadio;
	pAgainstComputedConcRadio:					TRadio;

{ ---------------------------------------------------------------------------------- }

{�a few (!) C externals }

PROCEDURE SetIthElement(vector: PExtended; i: INTEGER; value: EXTENDED); C; EXTERNAL;

PROCEDURE PlotFunction(scrXMin, scrXMax, scrYmin, scrYMax: integer;
											 fXmin, fXmax, fYmin, fYmax: Extended;
											 step: integer;
											 func: ProcPtr;
											 params: PExtended); C; EXTERNAL;

PROCEDURE PlotSemilogFunction(scrXMin, 
															scrXMax, 
															scrYmin, 
															scrYMax: integer;
															fXmin, 
															fXmax, 
															fYmin, 
															fYmax: Extended;
															step: integer;
															func: ProcPtr;
															params: PExtended); C; EXTERNAL;											 
											 
PROCEDURE PlotPoint	(scrXMin, scrXMax, scrYmin, scrYMax: integer;
										 fXmin, fXmax, fYmin, fYmax: Extended;
										 x, y: Extended); 
										 C; EXTERNAL;

PROCEDURE PlotSemilogPoint(scrXMin, 
													 scrXMax, 
													 scrYmin, 
													 scrYMax: integer;
													 fXmin, 
													 fXmax, 
													 fYmin, 
													 fYmax: Extended;
													 x, 
													 y: Extended); 
										 C; EXTERNAL;

PROCEDURE PlotSemilogSmallTicks(scr_x, 
																scr_y_min, 
																scr_y_max			: Integer;
																f_y_min, 
																f_y_max				: Extended;
																num_intervals	: Integer);
										C; EXTERNAL;

FUNCTION get_ModelFunc(modelNumber: INTEGER): ProcPtr; C; EXTERNAL;

FUNCTION get_NumberOfParams(modelNumber: INTEGER): INTEGER; C; EXTERNAL;	

PROCEDURE Num2NiceStr(n: EXTENDED; s: Str255; precision: INTEGER); C; EXTERNAL;

PROCEDURE DrawZeroLine(scrXMin, scrXMax, scrYmin, scrYMax: integer;
											 fXmin, fXmax, fYmin, fYmax: Extended); C; EXTERNAL;

FUNCTION AwakeXMDL(xmdl: Handle; doIt: BOOLEAN): BOOLEAN; C; EXTERNAL;

{ *********************************************************************************** }
{ *											TPlotWindow																									* }
{ *********************************************************************************** }
{$S AOpen}

PROCEDURE TPlotWindow.IRes(itsDocument: TDocument; itsSuperView: TView;
			VAR itsParams: Ptr);	OVERRIDE;

VAR nOfSubjects:						INTEGER;
BEGIN
	INHERITED IRes(itsDocument, itsSuperView, itsParams);
	fEasyFitDocument	:= TEasyFitDocument(itsDocument);

	nOfSubjects := GetNumberOfPages;
	IF nOfSubjects = 0 THEN
		fSubject := 0		{�this means no subject get displayed }
	ELSE
		fSubject := 1;
END;

{ ----------------------------------------------------------------------------------- }
{$S AOpen}

PROCEDURE TPlotWindow.IPlotWindow;
VAR s:											Str255;
		aDataAndFuncPlotView:		TDataAndFuncPlotView;
		aStaticText:						TStaticText;
		aScrollBar:							TScrollBar;
		aPlotPrintView:					TPlotPrintView;
		
BEGIN
	aStaticText := TStaticText(FindSubview('info'));
	fInfoView := aStaticText;

	aScrollBar := TScrollBar(FindSubview('scbr'));
	fScBarView := aScrollBar;

	aDataAndFuncPlotView := TDataAndFuncPlotView(FindSubview('plot'));
	fPlotView := aDataAndFuncPlotView;
	
	aPlotPrintView := TPlotPrintView(FindSubview('prnt'));
	fPrintView := aPlotPrintView;
	
	IF fSubject <> 0 THEN BEGIN
		NumToString(fSubject, s);
		fInfoView.SetText(Concat('Subject ', s), kDontRedraw);	{�I should use a resource ! }
	END;
	
	fScBarView.SetLongMax(GetNumberOfPages, kDontRedraw);
	fScBarView.SetLongMin(fSubject, kDontRedraw);
	fScBarView.SetLongVal(fSubject, kDontRedraw);
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TPlotWindow.DoChoice(origView: TView; itsChoice: INTEGER); OVERRIDE;
VAR theScrollBar:			TScrollBar;
		aButton:					TButton;
		originalSubject:	INTEGER;
BEGIN
	theScrollBar := TScrollBar(FindSubView('scbr'));
	IF origView = theScrollBar THEN BEGIN
		originalSubject := fSubject;
		fSubject := theScrollBar.GetLongVal;
		IF originalSubject <> fSubject THEN BEGIN
			fInfoView.ForceRedraw;
			fPlotView.ForceRedraw;
		END;
	END;
	
	aButton := TButton(FindSubView('xpr1'));
	IF (origView = aButton) & (NOT gWorking) THEN
		fPlotView.ExportData( {all subjects:}�FALSE);

	aButton := TButton(FindSubView('xpra'));
	IF (origView = aButton) & (NOT gWorking) THEN
		fPlotView.ExportData( {all subjects:}�TRUE);

	INHERITED DoChoice(origView, itsChoice);
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TPlotWindow.MakeDialog;
BEGIN
	fPlotView.MakeDialog;
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TPlotWindow.Draw(area: Rect); OVERRIDE;
BEGIN
	{�When the window was created the expdata table was empty; but now it
		could have been filled.  So we check it out. }
		
	IF (fSubject = 0) & (GetNumberOfPages > 0) THEN BEGIN
		fSubject := 1;
		fInfoView.SetText('Subject 1', kDontRedraw);

		fScBarView.SetLongMin(1, kDontRedraw);
		fScBarView.SetLongVal(1, kDontRedraw);
	END;
	
	INHERITED Draw(area);
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

{�We force here to always have a subject displayed. Before, the idea was
	to write "no subjects" in the info field, and not to display anything.
	The problem was that maybe the user wanted to simulate a model,
	without having to input fake "experimental data" }
	
FUNCTION TPlotWindow.GetNumberOfPages: INTEGER;
VAR aRect: Rect;
BEGIN
	fEasyFitDocument.fExpDataTable.GetInUseBounds(aRect);
	
	{ We subtract 1 to because of the X column }
	
	IF aRect.Right < 2 THEN	
		GetNumberOfPages := 1		{�Force believing that there is one subject }
	ELSE
		GetNumberOfPages := aRect.right - 1;
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

{
	Used mainly for didactical or demo purposes. If the subject doesn't change,
	redraw the plotView only.
}
PROCEDURE TPlotWindow.ShowSubject(subject: INTEGER; redraw: BOOLEAN);
VAR QDExtent: Rect;
BEGIN
	{$IFC qDebug}
	IF subject <= 0 THEN
		ProgramBreak('TPlotWindow.ShowSubject: null or negative subject');
	{$ENDC}
	
	IF subject <> fSubject THEN BEGIN
	
		{�Change scroll bar settings }
		fSubject := subject;
		IF subject > fScBarView.GetLongMax THEN
			fScBarView.SetLongMax(subject, kDontRedraw);
		fScBarView.SetLongVal(subject, kDontRedraw);
		
		{�Redraw scroll bar & info view }
		IF redraw THEN BEGIN
			fInfoView.ForceRedraw;				{�redraw the info view field }
			IF fScBarView.Focus & fScBarView.IsVisible THEN BEGIN
				fScBarView.GetQDExtent(QDExtent);	{ Redraw the scroll bar without flickering }
				fScBarView.Draw(QDExtent);
			END;
		END;
	END;
	
	IF redraw THEN
		fPlotView.ForceRedraw;
END;			{�ShowSubject }

{ ----------------------------------------------------------------------------------- }
{$S AFields}

PROCEDURE TPlotWindow.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
											fieldType: INTEGER)); OVERRIDE;
BEGIN
	DoToField('TPlotWindow', NIL, bClass);
	DoToField('fEasyFitDocument', @fEasyFitDocument, bObject);
	DoToField('fSubject', @fSubject, bInteger);
	DoToField('fInfoView', @fInfoView, bObject);
	DoToField('fScBarView', @fScBarView, bObject);
	DoToField('fPlotView', @fPlotView, bObject);
	
	INHERITED Fields(DoToField);
END;

{ ----------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE TPlotWindow.DoSetupMenus; OVERRIDE;
BEGIN
	INHERITED DoSetupMenus;
	
	Enable(cPrintAll, NOT gWorking);
END;

{ ----------------------------------------------------------------------------------- }
{$S ASelCommand}
			
FUNCTION TPlotWindow.DoMenuCommand(aCmdNumber: cmdNumber): TCommand; OVERRIDE;

	PROCEDURE PrintAllPlots;
	VAR saveDisplayedSubject: INTEGER;
			i: INTEGER;
			proceed: BOOLEAN;
	BEGIN
		{ We save the content of the fSubject field, then we make the view
			to show each subject in turn. }
		saveDisplayedSubject := fSubject;
		FOR i := 1 TO fEasyFitDocument.fDataAndFuncPlotWindow.GetNumberOfPages DO BEGIN
			ShowSubject(i, kDontRedraw);
			
			{�Discard the returned value from Print (it's meaningless anyway) }
			IF fPrintView.fPrintHandler.Print(cPrintAll, proceed) <> NIL
			THEN;
	
			IF NOT proceed THEN BEGIN
				ShowSubject(saveDisplayedSubject, kDontRedraw);
				EXIT(PrintAllPlots);
			END;
		END;
		ShowSubject(saveDisplayedSubject, kDontRedraw);
	END;
	
BEGIN
	IF aCmdNumber = cPrintAll THEN BEGIN
		fPrintView.fPrintHandler.CheckPrinter;
		IF TStdPrintHandler(fPrintView.fPrintHandler).PoseJobDialog THEN
			PrintAllPlots;
		DoMenuCommand := gNoChanges;
	END
	ELSE
		DoMenuCommand := INHERITED DoMenuCommand(aCmdNumber);
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

{�Use to set up the scroll bar correctly }
PROCEDURE TPlotWindow.NumberOfPagesHasChanged(redraw: BOOLEAN);
VAR
	nOfPages: INTEGER;
BEGIN
	nOfPages := GetNumberOfPages;
	fScBarView.SetLongMax(nOfPages, redraw);
	IF fSubject > nOfPages THEN BEGIN
		fSubject := nOfPages;
		fScBarView.SetLongMin(nOfPages, redraw);
		fScBarView.SetLongVal(nOfPages, redraw);
		IF redraw THEN
			ForceRedraw;
	END
	ELSE IF (fSubject < 1) & (nOfPages > 0) THEN BEGIN
		fSubject := 1;
		fScBarView.SetLongMin(1, redraw);
		fScBarView.SetLongVal(1, redraw);
		IF redraw THEN
			ForceRedraw;
	END;
END;

{ *********************************************************************************** }
{ *											TDataAndFuncPlotView																				* }
{ *********************************************************************************** }
{$S AOpen}

{ We could optimize drawing speed if we put here the computation of
	fHorSpace, fPlotRect and so on.  We would need to call GetGrafPort
	to get the drawing port, set its font to applFont, then compute the quantities.
	But I'm not much sure about how safe it is to call getgrafptr while the
	window isn't shown yet.  So for the moment we do these computations every
	time we need to draw. }

PROCEDURE TDataAndFuncPlotView.IRes(itsDocument: TDocument; itsSuperView: TView;
																		VAR itsParams: Ptr);	OVERRIDE;

CONST kDefaultDomainOption =		autoSubjectBySubject;
			kDefaultSemilogOption =		TRUE;
			kDefaultPlotFastOption =	TRUE;
			kDefaultIntervals =				5;
			kDefaultNumSmallTicks =		9;

VAR		r: Rect;
		
BEGIN
	INHERITED IRes(itsDocument, itsSuperView, itsParams);
	
	fPlotWindow := TPlotWindow(GetWindow);
	fEasyFitDocument := TEasyFitDocument(itsDocument);
	
	{�We assume the ExpDataTable to be already allocated !! }
	fExpDataTable := fEasyFitDocument.fExpDataTable;
	
	{�Computa l'estensione della view }
	SetRect(r, 0, 0, ord(fSize.h), ord(fSize.v));
	fExtent := r;

	{�Set defaults for the various options }
	fSemilog := kDefaultSemilogOption;
	fPlotFast := kDefaultPlotFastOption;
	fXIntervals := kDefaultIntervals;
	fYIntervals := kDefaultIntervals;
	fDomainOption := kDefaultDomainOption;
	fNumSmallTicks := kDefaultNumSmallTicks;
	
	fDomain.dLeft := 0.0;
	fDomain.dTop := 0.0;
	fDomain.dRight := 0.0;
	fDomain.dBottom := 0.0;
	
	{$IFC FALSE}
	
	{ stuff we could use to compute here fhorSpace etc. }
	
					ourPort := GetGrafPort;
					{$IFC qDebug}
					IF ourPort = NIL THEN BEGIN
						ProgramBreak('TDataAndFuncPlotWind: wasn''t able to get ourPort');
						FailNIL(ourPort);
					END;
					{$ENDC}
					SetPort(ourPort);
	{$ENDC}
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

FUNCTION TDataAndFuncPlotView.ComputeSteps: INTEGER;
BEGIN
	IF fPlotFast THEN
		ComputeSteps := fSize.h DIV 4
	ELSE
		ComputeSteps := fSize.h;
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

{�Calcola fPlotRect, basandosi su fFontAscent, fFontDescent, fHorSpace che devono
	avere gia' i valori giusti. }

PROCEDURE TDataAndFuncPlotView.ComputePlotRect;
VAR derefPlotRect: Rect;
BEGIN
	SetRect(derefPlotRect, 0, 0, ord(fSize.h), ord(fSize.v));
	WITH derefPlotRect DO BEGIN
	
		{�sottraiamo lo spazio verticale ingombrato dall'indicazione 
			in alto a sinistra. Ricorda che per abbassare un punto
			la sua coordinata Y deve aumentare. }
		top := top + fFontAscent DIV 2;
		
		{ restringiamo dal basso per fare posto alle scritte in 
			basso. }
		bottom := bottom - fFontAscent + fFontDescent - kBorder;
		
		{ facciamo spazio a sinistra. }
		left := left + fHorSpace;
		
		{ facciamo spazio a destra }
		right := right - fHorSpace DIV 2;
	END; 		{�with }

	fPlotRect := derefPlotRect;
END;

{ ----------------------------------------------------------------------------------- }
{$S MANonRes}

PROCEDURE TDataAndFuncPlotView.Resize(width, height: VCoordinate; 
			invalidate: BOOLEAN); OVERRIDE;
VAR r: Rect;
BEGIN
	ForceRedraw;	{ ??? needed ??? }
	INHERITED Resize(width, height, FALSE);
	ForceRedraw;	{ Force to redraw everything }
	
	{�Recompute a few things }
	SetRect(r, 0, 0, ord(fSize.h), ord(fSize.v));
	fExtent := r;
	ComputePlotRect;
END;			
			
{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs }

PROCEDURE TDataAndFuncPlotView.PlotTheData;
{ 
	Chiama una procedura C che disegna il grafico dei punti
	sperimentali 
}	
VAR	derefXmin,
		derefXMax,
		derefYMin,
		derefYMax: extended;
		derefPlotrect: Rect;
	
		{ (f_x, f_y) e' il punto sperimentale da plottare }
		f_x,
		f_y: Extended;
		
		{�indice della riga nella tabella dei dati sperimentali }
		row: integer;
		
		{ TRUE se valore della colonna dei tempi e' missing.
			In generale i valori della colonna dei tempi non 
			dovrebbero essere missing; tuttavia puo' capitare che
			lo siano se l'utente apre la finestra grafica prima di
			avere fatto il fitting }
		missingTime: boolean;
		
		{ TRUE se una certa osservazione e' missing }
		missingObservation: boolean;
		
		nRows: integer;
		
		theSubject: INTEGER;

BEGIN		{ PlotTheData }
	derefXmin := fDomain.dLeft; 
	derefXMax := fDomain.dRight; 
	derefYMin := fDomain.dBottom; 
	derefYMax := fDomain.dTop;
	derefPlotRect := fPlotRect;
	
	theSubject := GetCurrentSubject;
	
	IF theSubject = 0 THEN
		Exit(PlotTheData);
	
	nRows := GetNumberOfPoints;
	With derefPlotRect do
		for row := 1 to nRows do begin
		
			{�estrai dalla finestra dei dati un punto sperimentale;
				f_x lo troviamo nella colonna dei tempi, cioe' la
				0-esima. }
			
			GetX(f_x, row);
			missingTime := ClassExtended(f_x) = QNan;
			
			{ f_y invece lo troviamo alla colonna che corrisponde
				al soggetto che stiamo plottando;  quale sia questo 
				soggetto viene ricordato dal valore dello scroll bar }
			
			GetY(f_y, row);
			missingObservation := ClassExtended(f_y) = QNan;
			
			IF { ne' f_x ne' f_y sono missing }
				 ((NOT missingObservation) AND (NOT missingTime))
				 
				 AND {�il punto non e' fuori dal dominio }
				 ((f_x >= derefXMin) AND (f_x <= derefXMax) 
						AND 						
					(f_y >= derefYMin) AND (f_y <= derefYMax))
			THEN
				IF fSemilog & (f_y > 0.0) THEN
					PlotSemilogPoint(left, 
													 right, 
													 bottom, 
													 top,
													 derefXMin, 
													 derefXMax, 
													 derefYMin, 
													 derefYMax,
													 f_x, 
													 f_y)
				ELSE
					PlotPoint(left, 
										right, 
										bottom, 
										top,
										derefXMin, 
										derefXMax, 
										derefYMin, 
										derefYMax,
										f_x, 
										f_y);
									
		END;		{ for }
END;				{ PlotTheData }

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs }

PROCEDURE TDataAndFuncPlotView.PlotTheFunction;
LABEL
	99;
VAR
	derefXMin, 
	derefXMax, 
	derefYMin, 
	derefYMax:				Extended;
	derefPlotRect:		Rect;
	theFunc:					ProcPtr;
	workVector:				PExtended;
	NParams:					INTEGER;
	NParamWindowRows:	INTEGER;
	theSubject:				INTEGER;
	i:								INTEGER;
	saveWorkingDialog:	TWorkingDialog;
	fi:								FailInfo;
	{$IFC qXMDLs}
	oldXMDLState:			BOOLEAN;
	{$ENDC}
	{$IFC qDebug}
	s1:								MAName;
	s2:								Str255;
	{$ENDC}
		
		PROCEDURE plotTheFuncErrHdl(error: OSErr; message: LONGINT);
		BEGIN
			pWorkingDialog := saveWorkingDialog;
			gApplication.ShowError(error, message);
			GOTO 99;
		END;
		
BEGIN		{ PlotTheFunction }
	derefXmin := fDomain.dLeft; 
	derefXMax := fDomain.dRight; 
	derefYMin := fDomain.dBottom; 
	derefYMax := fDomain.dTop;
	derefPlotRect := fPlotRect;
	
	{ 16/2/90: we used to fetch the number of params from the Get_NOfParams function.
		Alas, later ColumnToArray would corrupt the heap whenever we had more rows in the 
		params window than the model has parameters.  Now it should be safe. 
		20/12/90: we now do both things, and allocate the vector to be
			big enough for any case. Now we can be initialize to NAN the vector
			if the parameter windows contains less rows than parameters. }
			
	NParams := get_NumberOfParams(fEasyFitDocument.fModelNumber);
	NParamWindowRows := fEasyFitDocument.fParamsTable.fInUseBounds.bottom;
	
	workVector := PExtended(NewPermPtr(MAX(NParamWindowRows, NParams) * SIZEOF(EXTENDED)));
	FailNil(workVector);
	
	theFunc := get_ModelFunc(fEasyFitDocument.fModelNumber);
	
	{$IFC qXMDLs}
	IF fEasyFitDocument.fModelNumber = kXMDL THEN
		oldXMDLState := AwakeXMDL(gXMDL, TRUE);
	{$ENDC}
	
	IF Focus THEN;

	{ limita la clip region della finestra al solo plotRect.
		Altrimenti la funzione rischia di essere disegnata anche
		sullo scroll bar !!! }
	ClipFurtherTo(derefPlotRect, 0, 0);
	
	theSubject := GetCurrentSubject;
	IF theSubject > 0 THEN BEGIN
		fEasyFitDocument.fParamsTable.ColumnToArray(theSubject, workVector);

		{ We set up this global that will be used in interpret().
			We convert the subject number to extended once and for all.
			I didn't want the conversion to happen every time we called
			interpret(). }
		gExtendedCurrentSubject := theSubject;

		{ Get the dose (it may be needed by an user model, so we need to
			put the value in this global _before_ calling fit(). ) }
		fEasyFitDocument.fDosesTable.GetDose(theSubject, gDose);
		
		{�Initialize to NAN the vector positions that may be left
			uninitialized because the Params Window didn't contain enough rows. }
		IF NParamWindowRows < NParams THEN
			FOR i := NParamWindowRows + 1 TO NParams DO
				SetIthElement(workVector, i-1, Nan(38));
	
		{�Stop polling events until we're done with plotting the function. This
			is done setting pWorkingDialog to NIL. }
		CatchFailures(fi, plotTheFuncErrHdl);
		saveWorkingDialog := pWorkingDialog;
		pWorkingDialog := NIL;
		
		{$IFC qDebug}
		gFocusedView.GetClassName(s1);
		gFocusedView.GetInspectorName(s2);
		Writeln('PlottheFunction: Focus is on view ', s1, ' ; ', s2);
		{$ENDC}
		
		WITH derefPlotRect DO
			if fSemilog then
				PlotSemilogFunction(left, 
														right, 
														bottom, 
														top,
														derefXMin, 
														derefXMax, 
														derefYMin, 
														derefYMax,
														ComputeSteps,
														theFunc,
														workVector)
			else
				PlotFunction(left, right, bottom, top,
										 derefXMin, derefXMax, derefYMin, derefYMax,
										 ComputeSteps,
										 theFunc,
										 workVector);
		
		{ Restore pWorkingDialog }
		pWorkingDialog := saveWorkingDialog;
		Success(fi);
	END;	{�If subject > 0 }
99:		
	{$IFC qXMDLs}
	IF fEasyFitDocument.fModelNumber = kXMDL THEN
		IF AwakeXMDL(gXMDL, oldXMDLState) THEN;
	{$ENDC}
	
	DisposPtr(Ptr(workVector));
END;		{ PlotTheFunction }

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

{�This procedure first shows the std dialog to write a file; if the 
	user doesn't cancel, we open a file and then write data in it. }
	
PROCEDURE TDataAndFuncPlotView.ExportData(allSubjects: BOOLEAN);
TYPE
	GoodOrBad = (good, bad);
VAR
	dismisser:			IDType;
	
		{ The format of the data is the usual tabular format: numbers separated
			by tabs and newlines.
			The first column is the independent variable; subsequent columns
			are Ycomputed and Yobserved for each subject:
				X		Ycomputed1	Yobserved1	Ycomputed2	Yobserved2 ... }
	
	FUNCTION CallModel(f: ProcPtr; p: PExtended; x: EXTENDED): EXTENDED; C; EXTERNAL;
		
	PROCEDURE DoWriteDataAllSubjects(fileRefNumber: INTEGER);
	CONST
		numOfPoints = 100;
	TYPE
		IntArray = ARRAY[1..kMaxSubjects] OF INTEGER;
		PIntArray = ^IntArray;
	VAR
		domainLeft:						EXTENDED;			{�Dereferencing the domain }
		domainRight:					EXTENDED;
		theFunc:							ProcPtr;			{�Pointer to the model function }
		originalSubject:			INTEGER;			{�subject originally displayed }
		i:										INTEGER;			{ for loop index }
		delta:								EXTENDED;			{�sampling interval on the X axis }
		Xi:										EXTENDED;			{�current position on the X axis }
		nObservations:				INTEGER;			{�number of observations }
		currentObservNumber:	INTEGER;
		nextObservationAt:		EXTENDED;			{ position on the X axis of the next observation }
			
		PROCEDURE WriteComputedValuesOnly;
		VAR
			theSubject:						INTEGER;			{ cursor over subjects }
			Yi:										EXTENDED;			{�current model value at Xi }
		BEGIN
			FOR theSubject := 1 TO GetNumberOfPages DO BEGIN
				fPlotWindow.ShowSubject(theSubject, kDontRedraw);
				fEasyFitDocument.fParamsTable.ColumnToArray(theSubject, @gParams);
				
				Yi := CallModel(theFunc, @gParams, Xi);
				WriteChar		(fileRefNumber, chTab);
				WriteNumber	(fileRefNumber, Yi);
				WriteChar		(fileRefNumber, chTab);
			END;
		END;		{�WriteComputedValuesOnly }
		
		PROCEDURE WriteObservedValuesOnly;
		VAR
			theSubject:						INTEGER;			{ cursor over subjects }
			observedValue:				EXTENDED;
		BEGIN
			FOR theSubject := 1 TO GetNumberOfPages DO BEGIN
				fPlotWindow.ShowSubject(theSubject, kDontRedraw);
				
				SELF.GetY(observedValue, currentObservNumber);
				WriteChar		(fileRefNumber, chTab);
				WriteChar		(fileRefNumber, chTab);
				WriteNumber	(fileRefNumber, observedValue);
			END;
		END;		{�WriteObservedValuesOnly }
		
		PROCEDURE WriteComputedAndObservedValues;
		VAR
			theSubject:						INTEGER;			{ cursor over subjects }
			Yi:										EXTENDED;			{�current model value at Xi }
			observedValue:				EXTENDED;
		BEGIN
			FOR theSubject := 1 TO GetNumberOfPages DO BEGIN
				fPlotWindow.ShowSubject(theSubject, kDontRedraw);
				fEasyFitDocument.fParamsTable.ColumnToArray(theSubject, @gParams);
				
				Yi := CallModel(theFunc, @gParams, Xi);
				SELF.GetY(observedValue, currentObservNumber);
	
				WriteChar		(fileRefNumber, chTab);
				WriteNumber	(fileRefNumber, Yi);
				WriteChar		(fileRefNumber, chTab);
				WriteNumber	(fileRefNumber, observedValue);
			END;
		END;		{�WriteComputedAndObservedValues }
		
	
	BEGIN
		originalSubject := GetCurrentSubject;
		domainLeft := fDomain.dLeft;
		domainRight := fDomain.dRight;
		delta := (domainRight - domainLeft) / numOfPoints;
		Xi := domainLeft - delta;
		theFunc := get_ModelFunc(fEasyFitDocument.fModelNumber);
	
		nObservations := SELF.GetNumberOfPoints;
		currentObservNumber := 1;
		SELF.GetX(nextObservationAt, 1);
	
		FOR i := 1 TO numOfPoints + 1 DO BEGIN
			Xi := Xi + delta;
			
			IF nextObservationAt = Xi THEN BEGIN
				{�Write observations and computed values on the same line }
				WriteNumber	(fileRefNumber, Xi);
				WriteComputedAndObservedValues;
				WriteChar		(fileRefNumber, chReturn);
				currentObservNumber := currentObservNumber + 1;
				IF currentObservNumber > fExpDataTable.fInUseBounds.Bottom THEN
					nextObservationAt := Nan(038) {�Signal there are no more points }
				ELSE
					SELF.GetX(nextObservationAt, currentObservNumber);
			END
			ELSE IF nextObservationAt < Xi THEN BEGIN
				{�Write observations and computed values on two separated lines }
				WriteNumber	(fileRefNumber, nextObservationAt);
				WriteObservedValuesOnly;
				WriteChar		(fileRefNumber, chReturn);
				WriteNumber	(fileRefNumber, Xi);
				WriteComputedValuesOnly;
				WriteChar		(fileRefNumber, chReturn);
				currentObservNumber := currentObservNumber + 1;
				IF currentObservNumber > fExpDataTable.fInUseBounds.Bottom THEN
					nextObservationAt := Nan(038) {�Signal there are no more points }
				ELSE
					SELF.GetX(nextObservationAt, currentObservNumber);
			END
			ELSE BEGIN
				{�Write computed values only }
				WriteNumber	(fileRefNumber, Xi);
				WriteComputedValuesOnly;
				WriteChar		(fileRefNumber, chReturn);
			END;		{�else }
		END;			{�for }
	
		{�Fix to loss of precision problem: adding deltas may sum up to less then it
			should. }
		IF (Xi < domainRight) & 
			 (nextObservationAt > Xi) & (nextObservationAt <= domainRight)
		THEN BEGIN
				WriteNumber	(fileRefNumber, nextObservationAt);
				WriteObservedValuesOnly;
				WriteChar		(fileRefNumber, chReturn);	
		END;
	
		fPlotWindow.ShowSubject(originalSubject, kDontRedraw);
	END;				{�DoWriteDataAllSubjects }
	
	{�The format of the data is the usual tabular format: numbers separated
		by tabs and newlines.
		The data we write on it are three columns: 
			X		Ycomputed		Yobserved
		Where X and Ycomputed are sampled often enough to allow a good
		graph of the function on common graphic packages. }
	
	PROCEDURE DoWriteDataOneSubject(fileRefNumber: INTEGER);
	CONST numOfPoints = 100;
	VAR domainLeft,
			domainRight:				EXTENDED;
			i:									INTEGER;
			delta:							EXTENDED;
			Xi,
			Yi:									EXTENDED;
			nObservations:			INTEGER;
			nextObservationAt:	EXTENDED;
			observValue:				EXTENDED;
			currentObservNumber: INTEGER;
			theSubject:					INTEGER;
			theFunc:						ProcPtr;
	
	BEGIN
		domainLeft := fDomain.dLeft;
		domainRight := fDomain.dRight;
		delta := (domainRight - domainLeft) / numOfPoints;
		Xi := domainLeft - delta;
		theFunc := get_ModelFunc(fEasyFitDocument.fModelNumber);
		theSubject := SELF.GetCurrentSubject;
		fEasyFitDocument.fParamsTable.ColumnToArray(theSubject, @gParams);
		nObservations := SELF.GetNumberOfPoints;
		currentObservNumber := 1;
		SELF.GetX(nextObservationAt, 1);
		SELF.GetY(observValue, 1);
	
		FOR i := 1 TO numOfPoints + 1 DO BEGIN
			Xi := Xi + delta;
			Yi := CallModel(theFunc, @gParams, Xi);
			
			IF nextObservationAt = Xi THEN BEGIN
				{�Write observation and computed value on the same line }
				WriteNumber	(fileRefNumber, Xi);
				WriteChar		(fileRefNumber, chTab);
				WriteNumber	(fileRefNumber, Yi);
				WriteChar		(fileRefNumber, chTab);	
				WriteNumber	(fileRefNumber, observValue);
				WriteChar		(fileRefNumber, chReturn);
				
				currentObservNumber := currentObservNumber + 1;
				IF currentObservNumber > fExpDataTable.fInUseBounds.Bottom THEN
					nextObservationAt := Nan(038) {�Signal there are no more points }
				ELSE BEGIN
					SELF.GetX(nextObservationAt, currentObservNumber);
					SELF.GetY(observValue, currentObservNumber);
				END
			END
			ELSE IF nextObservationAt < Xi THEN BEGIN
				{�Write observation and computed value on two separated lines }
				WriteNumber	(fileRefNumber, nextObservationAt);
				WriteChar		(fileRefNumber, chTab);
				WriteChar		(fileRefNumber, chTab);	
				WriteNumber	(fileRefNumber, observValue);
				WriteChar		(fileRefNumber, chReturn);
				WriteNumber	(fileRefNumber, Xi);
				WriteChar		(fileRefNumber, chTab);
				WriteNumber	(fileRefNumber, Yi);
				WriteChar		(fileRefNumber, chTab);	
				WriteChar		(fileRefNumber, chReturn);
		
				currentObservNumber := currentObservNumber + 1;
				IF currentObservNumber > fExpDataTable.fInUseBounds.Bottom THEN
					nextObservationAt := Nan(038) {�Signal there are no more points }
				ELSE BEGIN
					SELF.GetX(nextObservationAt, currentObservNumber);
					SELF.GetY(observValue, currentObservNumber);
				END
			END
			ELSE BEGIN
				{�Write computed value only }
				WriteNumber	(fileRefNumber, Xi);
				WriteChar		(fileRefNumber, chTab);
				WriteNumber	(fileRefNumber, Yi);
				WriteChar		(fileRefNumber, chTab);	
				WriteChar		(fileRefNumber, chReturn);
			END;
		END;
		
		{�Fix to loss of precision problem: adding deltas may sum up to less then it
			should. }
		IF (Xi < domainRight) & 
			 (nextObservationAt > Xi) & (nextObservationAt <= domainRight)
		THEN BEGIN
				WriteNumber	(fileRefNumber, nextObservationAt);
				WriteChar		(fileRefNumber, chTab);
				WriteChar		(fileRefNumber, chTab);	
				WriteNumber	(fileRefNumber, observValue);
				WriteChar		(fileRefNumber, chReturn);	
		END;
	END;
		
	FUNCTION AlertChangingDomainOption: GoodOrBad;
	CONST
		kAlertChangingDomainOption = 2002;
	VAR
		aWindow:			TWindow;
		dismisser:		IDType;
	BEGIN
		aWindow := NewTemplateWindow(kAlertChangingDomainOption, NIL);
		FailNil(aWindow);
		
		dismisser := TDialogView(aWindow.FindSubView('dlog')).PoseModally;
		IF dismisser = 'ok  ' THEN
			AlertChangingDomainOption := good
		ELSE
			AlertChangingDomainOption := bad;
		
		aWindow.Close;
	END;
	
BEGIN
	IF GetCurrentSubject = 0 THEN
		Exit(ExportData);
	
	IF allSubjects THEN BEGIN
		fExpDataTable.CompressInUseBounds;
		fPlotWindow.NumberOfPagesHasChanged(kRedraw);
		IF GetNumberOfPages < 1 THEN
			Exit(ExportData);

		{�We need to make sure that all subjects are computed over the same domain.
			So if the domain option is autoSubjectBySubject, we ask the user
			if it is OK to change it. }
		IF (fDomainOption = autoSubjectBySubject) & (GetNumberOfPages > 1) THEN BEGIN
			IF AlertChangingDomainOption = good THEN BEGIN
				fDomainOption := autoOverAllSubjects;
				ForceRedraw;
			END
			ELSE
				Exit(ExportData);
		END;
	END;

	{�Write the data to it }
	IF allSubjects & (GetNumberOfPages > 1) THEN BEGIN
		IF WriteInOpenFile('Export data in�', 'EasyFit data', 'TEXT', kTextCreator,
					 { mustUpdateWindows: } TRUE, DoWriteDataAllSubjects) THEN;
	END
	ELSE
		IF WriteInOpenFile('Export data in�', 'EasyFit data', 'TEXT', kTextCreator,
					 { mustUpdateWindows: } TRUE, DoWriteDataOneSubject) THEN;
END;

{ --------------------------------------------------------------------------------- }
{$S GrafWindObjs }

PROCEDURE TDataAndFuncPlotView.DrawXTicks;
VAR
	i							: integer;
	deltaDomain,
	deltaScreen,
	tmpDomain,
	tmpScreen			: Extended;
	s							: Str255;
	derefPlotRect : Rect;
BEGIN
	derefPlotRect := fPlotRect;
	
	WITH derefPlotRect DO BEGIN
	
		{ disegna le suddivisioni sull' asse X; analogo a 
			drawLinearYTicks,
			solo che qui partiamo da sinistra e andiamo a destra. }
		tmpScreen := left;
		deltaScreen := (right - left) / fXIntervals;
		
		tmpDomain := fDomain.dLeft;
		deltaDomain := (fDomain.dRight - fDomain.dLeft) / fXIntervals;
		
		{ disegna la prima indicazione, quella sull' incrocio degli
			assi. }
		Num2NiceStr(tmpDomain, s, kSmallPrecision);
		MoveTo(round(tmpScreen) - StringWidth(s) DIV 2, 
					 fExtent.bottom);
		DrawString(s);
		
		for i := 1 to fXIntervals do begin
			tmpScreen := tmpScreen + deltaScreen;
			tmpDomain := tmpDomain + deltaDomain;
			
			{ disegna la tacchetta }
			DrawLargeXTick(round(tmpScreen), bottom);
			
			{ disegna l'indicazione }
			Num2NiceStr(tmpDomain, s, kSmallPrecision);
			MoveTo(round(tmpScreen) - StringWidth(s) DIV 2, 
						 fExtent.bottom);
			DrawString(s);
		end;				{ for }
	END;					{�with }
END;						{�DrawXTicks }

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs }

PROCEDURE TDataAndFuncPlotView.DrawYTicks;
VAR
	i							: integer;
	deltaDomain,
	deltaScreen,
	tmpDomain,
	tmpScreen			: Extended;
	s							: Str255;
	derefDomain		: domainType;
	derefPlotRect	: Rect;	
BEGIN
	derefDomain := fDomain;
	derefPlotRect := fPlotRect;
	
	WITH derefPlotRect, derefDomain DO BEGIN
		{ disegna le suddivisioni e le indicazioni sull' asse Y; 
			la variabile "tmpDomain" e' di tipo extended per non
			perdere gli arrotondamenti.
			
			Per l'asse Y partiamo dall' alto e scendiamo. }
			
		tmpScreen := top;
		deltaScreen := (bottom - top) / fYIntervals;
		
		tmpDomain := dTop;
		deltaDomain := (dTop - dBottom) / fYIntervals;
		
		for i := 1 to fYIntervals do begin
		
			{�disegna la tacchetta }
			DrawLargeYTick(left, round(tmpScreen));
				
			{�disegna l'indicazione }
			Num2NiceStr(tmpDomain, s, kSmallPrecision);
			MoveTo(fPlotRect.left - StringWidth(s) - kBorder, 
							 round(tmpScreen) + fFontAscent DIV 2);
			DrawString(s);
			
			{ disegna le tacche piu' piccole senza indicazioni }
			if fSemilog then
				PlotSemilogSmallTicks(left,
															round(tmpScreen + deltaScreen),
															round(tmpScreen),
															tmpDomain / 10.0,
															tmpDomain,
															fNumSmallTicks);
		
			{ incrementiamo le var temporanee; va ricordato che 
				mentre crescono le coordinate dello schermo,
				calano quelle del dominio !!! }
			if fSemilog then
				tmpDomain := tmpDomain / 10.0
			else
				tmpDomain := tmpDomain - deltaDomain;
			tmpScreen := tmpScreen + deltaScreen;
		end;
		
		{�l'ultima tacchetta non ha bisogno di essere disegnata
			perche' si sovrapporrebbe all' asse X;
			l'indicazione pero' deve essere disegnata.  Questo
			e' idealmente l'ultimo passo del loop precedente, solo
			che non disegna la tacchetta per ottimizzare la velocita'.}
		Num2NiceStr(tmpDomain, s, kSmallPrecision);
		MoveTo(fPlotRect.left - StringWidth(s) - kBorder, 
						 round(tmpScreen));
		DrawString(s);
	END;			{ with }
END;				{�DrawYTicks }

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs }

PROCEDURE TDataAndFuncPlotView.DrawAxis;
{
	DrawAxis disegna gli assi con le suddivisioni nel rettangolo
	plotRect del grafport corrente.
	
	Inoltre disegna le indicazioni in corrispondenza delle 
	tacchette sugli assi.  Queste se ne stanno fuori dal 
	rettangolo "fPlotRect" ma dentro al rettangolo "fExtent".
	
	Dipende anche dai campi XInterval e YInterval di questo 
	oggetto.
}
VAR derefPlotRect: Rect;
BEGIN						{�DrawAxis }
	derefPlotRect := fPlotRect;
	WITH derefPlotRect DO BEGIN
		{�disegna gli assi veri e propri }
		MoveTo(left, top);
		LineTo(left, bottom);
		LineTo(right, bottom);
	END;					{ with }	
		
	DrawYTicks;
	DrawXTicks;
END;						{�DrawAxis }

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs }

{ DerefGrafRect e' l'estensione della view. DerefPlotRect e' un rettangolo 
	contenuto nel primo che esclude gli assi e le loro indicazioni }

PROCEDURE TDataAndFuncPlotView.Draw(area: Rect); OVERRIDE;
VAR derefGrafRect:	Rect;
		derefPlotRect:	Rect;
		fInfo:					FontInfo;
		s:							Str255;
		tmpInt:					INTEGER;
BEGIN
	ComputeDomain;
	
	IF fSemilog & ((fDomain.dBottom = 0) | (fDomain.dTop = 0)) THEN
		Exit(Draw);
	
	{ calcola alcune costanti del font }
	TextFont(applFont);
	GetFontInfo(fInfo);
	fFontAscent := fInfo.ascent;
	fFontDescent := fInfo.descent;
	
	{ Per calcolare "horSpace" assumiamo che la stringa piu'
		lunga producibile a sinistra sia simile a '0.12e-21'.
		Assumiamo anche che venga usata la procedura
		"Num2NiceStr" con precision = kSmallPrecision per produrre le 
		indicazioni. }
	Num2NiceStr(0.123456e-21, s, kSmallPrecision);
	
	{ uso una var temporanea perche' StringWidth puo' causare una
		rilocazione dello heap. }
	tmpInt := StringWidth(s);
	fHorSpace := tmpInt;
	
	ComputePlotRect;
	
	derefGrafRect := fExtent;
	derefPlotRect := fPlotRect;
	IF (GetNumberOfPages >= 1)							{�c'e' almeno un soggetto }
			& (fDomain.dBottom < fDomain.dTop)
			& (fDomain.dLeft < fDomain.dRight)
	THEN BEGIN		
		DrawAxis;
		PlotTheData;
		PlotTheFunction;
	END;				{ if there is at least one subject }
END;						{�TDataAndFuncPlot.Draw }

{ --------------------------------------------------------------------------------- }
{$S GrafWindObjs}

{ ComputeDomain - trova il dominio nella maniera preferita dall'utente. }

PROCEDURE TDataAndFuncPlotView.ComputeDomain;

	{�FattenDomain -- extend the size of the domain for esthetic reasons }
	PROCEDURE FattenDomain(VAR domain: DomainType; alsoY: BOOLEAN);
	VAR oldRoundDir:						RoundDir;
	BEGIN
		WITH domain DO BEGIN
			oldRoundDir := GetRound;
			
			IF alsoY THEN BEGIN
				SetRound(UpWard);
				dTop := Rint(dTop);
				dRight := Rint(dRight);
				SetRound(DownWard);
				dBottom := Rint(dBottom);
				dLeft := Rint(dLeft);
			END
			ELSE BEGIN
				SetRound(UpWard);
				dRight := Rint(dRight);
				SetRound(DownWard);
				dLeft := Rint(dLeft);
			END;
			
			SetRound(oldRoundDir);
		END;	{ with }
	END;		{�FattenDomain }
		
			{ AutoDomainSubjectBySubject - permette di settare il dominio 
				di default quando l'utente vuole il dominio calcolato automa-
				ticamente.  Si basa sul soggetto correntemente visualizzato
				sulla finestra.  }
				
	PROCEDURE AutoDomainSubjectBySubject(expand: boolean);
	VAR s:											Str255;
			derefDomain:						DomainType;
			
	BEGIN				{ AutoDomainSubjectBySubject }
		WITH derefDomain DO BEGIN
			GetMinX(dLeft);
			GetMaxX(dRight);
			GetMinY(dBottom, GetCurrentSubject);
			GetMaxY(dTop, GetCurrentSubject);
			
			{ Controlliamo che non ci siano dei missing }
			IF (ClassExtended(dLeft) = QNan) |
					(ClassExtended(dRight) = QNan)�|
					(ClassExtended(dBottom) = QNan) |
					(ClassExtended(dTop) = QNan)
			THEN BEGIN
				dLeft := 0.0;
				dRight := 0.0;
				dBottom := 0.0;
				dTop := 0.0;
			END
			ELSE
				FattenDomain(derefDomain, expand);
		END;				{ WITH }
		fDomain := derefDomain;
	END;					{ AutoDomainSubjectBySubject }


			{ AutoDomainAllSubjects - permette di settare il dominio di 
				default.  Calcola il dominio in modo che contenga
				tutti i dati di tutti i soggetti. 
				Il parametro boolean serve a specificare se si vuole che
				il dominio venga allargato per contenere i dati con piu' 
				larghezza; e' infatti indesiderabile quando si vuole
				un plot semilogaritmico. }
				
	PROCEDURE AutoDomainOverAllSubjects(expand: boolean);
	VAR
		s:							Str255;		{ Scratch string }
		col:						INTEGER;
		numCol:					INTEGER;
		tmp:						EXTENDED;
		derefDomain:		DomainType;
	
	BEGIN				{ AutoDomainOverAllSubjects }
		WITH derefDomain DO BEGIN
			numCol := GetNumberOfPages;

			if numCol >= 1 then begin

				{�inizializza il dominio }
				GetMinX(dLeft);
				GetMaxX(dRight);

				{ Controlliamo che non ci siano dei missing }
				IF (ClassExtended(dLeft) = QNan) |
					 (ClassExtended(dRight) = QNan) THEN BEGIN
					dLeft := 0.0;
					dRight := 0.0;
				END;
				
				{ inizializza il resto del dominio }
				GetMinY(dBottom, 1);
				GetMaxY(dTop, 1);
				
				{ e controlla anche qui per i missing }
				IF ClassExtended(dTop) = QNan THEN
					dTop := -Inf;
				IF ClassExtended(dBottom) = QNan THEN
					dBottom := Inf;

				{ ora va a vedere se c'e' bisogno di ingrandire il dominio per
					farci stare i dati degli altri soggetti }
				for col := 2 to numCol do begin
					GetMinY(tmp, col);
					if tmp < dBottom then 
						dBottom := tmp;
					
					GetMaxY(tmp, col);
					if tmp > dTop then 
						dTop := tmp;
				end;
				
				{ Ingrandisce un poco il dominio per motivi estetici }
				FattenDomain(derefDomain, expand);
				
				{ controlla se alla fine il dominio e' rimasto non inizializzato }
				IF (dTop = (-Inf)) | (dBottom = Inf) THEN BEGIN
					dBottom := 0.0;
					dTop := 0.0;
				END;
				
			END 			{ if }
			ELSE BEGIN
				{ non c'e' nemmeno un soggetto: dunque per evitare che nel
					dialog appaiano dei numeri non inizializzati, 
					mettiamo tutto a zero. }
				dLeft := 0.0;
				dRight := 0.0;
				dTop := 0.0;
				dBottom := 0.0;
			END;			{�else }
		END;				{�with }
		fDomain := derefDomain;
	END;					{ AutoDomainOverAllSubjects }
	

	{ AdjustForSemilog - Il grafico semilogaritmico richiede speciali precauzioni: 
		vogliamo che i limiti del dominio della Y coincidano con potenze di dieci.  }

	PROCEDURE AdjustForSemilog;
	VAR derefDomain:						DomainType;
	BEGIN
		{�Check for consistency: if we have null vertical domain limits,
			then we inhibit plotting by setting dBottom = dTop = 0. }
		IF (fDomain.dBottom <= 0.0) | (fDomain.dTop <= 0.0) THEN BEGIN
			fDomain.dBottom := 0.0;
			fDomain.dTop := 0.0;
			{ We don't change fYintervals }
		END
		ELSE BEGIN
			derefDomain := fDomain;
			WITH derefDomain DO BEGIN
				dBottom := PrevPowerOfTen(dBottom);
				dTop := NextPowerOfTen(dTop);
				fYIntervals := OrderOfMagnitudeDifference(dTop, dBottom);
			END;			{ with }
			fDomain := derefDomain;
		END;
	END;					{ AdjustForSemilog }
		
BEGIN					{�ComputeDomain }
	{�If there are no subjects in the data window, do nothing }
	IF GetNumberOfPages = 0 THEN
		EXIT(ComputeDomain);

	SetCursor(gWatchHdl^^);
	
	IF fDomainOption = autoSubjectBySubject THEN
		AutoDomainSubjectBySubject(not fSemilog)
	ELSE
	IF fDomainOption = autoOverAllSubjects THEN
		AutoDomainOverAllSubjects(not fSemilog);
	
	IF fSemilog THEN
		AdjustForSemilog;
END;				{ ComputeDomain }

{ --------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TDataAndFuncPlotView.MakeDialog;
CONST kDataAndFuncPlotOptionsDlog = 1110;
VAR theWindow:						TWindow;
		dismisser:						IDType;
		originalDomain:				DomainType;
		originalSemilog:			BOOLEAN;
		originalPlotFast:			BOOLEAN;
		originalDomainOption:	DomainOptionType;
		originalYIntervals:		INTEGER;

	PROCEDURE SetUp;
	VAR anExtended:			EXTENDED;
	BEGIN
		TCheckBox(pDialog.FindSubView('slog')).SetState(fSemilog, kDontRedraw);
		TCheckBox(pDialog.FindSubView('fast')).SetState(fPlotFast, kDontRedraw);
		
		EnableYTicks(NOT fSemilog);
		
		CASE fDomainOption OF
			autoSubjectBySubject:
				pAutoSubBySubRadio.SetState(TRUE, kDontRedraw);
			autoOverAllSubjects:
				pAutoOverAllSubRadio.SetState(TRUE, kDontRedraw);
			userDefined:
				TRadio(pDialog.FindSubView('udef')).SetState(TRUE, kDontRedraw);
		END;
		
		pDialog.SetUpDomain(fDomainOption);

		TNumberText(pDialog.FindSubView('xint')).SetValue(fXIntervals, kDontRedraw);
		TNumberText(pDialog.FindSubView('yint')).SetValue(fYIntervals, kDontRedraw);
	END;
	
	PROCEDURE CollectValues;
	VAR anExtended: EXTENDED;
	BEGIN
		{�Put the values in the appropriate variables }
		fSemilog := TCheckBox(pDialog.FindSubView('slog')).IsOn;
		fPlotFast := TCheckBox(pDialog.FindSubView('fast')).IsOn;
		
		IF pAutoSubBySubRadio.IsOn THEN
			fDomainOption := autoSubjectBySubject
		ELSE IF pAutoOverAllSubRadio.IsOn THEN
			fDomainOption := autoOverAllSubjects
		ELSE BEGIN
			fDomainOption := userDefined;
			
			{ We need to get the values of the domain from the fields in the dialog
				only in the "userDefined domain" case; otherwise we will compute
				the domain on our own as needed }
			GetDomain;
		END;

		fXIntervals := TNumberText(pDialog.FindSubView('xint')).GetValue;
		fYIntervals := pYTicksField.GetValue;
	END;

BEGIN
	FixEditMenu;
	theWindow := NewTemplateWindow(kDataAndFuncPlotOptionsDlog, NIL);
	FailNil(theWindow);

	{�Get a reference to the dialog view, for efficiency }
	pDialog := TDataAndFuncPlotOptionsDialogView(theWindow.FindSubView('dlog'));
	
	{�Put in these private globals these references, needed later }
	pXMinField := TRealText(pDialog.FindSubView('xmin'));
	pXMaxField := TRealText(pDialog.FindSubView('xmax'));
	pYMinField := TRealText(pDialog.FindSubView('ymin'));
	pYMaxField := TRealText(pDialog.FindSubView('ymax'));
	pYTicksField := TNumberText(pDialog.FindSubView('yint'));
	pAutoSubBySubRadio := TRadio(pDialog.FindSubView('auss'));
	pAutoOverAllSubRadio := TRadio(pDialog.FindSubView('auoa')); 
	pUserDefRadio := TRadio(pDialog.FindSubView('udef'));
	pSemilogCheckBox := TCheckBox(pDialog.FindSubView('slog'));
	pPlotView := SELF;
	
	{ Save the values of these fields, in case the user cancels. So we can
		mess with them at leasure while in the dialog. }
	originalDomain := fDomain;
	originalSemilog := fSemilog;
	originalPlotFast := fPlotFast;
	originalDomainOption := fDomainOption;
	originalYIntervals := fYIntervals;
	
	{�Set up the dialog, putting the right values in the controls }
	SetUp;
	
	{�Pose the dialog }
	dismisser := pDialog.PoseModally;

	IF dismisser = 'ok  ' THEN BEGIN
		CollectValues;
		ForceRedraw;
	END
	ELSE BEGIN
		fDomain := originalDomain;
		fSemilog := originalSemilog;
		fPlotFast := originalPlotFast;
		fDomainOption := originalDomainOption;
		fYIntervals := originalYIntervals;
	END;

	theWindow.Close;
END;

{ --------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TDataAndFuncPlotView.LoadDomain;
VAR anExtended: EXTENDED;
BEGIN
	anExtended := fDomain.dLeft;
	pXMinField.SetValue(anExtended, kDontRedraw);
	anExtended := fDomain.dRight;
	pXMaxField.SetValue(anExtended, kDontRedraw);
	anExtended := fDomain.dBottom;
	pYMinField.SetValue(anExtended, kDontRedraw);
	anExtended := fDomain.dTop;
	pYMaxField.SetValue(anExtended, kDontRedraw);
		
	pYTicksField.SetValue(fYIntervals, kDontRedraw);
END;

{ --------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TDataAndFuncPlotView.GetDomain;
VAR anExtended: EXTENDED;
BEGIN
	anExtended := pXMinField.GetValue;
	fDomain.dLeft := anExtended;
	anExtended := pXMaxField.GetValue;
	fDomain.dRight := anExtended;
	anExtended := pYMinField.GetValue;
	fDomain.dBottom := anExtended;
	anExtended := pYMaxField.GetValue;
	fDomain.dTop := anExtended;
END;

{ --------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TDataAndFuncPlotView.ShowDomain(state: BOOLEAN; reDraw: BOOLEAN);
BEGIN
	IF NOT state THEN
		IF pDialog.DeSelectCurrentEditText THEN;

	pXMinField.Show(state, reDraw);
	pXMaxField.Show(state, reDraw);
	pYMinField.Show(state, reDraw);
	pYMaxField.Show(state, reDraw);
END;

{ --------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TDataAndFuncPlotView.EnableDomain(state: BOOLEAN; reDraw: BOOLEAN);
BEGIN
	IF NOT state THEN
		IF pDialog.DeSelectCurrentEditText THEN;

	pXMinField.ViewEnable(state, reDraw);
	pXMaxField.ViewEnable(state, reDraw);
	pYMinField.ViewEnable(state, reDraw);
	pYMaxField.ViewEnable(state, reDraw);
	
	pXMinField.DimState(NOT state, reDraw);
	pXMaxField.DimState(NOT state, reDraw);
	pYMinField.DimState(NOT state, reDraw);
	pYMaxField.DimState(NOT state, reDraw);
END;

{ --------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TDataAndFuncPlotView.EnableYTicks(state: BOOLEAN);
BEGIN
	IF NOT state THEN
		IF pDialog.DeSelectCurrentEditText THEN;

	pYTicksField.ViewEnable(state, kDontRedraw);
	pYTicksField.DimState(NOT state, kRedraw);
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs }

PROCEDURE TDataAndFuncPlotView.GetX(VAR x: EXTENDED; obs: INTEGER);
BEGIN
	x := fExpDataTable.GetValue(obs, 0);
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs }

PROCEDURE TDataAndFuncPlotView.GetY(VAR y: EXTENDED; obs: INTEGER);
BEGIN
	y := fExpDataTable.GetValue(obs, GetCurrentSubject);
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs }

FUNCTION TDataAndFuncPlotView.GetNumberOfPages: INTEGER;
BEGIN
	GetNumberOfPages := fPlotWindow.GetNumberOfPages;
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs }

{�GetCurrentSubject returns the number of the current subject, or zero if
	no subject is currently displayed (because the data window is empty) }

FUNCTION TDataAndFuncPlotView.GetCurrentSubject: INTEGER;
VAR aRect: Rect;
BEGIN
	fExpDataTable.GetInUseBounds(aRect);
	IF aRect.right < fPlotWindow.fSubject THEN BEGIN
		fPlotWindow.fSubject := aRect.right;
		fPlotWindow.fScBarView.SetLongMax(aRect.right, kDontRedraw);
		fPlotWindow.ForceRedraw;	{�Invalidate all of the window }
	END;
	GetCurrentSubject := fPlotWindow.fSubject;
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs }

FUNCTION TDataAndFuncPlotView.GetNumberOfPoints: INTEGER;
VAR aRect: Rect;
BEGIN
	fExpDataTable.GetInUseBounds(aRect);
	GetNumberOfPoints := aRect.bottom;
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs }

PROCEDURE TDataAndFuncPlotView.GetMinX(VAR minimum: EXTENDED);
BEGIN
	{ also negatives, because the plot is logaritmic in the Y only }
	minimum := fExpDataTable.GetMinOfCol(0, kAlsoNegatives);
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs }

PROCEDURE TDataAndFuncPlotView.GetMinY(VAR minimum: EXTENDED; subject: INTEGER);
BEGIN
	minimum := fExpDataTable.GetMinOfCol(subject, fSemilog);
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs }

PROCEDURE TDataAndFuncPlotView.GetMaxX(VAR maximum: EXTENDED);
BEGIN
	{ also negatives, because the plot is logaritmic in the Y only }
	maximum := fExpDataTable.GetMaxOfCol(0, kAlsoNegatives);
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs }

PROCEDURE TDataAndFuncPlotView.GetMaxY(VAR maximum: EXTENDED; subject: INTEGER);
BEGIN
	maximum := fExpDataTable.GetMaxOfCol(subject, fSemilog);
END;

{ ----------------------------------------------------------------------------------- }
{$S AFields}

PROCEDURE TDataAndFuncPlotView.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
											fieldType: INTEGER)); OVERRIDE;
VAR anExt: EXTENDED;
BEGIN
	DoToField('TDataAndFuncPlotView', NIL, bClass);
	DoToField('fEasyFitDocument', @fEasyFitDocument, bObject);
	DoToField('fExpDataTable', @fExpDataTable, bObject);
	DoToField('fPlotWindow', @fPlotWindow, bObject);
	DoToField('fExtent', @fExtent, bRect);
	DoToField('fPlotRect', @fPlotRect, bRect);
	DoToField('fFontAscent', @fFontAscent, bInteger);
	DoToField('fFontDescent', @fFontDescent, bInteger);
	DoToField('fHorSpace', @fHorSpace, bInteger);
	DoToField('fDomainOption', @fDomainOption, bInteger);
	DoToField('fSemilog', @fSemilog, bBoolean);
	DoToField('fPlotFast', @fPlotFast, bBoolean);
	DoToField('fXIntervals', @fXIntervals, bInteger);
	DoToField('fYIntervals', @fYIntervals, bInteger);
	
	anExt := fDomain.dLeft;
	DoToField('fDomain.dLeft', @anExt, bExtended);
	anExt := fDomain.dTop;
	DoToField('fDomain.dTop', @anExt, bExtended);
	anExt := fDomain.dRight;
	DoToField('fDomain.dRight', @anExt, bExtended);
	anExt := fDomain.dBottom;
	DoToField('fDomain.dBottom', @anExt, bExtended);
	
	DoToField('fNumSmallTicks', @fNumSmallTicks, bInteger);
	
	INHERITED Fields(DoToField);
END;


{ ********************************************************************************** }
{�*						TDataAndFuncPlotOptionsDialogView																		 * }
{ ********************************************************************************** }
{$S GrafWindObjs}

PROCEDURE TDataAndFuncPlotOptionsDialogView.DoChoice(origView: TView; 
	itsChoice: INTEGER); OVERRIDE;

BEGIN
	WITH pPlotView DO
		CASE itsChoice OF
			mRadioHit:
				IF origView = pAutoSubBySubRadio  THEN BEGIN
					fDomainOption := autoSubjectBySubject;
					SetUpDomain(autoSubjectBySubject);
				END
				ELSE IF origView = pAutoOverAllSubRadio THEN BEGIN
					fDomainOption := autoOverAllSubjects;
					SetUpDomain(autoOverAllSubjects);
				END
				ELSE BEGIN	{�origView = 'udef' }
					fDomainOption := userDefined;
					SetUpDomain(userDefined);
				END;

			mCheckBoxHit:
				IF origView = pSemilogCheckBox THEN BEGIN
					fSemilog := NOT fSemilog;
					
					{ if we are now to plot semilog, a number of things must be done }
					IF fSemilog THEN BEGIN

						{ if necessary get the domain from the dialog }
						IF fDomainOption = userDefined THEN
							GetDomain;
						
						{ compute the domain, or at least adjust it for semilog if needed }
						ComputeDomain;
						
						{ put domain back in the dialog }
						LoadDomain;
						
						{ if we don't redraw, nothing will be seen }
						pXMinField.ForceRedraw;
						pXMaxField.ForceRedraw;
						pYMinField.ForceRedraw;
						pYMaxField.ForceRedraw;
					END;
					
					{ If semilog, y ticks are application's business }
					EnableYTicks(NOT fSemilog);
				END
				ELSE	{�It's not the semilog button }
					INHERITED DoChoice(origView, itsChoice);
				
			OTHERWISE
				INHERITED DoChoice(origView, itsChoice);
	
		END;	{�Case }
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TDataAndFuncPlotOptionsDialogView.SetUpDomain(domainOption: DomainOptionType);
BEGIN
	WITH pPlotView DO
		CASE domainOption OF
			autoSubjectBySubject:
				ShowDomain(FALSE, kReDraw);
			autoOverAllSubjects:
				BEGIN
					ComputeDomain;
					LoadDomain;
					ShowDomain(TRUE, kDontRedraw);
					EnableDomain(FALSE, kRedraw);
				END;
			userDefined:
				BEGIN
					LoadDomain;
					ShowDomain(TRUE, kRedraw);
					EnableDomain(TRUE, kRedraw);
				END;
		END;		{�Case }
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs}

{�This override to keep the user from inputing absurd domains where XMin > XMax
	or things like that. }

FUNCTION TDataAndFuncPlotOptionsDialogView.CanDismiss(dismissing: IDType): BOOLEAN;
	OVERRIDE;
BEGIN
	IF (INHERITED CanDismiss(dismissing)) THEN BEGIN
	
		IF	(dismissing = 'ok  ') &
				((TRealText(FindSubView('ymin')).GetValue > 
						TRealText(FindSubView('ymax')).GetValue) |
				 (TRealText(FindSubView('xmin')).GetValue > 
						TRealText(FindSubView('xmax')).GetValue))
		THEN BEGIN
			gApplication.Beep(50);
			MyAlert(kGenericMsgs, eWrongDomain);
			CanDismiss := FALSE;
		END
		ELSE IF (dismissing = 'ok  ') &
						TCheckBox(FindSubView('slog')).IsOn &
						((TRealText(FindSubView('ymin')).GetValue = 0.0) |
						 (TRealText(FindSubView('ymax')).GetValue = 0.0))
		THEN BEGIN
			gApplication.Beep(50);
			MyAlert(kGenericMsgs, eWrongDomainForSemilog);
			CanDismiss := FALSE;
		END
		ELSE
			CanDismiss := TRUE;
			
	END
	ELSE
		CanDismiss := FALSE;
END;


{ ********************************************************************************** }
{ *									TPlotWindowScrollBar																					 * }
{ ********************************************************************************** }
{$S GrafWindObjs}

PROCEDURE TPlotWindowScrollBar.Draw(area: Rect); OVERRIDE;
VAR myPlotWindow: TPlotWindow;
BEGIN
	myPlotWindow := TPlotWindow(GetWindow);
	IF myPlotWindow = NIL THEN
	{$IFC qDebug}
		ProgramBreak('TPlotWindowScrollBar.Draw: can''t get a ref. to my window');
	{$ELSEC}
		Failure(maxErr, 0);
	{$ENDC}

	SetLongMax(myPlotWindow.GetNumberOfPages, kDontRedraw);
	
	INHERITED Draw(area);
END;

{ ********************************************************************************** }
{ *									TPlotWindowInfoView																						 * }
{ ********************************************************************************** }
{$S GrafWindObjs}

PROCEDURE TPlotWindowInfoView.Draw(area: Rect); OVERRIDE;
VAR s: Str255;
		myPlotWindow: TPlotWindow;
BEGIN
	myPlotWindow := TPlotWindow(GetWindow);
	{$IFC qDebug}
	IF myPlotWindow = NIL THEN
		ProgramBreak('TPlotWindowInfoView.Draw: can''t get a ref. to my window');
	{$ELSEC}
	FailNil(myPlotWindow);
	{$ENDC}
	
	IF myPlotWindow.fSubject = 0 THEN
		SetText('No subjects', kDontRedraw)
	ELSE BEGIN
		NumToString(myPlotWindow.fSubject, s);
		SetText(Concat('Subject ', s), kDontRedraw);
	END;
	
	INHERITED Draw(area);
END;


{ ********************************************************************************* }
{ *									TStdResPlotView																								* }
{ ********************************************************************************* }
{$S AOpen}

PROCEDURE TStdResPlotView.IRes(itsDocument: TDocument; itsSuperView: TView;
			VAR itsParams: Ptr);	OVERRIDE;

CONST kDefaultPlotAgainstOption = againstTime;
BEGIN
	INHERITED IRes(itsDocument, itsSuperView, itsParams);
	
	fStdResTable := fEasyFitDocument.fStdResTable;
	fPlotAgainstOption := kDefaultPlotAgainstOption;
	fSemilog := FALSE;	{ this window doesn't draw semilog. }
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TStdResPlotView.ComputeDomain; OVERRIDE;

	FUNCTION Sign(x: EXTENDED): INTEGER;
	BEGIN
		IF x < 0 THEN
			Sign := -1
		ELSE IF x > 0 THEN
			Sign := 1
		ELSE
			Sign := 0;
	END;
	
BEGIN
	INHERITED ComputeDomain;
	
	IF fDomainOption <> userDefined THEN 
		{ After computing domain as usual, make it simmetrical in the Y axis }
		{$PUSH} {$H-}
		WITH fDomain DO
			IF Abs(dTop) > Abs(dBottom) THEN
				dBottom := Sign(dBottom) * Abs(dTop)
			ELSE
				dTop := Sign(dTop) * Abs(dBottom);
		{$POP}
END;

{ ---------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TStdResPlotView.MakeDialog;

CONST kStdResPlotOptionsDlog = 1120;

VAR theWindow:									TWindow;
		dismisser:									IDType;
		originalDomain:							DomainType;
		originalDomainOption:				DomainOptionType;
		originalYIntervals:					INTEGER;
		originalPlotAgainstOption:	PlotAgainstOption;
		
		
	PROCEDURE SetUp;
	VAR anExtended:			EXTENDED;
	BEGIN
		CASE fDomainOption OF
			autoSubjectBySubject:
				pAutoSubBySubRadio.SetState(TRUE, kDontRedraw);
			autoOverAllSubjects:
				pAutoOverAllSubRadio.SetState(TRUE, kDontRedraw);
			userDefined:
				TRadio(pDialog.FindSubView('udef')).SetState(TRUE, kDontRedraw);
		END;
		
		CASE fPlotAgainstOption OF
			againstTime:
				TRadio(pDialog.FindSubView('agax')).SetState(TRUE, kDontRedraw);
			againstObservedConc:
				TRadio(pDialog.FindSubView('aoby')).SetState(TRUE, kDontRedraw);
			againstEstimatedConc:
				TRadio(pDialog.FindSubView('acoy')).SetState(TRUE, kDontRedraw);
		END;
		
		pDialog.SetUpDomain(fDomainOption);
	
		TNumberText(pDialog.FindSubView('xint')).SetValue(fXIntervals, kDontRedraw);
	END;
	
	PROCEDURE CollectValues;
	VAR anExtended: EXTENDED;
	BEGIN
		IF pAutoSubBySubRadio.IsOn THEN
			fDomainOption := autoSubjectBySubject
		ELSE IF pAutoOverAllSubRadio.IsOn THEN
			fDomainOption := autoOverAllSubjects
		ELSE BEGIN
			fDomainOption := userDefined;
			
			{ We need to get the values of the domain from the fields in the dialog
				only in the "userDefined domain" case; otherwise we will compute
				the domain on our own as needed }
			GetDomain;
		END;
	
		IF TRadio(pDialog.FindSubView('agax')).IsOn THEN
			fPlotAgainstOption := againstTime
		ELSE IF TRadio(pDialog.FindSubView('aoby')).IsOn THEN
			fPlotAgainstOption := againstObservedConc
		ELSE
			fPlotAgainstOption := againstEstimatedConc;
	
		fXIntervals := TNumberText(pDialog.FindSubView('xint')).GetValue;
		fYIntervals := pYTicksField.GetValue;
	END;

BEGIN
	FixEditMenu;
	theWindow := NewTemplateWindow(kStdResPlotOptionsDlog, NIL);
	FailNil(theWindow);
	
	{�Get a reference to the dialog view, for efficiency }
	pDialog := TDataAndFuncPlotOptionsDialogView(theWindow.FindSubView('dlog'));
	
	{�Put in these private globals these references, needed later }
	pXMinField := TRealText(pDialog.FindSubView('xmin'));
	pXMaxField := TRealText(pDialog.FindSubView('xmax'));
	pYMinField := TRealText(pDialog.FindSubView('ymin'));
	pYMaxField := TRealText(pDialog.FindSubView('ymax'));
	pYTicksField := TNumberText(pDialog.FindSubView('yint'));
	pAutoSubBySubRadio := TRadio(pDialog.FindSubView('auss'));
	pAutoOverAllSubRadio := TRadio(pDialog.FindSubView('auoa'));
	pUserDefRadio := TRadio(pDialog.FindSubView('udef'));
	pPlotView := SELF;
	pAgainstTimeRadio := TRadio(pDialog.FindSubView('agax'));
	pAgainstObservedConcRadio := TRadio(pDialog.FindSubView('aoby'));
	pAgainstComputedConcRadio := TRadio(pDialog.FindSubView('acoy'));
	
	{ Save the values of these fields, in case the user cancels. So we can
		mess with them at leasure while in the dialog. }
	originalDomain := fDomain;
	originalDomainOption := fDomainOption;
	originalYIntervals := fYIntervals;
	originalPlotAgainstOption := fPlotAgainstOption;
	
	{�Set up the dialog, putting the right values in the controls }
	SetUp;
	
	{�Pose the dialog }
	dismisser := pDialog.PoseModally;
	
	IF dismisser = 'ok  ' THEN BEGIN
		CollectValues;
		ForceRedraw;
	END
	ELSE BEGIN
		fDomain := originalDomain;
		fDomainOption := originalDomainOption;
		fYIntervals := originalYIntervals;
		fPlotAgainstOption := originalPlotAgainstOption;
	END;
	
	theWindow.Close;
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TStdResPlotView.GetX(VAR x: EXTENDED; obs: INTEGER); OVERRIDE;
BEGIN
	CASE fPlotAgainstOption OF
		againstTime: 
			x := fExpDataTable.GetValue(obs, 0);
		againstObservedConc:
			x := fExpDataTable.GetValue(obs, GetCurrentSubject);
		againstEstimatedConc:
			x := fStdResTable.GetValue(obs, 
							kStdResColsPerSubj * (GetCurrentSubject - 1) + kEstimatedY);
	END;
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TStdResPlotView.GetY(VAR y: EXTENDED; obs: INTEGER); OVERRIDE;
BEGIN
	y := fStdResTable.GetValue(obs, 
					kStdResColsPerSubj * (GetCurrentSubject - 1) + kStdResiduals);
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TStdResPlotView.GetMinX(VAR minimum: EXTENDED); OVERRIDE;
BEGIN
	CASE fPlotAgainstOption OF
		againstTime: 
			minimum := fExpDataTable.GetMinOfCol(0, kAlsoNegatives);
		againstObservedConc:
			minimum := fExpDataTable.GetMinOfCol(GetCurrentSubject, kAlsoNegatives);
		againstEstimatedConc:
			minimum := fStdResTable.GetMinOfCol(
				kStdResColsPerSubj * (GetCurrentSubject - 1) + kEstimatedY, kAlsoNegatives);
	END;
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TStdResPlotView.GetMinY(VAR minimum: EXTENDED; subject: INTEGER); OVERRIDE;
BEGIN
	minimum := fStdResTable.GetMinOfCol(kStdResColsPerSubj * (GetCurrentSubject - 1) + 
		kStdResiduals, kAlsoNegatives);
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TStdResPlotView.GetMaxX(VAR maximum: EXTENDED); OVERRIDE;
BEGIN
	CASE fPlotAgainstOption OF
		againstTime: 
			maximum := fExpDataTable.GetMaxOfCol(0, kAlsoNegatives);
		againstObservedConc:
			maximum := fExpDataTable.GetMaxOfCol(GetCurrentSubject, kAlsoNegatives);
		againstEstimatedConc:
			maximum := fStdResTable.GetMaxOfCol( 
				kStdResColsPerSubj * (GetCurrentSubject - 1) + kEstimatedY, kAlsoNegatives);
	END;
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TStdResPlotView.GetMaxY(VAR maximum: EXTENDED; subject: INTEGER); OVERRIDE;
BEGIN
	maximum := fStdResTable.GetMaxOfCol(kStdResColsPerSubj * (GetCurrentSubject - 1) + 
		kStdResiduals, kAlsoNegatives);
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TStdResPlotView.Draw(area: Rect);
VAR derefXmin: 				EXTENDED;
		derefXMax: 				EXTENDED;
		derefYMin:				EXTENDED;
		derefYMax: 				EXTENDED;
		derefPlotRect:		Rect;
		currSubject:			INTEGER;
BEGIN
	currSubject := GetCurrentSubject;

	INHERITED Draw(area);
	
	{�The inherited draw sets the fDomain field }
	derefXMin := fDomain.dLeft;
	derefXMax := fDomain.dRight; 
	derefYMin := fDomain.dBottom; 
	derefYMax := fDomain.dTop;
	IF (currSubject >= 1) & (derefYMin < derefYMax) THEN BEGIN
		derefPlotRect := fPlotRect;
			WITH derefPlotRect DO
				DrawZeroLine(left, 
										 right, 
										 bottom, 
										 top,
										 derefXMin, 
										 derefXMax, 
										 derefYMin, 
										 derefYMax);
	END;
END;

{ ----------------------------------------------------------------------------------- }
{$S GrafWindObjs}

PROCEDURE TStdResPlotView.PlotTheFunction; OVERRIDE;
BEGIN
	{ we need to override because we don't plot any function in this window !!! }
END;

{ ----------------------------------------------------------------------------------- }
{$S AFields}

PROCEDURE TStdResPlotView.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
																			fieldType: INTEGER)); OVERRIDE;
VAR anExt: EXTENDED;
BEGIN
	DoToField('TStdResPlotView', NIL, bClass);
	DoToField('fStdResTable', @fStdResTable, bObject);
	DoToField('fPlotAgainstOption', @fPlotAgainstOption, bObject);
	
	INHERITED Fields(DoToField);
END;


{ ********************************************************************************** }
{�*						TStdResPlotOptionsDialogView																				 * }
{ ********************************************************************************** }
{$S GrafWindObjs}

PROCEDURE TStdResPlotOptionsDialogView.DoChoice(origView: TView; 
	itsChoice: INTEGER); OVERRIDE;

BEGIN
	WITH TStdResPlotView(pPlotView) DO
		CASE itsChoice OF
			mRadioHit:
				IF origView = pAgainstTimeRadio THEN BEGIN
					fPlotAgainstOption := againstTime;
					SetUpDomain(fDomainOption);
				END
				ELSE IF origView = pAgainstObservedConcRadio THEN BEGIN
					fPlotAgainstOption := againstObservedConc;
					SetUpDomain(fDomainOption);
				END
				ELSE IF origView = pAgainstComputedConcRadio THEN BEGIN
					fPlotAgainstOption := againstEstimatedConc;
					SetUpDomain(fDomainOption);
				END
				ELSE
					INHERITED DoChoice(origView, itsChoice);

			OTHERWISE
				INHERITED DoChoice(origView, itsChoice);
	
		END;	{�Case }
END;

{ *********************************************************************************** }
{ *								TPlotPrintView																										* }
{ *********************************************************************************** }
{$S ARes}

PROCEDURE TPlotPrintView.DoSetupMenus; OVERRIDE;
BEGIN
	INHERITED DoSetupMenus;
	
	FixEditMenu;
	Enable(cCopy, TRUE);
END;

{ ----------------------------------------------------------------------------------- }
{$S ASelCommand}
			
FUNCTION TPlotPrintView.DoMenuCommand(aCmdNumber: cmdNumber): TCommand; OVERRIDE;
BEGIN
	IF aCmdNumber = cCopy THEN BEGIN
		FailOSErr(ZeroScrap);
		SELF.WriteToDeskScrap;
		gApplication.CheckDeskScrap;		{ Force MacApp to notice the change }
		DoMenuCommand := gNoChanges;
	END
	ELSE
		DoMenuCommand := INHERITED DoMenuCommand(aCmdNumber);
END;

{ *********************************************************************************** }
{ *								TDataAndFuncPlotPrintView																										* }
{ *********************************************************************************** }
{$S ARes}

PROCEDURE TDataAndFuncPlotPrintView.GetInspectorName(VAR inspectorName: Str255); OVERRIDE;
BEGIN
	inspectorName := 'Data & Model Plot';
END;

{ *********************************************************************************** }
{ *								TStdResPlotPrintView																										* }
{ *********************************************************************************** }
{$S ARes}

PROCEDURE TStdResPlotPrintView.GetInspectorName(VAR inspectorName: Str255); OVERRIDE;
VAR
	againstStr: Str255;
BEGIN
	CASE TStdResPlotView(FindSubView('plot')).fPlotAgainstOption OF 
		againstTime:
			againstStr := 'X';
		againstObservedConc:
			againstStr := 'Observed Y';
		againstEstimatedConc:
			againstStr := 'Estimated Y';
	END;
	
	inspectorName := Concat('Std. Res. Plot against ', againstStr);
END;