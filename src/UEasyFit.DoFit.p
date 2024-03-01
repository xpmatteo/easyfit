{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	
	
	Change history:
		9/1/90: make application beep if any datacheck fails.  We should
			give more context to the user, showing him which window has an error and where.
			We will do it some day.
		18/1/90: Wrote PurgeMissings and RestoreMissings.
		19/1/90: Various small modifications to FillStdResWindow
			Added CallComputeWeights code
		20/1/90: Added FillWeightsWIndow
		25/1/90: Added call to force fExpDataTable, FWeightsTable and fParamsTable
			to compute the value of the current cell.  It should no longer be necesssary
			to strike return before calling fit.
		26/1/90: Aggiunto il metodo GetRealBounds in TTable, e relative chiamate in 
			DoFit; Aggiunta ClearStdResiduals a DoFit, con relative chiamate.  Infatti se
			il fitting fallisce NON ci devono essere eventuali vecchi valori nella
			stdreswindow
		28/1/90: Spostato PrintSmallHeader in DoFit, invece che in callfit.  Cosi'
			manda il suo messaggino anche se il peeling fallisce.
		29/1/90: Eliminato GetRealBounds.  Non riuscivo a farlo andare.
			Aggiunto test per selezione vuota.
			Spostata la free di WorkingDlog al di la' della label 99.  Se no, invece di
			abortire si piantava...
}

{�--------------------------------------------------------------------------------- }

CONST
	{�This mus be the max length required by the cuts vector; remember that
		if new models are added that have more than 4 exponentials, this
		should be raised. Three would have been enough, but we are willing to
		be a bit generous and play safe in case a four-exps model is introduced
		and we forget about this! }
	kMaxCutPoints = 4;

TYPE
	PeelingArray = ARRAY [0..kMaxCutPoints] OF LONGINT;
	PPeelingArray = ^PeelingArray;

{�--------------------------------------------------------------------------------- }

{�C external functions }

	FUNCTION 	fit(X								: EDataPtr;
								Y								: EDataPtr;
								NObservations		: LONGINT;
								params					: ParamsPtr;
								NParams					: LONGINT;
								model						: LONGINT;
								useWeights			: BOOLEAN;
								{$IFC qELS} useELS: BOOLEAN;{$ENDC}
								weights					: EDataPtr;
								lambda					: EXTENDED;
								maxIterations		: LONGINT;
{$IFC qConstraints}
								low_constr			: ParamsPtr;
								hi_constr				: ParamsPtr;
{$ENDC}
								theSubject			: LONGINT;
								fullOutput			: BOOLEAN;
								ReComputeWeights: ProcPtr;
								mustRefreshPlots: BOOLEAN): LONGINT; C; EXTERNAL;
	
	PROCEDURE FitErrHdl(nParams: LONGINT); C; EXTERNAL;
	PROCEDURE FitClearVars; C; EXTERNAL;
	
	FUNCTION CallPeel(X:											EDataPtr;
										Y:											EDataPtr;
										NObservations:					LONGINT;
										params:									PExtended;
										sqrtWeights:						EDataPtr;
										weightsOption:					LONGINT;
										modelNumber:						LONGINT;
										cutPoint:								PPeelingArray): LONGINT; 
								C; EXTERNAL;

	PROCEDURE ComputeEstimatedY(X:							EDataPtr;
															NObservations:	INTEGER;
															params:					EDataPtr;
															model:					ProcPtr;
															EstimatedY:			PExtended); C; EXTERNAL;

	PROCEDURE ComputeStdResiduals(Y							: EDataPtr;
																NObservations	: INTEGER;
																stdResiduals	: PExtended); 
																	C; EXTERNAL;

	PROCEDURE ComputePercentageResiduals(Y:										EDataPtr;
																			 NObservations:				INTEGER;
																			 PercentualResiduals:	PExtended);
																	C; EXTERNAL;
	
	PROCEDURE Num2PercentageStr(e: EXTENDED; s: Str255); C; EXTERNAL;
	
	PROCEDURE MyC2Pstr(cString, pString: Str255); C; EXTERNAL;
	
	PROCEDURE copyVector(dest, source: PExtended; len: INTEGER); C; EXTERNAL;

	PROCEDURE normalizeWeights(w: EDataPtr; len: INTEGER); C; EXTERNAL;

	FUNCTION computeWeights1OverObs(y: EDataPtr; len: INTEGER; w: EDataPtr):
		LONGINT; C; EXTERNAL; 

	FUNCTION computeWeights1OverSqObs(y: EDataPtr; len: INTEGER; w: EDataPtr):
		LONGINT; C; EXTERNAL; 

	FUNCTION ComputeWeights1OverEstimated(x: PExtended; len: INTEGER;
		p: PExtended; model: ProcPtr; w: PExtended): LONGINT; C; EXTERNAL;
		
	FUNCTION ComputeWeights1OverSqEstimated(x: PExtended; len: INTEGER;
		p: PExtended; model: ProcPtr; w: PExtended): LONGINT; C; EXTERNAL;
		
	PROCEDURE CallSprintfWith5Strings(VAR s: Str255; format: Str255; 
		p1, p2, p3, p4, p5: Str255); C; EXTERNAL;

	PROCEDURE CallSprintfWith6Numbers(VAR s: Str255; format: Str255; 
		p1: INTEGER; p2, p3, p4, p5, p6: EXTENDED); C; EXTERNAL;

	PROCEDURE print_pharmacokin_data(	X, Y: EDataPtr; NObservations: INTEGER;
																		params: PExtended; modelNumber: INTEGER;
																		dose: EXTENDED); C; EXTERNAL;

	PROCEDURE printVector(v: PExtended; start, stop: LONGINT); C; EXTERNAL;

	PROCEDURE CallXMDLName(xmdl: Handle); C; EXTERNAL;
	FUNCTION CallXMDLPeeling(xmdl: Handle;
													 X: EDataPtr;
													 Y: EDataPtr;
													 NObservations: LONGINT;
													 params: PExtended;
													 sqrtWeights: EDataPtr;
													 weightsOption: LONGINT): LONGINT; C; EXTERNAL;
	PROCEDURE CallXMDLFinalComputations(xmdl: Handle;
													 X: EDataPtr;
													 Y: EDataPtr;
													 sqrtWeights: EDataPtr;
													 NObservations: LONGINT;
													 params: PExtended;
													 weightsOption: LONGINT;
													 dose: EXTENDED;
													 subject: LONGINT); C; EXTERNAL;
													 
{ ---------------------------------------------------------------------------------- }
{$S Fit}

PROCEDURE MessagesWriteln(cString: Str255);
VAR pString: Str255;
BEGIN
	IF pMessagesWindow <> NIL THEN BEGIN
		MyC2Pstr(cString, pString);
		pMessagesWindow.Writeln(pString);
	END;
END;

{ ---------------------------------------------------------------------------------- }
{$S Fit}

PROCEDURE MessagesWrite(cString: Str255);
VAR pString: Str255;
BEGIN
	IF pMessagesWindow <> NIL THEN BEGIN
		MyC2Pstr(cString, pString);
		pMessagesWindow.Write(pString);
	END;
END;

{ ---------------------------------------------------------------------------------- }
{$S Fit}

PROCEDURE MessagesNewLine;
BEGIN
	IF pMessagesWindow <> NIL THEN
		pMessagesWindow.NewLine;
END;

{ ---------------------------------------------------------------------------------- }
{$S Fit}

PROCEDURE MessagesSynch;
BEGIN
	IF pMessagesWindow <> NIL THEN
		pMessagesWindow.Synch;
END;

{ ---------------------------------------------------------------------------------- }
{$S Fit}

PROCEDURE SetWDlogText(pString: Str255);
BEGIN
	IF pWorkingDialog <> NIL THEN
		pWorkingDialog.SetText(pString);
END;

{ ---------------------------------------------------------------------------------- }
{$S CallFit}

FUNCTION PollEvent: BOOLEAN;
BEGIN
	IF pWorkingDialog <> NIL THEN
		PollEvent := pWorkingDialog.PollEvent
	ELSE
		PollEvent := FALSE;
		
	{ ??? Maybe we should check for the user to be pressing cmd-. when
		pWorkingDlog is NIL. So we could know if the user wants to abort
		a computation even if there is no Working Dialog opened. This could
		happen when drawing in the data + function plot. }
END;

{ ---------------------------------------------------------------------------------- }
{$S Fit}

{�This is meant to be called from C, that doesn't know about objects and methods }

PROCEDURE RefreshPlots(subject: LONGINT; params: PExtended; NParams: LONGINT);
VAR anEasyFitDocument: TEasyFitDocument;
BEGIN
	anEasyFitDocument := TEasyFitDocument(gDocList.First);
	IF anEasyFitDocument <> NIL THEN BEGIN
		anEasyFitDocument.fParamsTable.ArrayToColumn(subject, params, NParams);
		anEasyFitDocument.fDataAndFuncPlotWindow.ShowSubject(subject, kRedraw);
	END;
END;

{ ---------------------------------------------------------------------------------- }
{$S Fit}

FUNCTION AskMoreIterations(VAR howMany:integer): BOOLEAN;
BEGIN
	AskMoreIterations := FALSE;
END;

{�----------------------------------------------------------------------------------- }
{$IFC qDebug}
{$S ADebug}
{ output the content of an array }

PROCEDURE WriteEDataArray(s: Str255; a: EDataArray; first, last: INTEGER);
VAR i: INTEGER;
BEGIN
	Writeln(s);
	FOR i := first TO last DO
		Writeln('  el.', i, ' = ', a[i]);
END;
{$ENDC}

{�----------------------------------------------------------------------------------- }
{$S CallFit}

PROCEDURE TEasyFitDocument.DoFit;
LABEL
	9,	{�Used to skip fitting a subject if something goes wrong }
	99, { indica la parte finale della procedura, dove si fa
				un pochino di bookkeeping }
	100; 	{�Usata nel Fit error handler. Come 99, solo che salta alla istruzione
					dopo la Success }
CONST
	{ I codici di errore rest. dalla funzione "fit".  
		Controlla sempre la consistenza con i codici definiti in
		FIT.H !! }
	noError = 0;
	insufficientMemory = 1;
	tooManyIterations = 2;
	badInitialEstimate = 3;
	tooFewObservations = 4;
	nullObservation = 5;
	overflowInWeights = 6;
	noSolutions = 11;
	userInterruptedFit = 18;
	invalidInitialEstimate = 19;
	constraintsLoopError = 20;
	sumIsNan = 21;
	errorInReComputeWeights = 22;
	peelingFailed = 23;
	noPeelingFuncAvailable = 24;
	
	kParamValuesWhenStopped = 'Parameter values when stopped:';
	kSeparationLine = '====================================';
	
VAR
	selection:					SubjectSet;
	theCurrentSubject:	INTEGER;
	currSubjectStr:			Str255;
	numberOfOperations,
	sizeOfSelection:		INTEGER;
	peelResult:					INTEGER;
	NObservations:			INTEGER;
	theNumberOfParams:	INTEGER;
	fi:									FailInfo;
	aWorkingDlog:				TWorkingDialog;
	cuts:								PPeelingArray;
	s:									Str255;						{ Scratch string }
	i:									INTEGER;					{ Scratch FOR index }
	bound:							INTEGER;					{�Nobservations, piu' i missing }
	aRect:							Rect;
	userCancelledFit:		BOOLEAN;
	XMDLFailed:					BOOLEAN;
	mustPrintResults:		BOOLEAN;
	mustCopyDataToTables:		BOOLEAN;
	ReComputeWeights:		ProcPtr;
	oldXMDLState:				BOOLEAN;
	
	{�Print peeling information }
	PROCEDURE PrintCutPoints;
	BEGIN
		IF fModelNumber IN [kTwoExpPlus, kTwoExpMinus] THEN BEGIN
			{$IFC qDebug}
			Writeln('PrintCutPoints: cuts are ', cuts^[0]:1, ' and ', cuts^[1]:1, ' and ',
				cuts^[2]:1);
			{$ENDC}
			
			NumToString(cuts^[0], s);
			fMessagesWindow.Write(Concat('Subdividing experimental points as 1-', s));
			NumToString(cuts^[0] + 1, s);
			fMessagesWindow.Write(Concat(', ', s));
			NumToString(NObservations, s);
			fMessagesWindow.Writeln(Concat('-', s, '.'));
		END
		ELSE IF fModelNumber IN [kThreeExpPlus, kThreeExpMinus] THEN BEGIN
			{$IFC qDebug}
			Writeln('PrintCutPoints: cuts are ', cuts^[0]:1, ' and ', cuts^[1]:1, ' and ',
				cuts^[2]:1, ' and ', cuts^[3]:1);
			{$ENDC}
			
			NumToString(cuts^[0], s);
			fMessagesWindow.Write(Concat('Subdividing experimental points as 1-', s));
			NumToString(cuts^[0] + 1, s);
			fMessagesWindow.Write(Concat(', ', s));
			NumToString(cuts^[1], s);
			fMessagesWindow.Write(Concat('-', s));
			NumToString(cuts^[1] + 1, s);
			fMessagesWindow.Write(Concat(', ', s));
			NumToString(NObservations, s);
			fMessagesWindow.Writeln(Concat('-', s, '.'));
		END;
	END;
		
	{�Take away missings from both gX and gY; remeber what goes where in
		gPlaces; set NObservations }
	PROCEDURE PurgeMissings;
	VAR i:			INTEGER;		{�Scratch index }
			placeCount: INTEGER;
	BEGIN
		placeCount := 0;
		FOR i := 1 TO bound DO
			IF (ClassExtended(gX^[i]) <> QNan) & (ClassExtended(gY^[i]) <> QNan) THEN BEGIN
				placeCount := placeCount + 1;
				IF i <> placeCount THEN BEGIN	{�This test is for efficiency }
					gX^[placeCount] := gX^[i];
					gY^[placeCount] := gY^[i];
				END;
				gPlaces[placeCount] := i;
			END;
			
		NObservations := placeCount;
	END;
	
	{�Do the opposite operation of PurgeMissings }
	PROCEDURE RestoreMissings(x: EDataPtr);
	VAR i:						INTEGER;		{�Scratch index }
			workVector:		EDataPtr;
	BEGIN
		workVector := EDataPtr(NewPermPtr(sizeof(EXTENDED) * bound));
		FailNil(workVector);
		{$IFC qDebug}
		{		
			FOR i := 1 TO bound DO
				writeln('Rest.Missings: At start: x^[i] =', x^[i]);
			FOR i := 1 TO NObservations DO
				writeln('gPlaces[i] =', gPlaces[i]);
		}
		{$ENDC}

		FOR i := 1 TO bound DO
			workVector^[i] := gMissing;
		
		FOR i := 1 TO NObservations DO
			workVector^[gPlaces[i]] := x^[i];

		FOR i := 1 TO bound DO
			x^[i] := workVector^[i];
		
		{$IFC qDebug}
		{
		FOR i := 1 TO bound DO
			writeln('Rest.Missings: At end: x^[i] =', x^[i]);
		}
		{$ENDC}
		DisposPtr(Ptr(workVector));
	END;
	
	PROCEDURE FillWeightsWindow;
	VAR i:				INTEGER;
			tmp:			EXTENDED;
	BEGIN
		FOR i := 1 to NObservations DO BEGIN
			tmp := gSqrtWeights^[i];
			gSqrtWeights^[i] := tmp * tmp;
		END;
		
		RestoreMissings(gSqrtWeights);
		fWeightsTable.ArrayToColumn(theCurrentSubject, PExtended(gSqrtWeights), bound);
	END;
	
	
	PROCEDURE ClearStdResWindow;
	VAR baseColumn:		INTEGER;
			workVector:		PExtended;
			i:						INTEGER;
	BEGIN
		workVector := PExtended(NewPermPtr(sizeof(EXTENDED) * bound));
		FailNil(workVector);
		
		{ calcola la prima colonna per questo soggetto }
		baseColumn := (theCurrentSubject-1) * kStdResColsPerSubj;

		{�Poni a 0.0 tutto workvector }
		FOR i := 0 TO (bound-1) DO
			SetIthElement(workVector, i, 0.0);
			
		{�Azzera tutte le colonne relative al nostro soggetto }
		FOR i := kXCol TO kStdPercResiduals DO
			fStdResTable.ArrayToColumn(baseColumn + i, workVector, bound);

		DisposPtr(Ptr(workVector));
	END;
	
	PROCEDURE FillStdResWindow;
	VAR baseColumn:		INTEGER;
			workVector:		PExtended;
			workVector2:	PExtended;
	BEGIN
		{ workVector actually is only "bound" long }
		workVector := PExtended(NewPermPtr(sizeof(EXTENDED) * bound));
		FailNil(workVector);
		workVector2 := PExtended(NewPermPtr(sizeof(EXTENDED) * bound));
		FailNil(workVector2);
		
		{ calcola la prima colonna per questo soggetto }
		baseColumn := (theCurrentSubject-1) * kStdResColsPerSubj;
	
		{ copia le X nella colonna appropriata, prendendo i valori 
			dalla ExpDataTable }
		fExpDataTable.ColumnToArray(kXCol, workVector);
		fStdResTable.ArrayToColumn(baseColumn + kXCol, workVector, bound);

		{ copia le Y osservate }
		fExpDataTable.ColumnToArray(theCurrentSubject, workVector);
		fStdResTable.ArrayToColumn(baseColumn + kObservedY, workVector, bound);

		{�riempi la colonna delle Y calcolate }
			ComputeEstimatedY(gX,
												NObservations,
												@gParams,
												get_ModelFunc(fModelNumber),
												workVector);
	
			{ Copia il valore di workVector in workVector2 perche' ci serve per
				i residui standardizzati; RestoreMissings ovviamente lo sporca }
			copyVector(workVector2, workVector, bound);

			RestoreMissings(EDataPtr(workVector2));
			fStdResTable.ArrayToColumn(baseColumn + kEstimatedY, workVector2, bound);

		{ riempi la colonna dei residui standard }
			ComputeStdResiduals(gY,
													NObservations,
													workVector);
			
			{ Copia il valore di workVector in workVector2 perche' ci serve per
				i residui standardizzati percentuali; RestoreMissings ovviamente lo sporca }
			copyVector(workVector2, workVector, bound);
			
			RestoreMissings(EDataPtr(workVector));
			fStdResTable.ArrayToColumn(baseColumn + kStdResiduals, workVector, bound);
		
		{ riempi la colonna dei residui standard % }
		ComputePercentageResiduals(gY,
															 NObservations,
															 workVector2);
		RestoreMissings(EDataPtr(workVector2));
		fStdResTable.ArrayToColumn(baseColumn + kStdPercResiduals, workVector2, bound);
		
		DisposPtr(Ptr(workVector));
		DisposPtr(Ptr(workVector2));
	END;		{ FillStdResWindow }
	
	
	PROCEDURE WriteStdResOnMessages;
	{
		Write the contents of the std.res. window for this subject on the
		messages window.
	}
	VAR x, y, yCalc, stdRes, stdResPerc:	EXTENDED;
			i: INTEGER;
			s: Str255;
			sX, sY, sYCalc, sStdRes, sStdResPerc: STRING[12];
			baseColumn: INTEGER;
	BEGIN
		fMessagesWindow.NewLine;
		fMessagesWindow.Writeln('Estimated Y and standardized residuals:');
		{ Write intestation of columns }
		sX := 'X';
		sY := 'Obs. Y';
		sYCalc := 'Est. Y';
		sStdRes := 'Std. Res.';
		sStdResPerc := 'Std. % Res.';
		CallSprintfWith5Strings(s, '%14P %13P %13P %13P %11P',
			sX, sY, sYCalc, sStdRes, sStdResPerc);
		fMessagesWindow.Writeln(s);
		fMessagesWindow.Writeln('--------------------------------------------------------------------');
		
		{ calcola la prima colonna nella finestra std. res. per questo soggetto }
		baseColumn := (theCurrentSubject-1) * kStdResColsPerSubj;

		FOR i := 1 TO bound DO BEGIN
			x := fExpDataTable.GetValue(i, 0);
			y := fExpDataTable.GetValue(i, theCurrentSubject);
			yCalc := fStdResTable.GetValue(i, baseColumn + kEstimatedY);
			IF (ClassExtended(x) <> QNan) AND (ClassExtended(y) <> QNan) THEN BEGIN
				stdRes := fStdResTable.GetValue(i, baseColumn + kStdResiduals);
				stdResPerc := fStdResTable.GetValue(i, baseColumn + kStdPercResiduals);
	
				CallSprintfWith6Numbers(s, '%2d) % .3E % .6E % .6E % .6E % 11.2f',
																i, x, y, yCalc, stdRes, stdResPerc);
				fMessagesWindow.Writeln(s);
			END;
		END;
		
		fMessagesWindow.Synch;
	END;
	
	
	
	PROCEDURE CallFit(VAR userCancel, mustCopyDataToTables, mustPrintResults: BOOLEAN);
	{
		Se esce perche' l'utente ha dato un interrupt durante 
		l'esecuzione, rest. true.
	}
	VAR
		fitRes					: Longint;
		aParamsPtr			: ParamsPtr;
		ignoredInt			: INTEGER;
		tempLambda			:	EXTENDED;
			
	BEGIN							{ CallFit}
		{$IFC qDebug}
			Writeln('callfit: about to call FIT');
		{$ENDC}
		
		tempLambda := fLambdaAtStart;
		fitRes := Fit(gX,
									gY,
									NObservations, 
									@gParams,
									theNumberOfParams,
									fModelNumber,
									fWeightsOption <> noWeights,
									{$IFC qELS} fWeightsOption = ELS, {$ENDC}
									gSqrtWeights,
									tempLambda,
									fMaxIterations,
		{$IFC qConstraints}
									@gLowConstraints,
									@gHiConstraints,
		{$ENDC}
									theCurrentSubject,
									fFullOutput,
									ReComputeWeights,
									fRefreshPlotsEachIteration);
		
		{$IFC qDebug}
			Writeln('callfit: fitting ended with code', fitres);
		{$ENDC}
		
		{ Interpreta il codice di errore  restituito da fit,
			ed eventualmente manda un alert }
		
		CASE fitRes OF
			noError: ;

			insufficientMemory:
				IF NOT fUnattended THEN
					MyAlert(kGenericMsgs, eNotEnoughMemoryForFitting);

			tooManyIterations:
				IF NOT fUnattended THEN
					MyAlert(kGenericMsgs, eTooManyIterations);

			badInitialEstimate:
				IF NOT fUnattended THEN
					MyAlert(kGenericMsgs, eBadInitialEstimate);

			tooFewObservations: 
				BEGIN
					IF NOT fUnattended THEN
						MyAlert(kGenericMsgs, eNotEnoughObservations);
					fMessagesWindow.Writeln(kSeparationLine);
					fMessagesWindow.NewLine;
					fMessagesWindow.Writeln('*** ERROR: Too few observations. ***');
					fMessagesWindow.Synch;
				END;
				
			noSolutions:
				BEGIN
					IF NOT fUnattended THEN
						MyAlert(kGenericMsgs, eNoSolutions);
					fMessagesWindow.Writeln(kSeparationLine);
					fMessagesWindow.NewLine;
					fMessagesWindow.Writeln('*** ERROR: fitting failed because of NANs in the Hessian matrix. ***');
					fMessagesWindow.Writeln(kParamValuesWhenStopped);
					printVector(@gParams, 0, theNumberOfParams - 1);
					fParamsTable.ArrayToColumn(theCurrentSubject, @gParams, theNumberOfParams);
					fMessagesWindow.Synch;
				END;
				
			userInterruptedFit: ;

			sumIsNan:
				IF NOT fUnattended THEN
					MyAlert(kGenericMsgs, eSumIsNan);

			errorInReComputeWeights:
				IF NOT fUnattended THEN
					MyAlert(kGenericMsgs, eComputeWeightsFailed);
			
			{$IFC qConstraints}
			invalidInitialEstimate:
				IF NOT fUnattended THEN
					MyAlert(kGenericMsgs, eInvalidInitialEstimate);
				
			constraintsLoopError: BEGIN
				fMessagesWindow.Writeln(kSeparationLine);
				fMessagesWindow.NewLine;
				fMessagesWindow.Writeln('*** ERROR: can''t satisfy constraints ***');
				fMessagesWindow.Writeln(kParamValuesWhenStopped);
				printVector(@gParams, 0, theNumberOfParams - 1);
				fParamsTable.ArrayToColumn(theCurrentSubject, @gParams, theNumberOfParams);
				fMessagesWindow.Synch;
				IF NOT fUnattended THEN
					MyAlert(kGenericMsgs, eConstraintsLoopError);
			END;
			{$ENDC}
			
			{$IFC qDebug}
			OTHERWISE
				BEGIN
					Writeln('CallFit: fit returned code', fitRes);
					ProgramBreak('CallFit: bad CASE');
				END;
			{$ENDC}
		END;					{ case }
			
		userCancel := (fitRes = userInterruptedFit);
		mustPrintResults :=	fitRes IN [noError, tooManyIterations];
		mustCopyDataToTables :=	fitRes IN [noError, 
																			 tooManyIterations,
																			 userInterruptedFit,
																			 sumIsNan,
																			 noSolutions,
																			 errorInReComputeWeights,
																			 constraintsLoopError];
	END;							{ CallFit}
	
	FUNCTION AParamIsMissing: BOOLEAN;
	{
		Se e' missing uno dei parametri che dovrebbe esserci,
		allora rest. TRUE.
	}
	VAR i: INTEGER;
	BEGIN					{ AParamIsMissing }
		FOR i := 1 TO theNumberOfParams DO
			IF ClassExtended(gParams[i]) = QNan THEN BEGIN
				AParamIsMissing := TRUE;
				Exit(AParamIsMissing);
			END;			{ IF }
		AParamIsMissing := FALSE;
	END;					{ AParamIsMissing }
	
	
	FUNCTION GetSize(sel: SubjectSet): INTEGER;
	{
		Serve a contare il numero di elementi nell' insieme "sel".
	}
	VAR 
		i, count: INTEGER;
	BEGIN			{ GetSize }
		count := 0;
		FOR i := 1 to kMaxSubjects do
			IF i in sel THEN
				count := count + 1;
		GetSize := count
	END;			{ GetSize }
	
	PROCEDURE PrintHeaderInfo;
	CONST 
		semicolon = ';';
		dot = '.';
		rquotes = '�';
	VAR
		dateStr,
		timeStr: Str255; 
		theSecs: Longint;
	BEGIN			{ PrintHeaderInfo }
		fMessagesWindow.NewLine; 
		fMessagesWindow.NewLine; 
		fMessagesWindow.NewLine;
		
		GetDateTime(theSecs);
		IUDateString(theSecs, abbrevDate, dateStr);
		IUTimeString(theSecs, false, timeStr);
		
		s := fTitle^^;		{�dereference document title }
		fMessagesWindow.Writeln(Concat('EasyFit v.', kVersion));
		{$IFC qDebug}
		fMessagesWindow.Writeln('DEBUG Version');
		{$ENDC}
		fMessagesWindow.Writeln(Concat(dateStr,
														' at ',
														timeStr,
														';   document �',
														s,
														rquotes,
														semicolon));
		fMessagesWindow.Synch;
	END;			{ PrintHeaderInfo }
	
	FUNCTION GetNumberOfOperations: INTEGER;
	BEGIN
		GetNumberOfOperations := sizeOfSelection;
	END;
	
	PROCEDURE DoFitErrorHdl(error: OSErr; message: LONGINT);
	BEGIN
		{ Allow Fit to do its own cleaning }
		FitErrHdl(theNumberOfParams);
		
		IF error = kUserInterruptedFit THEN BEGIN
			userCancelledFit := TRUE;
			GOTO 100;
		END
		ELSE IF error = kXMDLFailed THEN BEGIN
			XMDLFailed := TRUE;
			GOTO 100;
		END
		ELSE BEGIN
			{�We no longer need to be awakened often by MF }
			gApplication.fIdleFreq := kMaxIdleTime;
					
			{�Get rid of the working dialog }
			FreeIfObject(aWorkingDlog);
			aWorkingDlog := NIL;
			
			{�Signal this is invalid }
			pWorkingDialog := NIL;

			{ We got an error, and we are no longer fitting }
			gWorking := FALSE;
			
			{�dispose of cuts if necessary }
			IF cuts <> NIL THEN
				DisposPtr(Ptr(cuts));
			
			{$IFC qXMDLs}
			IF fModelNumber = kXMDL THEN
				IF AwakeXMDL(gXMDL, oldXMDLState) THEN;
			{$ENDC}
		END;
	END;
	
	FUNCTION CallComputeWeights: BOOLEAN;
	{
		This function sets up properly
			- the sqrtWeights vector
			- the ReComputeWeights function
		for the fit.
		If an error happens, TRUE is returned. If everything is OK, FALSE is
		returned.
	}
	VAR result: BOOLEAN;
			i:			INTEGER;
	BEGIN	
		CASE fWeightsOption OF 
			{$IFC qDebug}
			noWeights:
				ProgramBreak('CallComputeWeights: called with "no weights" option');
			{$ENDC}
			
			oneOverYObserved:
				BEGIN
					result := ComputeWeights1OverObs(gY, NObservations, gSqrtWeights) <> 0;
					ReComputeWeights := NIL;
				END;

			oneOverSquaredYObserved,
			ELS:	{�With ELS, the weights vector isn't used by fit. It is still
							used by peeling. }
				BEGIN
					result := ComputeWeights1OverSqObs(gY, NObservations, gSqrtWeights) <> 0;
					ReComputeWeights := NIL;
				END;
				
			oneOverYEstimated:
				BEGIN
					{�We use $B- to make sure we get the jump table entry, not an address within
						a segment. Just to play safe. }
					{$PUSH} {$B-}
					ReComputeWeights := @ComputeWeights1OverEstimated;
					{$POP}
					result := FALSE;
				END;
				
			oneOverSquaredYEstimated:
				BEGIN
					{�We use $B- to make sure we get the jump table entry, not an address within
						a segment. Just to play safe. }
					{$PUSH} {$B-}
					ReComputeWeights := @ComputeWeights1OverSqEstimated;
					{$POP}
					result := FALSE;
				END;
				
			inputByUser:
				BEGIN
					ReComputeWeights := NIL;
					fWeightsTable.ColumnToArray(theCurrentSubject, PExtended(gSqrtWeights));
					
					{�Check che ci siano tutti i pesi che ci devono essere }
					result := FALSE;
					FOR i := 1 TO bound DO
						IF 	{�The X column entry is not missing }
								((ClassExtended(fExpDataTable.GetValue(i, 0)) <> QNan)
								
								& {�The subject column entry is not missing either }
								(ClassExtended(fExpDataTable.GetValue(i, theCurrentSubject)) <> QNan))
								
								& { the weight is missing }
								(ClassExtended(gSqrtWeights^[i]) = QNan)
						
						THEN BEGIN	{ A weight is missing }
							CallComputeWeights := TRUE;
							Exit(CallComputeWeights);
						END;
					
					{�Il test e' andato bene, allora rimoviamo i missing }
					FOR i := 1 TO NObservations DO
						gSqrtWeights^[i] := gSqrtWeights^[gPlaces[i]];

					{�Ora normalizziamo i pesi }
					normalizeWeights(gSqrtWeights, NObservations);
					
					{ estraiamo la radice quadrata }
					FOR i := 1 TO NObservations DO
						gSqrtWeights^[i] := sqrt(gSqrtWeights^[i]);					
				END;
		END;		{ case }
		CallComputeWeights := result;
	END;			{ CallComputeWeights }
	
	PROCEDURE PrintSmallHeaderInfo;
	{
		Print an header for each subject 
	}
	CONST 
		semicolon = ';';
		dot = '.';
		dquotes = '"';
	VAR
		tmpHandle: Handle;
		tmpStr: Str255;
		
	BEGIN			{ PrintSmallHeaderInfo }
	
		{ Print an intestation for the subject }
	
		fMessagesWindow.NewLine;
		fMessagesWindow.NewLine;
		NumToString(theCurrentSubject, tmpStr);
		fMessagesWindow.Writeln('----------------------------------------');
		fMessagesWindow.Writeln(Concat('Fitting subject ', tmpStr, dot));
		fMessagesWindow.Writeln('----------------------------------------');
		fMessagesWindow.NewLine;
		
		{�Write the formula of the model }
		CASE fModelNumber OF
			kSingleExp: BEGIN
					fMessagesWindow.writeln('Model: single exponential:');
					fMessagesWindow.writeln('y = p1 * exp(�p2 * x)');
				END;
				
			kTwoExpPlus: BEGIN
					fMessagesWindow.writeln('Model:');
					fMessagesWindow.writeln('y = p1 * exp(�p2 * x) + p3 * exp(�p4 * x)');
				END;
				
			kTwoExpMinus: BEGIN
					fMessagesWindow.writeln('Model:');
					fMessagesWindow.writeln('y = �p1 * exp(�p2 * x) + p3 * exp(�p4 * x)');
				END;
				
			kThreeExpPlus: BEGIN
					fMessagesWindow.writeln('Model:');
					fMessagesWindow.writeln('y = p1 * exp(�p2 * x) + p3 * exp(�p4 * x) + p5 * exp(�p6 * x)');
				END;
				
			kThreeExpMinus: BEGIN
					fMessagesWindow.writeln('Model:');
					fMessagesWindow.writeln('y = �p1 * exp(�p2 * x) + p3 * exp(�p4 * x) + p5 * exp(�p6 * x)');
				END;
				
			kUserDefined: BEGIN
					fMessagesWindow.Writeln('User defined model:');
					tmpHandle := fUserModelText;
					
					{�Tronchiamo il modello utente a un kilobyte }
					fMessagesWindow.WritelnHandle(tmpHandle, 1024);
					IF GetHandleSize(tmpHandle) > 1024 THEN BEGIN
						fMessagesWindow.NewLine;
						fMessagesWindow.Writeln(' [...]');
					END;
				END;
			
			kXMDL: BEGIN
					{$IFC qDebug}
					Writeln('about to CallXMDLName; gXMDL = ', ORD4(gXMDL));
					{$ENDC}
					CallXMDLName(gXMDL);
					{$IFC qDebug}
					Writeln('called CallXMDLName');
					{$ENDC}
				END;
		END;
		fMessagesWindow.newline;
		
		{ Write the weighting option }
		
		CASE fWeightsOption OF
			noWeights: 
				fMessagesWindow.Writeln('No weighting.');
			oneOverYObserved:
				fMessagesWindow.Writeln('Weighting data as 1/y (observed y).');
			oneOverSquaredYObserved:
				fMessagesWindow.Writeln('Weighting data as 1/y**2 (observed y).');
			oneOverYEstimated:
				fMessagesWindow.Writeln('Iteratively reweighting data as 1/y(x) (estimated y).');
			oneOverSquaredYEstimated:
				fMessagesWindow.Writeln('Iteratively reweighting data as 1/y(x)**2 (estimated y).');
{$IFC qELS}
			ELS:
				BEGIN
					fMessagesWindow.Writeln('Weighting data with Extended Least Squares;');
					fMessagesWindow.Writeln('variance model is alpha*y(x)**beta.');
				END;
{$ENDC}
			inputByUser:
				fMessagesWindow.Writeln('Weighting data as from user input.');
			{$IFC qDebug}
			OTHERWISE
				ProgramBreak('PrintSmallHeaderInfo: bad switch');
			{$ENDC}
		END;
		fMessagesWindow.newline;
		
		fMessagesWindow.Synch;
	END;			{ PrintSmallHeaderInfo }
	
BEGIN 					{ DoFit }

	{�Make sure error handler will work }
	aWorkingDlog := NIL;
	FitClearVars;
	cuts := NIL;
	
	{�Initialize these in case we jump to the end because of an early error }
	userCancelledFit := FALSE;
	XMDLFailed := FALSE;
	mustPrintResults := FALSE;
	mustCopyDataToTables := FALSE;
	
	{$IFC qXMDLs}
	{�Load & lock the XMDL }
	IF fModelNumber = kXMDL THEN
		oldXMDLState := AwakeXMDL(gXMDL, TRUE);
	{$ENDC}
	
	{ It is necessary to place an exception handler just to clean up
		a few things if something goes wrong }
	CatchFailures(fi, DoFitErrorHdl);
	
	theNumberOfParams := get_NumberOfParams(fModelNumber);
	
	gApplication.ActivateBusyCursor(FALSE);
	SetCursor(gWatchHdl^^);
	
	{ gMenusAreSetup := FALSE; }
	gApplication.SetUpTheMenus;
	
	{�Now that we are working hard, we need to regain control from MF always
		as soon as possible.  It could have been more easy to
		set a very short idleFreq in the working dialog window.
		But we would have lost the ability to select windows while the fitting
		is running !!! }
	gApplication.fIdleFreq := 0;
	
	{�This command will change the contents of some windows; undo information
		will no longer be valid. }
	gApplication.CommitLastCommand;
	
	fExpDataTable.GetSelectedSubjects(selection);
	IF selection = [] THEN		{�no selected subjects }
		GOTO 99;
	sizeOfSelection := GetSize(selection);

	{ force fExpDataTable, FWeightsTable and fParamsTable to enter the value of 
		the entry view in the current cell. }
	fExpDataTable.ConfirmEntry;
	fParamsTable.ConfirmEntry;
	fDosesTable.ConfirmEntry;
	IF fWeightsOption = inputByUser THEN
		fWeightsTable.ConfirmEntry;
{$IFC qConstraints}
	fConstraintsTable.ConfirmEntry;
{$ENDC}
	
	{�Get the number of observations (missings included) }
	fExpDataTable.GetInUseBounds(aRect);
	bound := aRect.bottom;
		
	{ Ctrl che non ci siano syntax errors nelle tabelle }
	IF	fExpDataTable.DataCheck | 
			(fParamsTable.DataCheck |
			((fWeightsOption = inputByUser) & fWeightsTable.DataCheck))
	THEN BEGIN
		NotifyBeep;
		goto 99;
	END;
		
	numberOfOperations := GetNumberOfOperations;

	gWorking := TRUE;

	NEW(aWorkingDlog);
	FailNIL(aWorkingDlog);
	aWorkingDlog.Pose(numberOfOperations, 'Please be patient...');
	
	{�Set up these globals }
	pWorkingDialog := aWorkingDlog;

	PrintHeaderInfo;

	IF aWorkingDlog.PollEvent THEN
		GOTO 99;

	FOR theCurrentSubject := 1 TO kMaxSubjects DO
		IF theCurrentSubject IN selection THEN BEGIN
			NumToString(theCurrentSubject, currSubjectStr);
			
			{ Manda una intestazione sulla fin. di output }
			PrintSmallHeaderInfo;
			
			ClearStdResWindow;

			{�Read data }
			fExpDataTable.ColumnToArray(0, PExtended(gX));	
																							IF aWorkingDlog.PollEvent THEN GOTO 99;
			fExpDataTable.ColumnToArray(theCurrentSubject, PExtended(gY));
			PurgeMissings;
			
																							IF aWorkingDlog.PollEvent THEN GOTO 99;
			
			{$IFC qConstraints}
			fConstraintsTable.GetLowConstraints(@gLowConstraints, theNumberOfParams);
			fConstraintsTable.GetHiConstraints(@gHiConstraints, theNumberOfParams);
			{$ENDC}
			
																							IF aWorkingDlog.PollEvent THEN GOTO 99;

			{ If requested, compute weights }
			IF fWeightsOption <> noWeights THEN BEGIN
				IF	CallComputeWeights THEN BEGIN
					fMessagesWindow.Writeln('Couldn''t compute weights for this subject.');
					fMessagesWindow.Synch;
					IF NOT fUnattended THEN
						MyAlert(kGenericMsgs, eComputeWeightsFailed);
					GOTO 9;											{�Don't fit this one. }
				END;
			END;
			
																							IF aWorkingDlog.PollEvent THEN GOTO 99;

			{ Get the dose (it may be needed by an user model, so we need to
				put the value in this global _before_ calling fit(). ) }
			fDosesTable.GetDose(theCurrentSubject, gDose);

			{�Make sure AParamIsMissing will work }
			FOR i := 1 TO theNumberOfParams DO
				gParams[i] := gMissing;
				
			{ read its parameter estimates, if any }
			fParamsTable.ColumnToArray(theCurrentSubject, @gParams);
			
			{�If requested and necessary, execute peeling }
			IF fAutomaticPeeling & AParamIsMissing THEN BEGIN
			
				{ Inform the user via the Working Dialog }
				aWorkingDlog.SetText(Concat('Peeling subject ', currSubjectStr));

				{ Call the peeling procedure }
				cuts := PPeelingArray(NewPermPtr(sizeof(PeelingArray)));
				FailNil(cuts);
				
				{$IFC qXMDLs}
				IF fModelNumber = kXMDL THEN
					peelResult := CallXMDLPeeling(gXMDL,
																				gX,
																				gY,
																				NObservations,
																				@gParams,
																				gSqrtWeights,
																				ORD4(fWeightsOption))
				ELSE
				{$ENDC}
					peelResult := CallPeel(gX,
																 gY,
																 NObservations,
																 @gParams,
																 gSqrtWeights,
																 ORD(fWeightsOption),
																 fModelNumber,
																 cuts);
				{$IFC qDebug}
				NumToString(peelResult, s);
				fMessagesWindow.Writeln(Concat('Done peeling, result=', s));
				{$ENDC}
				
				IF aWorkingDlog.PollEvent THEN
					GOTO 99;

				{�Examine peeling result and inform the user }
				IF peelResult = noError THEN BEGIN
					fMessagesWindow.Writeln('Parameter estimates were computed with a peeling algorithm.');
					PrintCutPoints;
					fMessagesWindow.NewLine;
					fMessagesWindow.Synch;
					
					{�Redraw plot, if so requested }
					IF fRefreshPlotsEachIteration THEN
						RefreshPlots(theCurrentSubject, @gParams, theNumberOfParams);
				END
				ELSE IF peelResult = noPeelingFuncAvailable THEN BEGIN
					fMessagesWindow.Writeln('*** No initial values for the parameters;'); 
					fMessagesWindow.Writeln('    can''t use the peeling procedure with a user defined model;');
					fMessagesWindow.Writeln('    fitting cancelled. ***');
					fMessagesWindow.Synch;
					IF NOT fUnattended THEN
						MyAlert(kGenericMsgs, eCantPeelUserModel);
					GOTO 9;											{�Don't fit this one. }
				END
				ELSE BEGIN
					fMessagesWindow.Writeln('*** Peeling failed; fitting cancelled. ***');
					fMessagesWindow.Synch;
					IF NOT fUnattended THEN
						MyAlert(kGenericMsgs, ePeelingFailed);
					GOTO 9;											{�Don't fit this one. }
				END;
				
				DisposPtr(Ptr(cuts));
				cuts := NIL;									{�make the failure handler happy }
			END;														{ Peeling }
			
			{ ctrl che ci siano tutte le stime iniziali
				dei parametri che servono. }
			IF AParamIsMissing THEN BEGIN
				fMessagesWindow.WritelnResource(kGenericMsgs, eMissingParam);
				fMessagesWindow.Synch;
				IF NOT fUnattended THEN
					MyAlert(kGenericMsgs, eMissingParam);
				GOTO 9;
			END;
			
			{�At last! Execute the fitting ! }
			CallFit(userCancelledFit, mustCopyDataToTables, mustPrintResults);

			IF userCancelledFit THEN
				{ stop without computing anything else }
				LEAVE;
			
			IF mustCopyDataToTables THEN
				fParamsTable.ArrayToColumn(theCurrentSubject, @gParams, theNumberOfParams);
			
			IF mustPrintResults THEN BEGIN
				FillStdResWindow;
				WriteStdResOnMessages;
				fMessagesWindow.NewLine;
			
				{�ProgramBreak('About to repurge missings'); }

				{�Do pharmacokinetic computations and output them;
					we need to re-read data and purge missings again. }
				fExpDataTable.ColumnToArray(0, PExtended(gX));	
				fExpDataTable.ColumnToArray(theCurrentSubject, PExtended(gY));
				PurgeMissings;
				
				{$IFC qXMDLs}
				IF fModelNumber = kXMDL THEN BEGIN
					{$IFC qDebug}
					{ Writeln('DoFit: About to call XMDLFinalComp., gXMDL =', ORD4(gXMDL)); }
					{�ProgramBreak(''); }
					{$ENDC}
					CallXMDLFinalComputations(gXMDL, gX, gY, gSqrtWeights, NObservations,
																		@gParams, ORD4(fWeightsOption), gDose,
																		theCurrentSubject);
				END
				ELSE
				{$ENDC}
					print_pharmacokin_data(	gX, gY, NObservations, @gParams, 
																	fModelNumber, gDose);

				IF fWeightsOption <> noWeights THEN
					FillWeightsWindow;

			END;			
9:																{ jump here if you want to skip a subject }
			fMessagesWindow.Synch;
			aWorkingDlog.OperationDone;
		END; 													{�If currSubj in selection }
	
99:																{ Clean up before ending }
	Success(fi);
100:
	IF userCancelledFit THEN BEGIN
		fMessagesWindow.NewLine;
		fMessagesWindow.writeln(kSeparationLine);
		fMessagesWindow.NewLine;
		fMessagesWindow.writeln('*** Fitting stopped by the user ***');
		fMessagesWindow.writeln(kParamValuesWhenStopped);
		printVector(@gParams, 0, theNumberOfParams - 1);
		fParamsTable.ArrayToColumn(theCurrentSubject, @gParams, theNumberOfParams);
		fMessagesWindow.Synch;
	END
	ELSE IF XMDLFailed THEN BEGIN
		fMessagesWindow.NewLine;
		fMessagesWindow.writeln(kSeparationLine);
		fMessagesWindow.NewLine;
		fMessagesWindow.writeln('*** Error reported by the external model ***');
		fMessagesWindow.writeln(kParamValuesWhenStopped);
		printVector(@gParams, 0, theNumberOfParams - 1);
		fParamsTable.ArrayToColumn(theCurrentSubject, @gParams, theNumberOfParams);
		fMessagesWindow.Synch;
		IF NOT fUnattended THEN
			gApplication.ShowError(kXMDLFailed, 0);
	END;
	
	{$IFC qXMDLs}
	IF fModelNumber = kXMDL THEN
		IF AwakeXMDL(gXMDL, oldXMDLState) THEN;
	{$ENDC}
	FreeIfObject(aWorkingDlog);
	
	pWorkingDialog := NIL;					{�So we're sure we'll not use it when it's invalid }
	gWorking := FALSE;							{�pWorkingDialog and gWorking must always be set
																		together }
	
	fDataAndFuncPlotWindow.ForceRedraw;
	fStdResPlotWindow.ForceRedraw;
	
	{�We no longer need to be awakened often by MF }
	gApplication.fIdleFreq := kMaxIdleTime;
	
	IF fBeepWhenFitDone THEN
		NotifyBeep
END;																{ DoFit }

{ ---------------------------------------------------------------------------------- }
{$S CallFit}

{ This one is called when user tries to do bad things during the fitting,
	like trying to edit tables or closing the document. }
PROCEDURE RemindUserWeAreWorking;
BEGIN
	gApplication.Beep(50);
	IF pWorkingDialog <> NIL THEN BEGIN
		pWorkingDialog.fWindow.Select;
		pWorkingDialog.fWindow.Center({horizontally} TRUE, {vertically} TRUE,
			{fordialog} TRUE);
	END;
END;
