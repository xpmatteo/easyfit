{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}

{ ----------------------------------------------------------------------------------- }
{ External C routines }

PROCEDURE SetUserModelNParams(nParams: INTEGER); C; EXTERNAL;

FUNCTION p2cstr(s: UNIV Ptr): Ptr; C; EXTERNAL;

{ ----------------------------------------------------------------------------------- }
{$S ADoCommand}

PROCEDURE TEasyFitDocument.MakeFitOptionsDlog;
CONST kFitOptionsDlog = 1100;
VAR aWindow:			TWindow;
		dismisser:		IDType;
		theDialog:		TDialogView;
		
	PROCEDURE SetUpTheDialog;
	CONST kRedraw =				TRUE;
				kVerySmall =		1.0e-30;
	VAR aRealText:			TRealText;
			tmpExtended:		EXTENDED;
	BEGIN
		TCheckBox(theDialog.FindSubView('demo')).SetState(fRefreshPlotsEachIteration, NOT kRedraw);
		TCheckBox(theDialog.FindSubView('beep')).SetState(fBeepWhenFitDone, NOT kRedraw);
		TCheckBox(theDialog.FindSubView('UNAT')).SetState(fUnattended, NOT kRedraw);
		TCheckBox(theDialog.FindSubView('FUOU')).SetState(fFullOutput, NOT kRedraw);
		TCheckBox(theDialog.FindSubView('AUPE')).SetState(fAutomaticPeeling, NOT kRedraw);
		TNumberText(theDialog.FindSubView('MXIT')).SetValue(fMaxIterations, NOT kRedraw);

		aRealText := TRealText(theDialog.FindSubView('LAMB'));
			{�Stop the user from inputing a null or negative number }
		aRealText.fMinimum := kVerySmall; 
		tmpExtended := fLambdaAtStart;
		aRealText.SetValue(tmpExtended, NOT kRedraw);
	END;
	
BEGIN
	FixEditMenu;
	fChangeCount := fChangeCount + 1; {�so we will be asked to save document }
	
	aWindow := NewTemplateWindow(kFitOptionsDlog, NIL);
	FailNil(aWindow);
	
	{�Get a reference to the dialog view, for efficiency }
	theDialog := TDialogView(aWindow.FindSubView('DLOG'));
	
	{�Set up the dialog, getting the values from the global variables }
	SetUpTheDialog;
	
	{�Pose the dialog }
	dismisser := theDialog.PoseModally;
	
	{�Handle results }
	IF dismisser = 'ok  ' THEN BEGIN
		{�Put the values in the appropriate variables }
		fUnattended := TCheckBox(theDialog.FindSubView('UNAT')).IsOn;
		fFullOutput := TCheckBox(theDialog.FindSubView('FUOU')).IsOn;
		fRefreshPlotsEachIteration := TCheckBox(theDialog.FindSubView('demo')).IsOn;
		fBeepWhenFitDone := TCheckBox(theDialog.FindSubView('beep')).IsOn;
		fAutomaticPeeling := TCheckBox(theDialog.FindSubView('AUPE')).IsOn;
		fMaxIterations := TNumberText(theDialog.FindSubView('MXIT')).GetValue;
		fLambdaAtSTart := TRealText(theDialog.FindSubView('LAMB')).GetValue;
	END;
	
	aWindow.Close;
END;						{ MakeFitOptionsDlog }

{ ----------------------------------------------------------------------------------- }
{$S ADoCommand}

FUNCTION TEasyFitDocument.MakeUserModelDlog: BOOLEAN;
CONST kUserModelDlog = 1140;
VAR theWindow:					TWindow;
		dismisser:					IDType;
		theDialog:					TDialogView;
		theProgramField:		TTEView;
		theErrorMsgField:		TStaticText;
		ok:									BOOLEAN;
		whereError:					LONGINT;		{ Number of chars read before an error occurred }
		compileResult:			INTEGER;
		errMsg:							Str255;
		workText:						Handle;
		nParams:						INTEGER;

	FUNCTION Pose: IDType;
	LABEL 1;
	VAR fi: 				FailInfo;

		PROCEDURE HdlPoseModally(error: OSErr; message: LONGINT);
		BEGIN
			IF error = noErr THEN
				GOTO 1													{ If no error then keep the dialog running }
			ELSE BEGIN
				theDialog.fDismissed := TRUE; 	{ Avoid validating selected edit text }
				theWindow.Close;								{ If an error occurs then close the dialog 
																					and exit via failure mechanism }
				
				DisposHandle(workText);
				
				{ re-compile original text }
				compileResult := CompileUserModel(fUserModelText, whereError, nParams, errMsg);
				SetUserModelNParams(nParams);
			END;
		END;

	BEGIN
		theDialog.fDismissed := False;
		REPEAT
			CatchFailures(fi, HdlPoseModally);
			{$IFC MacApp20Def}
			gApplication.PollEvent( {allowApplicationToSleep:} TRUE);
			{$ELSEC}
			gApplication.PollEvent;
			{$ENDC}
			Success(fi);
		1:
		UNTIL theDialog.fDismissed;
		Pose := theDialog.fDismisser;
	END;

	{
		This procedure is made with reelaborated code from TTEPasteCommand. This
		is why its local vars begin with "f". 
		Its purpose is to add the text contained in "itsNewText" to the TEView
		passed as "itsTEView", removing the previous selection, if any.
		I modified the code for:
		- taking the new text from an already filled handle, rather than from the scrap
		- ignoring styles
		- loosing the chance of undoing-redoing (this will be handled properly
			in future releases !!!
	}
	PROCEDURE AddHandleToText(itsNewText: Handle; itsTEView: TTEView);
	VAR
		fTEView:			TTEView;			{ The TEView operated on }
		fHTE:					TEHandle;			{ same as fTEView's fHTE; duplicated for
																	code efficiency }
		fOldStart:		INTEGER;			{ The beginning and ending positions of the }
		fOldEnd:			INTEGER;			{ selection at the moment just before the
																	command was done }
		fNewStart:		INTEGER;			{ The beginning and ending locations in the Text� }
		fNewEnd:			INTEGER;			{ �of the new text that is added by the
																	command, if any }
		fNewText:			Handle; 			{ A Handle to the characters added by the command }
	
		PROCEDURE InstallNewText;
		VAR
			savedSize:		LONGINT;
			itsText:			Handle;
			fi: FailInfo;
			
			PROCEDURE HandleInstallNewTextFailure(error: OSErr; message: LONGINT);
			BEGIN
				HUnLock(fNewText);
			END;
			
		BEGIN
			IF fNewEnd > fNewStart THEN BEGIN
				itsText := fTEView.fText;
				savedSize := GetHandleSize(itsText);
		
				{ prevent heap fragmentation for TEInsert }
				MoveHHi(fNewText);
				HLock(fNewText);				
				
				CatchFailures(fi, HandleInstallNewTextFailure);
				TEInsert(fNewText^, GetHandleSize(fNewText), fHTE);
				Success(fi);
				
				HUnlock(fNewText);
		
				IF GetHandleSize(itsText) <= savedSize THEN
					FailOSErr(memFullErr);
		
				fTEView.fSpecsChanged := TRUE;
			END;
		END;		{�InstallNewText }
	
	
	BEGIN
		{ --- INITIALIZE --- }
	
		fTEView := itsTEView;
		fHTE := itsTEView.fHTE;
	
		WITH fHTE^^ DO BEGIN
			fOldStart := selStart;
			fOldEnd := selEnd;
		END;
	
		fNewStart := 0;
		fNewEnd := 0;
		fNewText := itsNewText;
	
		fNewStart := fHTE^^.selStart;
		fNewEnd := fNewStart + GetHandleSize(itsNewText);
	
		{�--- EXECUTE --- }
	
		IF fTEView.Focus THEN;								{??? What if Focus fails}
	
		{�BanishOldText }
		IF fOldEnd > fOldStart THEN
			TEDelete(fHTE);
	
		InstallNewText;
		fTEView.SynchView(kRedraw);
	END;
	
	PROCEDURE ImportModel;
	LABEL 999;
	VAR fi:							FailInfo;
			fileRefNumber:	INTEGER;
			where:					Point;
			typeList:				SFTypeList;
			reply:					SFReply;
			byteCount:			LONGINT;
			buffer:					Handle;
			fileSize:				LONGINT;
			
		PROCEDURE HandleImportFailure(error: OSErr; message: LONGINT);
		BEGIN
			IF FSClose(fileRefNumber) = noErr THEN ;
			HUnlock(buffer);
			DisposHandle(buffer);
			ErrorAlert(error, message);
			GOTO 999;
		END;
		
	BEGIN
			gApplication.CommitLastCommand;

			{ Open a file and try to read from it }

			{ Update all the windows to avoid a bug in Standard File in which
				you can't mount a disk correctly when window updates are pending.}
			gApplication.UpdateAllWindows;
			
			where.h := 100;
			where.v := 100;
			typeList[0] := 'TEXT';

			SFGetFile(where, 
								'Import model from:',
								{fileFilter:} NIL,
								{numTypes:} 1,
								typeList,
								{dlgHook:} NIL,
								reply);
			
			IF reply.good THEN
				WITH reply DO BEGIN
					CatchFailures(fi, HandleImportFailure);
					
					{�Open file }
					FailOSErr(FSOpen(fName, vRefNum, fileRefNumber));
					
					{ Read text }
					FailOSErr(GetEOF(fileRefNumber, fileSize));
					buffer := NewPermHandle(fileSize);
					FailNil(buffer);
					MoveHHi(buffer);
					HLock(buffer);
					FailSpaceIsLow;
					byteCount := fileSize;
					FailOSErr(FSRead(fileRefNumber, byteCount, buffer^));
					FailOSErr(FSClose(fileRefNumber));
					
					{ Add text to the dialog }
					AddHandleToText(buffer, theProgramField);

					HUnlock(buffer);
					DisposHandle(buffer);
					Success(fi);
				END;
			999: ;
	END;
	
	PROCEDURE WriteModel(fileRefNumber: INTEGER);
	VAR
		tmpHandle:			Handle;
		fi:							FailInfo;
		size:						LONGINT;

		PROCEDURE HdlWriteModelFailure(error: OSErr; message: LONGINT);
		BEGIN
			HUnLock(tmpHandle);
		END;

	BEGIN
		tmpHandle := theProgramField.ExtractText;
		HLock(tmpHandle);
		CatchFailures(fi,HdlWriteModelFailure);
		size := GetHandleSize(tmpHandle);
		FailMemError;
		WriteBytes(fileRefNumber, size, tmpHandle^);
		HUnLock(tmpHandle);
		Success(fi);
	END;
		
	
BEGIN				{�MakeUserModelDlog }
	gApplication.CommitLastCommand;
		
	FixEditMenu;												{�remove buzzwords }
	fChangeCount := fChangeCount + 1;		{�so we will be asked to save document }
	
	theWindow := NewTemplateWindow(kUserModelDlog, NIL);
	FailNil(theWindow);
	
	{�Get a reference to some of the views, for efficiency }
	theDialog := TDialogView(theWindow.FindSubView('dlog'));
	theErrorMsgField := TStaticText(theDialog.FindSubView('msgs'));
	theProgramField := TTEView(theDialog.FindSubView('prgm'));
	
	{ Get a copy of the original text in a different handle }
	workText := CopyHandleData(fUserModelText);
	
	{�Put previous program text into the TEView field }
	theProgramField.StuffText(workText);
	theProgramField.RecalcText;
	theProgramField.SynchView(kRedraw);
	theWindow.Open;
	
	ok := FALSE;
	REPEAT
		dismisser := Pose;			{�Pose the dialog }
		
		{�Handle results }
		IF dismisser = 'ok  ' THEN BEGIN
			
			{ Get Text }
			workText := theProgramField.ExtractText;

			{�Try to compile }
			compileResult := CompileUserModel(workText, whereError, nParams, errMsg);
			
			{$IFC qDebug}
			Writeln('Compiled; result was', compileResult, ' where =', whereError, 
			', nParams =', nParams, ' errMsg = ', errMsg);
			{$ENDC}
			
			IF compileResult = 0 THEN BEGIN		{�No error in compilation }
				SetUserModelNParams(nParams);
				ok := TRUE;
			END
			ELSE BEGIN {�compileResult was error }
				theErrorMsgField.SetText(errMsg, kRedraw);
				theProgramField.InstallSelection(TRUE, FALSE);
				SetSelect(whereError, whereError, theProgramField.fHTE);
				theProgramField.InstallSelection(FALSE, TRUE);
				theProgramField.ScrollSelectionIntoView;
				gApplication.Beep(50);
			END;
		END
		ELSE IF dismisser = 'iprt' THEN BEGIN
			{�User pressed import button; it is not really a dismisser,
				so we set ok to false}
			ok := FALSE;
			
			ImportModel;
		END
		ELSE IF dismisser = 'xprt' THEN BEGIN
			{�User pressed export button; it is not really a dismisser,
				so we set ok to false}
			ok := FALSE;
			
			IF WriteInOpenFile('Save model text in�', 
												 'User Model', 
												 'TEXT', 
												 kTextCreator,
												 { mustUpdateWindows: } TRUE,
												 WriteModel) THEN ;
		END
		ELSE BEGIN	{�dismisser = 'cncl' }
			ok := TRUE;
			
			DisposHandle(workText);
			
			{ re-compile original text }
			compileResult := CompileUserModel(fUserModelText, whereError, nParams, errMsg);
			SetUserModelNParams(nParams);
		END;
	UNTIL ok;
	
	IF dismisser = 'ok  ' THEN BEGIN
		DisposHandle(fUserModelText);
		fUserModelText := workText;
	END ELSE BEGIN
		workText := NIL;
	END;
	
	theWindow.Close;
	
	MakeUserModelDlog := dismisser = 'ok  ';
END;						{ MakeUserModelDlog }


{ -------------------------------------------------------------------------------------- }
{$IFC FALSE}
{$S ADoCommand}

PROCEDURE TEasyFitDocument.MakeChooseModelDlog;
CONST kChooseModelDlog = 1130;
VAR aWindow:			TWindow;
		dismisser:		IDType;
		theDialog:		TDialogView;
		
	PROCEDURE SetUpTheDialog;
	BEGIN
		CASE fModelNumber OF
			kSingleExp:
				TRadio(theDialog.FindSubView('SNGL')).SetState(TRUE, kDontRedraw);
			kTwoExpPlus:
				TRadio(theDialog.FindSubView('TWPL')).SetState(TRUE, kDontRedraw);
			kTwoExpMinus:
				TRadio(theDialog.FindSubView('TWMI')).SetState(TRUE, kDontRedraw);
			kThreeExpPlus:
				TRadio(theDialog.FindSubView('THPL')).SetState(TRUE, kDontRedraw);
			kThreeExpMinus:
				TRadio(theDialog.FindSubView('THMI')).SetState(TRUE, kDontRedraw);
			kUserDefined:
				TRadio(theDialog.FindSubView('USER')).SetState(TRUE, kDontRedraw);
		END;
	END;
	
	PROCEDURE GetChosenModel;
	BEGIN
		IF TRadio(theDialog.FindSubView('SNGL')).IsOn THEN
			fModelNumber := kSingleExp
		ELSE IF TRadio(theDialog.FindSubView('TWPL')).IsOn THEN
			fModelNumber := kTwoExpPlus
		ELSE IF TRadio(theDialog.FindSubView('TWMI')).IsOn THEN
			fModelNumber := kTwoExpMinus
		ELSE IF TRadio(theDialog.FindSubView('THPL')).IsOn THEN
			fModelNumber := kThreeExpPlus
		ELSE IF TRadio(theDialog.FindSubView('THMI')).IsOn THEN
			fModelNumber := kThreeExpMinus
		ELSE IF TRadio(theDialog.FindSubView('USER')).IsOn THEN
			fModelNumber := kUserDefined;
	END;
	
BEGIN
	gApplication.CommitLastCommand;
	
	aWindow := NewTemplateWindow(kChooseModelDlog, NIL);
	FailNil(aWindow);
	
	{�Get a reference to the dialog view, for efficiency }
	theDialog := TDialogView(aWindow.FindSubView('DLOG'));
	
	{�Set up the dialog, getting the values from the global variables }
	SetUpTheDialog;
	
	{�Pose the dialog }
	dismisser := theDialog.PoseModally;
	
	{�Handle results }
	IF dismisser = 'ok  ' THEN BEGIN
		fChangeCount := fChangeCount + 1; {�so we will be asked to save document }
		GetChosenModel;
	END;
	
	aWindow.Close;
END;						{ MakeChooseModelDlog }
{$ENDC} {FALSE}

{ -------------------------------------------------------------------------------------- }
{$S ADoCommand}

{
	The way I used to build the STYL resources that go with the text is:
	I build the text I want to display with MacApp example DemoText.
	I copy the text in the ScrapBook and I save the DemoText document. 
	Then I derez the STYL resources from the DemoText doc, and paste them
	into the AboutAppText.r file. I then build the TEXT resource this way:
	I create a new, empty file with ResEdit, create a TEXT resource in it,
	then paste in it the text I saved earlier in the ScrapBook.
	After that, I derez + paste in the AboutAppText.r file.
}

PROCEDURE TEasyFitApplication.DoShowAboutApp; OVERRIDE;
CONST kAboutAppDlog = 2000;
VAR theWindow:		TWindow;
		dismisser:		IDType;
		theText:			Handle;
		theStyle:			TEStyleHandle; {}
		theElements:	STHandle;	{}
		theTextView:	TTEView;
BEGIN
	FixEditMenu;
	theWindow := NewTemplateWindow(kAboutAppDlog, NIL);
	FailNil(theWindow);
	theTextView := TTEView(theWindow.FindSubView('text'));
	
	{�Stuff the text and the styles into the TEView }
	theText := GetResource('TEXT', kAboutAppTextRes);
	FailNILResource(theText);

	theStyle := TEStyleHandle(GetResource('STYL', kAboutAppStylesRes)); {}
	FailNILResource(theStyle); {}

	theElements := STHandle(GetResource('STYL', kAboutAppElementsRes)); {}
	FailNILResource(theElements); {}
	
	theTextView.StuffText(theText);
	theTextView.StuffStyles(theStyle, theElements); {}
	theTextView.RecalcText;
	theTextView.SynchView(kDontRedraw);
	
	{�Put in the version number and the date }
	TStaticText(theWindow.FindSubView('vers')).SetText(kVersion, kDontRedraw);
	TStaticText(theWindow.FindSubView('date')).SetText(compdate, kDontRedraw);

	dismisser := TDialogView(theWindow.FindSubView('dlog')).PoseModally;
	
	theWindow.Close;
	ReleaseResource(theText);
	ReleaseResource(Handle(theStyle));
	ReleaseResource(Handle(theElements));
END;						{ DoShowAboutApp }

{ -------------------------------------------------------------------------------------- }
{$S ADoCommand}

PROCEDURE TEasyFitApplication.DoShowAboutMarioNegri;
CONST kAboutMarioNegri = 2001;
VAR theWindow:		TWindow;
		dismisser:		IDType;
BEGIN
	theWindow := NewTemplateWindow(kAboutMarioNegri, NIL);
	FailNil(theWindow);
	
	dismisser := TDialogView(theWindow.FindSubView('dlog')).PoseModally;
	theWindow.Close;
END;						{ MakeAboutAppDlog }