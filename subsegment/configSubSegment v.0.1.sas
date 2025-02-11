%macro configSubsegment(name, segmentName, source, context); 
/*
name - Subsegment name
query - Subsegment query to set basic audience WITHOUT SEMICOLN
segmentName - segment name to link Subsegment
*/
	%let SubSegmentDetails = &source..&context._SubSegmentDetails;
	%let SegmentDetails = &source..&context._SegmentDetails;
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :subsegmentsCnt FROM &SubSegmentDetails;
		SELECT Max(subsegmentId)+1 INTO :maxId FROM &SubSegmentDetails;
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
			INSERT INTO &SubSegmentDetails (subSegmentId, SubsegmentName, fkSegmentId, isActive)
			VALUES(
				&maxId, 
				"&name", 
				&segmentId, 
				1
			);
		QUIT;
	%end;
	%else %do;
		%put Segment &segmentName not exist!;
	%end;
%mend;
/* %configSubsegment(name=TestSubsegment4, segmentName=Test, source=WORK, context=TEST); */