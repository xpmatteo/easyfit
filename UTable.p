{[a-,body+,h-,o=100,r+,rec+,t=4,u+,#+,j=20/57/1$,n+]}
{ 
	UTable.p
	
	This Unit is a modification of Apple's Ucalc.p from the Calc MacApp example.
	
	Copyright © 1986-1989 by Apple Computer, Inc. All rights reserved.
	Changes Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	
	This unit implements a simple spreadsheet-like table of data, capable of 
	displaying its data in a window.
	
	The table is fairly similar to a document, since it can save and read 
	its contents to/from disk.
	
	We can declare a table to have arbitrary dimensions. However, internally the
	table is represented as the rect (1, fNoOfRows, 1, fNoOfColumns), with
	elements (0,0), (x,0), (0,x) left to represent no cell, no row or no column,
	respectively.
	
	19/12/89: Added SetReadOnly method
}

UNIT UTable;

	INTERFACE

		USES
			{ ¥ MacApp }
			UMacApp,

			{ ¥ Building Blocks }
			UPrinting, UGridView, UTEView, UDialog,

			{ ¥ Required for this unit's interface }
			Sane,

			{ ¥ Implementation use }
			ToolUtils, Fonts, Packages

			{$IFC qNeedsROM128K}
			, PrintTraps
			{$ELSEC}
			, Printing						{ Needed because we override printing commands }
			{$ENDC}

			{ ¥ Other Libraries }
			, UEasyFitDeclarations, UEasyFitUtilities, UGrabberTracker;

		CONST

			kTableWindowType 	= 1001; 					{ Resource id of the table window }
			kTableNoGoAwayWindowType 	= 1002;		{ Same without go-away }

		TYPE

			RowNumber				= INTEGER;			{ Zero indicates no row. }
			ColumnNumber		= INTEGER;

			ValueFormat 		= DecForm;			{ Have SANE display numeric values in decimal }

			KindOfCell			= (EmptyCell, ValueCell, ErrorCell);

			EvalResult			= (NoError, MissingRightParen, SelfReference, ErrorCellReference,
								   BadNumber, IllegalCharacter, BadCellReference, GarbageAtEnd);

			TypeOfSelection 	= (NoSelection, CellSelection, RowSelection, ColumnSelection,
								   AllSelection);

			TypeOfStyle 		= (NoStyle, General, DecimalStyle, Scientific, UnknownStyle);

			FormatPtr				= ^FormatRecord;
			FormatRecord		= PACKED RECORD
				fStyle: 				TypeOfStyle;
				fDigits:				0..255;
				fJustification:	SignedByte;
				fFontNumber:		0..255;
				fFontSize:			0..255;
				fFontStyle: 		Style;
				END;

			TableDocDiskInfo 	= RECORD				{ This is the first record for a table }
				dimensions: 		Rect;
				allocatedCells: 	INTEGER;
				allocatedRows:		INTEGER;
				allocatedColumns:	INTEGER;
				selectionType:		TypeOfSelection;
				editRow:			RowNumber;
				editColumn: 		ColumnNumber;
				END;

			RowDiskInfo 		= RECORD					{ Info about the document's rows }
				number: 			INTEGER;
				END;

			ColumnDiskInfo		= RECORD				{ Info about the document's columns }
				number: 			INTEGER;
				width:				INTEGER;
				END;

			CellDiskInfo		= RECORD				{ The document's cells }
			{ row/column coordinate read/written separately }
				kind:						KindOfCell;
				value:					DiskValueType;
				formula:				FormulaString;
				END;

				ScrapInfoRecord 	= RECORD
					selection:			Rect;
					noOfCells:			INTEGER;
				END;
				
				CellScrapInfo		= RECORD
					{ row/column coordinate read/written separately }
					{ cell length read/written separately }
					format: 			FormatRecord;
					formula:			FormulaString;
				END;

{--------------------------------------------------------------------------------------------------}
			{ÊThis is a dynamic array. We need it because we want to declare at run-time
				its dimension }
			
			TDynaVector = OBJECT(TObject)
			
				fData: 		Ptr;
				fFirst:		INTEGER;
				fLast:		INTEGER;
				
					{ Init & Free }
					
				PROCEDURE TDynaVector.IDynaVector(first, last: INTEGER);
				PROCEDURE TDynaVector.Free;	OVERRIDE;
				
					{ Accessing elements }
					
				FUNCTION TDynaVector.GetElement(n: INTEGER): TObject;
				PROCEDURE TDynaVector.SetElement(n: INTEGER; toThis: TObject);

					{ Debug }
					
				PROCEDURE TDynaVector.Fields(PROCEDURE DoToField(fieldName: Str255; 
																			fieldAddr: Ptr;
												 							fieldType: INTEGER)); OVERRIDE;				
			END;

{--------------------------------------------------------------------------------------------------}
			{ÊSame as a DynaArray, but it is a two-dimensional table instead of a 
				vector. }
			
			TDynaMatrix = OBJECT(TObject)
			
				{ Some fields contain redundant info, but it is more important
					here to optimize for speed. }
				
				fData:					Ptr;
				fDimension:			Rect;
				fNRows:					INTEGER;
				fNColumns:			INTEGER;
				fRowOffset:			INTEGER;
				fColumnOffset:	INTEGER;

					{ Init & Free }
					
				PROCEDURE TDynaMatrix.IDynaMatrix(dimension: Rect);
				PROCEDURE TDynaMatrix.Free;	OVERRIDE;
				
					{ Accessing elements }
					
				FUNCTION TDynaMatrix.GetElement(r, c: LONGINT): TObject;
				PROCEDURE TDynaMatrix.SetElement(r, c: LONGINT; toThis: TObject);
				
					{ Inspecting & Debugging }
				
				PROCEDURE TDynaMatrix.Fields(PROCEDURE DoToField(fieldName: Str255; 
																			fieldAddr: Ptr;
												 							fieldType: INTEGER)); OVERRIDE;

			END;

{--------------------------------------------------------------------------------------------------}
			TTable= OBJECT (TObject)
				fDocument:		TDocument;			{Êits document }
				fTemplate:		INTEGER;				{Êthe template to be used by DoMakeViews }
				fReadOnly:		BOOLEAN;				{ÊDefault is false }
				
				fFormat:			FormatRecord;

				fCells: 			TDynaMatrix;		{ÊMatrix of pointers to cells }
				fEditCell:		TCell;					{ the cell being edited (the current selection) }

				fRows:				TDynaVector;
				fRowOffset: 	INTEGER;

				fColumns:			TDynaVector;
				fColumnOffset:		INTEGER;
				fColumnIsSelected:	BOOLEAN;		{ a column has been selected }
				
				fTableWindow:		TWindow;				{Êthe window related to the table }
				fCellsView: 		TCellsView; 		{ the view of the cells themselves }
				fRowsView:			TRowsView;			{ the view of the row numbers }
				fColumnsView:		TColumnsView;		{ the view of the column letters }
				fEntryView: 		TEntryView; 		{ the view for entering/editing cell values }
{$IFC FALSE}
				fCoordView: 		TCoordView; 		{ the view that shows the selected cell's coordinates }
{$ENDC}
				fPrintView:			TTablePrintView;{ÊThe view to be printed }
				fDimensions:		Rect;						{ the document's dimensions }
				fInUseBounds:		Rect;						{ the area of the document that is in use }
				fAllocatedCells:	INTEGER;			{ the number of allocated cells }
				fAllocatedRows: 	INTEGER;			{ the number of allocated rows }
				fAllocatedColumns:	INTEGER;		{ the number of allocated columns }

				fSelectionType: 	TypeOfSelection;

				fEditRow:				RowNumber;			{ the row of the cell being edited }
				fEditColumn:		ColumnNumber;		{ the column of the cell being edited }

				fNoOfRows:			INTEGER;			{ maximum number of rows }
				fNoOfColumns:		INTEGER;			{ maximum number of columns }

				fName:					Str255;				{ÊUsed in debugging saving documents }

					{ Initialization and termination }

				PROCEDURE TTable.ITable(dimensions: Rect; 
																itsDocument: TDocument;
																format: FormatRecord;
																template: INTEGER);

				{ Initialize the table }

				PROCEDURE TTable.DoInitialState;
				{ Initialize allocation counts }

				PROCEDURE TTable.DoMakeViews(forPrinting: BOOLEAN);
				{ Launch the views which are seen in the document's window }

				PROCEDURE TTable.Free; OVERRIDE;
				{ Free the table }

				PROCEDURE TTable.CompressInUseBounds;

				PROCEDURE TTable.GetInUseBounds(VAR bounds: Rect);
				
				PROCEDURE TTable.FreeData;
				{ Delete the cells, rows, and columns }
				
					{ÊCommunication with the rest of the application.  The
						coordinates passed to these routines are in the "external"
						system of coordinates.  (Internally, all tables regard as cell 1,1
						the cell at the top left corner.) }
				
				FUNCTION TTable.GetValue(r, c: INTEGER): EXTENDED;
								
				PROCEDURE TTable.ColumnToArray(c: INTEGER; p: PExtended);
				{ Copies the values in a C-style vector of extended, that the caller
					should allocate }
				
				{ Copies the values from a C-style vector of len extended into the c-th
					column }
				PROCEDURE TTable.ArrayToColumn(c: INTEGER; p: PExtended; len: INTEGER);
				
				{ Restituiscono il valore minimo o massimo che si trova su di una colonna;
					se la colonna e' vuota, restituiscono gMissing }
				FUNCTION TTable.GetMinOfCol(c: INTEGER; onlyPositives: BOOLEAN): EXTENDED;
				FUNCTION TTable.GetMaxOfCol(c: INTEGER; onlyPositives: BOOLEAN): EXTENDED;
				
				{ Returns TRUE if any of the cell is an error cell }
				FUNCTION TTable.DataCheck: BOOLEAN;
				
				{ÊSee doc in the implementation part }
				PROCEDURE TTable.ConfirmEntry;
				
				{ÊUse this method instead of writing the fReadOnly field }
				PROCEDURE TTable.SetReadOnly(readOnly: BOOLEAN);
				
					{ Filing OVERRIDES }

				PROCEDURE TTable.DoNeedDiskSpace(VAR dataForkBytes,
														rsrcForkBytes: LONGINT);
				{ Tells how many bytes of disk space will be required to store the
		  		  data for the document in a file on disk }

				PROCEDURE TTable.DoRead(aRefNum: INTEGER; rsrcExists,
											   forPrinting: BOOLEAN);
				{ Reads in the data from the disk, when a document is Opened or Reverted }

				PROCEDURE TTable.DoWrite(aRefNum: INTEGER; makingCopy: BOOLEAN);
				{ Writes the data to the disk, when a document is Saved }

					{ Cell management }

				PROCEDURE TTable.AddCell(theCell: TCell; r: RowNumber; c: ColumnNumber);
				{ Add the cell to the document }

				FUNCTION  TTable.CellExists(r: RowNumber; c: ColumnNumber): BOOLEAN;
				{ Is there a cell object at these coordinates? }

				PROCEDURE TTable.DeleteCell(r: RowNumber; c: ColumnNumber);
				{ Mark the cell at the given coordinates as deleted }

				PROCEDURE TTable.EachExistingCellDo(cellRange: Rect; PROCEDURE
														   DoToCell(aCell: GridCell));
				{ Perform DoToCell on each cell object in the range }

				PROCEDURE TTable.EditCell;
				{ Change the formula of the cell being edited to the string in the entry view }

				PROCEDURE TTable.FreeCell(theCell: TCell);
				{ Free the specified cell object }

				PROCEDURE TTable.FreeDeletedCells;
				{ Free each cell object that is marked deleted }

				FUNCTION  TTable.GetCell(r: RowNumber; c: ColumnNumber): TCell;
				{ Return the cell object for the given coordinates. }

				FUNCTION  TTable.GetExistingCell(r: RowNumber; c: ColumnNumber): TCell;
				{ Return the cell object or NIL if no cell is allocated for the given coordinates. }

				PROCEDURE TTable.SetEntry(r: RowNumber; c: ColumnNumber);
				{ Set the text in the entry view to the formula in the cell at the given
				  coordinates }

				PROCEDURE TTable.UndeleteCell(r: RowNumber; c: ColumnNumber);
				{ If there is a cell at the given coordinates, mark it undeleted }

					{ Row management }

				PROCEDURE TTable.AddRow(theRow: TRow);
				{ Add the row to the document }

				PROCEDURE TTable.EachExistingRowDo(PROCEDURE
														  DoToCell(aCell: GridCell));

				FUNCTION  TTable.GetRow(r: RowNumber): TRow;

				FUNCTION  TTable.RowExists(r: RowNumber): BOOLEAN;

					{ Column management }

				PROCEDURE TTable.AddColumn(theColumn: TColumn);
				{ Add the column to the document }

				FUNCTION  TTable.ColumnExists(c: ColumnNumber): BOOLEAN;
				
				PROCEDURE TTable.CoordToString(coord: INTEGER; VAR theString: Str255);
				{ÊProvide the string for the horizontal titles }

				PROCEDURE TTable.EachExistingColumnDo(PROCEDURE
															 DoToCell(aCell: GridCell));

				FUNCTION  TTable.GetColumn(c: ColumnNumber): TColumn;

					{ÊThis is called when a column is modified someway. It is an empty method
						that provides a hook to subclasses to handle the "column changed" event
						as they wish. The primary purpose of this is to redraw the data & model
						plot. If "all" is true, then "column" should not be used. }
				PROCEDURE TTable.ChangedColumn(all: BOOLEAN; column: ColumnNumber);

					{ Ranges of cells }

				FUNCTION  TTable.CellInRange(r: INTEGER; c: INTEGER; range: Rect): BOOLEAN;
				{ Do the given coordinates fall within the range? }

				PROCEDURE TTable.ConstrainToUsedCells(VAR cellRange: Rect);
				{ Shrink the range of cells to exclude unallocated cells, if possible }

				PROCEDURE TTable.DoRecalculate;
				{ Recalculate all the existing cells in the document }

					{ Inspecting }
		
				PROCEDURE TTable.Fields(PROCEDURE
											   				DoToField(fieldName: Str255; fieldAddr: Ptr;
																fieldType: INTEGER)); OVERRIDE;

				PROCEDURE TTable.GetInspectorName(VAR inspectorName: Str255); OVERRIDE;

				END;									{ TTable }

{--------------------------------------------------------------------------------------------------}

			TCellsView			= OBJECT (TTextGridView)
			{ TCellsView is the view used to show the cell values. }

				fTable:			TTable;
				fReadOnly:	BOOLEAN;

					{ Initialization and termination }

				PROCEDURE TCellsView.ICellsView(itsTable: TTable;
																				forClipboard: BOOLEAN; itsParent: TView);

					{ Commands and menus }

				FUNCTION  TCellsView.DoMouseCommand(VAR themouse: Point; VAR info: EventInfo;
												   VAR hysteresis: Point): TCommand; OVERRIDE;

				PROCEDURE TCellsView.DoSetupMenus; OVERRIDE;

				FUNCTION  TCellsView.DoMenuCommand(aCmdNumber: cmdNumber): TCommand; OVERRIDE;
				{ Handle menu commands }

				FUNCTION  TCellsView.DoKeyCommand(ch: Char; aKeyCode: INTEGER;
												 VAR info: EventInfo): TCommand; OVERRIDE;

					{ Display and Selection }

				PROCEDURE TCellsView.AdornCol(aCol: INTEGER; area: Rect); OVERRIDE;
				{ Draw a column delimiter ("adornment") in the given area }

				PROCEDURE TCellsView.AdornRow(aRow: INTEGER; area: Rect); OVERRIDE;
				{ Draw a row delimiter in the given area }

				FUNCTION  TCellsView.DoSetCursor(localPoint: Point;
					cursorRgn: RgnHandle): BOOLEAN; OVERRIDE;

				PROCEDURE TCellsView.DrawCell(aCell: GridCell; aQDRect: Rect); OVERRIDE;
				{ Draw the cell's value, using the proper justification }

				PROCEDURE TCellsView.GetVisibleCells(VAR visibleCells: Rect);
				{ Return a rectangle giving the cells that are visible }

				FUNCTION  TCellsView.IsCellVisible(aCell: GridCell): BOOLEAN;
				{ Tell whether the specified cell is visible or not }

				FUNCTION TCellsView.MustIgnoreChar(ch: Char): BOOLEAN;
				{ÊTells wether a char is acceptable for the TEntryView }
				
				PROCEDURE TCellsView.PositionAtCell(aCell: GridCell);
				{ Redraw the views so that aCell is at the top left corner of the grid }

				PROCEDURE TCellsView.ReSelect(cellRegion: RgnHandle);
				{ Set the current selection to the given cells }

				PROCEDURE TCellsView.ReSelectCell(aCell: GridCell);
				{ Set the current selection to the given cell }

				PROCEDURE TCellsView.ScrollSelectionIntoView(redraw: BOOLEAN); OVERRIDE;
				{ Scroll so that at least the top left cell of the selection is visible }

				PROCEDURE TCellsView.SetCell(aCell: GridCell);

				PROCEDURE TCellsView.SetSelection(cellsToSelect: RgnHandle; extendSelection,
												  highlight, select: BOOLEAN); OVERRIDE;
				{ Set the current selections to the specified cells. Adjust the entry and
		  		  coordinate views accordingly. }

					{ Printing }

				PROCEDURE TCellsView.GetPrintExtent(VAR printExtent: VRect); OVERRIDE;
				{ Return the area to print, depending on whether the command was
					Print Selection or Print. }

					{ Clipboard handling }

				FUNCTION  TCellsView.ContainsClipType(aType: ResType): BOOLEAN; OVERRIDE;

				PROCEDURE TCellsView.WriteTableScrap(calcScrap: Handle);

				PROCEDURE TCellsView.WriteTextScrap(textScrap: Handle);

				PROCEDURE TCellsView.WriteToDeskScrap; OVERRIDE;
				
					{ Inspecting }
				
				PROCEDURE TCellsView.Fields(PROCEDURE
																		DoToField(fieldName: Str255; fieldAddr: Ptr;
																		fieldType: INTEGER)); OVERRIDE;
				
				END;									{ TCellsView }

{--------------------------------------------------------------------------------------------------}
			TRowsView			= OBJECT (TTextGridView)
			{ TRowsView is the view used to show the row numbers. Click in this view
			  to select an entire row or group of rows. }

				fTable:		TTable;

				PROCEDURE TRowsView.AdornRow(aRow: INTEGER; area: Rect); OVERRIDE;
				{ Draw a row delimiter in the given area }

				FUNCTION  TRowsView.DoMouseCommand(VAR themouse: Point; VAR info: EventInfo;
												  VAR hysteresis: Point): TCommand; OVERRIDE;

				FUNCTION  TRowsView.DoSetCursor(localPoint: Point;
											   cursorRgn: RgnHandle): BOOLEAN; OVERRIDE;

				PROCEDURE TRowsView.DrawCell(aCell: GridCell; aQDRect: Rect); OVERRIDE;
				
				PROCEDURE TRowsView.Fields(PROCEDURE
										   DoToField(fieldName: Str255; fieldAddr: Ptr;
													 fieldType: INTEGER)); OVERRIDE;
				
				PROCEDURE TRowsView.SuperViewChangedSize(delta: VPoint; invalidate: BOOLEAN);
														 OVERRIDE;
				{ When the view is scrolled to the bottom row and the window is grown,
				  force a redraw of the entire visible area }

				END;									{ TRowsView }

{--------------------------------------------------------------------------------------------------}
			TColumnsView		= OBJECT (TTextGridView)
			{ TColumnsView is used to show the column headers, represented by the letters
			  A-BL. Click in this view to select an entire column or group of columns. }

				fTable:			TTable;

				PROCEDURE TColumnsView.IRes(itsDocument: TDocument; itsSuperView: TView;
											VAR itsParams: Ptr); OVERRIDE;
				{ Create the view from a resource template}

				PROCEDURE TColumnsView.AdornCol(aCol: INTEGER; area: Rect); OVERRIDE;
				{ Draw a column delimiter in the given area }

				FUNCTION  TColumnsView.DoMouseCommand(VAR themouse: Point; VAR info: EventInfo;
													 VAR hysteresis: Point): TCommand; OVERRIDE;

				FUNCTION  TColumnsView.DoSetCursor(localPoint: Point;
												  cursorRgn: RgnHandle): BOOLEAN; OVERRIDE;

				PROCEDURE TColumnsView.DrawCell(aCell: GridCell; aQDRect: Rect); OVERRIDE;
				
				PROCEDURE TColumnsView.Fields(PROCEDURE
																			DoToField(fieldName: Str255; fieldAddr: Ptr;
																			fieldType: INTEGER)); OVERRIDE;
				
				PROCEDURE TColumnsView.ReSelect(cellRegion: RgnHandle);

				PROCEDURE TColumnsView.SuperViewChangedSize(delta: VPoint; invalidate: BOOLEAN);
															OVERRIDE;
				{ When the view is scrolled to the rightmost column and the window is grown,
				  force a redraw of the entire visible area }

				END;									{ TColumnsView }

{--------------------------------------------------------------------------------------------------}

TTablePrintHandler	= OBJECT (TStdPrintHandler)
	fCmdNumber:			CmdNumber;

	PROCEDURE TTablePrintHandler.AdornPage; OVERRIDE;
	
	PROCEDURE TTablePrintHandler.CalcViewPerPage(VAR amtPerPage: VPoint); OVERRIDE;
	
	FUNCTION TTablePrintHandler.Print(itsCmdNumber: CmdNumber; VAR proceed: BOOLEAN):	
		TCommand; OVERRIDE;
END;

{--------------------------------------------------------------------------------------------------}

TTablePrintView = OBJECT(TView)
	
	fCellsView:	TCellsView;
	
	{ÊDraw some extra lines }
	PROCEDURE TTablePrintView.Draw(area: Rect); OVERRIDE;
	
	FUNCTION  TTablePrintView.DoBreakFollowing(vhs: VHSelect; prevBreak: VCoordinate;
											VAR Automatic: BOOLEAN): VCoordinate; OVERRIDE;

	{$IFC qDebug}
	{ For debugging printing only, draw lines showing the page breaks. }
	PROCEDURE TTablePrintView.DoDrawPageBreak(vhs: VHSelect; whichBreak: INTEGER;
										 loc: VCoordinate; automatic: BOOLEAN); OVERRIDE;
	{$ENDC}

	{ Return the area to print, depending on whether the command was Print Selection
		or Print. }
	PROCEDURE TTablePrintView.GetPrintExtent(VAR printExtent: VRect); OVERRIDE;
END;

{--------------------------------------------------------------------------------------------------}

{ÊOverride to account for the constraints table that is of fixed width }

TConstraintsTablePrintView = OBJECT(TTablePrintView)
	FUNCTION  TConstraintsTablePrintView.DoBreakFollowing(vhs: VHSelect;
							prevBreak: VCoordinate; VAR Automatic: BOOLEAN): VCoordinate; OVERRIDE;
END;

{--------------------------------------------------------------------------------------------------}
			TEntryView			= OBJECT (TTEView)
			{ TEntryView uses TextEdit to display and edit the selected cell's formula. }

				fTable:					TTable;
				fTouched:				BOOLEAN;
				fTEditing:			BOOLEAN;			{ TRUE: TextEdit mode }
				fFirstEdit:			BOOLEAN;			{ TRUE: undo to previous string }
				fOldString:			FormulaString;{ previous string, for undo/redo }


				FUNCTION  TEntryView.DoKeyCommand(ch: Char; aKeyCode: INTEGER;
												 VAR info: EventInfo): TCommand; OVERRIDE;

				FUNCTION  TEntryView.DoMakeTypingCommand(ch: Char): TTETypingCommand; OVERRIDE;
				{ Actually returns a TTableTypingCommand }

				FUNCTION  TEntryView.DoMouseCommand(VAR themouse: Point; VAR info: EventInfo;
												   VAR hysteresis: Point): TCommand; OVERRIDE;

				PROCEDURE TEntryView.DoSetupMenus; OVERRIDE;

				PROCEDURE TEntryView.Draw(area: Rect); OVERRIDE;

				PROCEDURE TEntryView.EditMode(editing: BOOLEAN);
				{ Enter or leave TextEdit mode.  In TextEdit mode (fTEditing=TRUE),
				  the Undo command causes an undo of the latest TextEdit action;
				  in non-TextEdit mode, Undo brings back the previous string (fOldString) }
				
				PROCEDURE TEntryView.Fields(PROCEDURE
											DoToField(fieldName: Str255; fieldAddr: Ptr;
													  fieldType: INTEGER)); OVERRIDE;
				
				PROCEDURE TEntryView.GetAsString(VAR theString: FormulaString);
				{ Return the current text as a string }

				PROCEDURE TEntryView.InstallSelection(wasActive, beActive: BOOLEAN); OVERRIDE;

				PROCEDURE TEntryView.SetEditMode;
				{ Enter TextEdit mode and clear the current text }

				PROCEDURE TEntryView.SetToString(theString: FormulaString);
				{ Set the current text to theString }

				PROCEDURE TEntryView.SwapStrings;
				{ Exchange the current text with that saved in fOldString }

				END;									{ TEntryView }

{--------------------------------------------------------------------------------------------------}
{$IFC FALSE}

			TCoordView			= OBJECT (TView)
			{ TCoordView is the view used to display the coordinates of the cell which is
			  currently selected. }

				fTable:		TTable;

				PROCEDURE TCoordView.Draw(area: Rect); OVERRIDE;
			   { Draws the view seen in the window.  Every nonblank view MUST override this method }
				
				PROCEDURE TCoordView.Fields(PROCEDURE
											DoToField(fieldName: Str255; fieldAddr: Ptr;
													  fieldType: INTEGER)); OVERRIDE;
				
				END;									{ TCoordView }
{$ENDC}
{--------------------------------------------------------------------------------------------------}

TTableScroller 	= OBJECT (TScroller)
{ TTableScroller takes care of scrolling both the cells and the rows or columns view,
	as appropriate }

	fRowScroller:		TScroller;			{ the scroller for the rows view }
	fColumnScroller:	TScroller;			{ the scroller for the columns view }

	PROCEDURE TTableScroller.DoScroll(delta: VPoint; redraw: BOOLEAN); OVERRIDE;
	{ When the cells view scrolls, scroll the columns or rows view too }

	PROCEDURE TTableScroller.Fields(PROCEDURE
									 DoToField(fieldName: Str255; fieldAddr: Ptr;
											 fieldType: INTEGER)); OVERRIDE;
	END;									{ TTableScroller }

{--------------------------------------------------------------------------------------------------}
			TColumn 			= OBJECT (TObject)

				fNumber:			INTEGER;
				fWidth: 			INTEGER;

				PROCEDURE TColumn.IColumn(number: INTEGER);

				PROCEDURE TColumn.ReadFromDisk(theRefNum: INTEGER);

				PROCEDURE TColumn.WriteToDisk(theRefNum: INTEGER);

				PROCEDURE TColumn.ReadFromScrap(theScrap: Handle; VAR scrapOffset: LONGINT);

				PROCEDURE TColumn.WriteToScrap(theScrap: Handle; VAR scrapOffset: LONGINT);
				
				PROCEDURE TColumn.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
															 fieldType: INTEGER)); OVERRIDE;
				
				END;									{ TColumn }

{--------------------------------------------------------------------------------------------------}
			TRow				= OBJECT (TObject)

				fNumber:			INTEGER;

				PROCEDURE TRow.IRow(number: INTEGER);

				PROCEDURE TRow.ReadFromDisk(theRefNum: INTEGER);

				PROCEDURE TRow.WriteToDisk(theRefNum: INTEGER);

				PROCEDURE TRow.ReadFromScrap(theScrap: Handle; VAR scrapOffset: LONGINT);

				PROCEDURE TRow.WriteToScrap(theScrap: Handle; VAR scrapOffset: LONGINT);

				PROCEDURE TRow.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
														  fieldType: INTEGER)); OVERRIDE;
				
				END;									{ TRow }

{--------------------------------------------------------------------------------------------------}
			TCell				= OBJECT (TObject)
			{ TCell describes one element of the spreadsheet grid. }
				fDeleted:					BOOLEAN;				{ Whether the cell has been deleted }
				fTable:						TTable;					{ The table I belong to }

				fRow:							RowNumber;			{ Which row I'm in }
				fColumn:					ColumnNumber;		{ Which column I'm in }

				fKind:						KindOfCell; 		{ What kind of cell: value, empty, error }
				fValue: 					ValueType;			{ My value represented as a number }
				fValueString:			ValueString;		{ My value represented as a string, for
																					  display }
				fFormula:					FormulaString;	{ My contents as typed in by the user }

				PROCEDURE TCell.ICell(owningTable: TTable; r: RowNumber; c: ColumnNumber);
				{ Initialize the cell's fields }

				PROCEDURE TCell.CopyContents(sourceCell: TCell);
				{ Copy contents of sourceCell }

				PROCEDURE TCell.EvaluateFormula;
				{ Calculate my value by evaluating fFormula. }

				PROCEDURE TCell.GetAsString(VAR theString: FormulaString);
				{ Return my formula string }

				PROCEDURE TCell.GetValueAsString(VAR theString: Str255);
				{ Return a string representation of my value }

				PROCEDURE TCell.Invalidate;
				{ Cause a cell to be marked invalid (in need of re-drawing). }

				FUNCTION  TCell.IsEmpty: BOOLEAN;
				{ Return TRUE if I have no formula or value }

				PROCEDURE TCell.SetDeleteState(deleted: BOOLEAN);
				{ Mark a cell as deleted or not deleted }

				PROCEDURE TCell.SetToString(theString: FormulaString);
				{ Set my formula to theString and recalculate my value if necessary }

				PROCEDURE TCell.Recalculate;
				{ Re-evaluate my formula string. }

				PROCEDURE TCell.ValueToString;
				{ Fill fValueString with the string representation of my value }

				PROCEDURE TCell.ReadFromDisk(theRefNum: INTEGER);

				PROCEDURE TCell.WriteToDisk(theRefNum: INTEGER);

				PROCEDURE TCell.ReadFromScrap(theScrap: Handle; VAR scrapOffset: LONGINT);

				PROCEDURE TCell.WriteToScrap(theScrap: Handle; VAR scrapOffset: LONGINT);

						{ Inspecting }
				
				PROCEDURE TCell.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
														   fieldType: INTEGER)); OVERRIDE;
				
				PROCEDURE TCell.GetInspectorName(VAR inspectorName: Str255); OVERRIDE;

				END;									{ TCell }

{--------------------------------------------------------------------------------------------------}
			TTableSelectCommand	= OBJECT (TCellSelectCommand)
			{ TTableSelectCommand is a command object created to handle mouse movement when you
			  click in a TCellsView. }

				fTable:		TTable;

				PROCEDURE TTableSelectCommand.ITableSelectCommand(itsTable: TTable;
																itsView: TGridView; theShiftKey,
																theCmdKey: BOOLEAN);

				PROCEDURE TTableSelectCommand.AutoScroll(deltaH, deltaV: VCoordinate); OVERRIDE;
				{ Auto scroll both the cells view and the row/column view }

				PROCEDURE TTableSelectCommand.ComputeNewSelection(VAR clickedCell: GridCell);
																 OVERRIDE;

				END;									{ TTableSelectCommand }

{--------------------------------------------------------------------------------------------------}
			TRowSelector		= OBJECT (TTableSelectCommand)
			{ TRowSelector is a command object created to handle mouse movement when you click
			  in a TRowsView. }

				fCellSelector:		TTableSelectCommand; { command to handle cells view selection }

				PROCEDURE TRowSelector.IRowSelector(itsTable: TTable; itsView: TGridView;
													theShiftKey, theCmdKey: BOOLEAN);
				{ Create a TTableSelectCommand to handle selection in the cells view in parallel
				  with selection in our view, the rows view }

				PROCEDURE TRowSelector.Free; OVERRIDE;
				{ Dispose of our cell selector }

				PROCEDURE TRowSelector.AutoScroll(deltaH, deltaV: VCoordinate); OVERRIDE;
				{ Auto scroll both the row view and the cells view }

				PROCEDURE TRowSelector.ComputeAnchorCell(VAR clickedCell: GridCell); OVERRIDE;
				PROCEDURE TRowSelector.ComputeNewSelection(VAR clickedCell: GridCell); OVERRIDE;
				PROCEDURE TRowSelector.DoIt; OVERRIDE;
				{ Perform these operations for the cells view as well as for the rows view }

				FUNCTION  TRowSelector.TrackMouse(aTrackPhase: TrackPhase; VAR anchorPoint,
												 previousPoint, nextPoint: VPoint;
												 mouseDidMove: BOOLEAN): TCommand; OVERRIDE;

				END;									{ TRowSelector }

{--------------------------------------------------------------------------------------------------}
			TColumnSelector 	= OBJECT (TTableSelectCommand)
			{ TColumnSelector is a command object created to handle mouse movement when you
			  click in a TColumnsView. }

				fCellSelector:		TTableSelectCommand; { command to handle cells view selection }

				PROCEDURE TColumnSelector.IColumnSelector(itsTable: TTable;
														  itsView: TGridView; theShiftKey,
														  theCmdKey: BOOLEAN);
				{ Create a TTableSelectCommand to handle selection in the cells view in parallel with
				  selection in our view, the column headers }

				PROCEDURE TColumnSelector.Free; OVERRIDE;
				{ Dispose of our cell selector }

				PROCEDURE TColumnSelector.AutoScroll(deltaH, deltaV: VCoordinate); OVERRIDE;
				{ Auto scroll both the column headers and the cells view }

				PROCEDURE TColumnSelector.ComputeAnchorCell(VAR clickedCell: GridCell); OVERRIDE;
				PROCEDURE TColumnSelector.ComputeNewSelection(VAR clickedCell: GridCell); OVERRIDE;
				PROCEDURE TColumnSelector.DoIt; OVERRIDE;
				{ Perform these operations for the cells view as well as for the column headers }

				FUNCTION  TColumnSelector.TrackMouse(aTrackPhase: TrackPhase; VAR anchorPoint,
													previousPoint, nextPoint: VPoint;
													mouseDidMove: BOOLEAN): TCommand; OVERRIDE;

				END;									{ TColumnSelector }

{--------------------------------------------------------------------------------------------------}
			TColumnSizer		= OBJECT (TCommand)
			{ TColumnSizer is a command object created to handle mouse movement when you click
			  on the boundary between two columns. }

				fTable:		TTable;
				fCellsView: 		TCellsView;
				fLeftEdge:			INTEGER;

				fColumn:			TColumn;
				fNewWidth:			INTEGER;
				fOldWidth:			INTEGER;			{ remember previous width for Undo }

				PROCEDURE TColumnSizer.IColumnSizer(itsTable: TTable; c: ColumnNumber);

				PROCEDURE TColumnSizer.AutoScroll(deltaH, deltaV: VCoordinate); OVERRIDE;
				{ Override to do nothing, i.e. suppress autoscrolling while resizing }

				FUNCTION  TColumnSizer.TrackMouse(aTrackPhase: TrackPhase; VAR anchorPoint,
												 previousPoint, nextPoint: VPoint;
												 mouseDidMove: BOOLEAN): TCommand; OVERRIDE;

				PROCEDURE TColumnSizer.TrackFeedback(anchorPoint, nextPoint: VPoint; turnItOn,
													 mouseDidMove: BOOLEAN); OVERRIDE;

				PROCEDURE TColumnSizer.TrackConstrain(anchorPoint, previousPoint: VPoint;
													  VAR nextPoint: VPoint); OVERRIDE;

				PROCEDURE TColumnSizer.DoIt; OVERRIDE;

				PROCEDURE TColumnSizer.UndoIt; OVERRIDE;

				PROCEDURE TColumnSizer.RedoIt; OVERRIDE;

				PROCEDURE TColumnSizer.SetColumnWidth(newWidth: INTEGER);
				
				PROCEDURE TColumnSizer.Fields(PROCEDURE
											  DoToField(fieldName: Str255; fieldAddr: Ptr;
														fieldType: INTEGER)); OVERRIDE;
				
				END;									{ TColumnSizer }

{--------------------------------------------------------------------------------------------------}
			TTableTypingCommand	= OBJECT (TTETypingCommand)
			{ We define our own typing command in order to remember which cell the typing was
			  performed in. Then if the user makes another selection we can undo/redo the
			  correct cell. }

				fCellsView: 		TCellsView;
				fTargetCell:		GridCell;			{ cell selected when command was created }

				PROCEDURE TTableTypingCommand.ITETypingCommand(itsTEView: TTEView;
															  itsFirstChar: Char); OVERRIDE;
				{ Initialize the command object. Save the current cell selection for later
				  Undo/Redo }

				PROCEDURE TTableTypingCommand.AddCharacter(aChar: Char); OVERRIDE;
				{ Overridden to keep text visible when it overflows the entry view's box }

				PROCEDURE TTableTypingCommand.UndoIt; OVERRIDE;
				{ Undo the typing in the target cell }

				PROCEDURE TTableTypingCommand.RedoIt; OVERRIDE;
				{ Redo the typing in the target cell }
				
				PROCEDURE TTableTypingCommand.Fields(PROCEDURE
													DoToField(fieldName: Str255; fieldAddr: Ptr;
															  fieldType: INTEGER)); OVERRIDE;
				
				END;									{ TTableTypingCommand }

{--------------------------------------------------------------------------------------------------}
			TCellEditCommand	= OBJECT (TCommand)
			{ TCellEditCommand is a command object created to handle the cCopy, cCut, and cClear
			  menu commands. }

				fTable:					TTable;
				fSelection: 		RgnHandle;			{ cells selected when command was created }

				PROCEDURE TCellEditCommand.ICellEditCommand(itsTable: TTable; 
						itsCommand: INTEGER);
				{ Initialize the command object. Save the current cell selection for later
				  Undo/Redo }

				PROCEDURE TCellEditCommand.Free; OVERRIDE;
				{ Clean up our stuff }

				PROCEDURE TCellEditCommand.DoIt; OVERRIDE;
				{ Edit the currently selected cells }

				PROCEDURE TCellEditCommand.UndoIt; OVERRIDE;
				{ Undo the edit of the cells }

				PROCEDURE TCellEditCommand.RedoIt; OVERRIDE;
				{ Redo the edit of the cells }

				PROCEDURE TCellEditCommand.Commit; OVERRIDE;
				{ Commit the edit of the cells }

				PROCEDURE TCellEditCommand.CopySelection;
				{ Copy the currently selected cell(s) into the clipboard }

				PROCEDURE TCellEditCommand.DeleteSelection;
				{ Delete the currently selected cell(s) }

				PROCEDURE TCellEditCommand.RestoreSelection;
				{ Restore the deleted cells }

				PROCEDURE TCellEditCommand.ReSelect;
				{ Change the selection back to what it was when this command was created }
				
				PROCEDURE TCellEditCommand.Fields(PROCEDURE
												  DoToField(fieldName: Str255; fieldAddr: Ptr;
															fieldType: INTEGER)); OVERRIDE;
				
			END;									{ TCellEditCommand }

{--------------------------------------------------------------------------------------------------}
			TCellPasteCommand	= OBJECT (TCommand)
			{ TCellPasteCommand is a command object created to handle the cPaste menu
				command. }
				
				fClipContainsText: BOOLEAN;
				fClipTextHandle:	Handle;
				fClipTextLength:	LONGINT;
				fClipTable:				TTable;
				fTable:						TTable;
				fSelection: 			RgnHandle;		{ cells selected when command was created }
				fReplacedCells: 	TList;				{ the cells we pasted over }

				PROCEDURE TCellPasteCommand.ICellPasteCommand(itsTable: TTable);
				{ Initialize the command object }

				PROCEDURE TCellPasteCommand.Free; OVERRIDE;
				{ We don' need this command no more }

				PROCEDURE TCellPasteCommand.DoIt; OVERRIDE;
				{ Paste to the currently selected cells. Save this selection for Undo/Redo. }

				PROCEDURE TCellPasteCommand.UndoIt; OVERRIDE;
				{ Undo the paste of the cells }

				PROCEDURE TCellPasteCommand.RedoIt; OVERRIDE;
				{ Redo the paste of the cells }

				PROCEDURE TCellPasteCommand.UpdateViews;
				{ Redisplay the affected cells }
				
				PROCEDURE TCellPasteCommand.Fields(PROCEDURE
												 				DoToField(fieldName: Str255; fieldAddr: Ptr;
																fieldType: INTEGER)); OVERRIDE;
				
			END;									{ TCellPasteCommand }

{ ---------------------------------------------------------------------------------- }	

VAR
		gDefaultFormat: 	FormatRecord;					{ default cell format }
		gClipFormat:			FormatRecord;					{ÊUsed in the Clip window }

{ ---------------------------------------------------------------------------------- }	
	{ Perform initialization of this unit. To be called once, at app. startup }
	
	PROCEDURE InitTables;

{ ---------------------------------------------------------------------------------- }	
	{ÊAllows Fields procedures to output the content of a format record }
	
	PROCEDURE FormatFields (aTitle: Str255; VAR aFormat: FormatRecord; PROCEDURE
								DoToField(fieldName: Str255; fieldAddr: Ptr; fieldType: INTEGER));

	
	
	
	IMPLEMENTATION
	
		{$I UTable.inc1.p}
	
END.
