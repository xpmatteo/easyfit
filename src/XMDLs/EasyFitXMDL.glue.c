/*
		This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
		Copyright © 1989-1990 Matteo Vaccari & Mario Negri Institute.

		Procedures you can use to call back to EasyFit in an
		EasyFit External Model (XMDL).
		This file must be included in your XMDL code, _AFTER_ your 
		entry point routine (usually called Dispatch).
*/

void EFWriteln(XMdlBlockPtr pb, char *msg)
{
	pb->callBackRequest = cbWriteln;
	pb->callBackArguments[0] = (long) msg;
	(pb->EntryPoint)(pb);
	
	/* synchronize the messages window view */
	pb->callBackRequest = cbSynch;
	(pb->EntryPoint)(pb);
}

void EFWrite(XMdlBlockPtr pb, char *msg)
{
	pb->callBackRequest = cbWrite;
	pb->callBackArguments[0] = (long) msg;
	(pb->EntryPoint)(pb);
}

void EFNewLine(XMdlBlockPtr pb)
{
	pb->callBackRequest = cbNewLine;
	(pb->EntryPoint)(pb);

	/* synchronize the messages window view */
	pb->callBackRequest = cbSynch;
	(pb->EntryPoint)(pb);
}

void EFGetVersion(XMdlBlockPtr pb, int *majorRevision, int *minorRevision,
									char *stage, int *release, Boolean *fpu)
{
	pb->callBackRequest = cbGetVersion;
	(pb->EntryPoint)(pb);
	
	*majorRevision = pb->callBackResults[0];
	*minorRevision = pb->callBackResults[1];
	*stage = pb->callBackResults[2];
	*release = pb->callBackResults[3];
	*fpu = pb->callBackResults[4];
}

ConfigRecordPtr EFGetConfigRecord(XMdlBlockPtr pb)
{
	pb->callBackRequest = cbGetConfigRecord;
	(pb->EntryPoint)(pb);
	return (ConfigRecordPtr) pb->callBackResults[0];
}

void EFFailNIL(XMdlBlockPtr pb, void *p)
{
	if (!p) {
		pb->callBackRequest = cbFailNIL;
		pb->callBackArguments[0] = p;
		(pb->EntryPoint)(pb);
	}
}

void EFFailNILResource(XMdlBlockPtr pb, void *p)
{
	if (!p) {
		pb->callBackRequest = cbFailNILResource;
		pb->callBackArguments[0] = p;
		(pb->EntryPoint)(pb);
	}
}

void EFFailOSErr(XMdlBlockPtr pb, OSErr err)
{
	if (err != noErr) {
		pb->callBackRequest = cbFailOSErr;
		pb->callBackArguments[0] = err;
		(pb->EntryPoint)(pb);
	}
}

void EFFailResError(XMdlBlockPtr pb)
{
	pb->callBackRequest = cbFailResError;
	(pb->EntryPoint)(pb);
}

void EFFailMemError(XMdlBlockPtr pb)
{
	pb->callBackRequest = cbFailMemError;
	(pb->EntryPoint)(pb);
}

void EFFailure(XMdlBlockPtr pb)
{
	pb->callBackRequest = cbFailure;
	(pb->EntryPoint)(pb);
}

Ptr EFNewPtr(XMdlBlockPtr pb, long size)
{
	pb->callBackRequest = cbNewPtr;
	pb->callBackArguments[0] = size;
	(pb->EntryPoint)(pb);
	return (Ptr) pb->callBackResults[0];
}

Handle EFNewHandle(XMdlBlockPtr pb, long size)
{
	pb->callBackRequest = cbNewHandle;
	pb->callBackArguments[0] = size;
	(pb->EntryPoint)(pb);
	return (Handle) pb->callBackResults[0];
}

void EFBeginGetResources(XMdlBlockPtr pb)
{
	pb->callBackRequest = cbBeginGetResources;
	(pb->EntryPoint)(pb);
}

void EFEndGetResources(XMdlBlockPtr pb)
{
	pb->callBackRequest = cbEndGetResources;
	(pb->EntryPoint)(pb);
}

void EFNumToString(XMdlBlockPtr pb, double num, char *string)
{
	pb->callBackRequest = cbNumToString;
	pb->callBackArguments[0] = (long) &num;
	pb->callBackArguments[1] = (long) string;
	(pb->EntryPoint)(pb);
}

int EFStringToNum(XMdlBlockPtr pb, char *string, double *num)
{
	pb->callBackRequest = cbStringToNum;
	pb->callBackArguments[0] = (long) string;
	pb->callBackArguments[1] = (long) num;
	(pb->EntryPoint)(pb);
	return pb->callBackResults[0];
}
