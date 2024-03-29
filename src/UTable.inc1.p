{ 
	UTable.inc1.p
	
	This Unit is a modification of Apple's Ucalc.inc1.p from the Calc MacApp example.
	
	Copyright � 1986-1989 by Apple Computer, Inc. All rights reserved.
	Changes Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.	
}

{�
	Notes about the TCell class:
	The "true" value of a cell is held in BOTH fValue, as binary, and fFormula, as
	a string. I know that is a waste, but at the moment it is more important 
	for me to get the thing working than to optimize.
	The fValueString field contains the cell content for display, which can be 
	less precise (i.e. less digits) than the true value.
	
	EvaluateFormula performs a Str2Num conversion between fFormula and fValue.

	EvaluateFormula:	fFormula	---Str2Num--> fValue
	ValueToString:		fValue		------------> fValueString
	
	Other note:
	TTable could probably get simpler if we only kept the binary value of each
	cell instead of both binary and decimal.  The present organization was inherited
	from the Calc MacApp example.
	
	12/2/90: Added parameter to GetMinOfCol and GetMaxOfCol so that when
		the plot in the windows must be semilog, we ignore any negative 
		quantities.
}
	
CONST
	kColumnSizingCursor = 1020;							{ cursor for resizing a column }

TYPE
	TypeOfLine			= (NoLine,							{ for DrawLine routine}
						   SolidLine, BoldLine, VDottedLine, HDottedLine, RowSeparator,
						   ColumnSeparator);

	
VAR																				{�This unit's GLOBALS }
	{ SANE conversion formats }
	pDecimalFormat: 	ValueFormat;
	pScientificFormat: ValueFormat;

	pColumnSeparatorPattern: Pattern;				{ patterns for separator lines }
	pRowSeparatorPattern: Pattern;
	
{--------------------------------------------------------------------------------------------------}

	{�External routines }
	
PROCEDURE SetPtrToZero(p: Ptr; size: LONGINT); C; EXTERNAL;

PROCEDURE SetIthElement(p: PExtended; i: INTEGER; value: EXTENDED); C; EXTERNAL;

PROCEDURE GetIthElement(p: PExtended; i: INTEGER; VAR value: EXTENDED); C; EXTERNAL;

PROCEDURE Num2NiceStr(e: EXTENDED; s: Str255; precision: INTEGER); C; EXTERNAL;

{--------------------------------------------------------------------------------------------------}
{�This is defined elsewhere }

PROCEDURE RemindUserWeAreWorking; EXTERNAL;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE FormatFields (aTitle: Str255; VAR aFormat: FormatRecord; PROCEDURE
						DoToField(fieldName: Str255; fieldAddr: Ptr; fieldType: INTEGER));

VAR
	aString:			Str255;
	anInteger:		INTEGER;
	aStyle:				Style;

BEGIN
	{ Because our brain-damaged compiler won't allow you to pass the address of byte-aligned
	  fields in packed records, we have to move the fields of a FormatRecord into a temporary
	  variable, then pass the address of the temporary. }

	DoToField(aTitle, NIL, bTitle);
	WITH aFormat DO
		BEGIN
		CASE aFormat.fStyle OF
			NoStyle:			aString := 'NoStyle';
			General:			aString := 'General';
			DecimalStyle:		aString := 'DecimalStyle';
			Scientific:			aString := 'Scientific';
			OTHERWISE			aString := 'UnknownStyle';
			END;
		DoToField('  fStyle', @aString, bString);

		anInteger := fDigits;
		DoToField('  fDigits', @anInteger, bInteger);
		
		CASE fJustification OF
			TEJustLeft:			aString := 'Left';
			TEJustCenter:		aString := 'Center';
			TEJustRight:		aString := 'Right';
			kNoJustification:	aString := 'None';
			OTHERWISE			aString := 'Unknown';
			END;
		DoToField('  fJustification', @aString, bString);

		anInteger := fFontNumber;
		DoToField('  fFontNumber', @anInteger, bFontName);
		anInteger := fFontSize;
		DoToField('  fFontSize', @anInteger, bInteger);
		aStyle := fFontStyle;
		DoToField('  fFontStyle', @aStyle, bStyle);
		END;
END;

{--------------------------------------------------------------------------------------------------}
{$S AReadFile}

PROCEDURE ReadCellCoordinate(theRefNum: INTEGER; VAR r: RowNumber; VAR c: ColumnNumber);
{ Reads a cell coordinate from a file }
VAR cellCoordinate: 	Point;

BEGIN
	ReadBytes(theRefNum, SIZEOF(cellCoordinate), @cellCoordinate);
	r := cellCoordinate.v;
	c := cellCoordinate.h;
END;

{ --------------------------------------------------------------------------------- }
{$S AInit}

PROCEDURE InitTables;
BEGIN
	{ Suppress Linker dead-stripping of these classes }
	IF gDeadStripSuppression THEN BEGIN
		IF Member(TObject(NIL), TCellsView) THEN;
		IF Member(TObject(NIL), TRowsView) THEN;
		IF Member(TObject(NIL), TColumnsView) THEN;
		IF Member(TObject(NIL), TEntryView) THEN;
		{�IF Member(TObject(NIL), TCoordView) THEN; }
		IF Member(TObject(NIL), TTableScroller) THEN;
		IF Member(TObject(NIL), TTablePrintView) THEN;
		IF Member(TObject(NIL), TConstraintsTablePrintView) THEN;
	END;
	
	gAlwaysTrackCursor := TRUE;				{ Track the grabber hand }

	pDecimalFormat.Style := FixedDecimal;
	pDecimalFormat.digits := kDefaultPrecision;

	pScientificFormat.Style := FloatDecimal;
	pScientificFormat.digits := kDefaultPrecision;

	gDefaultFormat.fJustification := kDefaultJustification;
	gDefaultFormat.fStyle := General;
	gDefaultFormat.fDigits := kDefaultPrecision;
	gDefaultFormat.fFontNumber := kCellFont;
	gDefaultFormat.fFontSize := kCellFontSize;
	gDefaultFormat.fFontStyle := [];
	
	gClipFormat := gDefaultFormat;
	gClipFormat.fFontNumber := systemFont;
	gClipFormat.fFontSize := 12;

	pColumnSeparatorPattern := gray;
	pRowSeparatorPattern := gray;
	
END;		{ InitTables }

{***************************************************************************************************
	T D y n a V e c t o r
***************************************************************************************************}

{$S AOpen} { Presently we only allocate a DynaVector at doc opening time }
PROCEDURE TDynaVector.IDynaVector(first, last: INTEGER);
VAR sizeOfDataInBytes: LONGINT;
BEGIN
	{$IFC qDebug}
	IF last < first THEN BEGIN
			Writeln('TDynaVector = ', ORD4(SELF),
							'first ', first,
							'last ', last);
			ProgramBreak('Wrong bounds in IDynaVector');	
	END;
	{$ENDC}
	
	{ Compute how much memory we need }
	sizeOfDataInBytes := SIZEOF(Handle) * (last - first + 1);
	
	{ Allocate it }
	fData := NewPermPtr(sizeOfDataInBytes);
	
	{$IFC qDebug}
		if fData = NIL THEN BEGIN
			Writeln('TDynaVector = ', ORD4(SELF),
							'sizeOfDataInBytes = ', sizeOfDataInBytes,
							'first ', first,
							'last ', last);
			ProgramBreak(' ahi ahi ahi, fData = NIL in TDynaVector');
		END;
	{$ENDC}
	
	FailNil(fData);
	
	{�Set it to zero (it is done here at low level to achieve max performance) }
	SetPtrToZero(fData, sizeOfDataInBytes);
	
	{�Set offset }
	fData := Pointer(ORD4(fData) - first * SIZEOF(Handle));
	
	{�set other fields }
	fFirst := first;
	fLast := last;
END;

{$S AClose}
PROCEDURE TDynaVector.Free;	OVERRIDE;
BEGIN
	fData := POINTER(ORD4(fData) + fFirst * SIZEOF(Handle));
	DisposIfPtr(fData);
	
	INHERITED Free;
END;

{$S ARes}
FUNCTION TDynaVector.GetElement(n: INTEGER): TObject;
VAR aPtr: ^TObject;
BEGIN
	{$IFC qDebug}	{�Check that we are trying to get a valid element }
		IF (n < fFirst) | (n > fLast) THEN BEGIN
			Writeln('n =', n);
			Writeln('fFirst, fLast = ', fFirst, fLast);
			ProgramBreak('DynaArray out of bounds!');
		END;
	{$ENDC}
	
	aPtr := Pointer(ORD4(fData) + n * SIZEOF(Handle));
	{�Writeln('TDynaVector.GetElement: about to return', ORD4(aPtr^)); }
	GetElement := aPtr^;
END;

{$S ARes}
PROCEDURE TDynaVector.SetElement(n: INTEGER; toThis: TObject);
VAR aPtr: ^TObject;
BEGIN
	{$IFC qDebug}
		IF (n < fFirst) | (n > fLast) THEN BEGIN
			ProgramBreak('DynaArray out of bounds!');
			Writeln('n =', n);
			Writeln('fFirst, fLast = ', fFirst, fLast);
		END;
	{$ENDC}
	
	aPtr := POINTER(ORD4(fData) + n * SIZEOF(Handle));
	aPtr^ := toThis;
END;

{$S AFields}
PROCEDURE TDynaVector.Fields(PROCEDURE DoToField(fieldName: Str255; 
														 fieldAddr: Ptr;
														 fieldType: INTEGER)); OVERRIDE;				
BEGIN
	DoToField('TDynaVector', NIL, bClass);
	DoToField('fData', @fData, bPointer);
	DoToField('fFirst', @fFirst, bINTEGER);
	DoToField('fLast', @fLast, bINTEGER);
	
	INHERITED Fields(DoToField);
END;

{***************************************************************************************************
	T D y n a M a t r i x
***************************************************************************************************}
{
	We implement the DynaMatrix simply by allocating a single big chunk of
	memory, and representing the matrix into it by rows.
}

{$S AOpen}
PROCEDURE TDynaMatrix.IDynaMatrix(dimension: Rect);
VAR NCols:							LONGINT;
		NRows:							LONGINT;
		sizeOfDataInBytes:	LONGINT;
BEGIN
	WITH dimension DO BEGIN
		NRows := bottom - top + 1;
		NCols := right - left + 1;
		fRowOffset := left;
		fColumnOffset := top;
	END;
	
{$IFC qDebug}
	{�writeln('NCols is ', NCols, ' and NRows is ', NRows); }
{$ENDC}	

	sizeOfDataInBytes := (NCols * NRows) * SIZEOF(Handle);
	fData := NewPermPtr(sizeOfDataInBytes);
	FailNil(fData);
	
	SetPtrToZero(fData, sizeOfDataInBytes);
	
	fDimension := dimension;
	fNRows := NRows;
	fNColumns := NCols;
END;

{$S AClose}
PROCEDURE TDynaMatrix.Free;	OVERRIDE;
BEGIN
	DisposIfPtr(fData);
	
	INHERITED Free;
END;

{$S ARes}
FUNCTION TDynaMatrix.GetElement(r, c: LONGINT): TObject;
VAR aPtr:				^TObject;
		{$IFC qDebug}
		dimension:	Rect;
		{$ENDC}
BEGIN
	{$IFC qDebug}
		dimension := fDimension;
		WITH dimension DO
			IF ((r < top) | (r > bottom) | (c < left) | (c > right)) THEN BEGIN
				IF (r < top)		THEN writeln('(r < top)', r , top);
				IF (r > bottom)	THEN writeln('(r > bottom)', r , bottom);
				IF (c < left)		THEN writeln('(c < left)', c , left);
				IF (c > right)	THEN writeln('(c > right)', c , right);
				writeln('r = ', r, ' c = ', c);
				writeln('rect is ', left, top, right, bottom);
				ProgramBreak('DynaMatrix.GetElement out of bounds!!!');
			END;
	{$ENDC}
	
	aPtr := POINTER(ORD4(fData) + 
									fNColumns * (r - fRowOffset) * SIZEOF(Handle) +
									(c - fColumnOffset) * SIZEOF(Handle));
	GetElement := aPtr^;
END;

{$S ARes}
PROCEDURE TDynaMatrix.SetElement(r, c: LONGINT; toThis: TObject);
VAR aPtr:				^TObject;
		{$IFC qDebug}
		dimension:	Rect;
		{$ENDC}
BEGIN
	{$IFC qDebug}
		{�Writeln('TDynaMatrix.SetElement: (r,c)= ',r ,c); }
		dimension := fDimension;
		WITH dimension DO
			IF ((r < top) | (r > bottom) | (c < left) | (c > right)) THEN BEGIN
				IF (r < top)		THEN writeln('(r < top)', r , top);
				IF (r > bottom)	THEN writeln('(r > bottom)', r , bottom);
				IF (c < left)		THEN writeln('(c < left)', c , left);
				IF (c > right)	THEN writeln('(c > right)', c , right);
				writeln('r = ', r, ' c = ', c);
				writeln('Dinamatrix dim is (ltrb)', left, top, right, bottom);
				ProgramBreak('DynaMatrix.SetElement out of bounds!!!');
			END;
	{$ENDC}
		
	aPtr := POINTER(ORD4(fData) + 
									fNColumns * (r - fRowOffset) * SIZEOF(Handle) +
									(c - fColumnOffset) * SIZEOF(Handle));
	aPtr^ := toThis;
END;

{$S AFields}

PROCEDURE TDynaMatrix.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
												 		 fieldType: INTEGER)); OVERRIDE;
BEGIN
	DoToField('TDynaMatrix', NIL, bClass);
	DoToField('fData', @fData, bPointer);
	DoToField('fDimension', @fDimension, bRect);
	DoToField('fNRows', @fNRows,	bINTEGER);
	DoToField('fNColumns', @fNColumns, bINTEGER);
	DoToField('fRowOffset', @fRowOffset, bINTEGER);
	DoToField('fColumnOffset', @fColumnOffset, bINTEGER);
	
	INHERITED Fields(DoToField);
END;

{***************************************************************************************************
	T T a b l e
***************************************************************************************************}
{$S AOpen}

PROCEDURE TTable.ITable(dimensions: Rect; 
												itsDocument: TDocument;
												format: FormatRecord;
												template: INTEGER);
VAR r:						RowNumber;
		c:						ColumnNumber;
		aRect:				Rect;
		aDynaVector:	TDynaVector;
		aDynaMatrix:	TDynaMatrix;
		
BEGIN
	fTableWindow := NIL;			{�Make sure Free will work }
	fColumns := NIL;
	fRows := NIL;
	fCells := NIL;
	fCellsView := NIL;
	fRowsView := NIL;
	fColumnsView := NIL;
	fEntryView := NIL;
	{�fCoordView := NIL; }
	
	fDocument := itsDocument;
	fTemplate := template;
	
	fReadOnly := FALSE; { default }

	fDimensions := dimensions;
	WITH dimensions DO
		BEGIN
		fRowOffset := top - 1;
		fColumnOffset := left - 1;
		fNoOfRows := bottom - top + 1;
		fNoOfColumns := right - left + 1;
		END;
	fSelectionType := NoSelection;

	fEditRow := 0;
	fEditColumn := 0;
	fEditCell := NIL;
	
	{ Initialize cells, rows and columns }
	New(aDynaVector);
	FailNil(aDynaVector);
	aDynaVector.IDynaVector(1, fNoOfRows);
	fRows := aDynaVector;
	
	New(aDynaVector);
	FailNil(aDynaVector);
	aDynaVector.IDynaVector(1, fNoOfColumns);
	fColumns := aDynaVector;
	
	New(aDynaMatrix);
	FailNil(aDynaMatrix);
	SetRect(aRect, 1, 1, fNoOfColumns, fNoOfRows);
	aDynaMatrix.IDynaMatrix(aRect);
	fCells := aDynaMatrix;
	
	{�The original pgm here was setting all places in fCells, fRows and fColumns
		to NIL.  To speed up things, I have built TDynavector and TDynaMatrix so
		that they always set to zero all of their fData field. }

	SetRect(aRect, 1, 1, 1, 1);
	fInUseBounds := aRect;
	
	fFormat := format;
END;

{--------------------------------------------------------------------------------------------------}
{$S AClose}

PROCEDURE TTable.Free;
BEGIN
	FreeData;
	FreeIfObject(fCells);
	FreeIfObject(fRows);
	FreeIfObject(fColumns);
	
	{�we need to free the views too, since we didn't declare freeOnClosing in the
		templates }
	FreeIfObject(fTableWindow);

	INHERITED Free;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TTable.AddCell(theCell: TCell; r: RowNumber; c: ColumnNumber);

	VAR
		aRect:				Rect;

	BEGIN
	fCells.SetElement(r, c, theCell);
	fAllocatedCells := fAllocatedCells + 1;

	SetRect(aRect, c, r, c, r);
	{$Push}{$H-}
	UnionRect(aRect, fInUseBounds, fInUseBounds);
	{$Pop}

	WITH theCell DO
		BEGIN
		fTable := SELF;
		fRow := r;
		fColumn := c;
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.ChangedColumn(all: BOOLEAN; column: ColumnNumber);
BEGIN
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TTable.AddColumn(theColumn: TColumn);
BEGIN
	fColumns.SetElement(theColumn.fNumber, theColumn);
	fAllocatedColumns := fAllocatedColumns + 1;

	fInUseBounds.left := Min(fInUseBounds.left, theColumn.fNumber);
	fInUseBounds.right := Max(fInUseBounds.right, theColumn.fNumber);
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TTable.AddRow(theRow: TRow);

	BEGIN
	fRows.SetElement(theRow.fNumber, theRow);
	fAllocatedRows := fAllocatedRows + 1;

	fInUseBounds.top := Min(fInUseBounds.top, theRow.fNumber);
	fInUseBounds.bottom := Max(fInUseBounds.bottom, theRow.fNumber);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

FUNCTION TTable.CellExists(r: RowNumber; c: ColumnNumber): BOOLEAN;

	BEGIN
	IF (r > 0) & (c > 0) & (fCells.GetElement(r, c) <> NIL) & 
			(NOT (TCell(fCells.GetElement(r, c)).fDeleted)) THEN
		CellExists := TRUE
	ELSE
		CellExists := FALSE;

	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

FUNCTION TTable.CellInRange(r: INTEGER; c: INTEGER; range: Rect): BOOLEAN;

	BEGIN
	WITH range DO
		CellInRange := (r >= top) & (r <= bottom) & (c >= left) & (c <= right);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

FUNCTION TTable.ColumnExists(c: ColumnNumber): BOOLEAN;

	BEGIN
	ColumnExists := FALSE;

	IF (c > 0) & (fColumns.GetElement(c) <> NIL) THEN
		ColumnExists := TRUE;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TTable.ConstrainToUsedCells(VAR cellRange: Rect);
 { Given a range of cells, this returns the range of cells that fall
   within the range of used cells.  This is used to optimize
   performance so that we don't try to operate on cells that
   we know have never been used (i.e. allocated). }

	BEGIN
	WITH cellRange DO
		BEGIN
		top := Max(top, fInUseBounds.top);
		left := Max(left, fInUseBounds.left);
		bottom := Min(bottom, fInUseBounds.bottom);
		right := Min(right, fInUseBounds.right);
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.CoordToString(coord: INTEGER; VAR theString: Str255);
BEGIN
	coord := coord - 1;
	IF coord < 26 THEN
		BEGIN
		theString := ' ';
		theString[1] := CHR(ORD('A') + coord);
		END
	ELSE
		BEGIN
		theString := '  ';
		theString[1] := CHR(ORD('A') + (coord DIV 26) - 1);
		theString[2] := CHR(ORD('A') + (coord MOD 26));
		END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.DeleteCell(r: RowNumber; c: ColumnNumber);

	VAR
		theCell:			TCell;

	BEGIN
	theCell := GetExistingCell(r, c);
	IF theCell <> NIL THEN
		BEGIN
		theCell.SetDeleteState(TRUE);
		fAllocatedCells := fAllocatedCells - 1;
		IF theCell = fEditCell THEN
			fEntryView.SetToString('');
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AOpen}

PROCEDURE TTable.DoInitialState;
BEGIN
	fAllocatedCells := 0;
	fAllocatedRows := 0;
	fAllocatedColumns := 0;

	fFormat := gDefaultFormat;
END;

{--------------------------------------------------------------------------------------------------}
{$S AOpen}

PROCEDURE TTable.DoMakeViews(forPrinting: BOOLEAN);
VAR aTableWindow:				TWindow;
		aTEntryView:				TEntryView;
		aCellsView: 				TCellsView;
		aColumnsView:				TColumnsView;
		aRowsView:					TRowsView;
		{�aCoordView: 				TCoordView; }
		aHorzScrollBar:		 	TSScrollBar;
		aVertScrollBar:			TSScrollBar;
		aScroller:					TScroller;
		aTableScroller:			TTableScroller;
		aCell:							GridCell;
		aPrintHandler:			TTablePrintHandler;
		
	PROCEDURE SetColumnWidths;
	VAR c:					ColumnNumber;
			newWidth:		INTEGER;
	BEGIN
		FOR c := 1 TO fNoOfColumns DO
			IF fColumns.GetElement(c) <> NIL THEN
				BEGIN
				newWidth := TColumn(fColumns.GetElement(c)).fWidth;
				IF newWidth <> kCellWidth THEN
					BEGIN
					fCellsView.SetColWidth(c, 1, newWidth);
					fColumnsView.SetColWidth(c, 1, newWidth);
					END;
				END;
		END;

BEGIN												{�TTable.DoMakeViews }

	aTableWindow := NewTemplateWindow(fTemplate, fDocument);
	FailNIl(aTableWindow);
	
	WITH aTableWindow DO BEGIN
		aCellsView := TCellsView(FindSubView('CELL'));
		aRowsView := TRowsView(FindSubView('ROWS'));
		aColumnsView := TColumnsView(FindSubView('COLS'));
		aTEntryView := TEntryView(FindSubView('ENTV'));
		{�aCoordView := TCoordView(FindSubView('CORD')); }
	END;
	
	{�This is to allow CloseWMgrWindow to close the window even if it has no go-away
		box.  I don't understand why very well. }
	aTableWindow.fIsClosable := TRUE;
	
	{ Tell wether this should be shown when the doc is open or not }
	aTableWindow.fOpenInitially := FALSE;
		
	fTableWindow := aTableWindow;
	aCellsView.fTable := SELF;
	aRowsView.fTable := SELF;
	aColumnsView.fTable := SELF;
	{�aCoordView.fTable := SELF; }
	aTEntryView.fTable := SELF; 
	
	aCellsView.fReadOnly := fReadOnly;
	aTEntryView.fAcceptsChanges := NOT fReadOnly;
	
	{�There may be a problem here, since this was done at TColumnView.Ires time,
		and I had to bring it here since I could not get a reference to the correct
		table in that method.  I can't see if it could bring any problem. }
	fColumnIsSelected := FALSE;

	IF NOT forPrinting THEN BEGIN
		aTEntryView.fText := NewPermHandle(0);
		FailNIL(aTEntryView.fText);
		aTEntryView.StuffText(aTEntryView.fText);		{ Stuff the initial text in }
		aTEntryView.fTouched := FALSE;
		aTEntryView.fTEditing := FALSE;
		aTEntryView.fOldString := '';
	END;

	{ Insert the entry view between the cell's view and its scroller in the target chain }
	aTableWindow.fTarget := aCellsView;
	aTEntryView.fNextHandler := aCellsView.fNextHandler;
	aCellsView.fNextHandler := aTEntryView;

	{ set up the cells view scroller to scroll the rows and columns too }
	aTableScroller := TTableScroller(aCellsView.GetScroller(TRUE));
	aTableScroller.SetScrollParameters(kCellWidth, kCellHeight, TRUE, TRUE);
	aScroller := aColumnsView.GetScroller(TRUE);
	aScroller.SetScrollParameters(kCellWidth, kCellHeight, TRUE, TRUE);
	aTableScroller.fColumnScroller := aScroller;
	aScroller := aRowsView.GetScroller(TRUE);
	aScroller.SetScrollParameters(kCellWidth, kCellHeight, TRUE, TRUE);
	aTableScroller.fRowScroller := aScroller;

	fCellsView := aCellsView;
	fRowsView := aRowsView;
	fColumnsView := aColumnsView;
	fEntryView := aTEntryView;
	{�fCoordView := aCoordView; }
	fPrintView := TTablePrintView(aTableWindow.FindSubView('prnt'));
	IF fPrintView <> NIL THEN
		fPrintView.fCellsView := fCellsView;
	
	NEW(aPrintHandler);
	FailNIL(aPrintHandler);
	aPrintHandler.IStdPrintHandler(fDocument,				{ its document }
																 fPrintView,			{ its view }
																 NOT kSquareDots,	{ does not have square dots }
																 NOT kFixedSize,	{ horizontal page size is variable }
																 kFixedSize);			{ vertical page size is fixed }
	aPrintHandler.fMinimalMargins := FALSE;

	SetColumnWidths;										{ get existing document's column widths }

	IF forPrinting THEN									{ Finder printing }
		aPrintHandler.RedoPageBreaks
	ELSE BEGIN

		fEditRow := 1;										{ default cell to edit is A1 }
		fEditColumn := 1;
		SetEntry(fEditRow, fEditColumn);
		fSelectionType := CellSelection;
		aCell.h := 1;
		aCell.v := 1;
		fCellsView.SelectCell(aCell, kDontExtend, kDontHighlight, kSelect);
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.GetInUseBounds(VAR bounds: Rect);
BEGIN
	bounds := fInUseBounds;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

{�Tries to reduce as much as possible the size of the InUseBounds. In order to
	do this, we may delete empty cells. We do not delete deleted cells, because
	they may be needed later by an undo command. So, to get maximum benefit
	from this procedure, it should be called after 
	gApplication.CommitLastCommand. }
	
PROCEDURE TTable.CompressInUseBounds;
VAR currentBounds:	Rect;
		columnCleared:	BOOLEAN;
		rowCleared:			BOOLEAN;
		
	FUNCTION ClearARow: BOOLEAN;
	VAR c: INTEGER;
			aCell: TCell;
	BEGIN
		WITH currentBounds DO BEGIN
			IF top = bottom THEN BEGIN
				ClearARow := FALSE;
				Exit(ClearARow);
			END;

			FOR c := 1 TO right DO BEGIN
				aCell := GetExistingCell(bottom, c);
				IF aCell <> NIL THEN BEGIN
					IF aCell.fKind = EmptyCell THEN BEGIN
						fAllocatedCells := fAllocatedCells - 1;
						aCell.Free;
						fCells.SetElement(bottom, c, NIL);
					END
					ELSE BEGIN
						ClearARow := FALSE;
						Exit(ClearARow);
					END;
				END;	{�aCell <> NIL }
			END;	{�for }
			
			{�Since we are here, we succeded in clearing a row }
			bottom := bottom - 1;
			ClearARow := TRUE;
		END;	{�with }
	END;		{�ClearARow }
	
	FUNCTION ClearAColumn: BOOLEAN;
	VAR r: INTEGER;
			aCell: TCell;
	BEGIN
		WITH currentBounds DO BEGIN
			IF right = left THEN BEGIN
				ClearAColumn := FALSE;
				Exit(ClearAColumn);
			END;

			FOR r := 1 TO bottom DO BEGIN
				aCell := GetExistingCell(r, right);
				IF aCell <> NIL THEN BEGIN
					IF aCell.fKind = EmptyCell THEN BEGIN
						fAllocatedCells := fAllocatedCells - 1;
						aCell.Free;
						fCells.SetElement(r, right, NIL);
					END
					ELSE BEGIN
						ClearAColumn := FALSE;
						Exit(ClearAColumn);
					END;
				END;	{�aCell <> NIL }
			END;	{�for }
			
			{�Since we are here, we succeded in clearing a row }
			right := right - 1;
			ClearAColumn := TRUE;
		END;	{�with }
	END;		{�ClearAColumn }
	
BEGIN
	
	IF fEntryView.fTEditing THEN
		EditCell;
		
	currentBounds := fInUseBounds;
	ConfirmEntry;
	
	{$IFC qDebug}
	WITH currentBounds DO
		Writeln('CompressInUseBounds: old bounds are (ltrb):',
							left, top, right, bottom);
	{$ENDC}
	
	{�Reduce the current bounds until no more changes are possible }
	REPEAT
		rowCleared := ClearARow;
		columnCleared := ClearAColumn;
	UNTIL (NOT rowCleared) AND (NOT columnCleared);

	{$IFC qDebug}
	WITH currentBounds DO
		Writeln('CompressInUseBounds: new bounds are (ltrb):',
							left, top, right, bottom);
	{$ENDC}
	fInUseBounds := currentBounds;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TTable.GetValue(r, c: INTEGER): EXTENDED;
BEGIN
	{$IFC qDebug}
	{
	Writeln('TTable.GetValue: r=', r,' c=', c,' fRowOffset=', fRowOffset,
					' fColumnOffset=', fColumnOffset, ' value =', 
					GetCell((r - fRowOffset), (c - fColumnOffset)).fValue, 
					' kind: ', ORD(GetCell((r - fRowOffset), (c - fColumnOffset)).fKind));
	}
	{$ENDC}

	GetValue := GetCell((r - fRowOffset), (c - fColumnOffset)).fValue
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.ColumnToArray(c: INTEGER; p: PExtended);
VAR row:			INTEGER;
		lastRow:	INTEGER;
		value:		EXTENDED;
BEGIN
	lastRow := fInUseBounds.bottom;
	FOR row := fInUseBounds.top TO lastRow DO BEGIN
		value := GetCell(row, (c - fColumnOffset)).fValue;
		SetIthElement(p, row - 1, value);
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.ArrayToColumn(c: INTEGER; p: PExtended; len: INTEGER);
VAR row:			INTEGER;
		aCell:		TCell;
		aStr:			Str255;
		value:		EXTENDED;
BEGIN
	FOR row := 1 TO len DO BEGIN
	
		GetIthElement(p, row - 1, value);
		
		IF ClassExtended(value) = QNan THEN BEGIN
			{�Set the value to missing only if the cell exists already;
				??? could we delete it here? }
			aCell := GetExistingCell(row, c - fColumnOffset);
			IF aCell <> NIL THEN BEGIN
				aCell.fFormula := '';
				aCell.fValue := gMissing;
				aCell.fValueString := '';
				aCell.fKind := emptyCell;
				aCell.Invalidate;
			END;
		END
		ELSE BEGIN
		
			{�Get a reference to the cell }
			aCell := GetCell(row, (c - fColumnOffset));

			{�Convert the binary to decimal }
			Num2NiceStr(value, aStr, kValuePrecision);
			
			{ Stuff both the binary and decimal values in it }
			aCell.fValue := value;
			aCell.fValueString := '';
			aCell.fFormula := aStr;
			aCell.fKind := valueCell;
			aCell.Invalidate;
		END;
	END;		{�For }
END;			{�ArrayToColumn }

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TTable.GetMinOfCol(c: INTEGER; onlyPositives: BOOLEAN): EXTENDED;
VAR i:				INTEGER;
		minimum:	EXTENDED;
		tmp:			EXTENDED;
BEGIN
	{$IFC qDebug}
	IF (c < fDimensions.left) OR (c > fDimensions.right) THEN BEGIN
		Writeln('c = ', c);
		ProgramBreak('GetMinOfCol: c is out of bounds!');
	END;
	{$ENDC}
	
	minimum := Inf;
	FOR i := fInUseBounds.top TO fInUseBounds.bottom DO BEGIN
		tmp := GetValue(i, c);
		IF onlyPositives & (tmp <= 0.0) THEN 
			Cycle;
		IF tmp < minimum THEN 
			minimum := tmp;
	END;
	IF minimum = Inf THEN
		GetMinOfCol := gMissing
	ELSE
		GetMinOfCol := minimum;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TTable.GetMaxOfCol(c: INTEGER; onlyPositives: BOOLEAN): EXTENDED;
VAR i:				INTEGER;
		maximum:	EXTENDED;
		tmp:			EXTENDED;
BEGIN
	{$IFC qDebug}
	IF (c < fDimensions.left) OR (c > fDimensions.right) THEN BEGIN
		Writeln('c = ', c);
		ProgramBreak('GetMaxOfCol: c is out of bounds!');
	END;
	{$ENDC}
	
	maximum := -Inf;
	FOR i := fInUseBounds.top TO fInUseBounds.bottom DO BEGIN
		tmp := GetValue(i, c);
		IF onlyPositives & (tmp <= 0.0) THEN 
			Cycle;
		IF tmp > maximum THEN 
			maximum := tmp;
	END;
	IF maximum = -Inf THEN
		GetMaxOfCol := gMissing
	ELSE
		GetMaxOfCol := maximum;
END;

{--------------------------------------------------------------------------------------------------}
{$S CallFit}

PROCEDURE TTable.ConfirmEntry;
{ Enters in the table the contents of the entry view, just like when pressing
	"Enter" key. }
BEGIN
	IF fEntryView.fTEditing THEN
		EditCell;
END;

{--------------------------------------------------------------------------------------------------}
{$S CallFit}

{ Returns TRUE if any of the cell is an error cell; selects and shows the
	cell responsible for the error }
	
FUNCTION TTable.DataCheck: BOOLEAN;
VAR noErrors: 		BOOLEAN;
		aRect:				Rect;
		bigRect:			VRect;
		badCell:			GridCell;
		aCell:				GridCell;
		minToSee:			Point;
		
	PROCEDURE CheckACell(aCell: GridCell);
	BEGIN
		IF GetExistingCell(aCell.v, aCell.h).fKind = errorCell THEN BEGIN
			noErrors := FALSE;
			badCell := aCell;
		END;
	END;
	
BEGIN
	noErrors := TRUE;
	aRect := fInUseBounds;
	EachExistingCellDo(aRect, CheckACell);
	
	IF NOT noErrors THEN BEGIN
		fEntryView.EditMode(FALSE);
		fColumnsView.SetEmptySelection(kHighlight);
		fRowsView.SetEmptySelection(kHighlight);
		fColumnIsSelected := FALSE;
	
		fCellsView.SelectCell(badCell, kDontExtend, kHighlight, kSelect);
		fCellsView.ScrollSelectionIntoView(TRUE);
		
		{ fix the columns view }
		minToSee.h := fColumnsView.GetColWidth(badCell.h);
		minToSee.v := kCellHeight;
		aCell.v := 1;
		aCell.h := badCell.h;
		fColumnsView.CellToVRect(aCell, bigRect);
		fColumnsView.RevealRect(bigRect, minToSee, TRUE);
	
		{ fix the rows view }
		minToSee.h := kCellWidth;
		minToSee.v := kCellHeight;
		aCell.v := badCell.v;
		aCell.h := 1;
		fRowsView.CellToVRect(aCell, bigRect);
		fRowsView.RevealRect(bigRect, minToSee, TRUE);
		
		{�Pull the window to front }
		fTableWindow.Show(TRUE, FALSE);
		fTableWindow.Select;
	END;
	
	DataCheck := NOT noErrors;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.SetReadOnly(readOnly: BOOLEAN);
BEGIN
	fReadOnly := readOnly;
	fCellsView.fReadOnly := readOnly;
	fEntryView.fAcceptsChanges := NOT readOnly;
END;

{--------------------------------------------------------------------------------------------------}
{$S AWriteFile}

{�The expression is broken in several parts, because the partial
	expression are of INTEGER type, that's too small in some cases. This way
	we avoid TRAPV system errors. }

PROCEDURE TTable.DoNeedDiskSpace(VAR dataForkBytes, rsrcForkBytes: LONGINT);
BEGIN
	dataForkBytes :=	dataForkBytes + SIZEOF(TableDocDiskInfo);
	dataForkBytes :=	dataForkBytes + ORD4(SIZEOF(RowDiskInfo)) * fAllocatedRows;
	dataForkBytes :=	dataForkBytes + ORD4(SIZEOF(ColumnDiskInfo)) * fAllocatedColumns;
	dataForkBytes :=	dataForkBytes + ORD4(SIZEOF(cellDiskInfo) + SIZEOF(point))
																			* fAllocatedCells;
END;

{--------------------------------------------------------------------------------------------------}
{$S AReadFile}

PROCEDURE TTable.DoRead(aRefNum: INTEGER; rsrcExists, forPrinting: BOOLEAN);
VAR i:					INTEGER;
		noOfCells:			INTEGER;
		noOfRows:			INTEGER;
		noOfColumns:		INTEGER;
		r:					RowNumber;
		c:					ColumnNumber;
		aCell:				TCell;
		aRow:				TRow;
		aColumn:			TColumn;
		fi: 				FailInfo;

	PROCEDURE ReadDocInfo;
	VAR theDocInfo: 		TableDocDiskInfo;
	BEGIN
		ReadBytes(aRefNum, SIZEOF(theDocInfo), @theDocInfo);

		WITH theDocInfo DO BEGIN
			fDimensions := dimensions;
			noOfRows := allocatedRows;
			noOfColumns := allocatedColumns;
			fAllocatedCells := allocatedCells;
			fSelectionType := NoSelection;
			fEditRow := editRow;
			fEditColumn := editColumn;
		END;

		WITH fDimensions DO BEGIN
			fNoOfRows := bottom - top + 1;
			fNoOfColumns := right - left + 1;
		END;

		{ Save the number of cells to be read, then set fAllocatedCells to
			zero.  As each cell is read fAllocatedCells is incremented.
			When we've finished, noOfCells must equal fAllocatedCells. }
		noOfCells := fAllocatedCells;
		DoInitialState; 								{ clear allocation counts }
		
		{$IFC qDebug}
		{
		Writeln('TTable.DoRead, ReadDocInfo: read this information:');
		WITH theDocInfo DO BEGIN
			WITH dimensions DO
				Writeln(' - dimensions (ltrb):', left, top, right, bottom);
			Writeln(' - allocatedCells:', allocatedCells);
			Writeln(' - allocatedRows:', allocatedRows);
			Writeln(' - allocatedColumns:', allocatedColumns);
			Writeln(' - selectionType:', ORD(selectionType));
			Writeln(' - editRow:', editRow);
			Writeln(' - editColumn:', editColumn);
		END;
		}
		{$ENDC}
	END;

	PROCEDURE HdlReadFailure(error: OSErr; message: LONGINT);
	BEGIN
		{ Oh Boy are we in trouble }
		{ Need to set back rows and columns to reflect the number read in so
			the freedata routine (which will eventually be called by other
			failure handlers on the stack) won't try to free unallocated objects}
		IF c = 0 THEN BEGIN
			{ We died while reading the rows in}
			fNoOfRows := r - 1;
			fNoOfColumns := 0;
		END
		ELSE IF i = 0 THEN BEGIN
			{ Died in the columns }
			fNoOfColumns := c - 1;
			END;
		END;

BEGIN
	CatchFailures(fi, HdlReadFailure);
	
	ReadDocInfo;													{ Get info about the document }
	r := 0; c := 0; i := 0; 							{ Initialized so failure handler knows
																				  where we died }

	FOR i := 1 TO noOfRows DO BEGIN				{ Get info about each row }
		
		{$IFC qDebug}
		{�Writeln('TTable.DoRead: about to read a row:'); }
		{$ENDC}
		
		ReadBytes(aRefNum, SIZEOF(r), @r);
		aRow := GetRow(r);
		aRow.ReadFromDisk(aRefNum);
		
		{$IFC qDebug}
		{�Writeln('TTable.DoRead: read a row:', r); }
		{$ENDC}
	END;

	FOR i := 1 TO noOfColumns DO BEGIN				{ Get info about each column }
		
		{$IFC qDebug}
		{�Writeln('TTable.DoRead: about to read a col:'); }
		{$ENDC}

		ReadBytes(aRefNum, SIZEOF(c), @c);
		aColumn := GetColumn(c);
		aColumn.ReadFromDisk(aRefNum);
		
		{$IFC qDebug}
		{�Writeln('TTable.DoRead: read a col:', c); }
		{$ENDC}
	END;

	FOR i := 1 TO noOfCells DO BEGIN					{ Read in the cells }
		
		{$IFC qDebug}
		{�Writeln('TTable.DoRead: about to read a cell:'); }
		{$ENDC}
		
		ReadCellCoordinate(aRefNum, r, c);

		{$IFC qDebug}
		{�Writeln('TTable.DoRead: read cell coord:', r, c); }
		{$ENDC}

		aCell := GetCell(r, c);
		aCell.ReadFromDisk(aRefNum);

		{$IFC qDebug}
		{ Writeln('TTable.DoRead: read a cell:', r, c);
			Writeln; }
		{$ENDC}
	END;

	{$IFC qDebug}
	IF noOfCells <> fAllocatedCells THEN BEGIN
		WRITELN('TTable.DoRead: Wrong number of cells.  noOfCells=', noOfCells,
				', fAllocatedCells=', fAllocatedCells);
		ProgramBreak('');
	END;
	{$ENDC}

	Success(fi);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TTable.DoRecalculate;
VAR r:					Rect;

	PROCEDURE RecalcCell(aCell: GridCell);
	BEGIN
		GetCell(aCell.v, aCell.h).Recalculate;
	END;

BEGIN
	r := fInUseBounds;
	EachExistingCellDo(r, RecalcCell);
END;

{--------------------------------------------------------------------------------------------------}
{$S AWriteFile}

PROCEDURE TTable.DoWrite(aRefNum: INTEGER; makingCopy: BOOLEAN);

	VAR
		cellsWritten:		INTEGER;
		r:					Rect;

{--------------------------------------------------------------------------------------------------}
	PROCEDURE WriteDocInfo;

		VAR
			theDocInfo: 		TableDocDiskInfo;

		BEGIN
		WITH theDocInfo DO
			BEGIN
			dimensions := fDimensions;
			allocatedRows := fAllocatedRows;
			allocatedColumns := fAllocatedColumns;
			allocatedCells := fAllocatedCells;
			selectionType := NoSelection;
			editRow := fEditRow;
			editColumn := fEditColumn;
			END;
		WriteBytes(aRefNum, SIZEOF(theDocInfo), @theDocInfo);
		END;

{--------------------------------------------------------------------------------------------------}
	PROCEDURE WriteRow(aCell: GridCell);

		BEGIN
		GetRow(aCell.v).WriteToDisk(aRefNum);
		END;

{--------------------------------------------------------------------------------------------------}
	PROCEDURE WriteColumn(aCell: GridCell);

		VAR
			theColumn:			TColumn;

		BEGIN
		theColumn := GetColumn(aCell.h);
		theColumn.fWidth := fColumnsView.GetColWidth(aCell.h);
		theColumn.WriteToDisk(aRefNum);
		END;


{--------------------------------------------------------------------------------------------------}
	PROCEDURE WriteCell(aCell: GridCell);

		VAR
			theCell:			TCell;

		BEGIN
		theCell := GetExistingCell(aCell.v, aCell.h);
		IF theCell <> NIL THEN
			BEGIN
			theCell.WriteToDisk(aRefNum);
			cellsWritten := cellsWritten + 1;
			END;
		END;

	BEGIN
	WriteDocInfo;														{ Write info about the document }

	EachExistingRowDo(WriteRow);						{ Write info about each row }
	EachExistingColumnDo(WriteColumn);			{ Write info about each column }

	cellsWritten := 0;
	r := fInUseBounds;
	EachExistingCellDo(r, WriteCell);				{ Write out the cells }

	{$IFC qDebug}
	IF cellsWritten <> fAllocatedCells THEN
		ProgramBreak('DoWrite: Incorrect number of cells written');
	{$ENDC}
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.EachExistingRowDo(PROCEDURE
										  DoToCell(aCell: GridCell));
{ Perform DoToCell for each ALLOCATED Row }

	VAR
		r:					RowNumber;
		aCell:				GridCell;
		aRect:				Rect;

	BEGIN
	aRect := fInUseBounds;
	WITH aRect DO
		BEGIN
		FOR r := top TO bottom DO
			BEGIN
			IF RowExists(r) THEN
				BEGIN
				aCell.h := 1;
				aCell.v := r;
				DoToCell(aCell);
				END;
			END;
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.EachExistingColumnDo(PROCEDURE
											 DoToCell(aCell: GridCell));
{ Perform DoToCell for each ALLOCATED Column }

	VAR
		c:					ColumnNumber;
		aCell:				GridCell;
		aRect:				Rect;

	BEGIN
	aRect := fInUseBounds;
	WITH aRect DO
		BEGIN
		FOR c := left TO right DO
			BEGIN
			IF ColumnExists(c) THEN
				BEGIN
				aCell.h := c;
				aCell.v := 1;
				DoToCell(aCell);
				END;
			END;
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.EachExistingCellDo(cellRange: Rect; PROCEDURE
										   DoToCell(aCell: GridCell));
{ Perform DoToCell for each ALLOCATED cell within a range of cells. }

	VAR
		r:					RowNumber;
		c:					ColumnNumber;
		aCell:				GridCell;

	BEGIN
	ConstrainToUsedCells(cellRange);
	WITH cellRange DO
		BEGIN
		FOR r := top TO bottom DO
			BEGIN
			FOR c := left TO right DO
				BEGIN
				IF CellExists(r, c) THEN
					BEGIN
					aCell.h := c;
					aCell.v := r;
					DoToCell(aCell);
					END;
				END;
			END;
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TTable.EditCell;
{ Change the formula of the cell being edited to the string in the entry view }

VAR theString:				FormulaString;

BEGIN
	fEntryView.GetAsString(theString);
	IF fEditCell = NIL THEN
		fEditCell := GetCell(fEditRow, fEditColumn);
	fEditCell.SetToString(theString);
END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TTable.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
												   fieldType: INTEGER)); OVERRIDE;

	VAR
		aString:			Str255;

	BEGIN
	DoToField('TTable', NIL, bClass);
	DoToField('fDocument', @fDocument, bObject);
	DoToField('fTemplate', @fTemplate, bInteger);
	DoToField('fReadOnly', @fReadOnly, bBoolean);
	{$Push}{$H-}	{ Because FormatFields is in a debugging (i.e. resident) segment) }
	FormatFields('fFormat', fFormat, DoToField);
	{$Pop}
	DoToFIeld('fCells', @fCells, bObject);
	DoToField('fEditCell', @fEditCell, bObject);
	DoToField('fRows', @fRows, bObject);
	DoToField('fRowOffset', @fRowOffset, bInteger);
	DoToField('fColumns', @fColumns, bObject);
	DoToField('fColumnOffset', @fColumnOffset, bInteger);
	DoToField('fColumnIsSelected', @fColumnIsSelected, bBoolean);
	DoToField('fTableWindow', @fTableWindow, bObject);
	DoToField('fCellsView', @fCellsView, bObject);
	DoToField('fRowsView', @fRowsView, bObject);
	DoToField('fColumnsView', @fColumnsView, bObject);
	DoToField('fEntryView', @fEntryView, bObject);
	{�DoToField('fCoordView', @fCoordView, bObject); }
	DoToField('fDimensions', @fDimensions, bRect);
	DoToField('fInUseBounds', @fInUseBounds, bRect);
	DoToField('fAllocatedRows', @fAllocatedRows, bInteger);
	DoToField('fAllocatedColumns', @fAllocatedColumns, bInteger);
	DoToField('fAllocatedCells', @fAllocatedCells, bInteger);
	CASE fSelectionType OF
		NoSelection:		aString := 'NoSelection';
		CellSelection:		aString := 'CellSelection';
		RowSelection:		aString := 'RowSelection';
		ColumnSelection:	aString := 'ColumnSelection';
		AllSelection:		aString := 'AllSelection';
		END;
	DoToField('fSelectionType', @aString, bString);
	DoToField('fEditRow', @fEditRow, bByte);
	DoToField('fEditColumn', @fEditColumn, bByte);
	DoToField('fNoOfRows', @fNoOfRows, bInteger);
	DoToField('fNoOfColumns', @fNoOfColumns, bInteger);
	INHERITED Fields(DoToField);
	END;


{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TTable.GetInspectorName(VAR inspectorName: Str255); OVERRIDE;
BEGIN
	inspectorName := fName;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.FreeCell(theCell: TCell);

	BEGIN
	{$IFC qDebug}
	IF fCells.GetElement(theCell.fRow, theCell.fColumn) <> theCell THEN
		ProgramBreak('TTable.FreeCell: Cell table inconsistent');
	{$ENDC}

	fCells.SetElement(theCell.fRow, theCell.fColumn, NIL);
	theCell.Free;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.FreeData;
VAR
		r:					RowNumber;
		c:					ColumnNumber;
		oldState:		Boolean;
		
BEGIN
	IF fEntryView <> NIL THEN BEGIN
		IF fEntryView.fTEditing THEN
			EditCell;
		fEntryView.SetToString('');
	END;
	
	oldState := Lock(TRUE);								{ HLock(Handle(SELF)) }
	WITH fInUseBounds DO
		IF fCells <> NIL THEN
			FOR r := top TO bottom DO
				FOR c := left TO right DO
				{$Push}{$H-}
					IF fCells.GetElement(r, c) <> NIL THEN
						FreeCell(TCell(fCells.GetElement(r, c)));
				{$Pop}
				
	IF fRows <> NIL THEN
		FOR r := 1 TO fNoOfRows DO BEGIN
			FreeIfObject(fRows.GetElement(r));
			fRows.SetElement(r, NIL);
		END;

	IF fRows <> NIL THEN
		FOR c := 1 TO fNoOfColumns DO BEGIN
			FreeIfObject(fColumns.GetElement(c));
			fColumns.SetElement(c, NIL);
		END;
		
	IF Lock(oldState) THEN ;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

{ Free each deleted cell. }

PROCEDURE TTable.FreeDeletedCells;
VAR r:					RowNumber;
		c:					ColumnNumber;
		theCell:			TCell;
		cellRange:			Rect;
BEGIN
	cellRange := fInUseBounds;
	WITH cellRange DO
		FOR r := top TO bottom DO
			FOR c := left TO right DO BEGIN
				theCell := TCell(fCells.GetElement(r, c));
				IF (theCell <> NIL) & theCell.fDeleted THEN
					FreeCell(theCell);
				END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TTable.GetCell(r: RowNumber; c: ColumnNumber): TCell;
 { Return the cell object for the given coordinates.  If a cell object
   doesn't already exist, create one. }

VAR theCell:			TCell;

BEGIN
	IF NOT CellExists(r, c) THEN
		BEGIN
		NEW(theCell);
		FailNIL(theCell);
		theCell.ICell(SELF, r, c);
		END
	ELSE
		BEGIN
		theCell := TCell(fCells.GetElement(r, c));
		END;

	GetCell := theCell;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TTable.GetColumn(c: ColumnNumber): TColumn;

	VAR
		theColumn:			TColumn;

	BEGIN
	IF NOT ColumnExists(c) THEN
		BEGIN
		NEW(theColumn);
		FailNIL(theColumn);
		theColumn.IColumn(c);
		AddColumn(theColumn);
		END
	ELSE
		BEGIN
		theColumn := TColumn(fColumns.GetElement(c));
		END;
	GetColumn := theColumn;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TTable.GetExistingCell(r: RowNumber; c: ColumnNumber): TCell;
 { Like GetCell, only return NIL if the cell object doesn't exist }

	BEGIN
	IF CellExists(r, c) THEN
		GetExistingCell := TCell(fCells.GetElement(r, c))
	ELSE
		GetExistingCell := NIL;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TTable.GetRow(r: RowNumber): TRow;

	VAR
		theRow: 			TRow;

	BEGIN
	IF NOT RowExists(r) THEN
		BEGIN
		NEW(theRow);
		FailNIL(theRow);
		theRow.IRow(r);
		AddRow(theRow);
		END
	ELSE
		BEGIN
		theRow := TRow(fRows.GetElement(r));
		END;
	GetRow := theRow;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

FUNCTION TTable.RowExists(r: RowNumber): BOOLEAN;

	BEGIN
	RowExists := FALSE;

	IF (r > 0) & (fRows.GetElement(r) <> NIL) THEN
		RowExists := TRUE;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TTable.SetEntry(r: RowNumber; c: ColumnNumber);
{ Set the string in TEntryView to the formula in the cell }

	VAR
		theString:			FormulaString;

	BEGIN
	IF CellExists(r, c) THEN
		BEGIN
		TCell(fCells.GetElement(r, c)).GetAsString(theString);
		fEntryView.SetToString(theString);
		END
	ELSE
		fEntryView.SetToString('');
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TTable.UndeleteCell(r: RowNumber; c: ColumnNumber);
VAR aCell : TCell;
BEGIN
aCell := TCell(fCells.GetElement(r, c));
IF aCell <> NIL THEN
	BEGIN
	aCell.SetDeleteState(FALSE);
	fAllocatedCells := fAllocatedCells + 1;		{�It was 'minus' in the Calc example !!! }
	END;
END;

{***************************************************************************************************
	T T a b l e W i n d o w
***************************************************************************************************}

{***************************************************************************************************
	T C e l l s V i e w
***************************************************************************************************}
{$S AOpen}

PROCEDURE TCellsView.ICellsView(itsTable: TTable;
																forClipboard: BOOLEAN; itsParent: TView);
	VAR
		aLocation:			VPoint;
		{$IFC MacApp20Def}
		ignoredSize:		VPoint;
		{$ENDC}

BEGIN
	fTable := itsTable;
	fReadOnly := itsTable.fReadOnly;
	aLocation.h := 0;
	aLocation.v := 0;
	ITextGridView(itsTable.fDocument,
								itsParent,
								aLocation,
								{$IFC MacApp20Def}
								ignoredSize,	{�it's ignored since size determiners are sizeVariable }
								{$ENDC}
								sizeVariable, 
								sizeVariable,
								itsTable.fNoOfRows, 
				 			  itsTable.fNoOfColumns, 0, kCellWidth, TRUE, TRUE, 0, 0, FALSE, 
								gSystemStyle);
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCellsView.AdornRow(aRow: INTEGER; area: Rect); OVERRIDE;

	BEGIN
	PenPat(pRowSeparatorPattern);
	PenSize(1, 1);

	MoveTo(area.left, area.bottom);
	LineTo(area.right - 1, area.bottom);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCellsView.AdornCol(aCol: INTEGER; area: Rect); OVERRIDE;

	BEGIN
	PenPat(pColumnSeparatorPattern);
	PenSize(1, 1);

	MoveTo(area.right, area.top);
	LineTo(area.right, area.bottom - 1);

	IF aCol > 1 THEN
		BEGIN
		MoveTo(area.left, area.top);
		LineTo(area.left, area.bottom - 1);
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

FUNCTION TCellsView.ContainsClipType(aType: ResType): BOOLEAN;
VAR offset: 			LONGINT;
BEGIN
	ContainsClipType := aType = kTableScrapType;
END;

{--------------------------------------------------------------------------------------------------}
{$S ASelCommand}

 { This view only handles arrow keys, tab, return and enter.  It assumes
   the other keys are handled by the entry view object.
	 This view also filters out unwanted characters, like alfanumeric ones. }
 { 13/9/90: Modified this method to handle chBackspace, chClear and chFwdDelete too. }
 
FUNCTION TCellsView.DoKeyCommand(ch: CHAR; aKeyCode: INTEGER; VAR info: EventInfo): TCommand;
CONST
	kNotAll = FALSE;
	kAll		= TRUE;
VAR
	r:										RowNumber;
	c:										ColumnNumber;
	aCellEditCommand: 		TCellEditCommand;
	originalEditColumn:		ColumnNumber;


	PROCEDURE HandleCellSelectionKeystroke;
	VAR aCell:				GridCell;
			minToSee:			Point;
			aRect:				VRect;
	BEGIN
		aCell.h := c;
		aCell.v := r;

		WITH fTable DO BEGIN
			IF fEntryView.fTEditing THEN
				ChangedColumn(kNotAll, originalEditColumn);

			fEntryView.EditMode(FALSE);
			fColumnsView.SetEmptySelection(kHighlight);
			fRowsView.SetEmptySelection(kHighlight);
			fColumnIsSelected := FALSE;
	
			SelectCell(aCell, kDontExtend, kHighlight, kSelect);
			ScrollSelectionIntoView(TRUE);
	
			{ fix the columns view }
			minToSee.h := fColumnsView.GetColWidth(aCell.h);
			minToSee.v := kCellHeight;
			aCell.v := 1;
			fColumnsView.CellToVRect(aCell, aRect);
			fColumnsView.RevealRect(aRect, minToSee, TRUE);
	
			{ fix the rows view }
			minToSee.h := kCellWidth;
			minToSee.v := kCellHeight;
			aCell.v := r;
			aCell.h := 1;
			fRowsView.CellToVRect(aCell, aRect);
			fRowsView.RevealRect(aRect, minToSee, TRUE);
		END;
		
		{�14/11/90: added these lines to make scrolling work
			properly while the user is scrolling with the cursor keys.
			Too bad that they slow down typing, that's slow already on slow Macs.}
		IF ch <> chEnter THEN BEGIN
			Update;
			IF ch IN [chTab,chRight] THEN
				fTable.fColumnsView.Update
			ELSE
				fTable.fRowsView.Update;
		END;
	END;				{�HandleCellSelectionKeystroke }
	
BEGIN
	DoKeyCommand := gNoChanges;
	
	c := fTable.fEditColumn;
	r := fTable.fEditRow;
	originalEditColumn := c;
	
	{ We want to make life easier to italian scientists ! }
	IF ch = ',' THEN
		ch := '.';
	
	CASE ch OF

		chEnter:
			BEGIN						{ Stay on same cell }
				HandleCellSelectionKeystroke;
			END;
			
		chTab, chRight:
			BEGIN
				c := Min(c + 1, fTable.fNoOfColumns);
				HandleCellSelectionKeystroke;
			END;

		chLeft:
			BEGIN
				c := Max(c - 1, 1);
				HandleCellSelectionKeystroke;
			END;

		chUp:
			BEGIN
				r := Max(r - 1, 1);
				HandleCellSelectionKeystroke;
			END;

		chReturn, chDown:
			BEGIN
				r := Min(r + 1, fTable.fNoOfRows);
				HandleCellSelectionKeystroke;
			END;

		chBackspace, chFwdDelete:
			IF fTable.fEntryView.fTEditing THEN BEGIN
				DoKeyCommand := INHERITED DoKeyCommand(ch, aKeyCode, info);
				fTable.fEditCell := fTable.GetCell(r, c);
			END
			ELSE IF gWorking THEN
				RemindUserWeAreWorking
			ELSE IF NOT fTable.fReadOnly THEN BEGIN
				{ do same as if user had hit the "clear" menu item }
				NEW(aCellEditCommand);
				FailNIL(aCellEditCommand);
				aCellEditCommand.ICellEditCommand(fTable, cClear);
				DoKeyCommand := aCellEditCommand;
				fTable.ChangedColumn(kAll, -1);
			END;

		chClear:
			IF gWorking THEN
				RemindUserWeAreWorking
			ELSE IF NOT fTable.fReadOnly THEN BEGIN
				fTable.fEntryView.EditMode(FALSE);
				NEW(aCellEditCommand);
				FailNIL(aCellEditCommand);
				aCellEditCommand.ICellEditCommand(fTable, cClear);
				DoKeyCommand := aCellEditCommand;
				fTable.ChangedColumn(kAll, -1);
			END;

		OTHERWISE
			BEGIN
				IF MustIgnoreChar(ch) THEN
					EXIT(DoKeyCommand);
				DoKeyCommand := INHERITED DoKeyCommand(ch, aKeyCode, info);
				fTable.fEditCell := fTable.GetCell(r, c);
			END;
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ASelCommand}

FUNCTION TCellsView.DoMenuCommand(aCmdNumber: cmdNumber): TCommand; OVERRIDE;
VAR aCellEditCommand:		TCellEditCommand;
		aCellPasteCommand:	TCellPasteCommand;
		cellsToSelect:			RgnHandle;
		aRect:							Rect;

	FUNCTION TextContainsMoreThanOneItem(h: Handle): LONGINT; C; EXTERNAL;

	FUNCTION DeskScrapViewContainsATable: BOOLEAN;
	BEGIN
		TDeskScrapView(gClipView).CheckScrapContents;
		
		DeskScrapViewContainsATable := 
			TDeskScrapView(gClipView).fHaveText &
			(TextContainsMoreThanOneItem(TDeskScrapView(gClipView).fDataHandle) <> 0);
	END;
	
BEGIN
	CASE aCmdNumber OF
		cSelectAll:
			BEGIN
			aRect := fTable.fInUseBounds;
			WITH aRect DO
				BEGIN
				right := right + 1;
				bottom := bottom + 1;
				END;
			cellsToSelect := MakeNewRgn;
			RectRgn(cellsToSelect, aRect);
			SetSelection(cellsToSelect, kDontExtend, kHighlight, kSelect);
			DisposeRgn(cellsToSelect);
			WITH fTable DO
				BEGIN
				fSelectionType := AllSelection;
				fRowsView.SetEmptySelection(kHighlight);
				fColumnsView.SetEmptySelection(kHighlight);
				fColumnIsSelected := FALSE;
				END;
			DoMenuCommand := gNoChanges;
			END;

		cCut, cCopy, cClear:
			IF NOT fTable.fEntryView.fTEditing THEN BEGIN
				NEW(aCellEditCommand);
				FailNIL(aCellEditCommand);
				aCellEditCommand.ICellEditCommand(fTable, aCmdNumber);
				DoMenuCommand := aCellEditCommand;
			END
			ELSE BEGIN									{ get ready for TextEdit operation }
				WITH fTable DO
					fEditCell := GetCell(fEditRow, fEditColumn);
				DoMenuCommand := INHERITED DoMenuCommand(aCmdNumber);
			END;

		cPaste:
			IF	gClipView.ContainsClipType(kTableScrapType)
					| (Member(gClipView, TDeskScrapView)
							& DeskScrapViewContainsATable)
					| (Member(gClipView, TTEView)
							& (TextContainsMoreThanOneItem(TTEView(gClipView).ExtractText) <> 0))
			THEN BEGIN
				NEW(aCellPasteCommand);
				FailNIL(aCellPasteCommand);
				aCellPasteCommand.ICellPasteCommand(fTable);
				DoMenuCommand := aCellPasteCommand;
			END
			ELSE BEGIN									{ paste text into entry view }
				WITH fTable DO BEGIN
					fEditCell := GetCell(fEditRow, fEditColumn);
					IF NOT fEntryView.fTEditing THEN
						fEntryView.SetEditMode;			{ prepare view for paste of text }
				END;
				DoMenuCommand := INHERITED DoMenuCommand(aCmdNumber);
			END;
		
		OTHERWISE
			DoMenuCommand := INHERITED DoMenuCommand(aCmdNumber);
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ASelCommand}

FUNCTION TCellsView.DoMouseCommand(VAR theMouse: Point; VAR info: EventInfo;
								   VAR hysteresis: Point): TCommand; OVERRIDE;

	VAR
		aCellSelector:		TTableSelectCommand;
		aColumnSizer:		TColumnSizer;
		aCell:				GridCell;
		whichPart:			GridViewPart;
		aRow:				INTEGER;
		aCol:				INTEGER;
		aGrabber:			TGrabberTracker;

	BEGIN
	DoMouseCommand := gNoChanges;
	whichPart := IdentifyPoint(theMouse, aRow, aCol);
	aCell.h := aCol;
	aCell.v := aRow;

	IF info.theOptionKey THEN
		BEGIN
		NEW(aGrabber);
		FailNIL(aGrabber);
		aGrabber.IGrabberTracker(0, fTable.fDocument, self, GetScroller(FALSE));
		DoMouseCommand := aGrabber;
		END
	ELSE
		BEGIN
		CASE whichPart OF
			inCell:
				BEGIN
				NEW(aCellSelector);
				FailNIL(aCellSelector);
				aCellSelector.ITableSelectCommand(fTable, SELF, info.theShiftKey, info.theCmdKey);
				DoMouseCommand := aCellSelector;
				fTable.fSelectionType := CellSelection;
				END;
	
			inColumn:
				BEGIN
				IF aCol > 1 THEN
					BEGIN
					NEW(aColumnSizer);
					FailNIL(aColumnSizer);
					aColumnSizer.IColumnSizer(fTable, aCol - 1);
					DoMouseCommand := aColumnSizer;
					END;
				END;
	
			OTHERWISE;
		END;
		fTable.fColumnsView.SetEmptySelection(kHighlight);
		fTable.fRowsView.SetEmptySelection(kHighlight);
		fTable.fColumnIsSelected := FALSE;
		fTable.fEditCell := NIL;
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TCellsView.DoSetCursor(localPoint: Point; cursorRgn: RgnHandle): BOOLEAN; OVERRIDE;

	CONST
		kOptionKey	= $3A;

	VAR
		aRow:				INTEGER;
		aCol:				INTEGER;
		aKeyMap:			KeyMap;
		qdExtent:			Rect;

	BEGIN
	IF SELF <> gClipView THEN
		BEGIN
		GetKeys(aKeyMap);
		IF aKeyMap[kOptionKey] THEN
			SetCursor(GetCursor(kGrabberHand)^^)
		ELSE
			CASE IdentifyPoint(localPoint, aRow, aCol) OF
				inColumn:
					IF aCol > 1 THEN
						SetCursor(GetCursor(kColumnSizingCursor)^^);
				OTHERWISE
					SetCursor(GetCursor(plusCursor)^^);
			END;
		GetQDExtent(qdExtent);
		RectRgn(cursorRgn, qdExtent);
		DoSetCursor := TRUE;
		END
	ELSE
		DoSetCursor := FALSE;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCellsView.DoSetupMenus; OVERRIDE;
VAR selection:			TypeOfSelection;
BEGIN
	INHERITED DoSetupMenus;

	{ If user isn't editing, then assume edit commands refer to cells }
	IF NOT fTable.fEntryView.fTEditing THEN BEGIN
		SetEditCmdName(cCut, cCutCells);
		SetEditCmdName(cCopy, cCopyCells);
		SetEditCmdName(cClear, cClearCells);

		IF (NOT fReadOnly) & (NOT gWorking) THEN BEGIN
			CanPaste(kTableScrapType);
			CanPaste(kTextScrapType);
		END;
	END;

	selection := fTable.fSelectionType;
	IF fReadOnly THEN BEGIN
		Enable(cCut, FALSE);
		Enable(cClear, FALSE);
		Enable(cPaste, FALSE);
	END
	ELSE BEGIN
		Enable(cCut, (selection <> NoSelection) & (NOT gWorking));
		Enable(cClear, (selection <> NoSelection) & (NOT gWorking));
	END;
	Enable(cCopy, selection <> NoSelection);
	Enable(cSelectAll, TRUE);
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCellsView.DrawCell(aCell: GridCell; aQDRect: Rect); OVERRIDE;

	VAR
		theCell:			TCell;
		theString:			Str255;

	BEGIN
	theCell := TCell(fTable.fCells.GetElement(aCell.v, aCell.h));
	IF (theCell <> NIL) & (NOT theCell.fDeleted) THEN
		WITH theCell DO
			BEGIN
			GetValueAsString(theString);
			SmartDrawString(theString, 
											aQDRect.left, 
											aQDRect.top + fLineAscent,
											GetColWidth(fColumn) - kCellHBorder * 2,
											fTable.fFormat.fJustification);
			END;

	END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TCellsView.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
												fieldType: INTEGER)); OVERRIDE;

	BEGIN
	DoToField('TCellsView', NIL, bClass);
	DoToField('fTable', @fTable, bObject);
	DoToField('fReadOnly', @fReadOnly, bBoolean);
	INHERITED Fields(DoToField);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TCellsView.MustIgnoreChar(ch: Char): BOOLEAN;
{
	Returns TRUE if the view must ignore the present character
}
BEGIN
	IF fReadOnly THEN
		MustIgnoreChar := NOT (ch IN kControlCharSet)
	ELSE
		MustIgnoreChar := NOT (ch IN kRealNumberCharSet);
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellsView.GetVisibleCells(VAR visibleCells: Rect);

	VAR
		visibleRect:		Rect;
		visibleVRect:		VRect;
		topLeftVPoint:		VPoint;

	BEGIN
	IF Focus THEN;										{ appease QDToViewRect }
	GetVisibleRect(visibleRect);
	topLeftVPoint := GetScroller(TRUE).fTranslation;
	visibleRect.topLeft := ViewToQDPt(topLeftVPoint);
	QDToViewRect(visibleRect, visibleVRect);
	visibleCells.topLeft := VPointToCell(visibleVRect.topLeft);
	visibleCells.botRight := VPointToCell(visibleVRect.botRight);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

FUNCTION TCellsView.IsCellVisible(aCell: GridCell): BOOLEAN;

	VAR
		visibleCells:		Rect;

	BEGIN
	GetVisibleCells(visibleCells);
	IsCellVisible := PtInRect(aCell, visibleCells);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellsView.PositionAtCell(aCell: GridCell);

	VAR
		aRect:				VRect;
		minToSee:			Point;
		r:					INTEGER;

	BEGIN
	{ position the cells view first }
	CellToVRect(aCell, aRect);
	WITH aRect DO
		SetPt(minToSee, right - left, bottom - top);
	RevealRect(aRect, minToSee, TRUE);

	WITH fTable DO
		BEGIN
		{ fix up the columns view }
		r := aCell.v;
		minToSee.h := fColumnsView.GetColWidth(aCell.h);
		minToSee.v := kCellHeight;
		aCell.v := 1;
		fColumnsView.CellToVRect(aCell, aRect);
		fColumnsView.RevealRect(aRect, minToSee, TRUE);

		{ fix up the rows view }
		minToSee.h := kCellWidth;
		minToSee.v := kCellHeight;
		aCell.v := r;
		aCell.h := 1;
		fRowsView.CellToVRect(aCell, aRect);
		fRowsView.RevealRect(aRect, minToSee, TRUE);
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellsView.ReSelect(cellRegion: RgnHandle);

	VAR
		aCell:				GridCell;

	BEGIN
	aCell := cellRegion^^.rgnBBox.topLeft;
	IF NOT IsCellVisible(aCell) THEN
		PositionAtCell(aCell);							{ position cellRegion at top left of grid }

	IF NOT EqualRect(cellRegion^^.rgnBBox, fSelections^^.rgnBBox) THEN
		BEGIN
		WITH fTable DO
			BEGIN
			fColumnsView.SetEmptySelection(kHighlight);
			fRowsView.SetEmptySelection(kHighlight);
			fColumnIsSelected := FALSE;
			END;
		SetSelection(cellRegion, kDontExtend, kHighlight, kSelect);
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellsView.ReSelectCell(aCell: GridCell);

	VAR
		cellRect:				Rect;

	BEGIN
	IF NOT IsCellVisible(aCell) THEN
		PositionAtCell(aCell);							{ position aCell at top left of grid }

	WITH aCell DO
		SetRect(cellRect, h, v, h+1, v+1);
	IF NOT EqualRect(cellRect, fSelections^^.rgnBBox) THEN
		BEGIN
		WITH fTable DO
			BEGIN
			fColumnsView.SetEmptySelection(kHighlight);
			fRowsView.SetEmptySelection(kHighlight);
			fColumnIsSelected := FALSE;
			END;
		SelectCell(aCell, kDontExtend, kHighlight, kSelect);
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellsView.ScrollSelectionIntoView(redraw: BOOLEAN); OVERRIDE;

	VAR
		topLeftRect:		VRect;
		minToSee:			Point;

	BEGIN
	IF NOT (EmptyRgn(fSelections)) THEN
		BEGIN
		CellToVRect(fSelections^^.rgnBBox.topLeft, topLeftRect);
		WITH topLeftRect DO
			SetPt(minToSee, right - left, bottom - top);
		RevealRect(topLeftRect, minToSee, redraw);
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellsView.SetCell(aCell: GridCell);

	BEGIN
	fTable.EditCell;											{ cell formula := string in entry view }
	InvalidateCell(aCell);								{ redraw the cell }
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellsView.SetSelection(cellsToSelect: RgnHandle; extendSelection, highlight,
								  select: BOOLEAN); OVERRIDE;

	VAR
		aQDRect:			Rect;

	BEGIN
	WITH fTable DO
		BEGIN
		INHERITED SetSelection(cellsToSelect, extendSelection, highlight, select);

		IF fEntryView.fTouched THEN						{ "commit" last cell }
			BEGIN
			EditCell;									{ change fEditCell's formula to the string
																  in fEntryView }
			fEntryView.SetToString('');
			END;

		IF NOT extendSelection & (cellsToSelect^^.rgnBBox.top <> 0) &
		   (cellsToSelect^^.rgnBBox.left <> 0) THEN
			BEGIN
			fEditColumn := cellsToSelect^^.rgnBBox.left;
			fEditRow := cellsToSelect^^.rgnBBox.top;
			fEditCell := TCell(fCells.GetElement(fEditRow, fEditColumn));

{
			IF fCoordView.Focus THEN
				BEGIN
				fCoordView.GetQDExtent(aQDRect);
				fCoordView.InvalidRect(aQDRect);
				END;
}

			END;

		SetEntry(fEditRow, fEditColumn);				{ set entry view contents to new cell }
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

PROCEDURE TCellsView.WriteTableScrap(calcScrap: Handle);

	VAR
		scrapOffset:		LONGINT;
		scrapInfo:			ScrapInfoRecord;
		cellsWritten:		INTEGER;
		i:					INTEGER;
		r:					Rect;

	PROCEDURE WriteCellToScrap(aCell: GridCell);
	BEGIN
		WITH fTable.GetCell(aCell.v, aCell.h) DO
			WriteToScrap(calcScrap, scrapOffset);
		cellsWritten := cellsWritten + 1;
	END;

BEGIN
	SetHandleSize(calcScrap, 0);
	scrapOffset := 0;

	scrapInfo.selection.top := 1;
	scrapInfo.selection.left := 1;
	scrapInfo.selection.bottom := fTable.fNoOfRows;
	scrapInfo.selection.right := fTable.fNoOfColumns;
	scrapInfo.noOfCells := fTable.fAllocatedCells;
	WriteScrap(calcScrap, scrapOffset, @scrapInfo, SIZEOF(scrapInfo));

	cellsWritten := 0;
	WITH fTable DO
		BEGIN
		FOR i := 1 TO fTable.fNoOfRows DO
			BEGIN
			WITH fTable.GetRow(i) DO
				WriteToScrap(calcScrap, scrapOffset);
			END;

		FOR i := 1 TO fTable.fNoOfColumns DO
			BEGIN
			WITH fTable.GetColumn(i) DO
				WriteToScrap(calcScrap, scrapOffset);
			END;
		r := fTable.fInUseBounds;
		EachExistingCellDo(r, WriteCellToScrap);
		END;

	{$IFC qDebug}
	WRITELN('WriteTableScrap: Number of cells written: ', cellsWritten: 0);
	IF cellsWritten <> scrapInfo.noOfCells THEN
		BEGIN
		WRITELN('WriteTableScrap: Incorrect number of cells written.');
		WRITELN('     Should be ', scrapInfo.noOfCells: 0, ', was ', cellsWritten: 0);
		ProgramBreak('');
		END;
	{$ENDC}

END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

PROCEDURE TCellsView.WriteTextScrap(textScrap: Handle);

	VAR
		r:					RowNumber;
		c:					ColumnNumber;
		theText:			Str255;
		scrapOffset:		LONGINT;
		savedPort:			GrafPtr;

	BEGIN
	GetPort(savedPort);						{ Use work port because GetValueAsString }
	SetPort(gWorkPort);						{ �sets the current port's font }

	SetHandleSize(textScrap, 0);
	scrapOffset := 0;

	FOR r := 1 TO fTable.fNoOfRows DO
		BEGIN
		FOR c := 1 TO fTable.fNoOfColumns DO
			BEGIN
			IF fTable.CellExists(r, c) THEN
				fTable.GetCell(r, c).GetValueAsString(theText)
			ELSE
				theText := '';
			IF c > 1 THEN
				theText := CONCAT(chTab, theText);
			WriteScrap(textScrap, scrapOffset, POINTER(ORD4(@theText) + 1), LENGTH(theText));
			END;
		theText := chReturn;
		WriteScrap(textScrap, scrapOffset, POINTER(ORD4(@theText) + 1), LENGTH(theText));
		END;

	SetPort(savedPort);
	END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

PROCEDURE TCellsView.WriteToDeskScrap; OVERRIDE;
VAR textScrap:			Handle;
		calcScrap:			Handle;
		err:				OSErr;
BEGIN
	textScrap := NewPermHandle(0);
	FailNIL(textScrap);
	WriteTextScrap(textScrap);
	err := PutDeskScrapData(kTextScrapType, textScrap);
	DisposHandle(textScrap);
	FailOSErr(err);

	calcScrap := NewPermHandle(0);
	FailNIL(calcScrap);
	WriteTableScrap(calcScrap);
	err := PutDeskScrapData(kTableScrapType, calcScrap);
	DisposHandle(calcScrap);
	FailOSErr(err);
END;

{--------------------------------------------------------------------------------------------------}
{$S ANonRes}

PROCEDURE TCellsView.GetPrintExtent(VAR printExtent: VRect); OVERRIDE;
VAR aRect:				VRect;
		tlCell: 			GridCell;
		brCell: 			GridCell;

BEGIN
	{ This shouldn't work anymore }
	{
		IF TTablePrintHandler(fPrintHandler).fCmdNumber = cPrintSelection THEN
			BEGIN
			tlCell := fSelections^^.rgnBBox.topLeft;
			brCell := fSelections^^.rgnBBox.botRight;
			brCell.h := Min(brCell.h - 1, fTable.fInUseBounds.right);
			brCell.v := Min(brCell.v - 1, fTable.fInUseBounds.bottom);
			END
		ELSE
	}
	BEGIN
		tlCell := fTable.fInUseBounds.topLeft;
		brCell := fTable.fInUseBounds.botRight;
	END;

	CellToVRect(tlCell, aRect);
	printExtent.topLeft := aRect.topLeft;
	CellToVRect(brCell, aRect);
	printExtent.botRight := aRect.botRight;

	{$IFC qDebug}
	IF gDebugPrinting THEN
		BEGIN
		WrLblVRect('TCellsView.GetPrintExtent ', printExtent);
		WRITELN;
		END;
	{$ENDC}
	END;

{***************************************************************************************************
	T R o w s V i e w
***************************************************************************************************}
{$S ARes}

PROCEDURE TRowsView.AdornRow(aRow: INTEGER; area: Rect); OVERRIDE;

	BEGIN
	PenSize(1, 1);
	PenPat(black);

	{ right line }
	MoveTo(area.right - 1, area.top);
	LineTo(area.right - 1, area.bottom - 1);

	{ bottom line }
	MoveTo(area.left, area.bottom);
	LineTo(area.right - 1, area.bottom);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ASelCommand}

FUNCTION TRowsView.DoMouseCommand(VAR theMouse: Point; VAR info: EventInfo;
								  VAR hysteresis: Point): TCommand; OVERRIDE;

	VAR
		aRowSelector:		TRowSelector;

	BEGIN
	NEW(aRowSelector);
	FailNIL(aRowSelector);
	aRowSelector.IRowSelector(fTable, SELF, info.theShiftKey, info.theCmdKey);
	DoMouseCommand := aRowSelector;
	WITH fTable DO
		BEGIN
		fSelectionType := RowSelection;
		fColumnsView.SetEmptySelection(kHighlight);
		fColumnIsSelected := FALSE;
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TRowsView.DoSetCursor(localPoint: Point; cursorRgn: RgnHandle): BOOLEAN; OVERRIDE;

	BEGIN
	DoSetCursor := FALSE;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TRowsView.DrawCell(aCell: GridCell; aQDRect: Rect); OVERRIDE;

	VAR
		theString:			Str255;

	BEGIN
	NumToString(aCell.v, theString);
	MoveTo(aQDRect.left + ((kRowTitleWidth - StringWidth(theString)) DIV 2), aQDRect.top +
		   fLineAscent + 2);
	DrawString(theString);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ANonRes}

PROCEDURE TRowsView.SuperViewChangedSize(delta: VPoint; invalidate: BOOLEAN); OVERRIDE;

	VAR
		theScroller:	TScroller;
		visRect:		Rect;

	BEGIN
	theScroller := TScroller(fSuperView);
	IF (theScroller.fTranslation.v + delta.v = theScroller.fMaxTranslation.v)
		& (delta.v > 0) THEN							{ needs redrawing }
			IF Focus THEN
				BEGIN
				GetVisibleRect(visRect);
				InvalidRect(visRect);
				END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TRowsView.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
											   fieldType: INTEGER)); OVERRIDE;

	BEGIN
	DoToField('TRowsView', NIL, bClass);
	DoToField('fTable', @fTable, bObject);
	INHERITED Fields(DoToField);
	END;

{***************************************************************************************************
	T C o l u m n s V i e w
***************************************************************************************************}
{$S AOpen}

PROCEDURE TColumnsView.IRes(itsDocument: TDocument; itsSuperView: TView;
	VAR itsParams: Ptr); OVERRIDE;

	BEGIN
	INHERITED IRes(itsDocument, itsSuperView, itsParams);
	SetRowHeight(1, fNumOfRows, kCellHeight);
	
	{�We cannot assume that fTable is initialized at this
		moment 
		
		fTable.fColumnIsSelected := FALSE;
	}
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TColumnsView.AdornCol(aCol: INTEGER; area: Rect); OVERRIDE;

	BEGIN
	PenPat(black);
	PenSize(1, 1);

	{ top line }
	MoveTo(area.left, area.top);
	LineTo(area.right - 1, area.top);

	{ bottom line }
	MoveTo(area.left, area.bottom - 1);
	LineTo(area.right - 1, area.bottom - 1);

	{ right line }
	MoveTo(area.right, area.top);
	LineTo(area.right, area.bottom - 1);

	{ left line }
	IF aCol > 1 THEN
		BEGIN
		MoveTo(area.left, area.top);
		LineTo(area.left, area.bottom - 1);
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ASelCommand}

FUNCTION TColumnsView.DoMouseCommand(VAR theMouse: Point; VAR info: EventInfo;
									 VAR hysteresis: Point): TCommand; OVERRIDE;

	VAR
		aColumnSelector:	TColumnSelector;
		aColumnSizer:		TColumnSizer;
		aRow:				INTEGER;
		aCol:				INTEGER;
		whichPart:			GridViewPart;
		aCell:				GridCell;

	BEGIN
	DoMouseCommand := gNoChanges;
	whichPart := IdentifyPoint(theMouse, aRow, aCol);
	aCell.h := aCol;
	aCell.v := aRow;

	CASE whichPart OF
		inCell:
			BEGIN
			fTable.fColumnIsSelected := TRUE;
			NEW(aColumnSelector);
			FailNIL(aColumnSelector);
			aColumnSelector.IColumnSelector(fTable, SELF, info.theShiftKey, info.theCmdKey);
			DoMouseCommand := aColumnSelector;
			fTable.fSelectionType := ColumnSelection;
			END;

		inColumn:
			BEGIN
			IF aCol > 1 THEN
				BEGIN
				NEW(aColumnSizer);
				FailNIL(aColumnSizer);
				aColumnSizer.IColumnSizer(fTable, aCol - 1);
				DoMouseCommand := aColumnSizer;
				END;
			END;

		OTHERWISE;
	END;
	fTable.fRowsView.SetEmptySelection(kHighlight);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TColumnsView.DoSetCursor(localPoint: Point; cursorRgn: RgnHandle): BOOLEAN; OVERRIDE;

	VAR
		aRow:				INTEGER;
		aCol:				INTEGER;
		qdExtent:			Rect;

	BEGIN
	IF SELF <> gClipView THEN
		BEGIN
		CASE IdentifyPoint(localPoint, aRow, aCol) OF
			inColumn:
				IF aCol > 1 THEN
					SetCursor(GetCursor(kColumnSizingCursor)^^);
			OTHERWISE
				SetCursor(arrow);
		END;
		GetQDExtent(qdExtent);
		RectRgn(cursorRgn, qdExtent);
		DoSetCursor := TRUE;
		END
	ELSE
		DoSetCursor := FALSE;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TColumnsView.DrawCell(aCell: GridCell; aQDRect: Rect); OVERRIDE;
VAR theString:			Str255;
BEGIN
	fTable.CoordToString(aCell.h, theString);
	SmartDrawString(theString, 
									aQDRect.left, 
									aQDRect.top + fLineAscent + 2,
									GetColWidth(aCell.h) - kCellHBorder * 2,
									teJustCenter);
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TColumnsView.ReSelect(cellRegion: RgnHandle);

	VAR
		aCell:				GridCell;
		cellsInColumn:		RgnHandle;
		cellsToSelect:		RgnHandle;

{--------------------------------------------------------------------------------------------------}
	PROCEDURE GetColumnCells(columnCell: GridCell);

		VAR
			aRect:			Rect;

		BEGIN
		SetRect(aRect, columnCell.h, 1, columnCell.h + 1, fTable.fCellsView.fNumOfRows + 1);
		RectRgn(cellsInColumn, aRect);
		UnionRgn(cellsInColumn, cellsToSelect, cellsToSelect);
		END;

	BEGIN
	aCell := cellRegion^^.rgnBBox.topLeft;
	IF NOT EqualRect(cellRegion^^.rgnBBox, fSelections^^.rgnBBox) THEN
		BEGIN											{ selection has changed }
		WITH fTable DO
			BEGIN
			fCellsView.SetEmptySelection(kHighlight);
			fRowsView.SetEmptySelection(kHighlight);
			fColumnIsSelected := TRUE;
			END;
		SetSelection(cellRegion, kDontExtend, kHighlight, kSelect);
		cellsToSelect := MakeNewRgn;
		cellsInColumn := MakeNewRgn;
		EachSelectedCellDo(GetColumnCells);				{ add cells in the column to cellsToSelect }
		fTable.fCellsView.SetSelection(cellsToSelect, kDontExtend, kHighlight, kSelect);
		DisposeRgn(cellsToSelect);
		DisposeRgn(cellsInColumn);
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ANonRes}

PROCEDURE TColumnsView.SuperViewChangedSize(delta: VPoint; invalidate: BOOLEAN); OVERRIDE;

	VAR
		theScroller:	TScroller;
		visRect:		Rect;

	BEGIN
	theScroller := TScroller(fSuperView);
	IF (theScroller.fTranslation.h + delta.h = theScroller.fMaxTranslation.h)
		& (delta.h > 0) THEN							{ needs redrawing }
			IF Focus THEN
				BEGIN
				GetVisibleRect(visRect);
				InvalidRect(visRect);
				END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TColumnsView.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
												  fieldType: INTEGER)); OVERRIDE;

	BEGIN
	DoToField('TColumnsView', NIL, bClass);
	DoToField('fTable', @fTable, bObject);
	INHERITED Fields(DoToField);
	END;

{***************************************************************************************************
	TTablePrintHandler
***************************************************************************************************}
{$S PrintImage}
{ Overridden to print page headers and footers }

PROCEDURE TTablePrintHandler.AdornPage; OVERRIDE;
CONST
	botSlop 			= 8;						{ ??? Arbitrary choice }
	topSlop 			= 24;						{ ??? Arbitrary choice }
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
	viewName := TTablePrintView(fView).fCellsView.fTable.fName;
	PreparePageHeader(aString, viewName, docName);
	baseLine := fPageAreas.theInk.top + topSlop;
	handyRect := fPageAreas.thePaper;
	ComputeTextRect(aString, baseLine, handyRect, theTextRect);
	MADrawString(@aString, theTextRect, teJustSystem);
	
	{ � draw the footer }
	PreparePageFooter(aString, fFocusedPage);
	baseLine := fPageAreas.theInk.bottom - botSlop;
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

{ ---------------------------------------------------------------------------------- }
{$S ANonRes}

PROCEDURE TTablePrintHandler.CalcViewPerPage(VAR amtPerPage: VPoint); OVERRIDE;
VAR noOfRows:			INTEGER;
BEGIN
	INHERITED CalcViewPerPage(amtPerPage);
	noOfRows := amtPerPage.v DIV kCellHeight;
	amtPerPage.v := noOfRows * kCellHeight;
END;

{ ---------------------------------------------------------------------------------- }
{$S PrintRes}

{ We set the PrintView's size big enough to show all that needs to be shown
	before printing, then we put it back in its old shape.
	We must change also the size of the scroll views, since they are
	"SizeRelSuperView". }
	
FUNCTION TTablePrintHandler.Print(itsCmdNumber: CmdNumber;
		VAR proceed: BOOLEAN): TCommand; OVERRIDE;

CONST kDontInvalidate = FALSE;

VAR fi:															FailInfo;
		oldExtentPrintView:							VRect;
		oldExtentColumnsScroller:				VRect;
		oldExtentRowsScroller:					VRect;
		oldExtentCellsScroller:					VRect;
		oldTranslationCellsScroller:		VPoint;
		columnsScroller:								TScroller;
		rowsScroller:										TScroller;
		cellsScroller:									TTableScroller;
		printExtent:										VRect;
		
	PROCEDURE PlotPrintErrHdl(error: OSErr; message: LONGINT);
	BEGIN
		WITH oldExtentPrintView DO
			fView.Resize(right-left, bottom-top, kDontInvalidate);
		WITH oldExtentColumnsScroller DO
			columnsScroller.Resize(right-left, bottom-top, kDontInvalidate);
		WITH oldExtentRowsScroller DO
			rowsScroller.Resize(right-left, bottom-top, kDontInvalidate);
		WITH oldExtentCellsScroller DO
			cellsScroller.Resize(right-left, bottom-top, kDontInvalidate);
		
		WITH oldTranslationCellsScroller DO
			cellsScroller.ScrollTo(h, v, kRedraw);
	END;

BEGIN
	{ʥ�Set the in-use bounds to the minimum }
	gApplication.CommitLastCommand;
	TTablePrintView(fView).fCellsView.fTable.CompressinUseBounds;

	{ ��remember original sizes + translations }
	fView.GetExtent(oldExtentPrintView);

	columnsScroller := TScroller(fView.FindSubView('SCL2'));
	rowsScroller := TScroller(fView.FindSubView('SCL3'));
	cellsScroller := TTableScroller(fView.FindSubView('SCL1'));
	
	columnsScroller.GetExtent(oldExtentColumnsScroller);
	rowsScroller.GetExtent(oldExtentRowsScroller);
	cellsScroller.GetExtent(oldExtentCellsScroller);
	
	oldTranslationCellsScroller := cellsScroller.fTranslation;
	
	{ʥ�Set scroll translation to zero }
	cellsScroller.ScrollTo(0, 0, kDontRedraw);

	{ ��Change the views size }
	TCellsView(fView.FindSubView('CELL')).GetPrintExtent(printExtent);
	WITH printExtent DO BEGIN
		fView.Resize(right-left + kRowTitleWidth, bottom-top + kCellHeight, kDontInvalidate);
		columnsScroller.Resize(right-left, kCellHeight, kDontInvalidate);
		rowsScroller.Resize(kCellWidth, bottom-top, kDontInvalidate);
		cellsScroller.Resize(right-left, bottom-top, kDontInvalidate);
	END;
	
	RedoPageBreaks;
	
	{ ��Print }
	CatchFailures(fi, PlotPrintErrHdl);
	Print := INHERITED Print(itsCmdNumber, proceed);
	Success(fi);
	
	{ ��Restore original sizes }
	WITH oldExtentPrintView DO
		fView.Resize(right-left, bottom-top, kDontInvalidate);
	WITH oldExtentColumnsScroller DO
		columnsScroller.Resize(right-left, bottom-top, kDontInvalidate);
	WITH oldExtentRowsScroller DO
		rowsScroller.Resize(right-left, bottom-top, kDontInvalidate);
	WITH oldExtentCellsScroller DO
		cellsScroller.Resize(right-left, bottom-top, kDontInvalidate);

	{ʥ�Restore original translations }
	WITH oldTranslationCellsScroller DO
		cellsScroller.ScrollTo(h, v, kDontRedraw);
		
	{ʥ Clean up }
	fView.ForceRedraw;
END;


{***************************************************************************************************
	T E n t r y V i e w
***************************************************************************************************}
{$S ASelCommand}

FUNCTION TEntryView.DoKeyCommand(Ch: CHAR; aKeyCode: INTEGER;
								 VAR info: EventInfo): TCommand; OVERRIDE;

BEGIN
	IF gWorking THEN
		RemindUserWeAreWorking
	ELSE BEGIN
		{ If this is the first character, wipe out old value and activate caret. }
		IF (NOT fTEditing) & ((Ch >= ' ') | (Ch = chBackspace)) THEN
			SetEditMode;
		DoKeyCommand := INHERITED DoKeyCommand(Ch, aKeyCode, info);
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ASelCommand}

FUNCTION TEntryView.DoMakeTypingCommand(Ch: CHAR): TTETypingCommand; OVERRIDE;

	VAR
		aTypingCommand: 	TTableTypingCommand;

	BEGIN
	NEW(aTypingCommand);
	FailNIL(aTypingCommand);
	aTypingCommand.ITETypingCommand(SELF, Ch);
	DoMakeTypingCommand := aTypingCommand;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ASelCommand}

FUNCTION TEntryView.DoMouseCommand(VAR theMouse: Point; VAR info: EventInfo;
								   VAR hysteresis: Point): TCommand; OVERRIDE;

	BEGIN
	{ If no characters typed, active caret, then handle mouse down. }
	IF NOT fTouched THEN
		InstallSelection(FALSE, TRUE);
	EditMode(TRUE);
	DoMouseCommand := INHERITED DoMouseCommand(theMouse, info, hysteresis);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TEntryView.DoSetupMenus; OVERRIDE;

	BEGIN
	{ TTEView.DoSetupMenus will setup the Edit menu commands for us. }
	INHERITED DoSetupMenus;

	IF gWorking THEN BEGIN
		Enable(cCopy, FALSE);
		Enable(cCut, FALSE);
		Enable(cPaste, FALSE);
		Enable(cClear, FALSE);
		Enable(cSelectAll, FALSE);
	END;


	IF fTEditing THEN
		BEGIN
		SetEditCmdName(cCut, cCutText);
		SetEditCmdName(cCopy, cCopyText);
		SetEditCmdName(cClear, cClearText);
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TEntryView.Draw(area: Rect); OVERRIDE;

	VAR
		r:					Rect;

	BEGIN
	INHERITED Draw(area);

	{ We want a rectangle around the whole view }
	PenSize(1, 1);
	PenPat(black);
	GetQDExtent(r);
	FrameRect(r);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ASelCommand}

PROCEDURE TEntryView.EditMode(editing: BOOLEAN);

	VAR
		lastCommand:		TCommand;

	BEGIN
	fTEditing := editing;
	fFirstEdit := FALSE;								{ set to TRUE only by DoKeyCommand }

	IF editing THEN
		BEGIN
		{$Push} {$H-}
		GetAsString(fOldString);						{ save previous string for Undo/Redo }
		{$Pop}
		END
	ELSE
		BEGIN											{ disable undo/redo for TTECommands. ???
														 		There must be a better way! this is
																disgusting! }
		lastCommand := GetLastCommand;
		IF lastCommand <> NIL THEN
			IF GetSuperClassID(GetClassID(lastCommand)) = GetClassIDFromName('TTECommand') THEN
				lastCommand.fCanUndo := FALSE;
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TEntryView.GetAsString(VAR theString: FormulaString);

	VAR
		theText:			CharsHandle;
		numberOfChars:		INTEGER;
		i:					INTEGER;

	BEGIN
	theText := TEGetText(fHTE);
	numberOfChars := Min(255, GetHandleSize(Handle(theText)));
	theString[0] := CHR(numberOfChars);
	FOR i := 1 TO numberOfChars DO
		theString[i] := theText^^[i - 1];
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TEntryView.InstallSelection(wasActive, beActive: BOOLEAN); OVERRIDE;

	VAR
		r:					Rect;

	BEGIN
	INHERITED InstallSelection(wasActive, beActive);

	TESetSelect(0, 0, fHTE);
	fTouched := beActive;
	IF Focus THEN
		BEGIN
		GetQDExtent(r);
		InsetRect(r, 2, 2);
		InvalidRect(r);
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ASelCommand}

PROCEDURE TEntryView.SetEditMode;
	BEGIN
	EditMode(TRUE);									{ sets fFirstEdit to FALSE }
	fFirstEdit := TRUE;								{ the only place it is set to TRUE }
	SetToString('');
	InstallSelection(FALSE, TRUE);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TEntryView.SetToString(theString: FormulaString);

	BEGIN
	IF Focus THEN;
	SetJustification(teJustLeft, kDontRedraw);		{ initialize text to left-justified }
	InstallSelection(TRUE, FALSE);
	TESetText(Ptr(ORD4(@theString) + 1), LENGTH(theString), fHTE);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TEntryView.SwapStrings;

	VAR
		newString:			FormulaString;

	BEGIN
	newString := fOldString;
	{$Push} {$H-}
	GetAsString(fOldString);
	{$Pop}
	SetToString(newString);
	END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TEntryView.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
												fieldType: INTEGER)); OVERRIDE;

	BEGIN
	DoToField('TEntryView', NIL, bClass);
	DoToField('fTable', @fTable, bObject);
	DoToField('fTouched', @fTouched, bBoolean);
	DoToField('fTEditing', @fTEditing, bBoolean);
	DoToField('fFirstEdit', @fFirstEdit, bBoolean);
	DoToField('fOldString', @fOldString, bString);
	INHERITED Fields(DoToField);
	END;


{$IFC FALSE}

						{***************************************************************************************************
							T C o o r d V i e w
						***************************************************************************************************}
						{--------------------------------------------------------------------------------------------------}
						{$S ARes}
						
						PROCEDURE TCoordView.Draw(area: Rect);
						
							VAR
								aString, anotherString: Str255;
						
							BEGIN
							WITH fTable DO
								BEGIN
								IF fEditColumn > 0 THEN
									fTable.CoordToString(fEditColumn, aString)
								ELSE
									aString := ' ';
						
								IF fEditRow > 0 THEN
									NumToString(fEditRow, anotherString)
								ELSE
									anotherString := ' ';
								END;
							aString := CONCAT(aString, anotherString);
							SetTheFont(kEntryFont, kEntryFontSize, [bold]);
							SmartDrawString(aString, 2, kEntryHeight, 46, teJustLeft);
							END;
						
						{--------------------------------------------------------------------------------------------------}
						{$S AFields}
						
						PROCEDURE TCoordView.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
																		fieldType: INTEGER)); OVERRIDE;
						
							BEGIN
							DoToField('TCoordView', NIL, bClass);
							DoToField('fTable', @fTable, bObject);
							INHERITED Fields(DoToField);
							END;

{$ENDC} { UNUSED }

{****************************************************************************************}
{  T T a b l e S c r o l l e r	}
{****************************************************************************************}

{--------------------------------------------------------------------------------------------------}
{$S MAScroll}

PROCEDURE TTableScroller.DoScroll(delta: VPoint; redraw: BOOLEAN); OVERRIDE;

	BEGIN
	IF delta.v <> 0 THEN								{ scroll the rows view }
		fRowScroller.DoScroll(delta, redraw);
	IF delta.h <> 0 THEN								{ scroll the columns view }
		fColumnScroller.DoScroll(delta, redraw);
	INHERITED DoScroll(delta, redraw);					{ scroll the cells view }
	END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TTableScroller.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
												fieldType: INTEGER)); OVERRIDE;

	BEGIN
	DoToField('TTableScroller', NIL, bClass);
	DoToField('fRowScroller', @fRowScroller, bObject);
	DoToField('fColumnScroller', @fColumnScroller, bObject);
	INHERITED Fields(DoToField);
	END;

{***************************************************************************************************
	T C o l u m n
***************************************************************************************************}
{$S ARes}

PROCEDURE TColumn.IColumn(number: INTEGER);

	BEGIN
	fNumber := number;
	fWidth := kCellWidth;
	FailMemError;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TColumn.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
						 fieldType: INTEGER)); OVERRIDE;

	BEGIN
	DoToField('TColumn', NIL, bClass);
	DoToField('fNumber', @fNumber, bInteger);
	DoToField('fWidth', @fWidth, bInteger);

	INHERITED Fields(DoToField);
	END;

{--------------------------------------------------------------------------------------------------}
{$S AReadFile}

PROCEDURE TColumn.ReadFromDisk(theRefNum: INTEGER);

	VAR
		columnInfo: 		ColumnDiskInfo;

	BEGIN
	ReadBytes(theRefNum, SIZEOF(columnInfo), @columnInfo);
	WITH columnInfo DO
		BEGIN
		fNumber := number;
		fWidth := width;
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

PROCEDURE TColumn.ReadFromScrap(theScrap: Handle; VAR scrapOffset: LONGINT);

	VAR
		columnInfo: 		ColumnDiskInfo;

	BEGIN
	ReadScrap(theScrap, scrapOffset, @columnInfo, SIZEOF(columnInfo));
	WITH columnInfo DO
		BEGIN
		fNumber := number;
		fWidth := width;
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AWriteFile}

PROCEDURE TColumn.WriteToDisk(theRefNum: INTEGER);

	VAR
		columnInfo: 		ColumnDiskInfo;
		theColumn:			ColumnNumber;

	BEGIN
	theColumn := fNumber;
	WriteBytes(theRefNum, SIZEOF(ColumnNumber), @theColumn);

	WITH columnInfo DO
		BEGIN
		number := fNumber;
		width := fWidth;
		END;
	WriteBytes(theRefNum, SIZEOF(columnInfo), @columnInfo);
	END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

PROCEDURE TColumn.WriteToScrap(theScrap: Handle; VAR scrapOffset: LONGINT);

	VAR
		columnInfo: 		ColumnDiskInfo;

	BEGIN
	WITH columnInfo DO
		BEGIN
		number := fNumber;
		width := fWidth;
		END;
	WriteScrap(theScrap, scrapOffset, @columnInfo, SIZEOF(columnInfo));
	END;

{***************************************************************************************************
	T R o w
***************************************************************************************************}
{$S ARes}

PROCEDURE TRow.IRow(number: INTEGER);

	BEGIN
	fNumber := number;
	FailMemError;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TRow.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
	fieldType: INTEGER)); OVERRIDE;

	BEGIN
	DoToField('TRow', NIL, bClass);
	DoToField('fNumber', @fNumber, bInteger);
	INHERITED Fields(DoToField)
	END;

{--------------------------------------------------------------------------------------------------}
{$S AReadFile}

PROCEDURE TRow.ReadFromDisk(theRefNum: INTEGER);

	VAR
		RowInfo:			RowDiskInfo;

	BEGIN
	ReadBytes(theRefNum, SIZEOF(RowInfo), @RowInfo);
	WITH RowInfo DO
		fNumber := number;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

PROCEDURE TRow.ReadFromScrap(theScrap: Handle; VAR scrapOffset: LONGINT);

	VAR
		RowInfo:			RowDiskInfo;

	BEGIN
	ReadScrap(theScrap, scrapOffset, @RowInfo, SIZEOF(RowInfo));
	WITH RowInfo DO
		fNumber := number;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AWriteFile}

PROCEDURE TRow.WriteToDisk(theRefNum: INTEGER);

	VAR
		RowInfo:			RowDiskInfo;
		theRow: 			RowNumber;

	BEGIN
	theRow := fNumber;
	WriteBytes(theRefNum, SIZEOF(RowNumber), @theRow);

	WITH RowInfo DO
		number := fNumber;
	WriteBytes(theRefNum, SIZEOF(RowInfo), @RowInfo);
	END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

PROCEDURE TRow.WriteToScrap(theScrap: Handle; VAR scrapOffset: LONGINT);

	VAR
		RowInfo:			RowDiskInfo;

	BEGIN
	WITH RowInfo DO
		number := fNumber;
	WriteScrap(theScrap, scrapOffset, @RowInfo, SIZEOF(RowInfo));
	END;

{***************************************************************************************************
	T C e l l
***************************************************************************************************}
{$S ARes}

PROCEDURE TCell.ICell(owningTable: TTable; r: RowNumber; c: ColumnNumber);
BEGIN
	owningTable.AddCell(SELF, r, c);
	FailMemError;

	fTable := owningTable;
	fDeleted := FALSE;

	fKind := EmptyCell;
	fValue := gMissing;
	fValueString := '';
	fFormula := '';

	fRow := r;
	fColumn := c;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCell.CopyContents(sourceCell: TCell);

	BEGIN
	fKind := sourceCell.fKind;
	fFormula := sourceCell.fFormula;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

{ This is a function that takes its input from the string fFormula, tries to
	convert it to a real number, and puts the result into the field
	fValue.  If the cell doesn't contain a valid number, fKind is set to
	ErrorCell; otherwise it is set to ValueCell. }
	
PROCEDURE TCell.EvaluateFormula;
VAR aString: Str255;
		anExtended: Extended;
BEGIN												{ EvaluateFormula }
	aString := fFormula;
	IF aString = '' THEN
		fValue := gMissing
	ELSE BEGIN
		anExtended := Str2Num(aString);
		IF ClassExtended(anExtended) = QNan THEN BEGIN
			{�???
				We should make the application beep when the conversion is wrong;
				still, we don't want this to happen when converting the external
				clipboard into our format.  How to distinguish between the two cases ??? 
				
				gApplication.Beep(100);
			}
			
			fKind := ErrorCell;
			fValue := gMissing;
		END
		ELSE BEGIN
			fKind := ValueCell;
			fValue := anExtended;
		END;
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCell.GetAsString(VAR theString: FormulaString);
BEGIN
	theString := fFormula;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCell.GetValueAsString(VAR theString: Str255);

	BEGIN
	CASE fKind OF
		ValueCell:
			BEGIN
				IF fValueString = '' THEN
					ValueToString;
				theString := fValueString;
			END;
		ErrorCell:
			theString := '???';
		OTHERWISE
			theString := '';
	END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TCell.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
										   fieldType: INTEGER)); OVERRIDE;

	VAR
		aString:		Str255;

	BEGIN
	DoToField('TCell', NIL, bClass);
	DoToField('fDeleted', @fDeleted, bBoolean);
	DoToField('fTable', @fTable, bObject);
	DoToField('fRow', @fRow, bByte);
	DoToField('fColumn', @fColumn, bByte);
	CASE fKind OF
		EmptyCell:	aString := 'Empty';
		ValueCell:	aString := 'Value';
		ErrorCell:	aString := 'Error';
		END;
	DoToField('fKind', @aString, bString);
	DoToField('fValueString', @fValueString, bString);
	DoToField('fValue', @fValue, bExtended);
	DoToField('fFormula', @fFormula, bString);
	INHERITED Fields(DoToField);
	END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TCell.GetInspectorName(VAR inspectorName: Str255); OVERRIDE;
VAR tableName, colName: Str255;
BEGIN
	IF IsObject(fTable.fColumnsView) THEN BEGIN
		fTable.CoordToString(fColumn, colName);
		NumToString(fRow, inspectorName);
		fTable.GetInspectorName(tableName);
		inspectorName := CONCAT(tableName, ' ', colName, ' ', inspectorName);
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCell.Invalidate;

	VAR
		aCell:				GridCell;

	BEGIN
	aCell.h := fColumn;
	aCell.v := fRow;
	fTable.fCellsView.InvalidateCell(aCell);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

FUNCTION TCell.IsEmpty: BOOLEAN;

	BEGIN
	IsEmpty := (fKind = EmptyCell) & (LENGTH(fFormula) = 0);
	END;

{--------------------------------------------------------------------------------------------------}
{$S AReadFile}

PROCEDURE TCell.ReadFromDisk(theRefNum: INTEGER);
VAR cellLength: 		INTEGER;
		cellInfo:				CellDiskInfo;
BEGIN
	{$IFC qDebug}
	{�Writeln('TCell.ReadFromDisk: entering'); }
	{$ENDC}
	
	ReadBytes(theRefNum, SIZEOF(cellInfo), @cellInfo);
	WITH cellInfo DO BEGIN
		fKind := kind;
		fValue := value;
		fFormula := formula;
	END;

	{$IFC qDebug}
	{
	Writeln('TCell.ReadFromDisk: exiting, after reading');
	WITH cellInfo DO BEGIN
		Writeln(' - kind:', ORD(kind));
		Writeln(' - value:', value);
		Writeln(' - formula:', formula);
	END;
	}
	{$ENDC}
	
END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

PROCEDURE TCell.ReadFromScrap(theScrap: Handle; VAR scrapOffset: LONGINT);
VAR cellLength: 		INTEGER;
		cellInfo:				CellDiskInfo;

BEGIN
	ReadScrap(theScrap, scrapOffset, @cellInfo, SIZEOF(cellInfo));

	WITH cellInfo DO BEGIN
		fKind := kind;
		fValue := value;
		fFormula := formula;
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCell.Recalculate;
VAR oldValue: ValueType;
		oldKind:	KindOfCell;
BEGIN
	fValueString := '';		{ so GetValueAsString will re-compute fValueString }
	oldValue := fValue;
	oldKind := fKind;
	EvaluateFormula;
	IF (oldValue <> fValue) | (oldKind <> fKind) THEN
		Invalidate;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCell.SetDeleteState(deleted: BOOLEAN);
BEGIN
	fDeleted := deleted;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCell.SetToString(theString: FormulaString);

	VAR
		theOldString:		FormulaString;

	BEGIN
	GetAsString(theOldString);
	IF theString <> theOldString THEN
		BEGIN
		fFormula := theString;
		fKind := EmptyCell; 				{ Force Recalculate to invalidate the cell }
		Recalculate;
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}
{ Fills fValueString with the string representation of the cell's value. }

PROCEDURE TCell.ValueToString;
VAR aString:				Str255;
		aValueType: 		ValueType;
		tableFormat:		FormatRecord;
BEGIN
	IF fValue = gMissing THEN BEGIN
		fValueString := '';
		Exit(ValueToString);
	END;
	
	tableFormat := fTable.fFormat;
	WITH tableFormat DO
		CASE tableFormat.fStyle OF
			General:
				BEGIN
					{ It would be convenient to allow the user to choose the number of 
						digits to be displayed }
					aValueType := fValue;
					Num2NiceStr(aValueType, aString, fDigits);
				END;
			DecimalStyle:
				BEGIN
					pDecimalFormat.digits := fDigits;
					aValueType := fValue;
					Num2Str(pDecimalFormat, aValueType, DecStr(aString));
				END;
			Scientific:
				BEGIN
					pScientificFormat.digits := fDigits;
					aValueType := fValue;
					Num2Str(pScientificFormat, aValueType, DecStr(aString));
				END;
		END;	{�Case }

	IF aString[1] = ' ' THEN
		Delete(aString, 1, 1);							{ Remove leading space }

	fValueString := Copy(aString, 1, Min(kMaxValueLength, LENGTH(aString)));
END;

{--------------------------------------------------------------------------------------------------}
{$S AWriteFile}

PROCEDURE TCell.WriteToDisk(theRefNum: INTEGER);
VAR cellInfo:				CellDiskInfo;
		cellLength: 		INTEGER;

	PROCEDURE WriteCellCoordinate(theObject: TObject);
	VAR cellCoordinate: 	Point;
	BEGIN
		cellCoordinate.v := TCell(theObject).fRow;
		cellCoordinate.h := TCell(theObject).fColumn;
		WriteBytes(theRefNum, SIZEOF(cellCoordinate), @cellCoordinate);
	END;

BEGIN
	WriteCellCoordinate(TObject(SELF));
	WITH cellInfo DO BEGIN
		kind := fKind;
		value := fValue;
		formula := fFormula;
		WriteBytes(theRefNum, SIZEOF(cellInfo), @cellInfo);
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S AClipBoard}

PROCEDURE TCell.WriteToScrap(theScrap: Handle; VAR scrapOffset: LONGINT);
VAR cellInfo:			CellDiskInfo;
		cellLength: 		INTEGER;

	PROCEDURE WriteCellCoordinate(theObject: TObject);
	VAR cellCoordinate: 	Point;
	BEGIN
		cellCoordinate.v := TCell(theObject).fRow;
		cellCoordinate.h := TCell(theObject).fColumn;
		WriteScrap(theScrap, scrapOffset, @cellCoordinate, SIZEOF(cellCoordinate));
	END;

BEGIN
	WriteCellCoordinate(TObject(SELF));
	WITH cellInfo DO BEGIN
		kind := fKind;
		value := fValue;
		formula := fFormula;
		WriteScrap(theScrap, scrapOffset, @cellInfo, SIZEOF(cellInfo));
	END;
END;

{***************************************************************************************************
	T T a b l e S e l e c t C o m m a n d
***************************************************************************************************}
{$S ASelCommand}

PROCEDURE TTableSelectCommand.ITableSelectCommand(itsTable: TTable; itsView: TGridView;
												theShiftKey, theCmdKey: BOOLEAN);

	BEGIN
	ICellSelectCommand(itsView, theShiftKey, theCmdKey);
	fTable := itsTable;
	itsTable.fEntryView.EditMode(FALSE);
	END;

{--------------------------------------------------------------------------------------------------}
{$S AScroll}

PROCEDURE TTableSelectCommand.AutoScroll(deltaH, deltaV: VCoordinate); OVERRIDE;

	BEGIN
	IF (deltaH <> 0) | (deltaV <> 0) THEN
		fTable.fCellsView.GetScroller(TRUE).ScrollBy(deltaH, deltaV, TRUE);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TTableSelectCommand.ComputeNewSelection(VAR clickedCell: GridCell); OVERRIDE;

	VAR
		r:					Rect;

	BEGIN
	IF fGridView.CanSelectCell(clickedCell) THEN
		BEGIN
		Pt2Rect(fAnchorCell, clickedCell, r);
		r.right := r.right + 1;
		r.bottom := r.bottom + 1;
		RectRgn(fThisSelection, r);
		IF fCmdKey THEN
			IF fDeselecting THEN
				DiffRgn(fPrevSelection, fThisSelection, fThisSelection)
			ELSE
				UnionRgn(fPrevSelection, fThisSelection, fThisSelection);
		END;
	END;

{***************************************************************************************************
	T R o W S e l e c t o r
***************************************************************************************************}
{$S ASelCommand}

PROCEDURE TRowSelector.IRowSelector(itsTable: TTable; itsView: TGridView; theShiftKey,
									theCmdKey: BOOLEAN);

	VAR
		aCellSelector:		TTableSelectCommand;

	BEGIN
	fCellSelector := NIL;
	fTable := itsTable;
	IF fTable.fSelectionType <> RowSelection THEN
		theCmdKey := FALSE;
	ICellSelectCommand(itsView, theShiftKey, theCmdKey);

	NEW(aCellSelector);
	FailNIL(aCellSelector);
	aCellSelector.ITableSelectCommand(itsTable, itsTable.fCellsView, theShiftKey, theCmdKey);
	fCellSelector := aCellSelector;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TRowSelector.Free; OVERRIDE;

	BEGIN
	FreeIfObject(fCellSelector);
	INHERITED Free;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AScroll}

PROCEDURE TRowSelector.AutoScroll(deltaH, deltaV: VCoordinate); OVERRIDE;

	BEGIN
	IF deltaV <> 0 THEN
		fTable.fCellsView.GetScroller(TRUE).ScrollBy(0, deltaV, TRUE);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TRowSelector.ComputeAnchorCell(VAR clickedCell: GridCell); OVERRIDE;

	BEGIN
	INHERITED ComputeAnchorCell(clickedCell);
	fAnchorCell.h := 1;

	clickedCell.h := 1;
	fCellSelector.ComputeAnchorCell(clickedCell);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TRowSelector.ComputeNewSelection(VAR clickedCell: GridCell); OVERRIDE;

	VAR
		r:					Rect;

	BEGIN
	clickedCell.h := fGridView.fNumOfCols;
	INHERITED ComputeNewSelection(clickedCell);

	clickedCell.h := fTable.fNoOfColumns;
	fCellSelector.ComputeNewSelection(clickedCell);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TRowSelector.DoIt; OVERRIDE;

	BEGIN
	INHERITED DoIt;
	fCellSelector.DoIt;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

FUNCTION TRowSelector.TrackMouse(aTrackPhase: TrackPhase; VAR anchorPoint, previousPoint,
								 nextPoint: VPoint; mouseDidMove: BOOLEAN): TCommand; OVERRIDE;

	VAR
		clickedCell:		GridCell;

	BEGIN
	IF mouseDidMove THEN
		BEGIN
		clickedCell := fGridView.VPointToCell(nextPoint);
		IF aTrackPhase = TrackPress THEN
			BEGIN
			ComputeAnchorCell(clickedCell);
			IF fCmdKey THEN
				BEGIN
				fDeselecting := PtInRgn(fAnchorCell, fGridView.fSelections);
				fCellSelector.fDeselecting := fDeselecting;
				END;
			END;

		IF LONGINT(clickedCell) <> LONGINT(fPrevCell) THEN
			BEGIN
			ComputeNewSelection(clickedCell);
			HighlightNewSelection;
			fCellSelector.HighlightNewSelection;

			CopyRgn(fThisSelection, fPrevSelection);
			fPrevCell := clickedCell;
			WITH fCellSelector DO
				BEGIN
				CopyRgn(fThisSelection, fPrevSelection);
				fPrevCell := clickedCell;
				END;
			END;
		END;
	TrackMouse := SELF;
	END;

{***************************************************************************************************
	T C o l u m n S e l e c t o r
***************************************************************************************************}
{$S ASelCommand}

PROCEDURE TColumnSelector.IColumnSelector(itsTable: TTable; itsView: TGridView;
										  theShiftKey, theCmdKey: BOOLEAN);

	VAR
		aCellSelector:		TTableSelectCommand;

	BEGIN
	aCellSelector := NIL;
	fTable := itsTable;
	IF fTable.fSelectionType <> ColumnSelection THEN
		theCmdKey := FALSE;
	ICellSelectCommand(itsView, theShiftKey, theCmdKey);

	NEW(aCellSelector);
	FailNIL(aCellSelector);
	aCellSelector.ITableSelectCommand(itsTable, itsTable.fCellsView, theShiftKey, theCmdKey);
	fCellSelector := aCellSelector;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TColumnSelector.Free; OVERRIDE;

	BEGIN
	FreeIfObject(fCellSelector);
	INHERITED Free;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AScroll}

PROCEDURE TColumnSelector.AutoScroll(deltaH, deltaV: VCoordinate); OVERRIDE;

	BEGIN
	IF deltaH <> 0 THEN
		fTable.fCellsView.GetScroller(TRUE).ScrollBy(deltaH, 0, TRUE);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TColumnSelector.ComputeAnchorCell(VAR clickedCell: GridCell); OVERRIDE;

	BEGIN
	INHERITED ComputeAnchorCell(clickedCell);
	fAnchorCell.v := 1;

	clickedCell.v := 1;
	fCellSelector.ComputeAnchorCell(clickedCell);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TColumnSelector.ComputeNewSelection(VAR clickedCell: GridCell); OVERRIDE;

	VAR
		r:					Rect;

	BEGIN
	clickedCell.v := fGridView.fNumOfRows;
	INHERITED ComputeNewSelection(clickedCell);

	clickedCell.v := fTable.fNoOfRows;
	fCellSelector.ComputeNewSelection(clickedCell);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TColumnSelector.DoIt; OVERRIDE;

	BEGIN
	INHERITED DoIt;
	fCellSelector.DoIt;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

FUNCTION TColumnSelector.TrackMouse(aTrackPhase: TrackPhase; VAR anchorPoint, previousPoint,
									nextPoint: VPoint; mouseDidMove: BOOLEAN): TCommand; OVERRIDE;

	VAR
		clickedCell:		GridCell;

	BEGIN
	IF mouseDidMove THEN
		BEGIN
		clickedCell := fGridView.VPointToCell(nextPoint);
		IF aTrackPhase = TrackPress THEN
			BEGIN
			ComputeAnchorCell(clickedCell);
			IF fCmdKey THEN
				BEGIN
				fDeselecting := PtInRgn(fAnchorCell, fGridView.fSelections);
				fCellSelector.fDeselecting := fDeselecting;
				END;
			END;

		IF LONGINT(clickedCell) <> LONGINT(fPrevCell) THEN
			BEGIN
			ComputeNewSelection(clickedCell);
			HighlightNewSelection;
			fCellSelector.HighlightNewSelection;

			CopyRgn(fThisSelection, fPrevSelection);
			fPrevCell := clickedCell;
			WITH fCellSelector DO
				BEGIN
				CopyRgn(fThisSelection, fPrevSelection);
				fPrevCell := clickedCell;
				END;
			END;
		END;
	TrackMouse := SELF;
	END;

{***************************************************************************************************
	T C o l u m n S i z e r
***************************************************************************************************}
{$S ASelCommand}

PROCEDURE TColumnSizer.IColumnSizer(itsTable: TTable; c: ColumnNumber);

	VAR
		colRect:			VRect;

	BEGIN
	ICommand(cSizeColumn, itsTable.fDocument, itsTable.fCellsView,
			 itsTable.fCellsView.GetScroller(TRUE));
	fConstrainsMouse := TRUE;
	fTable := itsTable;
	fCellsView := itsTable.fCellsView;
	fColumn := itsTable.GetColumn(c);
	fNewWidth := fCellsView.GetColWidth(fColumn.fNumber);
	fOldWidth := fNewWidth;
	fCellsView.ColToVRect(fColumn.fNumber, 1, colRect);
	fLeftEdge := colRect.left;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AScroll}

PROCEDURE TColumnSizer.AutoScroll(deltaH, deltaV: VCoordinate); OVERRIDE;

	BEGIN
	{ Do nothing, so that no scrolling takes place while resizing a column. }
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

FUNCTION TColumnSizer.TrackMouse(aTrackPhase: TrackPhase; VAR anchorPoint, previousPoint,
								 nextPoint: VPoint; mouseDidMove: BOOLEAN): TCommand; OVERRIDE;

	BEGIN
	fNewWidth := Min(nextPoint.h - fLeftEdge, kTELength);
	fNewWidth := Max(fNewWidth, 10);
	TrackMouse := SELF;
	nextPoint.h := Min(nextPoint.h, fLeftEdge + kTELength);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TColumnSizer.TrackFeedback(anchorPoint, nextPoint: VPoint; turnItOn,
									 mouseDidMove: BOOLEAN); OVERRIDE;

	VAR
		viewedRect: 		Rect;
		pState: 			PenState;

	BEGIN
	IF mouseDidMove THEN
		BEGIN
		GetPenState(pState);
		PenPat(black);

		fCellsView.GetQDExtent(viewedRect);

		MoveTo(Min(nextPoint.h, fLeftEdge + kTELength), viewedRect.top);
		Line(0, viewedRect.bottom - viewedRect.top);
		SetPenState(pState);
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TColumnSizer.TrackConstrain(anchorPoint, previousPoint: VPoint;
									  VAR nextPoint: VPoint); OVERRIDE;

	BEGIN
	IF nextPoint.h < fLeftEdge + 10 THEN
		nextPoint.h := fLeftEdge + 10
	ELSE
		nextPoint.h := Min(nextPoint.h, fLeftEdge + kTELength);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TColumnSizer.SetColumnWidth(newWidth: INTEGER);

	BEGIN
	IF newWidth > kTELength THEN
		BEGIN
		newWidth := kTELength;
		fNewWidth := kTELength;
		END
	ELSE IF newWidth < 10 THEN
		newWidth := 10;

	fCellsView.SetColWidth(fColumn.fNumber, 1, newWidth);
	fTable.fColumnsView.SetColWidth(fColumn.fNumber, 1, newWidth);
	fColumn.fWidth := newWidth;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TColumnSizer.DoIt; OVERRIDE;

	VAR
		minToSee:			Point;
		aRect:				VRect;

	BEGIN
	SetColumnWidth(fNewWidth);

	fCellsView.ColToVRect(fColumn.fNumber, 1, aRect);
	WITH aRect DO
		SetPt(minToSee, right - left, bottom - top);
	fCellsView.RevealRect(aRect, minToSee, TRUE);

	fTable.fColumnsView.ColToVRect(fColumn.fNumber, 1, aRect);
	WITH aRect DO
		SetPt(minToSee, right - left, bottom - top);
	fTable.fColumnsView.RevealRect(aRect, minToSee, TRUE);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TColumnSizer.UndoIt; OVERRIDE;

	BEGIN
	SetColumnWidth(fOldWidth);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TColumnSizer.RedoIt; OVERRIDE;

	BEGIN
	DoIt;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TColumnSizer.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
												  fieldType: INTEGER)); OVERRIDE;

	BEGIN
	DoToField('TColumnSizer', NIL, bClass);
	DoToField('fTable', @fTable, bObject);
	DoToField('fCellsView', @fCellsView, bObject);
	DoToField('fLeftEdge', @fLeftEdge, bInteger);
	DoToField('fColumn', @fColumn, bObject);
	DoToField('fNewWidth', @fNewWidth, bInteger);
	DoToField('fOldWidth', @fOldWidth, bInteger);
	INHERITED Fields(DoToField);
	END;

{***************************************************************************************************
	T T a b l e T y p i n g C o m m a n d
***************************************************************************************************}
{$S ADoCommand}

PROCEDURE TTableTypingCommand.ITETypingCommand(itsTEView: TTEView; itsFirstChar: CHAR); OVERRIDE;

	BEGIN
	fCellsView := TEntryView(itsTEView).fTable.fCellsView;
	fTargetCell := fCellsView.FirstSelectedCell;
	INHERITED ITETypingCommand(itsTEView, itsFirstChar);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TTableTypingCommand.AddCharacter(aChar: Char); OVERRIDE;
{ Switch the entry view from left to right justification when the typed characters overflow the
  entry box, and switch back to left justification if the text shrinks enough }

VAR
	selRight:				INTEGER;

{--------------------------------------------------------------------------------------------------}
	FUNCTION AddCharWidths: INTEGER;

		VAR
			aString:		Str255;

		BEGIN
		GetIText(fHTE^^.hText, aString);
		AddCharWidths := StringWidth(aString);
		END;

	BEGIN
	IF (aChar <> chBackspace) & (fTEView.fJustification = teJustLeft) THEN
		BEGIN
		selRight := fHTE^^.selRect.right;
		IF (selRight < 0) | (selRight > fHTE^^.destRect.right) THEN
			selRight := fHTE^^.selPoint.h;
		IF selRight + CharWidth(aChar) > fHTE^^.destRect.right THEN
			fTEView.SetJustification(teJustRight, kDontRedraw);
		END;

	INHERITED AddCharacter(aChar);

	IF (aChar = chBackspace) & (fTEView.fJustification = teJustRight) THEN
		IF AddCharWidths < LengthRect(fHTE^^.destRect, h) THEN
			fTEView.SetJustification(teJustLeft, kRedraw);
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TTableTypingCommand.UndoIt; OVERRIDE;
{ If the selection has changed since this command was created, restore it to the
  target cell before Undoing. }

	VAR
		entryView:			TEntryView;

	BEGIN
	fCellsView.ReSelectCell(fTargetCell);				{ make sure fTargetCell is selected }
	entryView := TEntryView(fTEView);
	IF (entryView.fTEditing) & (NOT entryView.fFirstEdit) THEN
		INHERITED UndoIt								{ TTE undo }
	ELSE
		BEGIN
		entryView.SwapStrings;							{ exchange current and saved strings }
		fCellsView.SetCell(fTargetCell);				{ change fTargetCell's contents and redraw
														  it }
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TTableTypingCommand.RedoIt; OVERRIDE;
{ If the selection has changed since this command was created, restore it to the
  target cell before Redoing. }

	VAR
		entryView:			TEntryView;

	BEGIN
	fCellsView.ReSelectCell(fTargetCell);				{ make sure fTargetCell is selected }
	entryView := TEntryView(fTEView);
	IF (entryView.fTEditing) & (NOT entryView.fFirstEdit) THEN
		INHERITED RedoIt								{ TTE redo }
	ELSE
		BEGIN
		entryView.SwapStrings;							{ exchange current and saved strings }
		fCellsView.SetCell(fTargetCell);				{ change fTargetCell's contents and redraw
														  it }
		END;
	END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TTableTypingCommand.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
														fieldType: INTEGER)); OVERRIDE;

	BEGIN
	DoToField('TTableTypingCommand', NIL, bClass);
	DoToField('fCellsView', @fCellsView, bObject);
	DoToField('fTargetCell', @fTargetCell, bPoint);
	INHERITED Fields(DoToField);
	END;


{***************************************************************************************************
	T C e l l E d i t C o m m a n d
***************************************************************************************************}
{$S ASelCommand}

PROCEDURE TCellEditCommand.ICellEditCommand(itsTable: TTable; itsCommand: INTEGER);
BEGIN
	fSelection := NIL;
	ICommand(itsCommand, itsTable.fDocument, itsTable.fCellsView, NIL);
	fTable := itsTable;
	fSelection := MakeNewRgn;							{ copy the current selection region }
	CopyRgn(itsTable.fCellsView.fSelections, fSelection);
	fChangesClipboard := itsCommand <> cClear;
	fCausesChange := itsCommand <> cCopy;
END;

{--------------------------------------------------------------------------------------------------}
{$S ARes}

PROCEDURE TCellEditCommand.Free; OVERRIDE;
BEGIN
	IF fSelection <> NIL THEN
		DisposeRgn(fSelection);
	INHERITED Free;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

{�Creates a clipboard view, copies the selection into it, and installs it
	into the clipboard window }

PROCEDURE TCellEditCommand.CopySelection;
VAR clipTable:			TTable;
		clipView:				TCellsView;
		clipRect:				Rect;

	PROCEDURE CopyRowToClipboard(aCell: GridCell);
	VAR newRow: 			TRow;
	BEGIN
		newRow := TRow(fTable.GetRow(aCell.v).Clone);
		newRow.fNumber := newRow.fNumber - clipTable.fRowOffset;
		clipTable.AddRow(newRow);
	END;

	PROCEDURE CopyColumnToClipboard(aCell: GridCell);
	VAR newColumn:			TColumn;
	BEGIN
		newColumn := TColumn(fTable.GetColumn(aCell.h).Clone);
		newColumn.fNumber := newColumn.fNumber - clipTable.fColumnOffset;
		clipTable.AddColumn(newColumn);
	END;

	PROCEDURE CopyCellToClipboard(aCell: GridCell);
	VAR newCell:			TCell;
			oldCell:			TCell;
	BEGIN
		oldCell := fTable.GetExistingCell(aCell.v, aCell.h);
		IF oldCell <> NIL THEN BEGIN
			newCell := TCell(oldCell.Clone);
			clipTable.AddCell(newCell, newCell.fRow - clipTable.fRowOffset, 
												newCell.fColumn - clipTable.fColumnOffset);
		END;
	END;

BEGIN
	NEW(clipTable);
	FailNIL(clipTable);
	clipRect := fSelection^^.rgnBBox;
	clipRect.bottom := clipRect.bottom - 1;
	clipRect.right := clipRect.right - 1;
	clipTable.ITable(clipRect, 
									 NIL, 							{�unused }
									 gClipFormat, 
									 0);									{�unused }
	clipTable.DoInitialState;

	fTable.fRowsView.EachSelectedCellDo(CopyRowToClipboard);
	fTable.fColumnsView.EachSelectedCellDo(CopyColumnToClipboard);
	fTable.fCellsView.EachSelectedCellDo(CopyCellToClipboard);

	NEW(clipView);
	FailNIL(clipView);
	clipView.ICellsView(clipTable, TRUE, NIL);
	clipTable.fCellsView := clipView;
	gApplication.ClaimClipboard(clipView);
	clipView.AdjustSize;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellEditCommand.DeleteSelection;

	PROCEDURE DeleteCell(aCell: GridCell);
	BEGIN
		fTable.DeleteCell(aCell.v, aCell.h);
	END;

BEGIN
	fTable.fCellsView.EachSelectedCellDo(DeleteCell);
	fTable.fCellsView.InvalidateSelection;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellEditCommand.RestoreSelection;
VAR firstCell:			GridCell;

	PROCEDURE RestoreCell(aCell: GridCell);
	BEGIN
		fTable.UndeleteCell(aCell.v, aCell.h);
	END;

BEGIN
	fTable.fCellsView.EachSelectedCellDo(RestoreCell);
	fTable.fCellsView.InvalidateSelection;

	firstCell := fTable.fCellsView.FirstSelectedCell;
	fTable.SetEntry(firstCell.v, firstCell.h);	{ update entry view }
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellEditCommand.ReSelect;
BEGIN
	fTable.fCellsView.ReSelect(fSelection);
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellEditCommand.DoIt;
BEGIN
	IF fCmdNumber <> cClear THEN
		CopySelection;
	IF fCmdNumber <> cCopy THEN
		DeleteSelection;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellEditCommand.UndoIt;
{ If the user has changed the selection since this command was created,
  restore it before Undoing so that the correct cells are affected. }

BEGIN
	IF fCmdNumber <> cCopy THEN BEGIN
		ReSelect;										{ restore command's original selection }
		RestoreSelection;
		fTable.fCellsView.ScrollSelectionIntoView(TRUE);
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellEditCommand.RedoIt;
{ If the user has changed the selection since this command was created,
  restore it before Redoing so that the correct cells are affected. }

BEGIN
	IF fCmdNumber <> cCopy THEN BEGIN
		ReSelect;										{ restore command's original selection }
		DeleteSelection;
		fTable.fCellsView.ScrollSelectionIntoView(TRUE);
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellEditCommand.Commit;
BEGIN
	fTable.FreeDeletedCells;
END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TCellEditCommand.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
													  fieldType: INTEGER)); OVERRIDE;
BEGIN
	DoToField('TCellEditCommand', NIL, bClass);
	DoToField('fTable', @fTable, bObject);
	DoToField('fSelection', @fSelection, bRgnHandle);
	INHERITED Fields(DoToField);
END;


{***************************************************************************************************
	T C e l l P a s t e C o m m a n d
***************************************************************************************************}
{$S ASelCommand}

PROCEDURE TCellPasteCommand.ICellPasteCommand(itsTable: TTable);
VAR cellsToSelect:	RgnHandle;
		firstCell:			GridCell;
		lastCell:				GridCell;
		aRect:					Rect;
		scrapSize:			Point;
		fi:							FailInfo;
	
	FUNCTION GetTextScrapDim(HScrap: Handle; len: LONGINT; VAR size: Point): LONGINT;
			C; EXTERNAL;
		
	PROCEDURE HandleICellPasteCommand(error: OSErr; message: LONGINT);
	BEGIN
		DisposeRgn(cellsToSelect);
	END;
	
BEGIN
	{$IFC qDebug}
	IF (NOT Member(gClipView, TCellsView))
		 & (NOT Member(gClipView, TTEView))
		 & ((NOT Member(gClipView, TDeskScrapView))
					| (NOT TDeskScrapView(gClipView).fHaveText))
	THEN
		ProgramBreak('Attempt to paste a non-TCellsView and non-TEXT clipboard');
	{$ENDC}
	
	{�make sure Free can work }
	fSelection := NIL;
	fReplacedCells := NIL;
	
	ICommand(cPaste, itsTable.fDocument, itsTable.fCellsView, NIL);
	fTable := itsTable;
	IF gClipView.ContainsClipType('TEXT') THEN BEGIN
		fClipContainsText := TRUE;
		IF Member(gClipView, TDeskScrapView) THEN
			fClipTextHandle := TDeskScrapView(gClipView).fDataHandle
		ELSE
		IF Member(gClipView, TTEView) THEN
			fClipTextHandle := TTEView(gClipView).ExtractText
		ELSE
			Failure(maxErr, 0);	{�Call it a programming error ! }
		fClipTextLength := GetHandleSize(fClipTextHandle);
		IF GetTextScrapDim(fClipTextHandle, fClipTextLength, scrapSize) <> 0 THEN
			Failure(kNonRectangularScrap, 0);
		{$IFC qDebug}
		Writeln('Pasting text; table size is (hv):', scrapSize.h, scrapSize.v);
		{$ENDC}
	END
	ELSE BEGIN
		fClipContainsText := FALSE;
		fClipTable := TCellsView(gClipView).fTable;
	END;
		
	{�If only one cell is selected, extend the selection to be as big as
		the scrap }

	firstCell := itsTable.fCellsView.FirstSelectedCell;
	lastCell := itsTable.fCellsView.LastSelectedCell;
	IF (itsTable.fSelectionType = cellSelection) 
			& (firstCell.h = lastCell.h) & (firstCell.v = lastCell.v)
	THEN BEGIN
		IF fClipContainsText THEN
			SetRect(aRect, firstCell.h,
										 firstCell.v,
										 firstCell.h + scrapSize.h, 
										 firstCell.v + scrapSize.v)
		ELSE
			SetRect(aRect, firstCell.h, 
										 firstCell.v,
										 firstCell.h + fClipTable.fNoOfColumns, 
										 firstCell.v + fClipTable.fNoOfRows);

		IF (aRect.right > itsTable.fNoOfColumns+1) | (aRect.bottom > itsTable.fNoOfRows+1)
		THEN
			Failure(kScrapTableTooBig, 0);

		cellsToSelect := MakeNewRgn;
		CatchFailures(fi, HandleICellPasteCommand);
		RectRgn(cellsToSelect, aRect);
		itsTable.fCellsView.SetSelection(cellsToSelect, kDontExtend, kHighlight, kSelect);
		Success(fi);
		DisposeRgn(cellsToSelect);
	END;
	
	{ copy the current selection region }
	fSelection := MakeNewRgn;
	CopyRgn(itsTable.fCellsView.fSelections, fSelection);
	
	{�init the list }
	fReplacedCells := NewList;
	FailNIL(fReplacedCells);
	{$IFC qDebug}
	fReplacedCells.SetEltType('TCell');
	{$ENDC}
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellPasteCommand.Free; OVERRIDE;

	PROCEDURE FreeCell(theCell: TCell);
	BEGIN
		FreeIfObject(theCell);
	END;

BEGIN
	IF fSelection <> NIL THEN
		DisposeRgn(fSelection);
	IF fReplacedCells <> NIL THEN BEGIN
		fReplacedCells.Each(FreeCell);
		fReplacedCells.Free;
	END;
	INHERITED Free;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellPasteCommand.DoIt;
VAR r:					INTEGER;
		c:					INTEGER;
		textOffset:	LONGINT;
		fi: 				FailInfo;
		
	PROCEDURE ReadStringFromTextScrap(HScrap: Handle; length: LONGINT; 
																			VAR offset: LONGINT; VAR s: FormulaString;
																			strLen: LONGINT);
			C; EXTERNAL;

	PROCEDURE PasteCell(aCell: GridCell);
	VAR sourceCell: 		TCell;
			replacedCell:		TCell;
			destCell:				TCell;
			sourceFormula:	FormulaString;
	BEGIN
		destCell := fTable.GetCell(aCell.v, aCell.h);
		replacedCell := TCell(destCell.Clone); {�??? What happens if Clone fails ? }
		fReplacedCells.InsertLast(replacedCell); {�??? What happens if InsertLast fails ? }

		IF fClipContainsText THEN BEGIN
			ReadStringFromTextScrap(fClipTextHandle, 
															fClipTextLength,
															textOffset, 
															sourceFormula,
															kMaxFormulaLength);
			IF textOffset >= fClipTextLength THEN
				textOffset := 0;
			destCell.SetToString(sourceFormula);
		END
		ELSE BEGIN	{�Clip contains a tableView }
			sourceCell := fClipTable.GetCell(r, c);
			
			c := c + 1;
			IF c > fClipTable.fNoOfColumns THEN BEGIN
				c := 1;
				r := r + 1;
				IF r > fClipTable.fNoOfRows THEN
					r := 1;
			END;
			destCell.CopyContents(sourceCell);						{ copy the necessary fields }
		END;
	END;					{�PasteCell }

	PROCEDURE HdlPasteFailure(error: OSErr; message: LONGINT);
	{ We ran out of memory and couldn't complete the paste.
	  So, let's back out the partial paste. All or nothing! }

		PROCEDURE RestoreCell(replacedCell: TCell);
		VAR pastedCell: 		TCell;
		BEGIN
			pastedCell := fTable.GetCell(replacedCell.fRow, replacedCell.fColumn);
			IF replacedCell.IsEmpty THEN				{ free up memory used by empty cell }
				BEGIN
				fTable.DeleteCell(pastedCell.fRow, pastedCell.fColumn);
				fTable.FreeCell(pastedCell);
				END
			ELSE
				pastedCell.CopyContents(replacedCell);
			replacedCell.Free;							{ free up memory used by replacement cell }
		END;

	BEGIN											{�HdlPasteFailure }
		fReplacedCells.Each(RestoreCell);
		fReplacedCells.DeleteAll;
		UpdateViews;
	END;											{�HdlPasteFailure }

BEGIN												{ TCellPasteCommand.DoIt }
	CatchFailures(fi, HdlPasteFailure);
	IF fClipContainsText THEN
		textOffset := 0
	ELSE BEGIN
		r := 1;
		c := 1;
	END;
	fTable.fCellsView.EachSelectedCellDo(PasteCell);
	Success(fi);
	UpdateViews;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellPasteCommand.UndoIt;

	PROCEDURE RestoreCell(replacedCell: TCell);
	VAR pastedCell: 		TCell;
	BEGIN
		pastedCell := fTable.GetCell(replacedCell.fRow, replacedCell.fColumn);
		pastedCell.CopyContents(replacedCell);
	END;

BEGIN
	fTable.fCellsView.ReSelect(fSelection);		{ restore original selection }
	fReplacedCells.Each(RestoreCell);
	UpdateViews;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellPasteCommand.RedoIt;
VAR r:					INTEGER;
		c:					INTEGER;

	PROCEDURE RepasteCell(aCell: GridCell);
	VAR sourceCell: 		TCell;
			destCell:			TCell;
	BEGIN
		destCell := fTable.GetCell(aCell.v, aCell.h);
		sourceCell := fClipTable.GetCell(r, c);
		c := c + 1;
		IF c > fClipTable.fNoOfColumns THEN
			BEGIN
			c := 1;
			r := r + 1;
			IF r > fClipTable.fNoOfRows THEN
				r := 1;
			END;

		destCell.CopyContents(sourceCell);
	END;

BEGIN
	fTable.fCellsView.ReSelect(fSelection);		{ restore original selection }
	r := 1;
	c := 1;
	fTable.fCellsView.EachSelectedCellDo(RepasteCell);
	UpdateViews;
END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TCellPasteCommand.UpdateViews;
VAR aString:			FormulaString;
		aCell:				GridCell;

	PROCEDURE RecalcCell(aCell: GridCell);
	VAR theCell:			TCell;
	BEGIN
		theCell := fTable.GetExistingCell(aCell.v, aCell.h);
		IF theCell <> NIL THEN
			theCell.Recalculate;
	END;

BEGIN
	WITH fTable DO BEGIN
		fCellsView.EachSelectedCellDo(RecalcCell);

		fCellsView.InvalidateSelection;

		aCell.h := fEditColumn;
		aCell.v := fEditRow;
		IF fCellsView.IsCellSelected(aCell) THEN BEGIN
			fEditCell := GetCell(aCell.v, aCell.h);
			fEditCell.GetAsString(aString);
			fEntryView.SetToString(aString);
		END;
	END;
END;

{--------------------------------------------------------------------------------------------------}
{$S AFields}

PROCEDURE TCellPasteCommand.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
													   fieldType: INTEGER)); OVERRIDE;

BEGIN
	DoToField('TCellPasteCommand', NIL, bClass);
	DoToField('fClipTable', @fClipTable, bObject);
	DoToField('fTable', @fTable, bObject);
	DoToField('fSelection', @fSelection, bRgnHandle);
	DoToField('fReplacedCells', @fReplacedCells, bObject);
	INHERITED Fields(DoToField);
END;

{ ********************************************************************************** }
{	*				TTablePrintView																													 * }
{ ********************************************************************************** }
{$S ARes}

{ Determines where page breaks occur for printing. }

FUNCTION  TTablePrintView.DoBreakFollowing(vhs: VHSelect; prevBreak: VCoordinate;
															VAR Automatic: BOOLEAN): VCoordinate; OVERRIDE;
VAR thisBreak:			VCoordinate;
		rowsPerPage:		LONGINT;
		totalWidth:			LONGINT;
		width: 					LONGINT;
		pageWidth:			LONGINT;
		extentRect: 		VRect;
		firstCol:				ColumnNumber;
		c:							ColumnNumber;

	FUNCTION ColumnAtCoord(loc: VCoordinate): INTEGER;
	VAR width: LONGINT;
	BEGIN
		ColumnAtCoord := -1;
		IF loc = 0 THEN
			EXIT(ColumnAtCoord);

		c := 0;
		width := kRowTitleWidth;
		WHILE width <= loc DO BEGIN
			c := c + 1;
			width := width + fCellsView.GetColWidth(c);
		END;
		ColumnAtCoord := c;
	END;

BEGIN
	{$IFC qDebug}
	{�Writeln('DoBreakFollowing: entering, TTable is ',
						fCellsView.fTable.fName,
						', n. of cols is ',
						fCellsView.fTable.fNoOfColumns:1); }
	{$ENDC}
	GetPrintExtent(extentRect);
	CASE vhs OF
		h:
			BEGIN
			rowsPerPage := fPrintHandler.fViewPerPage.v DIV kCellHeight;
			thisBreak := prevBreak + (rowsPerPage * kCellHeight);
			END;
		v:
			BEGIN
				pageWidth := fPrintHandler.fViewPerPage.h;
				totalWidth := 0;
				firstCol := ColumnAtCoord(prevBreak) + 1;
				FOR c := firstCol TO fCellsView.fTable.fNoOfColumns DO BEGIN
					IF c = 0 THEN
						width := kRowTitleWidth
					ELSE
						width := fCellsView.GetColWidth(c);
					IF totalWidth + width <= pageWidth THEN
						totalWidth := totalWidth + width
					ELSE
						LEAVE;
				END;
				thisBreak := prevBreak + totalWidth;
			END;
	END;
	
	thisBreak := Min(thisBreak, extentRect.botRight.vh[gOrthogonal[vhs]]);

	{$IFC qDebug}
	IF thisBreak <= prevBreak THEN BEGIN
		IF vhs = v THEN
			WriteLn('No advance in DoBreakFollowing; vhs = v ', 
							' prevBreak = ', prevBreak: 1)
		ELSE
			WriteLn('No advance in DoBreakFollowing; vhs = h ', 
							' prevBreak = ', prevBreak: 1);
		ProgramBreak('No advance in BreakFollowing');
	END;

	IF gDebugPrinting THEN BEGIN
		WRITE('TCellsView.DoBreakFollowing: prevBreak=');
		IF vhs = v THEN
			WRITELN('[v]', prevBreak, ', thisBreak=[v]', thisBreak)
		ELSE
			WRITELN('[h]', prevBreak, ', thisBreak=[h]', thisBreak);
	END;
	{$ENDC}

	DoBreakFollowing := thisBreak;
END;

{ ---------------------------------------------------------------------------------- }
{$S ANonRes}

PROCEDURE TTablePrintView.GetPrintExtent(VAR printExtent: VRect); OVERRIDE;
BEGIN
	fCellsView.GetPrintExtent(printExtent);
	WITH printExtent DO BEGIN
		right := right + kRowTitleWidth;
		bottom := bottom + 2*kCellHeight;
	END;
END;

{ ---------------------------------------------------------------------------------- }
{$IFC qDebug}
{$S ANonRes}

PROCEDURE TTablePrintView.DoDrawPageBreak(vhs: VHSelect; whichBreak: INTEGER;
										 loc: VCoordinate; automatic: BOOLEAN); OVERRIDE;

VAR vPt:				VPoint;
		qdStartPt:			Point;
		qdEndPt:			Point;

BEGIN
	IF gDebugPrinting THEN BEGIN
		vPt.vh[gOrthogonal[vhs]] := loc;
		vPt.vh[vhs] := 0;
		qdStartPt := ViewToQDPt(vPt);
		vPt.vh[vhs] := fSize.vh[vhs] - gBreaksPenState.pnSize.vh[vhs];
		qdEndPt := ViewToQDPt(vPt);

		MoveTo(qdStartPt.h, qdStartPt.v);
		LineTo(qdEndPt.h, qdEndPt.v);
	END;
END;

{$ENDC}

{ ---------------------------------------------------------------------------------- }
{$S ARes}

PROCEDURE TTablePrintView.Draw(area: Rect); OVERRIDE;
VAR
	extent:	VRect;
BEGIN
	INHERITED Draw(area);

	{ draw the extra borders for the rows and columns views }
	PenNormal;

	{ rows }
	MoveTo(0, kCellHeight);
	Line(kRowTitleWidth-1, 0);

	MoveTo(0, kCellHeight + kCellHeight-1);
	Line(kRowTitleWidth-1, 0);
	
	{ columns }
	MoveTo(kRowTitleWidth-1, kCellHeight);
	Line(0, kCellHeight-1);
	
	{ Bottom }
	IF NOT gPrinting THEN BEGIN
		GetExtent(extent);
		WITH extent DO BEGIN
			MoveTo(0, bottom - kSBarSizeMinus1);
			Line(right, 0);
		END;
	END;

	{�We used to draw a border on the right and bottom edge of the table;
		this caused a problem; is could happen that a whole page be reserved only
		to draw the border! So we gave up the right and bottom borders. }
	IF gPrinting THEN BEGIN							{�draw borders around view }
		GetPrintExtent(extent);
		WITH extent DO BEGIN
			MoveTo(0, kCellHeight);
			LineTo(0, bottom {-1});
		END;
	END;
END;


{ ********************************************************************************** }
{	*				TConstraintsTablePrintView																							 * }
{ ********************************************************************************** }
{$S ARes}

{ Determines where page breaks occur for printing. }

FUNCTION  TConstraintsTablePrintView.DoBreakFollowing(vhs: VHSelect;
						prevBreak: VCoordinate; VAR Automatic: BOOLEAN): VCoordinate; OVERRIDE;
VAR thisBreak:			VCoordinate;
		rowsPerPage:		LONGINT;
		pageWidth:			LONGINT;
		extentRect: 		VRect;

BEGIN
	GetPrintExtent(extentRect);
	CASE vhs OF
		h:
			BEGIN
			rowsPerPage := fPrintHandler.fViewPerPage.v DIV kCellHeight;
			thisBreak := prevBreak + (rowsPerPage * kCellHeight);
			END;
		v:
			BEGIN
				pageWidth := fPrintHandler.fViewPerPage.h;
				thisBreak := extentRect.right; { pageWidth? }
			END;
	END;
	
	thisBreak := Min(thisBreak, extentRect.botRight.vh[gOrthogonal[vhs]]);

	{$IFC qDebug}
	IF thisBreak <= prevBreak THEN BEGIN
		IF vhs = v THEN
			WriteLn('No advance in DoBreakFollowing; vhs = v ', 
							' prevBreak = ', prevBreak: 1)
		ELSE
			WriteLn('No advance in DoBreakFollowing; vhs = h ', 
							' prevBreak = ', prevBreak: 1);
		ProgramBreak('No advance in BreakFollowing');
	END;

	IF gDebugPrinting THEN BEGIN
		WRITE('TCellsView.DoBreakFollowing: prevBreak=');
		IF vhs = v THEN
			WRITELN('[v]', prevBreak, ', thisBreak=[v]', thisBreak)
		ELSE
			WRITELN('[h]', prevBreak, ', thisBreak=[h]', thisBreak);
	END;
	{$ENDC}

	DoBreakFollowing := thisBreak;
END;
