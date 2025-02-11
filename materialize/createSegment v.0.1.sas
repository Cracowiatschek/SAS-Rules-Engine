/* %let Segment = &source..&context._Segment; */
/* PROC SQL; */
/* 	CREATE TABLE &Segment ( */
/* 		customerId INT NOT NULL, */
/* 		segmentId INT NOT NULL, */
/* 		triggerId INT NOT NULL */
/* 	); */
/* QUIT; */

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

/* %createSegment(segmentName=YoungEuropean, source=work, context=TEST); */
	
	
    