{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}

CONST
	kMultiTEWindowType	= 1010;
	
{ ------------------------------------------------------------------------------------- }

FUNCTION ShiftHandle(h: Handle; amount: LONGINT): LONGINT; C; EXTERNAL;

{ ------------------------------------------------------------------------------------- }
{$IFC qDebug}
{$S ARes}

{ Calling Writeln in methods of multite results in the METHOD Writeln
	being called; these aliases work around it. }

PROCEDURE AliasWriteln(s: Str255);
BEGIN
	Writeln(s);
END;

PROCEDURE AliasWriteln2(s: Str255; id: IDType);
BEGIN
	Writeln(s, id);
END;

{$ENDC}
{ ------------------------------------------------------------------------------------- }
{$S AOpen}

PROCEDURE TMultiTE.IMultiTE(itsDocument: TDocument);
BEGIN
	fTEView := NIL;
	fWindow := NIL;
	fDocument := itsDocument;
	IObject;
END;

{ --------------------------------------------------------------------------------- }
{$S AClose}

PROCEDURE TMultiTE.Free;
BEGIN
	FreeIfObject(fWindow);
	INHERITED Free;
END;

{ --------------------------------------------------------------------------------- }
{$S AOpen}

PROCEDURE TMultiTE.DoMakeViews(forPrinting: BOOLEAN; textHandle: Handle);
VAR aWindow:			TWindow;
		aTEView:			TMultiTEView;
		aHandler:			TStdPrintHandler;
		fInfo:				FontInfo;
BEGIN
	aWindow := NewTemplateWindow(kMultiTEWindowType, fDocument);
	FailNIL(aWindow);
	aTEView := TMultiTEView(aWindow.FindSubView('TEVW'));
	fTEView := aTEView;
	fWindow := aWindow;
	
	{�Compute fLineHeight; needed in Synch }
	IF fTEView.Focus THEN;
	GetFontInfo(fInfo);
	WITH fInfo DO
		fLineHeight := ascent + descent;

	IF textHandle <> NIL THEN BEGIN
		fTEView.StuffText(textHandle);
		fTEView.RecalcText;
		Synch;
	END;
	
	
	New(aHandler);
	FailNIL(aHandler);
	aHandler.IStdPrintHandler(fDocument,						{ its document }
							  						fTEView,							{ its view }
							 							NOT kSquareDots,			{ does not have square dots }
							  						kFixedSize, 					{ horizontal page size is fixed }
							  						NOT kFixedSize);			{ vertical page size is variable 
																										(could be set to true on non-style
																										TE systems) }
END;

{ ---------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE TMultiTE.Writeln(s: Str255);
VAR strLen: INTEGER;
BEGIN
	strLen := Length(s);
	IF strLen = 255 THEN BEGIN
		SELF.Write(s);
		SELF.NewLine;
	END
	ELSE BEGIN
		{ We call "Write" only, so we do it faster than Write + NewLine }
		strLen := strLen + 1;
		s[strLen] := chr(13);			{�Append a carriage return }
		s[0] := chr(strLen);			{ Fix the length byte }
		SELF.Write(s);
	END;
END;

{ ---------------------------------------------------------------------------------- }
{$S TENonRes}

PROCEDURE TMultiTE.WritelnResource(strListID, strIndex: INTEGER);
VAR s: Str255;
BEGIN
	GetIndString(s, strListID, strIndex);
	{$IFC qDebug}
	FailResError;
	{$ENDC}
	SELF.Writeln(s);
END;

{ ---------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE TMultiTE.Write(s: Str255);
VAR total:					LONGINT;
		contig:					LONGINT;
		numChars:				LONGINT;
	
BEGIN
	numChars := fTEView.fHTE^^.teLength;
		
	{ Check there is enough memory to do this. See wether we could allocate 
		a handle big enough to hold the current text, and the new one.
		If it fails, call failure. }
	PurgeSpace(total, contig);
	IF contig < (numChars + Length(s)) THEN
		Failure(memFullErr, 0);
	
	{�Check if the new text exceeds the 32K limitation of TextEdit. }
	IF (numChars + ORD4(Length(s))) > MAXINT THEN
		SaveText;
		
	{�Finally do what's needed to add the string to the text.}

	{�Bring insertion point to the end of the text }
	TESetSelect(MAXINT, MAXINT, fTEView.fHTE);

	{ Chiama TextEdit per aggiungere la stringa al testo }
	TEInsert(POINTER(ORD4(@s) + 1), ORD4(s[0]), fTEView.fHTE);
END;

{ ---------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE TMultiTE.WritelnHandle(h: Handle; charsToCopy: LONGINT);
VAR total:					LONGINT;
		contig:					LONGINT;
		numChars:				LONGINT;
		handleLen:			LONGINT;
BEGIN
	numChars := fTEView.fHTE^^.teLength;
	handleLen := GetHandleSize(h);
	IF charsToCopy > handleLen THEN
		charsToCopy := handleLen;
	
	{ Check there is enough memory to do this. See wether we could allocate 
		a handle big enough to hold the current text, and the new one.
		If it fails, call failure. }
	PurgeSpace(total, contig);
	IF contig < (numChars + charsToCopy) THEN
		Failure(memFullErr, 0);
	
	{�Check if the new text exceeds the 32K limitation of TextEdit. }
	IF (numChars + charsToCopy) > MAXINT THEN
		SaveText;
		
	{�Finally do what's needed to add the string to the text.}

	{�Bring insertion point to the end of the text }
	TESetSelect(MAXINT, MAXINT, fTEView.fHTE);

	{ Chiama TextEdit per aggiungere la stringa al testo }
	MoveHHi(h);
	HLock(h);
	TEInsert(h^, charsToCopy, fTEView.fHTE);
	HUnLock(h);
	
	NewLine;
END;

{ ---------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE TMultiTE.NewLine;
VAR cr: STRING[1];	{ We use a String instead of a char, because we need it packed }
		total, 
		contig, 
		numChars: LONGINT;
BEGIN
	numChars := fTEView.fHTE^^.teLength;
	
	{ ??? This code is repeated in Write.  We could define a method
		to hold this code, and avoid duplication. }
		
	{ Check there is enough memory to do this. See wether we could allocate 
		a handle big enough to hold the current text, and the new one.
		If it fails, call failure. }
	PurgeSpace(total, contig);
	IF contig < (numChars + 1) THEN
		Failure(memFullErr, 0);
	
	{�Check if the new text exceeds the 32K limitation of TextEdit.
		If so, shift things in the text handle }
	IF (numChars + 1) > MAXINT THEN
		SaveText;
	
	{�Bring insertion point to the end of the text }
	TESetSelect(MAXINT, MAXINT, fTEView.fHTE);
	
	{ Add a carriage return. }
	cr[1] := chReturn;
	TEInsert(POINTER(ORD4(@cr) + 1), 1, fTEView.fHTE);
END;

{ ---------------------------------------------------------------------------------- }
{$S Fit}

PROCEDURE TMultiTE.Synch;
VAR
	oldHeight:	LONGINT;
	aRect:			Rect;
BEGIN
	oldHeight := fTEView.fLastHeight;
	
	fTEView.SynchView(kRedraw);
	
	{�This is a hack needed to cope with a bug in MacApp 2.0:
		the first line after a SynchView used not to be drawn. It may be that this
		code, and the field fLineHeight, become unnecessary in later releases of
		MacApp. This code wasn't needed with MacApp 2.0b9. }
	SetRect(aRect, 0, oldHeight - fLineHeight, fTEView.fLastWidth, oldHeight);
	fTEView.Draw(aRect);
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TMultiTE.SaveText;
LABEL
	99;
CONST
	kSaveTextDlog = 1150;
VAR
	aWindow:				TWindow;
	aDialog:				TDialogView;
	dismisser:			IDType;
		
	
	PROCEDURE WriteText(fileRefNumber: INTEGER);
	VAR
		tmpHandle:			Handle;
		fi:							FailInfo;
		size:						LONGINT;

			PROCEDURE HdlSaveTextFailure(error: OSErr; message: LONGINT);
			BEGIN
				HUnLock(tmpHandle);
				ErrorAlert(error, message);
				GOTO 99;
			END;

	BEGIN
		tmpHandle := fTEView.ExtractText;
		HLock(tmpHandle);
		CatchFailures(fi,HdlSaveTextFailure);
		size := GetHandleSize(tmpHandle);
		FailMemError;
		WriteBytes(fileRefNumber, size, tmpHandle^);
		HUnLock(tmpHandle);
		Success(fi);
	END;


BEGIN

99:
	aWindow := NewTemplateWindow(kSaveTextDlog, NIL);
	aDialog := TDialogView(aWindow.FindSubView('dlog'));
	dismisser := aDialog.PoseModally;
	aWindow.Close;
	
	
	{�Here it is important NOT to update the windows before saving the text,
		to cope with this problem: if the model is the user model, of an XMDL,
		and this model writes to the messages window, then we may fill up the
		messages window text during an update of the Data&Model plot window.
		If we insist with updating all of the windows before calling std file,
		like is suggested by MacApp to cope with a std file bug,
		then we are stuck in a never-ending loop. 
		It would be better to set mustUpdateWindows to FALSE only if the model
		is user defined or external, but we cannot refer here to EasyFitDocument
		stuff without introducing a circular reference. }
		
	IF (dismisser = 'ok  ')
			& (NOT WriteInOpenFile('Save messages text in�',
														 'EasyFit text',
														 'TEXT',
														 kTextCreator,
														 { mustUpdateWindows: } FALSE,
														 WriteText))
	THEN
		GOTO 99;	{�If user hits "cancel", he still must click the "erase it" button. }
	
	{ Clear the msgs window in any case }
	SetHandleSize(fTEView.ExtractText, 0);
	FailMemError;
	fTEView.RecalcText;
	Synch;
	
	{�
		this is what we used to do before we had the "Save text" dialog:
		we would erase a few kilobytes at the beginning of the text and go on
		
		numChars := ShiftHandle(fTEView.fText, 2 * 1024);
		fTEView.fHTE^^.teLength := numChars;
	}
END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TMultiTE.Fields(PROCEDURE
													DoToField(fieldName: Str255; fieldAddr: Ptr;
													fieldType: INTEGER)); OVERRIDE;
BEGIN
	DoToField('TMultiTE', NIL, bClass);
	DoToField('fDocument', @fDocument, bObject);
	DoToField('fWindow', @fWindow, bObject);
	DoToField('fTEView', @fTEView, bObject);
	DoToField('fLineHeight', @fLineHeight, bInteger);
	INHERITED Fields(DoToField);
END;

{ ********************************************************************************** }
{�TMultiTEView																																			 }
{ ********************************************************************************** }
{$S MANonRes}

PROCEDURE TMultiTEView.DoCalcPageStrips(VAR pageStrips: Point); OVERRIDE;
BEGIN
	INHERITED DoCalcPageStrips(pageStrips);
	
	{$IFC qDebug}
	{�Writeln('TMultiTEView.DoCalcPageStrips: pageStrips before retouching (h, v): ',
		pageStrips.h, pageStrips.v); }
	{$ENDC}
	pageStrips.v := 1;	{�Force always one page horizontally. }
END;