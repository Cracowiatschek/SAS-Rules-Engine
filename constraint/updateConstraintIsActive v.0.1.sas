%macro updateConstraintIsActive(name, isActive, source, context);
	%let Constraint = &source..&context._Constraint;
	
	PROC SQL NOPRINT;
		SELECT Max(constraintId)+1 INTO :maxId FROM &Constraint;
	QUIT;
	
	%if &maxId = . %then %do;
		%put Constraint library is empty.;
		%return;
	%end;
	
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &Constraint WHERE constraintName = "&name.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		%if &isActive = 1 %then %do;
			PROC SQL;
				UPDATE &Constraint
				SET isActive = 1
				WHERE constraintName = "&name.";
			QUIT;
		%end;
		%if &isActive = 0 %then %do;
			PROC SQL;
				UPDATE &Constraint
				SET isActive = 0
				WHERE constraintName = "&name.";
			QUIT;
		%end;
		%if &isActive ne 1 and &holidaysFlag ne 0 %then %do;
			%put isActive is not valid!;
		%end;
	%end;
	%else %do;
		%put Constraint name not found.;
	%end;
%mend;