%macro getDecisions(segmentsCount, source, conext);
	%let Segment = &source..&context._Segment;
	%let Decisions = &source..&context._Decisions;
	%let Constraint = &source..&context._Constraint;
	%let CustomerData = &source..&context._CustomerData; 
	
	PROC SQL;
		CREATE TABLE &Decisions (
			decisionId INT PRIMARY KEY,
			decisionName VARCHAR(30) NOT NULL,
			customerId INT NOT NULL,
			segmentId INT NOT NULL,
			result INT NOT NULL
		);
	QUIT;
	
	%if &segmentsCount >= 1 %then %do;
		PROC SQL NOPRINT;
			SELECT DISTINCT segmentId INTO :segmentsId SEPARATED BY '|' FROM &Segment;
		QUIT;
		
		%let count = 1;
		%do %while (%scan(&segmentsId, &count, |) ne );
			%let segmentId = %scan(&segmentsId, &count, |);
	        PROC SQL NOPRINT;
	        	SELECT DISTINCT constraintId INTO :constraintsId SEPARATED BY '|' FROM &Constraint
	        	WHERE isActive = 1
	        	AND fkSegmentId = &segmentId;
	        QUIT;
	        %let countConstraint = 1;
	        %do %while (%scan(&constraintsId, &countConstraint, |) ne );
				%let constraintId = %scan(&constraintsId, &countConstraint, |);
	        	PROC SQL NOPRINT;
	        		SELECT Strip(Max(operator)) INTO :operator FROM &Constraint
	        		WHERE constraintId = &constraintId;
	        		SELECT Strip(Max(constraintName)) INTO :constraintName FROM &Constraint
	        		WHERE constraintId = &constraintId;
	        		SELECT Strip(Max(attribute)) INTO :attribute FROM &Constraint
	        		WHERE constraintId = &constraintId;
	        		SELECT Strip(Max(constraintValue)) INTO :constraintValue FROM &Constraint
	        		WHERE constraintId = &constraintId;
	        		SELECT Strip(Max(dtype)) INTO :dtype FROM &Constraint
	        		WHERE constraintId = &constraintId;
	        		SELECT Count(*) INTO :maxDecisionId FROM &Decisions;
	        	QUIT;
				
				%let operator = %sysfunc(strip(&operator));
				%let attribute = %sysfunc(strip(&attribute));
				%let constraintValue = %sysfunc(strip(&constraintValue));
				%let dtype = %sysfunc(strip(&dtype));
				%let constraintName = %sysfunc(strip(&constraintName));
				
	        	%if &dtype = DATE %then %do;
	        		%put date find "&operator";
	        		%if "&operator" = ">" or "&operator" = ">=" or "&operator" = "=" 
	        			or "&operator" = "<=" or "&operator" = "<" or "&operator" = "<>" %then %do;
	        			PROC SQL NOPRINT;
			        		SELECT Count(*) INTO :isRelative 
			        		FROM &Constraint
			        		WHERE constraintId = &constraintId
			        		AND constraintValue LIKE '%Today%';
			        	QUIT;
			        	%if &isRelative = 0 %then %do;
		        			PROC SQL NOPRINT;
				        		SELECT "'"||Strip(Max(put(input(&constraintValue, yymmdd10.), date9.)))||"'d" INTO :constraintValue 
				        		FROM &Constraint
				        		WHERE constraintId = &constraintId;
				        	QUIT;
						%end;
						%if &isRelative > 0 %then %do;
							PROC SQL NOPRINT;
				        		SELECT substr("&constraintValue", 2, length("&constraintValue")-2) INTO :constraintValue 
				        		FROM sashelp.class;
				        	QUIT;
						%end;
	        		%end;
	        		%if "&operator" = "BETWEEN" or "&operator" = "NOT BETWEEN" %then %do;
						PROC SQL NOPRINT;
			        		SELECT Count(*) INTO :isRelative 
			        		FROM &Constraint
			        		WHERE constraintId = &constraintId
			        		AND constraintValue LIKE '%Today%';
			        	QUIT;
			        	%if &isRelative = 0 %then %do;
		        			%let date1 = %scan(&constraintValue, 1, |);
		        			%let date2 = %scan(&constraintValue, 2, |);
	
		        			PROC SQL NOPRINT;
				        		SELECT "'"||Strip(Max(put(input(&date1, yymmdd10.), date9.)))||"'d AND '"||Strip(Max(put(input(&date2, yymmdd10.), date9.)))||"'d" INTO :constraintValue 
				        		FROM &Constraint
				        		WHERE constraintId = &constraintId;
				        	QUIT;
				        %end;
				        %if &isRelative > 0 %then %do;
							%let date1 = %substr(%scan(&constraintValue, 1, |), 2, %length(%scan(&constraintValue, 1, |))-2);
		        			%let date2 = %substr(%scan(&constraintValue, 1, |), 2, %length(%scan(&constraintValue, 1, |))-2);
		        			
		        			PROC SQL NOPRINT;
				        		SELECT "&date1"||" AND "||"&date2" INTO :constraintValue 
				        		FROM &Constraint
				        		WHERE constraintId = &constraintId;
				        	QUIT;
						%end;
	        		%end;
	        		%if "&operator" = "IN" or "&operator" = "NOT IN" %then %do;
	        			%macro process_dates(dates);
	        				%global final_string;
						    %let n = %sysfunc(countw(&dates, |)); 
						    %let final_string = ( ;						   
						    %do i = 1 %to &n;
						        %let date = %scan(&dates, &i, |); 

						        %let date_without_quotes = %substr(&date, 2, 10);

						        %let formatted_date = %sysfunc(putn(%sysfunc(inputn(&date_without_quotes, yymmdd10.)), date9.));
	
								PROC SQL NOPRINT;
									SELECT Max("&final_string"||"'"||"&formatted_date"||"'d,") INTO :final_string FROM sashelp.class;
								QUIT;
	
						        %if &i = &n %then %do;
						            PROC SQL NOPRINT;
										SELECT Max(substr("&final_String", 1, length("&final_String") - 1))||")" INTO :final_string FROM sashelp.class;
									QUIT;
						        %end;
						    %end;
						%mend;
						%process_dates(dates = &constraintValue);
						%let constraintValue = &final_string;
	        		%end;
	        	%end;
	        	%put Segment: &segmentId, Constraint: &constraintId, &attribute &operator &constraintValue, DTYPE = &dtype;
	        	/*Do something*/ 
	        	
	        	PROC SQL;
	        		 CREATE TABLE work.dummyDecisions AS (
	        		 	SELECT DISTINCT Monotonic()+&maxDecisionId as decisionId ,"&constraintName" AS decisionName, customerId, &segmentId AS segmentId, 0 AS result 
	        		 	FROM &CustomerData
	        		 	WHERE &attribute &operator &constraintValue
	        		 	AND customerId NOT IN (
	        		 		SELECT customerId FROM &Decisions
	        		 		WHERE result = 1
	        		 	)
	        		 	AND customerId IN (
	        		 		SELECT customerId FROM &Segment
	        		 		WHERE segmentId = &segmentId
	        		 	)
	        		 );
	        		 INSERT INTO &Decisions (decisionId, decisionName, customerId, segmentId, result)
	        		 SELECT DISTINCT decisionId, decisionName, customerId, segmentId, result FROM work.dummyDecisions;
	        	QUIT;
	        	%let countConstraint = %eval(&countConstraint + 1);
			%end; 
			PROC SQL NOPRINT;
				SELECT Count(*) INTO :maxDecisionId FROM &Decisions;
        		 CREATE TABLE work.dummyDecisions AS (
        		 	SELECT DISTINCT Monotonic()+&maxDecisionId as decisionId ,"Customer is correct" AS decisionName, customerId, &segmentId AS segmentId, 1 AS result 
        		 	FROM &CustomerData
        		 	WHERE customerId NOT IN (
        		 		SELECT customerId FROM &Decisions
        		 		WHERE segmentId = &segmentId
        		 	)
        		 	AND customerId IN (
        		 		SELECT customerId FROM &Segment
        		 		WHERE segmentId = &segmentId
        		 	)
        		 );
        		 INSERT INTO &Decisions (decisionId, decisionName, customerId, segmentId, result)
        		 SELECT DISTINCT decisionId, decisionName, customerId, segmentId, result FROM work.dummyDecisions;
        	QUIT;
	        %let count = %eval(&count + 1);
	    %end;
	%end;
	%if &segmentsCount = 0 %then %do;
		PROC SQL;
			INSERT INTO &Decisions
			VALUES (1, "DUMMY", 0, 0, 0);
		QUIT;
		%put No segments to calculate, create dummy decisions.;
	%end;
%mend;

/* %getDecisions(segmentsCount=1, source=WORK , conext=TEST); */