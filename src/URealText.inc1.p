{ 
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	This Unit is based on Apple's UDialog.p from MacApp.
	
	UDialog.p is Copyright © 1986-1989 by Apple Computer, Inc. All rights reserved.
	Changes are Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}

{ ------------------------------------------------------------------------------------ }
{ÊC external procedures }

PROCEDURE Num2NiceStr(n: EXTENDED; s: Str255; precision: INTEGER); C; EXTERNAL;

{ ------------------------------------------------------------------------------------ }
{$S AInit}

PROCEDURE InitRealText;
BEGIN
	IF gDeadStripSuppression THEN
		IF Member(TObject(NIL), TRealText) THEN;
END;

{--------------------------------------------------------------------------------------------------}
{$S DlgOpen}

PROCEDURE TRealText.IRealText(itsSuperView: TView; itsLocation, itsSize: VPoint; 
																itsValue, itsMinimum, itsMaximum: EXTENDED);
VAR aString: Str255;
BEGIN
	IEditText(itsSuperView, itsLocation, itsSize, 255);
	{$IFC qDebug}
	IF itsMinimum > itsMaximum THEN
		WRITELN('Minimum value specified is greater than maximum for TRealText.');
	{$ENDC}
	fMinimum := itsMinimum;
	fMaximum := itsMaximum;
	Num2NiceStr(itsValue, aString, kRealTextPrecision);
	SetText(aString, kDontRedraw);
END;

{--------------------------------------------------------------------------------------------------}
{$S DlgOpen}

PROCEDURE TRealText.IRes(itsDocument: TDocument; itsSuperView: TView;
													VAR itsParams: Ptr); OVERRIDE;
BEGIN
	INHERITED IRes(NIL, itsSuperView, itsParams);

		{ÊSet default values for our fields }
		
	SetText('', kDontRedraw);		{Êno initial value }
	fMinimum := -Inf;						{ÊAny value allowed }
	fMaximum := Inf;						{Ê idem  }
END;

{--------------------------------------------------------------------------------------------------}
{$S DlgRes}

FUNCTION TRealText.GetValue: EXTENDED;
VAR aString:			Str255;
	
	{ÊThis is useful for Italian keyboards that have a comma instead of dot
		on the numeric keypad }
	PROCEDURE SubstituteCommas(VAR s: Str255);
	VAR i: INTEGER;
	BEGIN
		FOR i := 1 TO Length(s) DO
			IF s[i] = ',' THEN
				s[i] := '.';
	END;
	
BEGIN
	GetText(aString);
	SubstituteCommas(aString);
	{$IFC qDebug}
	{ÊWriteln('TRealText.GetValue: after substituting commas we have ',aString); }
	{$ENDC}
	GetValue := Str2Num(aString);
END;

{--------------------------------------------------------------------------------------------------}
{$S DlgNonRes}

PROCEDURE TRealText.SetValue(newValue: EXTENDED; redraw: BOOLEAN);
VAR aString:			Str255;

	FUNCTION EMax(a, b: EXTENDED): EXTENDED;
	BEGIN
		IF a < b THEN
			EMax := b
		ELSE
			EMax := a;
	END;

	FUNCTION EMin(a, b: EXTENDED): EXTENDED;
	BEGIN
		IF a > b THEN
			EMin := b
		ELSE
			EMin := a;
	END;
	
BEGIN
	{$PUSH}Ê{$H-} {ÊSince EMin and EMax cannot relocate the heap }
	newValue := EMax(fMinimum, EMin(fMaximum, newValue));
	{$POP}
	Num2NiceStr(newValue, aString, kRealTextPrecision);
	SetText(aString, redraw);
END;

{--------------------------------------------------------------------------------------------------}
{$S DlgNonRes}

FUNCTION TRealText.Validate: LONGINT; OVERRIDE;
VAR theString:			Str255;
		theValue:				Extended;
BEGIN
	Validate := kValidValue;

	theValue := GetValue;

	IF (ClassExtended(theValue) = QNan) THEN
		Validate := kInvalidValue
	ELSE IF theValue < fMinimum THEN
		Validate := kValueTooSmall
	ELSE IF theValue > fMaximum THEN
		Validate := kValueTooLarge;
END;

{--------------------------------------------------------------------------------------------------}
{$S DlgFields}

PROCEDURE TRealText.Fields(PROCEDURE DoToField(fieldName: Str255; fieldAddr: Ptr;
												 fieldType: INTEGER)); OVERRIDE;
BEGIN
	DoToField('TRealText', NIL, bClass);
	DoToField('fMinimum', @fMinimum, bExtended);
	DoToField('fMaximum', @fMaximum, bExtended);
	INHERITED Fields(DoToField);
END;
