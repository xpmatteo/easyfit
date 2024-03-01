{[a-,body+,h-,o=100,r+,rec+,t=4,u+,#+,j=20/57/1$,n+]}
{ UGrabberTracker.p }
{ Copyright � 1988-1989 by Apple Computer, Inc. All rights reserved.}

{ This unit tracks a scrolling view with a MacPaint�-like Grabber Hand }

UNIT UGrabberTracker;

	INTERFACE

		USES
			{ � MacApp }
			UMacApp;

			{ � Building Blocks }

			{ � Required for this unit's interface }

			{ � Implementation Use }

		CONST
			kGrabberHand = 9;		{ ID of the grabberhand cursor }

		TYPE
			TGrabberTracker 	= OBJECT (TCommand)
				PROCEDURE TGrabberTracker.IGrabberTracker(itsCmdNumber: CmdNumber;
														  itsDocument: TDocument; itsView: TView;
														  itsScroller: TScroller);
				FUNCTION  TGrabberTracker.TrackMouse(aTrackPhase: TrackPhase; VAR anchorPoint,
													 previousPoint, nextPoint: VPoint;
													 mouseDidMove: Boolean): TCommand; OVERRIDE;
				PROCEDURE TGrabberTracker.TrackFeedback(anchorPoint, nextPoint: VPoint; turnItOn,
														mouseDidMove: Boolean); OVERRIDE;
				PROCEDURE TGrabberTracker.AutoScroll(deltaH, deltaV: VCoordinate); OVERRIDE;
				END;

	IMPLEMENTATION

		{$I UGrabberTracker.inc1.p}

END.