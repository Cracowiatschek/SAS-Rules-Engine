%macro checkAvailability(day, isHoliday, context, source);
	/*
		Write your custom callendar checker,
		actually library dosen't have any native integration with callendar.
	*/
	%let day = %lowcase(&day);
	%let SegmentDetails = &source..&context._SegmentDetails;
	%global segments;
	
	PROC SQL NOPRINT;
		SELECT DISTINCT segmentName INTO :segments SEPARATED BY "|" 
		FROM &SegmentDetails WHERE &day = 1 AND holidaysFlag = 1;
	QUIT;
	
	%if &isHoliday = 0 %then %do;
		PROC SQL NOPRINT;
			SELECT DISTINCT segmentName INTO :segments SEPARATED BY "|" 
			FROM &SegmentDetails WHERE &day = 1;
		QUIT;
	%end;
%mend;