{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}

{�---------------------------------------------------------------------------------- }
{$S AInit}

PROCEDURE InitPercDoneBarView;
BEGIN
	IF gDeadStripSuppression THEN
		IF Member(TObject(NIL), TPercDoneBarView) THEN;
END;

{�---------------------------------------------------------------------------------- }
{$S Fit}

PROCEDURE TPercDoneBarView.IPercDoneBarView(numOfOperations: INTEGER);
BEGIN
	fOperationsToBeDone := numOfOperations;
	fOperationsAlreadyDone := 0;
	
	{$PUSH} {$H-}
	SetRect(fExtent, 0, 0, ORD(fSize.h), ORD(fSize.v));
	fWorkRect := fExtent;
	InsetRect(fWorkRect, 1, 1);
	WITH fWorkRect DO
		fLengthOfAnOperation := (right - left) / fOperationsToBeDone;
	{$POP}
END;

{�---------------------------------------------------------------------------------- }
{$S Fit}

PROCEDURE TPercDoneBarView.OperationDone;
VAR aRect: Rect;
BEGIN
	fOperationsAlreadyDone := fOperationsAlreadyDone + 1;
	
	IF Focus THEN BEGIN
		aRect := fExtent;		{�the parameter isn't used, but it is cleaner to initialize it
													anyway }
		Draw(aRect);
	END;
END;

{�---------------------------------------------------------------------------------- }
{$S Fit}

PROCEDURE TPercDoneBarView.Draw(area: Rect); OVERRIDE;
VAR tempRect: Rect;
BEGIN					{ DrawPercentageDoneBar }
	{�Disegna il contorno nero della barra }
	tempRect := fExtent;
	PenPat(black);
	FrameRect(tempRect);

	{ calcola il rettangolo da scurire }
	{$PUSH} {$H-}
	WITH fWorkRect DO
		right := round(left + fOperationsAlreadyDone * fLengthOfAnOperation);
	{$POP}
	
	{ disegna la parte scura della barra. Se dovessero esserci problemi
		con la dimensione dello stack, qui si potrebbe usare il parametro "area" come
		variabile locale; usare una variabile apposta pero' e' piu' chiaro. }
	tempRect := fWorkRect;
	PenPat(dkGray);
	PaintRect(tempRect);
END;			{ DrawPercentageDoneBar }