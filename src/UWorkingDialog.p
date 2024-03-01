{
	File UWorkingDialog.p
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	
	Created 17/12/89 h 1:52 AM !!!
	
	22/12/89: Changed TWorkingDialog to be a subclass of TObject instead of
	TDialogView.  In fact this is more appropriate.
}

UNIT UWorkingDialog;

INTERFACE

USES
	{ʥ Required by UEasyFitDeclarations }
	QuickDraw, Fonts, 
	
	{ � MacApp stuff }
	UMacApp, UDialog,
	
	{ʥ Matt Stuff }
	UEasyFitUtilities, UEasyFitDeclarations, UPercDoneBarView;

TYPE
	
	TWorkingDialog = OBJECT(TObject)
	
		fWindow:						TWindow;
		fDialogView:				TDialogView;
		fPercDoneBar:				TPercDoneBarView;
		fStaticText:				TStaticText;
		
		{ Creates the views for the working dialog and shows them }
		PROCEDURE TWorkingDialog.Pose(numOfOperations: INTEGER; txt: Str255);
		
		{�Closes the views and frees the thing }
		PROCEDURE TWorkingDialog.Free;		OVERRIDE;
	
		{�Returns TRUE if the user wants to interrupt }
		FUNCTION TWorkingDialog.PollEvent: BOOLEAN;
		
		{ Changes the text }
		PROCEDURE TWorkingDialog.SetText(txt: Str255);
		
		{�Passes this message on to the "Percentage done" bar }
		PROCEDURE TWorkingDialog.OperationDone;
		
	END;
	
IMPLEMENTATION

	{$I UWorkingDialog.inc1.p}
	
END.