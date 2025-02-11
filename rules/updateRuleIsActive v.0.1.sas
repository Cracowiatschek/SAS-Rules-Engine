%macro updateRuleIsActive(id, value, source, context); 
/*
name - Rules name
*/
	%let Rules = &source..&context._Rules;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :rulesCnt FROM &Rules;
	QUIT;
	
	%if &rulesCnt = 0 %then %do;
		%put Rules library is empty!;
		%return;
	%end;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &Rules WHERE ruleId = &id.;
	QUIT;
	
	%if &isExist = 1 %then %do;
		PROC SQL NOPRINT;
			SELECT Max(ruleId) INTO :ruleId FROM &Rules WHERE ruleId = &id.;
		QUIT;
		
		%if &value = 0 %then %do;
			PROC SQL;
				UPDATE &Rules
				SET isActive = 0
				WHERE ruleId = &ruleId;
			QUIT;
		%end;
		%if &value = 1 %then %do;
			PROC SQL;
				UPDATE &Rules
				SET isActive = 1
				WHERE ruleId = &ruleId;
			QUIT;
		%end;
	%end;
	%else %do;
		%put Rules &name not exist!;
	%end;
%mend;

/* %updateRuleIsActive(id=1, value=0, source=WORK, context=TEST); */