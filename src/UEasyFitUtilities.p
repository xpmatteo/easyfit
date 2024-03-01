{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}

UNIT UEasyFitUtilities;

INTERFACE

USES
	{ � MacApp }
	UMacApp,
	
	{ � Required by UEasyFitDeclarations }
	Fonts,
	
	{ʥ Needed by interface part }
	UEasyFitDeclarations,

	{ʥ Needed by implementation part }
	ToolUtils, Errors, Notification, Resources, SANE, Packages;


{ Formatting and Drawing routines }

PROCEDURE FitString(VAR theString: Str255; maxWidth: INTEGER);
FUNCTION  IsDigit(Ch: CHAR): BOOLEAN;
PROCEDURE SetEditCmdName(theCommand, customCommand: INTEGER);
PROCEDURE SetTheFont(fontNumber, fontSize: INTEGER; fontStyle: Style);
PROCEDURE SmartDrawString(theString: Str255; h, v, width: INTEGER; justification: INTEGER);

	{ Reading and Writing from and to disk }

PROCEDURE ReadBytes(theRefNum: INTEGER; size: LONGINT; buffer: Ptr);
PROCEDURE WriteBytes(theRefNum: INTEGER; size: LONGINT; buffer: Ptr);
PROCEDURE WriteNumber(fileRefNumber: INTEGER; VAR n: EXTENDED);
PROCEDURE WriteChar(fileRefNumber: INTEGER; c: CHAR);
PROCEDURE ReadScrap(theScrap: Handle; VAR scrapOffset: LONGINT; theData: Ptr; dataLength: INTEGER);
PROCEDURE WriteScrap(theScrap: Handle; VAR scrapOffset: LONGINT; theData: Ptr; dataLength: INTEGER);
FUNCTION WriteInOpenFile(prompt, defaultFileName: Str255;
													fileType, fileCreator: OSType;
													mustUpdateWindows: BOOLEAN;
													PROCEDURE WriteThis(aRefNumber: INTEGER)): BOOLEAN;
PROCEDURE DoToFilesInWD(fileType: OSType;
												vRefNumber: INTEGER;
												FUNCTION DoToFile(fileName: Str255;
																					vRefNumber: INTEGER): BOOLEAN);

	{�Communicating with C }

{�Write a string on the debug window }
PROCEDURE DebugWriteln(s: Str255);

{�Get debugging names informations }
PROCEDURE GetMacAppDebugNames(o: TObject; VAR className: MAName; VAR inspName: Str255);

	{�Mathematical utilities }
	
{ funzione "ceiling": approssima per eccesso un extended }
FUNCTION LCeil(x: Extended): Longint;

{ ExtToInteger - converte un extended in un integer,
	tenendo conto della direzione di arrotondamento corrente.
	serve per potere essere chiamata dal C. }
FUNCTION ExtToInteger(x: Extended): integer;

FUNCTION IsPowerOfTen(x: Longint): boolean;

{ restituisce la potenza di dieci piu' vicina dall'alto a
	un numero dato.   Non funziona se gli si passa 
	un valore <= 0 }
FUNCTION NextPowerOfTen(x: extended): extended;

{ restituisce la potenza di dieci piu' vicina dal basso a
	un numero dato.
	Se gli si passa un numero <= 0, restituisce 0. }
FUNCTION PrevPowerOfTen(x: extended): extended;

{ OrderOfMagnitudeDifference - differenza di ordini di
	grandezza tra due potenze di dieci }
FUNCTION OrderOfMagnitudeDifference(larger, smaller: extended):
							integer;

{ logaritmo in base 10 }
FUNCTION log10(x: extended): Extended;
	
	{�Miscellanea }
	
PROCEDURE FixEditMenu;
PROCEDURE MyAlert(strListID, strIndex: INTEGER);
FUNCTION CopyHandleData(orig: Handle): Handle;
PROCEDURE EasyFitErrorAlert(err: OSErr; message: LongInt);
PROCEDURE NotifyBeep;
PROCEDURE NotifyFlashSICN;

	{�Graphical utilities }

{ Procedure che disegnano le tacche sugli assi; la tacchetta
	viene disegnata sul port corrente alle coordinate x,y }
PROCEDURE DrawSmallYTick(x,y: integer);
PROCEDURE DrawLargeYTick(x,y: integer);
PROCEDURE DrawLargeXTick(x,y: integer);

	{�Printing utilities }

PROCEDURE PreparePageFooter(VAR footer: Str255; pageNumber: INTEGER);
PROCEDURE PreparePageHeader(VAR header, viewName, docName: Str255);
PROCEDURE ComputeTextRect(VAR aString: Str255; baseLine: INTEGER;
		thePaper: Rect; VAR theTextRect: Rect);


IMPLEMENTATION

{$I UEasyFitUtilities.inc1.p}

END.