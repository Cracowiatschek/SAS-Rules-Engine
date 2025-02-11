%macro readSegment(segmentName, source, context);
	%let Decisions = &source..&context._Decisions;
	%let SegmentDetails = &source..&context._SegmentDetails;
	
	PROC SQL NOPRINT;
		SELECT Count(DISTINCT segmentId) INTO :decisionsCnt FROM &Decisions;
		SELECT Count(segmentId) INTO :isExist FROM &SegmentDetails WHERE segmentName = "&segmentName";
		SELECT Max(segmentId) INTO :segmentId FROM &SegmentDetails WHERE segmentName = "&segmentName";
	QUIT;
	
	%if &isExist > 0 %then %do;
		PROC SQL;
			CREATE TABLE work.segment AS (
				SELECT DISTINCT customerId FROM &Decisions
				WHERE segmentId = &segmentId
				AND result = 1
			);
		QUIT;
	%end;
	%if &isExist = 0 %then %do;
		%put Segment &segmentName is not exist. Create dummy table;
		DATA work.segment;
			customerId = 0;
		RUN;
	%end;
%mend;
