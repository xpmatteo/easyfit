{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}

FUNCTION NewPermString(theString: Str255): Handle; C; EXTERNAL;

PROCEDURE FreeXMDL(xmdl: Handle); C; EXTERNAL;
FUNCTION LoadXMDL(name: Str255): Handle; C; EXTERNAL;

PROCEDURE ReportFilePos(aRefNum: INTEGER; msg: Str255); FORWARD;

TYPE

	TPlotPrintHandler = OBJECT(TStdPrintHandler)
	
		PROCEDURE TPlotPrintHandler.AdornPage; OVERRIDE;
		
		FUNCTION TPlotPrintHandler.Print(itsCmdNumber: CmdNumber;
												VAR proceed: BOOLEAN): TCommand; OVERRIDE;
	END;
	
{�---------------------------------------------------------------------------------- }
	
	{ This command clears the messages window }
	TClearMessagesCommand = OBJECT(TCommand)
		fEasyFitDocument:		TEasyFitDocument;
		fText:							Handle;
		
		PROCEDURE TClearMessagesCommand.IClearMessagesCommand
			(itsCmdNumber: CmdNumber; itsEasyFitDocument: TEasyFitDocument);

		PROCEDURE TClearMessagesCommand.Free;			OVERRIDE;
			
		PROCEDURE TClearMessagesCommand.DoIt;			OVERRIDE;
		PROCEDURE TClearMessagesCommand.ReDoIt;			OVERRIDE;
		PROCEDURE TClearMessagesCommand.UndoIt;		OVERRIDE;
	END;

{ *********************************************************************************** }
{ *															TClearMessagesCommand																* }
{ *********************************************************************************** }
{$S ASelCommand}

PROCEDURE TClearMessagesCommand.IClearMessagesCommand
	(itsCmdNumber: CmdNumber; itsEasyFitDocument: TEasyFitDocument);
VAR tmpHandle: Handle;
BEGIN
	fText := NIL;
	ICommand(itsCmdNumber, itsEasyFitDocument, NIL, NIL);
	
	fEasyFitDocument := itsEasyFitDocument;
	
	{ make a local copy of the msgs text }
	tmpHandle := itsEasyFitDocument.fMessagesWindow.fTeView.ExtractText;
	fText := CopyHandleData(tmpHandle);
END;

{ ----------------------------------------------------------------------------------- }
{$S ASelCommand}

PROCEDURE TClearMessagesCommand.Free;
BEGIN
	DisposIfHandle(fText);
	INHERITED Free;
END;

{ ----------------------------------------------------------------------------------- }
{$S ADoCommand}

PROCEDURE TClearMessagesCommand.DoIt;			OVERRIDE;
VAR tmpHandle: Handle;
BEGIN
	tmpHandle := fEasyFitDocument.fMessagesWindow.fTeView.ExtractText;
	SetPermHandleSize(tmpHandle, 0);
	fEasyFitDocument.fMessagesWindow.fTeView.RecalcText;
	fEasyFitDocument.fMessagesWindow.Synch;
END;

{ ----------------------------------------------------------------------------------- }
{$S ADoCommand}

PROCEDURE TClearMessagesCommand.ReDoIt;			OVERRIDE;
VAR tmpHandle: Handle;
BEGIN
	DoIt;
END;

{ ----------------------------------------------------------------------------------- }
{$S ADoCommand}

PROCEDURE TClearMessagesCommand.UndoIt;
VAR tmpHandle: Handle;
BEGIN
	{ create another copy of the text and pass it to TEView.
		We need to keep a private copy of the text throughout the existence
		of this command, becouse TTEView.StuffText has the nasty habit of
		disposing the old text before installing the new. }
	tmpHandle := CopyHandleData(fText);
	fEasyFitDocument.fMessagesWindow.fTeView.StuffText(tmpHandle);
	fEasyFitDocument.fMessagesWindow.fTeView.RecalcText;
	fEasyFitDocument.fMessagesWindow.Synch;
END;


{ *********************************************************************************** }
{ *															TPlotPrintHandler																		* }
{ *********************************************************************************** }
{$S PrintRes}

{ We set the View's size to page size before printing, then back to what it was
	before }
	
FUNCTION TPlotPrintHandler.Print(itsCmdNumber: CmdNumber;
												VAR proceed: BOOLEAN): TCommand; OVERRIDE;
CONST kDontInvalidate = FALSE;
VAR fi:							FailInfo;
		originalExtent:	VRect;
		originalHeight:	VCoordinate;
		originalWidth:	VCoordinate;
		width:					VCoordinate;
	
	PROCEDURE PlotPrintErrHdl(error: OSErr; message: LONGINT);
	BEGIN
		fView.Resize(originalWidth, originalHeight, kDontInvalidate);
	END;

BEGIN
	{ remember original size }
	fView.GetExtent(originalExtent);
	originalHeight := originalExtent.bottom;
	originalWidth := originalExtent.right;
	
	CatchFailures(fi, PlotPrintErrHdl);
	
	{ Change the view size }
	{$PUSH} {$H-}
	WITH fPageAreas.theInterior DO
		width := right - left;
	{$POP}
	fView.Resize(width, Num2Longint(width * kGoldenRatio), kDontInvalidate);
	
	Print := INHERITED Print(itsCmdNumber, proceed);
	
	{ Restore original size }
	fView.Resize(originalWidth, originalHeight, kDontInvalidate);
	
	Success(fi);
END;

{ ---------------------------------------------------------------------------------- }
{$S PrintImage}

{ Overridden to print page headers }

PROCEDURE TPlotPrintHandler.AdornPage; OVERRIDE;
CONST
	botSlop 			= 8;						{ ??? Arbitrary choice }
	topSlop 			= 16;						{ ??? Arbitrary choice }
VAR
	aString:			Str255;
	docName:			Str255;
	viewName:			Str255;
	baseLine:			INTEGER;
	theTextRect:	Rect;
	handyRect:		Rect;
	
BEGIN
	{ʥ�Set the font & style }
	TextFont(applFont);
	TextFace([]);
	TextSize(12);
	
	{ � draw the header }
	GetDocName(docName);
	fView.GetInspectorName(viewName);
	PreparePageHeader(aString, viewName, docName);
	baseLine := fPageAreas.theInk.top + topSlop;
	handyRect := fPageAreas.thePaper;
	ComputeTextRect(aString, baseLine, handyRect, theTextRect);
	MADrawString(@aString, theTextRect, teJustSystem);
	
	{ ��Print extra stuff if debugging }
	{$IFC qDebug}
	IF gDebugPrinting THEN BEGIN							
		{ Additionally frame the printable area of the page if gDebugPrinting }
		handyRect := fPageAreas.theInk;
		PenSize(1, 1);
		FrameRect(handyRect);

		{ Frame the 'interior' of the page }
		PenSize(2, 2);
		handyRect := fPageAreas.theInterior;
		FrameRect(handyRect);
		END;
	{$ENDC}
END;

{ ***********************************************************************************}
{ ******										TEasyFitApplication																****** }
{ ***********************************************************************************}
{$S AInit} { Gets mapped to GInit, so we don't need to preload GInit ! }

PROCEDURE TEasyFitApplication.IEasyFitApplication (itsMainFileType: OSType);
VAR segNumber: INTEGER;
		fi: FailInfo;
		{$IFC qXMDLs}
		volName: Str255;
		{$ENDC}
		
	PROCEDURE TEasyFitApplication_MakeViewForAlienClipboard; EXTERNAL;
	PROCEDURE TDataAndFuncPlotView_PlotTheData; EXTERNAL;
	PROCEDURE sprintf; C; EXTERNAL;
	PROCEDURE TEasyFitDocument_MakeFitOptionsDlog; EXTERNAL;
	PROCEDURE TEasyFitApplication_OpenOld; EXTERNAL;
	PROCEDURE TApplication_CanOpenDocument; EXTERNAL;
	PROCEDURE TEasyFitDocument_DoMenuCommand; EXTERNAL;
	PROCEDURE compile; C; EXTERNAL;
	
	{$IFC qXMDLs}
	PROCEDURE AppendXMDLsToModelMenu;
	VAR
		theMenuHandle: MenuHandle;
	BEGIN
		theMenuHandle := GetResMenu(mModel);
		FailNILResource(Handle(theMenuHandle));
		AddResMenu(theMenuHandle, kXMDLType);
	END;
	
	FUNCTION OpenTheResFile(fileName: Str255; vRefNum: INTEGER): BOOLEAN;
	CONST
		phPlainAlert = 2000;
	VAR
		fileRefNumber: INTEGER;
		err: OSErr;
	BEGIN
		fileRefNumber := OpenRFPerm(fileName, vRefNum, {permission:} fsRdWrPerm);
		
		{ Send an alert if opening was not successful }
		IF fileRefNumber = -1 THEN BEGIN
			err := ResError;
			ParamText(Concat('Couldn''t open External Models file ', fileName, '.'), '','','');
			StdAlert(phPlainAlert);
		END;
		
		OpenTheResFile := TRUE;
	END;
	{$ENDC}
	
	PROCEDURE IEasyFitHdl(error: OSErr; message: LONGINT);
	BEGIN
		DisposIfPtr(gX);
		DisposIfPtr(gY);
		DisposIfPtr(gSqrtWeights);
	END;

BEGIN
	{ Preload our segments; application startup is faster this way }
	{�I comment out this stuff, since it may cause problems. In fact,
		the segments are read into memory and locked, and this may generate an
		out of memory failure of opening the first document. This is because
		the locked segments are not purged until we get to the main event loop
		the first time. }
	
	{$IFC FALSE}
	{$PUSH} {$B-}
	segNumber := GetSegNumber(@NAN);	{�SANELib }
	IF PreloadSegment(segNumber) THEN ;
	segNumber := GetSegNumber(@TEasyFitApplication_MakeViewForAlienClipboard);	{�GClipBoard }
	IF PreloadSegment(segNumber) THEN ;
	segNumber := GetSegNumber(@MAOpenFile);	{�GFile }
	IF PreloadSegment(segNumber) THEN ;
	segNumber := GetSegNumber(@TDataAndFuncPlotView_PlotTheData);	{�GrafWindObjs }
	IF PreloadSegment(segNumber) THEN ;
	segNumber := GetSegNumber(@sprintf);	{�GWriteln }
	IF PreloadSegment(segNumber) THEN ;
	segNumber := GetSegNumber(@TEasyFitDocument_MakeFitOptionsDlog);	{�GDoCommand }
	IF PreloadSegment(segNumber) THEN ;
	segNumber := GetSegNumber(@TEasyFitApplication_OpenOld);	{�GOpen }
	IF PreloadSegment(segNumber) THEN ;
	segNumber := GetSegNumber(@TApplication_CanOpenDocument);	{�GFinder }
	IF PreloadSegment(segNumber) THEN ;
	segNumber := GetSegNumber(@MyAlert);	{�GNonRes }
	IF PreloadSegment(segNumber) THEN ;
	segNumber := GetSegNumber(@TEasyFitDocument_DoMenuCommand);	{�GSelCommand }
	IF PreloadSegment(segNumber) THEN ;
	segNumber := GetSegNumber(@compile);	{�ACompileUserModel }
	IF PreloadSegment(segNumber) THEN ;
	segNumber := GetSegNumber(@EasyFitErrorAlert);	{�GError }
	IF PreloadSegment(segNumber) THEN ;
	{$POP}
	{$ENDC} { FALSE }
	
	gX := NIL;
	gY := NIL;
	gSqrtWeights := NIL;
	
	CatchFailures(fi, IEasyFitHdl);
	gX := EDataPtr(NewPermPtr(SIZEOF(EDataArray)));
	FailNIL(gX);
	gY := EDataPtr(NewPermPtr(SIZEOF(EDataArray)));
	FailNIL(gY);
	gSqrtWeights := EDataPtr(NewPermPtr(SIZEOF(EDataArray)));
	FailNIL(gSqrtWeights);
	Success(fi);
	
	{�gMissing is used to represent a missing value; the true meaning of
		Nan(38) is 'invalid arg to financial function', but since we
		don't use financial functions here, it's no problem }
	gMissing := Nan(38);
	
	gWorking := FALSE;
	
	pWorkingDialog := NIL;	{�Make sure we don't try to use them when they're invalid }
	pMessagesWindow := NIL;
	
	gWatchHdl := GetCursor(watchCursor);
	FailResError;
	
	{�Init our modules that need to be inited }
	InitTables;
	InitRealText;
	InitPercDoneBarView;
	
	IF gDeadStripSuppression THEN BEGIN
		IF Member(TObject(NIL), TPlotWindow) THEN;
		IF Member(TObject(NIL), TDataAndFuncPlotView) THEN;
		IF Member(TObject(NIL), TStdResPlotView) THEN;
		IF Member(TObject(NIL), TDataAndFuncPlotOptionsDialogView) THEN;
		IF Member(TObject(NIL), TStdResPlotOptionsDialogView) THEN;
		IF Member(TObject(NIL), TPlotWindowScrollBar) THEN;
		IF Member(TObject(NIL), TPlotWindowInfoView) THEN;
		IF Member(TObject(NIL), TPlotPrintView) THEN;
		IF Member(TObject(NIL), TDataAndFuncPlotPrintView) THEN;
		IF Member(TObject(NIL), TStdResPlotPrintView) THEN;
		IF Member(TObject(NIL), TMultiTEView) THEN;
		{	IF Member(TObject(NIL), TAdornedScroller) THEN; }
	END;
	
	{�Enable the new std alert filter }
	gMacAppAlertFilter := @MacAppAlertFilter;

	{$IFC qXMDLs}
	{�Get the application's Working Directory }
	FailOSErr(GetVol(@volName, gApplicationWD));
	{$ENDC}
	
	Self.IApplication(itsMainFileType);
	
	{$IFC qXMDLs}
	{�Open the RF of all files of type 'XMDL' in our directory }
	DoToFilesInWD(kXMDLType, gApplicationWD, OpenTheResFile);
	
	gLastOpenedResFile := CurResFile;
	UseResFile(gApplicationRefNum);
	
	{�Append the names of all of the resources of type 'XMDL' that we are able
		to find }
	AppendXMDLsToModelMenu;
	{$ENDC}
	
	{$IFC qDebug}
	Writeln('TEsftAppl.IEsftAppl: address of gXMDL is ', ORD4(@gXMDL):1);
	Writeln('TEsftAppl.IEsftAppl: address of gFocusedView is ', ORD4(@gFocusedView):1);
	{$ENDC}
END;

{ -----------------------------------------------------------------------------------}
{$S MAFinder}

FUNCTION TEasyFitApplication.CanOpenDocument(itsCmdNumber: CmdNumber;
									  VAR anAppFile: AppFile): BOOLEAN; OVERRIDE;
BEGIN
	IF (anAppFile.fType = kXMDLType) & (itsCmdNumber = cFinderOpen) THEN
		CanOpenDocument := TRUE
	ELSE
		CanOpenDocument := INHERITED CanOpenDocument(itsCmdNumber, anAppFile);
END;

{ -----------------------------------------------------------------------------------}
{$S MAError}

PROCEDURE TEasyFitApplication.ShowError(error: OSErr; message: LONGINT); OVERRIDE;
BEGIN
	IF error = kXMDLNotPresent THEN
		Exit(ShowError);			{�No need to show an error }
			
	IF (error = kFileIsDamaged) | (error = kFormulaTooComplex)
			| (error = kNonRectangularScrap) | (error = kScrapTableTooBig)
			| (error = kTooManyParametersForELS) | (error = kFileCreatedByOldVersion)
			| (error = kXMDLFailed) | (error = kFailedXMDLInitialization)
	THEN
		EasyFitErrorAlert(error, message)
	ELSE
		INHERITED ShowError(error, message);
END;

{ -----------------------------------------------------------------------------------}
{$S AOpen}

FUNCTION TEasyFitApplication.DoMakeDocument(itsCmdNumber: CmdNumber): TDocument;
VAR anEasyFitDocument: TEasyFitDocument;
BEGIN
	New(anEasyFitDocument);
	FailNil(anEasyFitDocument);
	anEasyFitDocument.IEasyFitDocument;
	fEasyFitDocument := anEasyFitDocument;
	DoMakeDocument := anEasyFitDocument;
END;

{ -----------------------------------------------------------------------------------}
{$S AOpen}

PROCEDURE TEasyFitApplication.OpenNew(itsCmdNumber: CmdNumber); OVERRIDE;
BEGIN
	INHERITED OpenNew(itsCmdNumber);
	fEasyFitDocument.fExpDataTable.fTableWindow.Show({ shown: } TRUE, { redraw: } FALSE);
END;

{ -----------------------------------------------------------------------------------}
{$S AOpen}

{ 
	This override has several purposes: 
	- we open no more than a single document at a time
	- we need to copy the data from the PlotOptionsMiscellanea into the
		plot views. We do it here because when the inherited OpenOld exits, we know that
		the views have been created; when we read the data in DoRead, the views
		do not exist yet.
	- We open the windows that have to be opened only when the doc opening is
		completed
}

PROCEDURE TEasyFitApplication.OpenOld(itsOpenCmd: CmdNumber; anAppFile: AppFile); OVERRIDE;
CONST kOperationDescStrings = 200;
			kOpenDocIndex = 				6;
			kOneDocAtATime =			 	8;
VAR		openDoc,
			onlyOneAtATime:					Str255;
			tmpPlotMisc:						PlotOptionsMiscellanea;
			theEasyFitDocument:			TEasyFitDocument;

BEGIN
	IF gDocList.fSize > 0 THEN BEGIN
		GetIndString(openDoc, kOperationDescStrings, kOpenDocIndex);
		FailResError;
		GetIndString(onlyOneAtATime, kMiscellaneaStr, kOneDocAtATime);
		FailResError;

		{ Display 
			"I couldn't open 'anAppFile', because we only support one doc at a time" }
		ParamText(onlyOneAtATime, '', openDoc, anAppFile.fName);
		StdAlert(phGenError);
	END
	ELSE IF anAppFile.fType = kXMDLType THEN BEGIN
		{�We can't open a XMDL file as a document; we will open a new untitled instead. }
		OpenNew(itsOpenCmd)
	END
	ELSE BEGIN
		INHERITED OpenOld(itsOpenCmd, anAppFile);

		theEasyFitDocument := fEasyFitDocument;
		WITH theEasyFitDocument DO BEGIN
			fExpDataTable.fFormat						:= fFormat;
			fParamsTable.fFormat						:= fFormat;
			fStdResTable.fFormat						:= fFormat;
			fWeightsTable.fFormat						:= fFormat;
			fDosesTable.fFormat							:= fFormat;
			{$IFC qConstraints}
			fConstraintsTable.fFormat				:= fFormat;
			{$ENDC}
	
			tmpPlotMisc := fPlotOptionsMiscellanea;
			WITH tmpPlotMisc DO BEGIN
				fDataAndFuncPlotWindow.fPlotView.fDomainOption	:= dataAndFuncPlotDomainOption;
				fDataAndFuncPlotWindow.fPlotView.fSemilog				:= semilog;
				fDataAndFuncPlotWindow.fPlotView.fPlotFast			:= plotFast;
				{$PUSH}�{$H-}
				WITH fDataAndFuncPlotWindow.fPlotView.fDomain, dataAndFuncPlotDomain DO BEGIN
					dLeft := ddLeft;
					dRight := ddRight;
					dTop := ddTop;
					dBottom := ddBottom;
				END;
				{$POP}
				fDataAndFuncPlotWindow.fPlotView.fXIntervals		:= dataAndFuncPlotXTicks;
				fDataAndFuncPlotWindow.fPlotView.fYIntervals		:= dataAndFuncPlotYTicks;
				fStdResPlotWindow.fPlotView.fDomainOption				:= stdResPlotDomainOption;
				{$PUSH}�{$H-}
				WITH fStdResPlotWindow.fPlotView.fDomain, stdResPlotDomain DO BEGIN
					dLeft := ddLeft;
					dRight := ddRight;
					dTop := ddTop;
					dBottom := ddBottom;
				END;
				{$POP}
				TStdResPlotView(fStdResPlotWindow.fPlotView).fPlotAgainstOption	:= stdResPlotAgainstOption;
				fStdResPlotWindow.fPlotView.fXIntervals					:= stdResPlotXTicks;
				fStdResPlotWindow.fPlotView.fYIntervals					:= stdResPlotYTicks;
			END;
						
			fExpDataTable.fTableWindow.Show(fExpDataWindowShape.shown, { redraw: } FALSE);
			fParamsTable.fTableWindow.Show(fParamsWindowShape.shown, { redraw: } FALSE);
			fWeightsTable.fTableWindow.Show(fWeightsWindowShape.shown, { redraw: } FALSE);
			fDosesTable.fTableWindow.Show(fDosesWindowShape.shown, { redraw: } FALSE);
			{$IFC qConstraints}
			fConstraintsTable.fTableWindow.Show(fConstraintsWindowShape.shown, { redraw: } FALSE);
			{$ENDC}
			fMessagesWindow.fWindow.Show(fMessagesWindowShape.shown, { redraw: } FALSE);
			fStdResTable.fTableWindow.Show(fStdResWindowShape.shown, { redraw: } FALSE);
			fDataAndFuncPlotWindow.Show(fDataAndFuncPlotWindowShape.shown, { redraw: } FALSE);
			fStdResPlotWindow.Show(fStdResPlotWindowShape.shown, { redraw: } FALSE);
		END;
	END;
END;

{ -----------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TEasyFitApplication.AboutToLoseControl(convertClipboard: BOOLEAN); OVERRIDE;
BEGIN
	{ Remove Edit menu buzzwords for incoming Desk Accessory }
	FixEditMenu;
	INHERITED AboutToLoseControl(convertClipboard);
END;

{ -----------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TEasyFitApplication.DoSetupMenus; OVERRIDE;
BEGIN
	INHERITED DoSetupMenus;							{ First, let MacApp do its stuff }
	
	IF gDocList.fSize > 0 THEN BEGIN		{�if a document exists }
		Enable(cNew, FALSE);							{ Only one doc at a time. }
		Enable(cOpen, FALSE);

		Enable(cDataWindow, TRUE);				{ These windows are available }
		Enable(cParamsWindow, TRUE);
		Enable(cWeightsWindow, TRUE);
		Enable(cStdResWindow, TRUE);
		Enable(cDosesWindow, TRUE);
		{$IFC qConstraints}
		Enable(cConstraintsWindow, TRUE);
		{$ENDC}
		Enable(cMsgsWindow, TRUE);
		Enable(cDataAndFuncPlotWindow, TRUE);
		Enable(cStdResPlotWindow, TRUE);
	END;
	Enable(cAboutApp, NOT gWorking);
	Enable(cAboutIRFMN, NOT gWorking);
	
	FixEditMenu;
END;

{ -----------------------------------------------------------------------------------}
{$S ASelCommand}

FUNCTION TEasyFitApplication.DoMenuCommand(aCmdNumber: cmdNumber): TCommand; OVERRIDE;
BEGIN	
	DoMenuCommand := gNoChanges;
	CASE aCmdNumber OF
		cAboutIRFMN:
			DoShowAboutMarioNegri;
			
		cDataWindow:
			BEGIN
				fEasyFitDocument.fExpDataTable.fTableWindow.Show(TRUE, FALSE);
				fEasyFitDocument.fExpDataTable.fTableWindow.Select;
			END;
		cParamsWindow:
			BEGIN
				fEasyFitDocument.fParamsTable.fTableWindow.Show(TRUE, FALSE);
				fEasyFitDocument.fParamsTable.fTableWindow.Select;
			END;
		cWeightsWindow:
			BEGIN
				fEasyFitDocument.fWeightsTable.fTableWindow.Show(TRUE, FALSE);
				fEasyFitDocument.fWeightsTable.fTableWindow.Select;
			END;
		cStdResWindow:
			BEGIN
				fEasyFitDocument.fStdResTable.fTableWindow.Show(TRUE, FALSE);
				fEasyFitDocument.fStdResTable.fTableWindow.Select;
			END;
		cDosesWindow:
			BEGIN
				fEasyFitDocument.fDosesTable.fTableWindow.Show(TRUE, FALSE);
				fEasyFitDocument.fDosesTable.fTableWindow.Select;
			END;
		{$IFC qConstraints}
		cConstraintsWindow:
			BEGIN
				fEasyFitDocument.fConstraintsTable.fTableWindow.Show(TRUE, FALSE);
				fEasyFitDocument.fConstraintsTable.fTableWindow.Select;
			END;
		{$ENDC}
		cMsgsWindow:
			BEGIN
				fEasyFitDocument.fMessagesWindow.fWindow.Show(TRUE, FALSE);
				fEasyFitDocument.fMessagesWindow.fWindow.Select;
			END;
		cDataAndFuncPlotWindow:
			BEGIN
				fEasyFitDocument.fDataAndFuncPlotWindow.Show(TRUE, FALSE);
				fEasyFitDocument.fDataAndFuncPlotWindow.Select;
			END;
		cStdResPlotWindow:
			BEGIN
				fEasyFitDocument.fStdResPlotWindow.Show(TRUE, FALSE);
				fEasyFitDocument.fStdResPlotWindow.Select;
			END;

		OTHERWISE
			DoMenuCommand := INHERITED DoMenuCommand(aCmdNumber);
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S AClipboard}

FUNCTION TEasyFitApplication.MakeViewForAlienClipboard: TView; OVERRIDE;
 { Launch a view to represent the data found in the Clipboard at
   application start-up time, or when returning from an excursion
   to Switcher, or when returning from a Desk Accessory.  This
   creates a clipboard for our type of scrap.  }
	
	VAR 
		EasyFitScrap:		Handle;
		scrapOffset:		LONGINT;
		scrapLength:		LONGINT;
		clipTable:			TTable;
		clipView:				TCellsView;
		scrapInfo:			ScrapInfoRecord;
		r:							RowNumber;
		c:							ColumnNumber;
		i:							INTEGER;
		cellsRead:			INTEGER;
		cellCoord:			Point;
		offset: 				LONGINT;
		aRow:						TRow;
		aColumn:				TColumn;
		aCell:					TCell;
		perm:						BOOLEAN;
		fi: 						FailInfo;


		PROCEDURE HdlScrapFailure(error: OSErr; message: LONGINT);
		BEGIN
			{�There's need for improvement here. It should also close the view. 
				But maybe that's already done by MacApp }
			DisposIfHandle(EasyFitScrap);
			FreeIfObject(clipTable);
		END;

BEGIN																	{�makeViewForAlienClipboard }
	clipTable := NIL;										{ so failure handler works }
	EasyFitScrap := NIL;
	CatchFailures(fi, HdlScrapFailure);

	{ Before doing anything else, make sure the scrap contains my type }
	IF GetScrap(NIL, kTableScrapType, offset) > 0 THEN BEGIN
		EasyFitScrap := NewPermHandle(0);
		FailNIL(EasyFitScrap);

		perm := PermAllocation(TRUE);
		scrapLength := GetScrap(EasyFitScrap, kTableScrapType, offset);
		perm := PermAllocation(perm);

  	{ Only a negative result indicates an error--FailOSErr considers any 
			non-zero result an error. }
		IF scrapLength < 0 THEN
			FailOSErr(scrapLength);
	
		scrapOffset := 0;

		{�Now our scrap has been transferred into our handle 'EasyFitScrap', and
			from now on we extract informations from there. }
		
		{�get first the scrapinfo record }
		ReadScrap(EasyFitScrap, scrapOffset, @scrapInfo, SIZEOF(scrapInfo));
		FailMemError;
		
		{�create an ad hoc table and view }
		NEW(clipTable);
		FailNIL(clipTable);
		clipTable.ITable(scrapInfo.selection, 
										 NIL,									{ its document, unused }
										 gClipFormat,
										 0); 									{�unused }
		clipTable.DoInitialState;

		NEW(clipView);
		FailNIL(clipView);
		clipView.ICellsView(clipTable, TRUE, NIL);
		clipTable.fCellsView := clipView;

		{�create the clipTable's rows and cols }
		FOR r := 1 TO clipTable.fNoOfRows DO BEGIN
			NEW(aRow);
			aRow.ReadFromScrap(EasyFitScrap, scrapOffset);
			clipTable.AddRow(aRow);
		END;

		FOR c := 1 TO clipTable.fNoOfColumns DO BEGIN
			NEW(aColumn);
			aColumn.ReadFromScrap(EasyFitScrap, scrapOffset);
			clipTable.AddColumn(aColumn);
		END;

		{ read all of the cells from the scrap }
		cellsRead := 0;
		FOR i := 1 TO scrapInfo.noOfCells DO BEGIN
			ReadScrap(EasyFitScrap, scrapOffset, @cellCoord, SIZEOF(cellCoord));
			aCell := clipTable.GetCell(cellCoord.v, cellCoord.h);
			aCell.ReadFromScrap(EasyFitScrap, scrapOffset);
			cellsRead := cellsRead + 1;
		END;

		{$IFC qDebug}
		IF gIntenseDebugging THEN BEGIN
			WRITELN('MakeViewForAlienClipboard: cellsRead=', cellsRead: 0, ', scrapInfo.noOfCells=',
					scrapInfo.noOfCells);
			IF cellsRead <> scrapInfo.noOfCells THEN
				ProgramBreak('MakeViewForAlienClipboard: Wrong number of cells');
		END;
		{$ENDC}

		DisposHandle(EasyFitScrap);
		MakeViewForAlienClipboard := clipView;
	END
	ELSE
		{ let MacApp create the view }
		MakeViewForAlienClipboard := INHERITED MakeViewForAlienClipboard;
	Success(fi);
END;

{ ---------------------------------------------------------------------------------- }
{$S AFields}

PROCEDURE TEasyFitApplication.Fields(PROCEDURE DoToField(fieldName: Str255;
			fieldAddr: Ptr; fieldType: INTEGER)); OVERRIDE;
BEGIN
	DoToField('TEasyFitApplication', NIL, bClass);
	DoToField('fEasyFitDocument', @fEasyFitDocument, bObject);
	DoToField('pMessagesWindow', @pMessagesWindow, bObject);
	DoToField('pWorkingDialog', @pWorkingDialog, bObject);
	DoToField('gSubjectModified', @gSubjectModified, bInteger);
	DoToField('gWorking', @gWorking, bBoolean);
	DoToField('gMissing', @gMissing, bExtended);
	DoToField('gWatchHdl', @gWatchHdl, bHandle);
	DoToField('gX', @gX, bPointer);
	DoToField('gY', @gY, bPointer);
	DoToField('gSqrtWeights', @gSqrtWeights, bPointer);
	DoToField('gParams', @gParams, bPointer);
	DoToField('gLowConstraints', @gLowConstraints, bPointer);
	DoToField('gHiConstraints', @gHiConstraints, bPointer);
	DoToField('gPlaces', @gPlaces, bPointer);
	DoToField('gDose', @gDose, bExtended);
	{$IFC qXMDLs}
	DoToField('gXMDL', @gXMDL, bHandle);
	{$ENDC}
	
	INHERITED Fields(DoToField);
END;	

{ ***********************************************************************************}
{ ******										TEasyFitDocument																	****** }
{ ***********************************************************************************}
{$S AOpen}
				
PROCEDURE TEasyFitDocument.IEasyFitDocument;
VAR
	aList:								TList;
	aExpDataTable:				TExpDataTable;
	aParamsTable:					TParamsTable;
	aStdResTable:					TStdResTable;
	aWeightsTable:				TWeightsTable;
	aDosesTable:					TDOsesTable;
	aConstraintsTable:		TConstraintsTable;
	aMultiTE:							TMultiTE;
		
BEGIN
	fTablesList := NIL;

	fExpDataTable := NIL;
	fParamsTable := NIL;
	fStdResTable := NIL;
	fWeightsTable := NIL;
	fDosesTable := NIL;
{$IFC qConstraints}
	fConstraintsTable := NIL;
{$ENDC}
	fMessagesWindow := NIL;
	fDataAndFuncPlotWindow := NIL;
	fStdResPlotWindow := NIL;
	fMessagesText := NIL;
	
	IDocument(kFileType, kSignature, kUsesDataFork, NOT kUsesRsrcFork, NOT kDataOpen,
			  		NOT kRsrcOpen);

	fSavePrintInfo := TRUE;
	fIdleFreq := kEasyFitIdleFreq;
	
	New(aList);
	fTablesList := aList;
	FailNil(fTablesList);
	fTablesList.IList;
	{$IFC qDebug}
	fTablesList.SetEltType('TTable');
	{$ENDC}
	
	New(aExpDataTable);
	fExpDataTable := aExpDataTable;
	FailNil(fExpDataTable);
	fExpDataTable.IExpDataTable(SELF, gDefaultFormat);
	fTablesList.InsertLast(fExpDataTable);
	
	New(aParamsTable);
	fParamsTable := aParamsTable;
	FailNil(fParamsTable);
	fParamsTable.IParamsTable(SELF, gDefaultFormat);
	fTablesList.InsertLast(fParamsTable);

	New(aStdResTable);
	fStdResTable := aStdResTable;
	FailNil(fStdResTable);
	fStdResTable.IStdResTable(SELF, gDefaultFormat);
	fTablesList.InsertLast(fStdResTable);

	New(aWeightsTable);
	fWeightsTable := aWeightsTable;
	FailNil(fWeightsTable);
	fWeightsTable.IWeightsTable(SELF, gDefaultFormat);
	fTablesList.InsertLast(fWeightsTable);
	
	New(aDosesTable);
	fDosesTable := aDosesTable;
	FailNil(fDosesTable);
	fDosesTable.IDosesTable(SELF, gDefaultFormat);
	fTablesList.InsertLast(fDosesTable);

{$IFC qConstraints}
	New(aConstraintsTable);
	fConstraintsTable := aConstraintsTable;
	FailNil(fConstraintsTable);
	fConstraintsTable.IConstraintsTable(SELF, gDefaultFormat);
	fTablesList.InsertLast(fConstraintsTable);
{$ENDC}

	New(aMultiTE);
	fMessagesWindow := aMultiTE;
	FailNil(fMessagesWindow);
	aMultiTE.IMultiTE(SELF);
END;

{ ----------------------------------------------------------------------------------- }
{$S ARes}

FUNCTION TEasyFitDocument.DoIdle(phase: IdlePhase): BOOLEAN; OVERRIDE;
BEGIN
	IF (phase = idleContinue) 
			& ((gSubjectModified < 0) | (gSubjectModified = fDataAndFuncPlotWindow.fSubject))
	THEN BEGIN
		fDataAndFuncPlotWindow.ForceRedraw;
		gSubjectModified := 0;
	END;

	DoIdle := FALSE;									{ Did not free myself }
END;

{ -----------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TEasyFitDocument.Close; OVERRIDE;
BEGIN
	IF gWorking THEN
		RemindUserWeAreWorking
	ELSE
		INHERITED Close;
END;

{ -----------------------------------------------------------------------------------}
{$S AOpen}

PROCEDURE TEasyFitDocument.DoInitialState; OVERRIDE;
CONST kTitleBarHeight = 20;				{�The heigth of the title bar of a window.
																		Actually this shouldn't be a constant.
																		This code is not script manager compatible;
																		we don't care in this first version of the
																		application. }
VAR retStr:					STRING[1];
		tmpStr:					Str255;
		tmpHandle:			Handle;
		nParams:				INTEGER;
		whereError:			LONGINT;
		errMsg:					Str255;
		aShape:					WindowShapeData;
		aPoint:					Point;
		
	PROCEDURE DoYourInitialState(t: TTable);
	BEGIN
		t.DoInitialState;
		t.fFormat := gDefaultFormat;
	END;

	{ Makes sure that all of the window is totally on the screen. This is because
		the stupid ForceOnScreen only forces part of the window on screen.
		This proc is called only when a document is new. If a document is old,
		then it may be that the user intentionally left a window partially out
		of the screen. }
	PROCEDURE ForceShapeTotallyOnScreen(VAR aShape: WindowShapeData);
	CONST
		kSlop = 4;		{ Arbitrary }
	VAR
		hor:				LONGINT;
		vert:  			LONGINT;
	BEGIN
		WITH aShape.globalBounds DO BEGIN
			hor := right - screenBits.Bounds.right;
			IF hor > 0 THEN BEGIN
				right := right - hor - kSlop;
				left := left - hor - kSlop;
			END;
			vert := bottom - screenBits.Bounds.bottom;
			IF vert > 0 THEN BEGIN
				bottom := bottom - vert - kSlop;
				top := top - vert - kSlop;
			END;
		END;
	END;

	
BEGIN
	fFormat := gDefaultFormat;
	fTablesList.Each(DoYourInitialState);
	fWeightsOption := noWeights;
	fModelNumber := kSingleExp;			{�default model }
	fRefreshPlotsEachIteration := FALSE;
	fBeepWhenFitDone := FALSE;
	fUnattended := FALSE;
	fFullOutput := FALSE;
	fAutomaticPeeling := TRUE;
	fLambdaAtSTart := 0.1;
	fMaxIterations := 30;
	
	{ Set window initial position and size }
	aShape.shown := TRUE;
	SetRect(aShape.globalBounds, 	
						kSpaceFromScreenCorners, 
						gMBarHeight + kTitleBarHeight + kSpaceFromScreenCorners,
						kTableWindowDefaultHorSize + kSpaceFromScreenCorners,
						kTableWindowDefaultVertSize + gMBarHeight + kTitleBarHeight + kSpaceFromScreenCorners);
	ForceShapeTotallyOnScreen(aShape);
	fExpDataWindowShape := aShape;
	
	aShape.shown := FALSE;
	aPoint.h := kStdStaggerAmount;
	aPoint.v := kStdStaggerAmount;
	AddPt(aPoint, aShape.globalBounds.topLeft);
	AddPt(aPoint, aShape.globalBounds.botRight);
	ForceShapeTotallyOnScreen(aShape);
	fParamsWindowShape := aShape;
	
	AddPt(aPoint, aShape.globalBounds.topLeft);
	AddPt(aPoint, aShape.globalBounds.botRight);
	ForceShapeTotallyOnScreen(aShape);
	fWeightsWindowShape := aShape;
	
	AddPt(aPoint, aShape.globalBounds.topLeft);
	aShape.globalBounds.right := aShape.globalBounds.left + kTableWindowDefaultHorSize;
	aShape.globalBounds.bottom := aShape.globalBounds.top + kDosesWindowHeight;
	ForceShapeTotallyOnScreen(aShape);
	fDosesWindowShape := aShape;

	{$IFC qConstraints}
	AddPt(aPoint, aShape.globalBounds.topLeft);
	aShape.globalBounds.right := aShape.globalBounds.left + kConstraintsSizeH;
	aShape.globalBounds.bottom := aShape.globalBounds.top + kTableWindowDefaultVertSize;
	ForceShapeTotallyOnScreen(aShape);
	fConstraintsWindowShape := aShape;
	{$ENDC}

	AddPt(aPoint, aShape.globalBounds.topLeft);
	aShape.globalBounds.right := aShape.globalBounds.left + kTableWindowDefaultHorSize;
	aShape.globalBounds.bottom := aShape.globalBounds.top + kTableWindowDefaultVertSize;
	ForceShapeTotallyOnScreen(aShape);
	fMessagesWindowShape := aShape;

	AddPt(aPoint, aShape.globalBounds.topLeft);
	aShape.globalBounds.right := aShape.globalBounds.left + kTableWindowDefaultHorSize;
	aShape.globalBounds.bottom := aShape.globalBounds.top + kTableWindowDefaultVertSize;
	ForceShapeTotallyOnScreen(aShape);
	fStdResWindowShape := aShape;

	AddPt(aPoint, aShape.globalBounds.topLeft);
	aShape.globalBounds.right := aShape.globalBounds.left + kPlotWindowDefaultWidth;
	aShape.globalBounds.bottom := aShape.globalBounds.top + kPlotWindowDefaultHeight;
	ForceShapeTotallyOnScreen(aShape);
	fDataAndFuncPlotWindowShape := aShape;

	AddPt(aPoint, aShape.globalBounds.topLeft);
	aShape.globalBounds.right := aShape.globalBounds.left + kPlotWindowDefaultWidth;
	aShape.globalBounds.bottom := aShape.globalBounds.top + kPlotWindowDefaultHeight;
	ForceShapeTotallyOnScreen(aShape);
	fStdResPlotWindowShape := aShape;

	{�Set the default user model }
	retStr[1] := chReturn;	{�Init this small temporary string }
	retStr[0] := chr(1);
	tmpStr := 
		Concat('{ Put here your own model, e.g. like this: }',
					 retStr,
					 '    y := p1 * exp( -p2 * x);',
					 retStr);
	fUserModelText := NewPermString(tmpStr);
	FailNil(fUserModelText);
	
	{�Now we compile the default model; so, if the user tries to use it 
		without calling the "define user model" dialog, the interpreter will not crash. }
	tmpHandle := fUserModelText;
	IF CompileUserModel(tmpHandle , whereError, nParams, errMsg) <> 0 THEN BEGIN
		{�Failed compilation of the default model!!! call failure as a 
			generic programming error }
		{$IFC qDebug}
		Writeln('Error mesg: ', errMsg);
		Writeln('whereError: ', whereError);
		Writeln('handle to text: ', ORD4(fUserModelText));
		ProgramBreak('Failed compilation of the default model!');
		{$ENDC}
		Failure(maxErr, 0);
	END
	ELSE
		SetUserModelNParams(nParams);
END;

{ -----------------------------------------------------------------------------------}
{$S ACompileUserModel}

FUNCTION TEasyFitDocument.CompileUserModel(modelHandle: Handle; 
						VAR where: LONGINT; VAR NParams: INTEGER; VAR errString: Str255): INTEGER;
VAR compileResult: INTEGER;
		size: INTEGER;
		fi: FailInfo;
		
	PROCEDURE HdlCompileFailure(error: OSErr; message: LONGINT);
	BEGIN
		HUnlock(modelHandle);
	END;
	
	FUNCTION compile(progText: Ptr; VAR where: LONGINT; VAR NParams: INTEGER;
										errString: Str255): INTEGER; C; EXTERNAL;

	FUNCTION ForceCStyle(h: Handle): Handle; C; EXTERNAL;

BEGIN
	{�Add a null at the end of the handle, so we make it a C string }
	FailNIL(ForceCStyle(modelHandle));

	{�Lock the handle since we are going to dereference it }	
	MoveHHi(modelHandle);
	HLock(modelHandle);
	CatchFailures(fi, HdlCompileFailure);
	
	compileResult := compile(modelHandle^, where, NParams, errString);
	
	HUnLock(modelHandle);
	Success(fi);

	{�Remove the null character }
	size := GetHandleSize(modelHandle);
	SetPermHandleSize(modelHandle, size - 1);
	
	CompileUserModel := compileResult;
END;

{ -----------------------------------------------------------------------------------}
{$S AOpen}

PROCEDURE TEasyFitDocument.DoMakeViews(forPrinting: BOOLEAN); OVERRIDE;
CONST kDataAndFuncPlotWindowType = 1030;
			kStdResPlotWindowType = 1040;
VAR aWindow:									TWindow;
		aPlotPrintHandler:				TPlotPrintHandler;
		aView:										TView;
		tmpHandle:								handle;
		aShape:										WindowShapeData;
		
	PROCEDURE SetUpWindow(w: TWindow; VAR shape: WindowShapeData);
	BEGIN
		WITH shape.globalBounds DO BEGIN
			MoveWindow(w.fWmgrWindow, left, top, FALSE);
			SizeWindow(w.fWmgrWindow, right - left, bottom - top, FALSE);
		END;
		w.ForceOnScreen;
	END;
	
BEGIN
	fExpDataTable.DoMakeViews(forPrinting);
	aShape := fExpDataWindowShape;
	SetUpWindow(fExpDataTable.fTableWindow, aShape);
	
	fParamsTable.DoMakeViews(forPrinting);
	aShape := fParamsWindowShape;
	SetUpWindow(fParamsTable.fTableWindow, aShape);
	
	fWeightsTable.DoMakeViews(forPrinting);
	aShape := fWeightsWindowShape;
	SetUpWindow(fWeightsTable.fTableWindow, aShape);
	
	fDosesTable.DoMakeViews(forPrinting);
	aShape := fDosesWindowShape;
	SetUpWindow(fDosesTable.fTableWindow, aShape);

	{$IFC qConstraints}
	fConstraintsTable.DoMakeViews(forPrinting);
	aShape := fConstraintsWindowShape;
	SetUpWindow(fConstraintsTable.fTableWindow, aShape);
	{$ENDC}
	
	tmpHandle := fMessagesText;
	fMessagesWindow.DoMakeViews(forPrinting, tmpHandle);
	aShape := fMessagesWindowShape;
	SetUpWindow(fMessagesWindow.fWindow, aShape);
	{ Set up this global }
	pMessagesWindow := fMessagesWindow;
	
	fStdResTable.DoMakeViews(forPrinting);
	aShape := fStdResWindowShape;
	SetUpWindow(fStdResTable.fTableWindow, aShape);

	{�Create the Data & Func Plot window }
	aWindow := NewTemplateWindow(kDataAndFuncPlotWindowType, SELF);
	FailNIL(aWindow);
	fDataAndFuncPlotWindow := TPlotWindow(aWindow);
	fDataAndFuncPlotWindow.IPlotWindow;
	aShape := fDataAndFuncPlotWindowShape;
	SetUpWindow(fDataAndFuncPlotWindow, aShape);
	
	NEW(aPlotPrintHandler);
	FailNIL(aPlotPrintHandler);
	aView := fDataAndFuncPlotWindow.fPrintView;
	aPlotPrintHandler.IStdPrintHandler(SELF,						{ its document }
																		 aView,						{ its view }
																		 kSquareDots,			{ has square dots }
																		 kFixedSize,			{ horizontal page size is fixed }
																		 kFixedSize);			{ vertical page size is fixed }

	{�Create the Std res. Plot window }
	aWindow := NewTemplateWindow(kStdResPlotWindowType, SELF);
	FailNIL(aWindow);
	fStdResPlotWindow := TPlotWindow(aWindow);
	fStdResPlotWindow.IPlotWindow;
	aShape := fStdResPlotWindowShape;
	SetUpWindow(fStdResPlotWindow, aShape);

	NEW(aPlotPrintHandler);
	FailNIL(aPlotPrintHandler);
	aView := fStdResPlotWindow.fPrintView;
	aPlotPrintHandler.IStdPrintHandler(SELF,						{ its document }
																		 aView,						{ its view }
																		 kSquareDots,			{ has square dots }
																		 kFixedSize,			{ horizontal page size is fixed }
																		 kFixedSize);			{ vertical page size is fixed }
END;

{ -----------------------------------------------------------------------------------}
{$S AClose}

PROCEDURE TEasyFitDocument.Free; OVERRIDE;
LABEL
	99;
VAR
	fi: FailInfo;
	
	PROCEDURE DocFreeErr(error: OSErr; message: LONGINT);
	BEGIN
		gApplication.ShowError(error, message);
		GOTO 99;
	END;
	
BEGIN
	FreeIfObject(fTablesList);
	FreeIfObject(fExpDataTable);
	FreeIfObject(fParamsTable);
	FreeIfObject(fStdResTable);
	FreeIfObject(fWeightsTable);
	FreeIfObject(fDosesTable);
{$IFC qConstraints}
	FreeIfObject(fConstraintsTable);
{$ENDC}
	FreeIfObject(fMessagesWindow);
	FreeIfObject(fDataAndFuncPlotWindow);
	FreeIfObject(fStdResPlotWindow);

	pMessagesWindow := NIL;		{�Let everyone  know it's invalid }
	
	IF fModelNumber = kXMDL THEN BEGIN
		CatchFailures(fi, DocFreeErr);
		FreeXMDL(gXMDL);
		Success(fi);
	END;
99:

	INHERITED Free;
END;

{ -----------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TEasyFitDocument.FreeData; OVERRIDE;
LABEL 99;
VAR fi: FailInfo;

	PROCEDURE FreeYourData(t: TTable);
	BEGIN
		t.FreeData;
	END;
	
	PROCEDURE EsftRevertErr(error: OSErr; message: LONGINT);
	BEGIN
		gApplication.ShowError(error, message);
		GOTO 99;
	END;
	
BEGIN
	fTablesList.Each(FreeYourData);
	
	IF fModelNumber = kXMDL THEN BEGIN
		CatchFailures(fi, EsftRevertErr);
		FreeXMDL(gXMDL);
		Success(fi);
	END;
99:

	{�Now we cut out the text in the Msgs window }
	IF (fMessagesWindow <> NIL) & (fMessagesWindow.fTEView <> NIL) THEN
		fMessagesWindow.fTEView.SetText('')
	ELSE
		fMessagesText := NIL;
END;

{ ------------------------------------------------------------------------------------ }
{$S MAReadFile}

PROCEDURE TEasyFitDocument.Revert; OVERRIDE;
BEGIN
	INHERITED Revert;
	
	{�Install the msgs text }
	IF fMessagesText <> NIL THEN BEGIN
		fMessagesWindow.fTEView.StuffText(fMessagesText);
		{�fMessagesWindow.Synch; }
	END;
END;

{ ------------------------------------------------------------------------------------ }
{$S ASelCommand}

FUNCTION TEasyFitDocument.DoMenuCommand(aCmdNumber: cmdNumber): TCommand; OVERRIDE;
VAR
	r:								Rect;
	aFormatter:				TFormatter;
	aClearMessages:		TClearMessagesCommand;
	{$IFC qXMDLs}
	menuID:						INTEGER;
	item:							INTEGER;
	{$ENDC}
		
	{$IFC qXMDLs}
	PROCEDURE ClearXMDL;
	LABEL
		99;
	VAR
		fi: FailInfo;
		
		PROCEDURE ClearXMDLErr(error: OSErr; message: LONGINT);
		BEGIN
			gApplication.ShowError(error, message);
			GOTO 99;
		END;
		
	BEGIN
		IF fModelNumber = kXMDL THEN BEGIN
			CatchFailures(fi, ClearXMDLErr);
			FreeXMDL(gXMDL);
			Success(fi);
		END;
	99:
	END;

	PROCEDURE DoSetXMDL;
	VAR
		aMenuHandle: 	MenuHandle;
		aName:				Str255;
		fi:						FailInfo;
		thisXMDL:			Handle;
		
	BEGIN
		gApplication.CommitLastCommand;
		
		{�Get the command name }
		aMenuHandle := GetResMenu(menuID);
		FailNILResource(Handle(aMenuHandle));
		GetItem(aMenuHandle, item, aName);
		
		{�See if it is the same XMDL as before }
		IF (fModelNumber = kXMDL) & (fXMDLName = aName) THEN
			Exit(DoSetXMDL);
		
		{�Initialize and load the XMDL }
		thisXMDL := LoadXMDL(aName);
		fXMDLName := aName;
		
		{�Initialization of XMDL didn't fail. So we clear the previous
			model, in case it was a XMDL too. }
		ClearXMDL;

		{ We set a last few things, then we are done }
		gXMDL := thisXMDL;
		fXMDLName := aName;
		fModelNumber := kXMDL;
		fDataAndFuncPlotWindow.ForceRedraw;
		fChangeCount := fChangeCount + 1;
	END;
	{$ENDC}
	
BEGIN												{ TEasyFitDocument.DoMenuCommand }
	DoMenuCommand := gNoChanges;
	
	{$IFC qXMDLs}
	IF aCmdNumber < 0 THEN BEGIN
		CmdToMenuItem(aCmdNumber, menuID, item);
		IF menuID = mModel THEN
			DoSetXMDL;
		EXIT(DoMenuCommand);
	END;
	{$ENDC}
	
	CASE aCmdNumber OF
	
		cClearMessages:
			BEGIN
				NEW(aClearMessages);
				FailNIL(aClearMessages);
				aClearMessages.IClearMessagesCommand(aCmdNumber, SELF);
				DoMenuCommand := aClearMessages;
			END;
			
		cGeneral,
		cDecimal,
		cScientific,
		cLeftJustify,
		cRightJustify,
		cCenter,
		cNoDigits,
		c1Digit,
		c2Digits,
		c3Digits,
		c4Digits,
		c5Digits,
		c6Digits,
		c7Digits,
		c8Digits,
		c9Digits,
		c10Digits,
		c11Digits,
		c12Digits:
			BEGIN
				NEW(aFormatter);
				FailNIL(aFormatter);
				aFormatter.IFormatter(SELF, aCmdNumber);
				DoMenuCommand := aFormatter;
			END;
		
		cNoWeights:
			BEGIN
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fWeightsOption := noWeights;
			END;	
		cOneOverObsValue:
			BEGIN
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fWeightsOption := oneOverYObserved;
			END;	
		cOneOverSqObsValue:
			BEGIN
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fWeightsOption := oneOverSquaredYObserved;
			END;	
		cOneOverEstimatedValue:
			BEGIN
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fWeightsOption := oneOverYEstimated;
			END;
		cOneOverSqEstimatedValue:
			BEGIN
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fWeightsOption := oneOverSquaredYEstimated;
			END;
		cELSWeights:
			BEGIN
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fWeightsOption := ELS;
			END;
		cInputByHand:
			BEGIN
				{�Set the weights window as read + write }
				
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fWeightsOption := inputByUser;
			END;
		
		cDataAndFuncPlotOptions:
			fDataAndFuncPlotWindow.MakeDialog;
		cStdResPlotOptions:
			fStdResPlotWindow.MakeDialog;
		cFitOptions: 
			MakeFitOptionsDlog;
		cFit: 
			BEGIN
				fChangeCount := fChangeCount + 1;
				DoFit;
			END;
		
		cSingleExp:
			IF fModelNumber <> kSingleExp THEN BEGIN
				{$IFC qXMDLs}
				ClearXMDL;
				{$ENDC}
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fModelNumber := kSingleExp;
				fDataAndFuncPlotWindow.ForceRedraw;
			END;
		cTwoExpPlus: 
			IF fModelNumber <> kTwoExpPlus THEN BEGIN
				{$IFC qXMDLs}
				ClearXMDL;
				{$ENDC}
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fModelNumber := kTwoExpPlus;
				fDataAndFuncPlotWindow.ForceRedraw;
			END;
		cTwoExpMinus: 
			IF fModelNumber <> kTwoExpMinus THEN BEGIN
				{$IFC qXMDLs}
				ClearXMDL;
				{$ENDC}
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fModelNumber := kTwoExpMinus;
				fDataAndFuncPlotWindow.ForceRedraw;
			END;
		cThreeExpPlus: 
			IF fModelNumber <> kThreeExpPlus THEN BEGIN
				{$IFC qXMDLs}
				ClearXMDL;
				{$ENDC}
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fModelNumber := kThreeExpPlus;
				fDataAndFuncPlotWindow.ForceRedraw;
			END;
		cThreeExpMinus: 
			IF fModelNumber <> kThreeExpMinus THEN BEGIN
				{$IFC qXMDLs}
				ClearXMDL;
				{$ENDC}
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				fModelNumber := kThreeExpMinus;
				fDataAndFuncPlotWindow.ForceRedraw;
			END;
		cUserDefined: 
			BEGIN
				{$IFC qXMDLs}
				ClearXMDL;
				{$ENDC}
				gApplication.CommitLastCommand;
				fChangeCount := fChangeCount + 1;
				
				{�Change the model number only if the user exited the dialog
					with 'OK' }
				IF MakeUserModelDlog THEN BEGIN
					fDataAndFuncPlotWindow.ForceRedraw;
					fModelNumber := kUserDefined;
				END;
			END;
			
		OTHERWISE
			DoMenuCommand := INHERITED DoMenuCommand(aCmdNumber);
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TEasyFitDocument.DoSetupMenus; OVERRIDE;
VAR
	justification:		INTEGER;
	style:						TypeOfStyle;
	digits:						INTEGER;
	item:							INTEGER;
	aMenuHandle:			MenuHandle;
	aName:						Str255;	
BEGIN

	INHERITED DoSetupMenus;		{�Set up Open, Close, etc. }
	
	Enable(cClearMessages, NOT gWorking);
	
	IF gWorking THEN BEGIN
		Enable(cSave, FALSE);
		Enable(cSaveAs, FALSE);
		Enable(cSaveCopy, FALSE);
		Enable(cRevert, FALSE);
		Enable(cPageSetup, FALSE);
		Enable(cPrint, FALSE);
	END;
	
	justification := fFormat.fJustification;
	style := fFormat.fStyle;
	digits := fFormat.fDigits;

	{�The following things will be enabled only if we're not fitting; 
		This is to prevent user from changing things needed during the computation,
		or to prevent user confusion during the fit by allowing 
		access to unnecessary things like formats. }
		
	EnableCheck(cLeftJustify, NOT gWorking, justification = teJustLeft);
	EnableCheck(cRightJustify, NOT gWorking, justification = teJustRight);
	EnableCheck(cCenter, NOT gWorking, justification = TEJustCenter);
	EnableCheck(cGeneral, NOT gWorking, style = General);
	EnableCheck(cDecimal, NOT gWorking, style = DecimalStyle);
	EnableCheck(cScientific, NOT gWorking, style = Scientific);
	EnableCheck(cNoDigits, NOT gWorking, digits = 0);
	EnableCheck(c1Digit, NOT gWorking, digits = 1);
	EnableCheck(c2Digits, NOT gWorking, digits = 2);
	EnableCheck(c3Digits, NOT gWorking, digits = 3);
	EnableCheck(c4Digits, NOT gWorking, digits = 4);
	EnableCheck(c5Digits, NOT gWorking, digits = 5);
	EnableCheck(c6Digits, NOT gWorking, digits = 6);
	EnableCheck(c7Digits, NOT gWorking, digits = 7);
	EnableCheck(c8Digits, NOT gWorking, digits = 8);
	EnableCheck(c9Digits, NOT gWorking, digits = 9);
	EnableCheck(c10Digits, NOT gWorking, digits = 10);
	EnableCheck(c11Digits, NOT gWorking, digits = 11);
	EnableCheck(c12Digits, NOT gWorking, digits = 12);
	
	Enable(cDataAndFuncPlotOptions, NOT gWorking);
	Enable(cStdResPlotOptions, NOT gWorking);
	Enable(cFitOptions, NOT gWorking);
	Enable(cFit, NOT gWorking);
	
	EnableCheck(cSingleExp, NOT gWorking, fModelNumber = kSingleExp);
	EnableCheck(cTwoExpPlus, NOT gWorking, fModelNumber = kTwoExpPlus);
	EnableCheck(cTwoExpMinus, NOT gWorking, fModelNumber = kTwoExpMinus);
	EnableCheck(cThreeExpPlus, NOT gWorking, fModelNumber = kThreeExpPlus);
	EnableCheck(cThreeExpMinus, NOT gWorking, fModelNumber = kThreeExpMinus);
	EnableCheck(cUserDefined, NOT gWorking, fModelNumber = kUserDefined);

	{$IFC qXMDLs}
	IF NOT gWorking THEN BEGIN
		aMenuHandle := GetResMenu(mModel);
		FailNILResource(Handle(aMenuHandle));

		FOR item := 1 TO CountMItems(aMenuHandle) DO BEGIN
			
			{ There can be more than 31 menu entries with scrolling menus, but trying to
			 enable an item with number > 31 is bad news.  If the menu itself is enabled
			 (which it will be in MacApp if any of the first 31 items is enabled), then
			 the extras will always be enabled. }
			
			IF item <= 31 THEN
				EnableItem(aMenuHandle, item);
			IF fModelNumber = kXMDL THEN BEGIN
				GetItem(aMenuHandle, item, aName);
				CheckItem(aMenuHandle, item, aName = fXMDLName);
			END;
		END;
	END;
	{$ENDC}
	
	EnableCheck(cNoWeights, NOT gWorking, fWeightsOption = noWeights);
	EnableCheck(cOneOverObsValue, NOT gWorking, fWeightsOption = oneOverYObserved);
	EnableCheck(cOneOverSqObsValue, NOT gWorking, fWeightsOption = oneOverSquaredYObserved);
	EnableCheck(cOneOverEstimatedValue, NOT gWorking, fWeightsOption = oneOverYEstimated);
	EnableCheck(cOneOverSqEstimatedValue, NOT gWorking, fWeightsOption = oneOverSquaredYEstimated);
	EnableCheck(cELSWeights, NOT gWorking, fWeightsOption = ELS);
	EnableCheck(cInputByHand, NOT gWorking, fWeightsOption = inputByUser);
END;

{ ----------------------------------------------------------------------------------- }
{$S AWriteFile}

PROCEDURE TEasyFitDocument.DoNeedDiskSpace(VAR dataForkBytes,
									 rsrcForkBytes: LONGINT); OVERRIDE;
	
	VAR tmpHandle: Handle;
	
	PROCEDURE AccountForTable(t: TTable);
	BEGIN
		t.DoNeedDiskSpace(dataForkBytes, rsrcForkBytes);
	END;

BEGIN
	{ � The version; length + 2 because the length byte is written as an integer }
	dataForkBytes := dataForkBytes + Length(kVersion) + 2;

	{ ��Print record length }	
	INHERITED DoNeedDiskSpace(dataForkBytes, rsrcForkBytes);

	{ � The model number }
	dataForkBytes := dataForkBytes + 2;

	{ � The weights option }
	dataForkBytes := dataForkBytes + 2;

	{ � Miscellanea }
	dataForkBytes := dataForkBytes + SIZEOF(Miscellanea);
	dataForkBytes := dataForkBytes + SIZEOF(PlotOptionsMiscellanea);
	
	{ʥ the tables }
	fTablesList.Each(AccountForTable);
	
	{ � The window shapes data, times 9 windows }
	dataForkBytes := dataForkBytes + 9 * SIZEOF(WindowShapeData);
	
	{ � The user model text; + 4 because the length is written as a longint }
	dataForkBytes := dataForkBytes + GetHandleSize(fUserModelText) + 4;
	
	{ʥ The msgs window text }
	tmpHandle := fMessagesWindow.fTEView.ExtractText;
	dataForkBytes := dataForkBytes + GetHandleSize(tmpHandle) + 4;
	
	{ʥ�The name of the XMDL }
	{$IFC qXMDLs}
	IF fModelNumber = kXMDL THEN
		dataForkBytes := dataForkBytes + Length(fXMDLName) + 2;
	{$ENDC}
END;

{ ----------------------------------------------------------------------------------- }
{$S AReadFile}

PROCEDURE ReadStringFromDoc(aRefNum: INTEGER; VAR strRead: Str255);
VAR IOError		: OSErr;
		size			: Longint;
		strLen		: integer;
		derefStr	: Str255;
BEGIN
	{ leggi la lunghezza della stringa (2 bytes) }
	size := sizeof(integer);
	FailOSErr(FSRead(aRefNum, size, @strLen));
	
	IF (strLen < 0) | (strLen > 255) THEN BEGIN
		ReportFileDamaged(aRefNum);
		Failure(kFileIsDamaged, 0);
	END;
	
	{ leggi la stringa }
	size := ord4(strLen);
	FailOSErr(FSRead(aRefNum, size, Pointer(ord4(@derefStr)+1)));
	
	{�Metti a posto il byte della lunghezza }
	derefStr[0] := chr(strLen);
	
	strRead := derefStr;
END;			{ ReadStringFromDoc }
	
{ ----------------------------------------------------------------------------------- }
{$S AWriteFile}

PROCEDURE WriteStringToDoc(aRefNum: INTEGER; s: Str255);
VAR i 				: integer;
		IOError		: OSErr;
		size			: Longint;
		strLen		: integer;
BEGIN
	{�scrivi sul file la lunghezza delle stringa come integer (2 byte) }
	size := sizeof(integer);
	strLen := Length(s);
	FailOSErr(FSWrite(aRefNum, size, @strLen));

	size := ord4(strLen);
	FailOSErr(FSWrite(aRefNum, size, Pointer(ord4(@s)+1)));
END;			{ WriteStringToDoc }

{ ----------------------------------------------------------------------------------- }
{$S AWriteFile}

PROCEDURE WriteHandleToDoc(aRefNum: INTEGER; h: Handle);
VAR len				: LONGINT;
		fi				: FailInfo;
	
	PROCEDURE HdlWriteFailure(error: OSErr; message: LONGINT);
	BEGIN
		HUnLock(h);
	END;

BEGIN
	len := GetHandleSize(h);
	WriteBytes(aRefNum, SIZEOF(len), @len);
	IF len > 0 THEN BEGIN
		HLock(h);
		CatchFailures(fi, HdlWriteFailure);
		WriteBytes(aRefNum, len, h^);
		HUnLock(h);
		Success(fi);
	END;
END;			{ WriteHandleToDoc }
	
{ ----------------------------------------------------------------------------------- }
{$S AReadFile}

{�Crea una handle, e vi copia il contenuto dal documento. }

PROCEDURE ReadHandleFromDoc(aRefNum: INTEGER; VAR h: Handle);
VAR len				: LONGINT;
		fi				: FailInfo;
	
	PROCEDURE HdlReadFailure(error: OSErr; message: LONGINT);
	BEGIN
		HUnlock(h);
		DisposHandle(h);
	END;

BEGIN
	ReadBytes(aRefNum, SIZEOF(len), @len);
	
	{$IFC qDebug AND qDebugFiles}
	Writeln('ReadHandleFromDoc: len of handle is ', len); 
	{$ENDC}
	
	IF len < 0 THEN BEGIN
		{$IFC qDebug}
		ProgramBreak('ReadHandleFromDoc: len of handle is negative!');
		{$ENDC}
		
		{ set msg "file is damaged, or comes from an old version of EasyFit" }
		ReportFileDamaged(aRefNum);
		Failure(kFileIsDamaged, 0);
	END;

	h := NewPermHandle(len);
	FailNil(h);
	IF len > 0 THEN BEGIN
		CatchFailures(fi, HdlReadFailure);
		HLock(h);
		ReadBytes(aRefNum, len, h^);
		HUnLock(h);
		Success(fi);
	END;
END;			{ ReadHandleFromDoc }

{ ----------------------------------------------------------------------------------- }
{$S AReadFile}

PROCEDURE TEasyFitDocument.DoRead(aRefNum: INTEGER; rsrcExists,
									 								forPrinting: BOOLEAN); OVERRIDE;
	
CONST
		kMinor = 1;	 { returned values from VersionMinor }
		kEqual = 2;
		kMajor = 3;
		kError = 4;
		
VAR whereError:			LONGINT;
		nParams:				INTEGER;
		s:							Str255;
		modelNum:				INTEGER;
		weightsOption:	INTEGER;
		docVersion:			Str255;
		tmpMisc:				Miscellanea;
		tmpOldMisc:			OldMiscellanea;
		tmpPlotMisc:		PlotOptionsMiscellanea;
		tmpOldPlotMisc:	OldPlotOptionsMiscellanea;
		tmpHandle:			Handle;
		aShape:					WindowShapeData;
		{$IFC qDebug AND qDebugFiles}
		filePos:				LONGINT;
		newFilePos:			LONGINT;
		err:						OSErr;
		{$ENDC}
		
	PROCEDURE ReadATable(t: TTable);
	VAR tableName: Str255;
	BEGIN
		ReadStringFromDoc(aRefNum, tableName);

		{$IFC qDebug AND qDebugFiles}
		Writeln('TEasyFitDocument.DoRead: read table name:', tableName);
		{$ENDC}

		IF tableName <> t.fName THEN BEGIN
			ReportFileDamaged(aRefNum);
			Failure(kFileIsDamaged, 0);
		END;

		{$IFC qDebug AND qDebugFiles}
		Writeln('TEasyFitDocument.DoRead: table name was OK');
		{$ENDC}

		t.DoRead(aRefNum, rsrcExists, forPrinting);

		{$IFC qDebug AND qDebugFiles}
		Writeln('TEasyFitDocument.DoRead: read table data');
		{$ENDC}
	END;
	
	PROCEDURE CheckBoolean(b: BOOLEAN);
	BEGIN
		IF (ORD(b) <> 0) & (ORD(b) <> 1) THEN BEGIN
			{$IFC qDebug}
			ProgramBreak('CheckBoolean: about to fail');
			{$ENDC}
			ReportFileDamaged(aRefNum);
			Failure(kFileIsDamaged, 0);
		END;
	END;
	
	PROCEDURE CheckInBounds(lowBound, i, highBound: INTEGER);
	BEGIN
		IF (i < lowBound) | (i > highBound) THEN BEGIN
			{$IFC qDebug}
			ProgramBreak('CheckInBounds: about to fail');
			{$ENDC}
			ReportFileDamaged(aRefNum);
			Failure(kFileIsDamaged, 0);
		END;
	END;

	{ Procedura che cerca di stabilire se i dati letti in miscellanea sono
		sensati, o sono corrotti. Il parametro e' VAR per motivi di efficienza }
	PROCEDURE CheckMiscellanea(VAR m: Miscellanea);			
	BEGIN
		WITH m DO BEGIN
			CheckBoolean(beepWhenFitDone);
			CheckBoolean(refreshPlots);
			CheckBoolean(unattended);
			CheckBoolean(fullOutput);
			CheckBoolean(automaticPeeling);
			CheckInBounds(0, maxIterations, MAXINT);
			IF lambdaAtStart <= 0.0 THEN BEGIN
				ReportFileDamaged(aRefNum);
				Failure(kFileIsDamaged, 0);
			END;
			{ ??? We should check the format too ??? }
		END;
		{$IFC qDebug AND qDebugFiles}
		Writeln('CheckMiscellanea: success');
		{$ENDC}
	END;

	PROCEDURE CheckPlotOptionsMiscellanea(VAR m: PlotOptionsMiscellanea);			
	BEGIN
		WITH m DO BEGIN
			CheckInBounds(0, ORD(dataAndFuncPlotDomainOption), 2);
			CheckBoolean(semilog);
			CheckBoolean(plotFast);
			CheckInBounds(0, dataAndFuncPlotXTicks, MAXINT);
			CheckInBounds(0, dataAndFuncPlotYTicks, MAXINT);
			CheckInBounds(0, ORD(stdResPlotDomainOption), 2);
			CheckInBounds(0, stdResPlotXTicks, MAXINT);
			CheckInBounds(0, stdResPlotYTicks, MAXINT);
			CheckInBounds(0, ORD(stdResPlotAgainstOption), 2);
		END;
		{$IFC qDebug AND qDebugFiles}
		Writeln('CheckPlotOptionsMiscellanea: success');
		{$ENDC}
	END;
	
	PROCEDURE ReadWindowShapeData(VAR shapeData: WindowShapeData);
	BEGIN
		ReadBytes(aRefNum, SIZEOF(shapeData), @shapeData);
	END;
	
	FUNCTION VersionMinor(VAR v1, v2: Str255): LONGINT; C; EXTERNAL;

	PROCEDURE CheckVersion(vers: Str255);
	CONST
		kMinRecognizedVersion = '1.0a7'; {�We don't try to read docs produced by EasyFit
																			 versions older than this }
	VAR
		comparison:							LONGINT;
		minRecognizedVersion:		Str255;
		
	BEGIN
		minRecognizedVersion := kMinRecognizedVersion;
		comparison := VersionMinor(vers, minRecognizedVersion);
		IF comparison = kError THEN BEGIN
			ReportFileDamaged(aRefNum);
			Failure(kFileIsDamaged, 0);
		END
		ELSE IF comparison = kMinor THEN
			Failure(kFileCreatedByOldVersion, 0);
	END;
	
	FUNCTION DocWasGeneratedByPreB3Version(vers: Str255): BOOLEAN;
	CONST
		kModernVersion = '1.0�3'; 	{�Modern docs are created by this version or later }
		
	VAR
		comparison:							LONGINT;
		modernVersion:					Str255;
		
	BEGIN
		modernVersion := kModernVersion;
		comparison := VersionMinor(vers, modernVersion);
		IF comparison = kError THEN BEGIN
			ReportFileDamaged(aRefNum);
			Failure(kFileIsDamaged, 0);
		END
		ELSE
			DocWasGeneratedByPreB3Version := comparison = kMinor;
		
		{$IFC qDebug AND qDebugFiles}
		Writeln('DocWasGeneratedByPreB3Version: returning ', comparison = kMinor,
			' comparison = ', ORD(comparison));
		{$ENDC}
	END;
	
	PROCEDURE ConvertMiscellanea(VAR new: Miscellanea; VAR old: OldMiscellanea);
	BEGIN
		WITH new, old DO BEGIN
			beepWhenFitDone :=			oldBeepWhenFitDone;
			refreshPlots :=					oldRefreshPlots;
			unattended :=						oldUnattended;
			fullOutput :=						oldFullOutput;
			automaticPeeling :=			oldAutomaticPeeling;
			maxIterations :=				oldMaxIterations;
			lambdaAtStart :=				oldLambdaAtStart;
			format :=								oldFormat;
		END;
	END;
	
	PROCEDURE ConvertPlotOptionsMiscellanea(VAR newMiscellanea: PlotOptionsMiscellanea;
			VAR oldMiscellanea: OldPlotOptionsMiscellanea);
	BEGIN
		WITH newMiscellanea, oldMiscellanea DO BEGIN
			dataAndFuncPlotDomainOption		:= oldDataAndFuncPlotDomainOption;
			semilog												:= oldSemilog;
			plotFast											:= oldPlotFast;
			WITH dataAndFuncPlotDomain, oldDataAndFuncPlotDomain DO BEGIN
				ddLeft := dLeft;
				ddRight := dRight;
				ddTop := dTop;
				ddBottom := dBottom;
			END;
			dataAndFuncPlotXTicks					:= oldDataAndFuncPlotXTicks;
			dataAndFuncPlotYTicks					:= oldDataAndFuncPlotYTicks;
			stdResPlotDomainOption				:= oldStdResPlotDomainOption;
			WITH stdResPlotDomain, oldStdResPlotDomain DO BEGIN
				ddLeft := dLeft;
				ddRight := dRight;
				ddTop := dTop;
				ddBottom := dBottom;
			END;
			stdResPlotAgainstOption				:= oldStdResPlotAgainstOption;
			stdResPlotXTicks							:= oldStdResPlotXTicks;
			stdResPlotYTicks							:= oldStdResPlotYTicks;
		END;
	END;
	
	{$IFC qXMDLs}	
	PROCEDURE CheckAndLoadXMDL(name: Str255);
	LABEL
		99;
	TYPE
		GoodOrBad = (good, bad);
	VAR
		fi:						FailInfo;
			
		{�This alert asks the user if he wants to open the document even if
			the XMDL it needed is not available. If the user says 'Open Anyway',
			then we set the model to the default one; otherwise we call
			Failure. }
		FUNCTION MakeXMDLNotPresentAlert(name: Str255): GoodOrBad;
		CONST
			kAlertXMDLNotPresent = 2003;
		VAR
			aWindow:			TWindow;
			dismisser:		IDType;
			aStaticText:	TStatictext;
		BEGIN
			aWindow := NewTemplateWindow(kAlertXMDLNotPresent, NIL);
			FailNil(aWindow);
			
			aStaticText := TStaticText(aWindow.FindSubView('text'));
			IF Length(name) > 30 THEN BEGIN {�Truncate it if it is too long }
				name[0] := chr(30);
				name[30] := '�';
			END;
			aStaticText.SetText(Concat('This document uses the "',
																 name,
																 '" External Model. That model is not present.',
																 ' If you want to use that model, you must',
																 ' restart the application putting the',
																 ' External Model file in the same folder as EasyFit.'),
													kDontRedraw);
	
			dismisser := TDialogView(aWindow.FindSubView('dlog')).PoseModally;
			IF dismisser = 'ok  ' THEN
				MakeXMDLNotPresentAlert := good
			ELSE
				MakeXMDLNotPresentAlert := bad;
			
			aWindow.Close;
		END;
	
		PROCEDURE CheckAndLoadXMDLFailure(error: OSErr; message: LONGINT);
		BEGIN
			IF MakeXMDLNotPresentAlert(name) = good THEN BEGIN
				fModelNumber := kSingleExp;
				GOTO 99;
			END;
		END;
		
	BEGIN
		{$IFC qDebug}
		Writeln('CheckAndLoadXMDL: looking for "', name, '"');
		{$ENDC}

		{�Initialize and load the XMDL }
		CatchFailures(fi, CheckAndLoadXMDLFailure);
		gXMDL := LoadXMDL(name);
		Success(fi);
		fXMDLName := name;
		fModelNumber := kXMDL;
		
	99: ;
	END;
	{$ENDC}

BEGIN	
	{ � leggi la versione di EasyFit che ha generato il doc. }
	ReadStringFromDoc(aRefNum, docVersion);
	
	{$IFC qDebug AND qDebugFiles}
	Writeln('TEasyFitDocument.DoRead: Read version string');
	{$ENDC}

	{ʥ Check per vedere se possiamo leggere questa versione }
	CheckVersion(docVersion);
	
	{ʥ�Read print record information. Note that we are assuming that nothing
			else but reading & writing the print record is done by the inherited
			DoRead and DoWrite. This is true for MacApp 2.0, but may not be true
			in later versions. }
	INHERITED DoRead(aRefNum, rsrcExists, forPrinting);
	
	{$IFC qDebug AND qDebugFiles}
	Writeln('TEasyFitDocument.DoRead: done inherited');
	{$ENDC}
	
	{ � leggi il numero del modello }
	ReadBytes(aRefNum, SIZEOF(modelNum), @modelNum);
	
	{$IFC qDebug AND qDebugFiles}
	Writeln('TEasyFitDocument.DoRead: Read model number');
	{$ENDC}

	IF (modelNum >= kSingleExp) AND (modelNum <= kTheNumberOfModels) THEN
		fModelNumber := modelNum
	ELSE BEGIN
		ReportFileDamaged(aRefNum);
		Failure(kFileIsDamaged, 0);
	END;
	
	{ � leggi l'opzione di pesatura, e fai un test }
	ReadBytes(aRefNum, SIZEOF(weightsOption), @weightsOption);
	IF (weightsOption >= ORD(noWeights)) AND (weightsOption <= ORD(inputByUser)) THEN
		fWeightsOption := WeightOption(weightsOption)
	ELSE BEGIN
		ReportFileDamaged(aRefNum);
		Failure(kFileIsDamaged, 0);
	END;

	{$IFC qDebug AND qDebugFiles}
	Writeln('TEasyFitDocument.DoRead: read weights option');
	{$ENDC}

	{ � leggi miscellanea }
	IF DocWasGeneratedByPreB3Version(docVersion) THEN BEGIN		{�read old document }
		ReadBytes(aRefNum, SIZEOF(tmpOldMisc), @tmpOldMisc);
		ConvertMiscellanea(tmpMisc, tmpOldMisc);
	END
	ELSE
		ReadBytes(aRefNum, SIZEOF(tmpMisc), @tmpMisc);
	
	{$IFC qDebug AND qDebugFiles}
	Writeln('TEasyFitDocument.DoRead: Read miscellanea');
	{$ENDC}

	CheckMiscellanea(tmpMisc);
	WITH tmpMisc DO BEGIN
		fBeepWhenFitDone								:= beepWhenFitDone;
		fRefreshPlotsEachIteration			:= refreshPlots;
		fUnattended											:= unattended;
		fFullOutput											:= fullOutput;
		fAutomaticPeeling								:= automaticPeeling;
		fMaxIterations									:= maxIterations;
		fLambdaAtStart									:= lambdaAtStart;
		fFormat													:= format;
	END;
	
	{ � leggi plot options miscellanea }
	IF DocWasGeneratedByPreB3Version(docVersion) THEN BEGIN		{�read old document }
		ReadBytes(aRefNum, SIZEOF(tmpOldPlotMisc), @tmpOldPlotMisc);
		ConvertPlotOptionsMiscellanea(tmpPlotMisc, tmpOldPlotMisc);
	END
	ELSE
		ReadBytes(aRefNum, SIZEOF(tmpPlotMisc), @tmpPlotMisc);
		
	{$IFC qDebug AND qDebugFiles}
	Writeln('TEasyFitDocument.DoRead: Read plot options miscellanea');
	{$ENDC}

	CheckPlotOptionsMiscellanea(tmpPlotMisc);
	fPlotOptionsMiscellanea := tmpPlotMisc;
	
	{ � leggi tutte le tabelle }
	fTablesList.Each(ReadATable);
	{$IFC qDebug AND qDebugFiles}
	Writeln('TEasyFitDocument.DoRead: read all of the tables');
	{$ENDC}
	
	{ʥ Read window positions and sizes }
	ReadWindowShapeData(aShape);
	fExpDataWindowShape := aShape;
	ReadWindowShapeData(aShape);
	fParamsWindowShape := aShape;
	ReadWindowShapeData(aShape);
	fWeightsWindowShape := aShape;
	ReadWindowShapeData(aShape);
	fStdResWindowShape := aShape;
	ReadWindowShapeData(aShape);
	fDosesWindowShape := aShape;
	{$IFC qConstraints}
	ReadWindowShapeData(aShape);
	fConstraintsWindowShape := aShape;
	{$ENDC}
	ReadWindowShapeData(aShape);
	fMessagesWindowShape := aShape;
	ReadWindowShapeData(aShape);
	fDataAndFuncPlotWindowShape := aShape;
	ReadWindowShapeData(aShape);
	fStdResPlotWindowShape := aShape;

	{ � Leggi il testo del modello utente }
	ReadHandleFromDoc(aRefNum, tmpHandle);
	fUserModelText := tmpHandle;
	
	{$IFC qDebug AND qDebugFiles}
	Writeln('TEasyFitDocument.DoRead: read user model text');
	{$ENDC}

	{�Now we compile the model; so, if the user tries to use it 
		without calling its dialog, the interpreter will not crash. }
	IF CompileUserModel(fUserModelText, whereError, nParams, s) <> 0 THEN BEGIN
		{�Failed compilation of the saved model }
		{$IFC qDebug}
		Writeln('Error mesg: ', s);
		Writeln('whereError: ', whereError);
		Writeln('handle to text: ', ORD4(fUserModelText));
		ProgramBreak('Failed compilation of the saved model!');
		{$ENDC}
		ReportFileDamaged(aRefNum);
		Failure(kFileIsDamaged, 0);
	END
	ELSE	{ Compilation OK }
		SetUserModelNParams(nParams);
	
	{ � Read messages text }
	ReadHandleFromDoc(aRefNum, tmpHandle);
	fMessagesText := tmpHandle;

	{$IFC qDebug AND qDebugFiles}
	Writeln('TEasyFitDocument.DoRead: read msgs window text');
	{$ENDC}

	{$IFC qXMDLs}
	{ � Read XMDL name, if present }
	IF fModelNumber = kXMDL THEN BEGIN
		ReadStringFromDoc(aRefNum, s);
		fXMDLName := s;
		CheckAndLoadXMDL(s);
	END;
	{$ENDC}
END;

{ ----------------------------------------------------------------------------------- }
{$S AWriteFile}

PROCEDURE TEasyFitDocument.DoWrite(aRefNum: INTEGER; makingCopy: BOOLEAN); OVERRIDE;
VAR s:						Str255;
		temp:					INTEGER;
		tmpMisc:			Miscellanea;
		tmpPlotMisc:	PlotOptionsMiscellanea;
		tmpHandle:		Handle;
	
	PROCEDURE WriteATable(t: TTable);
	VAR tableName: Str255;
	BEGIN
		{�We write the table name for debugging purposes. That's the only reason
			for having the fName strings. }
		tableName := t.fName;
		WriteStringToDoc(aRefNum, tableName);
		t.DoWrite(aRefNum, makingCopy);

		{$IFC qDebug AND qDebugFiles}
		ReportFilePos(aRefNum, Concat('after table ', tableName));
		{$ENDC}
	END;
	
	PROCEDURE WriteWindowShapeData(aWindow: TWindow);
	VAR aShapeData: WindowShapeData;
			s: Str255;
	BEGIN
		{$IFC qDebug}
		IF Member(aWindow, TTable) THEN BEGIN
			s := TTable(aWindow).fName;
			Writeln('WriteWindowShapeData: ', s, ', shown: ', aWindow.IsShown);
		END
		ELSE
			Writeln('WriteWindowShapeData: <not a table>, shown: ', aWindow.IsShown);
		{$ENDC}
						
		WITH aShapeData DO BEGIN
			shown := aWindow.IsShown;
			aWindow.GetGlobalBounds(globalBounds);
		END;
		WriteBytes(aRefNum, SIZEOF(aShapeData), @aShapeData);
	END;
	
BEGIN
	{ � scrivi la versione di EasyFit che ha generato il doc }
	WriteStringToDoc(aRefNum, kVersion);
	
	{$IFC qDebug AND qDebugFiles}
	ReportFilePos(aRefNum, 'after version');
	{$ENDC}
	
	{ʥ�Write print record information. Note that we are assuming that nothing
			else but reading & writing the print record is done by the inherited
			DoRead and DoWrite. This is true for MacApp 2.0, but may not be true
			in later versions. }
	INHERITED DoWrite(aRefNum, makingCopy);

	{$IFC qDebug AND qDebugFiles}
	ReportFilePos(aRefNum, 'after inherited');
	{$ENDC}
	
	{ � scrivi il numero del modello }
	temp := fModelNumber;
	WriteBytes(aRefNum, SIZEOF(temp), @temp);
	
	{$IFC qDebug AND qDebugFiles}
	ReportFilePos(aRefNum, 'after model num');
	{$ENDC}
	
	{ � scrivi il numero dell'opzione di pesatura }
	temp := ORD(fWeightsOption);
	WriteBytes(aRefNum, SIZEOF(temp), @temp);
	
	{$IFC qDebug AND qDebugFiles}
	ReportFilePos(aRefNum, 'after weights option');
	{$ENDC}
	
	{ � scrivi miscellanea }
	WITH tmpMisc DO BEGIN
		beepWhenFitDone								:= fBeepWhenFitDone;
		refreshPlots									:= fRefreshPlotsEachIteration;
		unattended										:= fUnattended;
		fullOutput										:= fFullOutput;
		automaticPeeling							:= fAutomaticPeeling;
		maxIterations									:= fMaxIterations;
		lambdaAtStart									:= fLambdaAtStart;
		format												:= fFormat;
	END;
	WriteBytes(aRefNum, SIZEOF(tmpMisc), @tmpMisc);	

	{$IFC qDebug AND qDebugFiles}
	ReportFilePos(aRefNum, 'after miscellanea');
	{$ENDC}
	
	WITH tmpPlotMisc DO BEGIN
		dataAndFuncPlotDomainOption		:= fDataAndFuncPlotWindow.fPlotView.fDomainOption;
		semilog												:= fDataAndFuncPlotWindow.fPlotView.fSemilog;
		plotFast											:= fDataAndFuncPlotWindow.fPlotView.fPlotFast;
		{$PUSH}�{$H-}
		WITH dataAndFuncPlotDomain, fDataAndFuncPlotWindow.fPlotView.fDomain DO BEGIN
			ddLeft := dLeft;
			ddRight := dRight;
			ddTop := dTop;
			ddBottom := dBottom;
		END;
		{$POP}
		dataAndFuncPlotXTicks					:= fDataAndFuncPlotWindow.fPlotView.fXIntervals;
		dataAndFuncPlotYTicks					:= fDataAndFuncPlotWindow.fPlotView.fYIntervals;
		stdResPlotDomainOption				:= fStdResPlotWindow.fPlotView.fDomainOption;
		{$PUSH}�{$H-}
		WITH stdResPlotDomain, fStdResPlotWindow.fPlotView.fDomain DO BEGIN
			ddLeft := dLeft;
			ddRight := dRight;
			ddTop := dTop;
			ddBottom := dBottom;
		END;
		{$POP}
		stdResPlotAgainstOption				:= TStdResPlotView(fStdResPlotWindow.fPlotView).fPlotAgainstOption;
		stdResPlotXTicks							:= fStdResPlotWindow.fPlotView.fXIntervals;
		stdResPlotYTicks							:= fStdResPlotWindow.fPlotView.fYIntervals;
	END;
	WriteBytes(aRefNum, SIZEOF(tmpPlotMisc), @tmpPlotMisc);	

	{$IFC qDebug AND qDebugFiles}
	ReportFilePos(aRefNum, 'after plot options miscellanea');
	{$ENDC}
	
	{ � Write the tables }
	fTablesList.Each(WriteATable);
	
	{ � Write window positions and sizes etc. }
	WriteWindowShapeData(fExpDataTable.fTableWindow);
	WriteWindowShapeData(fParamsTable.fTableWindow);
	WriteWindowShapeData(fWeightsTable.fTableWindow);
	WriteWindowShapeData(fStdResTable.fTableWindow);
	WriteWindowShapeData(fDosesTable.fTableWindow);
	{$IFC qConstraints}
	WriteWindowShapeData(fConstraintsTable.fTableWindow);
	{$ENDC}
	WriteWindowShapeData(fMessagesWindow.fWindow);
	WriteWindowShapeData(fDataAndFuncPlotWindow);
	WriteWindowShapeData(fStdResPlotWindow);
	
	{ � Write User Model text }
	tmpHandle := fUserModelText;
	WriteHandleToDoc(aRefNum, tmpHandle);

	{ � Write messages text }
	tmpHandle := fMessagesWindow.fTEView.ExtractText;
	WriteHandleToDoc(aRefNum, tmpHandle);

	{$IFC qXMDLs}
	IF fModelNumber = kXMDL THEN BEGIN
		s := fXMDLName;
		WriteStringToDoc(aRefNum, s);
	END;
	{$ENDC}
END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TEasyFitDocument.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
													 				fieldType: INTEGER)); OVERRIDE;
VAR i: INTEGER;
		si: Str255;
		sst: Str255;
		bool: BOOLEAN;
BEGIN
	DoToField('TEasyFitDocument', NIL, bClass);
	DoToField('fExpDataTable', @fExpDataTable, bObject);
	DoToField('fParamsTable', @fParamsTable, bObject);
	DoToField('fStdResTable', @fStdResTable, bObject);
	DoToField('fWeightsTable', @fWeightsTable, bObject);
	DoToField('fDosesTable', @fDosesTable, bObject);
{$IFC qConstraints}
	DoToField('fConstraintsTable', @fConstraintsTable, bObject);
{$ENDC}
	DoToField('fMessagesWindow', @fMessagesWindow, bObject);
	DoToField('fDataAndFuncPlotWindow', @fDataAndFuncPlotWindow, bObject);
	DoToField('fStdResPlotWindow', @fStdResPlotWindow, bObject);
	DoToField('fTablesList', @fTablesList, bObject);	
	DoToField('fWeightsOption', @fWeightsOption, bByte);
	
	{$Push}{$H-}	{ Because FormatFields is in a debugging (i.e. resident) segment) }
	FormatFields('fFormat', fFormat, DoToField);
	{$Pop}
	
	DoToField('fModelNumber', @fModelNumber, bByte);
	{$IFC qXMDLs}
	DoToField('fXMDLName', @fXMDLName, bString);
	{$ENDC}
	DoToField('fRefreshPlotsEachIteration', @fRefreshPlotsEachIteration, bBoolean);
	DoToField('fBeepWhenFitDone', @fBeepWhenFitDone, bBoolean);
	DoToField('fUnattended', @fUnattended, bBoolean);
	DoToField('fFullOutput', @fFullOutput, bBoolean);
	DoToField('fAutomaticPeeling', @fAutomaticPeeling, bBoolean);
	DoToField('fMaxIterations', @fMaxIterations, bInteger);
	DoToField('fLambdaAtStart', @fLambdaAtStart, bExtended);
	DoToField('fUserModelText', @fUserModelText, bHandle);
	
	INHERITED Fields(DoToField);
END;

{ ***********************************************************************************}
{ ****** 													TExpDataTable 															****** }
{ ***********************************************************************************}
{$S AOpen}

PROCEDURE TExpDataTable.IExpDataTable(itsEasyFitDocument: TEasyFitDocument;
																					itsFormat: FormatRecord);
VAR aRect: Rect;
BEGIN
	fName := 'Data';
	fEasyFitDocument := itsEasyFitDocument;
	
	{�The 'X' column is col. number zero.
		Every other column has the number of its subject.
		Each column ranges from 1 to kMaxObservations including. }
	SetRect(aRect, 0, 1, kMaxSubjects, kMaxObservations);
	ITable(aRect,
				 TDocument(itsEasyFitDocument),
				 itsFormat,
				 kExpDataWindowType);
END;

{ --------------------------------------------------------------------------------- }
{$S ARes}

{�If I was a good boy, I'd store the 'subject' and 'X' strings in a resource }
PROCEDURE TExpDataTable.CoordToString(coord: INTEGER; VAR theString: Str255);
 OVERRIDE;
VAR s: Str255;
BEGIN
	IF coord = 1 THEN
		theString := 'X'
	ELSE BEGIN
		NumToString(coord - 1, s);
		theString := Concat('Subject ', s);
	END;
END;

{ --------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE TExpDataTable.ChangedColumn(all: BOOLEAN; column: ColumnNumber); OVERRIDE;
BEGIN
	{$IFC qDebug}
	IF (NOT all) & ((column < 1) | (column > kMaxSubjects)) THEN BEGIN
		Writeln('TExpDataTable.ChangedColumn: column number is wrong (',
												 column:1,')');
		ProgramBreak('');
	END;
	{$ENDC}
	
	IF all | (column = 1) THEN					{�If the time col changes, then redraw always }
		gSubjectModified := -1
	ELSE
		gSubjectModified := column - 1; { account for the time column }
END;

{ --------------------------------------------------------------------------------- }
{$S CallFit}

PROCEDURE TExpDataTable.GetSelectedSubjects(VAR selection: SubjectSet);
VAR i: SubjectNumber;
		p: Point;
		r: INTEGER;
		
	FUNCTION EmptyColumn(c: INTEGER): BOOLEAN;
	VAR r: INTEGER;
	BEGIN
		EmptyColumn := TRUE;
		FOR r := 1 TO fInUseBounds.bottom DO
			IF ClassExtended(GetValue(r, c)) <> QNan THEN BEGIN
				EmptyColumn := FALSE;
				LEAVE;
			END;
	END;
	
BEGIN
	WITH fInUseBounds DO BEGIN

		{ First make a fast check for this common case }
		IF NOT fColumnIsSelected THEN
			selection := [1..(right - 1)] {�Remember, internal format is (1, kMax + 1) }
		
		{�If it fails, go on with the more expensive general case }
		ELSE BEGIN
			{�Check each subject }
			p.v := 1;																			{�??? Zero ??? }
			selection := [];															{�Must initialize!! }
			FOR i := (left + 1) TO right DO BEGIN					{ Skip the X col }
				p.h := i;
				{$PUSH} {$H-}�{ PtInRgn cannot relocate the heap }
				IF PtInRgn(p, fColumnsView.fSelections) THEN
					selection := selection + [(i - 1)];		{ Add it to the selection }
				{$POP}
			END;
			
			IF selection = [] THEN		{�It may be that the only selected col was the X one }
				selection := [1..(right - 1)];
		END;	{�else }
	END;		{ with }

	{�Now, an additional check to skip empty cols }
	r := finUseBounds.right;
	FOR i := 2 TO r DO
		IF (i IN selection) & EmptyColumn(i) THEN
			selection := selection - [i];
END;

{ ---------------------------------------------------------------------------------- }
{$S ADoCommand}

PROCEDURE TExpDataTable.AddColumn(theColumn: TColumn);	OVERRIDE;
VAR oldRight:				INTEGER;
BEGIN
	oldRight := fInUseBounds.right;
	
	INHERITED AddColumn(theColumn);

	{ Check if the scroll bar in the graphical windows has to be redrawn.
		The check for NIL is necessary because when opening an old doc, the
		tables get read from disk before the plot windows are created. }
	IF fInUseBounds.right > oldRight THEN BEGIN
		IF fEasyFitDocument.fDataAndFuncPlotWindow <> NIL THEN BEGIN
			fEasyFitDocument.fDataAndFuncPlotWindow.FindSubView('scbr').ForceRedraw;
			IF oldRight = 0 THEN
				fEasyFitDocument.fDataAndFuncPlotWindow.FindSubView('info').ForceRedraw;
		END;
		IF fEasyFitDocument.fStdResPlotWindow <> NIL THEN BEGIN
			fEasyFitDocument.fStdResPlotWindow.FindSubView('scbr').ForceRedraw;
			IF oldRight = 0 THEN
				fEasyFitDocument.fStdResPlotWindow.FindSubView('info').ForceRedraw;
		END;
	END;
END;

{ ---------------------------------------------------------------------------------- }
{$S ADoCommand}

PROCEDURE TExpDataTable.AddCell(theCell: TCell; r: RowNumber; c: ColumnNumber);
	OVERRIDE;
VAR oldRight: INTEGER;
BEGIN
	oldRight := fInUseBounds.right;
	INHERITED AddCell(theCell, r, c);
	
	{ Check if the scroll bar in the graphical windows has to be redrawn.
		The check for NIL is necessary because when opening an old doc, the
		tables get read from disk before the plot windows are created. }
	IF fInUseBounds.right > oldRight THEN BEGIN
		IF fEasyFitDocument.fDataAndFuncPlotWindow <> NIL THEN BEGIN
			fEasyFitDocument.fDataAndFuncPlotWindow.FindSubView('scbr').ForceRedraw;
			IF oldRight = 0 THEN
				fEasyFitDocument.fDataAndFuncPlotWindow.FindSubView('info').ForceRedraw;
		END;
		IF fEasyFitDocument.fStdResPlotWindow <> NIL THEN BEGIN
			fEasyFitDocument.fStdResPlotWindow.FindSubView('scbr').ForceRedraw;
			IF oldRight = 0 THEN
				fEasyFitDocument.fStdResPlotWindow.FindSubView('info').ForceRedraw;
		END;
	END;
END;


{ ***********************************************************************************}
{ ****** 													TParamsTable 																****** }
{ ***********************************************************************************}
{$S AOpen}

PROCEDURE TParamsTable.IParamsTable(itsEasyFitDocument: TEasyFitDocument;
																					itsFormat: FormatRecord);
VAR aRect: Rect;
BEGIN
	fName := 'Parameters';
	fEasyFitDocument := itsEasyFitDocument;
	
	{�Every column has the number of its subject.
		Each column ranges from 1 to kMaxParams including. }
	SetRect(aRect, 1, 1, kMaxSubjects, kMaxParams);
	ITable(aRect,
				 TDocument(itsEasyFitDocument),
				 itsFormat,
				 kParamsWindowType);
END;

{ --------------------------------------------------------------------------------- }
{$S ARes}

{�If I was a good boy, I'd store the 'subject' string in a resource }
{ But since this pgm is destined to a scientific audience, English is
	assumed to be understood! }
PROCEDURE TParamsTable.CoordToString(coord: INTEGER; VAR theString: Str255);
 OVERRIDE;
VAR s: Str255;
BEGIN
	NumToString(coord, s);
	theString := Concat('Subject ', s);
END;

{ --------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE TParamsTable.ChangedColumn(all: BOOLEAN; column: ColumnNumber); OVERRIDE;
BEGIN
	{$IFC qDebug}
	IF (NOT all) & ((column < 1) | (column > kMaxSubjects)) THEN BEGIN
		Writeln('TParamsTable.ChangedColumn: column number is wrong (',
												 column:1,')');
		ProgramBreak('');
	END;
	{$ENDC}
	
	IF all THEN
		gSubjectModified := -1
	ELSE
		gSubjectModified := column;
END;

{ ***********************************************************************************}
{ ****** 													TWeightsTable 															****** }
{ ***********************************************************************************}
{$S AOpen}

PROCEDURE TWeightsTable.IWeightsTable(itsEasyFitDocument: TEasyFitDocument;
																					itsFormat: FormatRecord);
VAR aRect: Rect;
BEGIN
	fName := 'Weights';
	fEasyFitDocument := itsEasyFitDocument;
	
	{�Every column has the number of its subject.
		Each column ranges from 1 to kMaxObservations including. }
	SetRect(aRect, 1, 1, kMaxSubjects, kMaxObservations);
	ITable(aRect,
				 TDocument(itsEasyFitDocument),
				 itsFormat,
				 kWeightsWindowType);
	
	{�fReadOnly := NOT (itsEasyFitDocument.fWeightsOption = inputByUser); }
END;

{ --------------------------------------------------------------------------------- }
{$S ARes}

{�If I was a good boy, I'd store the 'subject' string in a resource }
{ But since this pgm is destined to a scientific audience, English is
	assumed to be understood! }
PROCEDURE TWeightsTable.CoordToString(coord: INTEGER; VAR theString: Str255);
 OVERRIDE;
VAR s: Str255;
BEGIN
	NumToString(coord, s);
	theString := Concat('Subject ', s);
END;

{ ***********************************************************************************}
{ ****** 													TStdResTable 																****** }
{ ***********************************************************************************}
{$S AOpen}

PROCEDURE TStdResTable.IStdResTable(itsEasyFitDocument: TEasyFitDocument;
																					itsFormat: FormatRecord);
VAR aRect: Rect;
BEGIN
	fName := 'Standard Residuals';
	fEasyFitDocument := itsEasyFitDocument;
	
	{�Here it's more complicated.
		??? Should I provide individual methods to access every kind of column ??? }
	SetRect(aRect, 0, 1, (kMaxSubjects * kStdResColsPerSubj) - 1, kMaxObservations);
	ITable(aRect,
				 TDocument(itsEasyFitDocument),
				 itsFormat,
				 kStdResWindowType);
	fReadOnly := TRUE;							{�Always read-only this one }
END;

{ --------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE TStdResTable.CoordToString(coord: INTEGER; VAR theString: Str255);
 OVERRIDE;
VAR theSubject: 				INTEGER;
		theColumnType: 			INTEGER;
		theSubjectString:		Str255;
BEGIN
	theSubject := (coord DIV kStdResColsPerSubj) + 1;
	theColumnType := (coord - 1) MOD kStdResColsPerSubj;
	NumToString(theSubject, theSubjectString);
	CASE theColumnType OF
		kXCol:
				theString := 'X';
		kObservedY:
				theString := Concat('Obs. Y (', theSubjectString, ')');
		kEstimatedY:
				theString := Concat('Est. Y (', theSubjectString, ')');
		kStdResiduals:
				theString := Concat('Std. Res. (', theSubjectString, ')');
		kStdPercResiduals:
				theString := Concat('Std. % Res. (', theSubjectString, ')');
	END;		{�case }
END;

{ ***********************************************************************************}
{ ****** 													TDosesTable 																****** }
{ ***********************************************************************************}
{$S AOpen}

PROCEDURE TDosesTable.IDosesTable(itsEasyFitDocument: TEasyFitDocument;
																					itsFormat: FormatRecord);
VAR aRect: Rect;
BEGIN
	fName := 'Doses';
	fEasyFitDocument := itsEasyFitDocument;
	
	{�This table has one row only }
	SetRect(aRect, 1, 1, kMaxSubjects, 1);
	ITable(aRect,
				 TDocument(itsEasyFitDocument),
				 itsFormat,
				 kDosesWindowType);
END;

{ --------------------------------------------------------------------------------- }
{$S ARes}

{�If I was a good boy, I'd store the 'subject' string in a resource }
PROCEDURE TDosesTable.CoordToString(coord: INTEGER; VAR theString: Str255);
 OVERRIDE;
VAR s: Str255;
BEGIN
	NumToString(coord, s);
	theString := Concat('Subject ', s);
END;

{ --------------------------------------------------------------------------------- }
{$S AOpen}

PROCEDURE TDosesTable.DoMakeViews(forPrinting: BOOLEAN); OVERRIDE;
BEGIN
	INHERITED DoMakeViews(forPrinting);
	
	{�Modify resize limits }
	fTableWindow.fResizeLimits.top := kDosesWindowHeight;
	fTableWindow.fResizeLimits.bottom := kDosesWindowHeight;
END;

{ --------------------------------------------------------------------------------- }
{$S CallFit}

PROCEDURE TDosesTable.GetDose(theSubject: INTEGER; VAR theDose: EXTENDED);
VAR tmp: EXTENDED;
BEGIN
	theDose := GetValue(1, theSubject);
END;

{ --------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE TDosesTable.ChangedColumn(all: BOOLEAN; column: ColumnNumber); OVERRIDE;
BEGIN
	{$IFC qDebug}
	IF (NOT all) & ((column < 1) | (column > kMaxSubjects)) THEN BEGIN
		Writeln('TDosesTable.ChangedColumn: column number is wrong (',
												 column:1,')');
		ProgramBreak('');
	END;
	{$ENDC}
	
	IF all THEN
		gSubjectModified := -1
	ELSE
		gSubjectModified := column;
END;

{ ***********************************************************************************}
{ ****** 													TConstraintsTable 													****** }
{ ***********************************************************************************}
{$IFC qConstraints}

CONST kLowColumn = 1; {�Constants used to index the two columns }
			kHiColumn = 2;

{$S AOpen}

PROCEDURE TConstraintsTable.IConstraintsTable(itsEasyFitDocument: TEasyFitDocument;
																							itsFormat: FormatRecord);
VAR aRect: Rect;
BEGIN
	fName := 'Constraints';
	fEasyFitDocument := itsEasyFitDocument;
	
	{�This table has two columns only }
	SetRect(aRect, 1, 1, kConstraintsMaxCols, kConstraintsMaxRows);
	ITable(aRect,
				 TDocument(itsEasyFitDocument),
				 itsFormat,
				 kConstraintsWindowType);
END;

{ --------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE TConstraintsTable.CoordToString(coord: INTEGER; VAR theString: Str255);
 OVERRIDE;
BEGIN
	IF coord = kLowColumn THEN
		theString := 'Low'
	ELSE
		theString := 'High';
END;

{ --------------------------------------------------------------------------------- }
{$S AOpen}

PROCEDURE TConstraintsTable.DoMakeViews(forPrinting: BOOLEAN); OVERRIDE;
{ These constants must have the same value as the ones declared in file
	ConstraintsWindow.r }
BEGIN
	INHERITED DoMakeViews(forPrinting);
	
	{�Modify resize limits }
	fTableWindow.fResizeLimits.right := kConstraintsSizeH+1;
	fTableWindow.fResizeLimits.left := kConstraintsSizeH+1;
	fTableWindow.fResizeLimits.bottom := kConstraintsSizeV;
END;

{ --------------------------------------------------------------------------------- }
{$S CallFit}

{�Missing values are changed to -infinite }
PROCEDURE TConstraintsTable.GetLowConstraints(p: PExtended; NParams: INTEGER);
VAR row: INTEGER;
		value: EXTENDED;
BEGIN
	FOR row := 1 TO NParams DO BEGIN
		value := GetCell(row, kLowColumn).fValue;
		IF ClassExtended(value) = QNan THEN
			SetIthElement(p, row - 1, -inf)
		ELSE
			SetIthElement(p, row - 1, value)
	END;
END;

{ --------------------------------------------------------------------------------- }
{$S CallFit}

{�Missing values are changed to +infinite }
PROCEDURE TConstraintsTable.GetHiConstraints(p: PExtended; NParams: INTEGER);
VAR row: INTEGER;
		value: EXTENDED;
BEGIN
	FOR row := 1 TO NParams DO BEGIN
		value := GetCell(row, kHiColumn).fValue;
		IF ClassExtended(value) = QNan THEN
			SetIthElement(p, row - 1, inf)
		ELSE
			SetIthElement(p, row - 1, value)
	END;
END;


{$ENDC} {qConstraints}

{***************************************************************************************************
	T F o r m a t t e r
***************************************************************************************************}
{$S ASelCommand}

PROCEDURE TFormatter.IFormatter(itsEasyFitDocument: TEasyFitDocument; 
																itsCommand: INTEGER);
BEGIN
	ICommand(itsCommand, itsEasyFitDocument, NIL, NIL);
	fTablesList := itsEasyFitDocument.fTablesList;
	fOldFormat := itsEasyFitDocument.fFormat;
	
	{ the new format is just like the old one, ...}
	fNewFormat := fOldFormat;
	
	{�...except that: }�
	WITH fNewFormat DO
		CASE fCmdNumber OF
			cGeneral:
				fStyle := General;
			cDecimal:
				fStyle := DecimalStyle;
			cScientific:
				fStyle := Scientific;
			cLeftJustify:
				fJustification := teJustLeft;
			cRightJustify:
				fJustification := teJustRight;
			cCenter:
				fJustification := teJustCenter;
			cNoDigits:
				fDigits := 0;
			c1Digit:
				fDigits := 1;
			c2Digits:
				fDigits := 2;
			c3Digits:
				fDigits := 3;
			c4Digits:
				fDigits := 4;
			c5Digits:
				fDigits := 5;
			c6Digits:
				fDigits := 6;
			c7Digits:
				fDigits := 7;
			c8Digits:
				fDigits := 8;
			c9Digits:
				fDigits := 9;
			c10Digits:
				fDigits := 10;
			c11Digits:
				fDigits := 11;
			c12Digits:
				fDigits := 12;
		END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TFormatter.DoIt; OVERRIDE;
VAR tmp: FormatRecord;

	PROCEDURE ChangeFormat(aTable: TTable);
	BEGIN
		aTable.fFormat := fNewFormat;
		IF fCmdNumber IN [cGeneral, cDecimal, cScientific, cNoDigits..c12Digits]
		THEN	{ Style change }
			aTable.DoRecalculate;
		aTable.fCellsView.ForceRedraw;
	END;
	
BEGIN
	{�Change format in all of the tables... }
	fTablesList.Each(ChangeFormat);
	
	{�And of course in the document }
	TEasyFitDocument(fChangedDocument).fFormat := fNewFormat;
	
	{�we swap old with new, so that UndoIt & RedoIt will work }
	tmp := fOldFormat;
	fOldFormat := fNewFormat;
	fNewFormat := tmp;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TFormatter.RedoIt; OVERRIDE;
BEGIN
	DoIt;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TFormatter.UndoIt; OVERRIDE;
BEGIN
	DoIt;
END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TFormatter.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
													  fieldType: INTEGER)); OVERRIDE;
BEGIN
	DoToField('TFormatter', NIL, bClass);

	{�??? we're missing some fields here }

	INHERITED Fields(DoToField);
END;

{ *********************************************************************************** }
{	* TAdornedScroller -- it is a TScroller that draws an adornment around itself 		* }
{ *********************************************************************************** }
{$IFC FALSE}
PROCEDURE TAdornedScroller.Draw(area: Rect); OVERRIDE;
VAR qdExtent: Rect;
		penSize: Point;
BEGIN
	penSize.h := 1;
	penSize.v := 1;
	GetQDExtent(qdExtent);
	{�InsetRect(qdExtent, -1, -1); }
	Adorn(qdExtent, penSize, {itsAdornment:} [adnLineTop, adnLineLeft, adnLineBottom]);

	INHERITED Draw(area);
END;
{$ENDC}

{ *********************************************************************************** }
{ *		Global procedures																															* }
{ *********************************************************************************** }
{$S AOpen}

PROCEDURE ReportFileDamaged(aRefNum: INTEGER);
{$IFC qDebug}
VAR filePos: 	LONGINT;
		err: 			OSErr;
		s:				Str255;
		len:			LONGINT;
		i:				INTEGER;
{$ENDC}
BEGIN
{$IFC qDebug}
	Write('File is damaged; ');
	err := GetFPos(aRefNum, filePos);
	IF err = NoErr THEN
		Writeln('file position is ', filePos)
	ELSE
		Writeln('can''t get file position (OSErr ', err:1, ')');
	Writeln('41 bytes centered on filePos:');

	err := SetFPos(aRefNum, fsFromStart, filePos - 20);
	IF err <> NoErr THEN BEGIN
		Writeln('can''t set file position (OSErr ', err:1, ')');
		Exit(ReportFileDamaged);
	END;

	len := 41;
	err := FSRead(aRefNum, len, POINTER(ORD4(@s)+1));
	IF err <> NoErr THEN BEGIN
		Writeln('failed FSRead (OSErr ', err:1, ')');
		Exit(ReportFileDamaged);
	END;
	s[0] := CHR(21);
	Writeln(s);

	FOR i := 1 TO 41 DO
		Write(ORD(s[i]):1, ' ');
	Writeln;
	FOR i := 1 TO 41 DO
		Write(i:2, ' ');
	Writeln;
	
	IF SetFPos(aRefNum, fsFromStart, filePos + 20) <> noErr THEN;
	{$ENDC}
END;

{ ---------------------------------------------------------------------------------- }
{$S AOpen}

PROCEDURE ReportFilePos(aRefNum: INTEGER; msg: Str255);

VAR filePos: 	LONGINT;
		err: 			OSErr;

BEGIN
	err := GetFPos(aRefNum, filePos);
	IF err = NoErr THEN
		Writeln('ReportFilePos: file position is ', filePos:1, ' ', msg)
	ELSE
		Writeln('ReportFilePos: can''t get file position (OSErr ', err:1, ')');
END;
