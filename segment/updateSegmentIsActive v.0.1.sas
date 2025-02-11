%macro updateSegmentIsActive(name, isActive, source, context);
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
		%if &isActive = 1 %then %do;
			PROC SQL;
				UPDATE &SegmentDetails
				SET isActive = 1
				WHERE SegmentName = "&name.";
			QUIT;
		%end;
		%if &isActive = 0 %then %do;
			PROC SQL;
				UPDATE &SegmentDetails
				SET isActive = 0
				WHERE SegmentName = "&name.";
			QUIT;
		%end;
		%if &isActive ne 1 and &holidaysFlag ne 0 %then %do;
			%put isActive is not valid!;
		%end;
	%end;
	%else %do;
		%put Segment name not found.;
	%end;
%mend;