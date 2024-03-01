{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.

	Created 15/12/89
}

UNIT UPercDoneBarView;

INTERFACE

USES
	{ � MacApp stuff }
	UMacApp;

TYPE

	TPercDoneBarView = OBJECT(TView)
		
		{�variabili che servono a decidere in quante parti dividere
			il percentage done bar }
		fOperationsToBeDone,
		fOperationsAlreadyDone: integer;
		
		{ variabile di lavoro dalla procedura che disegna il percentagedonebar. }
		fWorkRect: Rect;
		
		{�L'area del PercDoneBar }
		fExtent: Rect;
		
		{�la distanza in pixel da scurire sul perc.done bar per ogni 
			operazione ultimata; settato da PutUpWDlog }
		fLengthOfAnOperation: Extended;

		
		PROCEDURE TPercDoneBarView.IPercDoneBarView(numOfOperations: INTEGER);
		
		PROCEDURE TPercDoneBarView.OperationDone;
		
		PROCEDURE TPercDoneBarView.Draw(area: Rect); OVERRIDE;
		
	END;
	
	{ We need to call this to avoid the linker dead-stripping this class }
	PROCEDURE InitPercDoneBarView;

IMPLEMENTATION

	{$I UPercDoneBarView.inc1.p}
	
END.
