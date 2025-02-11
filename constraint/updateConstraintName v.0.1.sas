
%macro updateConstraintName(name, value, source, context);
	%let Constraint = &source..&context._Constraint;

	PROC SQL NOPRINT;
		SELECT Max(constraintId)+1 INTO :maxId FROM &Constraint;
	QUIT;
	
	%if &maxId = . %then %do;
		%put Constraint library is empty.;
		%return;
	%end;
	
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isHired FROM &Constraint WHERE constraintName = "&value." AND constraintName ne "&name.";
	QUIT;

	%if &isHired > 0 %then %do;
		%put New Constraint name is hired!;
		%return;
	%end;
	
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &constraintDetails WHERE constraintName = "&name.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		PROC SQL;
			UPDATE &Constraint
			WHERE constraintName = "&name.";
		QUIT;
	%end;
	%else %do;
		%put Constraint name not found.;
	%end;
	
%mend;

