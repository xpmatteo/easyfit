{ 
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	This Unit is based on Apple's UDialog.p from MacApp.
	
	UDialog.p is Copyright © 1986-1989 by Apple Computer, Inc. All rights reserved.
	Changes are Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}

UNIT URealText;

INTERFACE

USES
	SANE, UMacApp, UDialog, UTEView;

CONST
	{ÊThe number of significant digits in a TRealText }
	kRealTextPrecision = 8;

TYPE
	
	TRealText 		= OBJECT (TEditText)

		fMinimum:			EXTENDED;
		fMaximum:			EXTENDED;
	
		PROCEDURE TRealText.IRealText(itsSuperView: TView; itsLocation, itsSize: VPoint;
											itsValue, itsMinimum, itsMaximum: EXTENDED);
	
		PROCEDURE TRealText.IRes(itsDocument: TDocument; itsSuperView: TView;
									 VAR itsParams: Ptr); OVERRIDE;
	
		FUNCTION  TRealText.GetValue: EXTENDED;
	
		PROCEDURE TRealText.SetValue(newValue: EXTENDED; redraw: BOOLEAN);
	
		FUNCTION  TRealText.Validate: LONGINT; OVERRIDE;

		PROCEDURE TRealText.Fields(PROCEDURE
									 DoToField(fieldName: Str255; fieldAddr: Ptr;
												 fieldType: INTEGER)); OVERRIDE;
	END;

	{ÊTo be called once, at app startup }
	PROCEDURE InitRealText;

IMPLEMENTATION

	{$I URealText.inc1.p}
	
END.