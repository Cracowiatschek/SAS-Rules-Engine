%macro updateSubsegmentIsActive(name, value, source, context); 
/*
name - SubSegmentDetails name
*/
	%let SubSegmentDetails = &source..&context._SubSegmentDetails;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :subsegmentCnt FROM &SubSegmentDetails;
	QUIT;
	
	%if &subsegmentCnt = 0 %then %do;
		%put SubSegmentDetails library is empty!;
		%return;
	%end;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &SubSegmentDetails WHERE subsegmentName = "&name.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		PROC SQL NOPRINT;
			SELECT Max(subsegmentId) INTO :subsegmentId FROM &SubSegmentDetails WHERE subsegmentName = "&name.";
		QUIT;
		
		%if &value = 0 %then %do;
			PROC SQL;
				UPDATE &SubSegmentDetails
				SET isActive = 0
				WHERE subsegmentId = &subsegmentId;
			QUIT;
		%end;
		%if &value = 1 %then %do;
			PROC SQL;
				UPDATE &SubSegmentDetails
				SET isActive = 1
				WHERE subsegmentId = &subsegmentId;
			QUIT;
		%end;
	%end;
	%else %do;
		%put SubSegmentDetails &name not exist!;
	%end;
%mend;

/* %updateSubsegmentIsActive(name=TestSubsegment4, value=0, source=WORK, context=TEST); */