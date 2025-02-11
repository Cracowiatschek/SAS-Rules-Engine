%macro updateSegmentPriority(name, priority, source, context);
	%let SegmentDetails = &source..&context._SegmentDetails;
	
	PROC SQL NOPRINT;
		SELECT Max(segmentId)+1 INTO :maxId FROM &SegmentDetails;
	QUIT;
	
	%if &maxId = . %then %do;
		%put Segment library is empty.;
		%return;
	%end;
	
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &SegmentDetails WHERE segmentName = "&name.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		PROC SQL NOPRINT;
			SELECT Count(*) INTO :segmentsCnt FROM &SegmentDetails;
		QUIT;
		%if &segmentsCnt > 0 %then %do;
			PROC SQL;
				UPDATE &SegmentDetails
				SET priority = priority + 1
				WHERE priority >= &priority;
			QUIT;
			%if &priority < &maxId %then %do;
				PROC SQL;
					UPDATE &SegmentDetails
					SET priority = &priority
					WHERE segmentName = "&name.";
				QUIT;
			%end;
			%if &priority >= &maxId %then %do;
				PROC SQL;
					UPDATE &SegmentDetails
					SET priority = &priority
					WHERE segmentName = "&name.";
				QUIT;
			%end;
		%end;	
	%end;
	%else %do;
		%put Segment name not found.;
	%end;
%mend;
