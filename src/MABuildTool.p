{[a-,body+,h-,o=100,r+,rec+,t=4,u+,#+,j=20/57/1$,n-]}
{------------------------------------------------------------------------------

FILE MABuildTool.p
 Copyright © 1986-1990 Apple Computer, Inc.  All rights reserved.

	Modified by Matteo Vaccari to avoid generating -elem881 when -needsFPU is set.


NAME
 MABuild -- process MABuild options

SYNOPSIS
 MABuild

DESCRIPTION
------------------------------------------------------------------------------}
PROGRAM MABuild;

	USES
		{ • MacApp }
		UMacApp, UAssociation,

		{ • Building Blocks }
		UMPWTool,

		{ • Required for this unit's interface }

		{ • Implementation use }
		Memory, CursorCtl, Signal, PasLibIntf, IntEnv, ToolUtils, OSUtils, Packages;

	CONST
		{ Keyword IDs }
		kwAsm				= 1;
		kwC 				= 2;
		kwCPlus 			= 3;
		kwLib				= 4;
		kwLink				= 5;
		kwMake				= 6;
		kwPascal			= 7;
		kwRez				= 8;
		kwPostRez			= 9;
		kwd 				= 10;
		kwRenameFlag		= 11;
		kwPP				= 12;
		kwNoPP				= 13;
		kwTT				= 14;
		kwNoTT				= 15;
		kwAlign 			= 16;
		kwNoAlign			= 17;
		kwSeparateObjects	= 18;
		kwNoSeparateObjects = 19;
		kwExecute			= 20;
		kwNoExecute 		= 21;
		kwFail				= 22;
		kwNoFail			= 23;
		kwLinkMap			= 24;
		kwNoLinkMap 		= 25;
		kwLinkXRef			= 26;
		kwNoLinkXRef		= 27;
		kwAutoBuild 		= 28;
		kwNoAutoBuild		= 29;
		kwUserAutoBuild 	= 30;
		kwNoUserAutoBuild	= 31;
		kwMacApp			= 32;
		kwNoMacApp			= 33;
		kwDebugTheDebugger	= 34;
		kwNoDebugTheDebugger = 35;
		kwDebug 			= 36;
		kwNoDebug			= 37;
		kwBottleNeck		= 38;
		kwNoBottleNeck		= 39;
		kwExpandEnvVars 	= 40;
		kwNoExpandEnvVars	= 41;
		kwSave				= 42;
		kwNoSave			= 43;
		kwRun				= 44;
		kwNoRun 			= 45;
		kwInspector 		= 47;
		kwNoInspector		= 48;
		kwUnInit			= 49;
		kwNoUnInit			= 50;
		kwRangeCheck		= 51;
		kwNoRangeCheck		= 52;
		kwNames 			= 53;
		kwNoNames			= 54;
		kwSym				= 55;
		kwNoSym 			= 56;
		kwTrace 			= 57;
		kwNoTrace			= 58;
		kwNeedsROM128k		= 59;
		kwNoNeedsROM128k	= 60;
		kwNeedsColorQD		= 61;
		kwNoNeedsColorQD	= 62;
		kwPerform			= 63;
		kwNoPerform 		= 64;
		kwNeedsSystem6		= 65;
		kwNoNeedsSystem6	= 66;
		kwROM128K			= 67;
		kwNeedsMC68020		= 68;
		kwNoNeedsMC68020	= 69;
		kwNeedsMC68030		= 70;
		kwNoNeedsMC68030	= 71;
		kwNeedsFPU			= 72;
		kwNoNeedsFPU		= 73;
		kwTemplateViews 	= 76;
		kwNoTemplateViews	= 77;
		kwStatusOnly		= 80;
		kwNoStatusOnly		= 81;
		kwE 				= 82;
		kwR 				= 83;
		kwS 				= 84;

		kwMALibrary 		= 85;
		kwNoMALibrary		= 86;

		kwCPlusSupport		= 87;
		kwNoCPlusSupport	= 88;

		kwExperimentalAndUnsupported = 89;
		kwNoExperimentalAndUnsupported = 90;

		kwPasLoad			= 91;
		kwNoPasLoad 		= 92;

		kwCPlusLoad 		= 93;
		kwNoCPlusLoad		= 94;

		kHelpStr			= 129;						{ Resource ID of the stringlist printed for
														 help }

	TYPE
		PText				= ^TEXT;

		TStringHandle		= OBJECT (TObject)
			fHandle:			Handle;
			PROCEDURE TStringHandle.WriteToFile(theFile: PText);
			PROCEDURE TStringHandle.Catenate(theString: Str255);
			PROCEDURE TStringHandle.CatenateToFront(theString: Str255);
			PROCEDURE TStringHandle.IStringHandle;
			FUNCTION TStringHandle.AsStr255: Str255;
			PROCEDURE TStringHandle.Free; OVERRIDE;
			END;

		TMABuildTool		= OBJECT (TMPWTool)
			fMacApp:			Boolean;

			fDebugTheDebugger:	Boolean;
			fDebug: 			Boolean;
			fInspector: 		Boolean;
			fNames: 			Boolean;
			fRangeCheck:		Boolean;
			fPerform:			Boolean;
			fSym:				Boolean;
			fTrace: 			Boolean;
			fUnInit:			Boolean;
			fAlign: 			Boolean;
			fSeparateObjects:	Boolean;
			fSeparateObjectsFolder: Str255;
			fMALibrary: 		Boolean;
			fPasLoad:			Boolean;				{ Make Pascal's symbol table dumps external
														 files instead of the default of using the
														 source file's resource fork }
			fCPlusLoad: 		Boolean;				{ Create load/dump files for C++ }

			fCPlusSupport:		Boolean;
			fExperimentalAndUnsupported: Boolean;		{ True if the user want to flirt with
														 certain destruction }

			fNeedsColorQD:		Boolean;
			fNeedsMC68020:		Boolean;
			fNeedsMC68030:		Boolean;
			fNeedsFPU:			Boolean;
			fNeedsSystem6:		Boolean;
			fNeedsROM128K:		Boolean;
			fTemplateViews: 	Boolean;

			fAllProgress:		Boolean;
			fExecute:			Boolean;
			fAutoBuild: 		Boolean;
			fUserAutoBuild: 	Boolean;
			fNoFail:			Boolean;
			fLinkMap:			Boolean;
			fLinkXRef:			Boolean;
			fStatusOnly:		Boolean;
			fTimes: 			Boolean;
			fRunAfterBuild: 	Boolean;
			fSaveBeforeBuild:	Boolean;
			fBottleNeckedDispatching: Boolean;
			fExpandEnvironmentVars: Boolean;

			fEverExported:		Boolean;				{ only need to export once }

			fAsmOptions:		TStringHandle;
			fCOptions:			TStringHandle;
			fCPlusOptions:		TStringHandle;
			fEchoOptions:		TStringHandle;
			fLibOptions:		TStringHandle;
			fLinkOptions:		TStringHandle;
			fMakeOptions:		TStringHandle;
			fPascalOptions: 	TStringHandle;
			fRezOptions:		TStringHandle;
			fPostRezOptions:	TStringHandle;

			fTargStringList:	TList;
			fOptionFlags:		TStringHandle;

			fOutputFile:		PText;

			fRenameFlagsPairs:	TAssociation;

			PROCEDURE TMABuildTool.IMABuildTool;

			PROCEDURE TMABuildTool.DoProcessFileArg(arg: Str255); OVERRIDE;
			PROCEDURE TMABuildTool.DoProcessOptionArg(kw: integer); OVERRIDE;
			PROCEDURE TMABuildTool.DoShowUsage; OVERRIDE;
			PROCEDURE TMABuildTool.DoStartProgress; OVERRIDE;
			PROCEDURE TMABuildTool.DoToolAction; OVERRIDE;
			PROCEDURE TMABuildTool.DoAllTargets;
			PROCEDURE TMABuildTool.InstallKeyWords; OVERRIDE;
			PROCEDURE TMABuildTool.EachSourceToolOptionStringDo(PROCEDURE
																DoToOptionString(itsStringHandle:
																				 TStringHandle));
			PROCEDURE TMABuildTool.CatenateToSourceOptionStrings(newText: Str255);
			PROCEDURE TMABuildTool.Echo(aStr: Str255);
			PROCEDURE TMABuildTool.Execute(aStr: Str255);
			PROCEDURE TMABuildTool.SetIE(theVariable: Str255;
										 theValue: Str255); { output a set instruction }
			FUNCTION TMABuildTool.Exists(theFile: Str255): Boolean;
			END;

	VAR
		gMABuildTool:		TMABuildTool;				{ The tool }
		aFile:				TEXT;						{ output file if specified with -o }
		gDirectorySeparator: Str255;					{ : or / as required by host filesystem }
		StartPath:			Str255;

{--------------------------------------------------------------------------------------------------}
		{$S TRes}

	FUNCTION NewTStringHandle: TStringHandle;

		VAR
			aTStringHandle: 	TStringHandle;

		BEGIN
		New(aTStringHandle);
		aTStringHandle.IStringHandle;
		NewTStringHandle := aTStringHandle;
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TStringHandle.WriteToFile(theFile: PText);

		VAR
			remaining:			integer;
			aString:			Str255;
			thisTime, offset:	integer;

		BEGIN
		remaining := GetHandleSize(fHandle);
		offset := 0;
		WHILE remaining > 0 DO
			BEGIN
			IF remaining > 255 THEN
				thisTime := 255
			ELSE
				thisTime := remaining;
			remaining := remaining - thisTime;
			BlockMove(Ptr(ord(fHandle^) + offset), Ptr(@aString[1]), thisTime);
			offset := offset + thisTime;
			aString[0] := chr(thisTime);
			Write(theFile^, aString);
			END;
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	FUNCTION TStringHandle.AsStr255: Str255;

		VAR
			aString:			Str255;

		BEGIN
		aString[0] := chr(min(GetHandleSize(fHandle), 255));
		BlockMove(fHandle^, Ptr(@aString[1]), length(aString));
		AsStr255 := aString;
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TStringHandle.IStringHandle;

		VAR
			aHandle:			Handle;

		BEGIN
		fHandle := NIL;
		aHandle := NewHandle(0);
		FailNil(aHandle);
		fHandle := aHandle;
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TStringHandle.Free;

		BEGIN
		DisposIfHandle(fHandle);
		inherited Free;
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TStringHandle.Catenate(theString: Str255);

		VAR
			aLong:				Longint;

		BEGIN
		aLong := Munger(fHandle, GetHandleSize(fHandle), NIL, 0, { force insertion }
						Ptr(@theString[1]), length(theString));
		FailMemError;
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TStringHandle.CatenateToFront(theString: Str255);

		VAR
			aLong:				Longint;

		BEGIN
		aLong := Munger(fHandle, 0, NIL, 0, 			{ force insertion }
						Ptr(@theString[1]), length(theString));
		FailMemError;
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TMABuildTool.DoShowUsage;

		VAR
			theHelpString:		Str255;
			i:					integer;

		BEGIN
		PLFlush(diagnostic);
		PLSetVBuf(diagnostic, NIL, _IOFBF, 4096);

		{ output each string in the stringlist }
		i := 1;
		GetIndString(theHelpString, kHelpStr, i);
		WHILE (theHelpString <> '') DO
			BEGIN
			WriteLn(diagnostic, theHelpString);
			i := succ(i);
			GetIndString(theHelpString, kHelpStr, i);
			END;
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TInit}

	PROCEDURE TMABuildTool.DoProcessFileArg(arg: Str255);

		VAR
			aStringHandle:		TStringHandle;

		BEGIN
		{ Special case for MacApp as target for backward compatibility (until post 2.0)}
		IF EqualString(arg, 'MacApp', FALSE, TRUE) THEN
			fAutoBuild := TRUE
		ELSE
			BEGIN
			aStringHandle := NewTStringHandle;
			aStringHandle.Catenate(arg);
			fTargStringList.InsertLast(aStringHandle);
			END;
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TInit}

	PROCEDURE TMABuildTool.DoStartProgress;

		VAR
			theDateTimeString:	Str255;

		BEGIN
		IUTimeString(fStartDateTime, TRUE, theDateTimeString);
		Write(diagnostic, gProgName, ' - v. 2.0 Release ', compdate, '          Start: ',
			  theDateTimeString);

		IUDateString(fStartDateTime, shortDate, theDateTimeString);
		WriteLn(diagnostic, ' ', theDateTimeString);

		WriteLn(diagnostic);
		WriteLn(diagnostic, 'Copyright Apple Computer, Inc. 1986-1990');
		WriteLn(diagnostic, 'All Rights Reserved.');
		WriteLn(diagnostic);
		PLFlush(diagnostic);
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TMABuildTool.EachSourceToolOptionStringDo(PROCEDURE
														DoToOptionString(itsStringHandle:
																		 TStringHandle));

		BEGIN
		DoToOptionString(fAsmOptions);
		DoToOptionString(fCOptions);
		DoToOptionString(fCPlusOptions);
		DoToOptionString(fMakeOptions);
		DoToOptionString(fPascalOptions);
		DoToOptionString(fRezOptions);
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TMABuildTool.CatenateToSourceOptionStrings(newText: Str255);

		PROCEDURE DoToOptionString(itsStringHandle: TStringHandle);

			BEGIN
			itsStringHandle.Catenate(newText);
			END;

		BEGIN
		EachSourceToolOptionStringDo(DoToOptionString);
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TInit}

	PROCEDURE TMABuildTool.DoProcessOptionArg(kw: integer);

		VAR
			theNextArg: 		Str255;

		BEGIN
		CASE kw OF
			kwAsm:
				BEGIN
				fAsmOptions.Catenate(' ');
				fAsmOptions.Catenate(GetNextArg);
				END;

			kwC:
				BEGIN
				fCOptions.Catenate(' ');
				fCOptions.Catenate(GetNextArg);
				END;

			kwCPlus:
				BEGIN
				fCPlusOptions.Catenate(' ');
				fCPlusOptions.Catenate(GetNextArg);
				END;

			kwLib:
				BEGIN
				fLibOptions.Catenate(' ');
				fLibOptions.Catenate(GetNextArg);
				END;

			kwLink:
				BEGIN
				fLinkOptions.Catenate(' ');
				fLinkOptions.Catenate(GetNextArg);
				END;

			kwMake:
				BEGIN
				fMakeOptions.Catenate(' ');
				fMakeOptions.Catenate(GetNextArg);
				END;

			kwPascal:
				BEGIN
				fPascalOptions.Catenate(' ');
				fPascalOptions.Catenate(GetNextArg);
				END;

			kwRez:
				BEGIN
				fRezOptions.Catenate(' ');
				fRezOptions.Catenate(GetNextArg);
				END;

			kwPostRez:
				BEGIN
				fPostRezOptions.Catenate(' ');
				fPostRezOptions.Catenate(GetNextArg);
				END;

			kwd:
				BEGIN
				theNextArg := GetNextArg;

				fAsmOptions.Catenate(' -d ');
				fAsmOptions.Catenate(theNextArg);

				fCOptions.Catenate(' -d ');
				fCOptions.Catenate(theNextArg);

				fCPlusOptions.Catenate(' -d ');
				fCPlusOptions.Catenate(theNextArg);

				fMakeOptions.Catenate(' -d ');
				fMakeOptions.Catenate(theNextArg);

				fPascalOptions.Catenate(' -d ');
				fPascalOptions.Catenate(theNextArg);

				fRezOptions.Catenate(' -d ');
				fRezOptions.Catenate(theNextArg);

				END;

			kwRenameFlag:
				BEGIN
				fRenameFlagsPairs.InsertEntry(GetNextArg, GetNextArg);
				END;

			kwPP:
				BEGIN
				fAllProgress := TRUE;
				fProgress := TRUE;
				END;
			kwNoPP:
				BEGIN
				fAllProgress := FALSE;
				fProgress := FALSE;
				END;

			kwTT:
				BEGIN
				fTimes := TRUE;
				fTime := TRUE;
				END;
			kwNoTT:
				BEGIN
				fTimes := FALSE;
				fTime := FALSE;
				END;

			kwAlign:
				fAlign := TRUE;
			kwNoAlign:
				fAlign := FALSE;

			kwSeparateObjects:
				fSeparateObjects := TRUE;
			kwNoSeparateObjects:
				fSeparateObjects := FALSE;

			kwExecute:
				fExecute := TRUE;
			kwNoExecute:
				fExecute := FALSE;

			kwFail:
				fNoFail := FALSE;
			kwNoFail:
				fNoFail := TRUE;

			kwLinkMap:
				fLinkMap := TRUE;
			kwNoLinkMap:
				fLinkMap := FALSE;

			kwLinkXRef:
				fLinkXRef := TRUE;
			kwNoLinkXRef:
				fLinkXRef := FALSE;

			kwAutoBuild:
				fAutoBuild := TRUE;
			kwNoAutoBuild:
				fAutoBuild := FALSE;

			kwUserAutoBuild:
				fUserAutoBuild := TRUE;
			kwNoUserAutoBuild:
				fUserAutoBuild := FALSE;

			kwMacApp:
				fMacApp := TRUE;
			kwNoMacApp:
				fMacApp := FALSE;

			kwDebugTheDebugger:
				fDebugTheDebugger := TRUE;
			kwNoDebugTheDebugger:
				fDebugTheDebugger := FALSE;

			kwDebug:
				BEGIN
				fDebug := TRUE;
				fInspector := TRUE;
				fUnInit := TRUE;
				fPerform := TRUE;
				fRangeCheck := TRUE;
				fTrace := TRUE;
				fNames := TRUE;
				fBottleNeckedDispatching := TRUE;
				END;
			kwNoDebug:
				BEGIN
				fDebug := FALSE;
				fInspector := FALSE;
				fUnInit := FALSE;
				fPerform := FALSE;
				fRangeCheck := FALSE;
				fTrace := FALSE;
				fNames := FALSE;
				fBottleNeckedDispatching := FALSE;
				END;

			kwBottleNeck:
				fBottleNeckedDispatching := TRUE;
			kwNoBottleNeck:
				fBottleNeckedDispatching := FALSE;

			kwExpandEnvVars:
				fExpandEnvironmentVars := TRUE;
			kwNoExpandEnvVars:
				fExpandEnvironmentVars := FALSE;

			kwSave:
				fSaveBeforeBuild := TRUE;
			kwNoSave:
				fSaveBeforeBuild := FALSE;

			kwRun:
				fRunAfterBuild := TRUE;
			kwNoRun:
				fRunAfterBuild := FALSE;

			kwInspector:
				fInspector := TRUE;
			kwNoInspector:
				fInspector := FALSE;

			kwUnInit:
				fUnInit := TRUE;
			kwNoUnInit:
				fUnInit := FALSE;

			kwRangeCheck:
				fRangeCheck := TRUE;
			kwNoRangeCheck:
				fRangeCheck := FALSE;

			kwNames:
				fNames := TRUE;
			kwNoNames:
				fNames := FALSE;

			kwSym:
				fSym := TRUE;
			kwNoSym:
				fSym := FALSE;

			kwTrace:
				fTrace := TRUE;
			kwNoTrace:
				fTrace := FALSE;

			kwNeedsROM128k:
				fNeedsROM128K := TRUE;
			kwNoNeedsROM128k:
				fNeedsROM128K := FALSE;

			kwNeedsColorQD:
				fNeedsColorQD := TRUE;
			kwNoNeedsColorQD:
				fNeedsColorQD := FALSE;

			kwPerform:
				fPerform := TRUE;
			kwNoPerform:
				fPerform := FALSE;

			kwNeedsSystem6:
				fNeedsSystem6 := TRUE;
			kwNoNeedsSystem6:
				fNeedsSystem6 := FALSE;

			kwROM128K:
				fNeedsROM128K := TRUE;

			kwNeedsMC68020:
				fNeedsMC68020 := TRUE;
			kwNoNeedsMC68020:
				fNeedsMC68020 := FALSE;

			kwNeedsMC68030:
				fNeedsMC68030 := TRUE;
			kwNoNeedsMC68030:
				fNeedsMC68030 := FALSE;

			kwNeedsFPU:
				fNeedsFPU := TRUE;
			kwNoNeedsFPU:
				fNeedsFPU := FALSE;

			kwTemplateViews:
				fTemplateViews := TRUE;
			kwNoTemplateViews:
				fTemplateViews := FALSE;

			kwStatusOnly:
				BEGIN
				fExecute := FALSE;
				fStatusOnly := TRUE;
				END;
			kwNoStatusOnly:
				BEGIN
				fExecute := TRUE;
				fStatusOnly := FALSE;
				END;

			kwE:
				fMakeOptions.Catenate(' -e');

			kwR:
				BEGIN
				fExecute := FALSE;
				fStatusOnly := TRUE;
				fMakeOptions.Catenate(' -r');
				END;

			kwS:
				BEGIN
				fExecute := FALSE;
				fStatusOnly := TRUE;
				fMakeOptions.Catenate(' -s');
				END;

			kwMALibrary:
				BEGIN
				fMALibrary := TRUE;
				END;

			kwNoMALibrary:
				BEGIN
				fMALibrary := FALSE;
				END;

			kwPasLoad:
				BEGIN
				fPasLoad := TRUE;
				END;

			kwNoPasLoad:
				BEGIN
				fPasLoad := FALSE;
				END;

			kwCPlusLoad:
				BEGIN
				fCPlusLoad := TRUE;
				END;

			kwNoCPlusLoad:
				BEGIN
				fCPlusLoad := FALSE;
				END;

			kwCPlusSupport:
				BEGIN
				fCPlusSupport := TRUE;
				END;

			kwNoCPlusSupport:
				BEGIN
				fCPlusSupport := FALSE;
				END;

			kwExperimentalAndUnsupported:
				BEGIN
				fExperimentalAndUnsupported := TRUE;
				END;

			kwNoExperimentalAndUnsupported:
				BEGIN
				fExperimentalAndUnsupported := FALSE;
				END;

			OTHERWISE
				inherited DoProcessOptionArg(kw);
		END;

		END;

{--------------------------------------------------------------------------------------------------}
	{$S TInit}

	PROCEDURE TMABuildTool.IMABuildTool;

		VAR
			anAssociation:		TAssociation;
			aString:			Str255;

		BEGIN
		ITool;

		{ Try to get the appropriate separator character for directories }
		IF IEGetEnv('MADirectorySeparator', aString) THEN
			gDirectorySeparator := aString
		ELSE
			gDirectorySeparator := ':';

		fOutputFile := @Output;
		PLFlush(fOutputFile^);
		PLSetVBuf(fOutputFile^, NIL, _IOFBF, 8192);

		fRenameFlagsPairs := NIL;
		New(anAssociation);
		anAssociation.IAssociation;
		fRenameFlagsPairs := anAssociation;

		{ setup the default options }
		fMacApp := TRUE;

		fDebugTheDebugger := FALSE;

		fDebug := FALSE;
		fInspector := FALSE;
		fNames := FALSE;
		fPerform := FALSE;
		fRangeCheck := FALSE;
		fSym := FALSE;
		fTrace := FALSE;
		fUnInit := FALSE;
		fAlign := TRUE;
		fSeparateObjects := TRUE;
		fSeparateObjectsFolder := '';
		fMALibrary := TRUE;

		fPasLoad := FALSE;
		fCPlusLoad := FALSE;

		fCPlusSupport := FALSE;
		fExperimentalAndUnsupported := FALSE;

		fNeedsColorQD := FALSE;
		fNeedsMC68020 := FALSE;
		fNeedsMC68030 := FALSE;
		fNeedsFPU := FALSE;
		fNeedsSystem6 := FALSE;
		fNeedsROM128K := TRUE;
		fTemplateViews := TRUE;

		fAllProgress := FALSE;
		fExecute := TRUE;
		fAutoBuild := FALSE;
		fUserAutoBuild := TRUE;
		fNoFail := FALSE;
		fProgress := FALSE;
		fStatusOnly := FALSE;
		fTimes := FALSE;
		fLinkMap := FALSE;
		fLinkXRef := FALSE;
		fBottleNeckedDispatching := FALSE;
		fRunAfterBuild := FALSE;
		fSaveBeforeBuild := FALSE;
		fExpandEnvironmentVars := FALSE;

		fEverExported := FALSE;

		fAsmOptions := NIL;
		fCOptions := NIL;
		fCPlusOptions := NIL;
		fEchoOptions := NIL;
		fLibOptions := NIL;
		fLinkOptions := NIL;
		fMakeOptions := NIL;
		fPascalOptions := NIL;
		fRezOptions := NIL;
		fPostRezOptions := NIL;

		fAsmOptions := NewTStringHandle;
		fCOptions := NewTStringHandle;
		fCPlusOptions := NewTStringHandle;
		fEchoOptions := NewTStringHandle;
		fLibOptions := NewTStringHandle;
		fLinkOptions := NewTStringHandle;
		fMakeOptions := NewTStringHandle;
		fPascalOptions := NewTStringHandle;
		fRezOptions := NewTStringHandle;
		fPostRezOptions := NewTStringHandle;

		fEchoOptions := NIL;
		fTargStringList := NIL;
		fOptionFlags := NIL;

		fEchoOptions := NewTStringHandle;

		fTargStringList := NewList;

		fOptionFlags := NewTStringHandle;

		END;

{--------------------------------------------------------------------------------------------------}
	{$S TInit}

	PROCEDURE TMABuildTool.InstallKeyWords;

		BEGIN
		inherited InstallKeyWords;

		InstallKeyWord('Asm', kwAsm);
		InstallKeyWord('C', kwC);
		InstallKeyWord('CPlus', kwCPlus);
		InstallKeyWord('Lib', kwLib);
		InstallKeyWord('Link', kwLink);
		InstallKeyWord('Make', kwMake);
		InstallKeyWord('Pascal', kwPascal);
		InstallKeyWord('Rez', kwRez);
		InstallKeyWord('PostRez', kwPostRez);
		InstallKeyWord('d', kwd);
		InstallKeyWord('RenameFlag', kwRenameFlag);
		InstallKeyWord('PP', kwPP);
		InstallKeyWord('NoPP', kwNoPP);
		InstallKeyWord('TT', kwTT);
		InstallKeyWord('NoTT', kwNoTT);
		InstallKeyWord('Align', kwAlign);
		InstallKeyWord('NoAlign', kwNoAlign);
		InstallKeyWord('SeparateObjects', kwSeparateObjects);
		InstallKeyWord('NoSeparateObjects', kwNoSeparateObjects);
		InstallKeyWord('Execute', kwExecute);
		InstallKeyWord('NoExecute', kwNoExecute);
		InstallKeyWord('Fail', kwFail);
		InstallKeyWord('NoFail', kwNoFail);
		InstallKeyWord('LinkMap', kwLinkMap);
		InstallKeyWord('NoLinkMap', kwNoLinkMap);
		InstallKeyWord('LinkXRef', kwLinkXRef);
		InstallKeyWord('NoLinkXRef', kwNoLinkXRef);
		InstallKeyWord('AutoBuild', kwAutoBuild);
		InstallKeyWord('NoAutoBuild', kwNoAutoBuild);
		InstallKeyWord('UserAutoBuild', kwUserAutoBuild);
		InstallKeyWord('NoUserAutoBuild', kwNoUserAutoBuild);
		InstallKeyWord('MacApp', kwMacApp);
		InstallKeyWord('NoMacApp', kwNoMacApp);
		InstallKeyWord('DebugTheDebugger', kwDebugTheDebugger);
		InstallKeyWord('NoDebugTheDebugger', kwNoDebugTheDebugger);
		InstallKeyWord('Debug', kwDebug);
		InstallKeyWord('NoDebug', kwNoDebug);
		InstallKeyWord('BottleNeck', kwBottleNeck);
		InstallKeyWord('NoBottleNeck', kwNoBottleNeck);
		InstallKeyWord('ExpandEnvVars', kwExpandEnvVars);
		InstallKeyWord('NoExpandEnvVars', kwNoExpandEnvVars);
		InstallKeyWord('Save', kwSave);
		InstallKeyWord('NoSave', kwNoSave);
		InstallKeyWord('Run', kwRun);
		InstallKeyWord('NoRun', kwNoRun);
		InstallKeyWord('Inspector', kwInspector);
		InstallKeyWord('NoInspector', kwNoInspector);
		InstallKeyWord('UnInit', kwUnInit);
		InstallKeyWord('NoUnInit', kwNoUnInit);
		InstallKeyWord('RangeCheck', kwRangeCheck);
		InstallKeyWord('NoRangeCheck', kwNoRangeCheck);
		InstallKeyWord('Names', kwNames);
		InstallKeyWord('NoNames', kwNoNames);
		InstallKeyWord('Sym', kwSym);
		InstallKeyWord('NoSym', kwNoSym);
		InstallKeyWord('Trace', kwTrace);
		InstallKeyWord('NoTrace', kwNoTrace);
		InstallKeyWord('NeedsROM128k', kwNeedsROM128k);
		InstallKeyWord('NoNeedsROM128k', kwNoNeedsROM128k);
		InstallKeyWord('NeedsColorQD', kwNeedsColorQD);
		InstallKeyWord('NoNeedsColorQD', kwNoNeedsColorQD);
		InstallKeyWord('Perform', kwPerform);
		InstallKeyWord('NoPerform', kwNoPerform);
		InstallKeyWord('NeedsSystem6', kwNeedsSystem6);
		InstallKeyWord('NoNeedsSystem6', kwNoNeedsSystem6);
		InstallKeyWord('ROM128K', kwROM128K);
		InstallKeyWord('NeedsMC68020', kwNeedsMC68020);
		InstallKeyWord('NoNeedsMC68020', kwNoNeedsMC68020);
		InstallKeyWord('NeedsMC68030', kwNeedsMC68030);
		InstallKeyWord('NoNeedsMC68030', kwNoNeedsMC68030);
		InstallKeyWord('NeedsFPU', kwNeedsFPU);
		InstallKeyWord('NoNeedsFPU', kwNoNeedsFPU);
		InstallKeyWord('TemplateViews', kwTemplateViews);
		InstallKeyWord('NoTemplateViews', kwNoTemplateViews);
		InstallKeyWord('StatusOnly', kwStatusOnly);
		InstallKeyWord('NoStatusOnly', kwNoStatusOnly);
		InstallKeyWord('E', kwE);
		InstallKeyWord('R', kwR);
		InstallKeyWord('S', kwS);
		InstallKeyWord('PasLoad', kwPasLoad);
		InstallKeyWord('NoPasLoad', kwNoPasLoad);

		InstallKeyWord('CPlusLoad', kwCPlusLoad);
		InstallKeyWord('NoCPlusLoad', kwNoCPlusLoad);

		InstallKeyWord('MALibrary', kwMALibrary);
		InstallKeyWord('NoMALibrary', kwNoMALibrary);

		InstallKeyWord('CPlusSupport', kwCPlusSupport);
		InstallKeyWord('NoCPlusSupport', kwNoCPlusSupport);

		InstallKeyWord('ExperimentalAndUnsupported', kwExperimentalAndUnsupported);
		InstallKeyWord('NoExperimentalAndUnsupported', kwNoExperimentalAndUnsupported);

		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TMABuildTool.Execute(aStr: Str255);

		BEGIN
		WriteLn(fOutputFile^, aStr);
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TMABuildTool.SetIE(theVariable: Str255;
								 theValue: Str255);

		BEGIN
		WriteLn(fOutputFile^, 'SET ', theVariable, ' "', theValue, '"');
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TMABuildTool.Echo(aStr: Str255);

		BEGIN
		Write(fOutputFile^, '{MAEcho} ');
		WriteLn(fOutputFile^, aStr);
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	FUNCTION TMABuildTool.Exists(theFile: Str255): Boolean;
	{ Return true if the file or directory exists }

		VAR
			fndrInfo:			FInfo;
			aCInfoPBRec:		CInfoPBRec;

		BEGIN
		WITH aCInfoPBRec DO
			BEGIN
			ioCompletion := NIL;
			ioNamePtr := @theFile;
			ioVRefNum := 0;
			ioFRefNum := 0;
			ioFDirIndex := 0;
			ioDirID := 0;
			END;

		Exists := (PBGetCatInfo(@aCInfoPBRec, FALSE) = noErr) & (aCInfoPBRec.IOResult = noErr);
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TMABuildTool.DoAllTargets;

		VAR
			aTStringHandle: 	TStringHandle;
			aString, bString, XAppPath, XAppName, MAMakeFileExtension, MASetupExtension: Str255;
			ObjApp, SrcApp, SeparateObjectsFolder, BuildFlags, MABuildFlagsExtension: Str255;
			i:					integer;
			automake, autorez, anyPascal, anyCPlus: Boolean;
			dirID:				Longint;
			MAShellVersion: 	Str255;

		BEGIN
		{ Process every target in fTargStringList }
		aTStringHandle := TStringHandle(fTargStringList.First);

		WHILE aTStringHandle <> NIL DO
			BEGIN
			fTargStringList.Delete(aTStringHandle);

			aString := aTStringHandle.AsStr255; 		{ Paths can't currently be longer than this
														 anyways! (MPW 3.1)}

			aTStringHandle.Free;

			{ find the pathname and filename }
			XAppName := aString;
			XAppPath := '';
			FOR i := length(aString) DOWNTO 1 DO
				BEGIN
				IF Copy(aString, i, length(gDirectorySeparator)) = gDirectorySeparator THEN
					BEGIN
					XAppName := Copy(aString, i + 1, length(aString) - i);
					XAppPath := Copy(aString, 1, i);
					LEAVE;
					END
				END;

			{ Automatically trim .MAMake off the target name if it was specified }
			IF IEGetEnv('MAMakeFileExtension', MAMakeFileExtension) & (MAMakeFileExtension <>
			   '') THEN
				BEGIN
				aString := MAMakeFileExtension;
				bString := XAppName;
				UprStr255(aString);
				UprStr255(bString);
				i := pos(aString, bString);
				IF (i <> 0) & (i + length(MAMakeFileExtension) - 1 = length(XAppName)) THEN
					Delete(XAppName, i, length(MAMakeFileExtension));
				END;

			{ Blank path is current path }
			IF XAppPath = '' THEN
				XAppPath := StartPath;

			SetIE('XAppPath', XAppPath);
			SetIE('XAppName', XAppName);

			{ Check for the  MASetupExtension file }
			IF IEGetEnv('MASetupExtension', MASetupExtension) & Exists(concat(XAppPath, XAppName,
																	   MASetupExtension)) THEN
				WriteLn(fOutputFile^, 'EXECUTE "', concat(XAppPath, XAppName, MASetupExtension),
						'"');

			{ Process separate objects into the source and object pathnames… }
			SeparateObjectsFolder := fSeparateObjectsFolder;
			ObjApp := concat(XAppPath, SeparateObjectsFolder);
			SrcApp := XAppPath;
			SetIE('ObjApp', ObjApp);
			SetIE('SrcApp', SrcApp);

			IF fProgress THEN
				Echo('"Target Folder: ∂"{ObjApp}∂""');

			{ Linkmap and LinkXref }
			IF fLinkMap THEN
				BEGIN
				IF fPerform THEN
					SetIE('XLinkMap', '-la -lf -l > ∂''{ObjApp}{XAppName}.map∂'' ')
				ELSE
					SetIE('XLinkMap', '-la -lf -map > ∂''{ObjApp}{XAppName}.map∂'' ');
				END
			ELSE
				SetIE('XLinkMap', '');

			IF fLinkXRef THEN
				SetIE('XLinkXRef', '-x ∂''{ObjApp}{XAppName}.xref∂'' ')
			ELSE
				SetIE('XLinkXRef', '');

			{ Get various file names for autodependencies }
			{ in Pascal }
			anyPascal := FALSE;
			IF Exists(concat(SrcApp, 'U', XAppName, '.p')) THEN
				BEGIN
				anyPascal := TRUE;
				SetIE('XUAppName.p', concat(SrcApp, 'U', XAppName, '.p'));
				SetIE('XUAppName.p.o', concat(ObjApp, 'U', XAppName, '.p.o'));
				END
			ELSE
				BEGIN
				SetIE('XUAppName.p', '');
				SetIE('XUAppName.p.o', '');
				END;

			IF Exists(concat(SrcApp, 'M', XAppName, '.p')) THEN
				BEGIN
				anyPascal := TRUE;
				SetIE('XMAppName.p', concat(SrcApp, 'M', XAppName, '.p'));
				SetIE('XMAppName.p.o', concat(ObjApp, 'M', XAppName, '.p.o'));
				END
			ELSE
				BEGIN
				SetIE('XMAppName.p', '');
				SetIE('XMAppName.p.o', '');
				END;

			IF Exists(concat(SrcApp, XAppName, '.p')) THEN
				BEGIN
				anyPascal := TRUE;
				SetIE('XAppName.p', concat(SrcApp, XAppName, '.p'));
				SetIE('XAppName.p.o', concat(ObjApp, XAppName, '.p.o'));
				END
			ELSE
				BEGIN
				SetIE('XAppName.p', '');
				SetIE('XAppName.p.o', '');
				END;

			{ you should wonder at how long this next chunk took to write! }
			SetIE('EXIT', '0');
			SetIE('XUAppName.inc.p', '`(Files "{SrcApp}"U{XAppName}.≈.p) ≥ dev:null`');
			SetIE('EXIT', '1');

			{ in C++ }
			anyCPlus := FALSE;
			IF Exists(concat(SrcApp, 'U', XAppName, '.h')) THEN
				BEGIN
				anyCPlus := TRUE;
				fCPlusSupport := TRUE;
				SetIE('XUAppName.h', concat(SrcApp, 'U', XAppName, '.h'));
				END
			ELSE
				BEGIN
				SetIE('XUAppName.h', '');
				END;

			IF Exists(concat(SrcApp, 'U', XAppName, '.cp')) THEN
				BEGIN
				anyCPlus := TRUE;
				fCPlusSupport := TRUE;
				SetIE('XUAppName.cp', concat(SrcApp, 'U', XAppName, '.cp'));
				SetIE('XUAppName.cp.o', concat(ObjApp, 'U', XAppName, '.cp.o'));
				END
			ELSE
				BEGIN
				SetIE('XUAppName.cp', '');
				SetIE('XUAppName.cp.o', '');
				END;

			IF Exists(concat(SrcApp, 'M', XAppName, '.cp')) THEN
				BEGIN
				anyCPlus := TRUE;
				fCPlusSupport := TRUE;
				SetIE('XMAppName.cp', concat(SrcApp, 'M', XAppName, '.cp'));
				SetIE('XMAppName.cp.o', concat(ObjApp, 'M', XAppName, '.cp.o'));
				END
			ELSE
				BEGIN
				SetIE('XMAppName.cp', '');
				SetIE('XMAppName.cp.o', '');
				END;

			IF Exists(concat(SrcApp, XAppName, '.cp')) THEN
				BEGIN
				anyCPlus := TRUE;
				fCPlusSupport := TRUE;
				SetIE('XAppName.cp', concat(SrcApp, XAppName, '.cp'));
				SetIE('XAppName.cp.o', concat(ObjApp, XAppName, '.cp.o'));
				END
			ELSE
				BEGIN
				SetIE('XAppName.cp', '');
				SetIE('XAppName.cp.o', '');
				END;

			{ See if we can automake it }
			IF NOT Exists(concat(XAppPath, XAppName, MAMakeFileExtension)) THEN
				BEGIN
				automake := TRUE;
				IF NOT (anyPascal | anyCPlus) THEN
					BEGIN
					Echo(
'''###'' MABuild: Bad parameter: Unable to access file: "{XAppPath}{XAppName}{MAMakeFileExtension}"'
						 );
					Echo('MABuild of {XAppName} failed: `DATE`');
					Execute('{MAFailed}');

					IF fNoFail THEN
						SetIE('XExitStatus', '1')
					ELSE
						Execute('EXIT 1');
					END
				END
			ELSE
				automake := FALSE;

			{ See if we can autorez it }
			IF NOT Exists(concat(XAppPath, XAppName, '.r')) THEN
				BEGIN
				autorez := TRUE;
				SetIE('XAutoRez', '1');
				SetIE('XAppRezSrc', '{MATools}Default.r');
				END
			ELSE
				BEGIN
				autorez := FALSE;
				SetIE('XAutoRez', '0');
				SetIE('XAppRezSrc', '{XAppPath}{XAppName}.r');
				END;

			{ Make sure separate objects folder exists }
			IF NOT Exists(ObjApp) & (DirCreate(0, 0, ObjApp, dirID) <> noErr) THEN
				BEGIN
				Echo('''###'' MABuild: Unable to create directory: "{ObjApp}"');
				Echo('MABuild of {XAppName} failed: `DATE`');
				Execute('{MAFailed}');

				IF fNoFail THEN
					SetIE('XRunStatus', '1')
				ELSE
					Execute('EXIT 1');
				END;

			{ SET the BuildFlags }
			IF IEGetEnv('MABuildFlagsExtension', MABuildFlagsExtension) THEN;
			BuildFlags := concat(ObjApp, XAppName, MABuildFlagsExtension);
			SetIE('BuildFlags', BuildFlags);

			{ Find out what the last option flags were }
			IF Exists(BuildFlags) THEN
				Execute('EXECUTE "{BuildFlags}" ∑ Dev:Null || SET Status 0')
			ELSE
				SetIE('XLastOptionFlags', 'InvalidString');

			IF fExecute THEN
				BEGIN
				Execute('IF {XLastOptionFlags} != {XOptionFlags}');
			 { the file BuildFlags will contain a SET command to set the value of XLastOptionFlags }
				Echo('"SET XLastOptionFlags {XOptionFlags}"  >  "{BuildFlags}"');
				Execute('END');
				END;

			{ Rebuild the application by creating the "MakeIt" file and then executing it }
			SetIE('XMakeIt', '{ObjApp}{XAppName}{MAMakeOutfileExtension}');

{ SET the failure processing mode in the makeit files and (OPTIONALLY) the active environment vars into the makefile }
			IF fNoFail THEN
				Echo('SET EXIT 0  > "{XMakeIt}"')
			ELSE
				Echo('SET EXIT 1  > "{XMakeIt}"');

			IF fExpandEnvironmentVars THEN
				BEGIN
				IF fStatusOnly THEN
					SetIE('XMakeitRedirection', '')
				ELSE
					SetIE('XMakeitRedirection', ' >> ∂''{XMakeIt}∂''');

				Execute('SET AsmOptions {XMakeitRedirection}');
				Execute('SET BuildFlags {XMakeitRedirection}');
				Execute('SET COptions {XMakeitRedirection}');
				Execute('SET CPlusOptions {XMakeitRedirection}');
				Execute('SET EchoOptions {XMakeitRedirection}');
				Execute('SET LibOptions {XMakeitRedirection}');
				Execute('SET LinkOptions {XMakeitRedirection}');
				Execute('SET MakeOptions {XMakeitRedirection}');
				Execute('SET ObjApp {XMakeitRedirection}');
				Execute('SET PascalOptions {XMakeitRedirection}');
				Execute('SET PostRezOptions {XMakeitRedirection}');
				Execute('SET RezOptions {XMakeitRedirection}');
				Execute('SET SeparateObjectsFolder {XMakeitRedirection}');
				Execute('SET SrcApp {XMakeitRedirection}');
				Execute('SET XAppName {XMakeitRedirection}');
				Execute('SET XAppName.cp {XMakeitRedirection}');
				Execute('SET XAppName.cp.o {XMakeitRedirection}');
				Execute('SET XAppName.p {XMakeitRedirection}');
				Execute('SET XAppName.p.o {XMakeitRedirection}');
				Execute('SET XAppRezSrc {XMakeitRedirection}');
				Execute('SET XAutoRez {XMakeitRedirection}');
				Execute('SET XLinkMap {XMakeitRedirection}');
				Execute('SET XLinkXRef {XMakeitRedirection}');
				Execute('SET XMAppName.cp {XMakeitRedirection}');
				Execute('SET XMAppName.cp.o {XMakeitRedirection}');
				Execute('SET XMAppName.p {XMakeitRedirection}');
				Execute('SET XMAppName.p.o {XMakeitRedirection}');
				Execute('SET XTimes {XMakeitRedirection}');
				Execute('SET XRunAfterBuild {XMakeitRedirection}');
				Execute('SET XUAppName.cp {XMakeitRedirection}');
				Execute('SET XUAppName.cp.o {XMakeitRedirection}');
				Execute('SET XUAppName.h {XMakeitRedirection}');
				Execute('SET XUAppName.p {XMakeitRedirection}');
				Execute('SET XUAppName.p.o {XMakeitRedirection}');
				END;

			{ Export the various and sundry environment variables }
			IF NOT fEverExported THEN
				BEGIN
				fEverExported := TRUE;					{ only need to export once }
				Execute('EXPORT ∂');
				Execute(
	  'AsmOptions BuildFlags COptions CPlusOptions EchoOptions LibOptions LinkOptions MakeOptions ∂'
						);
				Execute(
'ObjApp PascalOptions PostRezOptions RezOptions SeparateObjectsFolder SrcApp XAppName XAppName.cp XAppName.cp.o ∂'
						);
				Execute(
			 'XAppName.p XAppName.p.o XAppRezSrc XAutoRez XLinkMap XLinkXRef XMakeit XMAppName.cp ∂'
						);
				Execute('XMAppName.cp.o XMAppName.p XMAppName.p.o XTimes XRunAfterBuild ∂');
				Execute(
				 'XUAppName.cp XUAppName.cp.o XUAppName.h XUAppName.inc.p XUAppName.p XUAppName.p.o'
						);
				END;

			{ Give user makefile processing status message }
			IF fProgress THEN
				BEGIN
				IF automake THEN
					Echo('"AutoMaking:    {XAppName}"')
				ELSE
					Echo('"Making:        {XAppName}{MAMakeFileExtension}"');
				END;

			IF fTimes THEN
				SetIE('XMakeStartTime', '`DATE -n`');
			SetIE('EXIT', '0');

			{ run make }
			Execute('{MAMake} {MakeOptions} ∂');

			{ Automatically include the CPLus libraries
			and select the proper FPU support.	!!! this is so hinky! (but its better than making MacApp users suffer!) }
			IF fCPlusSupport THEN
				BEGIN
				{ Eliminate Pascal support }
				Execute('-d PascalNonFPUSANELib=  ∂');
				Execute('-d PascalFPUSANELib=  ∂');
				Execute('-d PascalSupport=  ∂');

				{ Check if newer MPW 3.2 support }
				IF IEGetEnv('MAShellVersion', MAShellVersion) & ((Copy(MAShellVersion, 1, 3) <>
				   '3.0') & (Copy(MAShellVersion, 1, 3) <> '3.1')) THEN
					BEGIN
					{ Eliminate 3.0, 3.1 CPlus Support }
					Execute('-d 31CPlusNonFPUSANELib=  ∂');
					Execute('-d 31CPlusFPUSANELib=  ∂');
					Execute('-d 31CPlusSupport=  ∂');

					{ Select the proper floating point support }
					IF fNeedsFPU THEN
						Execute('-d CPlusNonFPUSANELib=  ∂')
					ELSE
						Execute('-d CPlusFPUSANELib=  ∂');
					END
				ELSE
					BEGIN
					{ Eliminate 3.2 CPlus Support }
					Execute('-d CPlusNonFPUSANELib=  ∂');
					Execute('-d CPlusFPUSANELib=  ∂');
					Execute('-d CPlusSupport=  ∂');

					{ Select the proper floating point support }
					IF fNeedsFPU THEN
						Execute('-d 31CPlusNonFPUSANELib=  ∂')
					ELSE
						Execute('-d 31CPlusFPUSANELib=  ∂');
					END
				END
			ELSE
				BEGIN
				{ Eliminate CPlus support }
				Execute('-d 31CPlusNonFPUSANELib=  ∂');
				Execute('-d 31CPlusFPUSANELib=  ∂');
				Execute('-d 31CPlusSupport=  ∂');
				Execute('-d CPlusNonFPUSANELib=  ∂');
				Execute('-d CPlusFPUSANELib=  ∂');
				Execute('-d CPlusSupport=  ∂');

				{ Select the proper floating point support }
				IF fNeedsFPU THEN
					Execute('-d PascalNonFPUSANELib=  ∂')
				ELSE
					Execute('-d PascalFPUSANELib=  ∂');
				END;

			IF automake THEN
				Execute('-d AppName={XAppName} ∂'); 	{ the default rules supply the rest }
			Execute('-f "{MATools}Basic Definitions" ∂');
			IF NOT automake THEN
				Execute('-f "{XAppPath}{XAppName}{MAMakeFileExtension}" ∂'); { a makefile was
				supplied }
			Execute('-f "{MATools}Build Rules and Dependencies" ∂');
			Execute('"{ObjApp}{XAppName}" ∂');
			IF NOT fStatusOnly THEN
				Execute('>> "{XMakeIt}"')
			ELSE
				Execute('');

			SetIE('XMakeStatus', '{Status}');
			SetIE('EXIT', '1');
			Execute('IF "{XMakeStatus}"');
			Echo('MAKE of {XAppName} failed: `DATE`');
			IF fTimes THEN
				Echo('Elapsed time: `evaluate ∂`DATE -n∂` - {XMakeStartTime}` seconds');
			Execute('{MAFailed}');
			IF fNoFail THEN
				SetIE('XExitStatus', '{XMakeStatus}')
			ELSE
				Execute('EXIT "{XMakeStatus}"');

			IF fTimes THEN
				BEGIN
				Execute('ELSE');
				Echo('Elapsed time: `evaluate ∂`DATE -n∂` - {XMakeStartTime}` seconds');
				END;
			Execute('END');

			{ Attempt Execution and let the user know how it all came out }
			IF fExecute THEN
				BEGIN
				SetIE('EXIT', '0');
				Execute('"{XMakeIt}"');
				SetIE('XRunStatus', '{Status}');
				SetIE('EXIT', '1');
				Execute('IF "{XRunStatus}"');
				Execute('{MAFailed}');
				IF fNoFail THEN
					SetIE('XExitStatus', '{XRunStatus}')
				ELSE
					Execute('EXIT "{XRunStatus}"');
				Execute('END');
				END;
			aTStringHandle := TStringHandle(fTargStringList.First);
			END;
		END;

{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	PROCEDURE TMABuildTool.DoToolAction;

		VAR
			SeparateObjectsFolder, MASeparateObjectsPrefix: Str255;
			MAAutoBuild:		Str255;
			MAUserAutoBuild:	Str255;
			MAShortVersion: 	Str255;
			MALoadFiles, LoadFileDir, CPlusLoad: Str255;
			aTStringHandle: 	TStringHandle;
			aString:			Str255;
			dirID:				Longint;
			vRefNum:			integer;

			{* PathNameFromDirID ********************************************************}

		FUNCTION PathNameFromDirID(dirID: Longint;
								   vRefNum: integer): Str255;

			CONST
				fsRtDir 			= 2;

			VAR
				Block:				CInfoPBRec;
				directoryName, FullPathName: Str255;
				err:				oserr;

			BEGIN
			FullPathName := '';
			WITH Block DO
				BEGIN
				ioNamePtr := @directoryName;
				ioDrParID := dirID;
				END;

			REPEAT
				WITH Block DO
					BEGIN
					ioVRefNum := vRefNum;
					ioFDirIndex := - 1;
					ioDrDirID := Block.ioDrParID;
					END;
				err := PBGetCatInfo(@Block, FALSE);

				IF gConfiguration.hasAUX THEN
					BEGIN
					IF directoryName[1] <> '/' THEN
						BEGIN
						{ If this isn't root (i.e. "/"), append a slash ('/') }
						directoryName := concat(directoryName, '/');
						END;
					END
				ELSE
					BEGIN
					directoryName := concat(directoryName, ':');
					END;
				FullPathName := concat(directoryName, FullPathName);
			UNTIL (Block.ioDrDirID = fsRtDir);

			PathNameFromDirID := FullPathName;
			END;

		BEGIN

		IF NOT IEGetEnv('MAShortVersion', MAShortVersion) | (MAShortVersion <> '2.0') THEN
			BEGIN
			Stop(
		   '''###'' MABuild: Whoops… You have not executed the Startup file in the MacApp directory'
				 );
			END;
		{ Resolve matrix of options. }
		IF NOT fProgress THEN
			fEchoOptions.Catenate(' ∑ Dev:Null ');
		IF fDebug THEN
			fNames := TRUE;

{!!!!!#### still need parsing loops to process each of these as multiple targets if the var is a list }
		IF fUserAutoBuild & IEGetEnv('MAUserAutoBuild', MAUserAutoBuild) & (MAUserAutoBuild <>
		   '') THEN
			BEGIN
			aTStringHandle := NewTStringHandle;
			aTStringHandle.Catenate(MAUserAutoBuild);
			fTargStringList.InsertFirst(aTStringHandle);
			END;

		IF fAutoBuild & IEGetEnv('MAAutoBuild', MAAutoBuild) & (MAAutoBuild <> '') THEN
			BEGIN
			aTStringHandle := NewTStringHandle;
			aTStringHandle.Catenate(MAAutoBuild);
			fTargStringList.InsertFirst(aTStringHandle);
			END;

		{ Building for use with MacApp? }
		IF fMacApp THEN
			CatenateToSourceOptionStrings(' -d qMacApp=TRUE')
		ELSE
			BEGIN
			CatenateToSourceOptionStrings(' -d qMacApp=FALSE');
			fOptionFlags.Catenate('Ge');	{ Generic?, nm is taken already. }
			END;

		IF fAlign THEN
			BEGIN
			fLinkOptions.Catenate(' -ac 4 -ad 4');
			fRezOptions.Catenate(' -align longword');
			END;

		{ process elapsed time indication }
		IF fTimes THEN
			BEGIN
			fAsmOptions.Catenate(' -t');
			fCOptions.Catenate(' -t');
			fCPlusOptions.Catenate(' -t');
			{ fLinkOptions.Catenate(' -t'); # -t means file type}
			{ fLibOptions.Catenate(' -t'); # there isn't a -t option}
			{ fMakeOptions.Catenate(' -t'); # -t means touch the files}
			fPascalOptions.Catenate(' -t');
			{ fRezOptions.Catenate(' -t');	 # -t means file type}
			fPostRezOptions.Catenate(' -t');
			END;

		{ Progress indication }
		IF fAllProgress THEN
			BEGIN
			CatenateToSourceOptionStrings(' -p');
			fLinkOptions.Catenate(' -p');
			fLibOptions.Catenate(' -p');
			fPostRezOptions.Catenate(' -p');
			END;

		IF fBottleNeckedDispatching THEN
			fLinkOptions.Catenate(' -opt NoBypass')
		ELSE
			fLinkOptions.Catenate(' -opt on');

		{ Debug the Debugger }
		IF fDebugTheDebugger THEN
			BEGIN
			fOptionFlags.Catenate('DD');

			CatenateToSourceOptionStrings(' -d qDebugTheDebugger=TRUE')
			END
		ELSE
			CatenateToSourceOptionStrings(' -d qDebugTheDebugger=FALSE');

		{ ROM 128K }
		IF fNeedsROM128K THEN
			CatenateToSourceOptionStrings(' -d qNeedsROM128K=TRUE')
		ELSE
			BEGIN
			fOptionFlags.Catenate('64');

			CatenateToSourceOptionStrings(' -d qNeedsROM128K=FALSE')
			END;

		{ PreSystem 6.0 support }
		IF fNeedsSystem6 THEN
			BEGIN
			fOptionFlags.Catenate('S6');

			CatenateToSourceOptionStrings(
' -d qNeedsScriptManager=TRUE -d qNeedsHierarchicalMenus=TRUE -d qNeedsStyleTextEdit=TRUE  -d qNeedsWaitNextEvent=TRUE'
										  )
			END
		ELSE
			CatenateToSourceOptionStrings(
' -d qNeedsScriptManager=FALSE -d qNeedsHierarchicalMenus=FALSE -d qNeedsStyleTextEdit=FALSE -d qNeedsWaitNextEvent=FALSE'
										  );

		{ ColorQD support }
		IF fNeedsColorQD THEN
			BEGIN
			fOptionFlags.Catenate('Cq');

			CatenateToSourceOptionStrings(' -d qNeedsColorQD=TRUE');
			END
		ELSE
			CatenateToSourceOptionStrings(' -d qNeedsColorQD=FALSE');

		{ 020 support }
		IF fNeedsMC68020 THEN
			BEGIN
			fOptionFlags.Catenate('20');

			CatenateToSourceOptionStrings(' -d qNeedsMC68020=TRUE');
			fCOptions.Catenate(' -mc68020');
			fCPlusOptions.Catenate(' -mc68020');
			fPascalOptions.Catenate(' -mc68020');
			END
		ELSE
			CatenateToSourceOptionStrings(' -d qNeedsMC68020=FALSE');

		{ 030 support }
		IF fNeedsMC68030 THEN
			BEGIN
			fOptionFlags.Catenate('30');

			CatenateToSourceOptionStrings(' -d qNeedsMC68030=TRUE');
			fCOptions.Catenate(' -mc68020');
			fCPlusOptions.Catenate(' -mc68020');
			fPascalOptions.Catenate(' -mc68020');
			END
		ELSE
			CatenateToSourceOptionStrings(' -d qNeedsMC68030=FALSE');

		{ FPU support }
		IF fNeedsFPU THEN
			BEGIN
			fOptionFlags.Catenate('Fp');

			CatenateToSourceOptionStrings(' -d qNeedsFPU=TRUE');
			fCOptions.Catenate(' -mc68881');			{ eliminated -elems881 }
			fCPlusOptions.Catenate(' -mc68881');
			fPascalOptions.Catenate(' -mc68881');
			END
		ELSE
			BEGIN
			CatenateToSourceOptionStrings(' -d qNeedsFPU=FALSE');
			END;

		{ MacApp as library support }
		IF fMALibrary THEN
			BEGIN
			fMakeOptions.Catenate(' -d MacAppObjs=  ');
			END
		ELSE
			BEGIN
			fMakeOptions.Catenate(' -d MacAppLibrary=  ');
			END;

		{ Pascal external symbol table files support }
		IF NOT fPasLoad THEN
			BEGIN
			fMakeOptions.Catenate(' -d PascalLoad=  -d PascalLoadOptions=  '); { Remove the definitions }
			END;

		{ C++ external symbol table files support }
		IF fCPlusLoad & fNeedsFPU THEN
			BEGIN
			Echo('''###'' MABuild: Warning: CPlusLoad and NeedsFPU are incompatible.  Using NoCPlusLoad.');
			fCPlusLoad := FALSE;
			END;

		IF NOT fCPlusLoad THEN
			BEGIN
			fMakeOptions.Catenate(' -d CPlusLoad=  -d CPlusLoadOptions=  '); { Remove the definitions }
			END;

		{ Embedded debugger names }
		IF fNames THEN
			BEGIN
			fOptionFlags.Catenate('Nm');

			CatenateToSourceOptionStrings(' -d qNames=TRUE');
			{$IFC FALSE}								{ !!! not until 32bit everything… gets too
														 big! }
			IF IEGetEnv('MAShellVersion', MAShellVersion) & (MAShellVersion <> '3.0') THEN
				fLinkOptions.Catenate(' -opt names');	{ Make the selector procs show up }
			{$EndC}
			END
		ELSE
			BEGIN
			CatenateToSourceOptionStrings(' -d qNames=FALSE');
			fCOptions.Catenate(' -mbg off');
			fCPlusOptions.Catenate(' -mbg off');
			END;

		{ Debugging support }
		IF fDebug THEN
			BEGIN
			fOptionFlags.Catenate('Db');

			CatenateToSourceOptionStrings(' -d qDebug=TRUE');
			fRezOptions.Catenate(' -d Debugging');		{ For backward compatibility. To be dropped
														 in next release (post 2.0)}
			END
		ELSE
			BEGIN
			CatenateToSourceOptionStrings(' -d qDebug=FALSE');
			fMakeOptions.Catenate(' -d DebugFiles= -d DebugRsrcs= -d DebugLib=  '); { Eliminate
				debug files as targets in the makefiles }
			END;

		{ Inspector support }
		IF fInspector THEN
			BEGIN
			fOptionFlags.Catenate('In');

			CatenateToSourceOptionStrings(' -d qInspector=TRUE');
			END
		ELSE
			CatenateToSourceOptionStrings(' -d qInspector=FALSE');

		{ UnInitialized storage support }
		IF fUnInit THEN
			BEGIN
			fOptionFlags.Catenate('Un');

			CatenateToSourceOptionStrings(' -d qUnInit=TRUE');
			END
		ELSE
			CatenateToSourceOptionStrings(' -d qUnInit=FALSE');

		{ Perform support }
		IF fPerform THEN
			BEGIN
			fOptionFlags.Catenate('Pe');

			CatenateToSourceOptionStrings(' -d qPerform=TRUE');
			END
		ELSE
			BEGIN
			CatenateToSourceOptionStrings(' -d qPerform=FALSE');
			fMakeOptions.Catenate(' -d PerformLib= ');	{ Eliminate the performance libraries as
														 target }
			END;

		{ RangeCheck support }
		IF fRangeCheck THEN
			BEGIN
			fOptionFlags.Catenate('Ra');

			CatenateToSourceOptionStrings(' -d qRangeCheck=TRUE');
			END
		ELSE
			CatenateToSourceOptionStrings(' -d qRangeCheck=FALSE');

		{ Trace support }
		IF fTrace THEN
			BEGIN
			fOptionFlags.Catenate('Tr');

			CatenateToSourceOptionStrings(' -d qTrace=TRUE');
			END
		ELSE
			CatenateToSourceOptionStrings(' -d qTrace=FALSE');

		{ template views support }
		IF fTemplateViews THEN
			BEGIN
			fOptionFlags.Catenate('Te');

			CatenateToSourceOptionStrings(' -d qTemplateViews=TRUE');
			END
		ELSE
			CatenateToSourceOptionStrings(' -d qTemplateViews=FALSE');

		{ symbolic debugging support }
		IF fSym THEN
			BEGIN
			fOptionFlags.Catenate('Sm');

			CatenateToSourceOptionStrings(' -d qSym=TRUE');
			fAsmOptions.Catenate(' -sym on');
			fCOptions.Catenate(' -sym on');
			fCPlusOptions.Catenate(' -sym on');
			fLinkOptions.Catenate(' -sym on');
			fPascalOptions.Catenate(' -sym on');
			END
		ELSE
			CatenateToSourceOptionStrings(' -d qSym=FALSE');

		{ See if user wants to play with experimental and _UNSUPPORTED_ goodies. }
		IF fExperimentalAndUnsupported THEN
			BEGIN
			fOptionFlags.Catenate('Ex');

			CatenateToSourceOptionStrings(' -d qExperimentalAndUnsupported=TRUE');
			END
		ELSE
			CatenateToSourceOptionStrings(' -d qExperimentalAndUnsupported=FALSE');

		{ Process separate objects }
		{ Get basic name }
		IF fSeparateObjects THEN
			BEGIN
			IF NOT fRenameFlagsPairs.ValueAt(fOptionFlags.AsStr255, SeparateObjectsFolder) THEN
				SeparateObjectsFolder := fOptionFlags.AsStr255;
			END
		ELSE
			BEGIN
			IF NOT IEGetEnv('MANoSeparateObjectsFolder', SeparateObjectsFolder) THEN
				SeparateObjectsFolder := '';
			END;

		{ Add the prefix }
		IF IEGetEnv('MASeparateObjectsPrefix', MASeparateObjectsPrefix) THEN
			SeparateObjectsFolder := concat(MASeparateObjectsPrefix, SeparateObjectsFolder,
											gDirectorySeparator);

		SetIE('SeparateObjectsFolder', SeparateObjectsFolder);
		fSeparateObjectsFolder := SeparateObjectsFolder;

		{ output the results. }
		IF fTimes THEN
			WriteLn(fOutputFile^, 'SET XStartTime ', fStartDateTime);
		WriteLn(fOutputFile^, 'SET XTimes ', ord(fTimes));
		WriteLn(fOutputFile^, 'SET XRunAfterBuild ', ord(fRunAfterBuild));

		Write(fOutputFile^, 'SET AsmOptions "'); fAsmOptions.WriteToFile(fOutputFile);
		WriteLn(fOutputFile^, ' "');
		Write(fOutputFile^, 'SET COptions "'); fCOptions.WriteToFile(fOutputFile);
		WriteLn(fOutputFile^, ' "');
		Write(fOutputFile^, 'SET CPlusOptions "'); fCPlusOptions.WriteToFile(fOutputFile);
		WriteLn(fOutputFile^, ' "');
		Write(fOutputFile^, 'SET EchoOptions "'); fEchoOptions.WriteToFile(fOutputFile);
		WriteLn(fOutputFile^, ' "');
		Write(fOutputFile^, 'SET LibOptions "'); fLibOptions.WriteToFile(fOutputFile);
		WriteLn(fOutputFile^, ' "');
		Write(fOutputFile^, 'SET LinkOptions "'); fLinkOptions.WriteToFile(fOutputFile);
		WriteLn(fOutputFile^, ' "');
		Write(fOutputFile^, 'SET MakeOptions "'); fMakeOptions.WriteToFile(fOutputFile);
		WriteLn(fOutputFile^, ' "');
		Write(fOutputFile^, 'SET PascalOptions "'); fPascalOptions.WriteToFile(fOutputFile);
		WriteLn(fOutputFile^, ' "');
		Write(fOutputFile^, 'SET RezOptions "'); fRezOptions.WriteToFile(fOutputFile);
		WriteLn(fOutputFile^, ' "');
		Write(fOutputFile^, 'SET PostRezOptions "'); fPostRezOptions.WriteToFile(fOutputFile);
		WriteLn(fOutputFile^, ' "');

		Write(fOutputFile^, 'SET XOptionFlags "'); fOptionFlags.WriteToFile(fOutputFile);
		WriteLn(fOutputFile^, '"');

		{ Process autosave }
		IF fSaveBeforeBuild THEN
			BEGIN
			IF fProgress THEN
				Echo('"AutoSaving…"');
			Execute('Save -a');
			END;

		{ Remember the current directory }
		IF HGetVol(NIL, vRefNum, dirID) = noErr THEN
			StartPath := PathNameFromDirID(dirID, vRefNum);

		{ Make sure load files folder and separate objects folder exists for load files}
		IF IEGetEnv('MALoadFiles', MALoadFiles) THEN
			LoadFileDir := concat(MALoadFiles, fSeparateObjectsFolder)
		ELSE										{ Punt }
			LoadFileDir := concat(MALoadFiles, fSeparateObjectsFolder);
		{ Make sure the basic load files directory exists }
		IF (MALoadFiles <> '') & NOT Exists(MALoadFiles) & (DirCreate(0, 0, MALoadFiles,
		   dirID) <> noErr) THEN
			BEGIN
			Echo('''###'' MABuild: Unable to create directory: "{MALoadFiles}"');
			Echo('MABuild of {XAppName} failed: `DATE`');
			Execute('{MAFailed}');

			IF fNoFail THEN
				SetIE('XRunStatus', '1')
			ELSE
				Execute('EXIT 1');
			END;
		{ Make sure the load files directory that is specific to our build options exists }
		IF NOT Exists(LoadFileDir) & (DirCreate(0, 0, LoadFileDir, dirID) <> noErr) THEN
			BEGIN
			Echo(
		   '''###'' MABuild: Unable to create directory: "{MALoadFiles}{SeparateObjectsFolder}"'
				 );
			Echo('MABuild of {XAppName} failed: `DATE`');
			Execute('{MAFailed}');

			IF fNoFail THEN
				SetIE('XRunStatus', '1')
			ELSE
				Execute('EXIT 1');
			END;

		{ process each target in the list }
		DoAllTargets;

		{ termination messages }
		IF fTimes THEN
			BEGIN
			Echo('" "');
			Echo('MABuild:   Elapsed time: `evaluate ∂`DATE -n∂` - {XStartTime}` seconds');
			END;

		Execute('IF "{XExitStatus}"');
		Execute('{MAFailed}');
		Execute('EXIT "{XExitStatus}"');
		Execute('END');

		IF fProgress THEN
			BEGIN
			Echo('Completion time for MABuild is `DATE`');
			Execute('{MADone}');
			END;
		END;
{--------------------------------------------------------------------------------------------------}
	{$S TRes}

	BEGIN
	InitUMPWTool;

	New(gMABuildTool);
	gMABuildTool.IMABuildTool;
	gMABuildTool.Run;
	END.
