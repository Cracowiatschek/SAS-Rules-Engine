%macro updateTriggerSegmentLink(name, segmentName, source, context); 
/*
name - trigger name
*/
	%let Trigger = &source..&context._Trigger;
	%let SegmentDetails = &source..&context._SegmentDetails;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :triggersCnt FROM &Trigger;
	QUIT;
	
	%if &triggersCnt = 0 %then %do;
		%put Triggers library is empty!;
		%return;
	%end;
	
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &Trigger WHERE triggerName = "&name.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		PROC SQL NOPRINT;
			SELECT Max(triggerId) INTO :triggerId FROM &Trigger WHERE triggerName = "&name.";
		QUIT;
		PROC SQL NOPRINT;
			SELECT Count(*) INTO :isSegmentExist FROM &SegmentDetails WHERE segmentName = "&segmentName.";
		QUIT;

		%if &isSegmentExist = 1 %then %do;	
			PROC SQL NOPRINT;
				SELECT Max(segmentId) INTO :segmentId FROM &SegmentDetails WHERE segmentName = "&segmentName.";
			QUIT;
			PROC SQL;
				UPDATE &Trigger
				SET fkSegmentId = &segmentId
				WHERE triggerId = &triggerId;
			QUIT;
		%end;
		%if &isSegmentExist = 0 %then %do;
			%put Segment is not found!;
		%end;
	%end;
	%else %do;
		%put Trigger &name not exist!;
	%end;
%mend;

/* %updateTriggerSegmentLink(name=TriggerTest, segmentName=Test, source=WORK, context=TEST); */