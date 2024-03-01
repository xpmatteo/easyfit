{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.

	This unit implements our text window;
	It is used to show textual output of the fitting.
	The user can copy text from here, but not write or cut or delete text.
	Only the application writes on this window.
	
	The name, TMultiTE, comes out because in the beginning, I wanted to make 
	a multi-page window, with a separate page for each subject.

	The text for this window is allocated and released outside of this unit;
	this unit only does the displaying of text: the text itself
	belongs to the application.
	
	Also, the text belongs to the TEView, that allocates it if we pass it a
	NIL handle; and the TEView deallocates it when the TEView itself is freed.
}

UNIT UMultiTE;

INTERFACE

USES
	{ � MacApp stuff }
	UMacApp, UDialog, UTEView, UPrinting,
	
	{ʥ Required by UEasyFitDeclarations }
	Fonts,
	
	{ʥ�Needed by the interface part }
	UEasyFitDeclarations,
	
	{ � Needed by the implementation }
	UEasyFitUtilities, Errors, ToolUtils, Files, Packages;

TYPE 
	
	TMultiTE = OBJECT(TObject)
	
		fDocument:					TDocument;
		fTEView:						TMultiTEView;
		fWindow:						TWindow;
		fLineHeight:				INTEGER;	{�This is non-styled text; so we can cache the
																		height of a line in pixels }
				
			{ Initing & Freeing }

		PROCEDURE TMultiTE.IMultiTE(itsDocument: TDocument);

		PROCEDURE TMultiTE.DoMakeViews(forPrinting: BOOLEAN; textHandle: Handle);
		{ Launch the views }

		PROCEDURE TMultiTE.Free; OVERRIDE;
		{ Free the thing }

			{�Communication with the rest of the application }
		
		PROCEDURE TMultiTE.Writeln(s: Str255);
		PROCEDURE TMultiTE.WritelnResource(strListID, strIndex: INTEGER);
		PROCEDURE TMultiTE.WritelnHandle(h: Handle; charsToCopy: LONGINT);
		PROCEDURE TMultiTE.Write(s: Str255);
		PROCEDURE TMultiTE.NewLine;
		
		{�To be called after a group of write's and writeln's to see something
			printed }
		PROCEDURE TMultiTe.Synch;

			{ Miscellanea }

		{�Clears the text in the window, allowing the user to save it first. }
		PROCEDURE TMultiTE.SaveText;

			{�Debug }
		
		PROCEDURE TMultiTE.Fields(PROCEDURE
														DoToField(fieldName: Str255; fieldAddr: Ptr;
														fieldType: INTEGER)); OVERRIDE;


	END;
	

	TMultiTEView = OBJECT(TTEView)	
			{�Prevents MacApp printing mechanism from printing empty pages
				for the horizontal extent of the view is larger than
				the page size. }
			PROCEDURE TMultiTEView.DoCalcPageStrips(VAR pageStrips: Point); OVERRIDE;
	END;

	
IMPLEMENTATION

	{$I UMultiTE.inc1.p}
	
END.
