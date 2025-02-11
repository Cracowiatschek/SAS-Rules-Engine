 
%macro configRule(name, type, query, subSegmentName, source, context); 
/*
name - Rules name
query - Rules query to set basic audience WITHOUT SEMICOLN
subSegmentName - segment name to link Rules
*/
	%let Rules = &source..&context._Rules;
	%let SubSegmentDetails = &source..&context._SubSegmentDetails;
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :rulesCnt FROM &Rules;
		SELECT Max(ruleId)+1 INTO :maxId FROM &Rules;
	QUIT;
	
	%if &maxId = . %then %do;
		%let maxId = 1;
	%end;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &subSegmentDetails WHERE subSegmentName = "&subSegmentName.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		PROC SQL NOPRINT;
			SELECT Max(subsegmentId) INTO :subsegmentId FROM &SubSegmentDetails WHERE subSegmentName = "&subSegmentName.";
		QUIT;
		
		%let type = %upcase(&type);
		
		%if "&type" = "CONSTRAINT" or "&type" = "LIMIT" or "&type" = "SPLIT" %then %do;
			PROC SQL;
				INSERT INTO &Rules (ruleId, type, query, fkSubsegmentId, isActive)
				VALUES(
					&maxId,
					"&type",
					"&query", 
					&subsegmentId, 
					1
				);
			QUIT;
		%end;
	%end;
	%else %do;
		%put Subsegment &subSegmentName not exist!;
	%end;
%mend;

/* %let query = SELECT CST_ID FROM WORK.CST1; */
/* %configRule(name=TestRules4, type=constraint, query=&query, subSegmentName=TestSubsegment4, source=WORK, context=TEST); */