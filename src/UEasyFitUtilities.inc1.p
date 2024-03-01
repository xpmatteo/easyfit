{ EasyFitUtilities.inc1.p}
{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	Portions are Copyright � 1986-1989 by Apple Computer, Inc. All rights reserved.
}

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE FitString(VAR theString: Str255; maxWidth: INTEGER);
{ Truncates theString to fit in maxWidth pixels }

	VAR
		currWidth:			INTEGER;
		noOfChars:			INTEGER;

	BEGIN
	IF StringWidth(theString) > maxWidth THEN
		BEGIN
		currWidth := CharWidth('�');
		noOfChars := 0;
		REPEAT
			noOfChars := noOfChars + 1;
			currWidth := currWidth + CharWidth(theString[noOfChars]);
		UNTIL currWidth > maxWidth;

		{$Push} {$R-}
		theString[0] := CHR(noOfChars); 				{ Set length of theString }
		{$Pop}
		theString[noOfChars] := '�';
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION IsDigit(Ch: CHAR): BOOLEAN;

	BEGIN
	IsDigit := (Ch >= '0') AND (Ch <= '9');
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE SetEditCmdName(theCommand, customCommand: INTEGER);
 { Sets the Edit menu command name to the custom name, e.g. 'Copy Cells'. }

	VAR
		commandName:		Str255;

	BEGIN
	CmdToName(customCommand, commandName);
	SetCmdName(theCommand, commandName);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE SetTheFont(fontNumber, fontSize: INTEGER; fontStyle: Style);

	BEGIN
	TextFont(fontNumber);
	TextSize(fontSize);
	TextFace(fontStyle);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE SmartDrawString(theString: Str255; h, v, width: INTEGER; justification: INTEGER);
 { Draws the string at the [h,v] coordinate, taking into account the
  width and justification. }

	VAR
		widthOfString:		INTEGER;

	BEGIN
	FitString(theString, width);
	widthOfString := StringWidth(theString);
	CASE justification OF
		TEJustCenter:
			h := h + (width - widthOfString) DIV 2;
		teJustRight:
			h := h + width - widthOfString;
		teJustLeft:
			h := h + 1;
	END;
	MoveTo(h, v);
	DrawString(theString);
	END;

{--------------------------------------------------------------------------------------------------}
{$S AReadFile}

PROCEDURE ReadBytes(theRefNum: INTEGER; size: LONGINT; buffer: Ptr);
{ Utility for reading data from a file }

	BEGIN
	FailOSErr(FSRead(theRefNum, size, buffer));
	END;

{--------------------------------------------------------------------------------------------------}
{$S AWriteFile}

PROCEDURE WriteBytes(theRefNum: INTEGER; size: LONGINT; buffer: Ptr);
{ Utility for writing data to a file }

	BEGIN
	FailOSErr(FSWrite(theRefNum, size, buffer));
	END;

{--------------------------------------------------------------------------------------------------}
{$S GrafWindObjs}

PROCEDURE Num2NiceStr(n: EXTENDED; s: Str255; precision: INTEGER); C; EXTERNAL;

{�Write a number as a string. We use VAR for speed }
PROCEDURE WriteNumber(fileRefNumber: INTEGER; VAR n: EXTENDED);
CONST
	{$IFC qDebug}
	kDigits = 20;
	{$ELSEC}
	kDigits = 8;
	{$ENDC}
VAR
	str: Str255;
	bufLen: LONGINT;
BEGIN
	IF ClassExtended(n) = QNan THEN
		str := ''
	ELSE
		
		Num2NiceStr(n, str, kDigits);
	bufLen := Length(str);
	FailOSErr(FSWrite(fileRefNumber, bufLen, POINTER(ORD4(@str) + 1)));
END;

{--------------------------------------------------------------------------------------------------}
{$S GrafWindObjs}

PROCEDURE WriteChar(fileRefNumber: INTEGER; c: CHAR);
VAR bufLen: LONGINT;
BEGIN
	{�In Pascal, a char takes two bytes, the first being a null, and
		the second being the one we're interested in. }
	bufLen := 1;
	FailOSErr(FSWrite(fileRefNumber, bufLen, POINTER(ORD4(@c) + 1)));
END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

PROCEDURE ReadScrap(theScrap: Handle; VAR scrapOffset: LONGINT; theData: Ptr; 
										dataLength: INTEGER);
 { Utility for extracting data from the scrap, where scrapOffset indicates
  the start of the data within the scrap handle, and dataLength is the length of
  the data to be extracted.  dataLength is added to scrapOffset. }

	VAR
		p:					Ptr;

	BEGIN
	p := POINTER(ORD4(theScrap^) + scrapOffset);
	BlockMove(p, theData, dataLength);
	scrapOffset := scrapOffset + dataLength;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

PROCEDURE WriteScrap(theScrap: Handle; VAR scrapOffset: LONGINT; theData: Ptr; dataLength: INTEGER);
{ Utility for appending data to the end of the scrap handle }

	VAR
		p:					Ptr;

	BEGIN
	SetPermHandleSize(theScrap, scrapOffset + dataLength);
	p := POINTER(ORD4(theScrap^) + scrapOffset);
	BlockMove(theData, p, dataLength);
	scrapOffset := scrapOffset + dataLength;
	END;

{ ---------------------------------------------------------------------------------- }
{$S ADebug}

PROCEDURE DebugWriteln(s: Str255);
BEGIN
	Writeln(s);
END;

{ -----------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE FixEditMenu;
BEGIN
	{ Remove Edit menu buzzwords }
	SetEditCmdName(cCut, cStandardCut);
	SetEditCmdName(cCopy, cStandardCopy);
	SetEditCmdName(cClear, cStandardClear);
END;

{ -----------------------------------------------------------------------------------}
{$S ANonRes}

PROCEDURE MyAlert(strListID, strIndex: INTEGER);
CONST phPlainAlert = 2000;
VAR s: Str255;
BEGIN
	GetIndString(s, strListID, strIndex);
	ParamText(s, '', '', '');
	IF gInBackground THEN
		NotifyBeep;
	StdAlert(phPlainAlert);
END;

{ -----------------------------------------------------------------------------------}
{$S GrafWindObjs}

FUNCTION ExtToInteger(x: Extended): integer;
BEGIN
	ExtToInteger := Num2Integer(x);
END;

{ -----------------------------------------------------------------------------------}
{$S GrafWindObjs}

FUNCTION LCeil(x: Extended): Longint;
VAR saveRoundDir: RoundDir;
BEGIN
	saveRoundDir := getRound;
	SetRound(upward);
	LCeil := Num2Longint(x);
	SetRound(saveRoundDir);
END;
	
{ -----------------------------------------------------------------------------------}
{$S GrafWindObjs}

FUNCTION IsPowerOfTen;
VAR s: Str255;
		i: integer;
BEGIN
	if x = 0 then 
		IsPowerOfTen := FALSE
	else begin
	
		{�correggi il caso in cui x < 0 per trattarlo come il caso
			in cui x > 0 }
		if x < 0 then 
			x := x * (-1);
		
		IsPowerOfTen := TRUE;
		
		NumToString(x, s);
		
		if s[1] <> '1' then 
			IsPowerOfTen := FALSE
		else
			for i := 2 to Length(s) do 
				if s[i] <> '0' then begin
					IsPowerOfTen := FALSE;
					leave;
				end;
	
	end;	{�else }
END;		{ IsPowerOfTen }

{ -----------------------------------------------------------------------------------}
{$S GrafWindObjs}

FUNCTION NextPowerOfTen(x: extended): extended;
VAR s: Str255;
		i: integer;
		xLong: Longint;
BEGIN
	{$IFC qDebug}
	if x <= 0 then begin
			Writeln('x is ', x);
			ProgramBreak('NextPowerOfTen: arg. "x" is null or neg.');
	end;
	{$ENDC}
	
	if x < 1 then 
		NextPowerOfTen := 1.0
	else begin				{�x > 1 }
	
		xLong := LCeil(x);
		if IsPowerOfTen(xLong) then
			NextPowerOfTen := Num2Extended(xLong)
		else begin
			NumToString(xLong, s);
			s := Concat('1', s);
			for i := 2 to Length(s) do
				s[i] := '0';
			NextPowerOfTen := Str2Num(s);
		end;	{ else not IsPowerOfTen(xLong) }
		
	end;		{ else x > 1 }
END;	 		{�NextPowerOfTen }

{ -----------------------------------------------------------------------------------}
{$S GrafWindObjs}

FUNCTION PrevPowerOfTen(x: extended): extended;
CONST
	{ Questa costante e' il numero di cifre piu' grande che la
		Num2Str puo' usare.  }
	kMinPlottableNumberExp = 78;
	kMinPlottableNumber = 10.0 ** (-kMinPlottableNumberExp);
			
VAR s: DecStr;
		i: integer;
		xLong: Longint;
		myDecForm: DecForm;
BEGIN
	{$IFC qDebug}
	if x <= 0 then begin
		Writeln('x is ', x);
		ProgramBreak('PrevPowerOfTen: arg. "x" is null or neg.');
	end;
	{$ENDC}
	
	
	IF x <= 0 THEN
		PrevPowerOfTen := 0
	ELSE
	IF x < kMinPlottableNumber THEN
		PrevPowerOfTen := kMinPlottableNumber
	ELSE
	IF x < 1 THEN BEGIN
	
		{�convertiamo questo numero in stringa decimale }
		myDecForm.Style := FixedDecimal;
		myDecForm.Digits := kMinPlottableNumberExp;
		Num2Str(myDecForm, x, s);
		
		{ cerca la prima cifra non nulla dopo la virgola;
			inizializza "i" perche' punti alla prima cifra dopo la
			virgola, cioe' la terza (vedi infatti ad es. "0.002") }
		i := 3;
		while (s[i] = '0') do
			i := i + 1;
		
		{ poni a '1' questa cifra }
		s[i] := '1';
		
		{ tronca la stringa dopo questa cifra }
		s[0] := chr(i);
		
		{ ora convertiamo in binario la stringa cosi' manipolata...
			et voila! }
		PrevPowerOfTen := Str2Num(s);
	end					{ if x < 1 }
	else begin	{ else x > 1 }

		{ convertiamo x in long, approssimando per difetto }
		xLong := trunc(x);
		
		if IsPowerOfTen(xLong) then
			PrevPowerOfTen := Num2Extended(xLong)
		else begin
			NumToString(xLong, Str255(s));
			s[1] := '1';
			for i := 2 to Length(s) do
				s[i] := '0';

			PrevPowerOfTen := Str2Num(s);
		end;				{ else it is not a power of ten }
	end;					{ else x > 1 }
END;						{ PrevPowerOfTen }

{ -----------------------------------------------------------------------------------}
{$S ARes}

FUNCTION log10(x: extended): Extended;
CONST kOneOverLogOfTen = 0.43429448190325182760;
BEGIN
	log10 := ln(x) * kOneOverLogOfTen;
END;

{ -----------------------------------------------------------------------------------}
{$S GrafWindObjs}

FUNCTION OrderOfMagnitudeDifference;
BEGIN
	{ per problemi di arrotondamento, usiamo round invece di trunc }
	OrderOfMagnitudeDifference := round(log10(larger) - 
																			log10(smaller));
END;		{ OrderOfMagnitudeDifference }

{ -----------------------------------------------------------------------------------}
{$S GrafWindObjs}

PROCEDURE DrawLargeYTick(x,y: integer);
{ 
	Disegna una suddivisione maggiore dell' asse Y, 
	sul port corrente,
	centrata nel punto x,y.
}
BEGIN
	MoveTo(x, y);
	Line(kLargeTickLen, 0);
END;			{ DrawLargeYTick }

{ -----------------------------------------------------------------------------------}
{$S GrafWindObjs}

PROCEDURE DrawLargeXTick(x,y: integer);
{ 
	Analogo per l'asse X
}
BEGIN
	MoveTo(x, y);
	Line(0, - kLargeTickLen);
END;					{�DrawLargeXTick }
											
{ -----------------------------------------------------------------------------------}
{$S GrafWindObjs}

PROCEDURE DrawSmallYTick(x,y: integer);
{ 
	Disegna una suddivisione minore dell' asse Y, 
	sul port corrente,
	centrata nel punto x,y.
}
BEGIN
	MoveTo(x, y);
	Line(kSmallTickLen, 0);
END;				{ DrawSmallYTick }

{ -----------------------------------------------------------------------------------}
{$S MAError}

PROCEDURE EasyFitErrorAlert(err: OSErr; message: LongInt);
CONST
		kMsgCmdErr			= msgCmdErr DIV $10000;
		kMsgAlert			= msgAlert DIV $10000;
		kMsgLookup			= msgLookup DIV $10000;
		kMsgAltRecov		= msgAltRecovery DIV $10000;

TYPE
		Converter			= RECORD
			CASE BOOLEAN OF
				TRUE:
					(message:			 LongInt);
				FALSE:
					(hiWd, loWd:		 INTEGER);
			END;

VAR
		c:					Converter;
		alertID:			INTEGER;
		genericAlert:		BOOLEAN;
		opString:			Str255;
		errStr: 			Str255;
		x:					BOOLEAN;

BEGIN
	c.message := message;

	alertID := phGenError;								{ the default alert }
	genericAlert := TRUE;
	opString := '';

	CASE c.hiWd OF
		kMsgCmdErr:
			BEGIN
			alertID := phCmdErr;
			CmdToName(c.loWd, opString);
			END;
		kMsgAlert:
			BEGIN
			alertID := c.loWd;
			genericAlert := FALSE;
			END;
		kMsgLookup, kMsgAltRecov:
			BEGIN
			x := LookupErrString(c.loWd, errOperationsID, opString);
			END;
		OTHERWISE
			BEGIN
			GetIndString(opString, c.hiWd, c.loWd);
			END;
	END;

	IF genericAlert THEN BEGIN
		CASE err OF
			kFileIsDamaged:
				GetIndString(errStr, kGenericMsgs, eFileIsDamaged);
			kFormulaTooComplex:
				GetIndString(errStr, kGenericMsgs, eOutOfStackSpace);
			kNonRectangularScrap:
				GetIndString(errStr, kGenericMsgs, eNonRectangularScrap);
			kScrapTableTooBig:
				GetIndString(errStr, kGenericMsgs, eScrapTableTooBig);
			kTooManyParametersForELS:
				GetIndString(errStr, kGenericMsgs, eTooManyParametersForELS);
			kFileCreatedByOldVersion:
				GetIndString(errStr, kGenericMsgs, eFileCreatedByOldVersion);
			kXMDLFailed:
				GetIndString(errStr, kGenericMsgs, eXMDLFailed);
			kFailedXMDLInitialization:
				GetIndString(errStr, kGenericMsgs, eFailedXMDLInitialization);
		END;	{�Case }
		
		ParamText(errStr, {�recovery: } '', opString, gErrorParm3);

		IF opString = '' THEN
			alertID := phUnknownErr;
	END;

	StdAlert(alertID);
	gInhibitNestedHandling := FALSE;					{ Used suppress nested event handling }

	IF genericAlert THEN
		ResetAlrtStage;
END;

{ -----------------------------------------------------------------------------------}
{$S ARes}

{�Creates a handle with NewPermHandle, and copies the data of the original handle 
	into the new handle }

FUNCTION CopyHandleData(orig: Handle): Handle;
VAR newHnd: Handle;
		size: LONGINT;
BEGIN
	size := GetHandleSize(orig);
	newHnd := NewPermHandle(size);
	FailNil(newHnd);
	MoveHHi(orig);
	HLock(orig);
	FailOSErr(PtrToXHand(orig^, newHnd, size));
	HUnLock(orig);
	CopyHandleData := newHnd;
END;

{ ---------------------------------------------------------------------------------- }
{$S CallFit}

{�Sends a beep in a notification-manager-compatible way. It also flashes
	the application small icon. }
	
{�Holds notification requests for the notification manager }
VAR	pNMRequest:				NMRec;
	
PROCEDURE NotifyBeep;
VAR mySmallIcon: Handle;
BEGIN
	IF gInBackGround & (gConfiguration.systemVersion >= $0600) THEN BEGIN
		WITH pNMRequest DO BEGIN
			qType := ORD(nmType);
			nmMark := 0;
			mySmallIcon := GetResource('SICN', 1000);
			nmSIcon := mySmallIcon;
			nmSound := Handle(-1);
			nmStr := NIL;
			nmResp := Pointer(-1);
		END;
		IF NMInstall(@pNMRequest)=noErr THEN;
	END
	ELSE
		SysBeep(50);
END;

{ ---------------------------------------------------------------------------------- }
{$S CallFit}

{�Calls the notification manager to flashe the application small icon. }

PROCEDURE NotifyFlashSICN;
VAR mySmallIcon: Handle;
BEGIN
	IF gInBackGround & (gConfiguration.systemVersion >= $0600) THEN BEGIN
		WITH pNMRequest DO BEGIN
			qType := ORD(nmType);
			nmMark := 0;
			mySmallIcon := GetResource('SICN', 1000);
			nmSIcon := mySmallIcon;
			nmSound := NIL;
			nmStr := NIL;
			nmResp := Pointer(-1);
		END;
		IF NMInstall(@pNMRequest)=noErr THEN;
	END
END;

{ ----------------------------------------------------------------------------------- }
{$S ADoCommand}

{�This procedure first shows the std dialog to write a file; if the 
	user doesn't cancel, we open a file and then write data in it. }
	
FUNCTION WriteInOpenFile(prompt, defaultFileName: Str255;
													fileType, fileCreator: OSType;
													mustUpdateWindows: BOOLEAN;
													PROCEDURE WriteThis(aRefNumber: INTEGER)): BOOLEAN;
VAR
	reply:					SFReply;
	SFWhere:				Point;
	fileRefNumber: 	INTEGER;
	fndrInfo:				FInfo;
	OSResult:				OSErr;
	fi:							FailInfo;
		
	PROCEDURE HdlOpenFileFailure(error: OSErr; message: LONGINT);
	BEGIN
		IF FSClose(fileRefNumber) = noErr THEN ;
		IF FSDelete(reply.fName, reply.vRefNum) = noErr THEN ;
		IF FlushVol(NIL, reply.vRefnum) = noErr THEN;
	END;
	
BEGIN
	{ʥ�Open Std File dialog }
	SFWhere.h := 100;
	SFWhere.v := 100;

	{ Update all the windows to avoid a bug in Standard File in which
		you can't mount a disk correctly when window updates are pending.
		Also to make sure that the plot window is drawn, so that fDomain
		is properly set. }
	IF mustUpdateWindows THEN
		gApplication.UpdateAllWindows;
	
	SFPutFile(SFWhere,
						prompt,
						defaultFileName,
						NIL,
						reply);
			
	WITH reply DO
		IF good THEN BEGIN

			{ ��Open the file }
			OSResult := FSOpen(fName, vRefNum, fileRefNumber);
			IF OSResult = noErr THEN											{�Se il file gia' esiste, vuotalo
																											da quello che conteneva }
				FailOSErr(SetEOF(fileRefNumber, 0))
			ELSE
			IF OSResult = fnfErr THEN BEGIN								{�se il file non esiste, crealo }
				FailOSerr(Create(fName, vRefNum, kTextCreator, 'TEXT'));
				FailOSErr(FSOpen(fName, vRefNum, fileRefNumber));
			END
			ELSE
				FailOSErr(OSResult);

			{ʥ�Write the data to it }
			CatchFailures(fi, HdlOpenFileFailure);
			WriteThis(fileRefNumber);
			Success(fi);
			
			{ ��Close the file }
			FailOSErr(FSClose(fileRefNumber));
			
			{ ��set appropriate finder info }
			FailOSErr(GetFInfo(fName, vRefNum, fndrInfo));
			WITH fndrInfo DO BEGIN
				fdType := fileType; 
				fdCreator := fileCreator;
			END;
			FailOSErr(SetFInfo(fName, vRefNum, fndrInfo));
			FailOSErr(FlushVol(NIL, vRefnum));
			
			WriteInOpenFile := TRUE;
		END
		ELSE
			WriteInOpenFile := FALSE;
END;

{ ----------------------------------------------------------------------------------- }
{$S PrintImage}

PROCEDURE PreparePageFooter(VAR footer: Str255; pageNumber: INTEGER);
VAR aStr: Str255;
BEGIN
	NumToString(pageNumber, aStr);
	footer := CONCAT('-', aStr, '-');
END;

{ ----------------------------------------------------------------------------------- }
{$S PrintImage}

PROCEDURE PreparePageHeader(VAR header, viewName, docName: Str255);
VAR dateStr:									Str255; 
		timeStr:									Str255;
		theSecs:									Longint;
BEGIN
	GetDateTime(theSecs);
	IUDateString(theSecs, abbrevDate, dateStr);
	IUTimeString(theSecs, false, timeStr);
	header := 
		Concat(viewName, ' from �', docName, '�. ', dateStr, ' at ', timeStr);
END;

{ ----------------------------------------------------------------------------------- }
{$S PrintImage}

{�Compute the rect that will contain a string when printed. We rely on the font
	being properly set. We assume the string will be horizontally centered on the page
	thePage. We pass the string as a VAR for speed. }

PROCEDURE ComputeTextRect(VAR aString: Str255; baseLine: INTEGER;
		thePaper: Rect; VAR theTextRect: Rect);
VAR
	theFontInfo:	FontInfo;
	itsWidth:			INTEGER;
	rPlusL: 			INTEGER;
BEGIN
	GetFontInfo(theFontInfo);
	WITH thePaper DO
		rPlusL := right + left;
	itsWidth := StringWidth(aString);
	{$Push} {$H-}
	WITH theTextRect, theFontInfo DO BEGIN
		left := (rPlusL - itsWidth) DIV 2;
		top := baseLine - ascent;
		right := left + itsWidth;
		bottom := baseLine + descent;
		END;
	{$Pop}
END;

{ ----------------------------------------------------------------------------------- }
{$S AInit}

{�Execute a specified operation on all of the files of type fileType in
	the directory specified by vRefNumber. A Working Directory ref num
	is acceptable in place of a volume ref number.
	The DoToFile function should return TRUE if it needs to go on to the next file,
	or FALSE if it wants to stop. }

PROCEDURE DoToFilesInWD(fileType: OSType;
												vRefNumber: INTEGER;
												FUNCTION DoToFile(fileName: Str255;
																					vRefNumber: INTEGER): BOOLEAN);
VAR
	pb:					HParamBlockRec;
	continue:		BOOLEAN;
	err:				OSErr;
	fileName:		Str255;
	
BEGIN

	fileName := '';
	WITH pb DO BEGIN
		ioNamePtr := @fileName;
		ioVRefNum := vRefNumber;
		ioFVersNum := 0;
		ioFDirIndex := 1;
	END;
	
	continue := TRUE;
	REPEAT 
		err := PBGetFInfo(@pb, {async:} FALSE);
		
		{$IFC qDebug}
		IF err <> noErr THEN
			Writeln('DoToFilesInDirectory: PBGetFInfo exited with code ', err:1);
		{�Write('DoToFilesInWD: File type: ', pb.ioFlFndrInfo.fdType); }
		{�Writeln(', File name: ', fileName); }
		{$ENDC}
		
		IF (err = noErr) & (pb.ioFlFndrInfo.fdType = fileType) THEN
			 continue := DoToFile(fileName, vRefNumber);
			
		pb.ioFDirIndex := pb.ioFDirIndex + 1;
	UNTIL (err <> noErr) | NOT continue;
END;

{ ----------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE GetMacAppDebugNames(o: TObject; VAR className: MAName; VAR inspName: Str255);
BEGIN
	o.GetInspectorName(inspName);
	o.GetClassName(className);
END;