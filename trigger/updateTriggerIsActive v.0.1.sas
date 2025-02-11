%macro updateTriggerIsActive(name, value, source, context); 
/*
name - trigger name
*/
	%let Trigger = &source..&context._Trigger;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :triggersCnt FROM &Trigger;
	QUIT;
	
	%if &triggersCnt = 0 %then %do;
		%put Triggers library is empty!;
		%return;
	%end;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &Trigger WHERE triggerName = "&name.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		PROC SQL NOPRINT;
			SELECT Max(triggerId) INTO :triggerId FROM &Trigger WHERE triggerName = "&name.";
		QUIT;
		
		%if &value = 0 %then %do;
			PROC SQL;
				UPDATE &Trigger
				SET isActive = 0
				WHERE triggerId = &triggerId;
			QUIT;
		%end;
		%if &value = 1 %then %do;
			PROC SQL;
				UPDATE &Trigger
				SET isActive = 1
				WHERE triggerId = &triggerId;
			QUIT;
		%end;
	%end;
	%else %do;
		%put Trigger &name not exist!;
	%end;
%mend;

/* %updateTriggerName(name=TestTrigger1, value=TriggerTest, source=WORK, context=TEST); */