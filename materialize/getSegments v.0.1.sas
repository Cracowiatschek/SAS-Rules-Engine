%macro checkAvailability(day, isHoliday, context, source);
	/*
		Write your custom callendar checker,
		actually library dosen't have any native integration with callendar.
	*/
	%let day = %lowcase(&day);
	%let SegmentDetails = &source..&context._SegmentDetails;
	%global segments;
	%global segmentsCount;
	
	PROC SQL NOPRINT;
		SELECT DISTINCT segmentName INTO :segments SEPARATED BY "|" 
		FROM &SegmentDetails WHERE &day = 1 AND holidaysFlag = 1;
		SELECT Count(*) INTO :segmentsCount SEPARATED BY "|" 
		FROM &SegmentDetails WHERE &day = 1 AND holidaysFlag = 1;
	QUIT;
	
	%if &isHoliday = 0 %then %do;
		PROC SQL NOPRINT;
			SELECT DISTINCT segmentName INTO :segments SEPARATED BY "|" 
			FROM &SegmentDetails WHERE &day = 1;
			SELECT Count(*) INTO :segmentsCount SEPARATED BY "|" 
			FROM &SegmentDetails WHERE &day = 1;
		QUIT;
	%end;
%mend;

%macro createSegment(segmentName, source, context);
	%let Segment = &source..&context._Segment;
	%let SegmentDetails = &source..&context._SegmentDetails;
	%let Trigger = &source..&context._Trigger;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &SegmentDetails WHERE segmentName = "&segmentName.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		PROC SQL NOPRINT;
			SELECT Max(segmentId) INTO :segmentId FROM &SegmentDetails WHERE segmentName = "&segmentName.";
		QUIT;

		PROC SQL NOPRINT;
			SELECT DISTINCT triggerId INTO :triggers SEPARATED BY "|" FROM &Trigger WHERE fkSegmentId = &segmentId AND isActive = 1;
		QUIT;
		
		%let count = 1;
		
		%do %while (%scan(&triggers, &count, |) ne );
	        %let triggerId = %scan(&triggers, &count, |);
	        	PROC SQL NOPRINT;
	        		SELECT max(query) INTO :query FROM &Trigger WHERE triggerId = &triggerId;
	        	QUIT;
	        	PROC SQL;
	        		CREATE TABLE work.customers AS (
	        			&query
	        		);
	        	QUIT;
	    		PROC SQL;
	    			INSERT INTO &Segment (customerId, segmentId, triggerId)
	    			SELECT DISTINCT customerId, &segmentId, &triggerId FROM work.customers;
	    		QUIT;
	        %let count = %eval(&count + 1);
	    %end;
	%end;
	%else %do;
		%put Segment is not exist!;
	%end;
%mend;

%macro getSegments(day, isHoliday, context, source);
	%let Segment = &source..&context._Segment;
	%global countSegments;

	%checkAvailability(day=&day, isHoliday=&isHoliday, context=&context, source=&source);
	
	PROC SQL;
		CREATE TABLE &Segment (
			customerId INT NOT NULL,
			segmentId INT NOT NULL,
			triggerId INT NOT NULL
		);
	QUIT;

	%let countSegments = 1;
	
	%if &segmentsCount >= 1 %then %do;
		%do %while (%scan(&segments, &countSegments, |) ne );
	        %let segmentName = %scan(&segments, &countSegments, |);
	        %createSegment(segmentName=&segmentName, source=&source, context=&context);
	        %let countSegments = %eval(&countSegments + 1);
	    %end;
	%end;
	%else %do;
		%put No segments to execute;
	%end;
%mend;

/*  %getSegments(day=monday, isHoliday=0, context=TEST, source=work );  */