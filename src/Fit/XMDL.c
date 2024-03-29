/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	
	We exploit the failure handling mechanism of MacApp.
	We need to convert everything to double, before jumping to
	execute the XMDL, and convert back the results. This is because the 
	length of the extended type varies when the -mc68881 option is on.
	This could cause all sorts of incompatibilities between EasyFit
	and XMDLs if we didn't convert everything to the safety of the double
	format.
*/

#include <Resources.h>
#include <Memory.h>
#include <Strings.h>
#include <Types.h>
#include "fit.h"
#include "MacApp.h"
#include "EasyFitXMDL.h"

#pragma segment Fit

extern pascal void FailNILResource(void *r);
extern pascal void Failure(short error, long message);
extern pascal void FailMemError(void);
extern pascal void FailResError(void);
extern pascal void FailNIL(void *p);
extern pascal void FailNILResource(void *r);
extern pascal void FailOSErr(short error);

extern pascal short int gApplicationRefNum;
extern pascal short int gLastOpenedResFile;
extern pascal ConfigRecord gConfiguration;

static pNumberOfParams;
static Boolean pXmdlAwake;

#define kXMDLFailed -24008
#define kFailedXMDLInitialization -24009
			
/* -------------------------------------------------------------------------------- */
/*
	Interface to the failure handling mechanism employed by MacApp.
	See the guide "Object Pascal To C++ Tips" on the developer's CD-ROM
	vol. IV for this.

	The trick is to say:
	
		TRY
			{
			stuff which might fail
			}
		RECOVER
			{
			recovery stuff
			}
		ENDTRY

*/
#include <SetJmp.h>

long pFailM;			/* Current failure message */
short pFailE;			/* Current failure error	 */

pascal void StandardHandler(short e, long m, void * Handler_StaticLink)
	{
	pFailE = e;
	pFailM = m;
	longjmp((jmp_buf) Handler_StaticLink, 1);
	}

#define TRY \
	{ \
		jmp_buf errorBuf; \
		if (! setjmp(errorBuf) ) { \
			FailInfo	fi; \
			CatchFailures(&fi, StandardHandler, errorBuf);

#define RECOVER \
			Success(&fi); \
			} \
		else \
			{

/*
	The default Object Pascal semantics are that returning from
	an error handler will go to the next failure handler on the
	stack.  The way we do this in C++ is that we call failure
	again with the same error information.  We can use a goto out
	of the RECOVER..ENDTRY block to stop the error processing.
 */

#define ENDTRY \
			Failure(pFailE, pFailM); \
			} \
	}
	
/* -------------------------------------------------------------------------------- */
/*
	Error checking procedure to be called in most functions in this
	file 
*/
void CheckError(char *name, Handle xmdl)
{
	if (xmdl == NULL) {
		DEBUGWRITELN(name);
		PROGRAMBREAK("\p xmdl is NIL");
	}
	if (pXmdlAwake != false && pXmdlAwake != true) {
		DEBUGWRITELN(name);
		PROGRAMBREAK("\p pXmdlAwake uninitialized");
	}
	if (!pXmdlAwake) {
		DEBUGWRITELN(name);
		PROGRAMBREAK("\p pXmdlAwake is false");
	}
}
	
/* -------------------------------------------------------------------------------- */
/*
	Glue to call the external model; see tech note #256, revision 90.08 for this.
*/
void CallXMDL(Handle xmdl, XMdlBlockPtr pb)
= { 
		0x205F,		/* MOVEA.L  (A7)+,A0  pop handle off stack								*/
    0x2050,		/* MOVEA.L  (A0),A0   dereference to get address of XMDL	*/
    0x4E90		/* JSR      (A0)      call XMDL, leaving pb on stack			*/
	};

/* -------------------------------------------------------------------------------- */
/*
	This procedure dispatches call backs to EasyFit. It is necessary to
	pass its address in the XMdlBlock to the XMDL.
*/
void EntryPoint(XMdlBlockPtr pb)
{
	switch(pb->callBackRequest) {
		case cbWriteln:
			writeln((char *) pb->callBackArguments[0]);
			break;
			
		case cbWrite:
			write((char *) pb->callBackArguments[0]);
			break;
			
		case cbNewLine:
			newline;
			break;
			
		case cbSynch:
			synch;
			break;
			
		case cbPollEvents:
			CHECK_FOR_INTERRUPT
			break;
			
		case cbGetVersion:
			/* ??? what to do if parseVersion returns error? */
			parseVersion(kVersion,
									 &(pb->callBackResults[0]),
									 &(pb->callBackResults[1]),
									 &(pb->callBackResults[2]),
									 &(pb->callBackResults[3]));
			#if qNeedsFPU
			pb->callBackResults[4] = true;
			#else
			pb->callBackResults[4] = false;
			#endif
			break;
			
		case cbFailNIL:
			FailNIL(NULL);
			break;
			
		case cbFailNILResource:
			FailNILResource(NULL);
			break;
			
		case cbFailOSErr:
			FailOSErr(pb->callBackArguments[0]);
			break;
			
		case cbFailResError:
			FailResError();
			break;
			
		case cbFailMemError:
			FailMemError();
			break;
			
		case cbFailure:
			Failure(kXMDLFailed, 0);
			break;
			
		case cbGetConfigRecord:
			pb->callBackResults[0] = (long) &gConfiguration;
			break;
			
		case cbNewPtr:
			pb->callBackResults[0] = (long) NewPermPtr(pb->callBackArguments[0]);
			break;
			
		case cbNewHandle:
			pb->callBackResults[0] = (long) NewPermHandle(pb->callBackArguments[0]);
			break;
		
		case cbBeginGetResources:
			UseResFile(gLastOpenedResFile);
			break;
			
		case cbEndGetResources:
			UseResFile(gApplicationRefNum);
			break;
			
		case cbNumToString:
			sprintf((char *) (pb->callBackArguments[1]), "%.15g",
																			*((double *) (pb->callBackArguments[0])));
			break;
			
		case cbStringToNum:
			{�
				int retVal;
				retVal = sscanf((char *) (pb->callBackArguments[0]), "%lf",
																			(double *) (pb->callBackArguments[1]));
				pb->callBackResults[0] = retVal;
			}
			break;
			
		default:
			#if qDebug
			{
				char s[100];
				sprintf(s, "XMDL EntryPoint: unknown callback code %d", pb->callBackRequest);
				PROGRAMBREAK(c2pstr(s));
			}
			#endif
			break;
	}
}

/* -------------------------------------------------------------------------------- */
/*
	Load and lock the XMDL in memory; return its handle. Call this at the
	beginning of the fitting.
*/
Handle LoadXMDL(Str255 name)
{
	Handle xmdl;
	XMdlBlock pb;
	Boolean oldState;
	
	xmdl = NULL;			/* make sure failure handlers will work */

	/* Load & lock the XMDL in permanent memory */	
	UseResFile(gLastOpenedResFile);
	FailResError;
	oldState = PermAllocation(true);
	xmdl = GetNamedResource('XMDL', name);
	PermAllocation(oldState);
	TRY
		FailNILResource(xmdl);
	RECOVER
		UseResFile(gApplicationRefNum);
	ENDTRY
	UseResFile(gApplicationRefNum);
	MoveHHi(xmdl);
	HLock(xmdl);
	
	/* send an initialize message to the XMDL */
	TRY
		pb.request = rInitialize;
		pb.EntryPoint = EntryPoint;
		CallXMDL(xmdl, &pb);
		
		/* Check if the XMDL says initialization went well */
		if (pb.initializeResult == kInitializeFailed)
			Failure(kFailedXMDLInitialization, 0);
	RECOVER
		HUnlock(xmdl);
		ReleaseResource(xmdl);
	ENDTRY
	
	/* Since we are unlocking the handle, next time we use the XMDL
		 we need to call GetResource and HLock before doing anything. */
	HUnlock(xmdl);
	pXmdlAwake = false;
	return xmdl;
}

/* -------------------------------------------------------------------------------- */
/*
	Call this to prepare for sending messages to the XMDL, or to send to sleep
	the xmdl.
*/

Boolean AwakeXMDL(Handle xmdl, Boolean awakeIt)
{
	#if qDebug
	{
		char s[200];
		sprintf(s, "AwakeXMDL: old state=%d, request=%d", pXmdlAwake, awakeIt);
		DEBUGWRITELN(c2pstr(s));
	}
	#endif
	
	if (awakeIt == pXmdlAwake)
		return pXmdlAwake;				/* need to do nothing */
	
	if (awakeIt) {
		LoadResource(xmdl);
		FailResError();
		MoveHHi(xmdl);
		HLock(xmdl);
		
		pXmdlAwake = true;
		return false;
	}
	else {	
		HUnlock(xmdl);
		pXmdlAwake = false;
		return true;
	}
}

/* -------------------------------------------------------------------------------- */
/*
	Call this when we're through with the XMDL.
*/
void FreeXMDL(Handle xmdl)
{
	if (xmdl) {
		XMdlBlock pb;
		
		/* Make sure the XMDL is in memory and locked. 
			 Note that other calls don't call Awake because they would cause
			 the model to be locked while the rest of the application wants it
			 to be sleeping. */
		AwakeXMDL(xmdl, true);
		
		/* send a 'finished' message to the XMDL */
		pb.request = rFinished;
		pb.EntryPoint = EntryPoint;
		TRY
			CallXMDL(xmdl, &pb);
		RECOVER
			HUnlock(xmdl);
			ReleaseResource(xmdl);
		ENDTRY
		
		HUnlock(xmdl);
		ReleaseResource(xmdl);
	}
}

/* -------------------------------------------------------------------------------- */

void CallXMDLName(Handle xmdl)
{
	XMdlBlock pb;
	
	#if qDebug
	CheckError("\pCallXMDLName:", xmdl);
	#endif
	
	pb.request = rModelName;
	pb.EntryPoint = EntryPoint;
	CallXMDL(xmdl, &pb);
}

/* -------------------------------------------------------------------------------- */

int GetXMDLNParams(Handle xmdl)
{
	XMdlBlock pb;
	
	#if qDebug
	CheckError("\pGetXMDLNParams:", xmdl);
	#endif
	
	pb.request = rGiveNParams;
	pb.EntryPoint = EntryPoint;
	CallXMDL(xmdl, &pb);
	
	if (pb.NParams < 1 || pb.NParams > kMaxParams)
		Failure(kXMDLFailed, 0);
	
	pNumberOfParams = pb.NParams;
	return pb.NParams;
}

/* -------------------------------------------------------------------------------- */

int CallXMDLPeeling(Handle xmdl, extended X[], extended Y[],
										int NObservations, extended params[], extended sqrtWeights[],
										int weightsOption)
{
	XMdlBlock pb;
	double *dX, *dY, *dParams, *dSqrtWeights;
	int i;
	
	#if qDebug
	CheckError("\pCallXMDLPeeling:", xmdl);
	#endif
	
	dX = dY = dParams = dSqrtWeights = NULL;
	
	TRY
		dX = (double *) NewPermPtr(sizeof(double)*NObservations);
		FailNIL(dX);
		dY = (double *) NewPermPtr(sizeof(double)*NObservations);
		FailNIL(dY);
		dSqrtWeights = (double *) NewPermPtr(sizeof(double)*NObservations);
		FailNIL(dSqrtWeights);
		dParams = (double *) NewPermPtr(sizeof(double)*pNumberOfParams);
		FailNIL(dParams);
		
		for (i=0; i<pNumberOfParams; i++)
			dParams[i] = params[i];
		for (i=0; i<NObservations; i++) {
			dX[i] = X[i];
			dY[i] = Y[i];
			dSqrtWeights[i] = sqrtWeights[i];
		}
		
		pb.request = rPeeling;
		pb.XObservations = dX;
		pb.YObservations = dY;
		pb.weightsOption = weightsOption;
		pb.sqrtWeights = dSqrtWeights;
		pb.NObservations = NObservations;
		pb.params = dParams;
		pb.EntryPoint = EntryPoint;
		
		CallXMDL(xmdl, &pb);
		
		for (i=0; i<pNumberOfParams; i++)
			params[i] = dParams[i];
	RECOVER
		if (dX)
			DisposPtr((Ptr) dX);
		if (dY)
			DisposPtr((Ptr) dY);
		if (dParams)
			DisposPtr((Ptr) dParams);
		if (dSqrtWeights)
			DisposPtr((Ptr) dSqrtWeights);
	ENDTRY

	DisposPtr((Ptr) dX);
	DisposPtr((Ptr) dY);
	DisposPtr((Ptr) dParams);
	DisposPtr((Ptr) dSqrtWeights);
	return pb.peelingResult ? PEELING_FAILED : NO_ERROR;
}

/* -------------------------------------------------------------------------------- */
/*
	This uses globals instead of arguments because it must have the
	same header as the other models.
*/
extended CallXMDLModel(extended params[], extended x)
{
	XMdlBlock pb;
	double dParams[kMaxParams];
	int i;
	extern pascal extended gDose;
	extern pascal Handle gXMDL;
	FocusRec savedFocus;
	
	#if qDebug
	CheckError("\pCallXMDLModel:", gXMDL);
	#endif
	
	CHECK_FOR_INTERRUPT
	
	for (i=0; i<pNumberOfParams; i++)
		dParams[i] = params[i];
	pb.request = rModel;
	pb.x = x;
	pb.params = dParams;
	pb.dose = gDose;
	pb.subject = gCurrentSubject;
	pb.EntryPoint = EntryPoint;
		
	savedFocus.clip = MakeNewRgn();
	GetFocus(&savedFocus);		/* preserve the focus */

	CallXMDL(gXMDL, &pb);

	SetFocus(&savedFocus);
	DisposeRgn(savedFocus.clip);

	return pb.y;
}


/* -------------------------------------------------------------------------------- */
/*
	This is called in lieu of the "Pharmacokinetic Computations".
*/
void		 CallXMDLFinalComputations(Handle xmdl,
																	 extended X[],
																	 extended Y[],
																	 extended sqrtWeights[],
																	 int NObservations,
																	 extended params[],
																	 int weightsOption,
																	 extended dose,
																	 int subject)
{
	XMdlBlock pb;
	double *dX, *dY, *dParams, *dSqrtWeights;
	int i;
	
	#if qDebug
	CheckError("\pCallXMDLFinalComputations:", xmdl);
	#endif
	
	dX = dY = dParams = dSqrtWeights = NULL;
	
	TRY
		dX = (double *) NewPermPtr(sizeof(double)*NObservations);
		FailNIL(dX);
		dY = (double *) NewPermPtr(sizeof(double)*NObservations);
		FailNIL(dY);
		dSqrtWeights = (double *) NewPermPtr(sizeof(double)*NObservations);
		FailNIL(dY);
		dParams = (double *) NewPermPtr(sizeof(double)*pNumberOfParams);
		FailNIL(dParams);
		
		for (i=0; i<pNumberOfParams; i++)
			dParams[i] = params[i];
		for (i=0; i<NObservations; i++) {
			dX[i] = X[i];
			dY[i] = Y[i];
			dSqrtWeights[i] = sqrtWeights[i];
		}
		
		pb.request = rFinalComputations;
		pb.XObservations = dX;
		pb.YObservations = dY;
		pb.sqrtWeights = dSqrtWeights;
		pb.NObservations = NObservations;
		pb.weightsOption = weightsOption;
		pb.params = dParams;
		pb.dose = dose;
		pb.subject = subject;
		pb.EntryPoint = EntryPoint;
	
		CallXMDL(xmdl, &pb);
	RECOVER
		if (dX)
			DisposPtr((Ptr) dX);
		if (dY)
			DisposPtr((Ptr) dY);
		if (dParams)
			DisposPtr((Ptr) dParams);
		if (dSqrtWeights)
			DisposPtr((Ptr) dSqrtWeights);
	ENDTRY

	DisposPtr((Ptr) dX);
	DisposPtr((Ptr) dY);
	DisposPtr((Ptr) dParams);
	DisposPtr((Ptr) dSqrtWeights);
}
