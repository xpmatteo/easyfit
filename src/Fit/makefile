
# makefile per il modulo di fitting
# per compilarlo a scopo di debug su macintosh

COptions = -d TOOL -d DEBUG -d qDebug=TRUE

OBJ = absdeterminant.c.o 	�
	computehess.c.o 	�
	computeparams.c.o 	�
	computesum.c.o 	�
	fit.c.o 	�
	fitglobals.c.o 	�
	linearsearch.c.o 	�
	marquardt.c.o 	�
	model.c.o 	�
	tabata.c.o 	�
	scaling.c.o 	�
	solvelinearsystem.c.o 	�
	testforconvergence.c.o 	�
	lu.c.o �
	nrutil.c.o �
	main.c.o �
	matrutil.c.o �
	updateparams.c.o

fit � {OBJ}
		Link -w -c 'MPS ' -t 'MPST' �
			{OBJ} �
			"{CLibraries}"CRuntime.o �
			"{Libraries}"Interface.o �
			"{CLibraries}"StdCLib.o �
			"{CLibraries}"CSANELib.o �
			"{CLibraries}"Math.o �
			"{CLibraries}"CInterface.o �
			"{PLibraries}"PasLib.o �
			"{PLibraries}"SANELib.o �
			"{Libraries}"ObjLib.o �
		 -o fit


out.diff � fit
	fit > out.fit
	diff -w out.fit out.fit.old | tee out.diff

commit �
	mv out.fit out.fit.old

# ------------ dipendenze ------------------

{OBJ} � m_indep.h fit.h nrecipes.h MacApp.h

