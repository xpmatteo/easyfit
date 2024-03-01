/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989-1991 Matteo Vaccari & Mario Negri Institute.
	All rights reserved.
	
	---------------------------
	
	EasyFitUtilities.c - Routines that could not easily be implemented in Pascal.
*/

#include <StdIO.h>
#include <types.h>
#include <quickdraw.h>
#include <strings.h>
#include <string.h>
#include <memory.h>
#include <ToolUtils.h>
#include "MacApp.h"

#if qDebug
static char tmp[256];
#endif

/* -------------------------------------------------------------------------------- */
/*
	Questa procedura serve a fornire al pascal una maniera 
	conveniente di convertire un extended in stringa.
	Infatti le procedure SANE accessibili dal pascal non vanno bene
	per motivi estetici: uno deve stabilire quante cifre decimali
	vuole, e se ci sono degli zeri questi vengono accodati lo stesso.
	La stringa passata in "s" viene trattata come una stringa Pascal.
*/
#pragma segment ARes

void Num2NiceStr(n, s, precision) 
extended n;
char *s;
short precision;
{
	char formatString[30];
	
	/* costruisco la stringa di formato */
	sprintf(formatString, "%%.%dg", precision);
	
	sprintf(s+1, formatString, n);
	s[0] = strlen(s+1);
}

/* -------------------------------------------------------------------------------- */
/*
	Num2PercentageStr - formatta un numero extended in virgola fissa
	con due cifre dopo la virgola.
	La stringa passata in "s" viene trattata come una stringa Pascal.
*/
#pragma segment ARes
void Num2PercentageStr(n, s) 
extended n;
char *s;
{
	sprintf(s+1, "%.2f", n);
	s[0] = strlen(s+1);
}

/* -------------------------------------------------------------------------------- */
/*
	Tries to interpret the scrap as a piece of table, with columns
	separated by RETs and row element separated by TABs. returns 0 if
	it is OK, 1 if it is not rectangular.
*/

#pragma segment ADoCommand

int GetTextScrapDim(Handle HScrap, int len, Point *size)
{
	int offset, r, c;
	char *p;
	
	size->h = 1;
	size->v = 1;
	p = *HScrap;
	r = 1;
	c = 1;
	offset = 0;
	while (1) {
	
		/* Skip everything until the first occurrence of RET or TAB, if any */
		while ((offset < len) && (*p != '\t') && (*p != '\n')) {
				p++;
				offset++;
		}		
		if (offset == len) {
			return 0;
		}
		if (*p == '\t') {
			c++;
			if (size->h < c)
				size->h = c;
		}
		else 
		if (*p == '\n' && offset < (len-1)) {	/* if offset = len-1 then the scrap ends
																						with a newline; we don't count
																						the last row */
			if (c != size->h) {							/*ÊThis scrap ain't rectangular */
				return 1;
			}
			c = 1;
			r++;
			if (size->v < r)
				size->v = r;
		}
		p++;
		offset++;
	}
}				/*ÊGetTextScrapDim */

/* ------------------------------------------------------------------------------- */
#pragma segment ASelCommand

/* Returns 1 iff the text pointed to by the handle contains at least a TAB
	or a newline. */

int TextContainsMoreThanOneItem(Handle h)
{
	int len;
	char *p, *end;
	
	len = GetHandleSize(h);
	
	/* No need to lock the handle, since what we do can't allocate memory */
	for (p = *h, end = p+len; p < end; p++)
		if (*p == '\t' || *p == '\n')
			return 1;
	return 0;
}


/* ------------------------------------------------------------------------------- */
/* 
	This one is for pasting text into a table. It's here because these
	hacks are best done in C.
	Parameters:
		HScrap must be a handle to a TEXT scrap
		length must be the length of the scrap
		offset must be the number of the char where we start reading
		s			 must point to the pascal string that will receive our output
		strLen must be the max length allowed for s
*/
#pragma segment ADoCommand

void ReadStringFromTextScrap(Handle HScrap, 
														 int length,
														 int *offset,
														 char *s,
														 int strLen)
{
	int i;
	Boolean good;
	char *p;

#if qDebug
	if (*offset > length)
		PROGRAMBREAK("\pReadStringFromTextScrap: offset > length!");
#endif

	s[0] = 0;		/* By default, the result string is empty */
	i = 1;
	good = 1;
	p = *HScrap + *offset;
	while ((*p != '\n') && (*p != '\t') && (*offset < length)) {
		if (good && (i <= strLen)) {
				s[i] = *p;
				i++;
		}
		else
			good = 0;
		p++;
		(*offset)++;
	}
	
	if (*offset < length)
		(*offset)++;			/* consume the tab or ret */
	s[0] = i - 1;				/* set the p-string length */

#if qDebug
	sprintf(tmp, "ReadStringFromTextScrap: string is %P", s);
	DEBUGWRITELN(c2pstr(tmp));
#endif
}        /* ReadStringFromTextScrap */

/* -------------------------------------------------------------------------------- */
/*
	Set quickly to zero the area pointed by "p"
*/
#pragma segment ARes
void SetPtrToZero(Ptr p, long size)
{
	Ptr last;
	
	last = p + size;
	while (p < last)
		*p++ = 0;
}

/* -------------------------------------------------------------------------------- */
/*
	Used to shift the contents of a handle, so that we get it smaller throwing 
	away the first "amount" bytes.  The final size of the handle is returned.
*/
#pragma segment TERes
long ShiftHandle(Handle h, long amount)
{
	long size;
	char *pLow, *pHigh, *end;
	
#if qDebug
	if (!h)
		PROGRAMBREAK("\pShiftHandle: passed nil handle!");
#endif
	
	size = GetHandleSize(h);
	if (size < amount) {
		SetHandleSize(h, 0);
		return 0;
	}

	/* shift */
	pLow = *h;
	pHigh = (*h) + amount;
	end = (*h) + size;
	while (pHigh < end) {
		*pLow = *pHigh;
		pLow++;
		pHigh++;
	}
	SetHandleSize(h, size - amount);
	return size - amount;
}

/*
	Used to test ShiftHandle's correctness
			
			#include <ToolUtils.h>
			main()
			{
				Handle h;
				
				h = NewString("\pabcdefghijklmnopqrstuvwxyz0123456789");
				fprintf(stderr, "%s\n", *h);
				fprintf(stderr, "Orig size is %d\n", GetHandleSize(h));
				
				fprintf(stderr, "New size is %d \n", ShiftHandle(h, 5));
				fprintf(stderr, "New size is %d \n", GetHandleSize(h));
				fprintf(stderr, "%s\n", *h);
			}
*/

/* -------------------------------------------------------------------------------- */
/* 
	Set the value of the i-th element of the vector of extendeds 
	pointed by p 
*/

#pragma segment ARes

void SetIthElement(p, i, value)
extended p[], value;
int i;
{
	*(p + i) = value;
}

/* -------------------------------------------------------------------------------- */
/* 
	Get the value of the i-th element of the vector of extendeds 
	pointed by p.  A function would have been more elegant, but _slower_.
*/
#pragma segment ARes

void GetIthElement(p, i, value)
extended p[], *value;
int i;
{
	*value = *(p + i);
}

/* -------------------------------------------------------------------------------- */
/*
	Same as the C libraries c2pstr, only it doesn't transform in place
	the string.  Instead, it returns a copy.  So you can pass safely
	string constants to this functions (you would be in trouble passing
	a string constant more than once to c2pstr).
	Of course no checking is done on the size of the strings, assuming
	the caller knows what he's doing.
*/
#pragma segment ARes

void MyC2Pstr(Str255 cString, Str255 pString)
{
	char *pByteCount;
	
	pByteCount = pString;				/* pByteCount points to the first byte of pString */
	*pByteCount = 0;						/* The byte count initially is zero */
	pString++;
	while (*cString) {
		*pString++ = *cString++;
		(*pByteCount)++;
	}
}

/*
	This is a slower version of MyC2PStr, that I used when I thought that 
	the other version didn't work right
	
	void MyC2Pstr(Str255 cString, Str255 pString)
	{
		sprintf(pString, "%s", cString);
		c2pstr(pString);
	}

*/
/* Main program to test MyC2Pstr's correctness */
/*
		#include <stdio.h>
		#include <types.h>

		main()
		{
			char s1[] = "abcd";
			char s2[] = "";
			char ps1[500], ps2[500];
			
			MyC2Pstr(s1, ps1);
			MyC2Pstr(s2, ps2);
			printf("s1: >%P< s2: >%P< \n", ps1, ps2);
		}
*/

/* -------------------------------------------------------------------------------- */
/*
	This procedures allow Pascal to access, in a limited way, the sprintf
	std C procedure.
*/
#pragma segment ARes

void CallSprintfWith5Strings(Str255 dest, Str255 p_format, 
														Str255 s1, Str255 s2, Str255 s3, Str255 s4, Str255 s5)
{
	Str255 c_format;
	
	/* use p2cstr on a copy of format, so we don't spoil the actual parameter */
	sprintf(c_format, "%s", p_format);
	p2cstr(c_format);
	
	sprintf(dest, c_format, s1, s2, s3, s4, s5);
	c2pstr(dest);
}


#pragma segment ARes
void CallSprintfWith6Numbers(Str255 dest, Str255 p_format, 
														 int p1, extended p2, extended p3, extended p4, 
														 extended p5, extended p6)
{
	Str255 c_format;
	
	/* use p2cstr on a copy of format, so we don't spoil the actual parameter */
	sprintf(c_format, "%s", p_format);
	p2cstr(c_format);
	
	sprintf(dest, c_format, p1, p2, p3, p4, p5, p6);
	c2pstr(dest);
}

/* ------------------------------------------------------------------------------- */
/*
	ForceCStyle - adds a null at the end of an handle to get a C-Style string.
	Returns the handle, or NIL if there was not enough memory.
*/

#pragma segment ACompileUserModel

Handle ForceCStyle(Handle h)
{
	int len;
	
	len = GetHandleSize(h);
	SetHandleSize(h, len + 1);
	if (MemError()) 
		return 0;
	else {
		((char *) (*h)) [len] = '\0';
		return h;
	}
}

/* main used to test ForceCStyle's correctness */
/*
	main()
	{
		Handle h;
		
		h = (Handle) NewString("\pabc");
		p2cstr(*h);
	
		printf("0:%c 1:%c 2:%c 3:%c 4:%c, size is %d\n",	(*h) [0],
																											(*h) [1],
																											(*h) [2],
																											(*h) [3],
																											(*h) [4],
																											GetHandleSize(h));	
	
		printf("0:%d 1:%d 2:%d 3:%d 4:%d, size is %d\n",	(*h) [0],
																											(*h) [1],
																											(*h) [2],
																											(*h) [3],
																											(*h) [4],
																											GetHandleSize(h));	
	
		ForceCStyle(h);
		
		printf("0:%c 1:%c 2:%c 3:%c 4:%c, size is %d\n",	(*h) [0],
																											(*h) [1],
																											(*h) [2],
																											(*h) [3],
																											(*h) [4],
																											GetHandleSize(h));	
		printf("0:%d 1:%d 2:%d 3:%d 4:%d, size is %d\n",	(*h) [0],
																											(*h) [1],
																											(*h) [2],
																											(*h) [3],
																											(*h) [4],
																											GetHandleSize(h));	
	}
*/

/* ------------------------------------------------------------------------------- */
/*	NewPermString - Takes in input a pointer to a pascal string.
		It creates an handle with NewPermHandle, stores the string in it, and 
		removes the initial length byte. The result is a handle to 
		a piece of text that is not a pascal string, nor a C string because
		it doesn't have the terminal null char.
		
		It returns the string, or NIL if it couldn't be created.
*/

#pragma segment ARes
Handle NewPermString (Str255 theString)
{
	int size;
	Handle h;
	
	h = NewPermHandle(theString[0]);		/* create the handle */
	if (!h)
		return 0L;
	SetString(h, theString);						/* copy the string to the handle */
	
	HLock(h);
	p2cstr(*h);													/* remove the length byte */
	HUnlock(h);
	
	size = GetHandleSize(h);	
	SetHandleSize(h, size - 1);					/* remove the terminal null char */
	
	return h;
}

/* ------------------------------------------------------------------------------- */
/*	CallModel - calls the model. This can't be done from Pascal, since
		you can't use a pointer to function in Pascal.
*/

#pragma segment ARes

extended CallModel(f, p, x)
extended (*f)(), p[], x;
{
	return (*f)(p, x);
}

/* -------------------------------------------------------------------------------- */
/*
	Parse a version string. If it has no suffix, '\0' is returned in "stage".
	Returns true if an error happened.
*/

#pragma segment AOpen

int parseVersion(char *versString, int *majorVersion, int *minorVersion, char *stage,
	int *release)
{
	int i, n;
	Str255 workString;
	
	/* Copy the version string to a C-style work string. Change any '§'
		 character to 'b', since scanf doesn't understand 8-bits chars. */
	for (i=1; i<=versString[0]; i++) {
		workString[i-1] = ((versString[i]=='§') ? 'b' : versString[i]);
	}
	workString[versString[0]] = '\0';
	
	n = sscanf(workString, "%d.%d%1[abd]%d", majorVersion, minorVersion, stage, release);
	
	#if qDebug
	{
		Str255 s;
		sprintf(s, "ParseVersion: workString=%s, parsed %d-.-%d-%c-%d", workString,
			*majorVersion, *minorVersion, *stage, *release);
		DEBUGWRITELN(c2pstr(s));
	}
	#endif
	
	if (n==2) {
		*stage='\0';
		return false;
	}
	else if (n==4)
		return false;
	else
		return true;
}

/* -------------------------------------------------------------------------------- */
/*
	Questa funzione decide se la relazione d'ordine fra due stringhe di
	versione e' <. Il formato delle stringhe di versione e'
	
		majorVersion . minorVersion [a,b,d] release
	
	dove majorRelease, minorRelease, release sono numeri interi, e [a,b,d] indica
	una scelta fra i tre caratteri d, a, b. Nell'ordine, le versioni piu'
	vecchie hanno la lettera d, a, b. Per le versioni definitive il carattere
	e l'ultimo numero di release sono omessi. Vedere la documentazione Apple
	sul loro schema di version numbering, ad esempio nella documentazione del
	comando setVersion di MPW shell.
	
	Valori restituiti:
		MINOR: vers1 < vers2
		EQUAL: vers1 = vers2
		MAJOR: vers2 > vers2
		ERROR: vers1 o vers2 hanno causato errore nel parsing.
*/

#define MINOR 1
#define EQUAL 2
#define MAJOR 3
#define ERROR 4

#pragma segment AOpen

void renumberStage(char *stage)
{
	switch(*stage) {
		case 'd':
			*stage = 1;
			break;
		case 'a':
			*stage = 2;
			break;
		case 'b':
			*stage = 3;
			break;
		default:
			*stage = 0;
	}
}

#pragma segment AOpen

int VersionMinor(Str255 vers1, Str255 vers2)
{
	int majorVersion1, minorVersion1, majorVersion2, minorVersion2;
	char stage1, stage2;
	int release1, release2;
	
	if (parseVersion(vers1, &majorVersion1, &minorVersion1, &stage1, &release1))
		return ERROR;
	if (parseVersion(vers2, &majorVersion2, &minorVersion2, &stage2, &release2))
		return ERROR;
	
	if (majorVersion1 < majorVersion2)
		return MINOR;
	else if (majorVersion1 > majorVersion2)
		return MAJOR;
	else if (minorVersion1 < minorVersion2)
		return MINOR;
	else if (minorVersion1 > minorVersion2)
		return MAJOR;
	
	/* if neither version has the letter+release suffix, we exit */
	if (stage1=='\0' && stage2=='\0')
		return EQUAL;
		
	/* if only vers1 has the suffix, then it is earlier */
	if (stage2=='\0')
		return MINOR;
	
	/* if only vers2 has the suffix, then it is earlier */
	if (stage1=='\0')
		return MAJOR;
	
	/* Now renumber stages so that comparisons are easier */
	renumberStage(&stage1);
	renumberStage(&stage2);
	
	if (stage1 < stage2)
		return MINOR;
	else if (stage1 > stage2)
		return MAJOR;
	else if (release1 < release2)
		return MINOR;
	else if (release1 > release2)
		return MAJOR;
	else
		return EQUAL;
}

/* -------------------------------------------------------------------------------- */
/*
	DebugAlert -- can be used to show debugging information while compiling
	in non-debug mode. Thus you can chase those nasty no-debug-only bugs!
	The msg parameter must be a C string. It will not be changed after the call.
*/
#include <Dialogs.h>

void DebugAlert(char *msg)
{
	extern pascal void StdAlert(short alertID);
	const phPlainAlert = 2000;

	ParamText(c2pstr(msg), "\p","\p","\p");
	StdAlert(phPlainAlert);
	p2cstr(msg);
}
