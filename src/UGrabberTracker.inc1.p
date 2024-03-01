{[a-,body+,h-,o=100,r+,rec+,t=4,u+,#+,j=20/57/1$,n+]}
{ UGrabberTracker.inc1.p }
{ Copyright � 1988-1989 by Apple Computer, Inc. All rights reserved.}

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TGrabberTracker.IGrabberTracker(itsCmdNumber: CmdNumber; itsDocument: TDocument;
										  itsView: TView; itsScroller: TScroller);

	BEGIN
	ICommand(itsCmdNumber, itsDocument, itsView, itsScroller);
	fCanUndo := false;
	fCausesChange := false;
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

FUNCTION TGrabberTracker.TrackMouse(aTrackPhase: TrackPhase; VAR anchorPoint, previousPoint,
									nextPoint: VPoint; mouseDidMove: Boolean): TCommand; OVERRIDE;

	VAR
		delta:				VPoint;

	BEGIN
	TrackMouse := self; 								{ keep tracking with me }
	CASE aTrackPhase OF
		trackPress: ;
		trackMove:
			IF mouseDidMove THEN
				BEGIN
				WITH fScroller, delta DO
					BEGIN
					v := MinMax(anchorPoint.v - nextPoint.v, - fTranslation.v, fMaxTranslation.v -
								fTranslation.v);
					h := MinMax(anchorPoint.h - nextPoint.h, - fTranslation.h, fMaxTranslation.h -
								fTranslation.h);
					IF NOT EqualVPt(delta, gZeroVPt) THEN
						BEGIN
						ScrollBy(h, v, True);
						Update;
						END
					END;

				AddVPt(delta, nextPoint);

				previousPoint := nextPoint;
				anchorPoint := nextPoint;
				END;
		trackRelease: ;
	END;												{ CASE }
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TGrabberTracker.TrackFeedback(anchorPoint, nextPoint: VPoint; turnItOn,
										mouseDidMove: Boolean);

	BEGIN
	{ NO feedback please }
	END;

{--------------------------------------------------------------------------------------------------}
{$S ADoCommand}

PROCEDURE TGrabberTracker.AutoScroll(deltaH, deltaV: VCoordinate);

	BEGIN
	{ NO AutoScroll please }
	END;