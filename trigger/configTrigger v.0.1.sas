 
%macro configTrigger(name, query, segmentName, source, context); 
/*
name - trigger name
query - trigger query to set basic audience WITHOUT SEMICOLN
segmentName - segment name to link trigger
*/
	%let Trigger = &source..&context._Trigger;
	%let SegmentDetails = &source..&context._SegmentDetails;
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :triggersCnt FROM &Trigger;
		SELECT Max(triggerId)+1 INTO :maxId FROM &Trigger;
	QUIT;
	
	%if &maxId = . %then %do;
		%let maxId = 1;
	%end;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &SegmentDetails WHERE segmentName = "&segmentName.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		PROC SQL NOPRINT;
			SELECT Max(segmentId) INTO :segmentId FROM &SegmentDetails WHERE segmentName = "&segmentName.";
		QUIT;

		PROC SQL;
			INSERT INTO &Trigger (triggerId, triggerName, query, fkSegmentId, isActive)
			VALUES(
				&maxId, 
				"&name", 
				"&query", 
				&segmentId, 
				1
			);
		QUIT;
	%end;
	%else %do;
		%put Segment &segmentName not exist!;
	%end;
%mend;

/* %let query = SELECT CST_ID FROM WORK.CST1; */
/* %configTrigger(name=TestTrigger4, query=&query, segmentName=Test, source=WORK, context=TEST); */