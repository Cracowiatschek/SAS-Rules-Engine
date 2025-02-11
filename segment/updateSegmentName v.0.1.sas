
%macro updateSegmentName(name, value, source, context);
	%let SegmentDetails = &source..&context._SegmentDetails;

	PROC SQL NOPRINT;
		SELECT Max(segmentId)+1 INTO :maxId FROM &SegmentDetails;
	QUIT;
	
	%if &maxId = . %then %do;
		%put Segment library is empty.;
		%return;
	%end;
	
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isHired FROM &SegmentDetails WHERE segmentName = "&value." AND segmentName ne "&name.";
	QUIT;

	%if &isHired > 0 %then %do;
		%put New segment name is hired!;
		%return;
	%end;
	
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &SegmentDetails WHERE segmentName = "&name.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		PROC SQL;
			UPDATE &SegmentDetails
			SET SegmentName = "&value."
			WHERE SegmentName = "&name.";
		QUIT;
	%end;
	%else %do;
		%put Segment name not found.;
	%end;
	
%mend;

