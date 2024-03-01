{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}
{--------------------------------------------------------------------------------------------------}
{$S CallFit}

PROCEDURE TWorkingDialog.Pose(numOfOperations: INTEGER; txt: Str255);
CONST kWorkingWindowType = 1020;
VAR aWindow:				TWindow;
		aPercDoneBar:		TPercDoneBarView;
		aStaticText:		TStaticText;
		aDialogView:		TDialogView;
BEGIN
	{�Make sure Free will work }
	fWindow := NIL;
	
	{�Remove buzzwords }
	FixEditMenu;

	{�Just to be sure }
	gApplication.CommitLastCommand;
	
	{�Create the window and the views from their template }
	aWindow := NewTemplateWindow(kWorkingWindowType, NIL);
	FailNil(aWindow);
	fWindow := aWindow;
	
	{�Find the dialog subView }
	aDialogView := TDialogView(aWindow.FindSubView('DLOG'));
	fDialogView := aDialogView;
	
	{�Init the Percentage Done bar }
	aPercDoneBar := TPercDoneBarView(aWindow.FindSubView('PERC'));
	aPercDoneBar.IPercDoneBarView(numOfOperations);
	fPercDoneBar := aPercDoneBar;
	
	{�Set the text }
	aStaticText := TStaticText(aWindow.FindSubView('TEXT'));
	aStaticText.SetText(txt, kDontRedraw);
	fStaticText := aStaticText;
	
	{�Center window like a dialog }
	aWindow.Center({horizontally} TRUE, {vertically} TRUE, {fordialog} TRUE);
	
	{�Open the window }
	aWindow.Open;
	fDialogView.fDismissed := False;
END;

{--------------------------------------------------------------------------------------------------}
{$S CallFit}

PROCEDURE TWorkingDialog.Free;		OVERRIDE;
BEGIN
	IF fWindow <> NIL THEN
		fWindow.Close;
	INHERITED Free;
END;
		
{--------------------------------------------------------------------------------------------------}
{$S Fit} {�Moved from segment CallFit to Fit to make CallFit size < 32K }

{�If the user presses Abort, then PollEvent returns TRUE,
	else returns false. }

FUNCTION TWorkingDialog.PollEvent: BOOLEAN;
LABEL 99;
VAR fi:				FailInfo;
		theEvent:	EventRecord;
		
		PROCEDURE HdlPollEvent(error: OSErr; message: LONGINT);
		BEGIN
			IF error = noErr THEN
				GOTO 99											{ If no error then keep the dialog running }
			
			{�the dialog will be closed by the DoFit error handler }
		END;

BEGIN
	{�We need to CatchFailures, because a programming error, or whatever, may
		happen when we call WaitNextEvent. So, we are prepared to
		abort the fit command cleanly, closing the Working dialog. } 
	CatchFailures(fi, HdlPollEvent);
	WHILE EventAvail(gMainEventMask, theEvent) DO BEGIN
		{$IFC MacApp20Def}
		gApplication.PollEvent( {allowApplicationToSleep:}�TRUE);
		{$ELSEC}
		gApplication.PollEvent;
		{$ENDC}
		gApplication.ActivateBusyCursor(FALSE);
		SetCursor(gWatchHdl^^);
	END;
	Success(fi);
	
99:
	IF fDialogView.fDismissed THEN
		SetText('Stopping�');
	PollEvent := fDialogView.fDismissed;
END;

{--------------------------------------------------------------------------------------------------}
{$S Fit} {�Moved from segment CallFit to Fit to make CallFit size < 32K }

{ Changes the text }
PROCEDURE TWorkingDialog.SetText(txt: Str255);
BEGIN
	fStaticText.SetText(txt, kRedraw);
END;
		
{--------------------------------------------------------------------------------------------------}
{$S Fit} {�Moved from segment CallFit to Fit to make CallFit size < 32K }

{�Passes this message on to the "Percentage done" bar }
PROCEDURE TWorkingDialog.OperationDone;
BEGIN
	fPercDoneBar.OperationDone;
END;