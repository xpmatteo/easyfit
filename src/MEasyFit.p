{
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
}

{ MEasyFit.p }

PROGRAM EasyFit;

{$MC68020-}											{ The main program must be universal code }
{$MC68881-}

USES
	{ � MacApp }
	UMacApp,

	{ � Building Blocks }
	UPrinting, UGridView, UTEView, UDialog,

	{ � Required by UEasyFitDeclarations }
	Fonts,
	
	{ � My general declarations }
	UEasyFitDeclarations,

	{ � Required by UEasyFit }
	UMultiTE, Sane, UTable,

	{ � Implementation use }
	UEasyFit;

CONST
	phSplash = 2010;
 	phWeNeedSystem6 = 2020;
	phWeNeedFPUAndSystem6 = 2030;
VAR
	gEasyFitApplication:	TEasyFitApplication;			{ The application object }
	theDialog:						DialogPtr;								{ for the splash screen }
	
BEGIN
	InitToolBox;										{ Essential toolbox and utilities initialization }
	PullApplicationToFront;
	IF ValidateConfiguration(gConfiguration) THEN BEGIN
		theDialog := GetNewCenteredDialog(phSplash, NIL, NIL);
		IF theDialog <> NIL THEN
			DrawDialog(theDialog);						{ Show splash screen }

		InitUMacApp(25);								{ Initialize MacApp; 25 calls to MoreMasters }
		InitUTEView;										{ Initialize TEView unit }
		InitUGridView;									{ Initialize the GridView unit }
		InitUPrinting;									{ Initialize the Printing unit }
		InitUDialog;										{�Init the dialogs unit }
		
		New(gEasyFitApplication);							{ Allocate the Application object }
		FailNil(gEasyFitApplication);
		gEasyFitApplication.IEasyFitApplication(kFileType);	{ Initialize the application }

		DisposDialog(theDialog);							{ Remember to remove the splash screen }

		gEasyFitApplication.Run;							{ Run the application }
	END
	ELSE BEGIN {�configuration is invalid }
		IF qNeedsFPU THEN
			StdAlert(phWeNeedFPUAndSystem6)
		ELSE
			StdAlert(phWeNeedSystem6)
	END;
END.