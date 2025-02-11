
%macro updateConstraintValue(name, value, source, context); 
/*
name - Constraint name
attribute - Constraint attribute name
operator - operator for constraint
value - value of constraint
dtype - data type
segmentName - segment name to link Constraint
*/
	%let Constraint = &source..&context._Constraint;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :ConstraintsCnt FROM &Constraint;
		SELECT Max(constraintId)+1 INTO :maxId FROM &Constraint;
	QUIT;
	
	%if &maxId = . %then %do;
		%let maxId = 1;
	%end;

	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &Constraint WHERE constraintName = "&name.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		PROC SQL noprint;
			SELECT Max(operator) into :operator FROM &Constraint WHERE constraintName = "&name.";
			SELECT Max(dtype) into :dtype FROM &Constraint WHERE constraintName = "&name.";
			SELECT Max(constraintId) into :constraintId FROM &Constraint WHERE constraintName = "&name.";
		QUIT;
		%let operator = %upcase(&operator);
		%let dtype = %upcase(&dtype);
		
		/*Init Test*/
		%macro updateConstraint(id, name, attribute, operator, value, dtype, segmentId);
			%if "&operator" = "'>'" or "&operator" = "'>='" or "&operator" = "'='" or "&operator" = "'<='" or "&operator" = "'<'" or "&operator" = "'<>'" %then %do;
				%let operator = %substr(&operator, 2, %eval(%length(&operator) - 2));
			%end;
			%if "&operator" = "LIKE" or "&operator" = "NOT LIKE" %then %do;
				%let value = %sysfunc(tranwrd(&value, /prct, %));
			%end;
			
			PROC SQL;
				UPDATE &Constraint. 
				SET constraintValue = "&value"
				WHERE constraintId = &constraintId;
			QUIT;
		%mend;
		
		%macro initTest();
			DATA work.correctIndicators;
				validNumeric = 1;
				validDate = 1;
				validTimestamp = 1;
				validRelativeDate = 1;
				validRelativeTimestamp = 1;
				validBool = 1;
				validText = 1;
			RUN;
		%mend;
		
		%macro numericTest(dtype, value);
			%let checkFloat = %sysfunc(countw(&value, .));
			
			%if %sysfunc(notdigit(&value)) > 0 or "&dtype" ne "NUMERIC" or &checkFloat > 2 %then %do;
				PROC SQL;
					UPDATE work.correctIndicators
					SET validNumeric = 0;
				QUIT;
			%end;
			
			%if "&dtype" = "NUMERIC" and &checkFloat = 2 %then %do;
				%put TEST;
				%let digitsOnly = %sysfunc(compress(&value, .));
				%put &digitsOnly;
				%if %sysfunc(notdigit(&digitsOnly)) = 0 %then %do;
					PROC SQL;
						UPDATE work.correctIndicators
						SET validNumeric = 1;
					QUIT;
				%end;
			%end;
		%mend;
		
		%macro dateTest(dtype, value);
			%if "&dtype" = "DATE" and %Length(&value) >= 9 %then %do;
		        %let prefix = %upcase(%substr(&value, 2, 7));
		        %if "&prefix" ne "TODAY()" %then %do;
		        	%if %Length(&value) = 12 %then %do;
		        		%let year = %substr(&value, 2, 4);
				        %let o1 = %substr(&value, 6, 1);
				        %let month = %substr(&value, 7, 2);
				        %let o2 = %substr(&value, 9, 1);
				        %let day = %substr(&value, 10, 2);
				        
				        %if %sysfunc(notdigit(&year)) = 0 and "&o1" = "-" and "&o2" = "-" and %sysfunc(notdigit(&month)) = 0 and %sysfunc(notdigit(&day)) = 0 %then %do;
				            PROC SQL;
								UPDATE work.correctIndicators
								SET validRelativeDate = 0;
							QUIT;
				        %end;
				        %else %do;
				        	PROC SQL;
								UPDATE work.correctIndicators
								SET validDate = 0;
							QUIT;
				        %end;
				    %end;
					%else %do;
						PROC SQL;
							UPDATE work.correctIndicators
							SET validDate = 0;
						QUIT;
					%end;
			    %end;
			    
			    %if "&prefix" = "TODAY()" %then %do;
			    	PROC SQL;
						UPDATE work.correctIndicators
						SET validDate = 0;
					QUIT;
			    	%if %Length(&value) > 10 %then %do;
				    	%let valueOperator = %substr(&value, 9, 1);

						%let digit = %substr(&value, 10, %eval(%length(&value) - 10);

						%if %sysfunc(notdigit(&digit)) > 0%then %do;
				        	PROC SQL;
								UPDATE work.correctIndicators
								SET validRelativeDate = 0;
							QUIT;
			    		%end;
			    		
			    		%if "&valueOperator" ne "+" and "&valueOperator" ne "-" %then %do;
				        	PROC SQL;
								UPDATE work.correctIndicators
								SET validRelativeDate = 0;
							QUIT;
			    		%end;
					%end;
					%else %do;
						%if %Length(&value) ne 9 %then %do;
							PROC SQL;
								UPDATE work.correctIndicators
								SET validRelativeDate = 0;
							QUIT;
						%end;
					%end;
			    %end;
			    %else %do;
			    	PROC SQL;
						UPDATE work.correctIndicators
						SET validRelativeDate = 0;
					QUIT;
			    %end; 
			%end;
			%else %do;
				PROC SQL;
					UPDATE work.correctIndicators
					SET validRelativeDate = 0,
					validDate = 0;
				QUIT;		
			%end;	
		%mend;
		
		%macro timestampTest(dtype, value);
			%if "&dtype" = "TIMESTAMP" and %Length(&value) >= 10 %then %do;
		        %let prefix = %upcase(%substr(&value, 2, 10));

		        %if "&prefix" ne "DATETIME()" %then %do;
		        	%if %Length(&value) = 21 %then %do;
		        		%let year = %substr(&value, 2, 4);
				        %let o1 = %substr(&value, 6, 1);
				        %let month = %substr(&value, 7, 2);
				        %let o2 = %substr(&value, 9, 1);
				        %let day = %substr(&value, 10, 2);
				        %let concat = %substr(&value, 12, 1);
				        %let hour = %substr(&value, 13, 2);
				        %let o3 = %substr(&value, 15, 1);
				        %let minute = %substr(&value, 16, 2);
				        %let o4 = %substr(&value, 18, 1);
				        %let second = %substr(&value, 19, 2);
				        %if %sysfunc(notdigit(&year)) = 0 and %sysfunc(notdigit(&month)) = 0 and %sysfunc(notdigit(&day)) = 0 
				        and %sysfunc(notdigit(&hour)) = 0 and %sysfunc(notdigit(&minute)) = 0 and %sysfunc(notdigit(&second)) = 0 
				        and "&o1" = "-" and "&o2" = "-" and "&o3" = ":" and "&o4" = ":" and "&concat" = "T" %then %do;
				            PROC SQL;
								UPDATE work.correctIndicators
								SET validRelativeTimestamp = 0;
							QUIT;
				        %end;
				        %else %do;
				        	PROC SQL;
								UPDATE work.correctIndicators
								SET validTimestamp = 0;
							QUIT;
				        %end;
				    %end;
					%else %do;
						PROC SQL;
							UPDATE work.correctIndicators
							SET validTimestamp = 0;
						QUIT;
					%end;
			    %end;
			    
			    %if "&prefix" = "DATETIME()" %then %do;
			    	PROC SQL;
						UPDATE work.correctIndicators
						SET validTimestamp = 0;
					QUIT;
			    	%if %Length(&value) > 12 %then %do;
				    	%let valueOperator = %substr(&value, 12, 1);
						%let digit = %substr(&value, 13, %eval(%length(&value) - 13);

						%if %sysfunc(notdigit(&digit)) > 0 %then %do;
				        	PROC SQL;
								UPDATE work.correctIndicators
								SET validRelativeTimestamp = 0;
							QUIT;
			    		%end;
			    		
			    		%if "&valueOperator" ne "+" and "&valueOperator" ne "-" %then %do;
				        	PROC SQL;
								UPDATE work.correctIndicators
								SET validRelativeTimestamp = 0;
							QUIT;
			    		%end;
					%end;
					%else %do;
						%if %Length(&value) ne 10 %then %do;
							PROC SQL;
								UPDATE work.correctIndicators
								SET validRelativeTimestamp = 0;
							QUIT;
						%end;
					%end;
			    %end;
			    %else %do;
			    	PROC SQL;
						UPDATE work.correctIndicators
						SET validRelativeTimestamp = 0;
					QUIT;
			    %end; 
			%end;
			%else %do;
				PROC SQL;
					UPDATE work.correctIndicators
					SET validRelativeTimestamp = 0,
					validTimestamp = 0;
				QUIT;		
			%end;	
		%mend;
		
		%macro boolTest(dtype, value);
			%if ("&dtype" = "BOOL" and &value = 1) or ("&dtype" = "BOOL" and &value = 0) %then %do;
				PROC SQL;
					UPDATE work.correctIndicators
					SET validBool = 1;
				QUIT;
			%end;
			%else %do;
				PROC SQL;
					UPDATE work.correctIndicators
					SET validBool = 0;
				QUIT;
			%end;
		%mend;
		
		%macro textTest(dtype, value);
			%let doubleQuotesCount = %sysfunc(countc(&value, %str(%")));
		    %let singleQuotesCount = %sysfunc(countc(&value, %str(%')));
			
			%if ((&doubleQuotesCount = 2 and "&dtype" = "TEXT") or (&singleQuotesCount = 2 and "&dtype" = "TEXT")) %then %do;
				PROC SQL;
					UPDATE work.correctIndicators
					SET validText = 1;
				QUIT;
			%end;
			%else %do;
				PROC SQL;
					UPDATE work.correctIndicators
					SET validText = 0;
				QUIT;
			%end;
		%mend;
		
		
		%if "&operator" = "'>'" or "&operator" = "'>='" or "&operator" = "'='" or "&operator" = "'<='" or "&operator" = "'<'" or "&operator" = "'<>'" %then %do;
			%initTest;
			%if "&dtype" = "NUMERIC" or "&dtype" = "DATE" or "&dtype" = "TIMESTAMP" %then %do;
				
				/*NUM test*/
				%numericTest(dtype=&dtype, value=&value);
				
			    /*Date test*/
			    %dateTest(dtype=&dtype, value=&value);
			    
			    /*Timestamp test*/
			    %timestampTest(dtype=&dtype, value=&value);
				PROC SQL noprint;
					SELECT Max(validNumeric) INTO :validNumeric FROM work.correctIndicators;
					SELECT Max(validDate) INTO :validDate FROM work.correctIndicators;
					SELECT Max(validRelativeDate) INTO :validRelativeDate FROM work.correctIndicators;
					SELECT Max(validTimestamp) INTO :validTimestamp FROM work.correctIndicators;
					SELECT Max(validRelativeTimestamp) INTO :validRelativeTimestamp FROM work.correctIndicators;
				QUIT;
				%let correctIndicator = &validNumeric + &validDate + &validRelativeDate + &validTimestamp + &validRelativeTimestamp;
				/* check correctnes */
				%if &correctIndicator = 1 %then %do;
					%goto saveConstraint;
				%end;
				%else %do;
					%let incorrectIndicator = 1;
					%goto incorrect;
				%end;
			%end;
			%if "&dtype" = "BOOL" and ("&operator" = "'='" or "&operator" = "'<>'") %then %do;
				%boolTest(dtype=&dtype, value=&value);
				
				PROC SQL noprint;
					SELECT Max(validBool) INTO :validBool FROM work.correctIndicators;
				QUIT;
				
				%let correctIndicator = &validBool;
				%if &correctIndicator = 1 %then %do;
					%goto saveConstraint;
				%end;
				%else %do;
					%let incorrectIndicator = 1;
					%goto incorrect;
				%end;
			%end;
			%if "&dtype" = "TEXT" and ("&operator" = "'='" or "&operator" = "'<>'") %then %do;
				%textTest(dtype=&dtype, value=&value);
				
				PROC SQL noprint;
					SELECT Max(validText) INTO :validText FROM work.correctIndicators;
				QUIT;
				
				%let correctIndicator = &validText;
				%if &correctIndicator = 1 %then %do;
					%goto saveConstraint;
				%end;
				%else %do;
					%let incorrectIndicator = 1;
					%goto incorrect;
				%end;
			%end;
		%end;
		%if ("&operator" = "NOT LIKE" and "&dtype" = "TEXT") or ("&operator" = "NOT LIKE" and "&dtype" = "TEXT")  %then %do;
			%initTest;
			%textTest(dtype=&dtype, value=&value);
			
			%let position = %index(&value, /prct);
			
			%if &position > 1 %then %do;
				PROC SQL noprint;
					SELECT Max(validText) INTO :validText FROM work.correctIndicators;
				QUIT;
			%end;
			%else %do;
				%let validText = 0;
			%end;
			%let correctIndicator = &validText;
			%if &correctIndicator = 1 %then %do;
				%goto saveConstraint;
			%end;
			%else %do;
				%let incorrectIndicator = 1;
				%goto incorrect;
			%end;
		%end;
		%if ("&operator" = "BETWEEN" and "&dtype" = "NUMERIC") or  ("&operator" = "NOT BETWEEN" and "&dtype" = "NUMERIC")
			or ("&operator" = "BETWEEN" and "&dtype" = "DATE") or  ("&operator" = "BETWEEN" and "&dtype" = "DATE")
			or  ("&operator" = "BETWEEN" and "&dtype" = "TIMESTAMP") or  ("&operator" = "BETWEEN" and "&dtype" = "TIMESTAMP") %then %do;
			
			
			
			%let correctIndicator = 0;
			%let countVar = %sysfunc(countw(&value, |));
			%if &countVar = 2 %then %do;
				%let count = 1;

			    %do %while (%scan(&value, &count, |) ne );
			        %let currentValue = %scan(&value, &count, |);
			        %initTest;
			        %numericTest(dtype=&dtype, value=&currentValue);
			        %dateTest(dtype=&dtype, value=&currentValue);
			        %timestampTest(dtype=&dtype, value=&currentValue);
			        
					PROC SQL noprint;
						SELECT Max(validNumeric) INTO :validNumeric FROM work.correctIndicators;
						SELECT Max(validDate) INTO :validDate FROM work.correctIndicators;
						SELECT Max(validRelativeDate) INTO :validRelativeDate FROM work.correctIndicators;
						SELECT Max(validTimestamp) INTO :validTimestamp FROM work.correctIndicators;
						SELECT Max(validRelativeTimestamp) INTO :validRelativeTimestamp FROM work.correctIndicators;
					QUIT;
					
					%let correctIndicator = %eval(&correctIndicator + &validNumeric + &validDate + &validRelativeDate + &validTimestamp + &validRelativeTimestamp);
			        %let count = %eval(&count + 1);
			    %end;

			    %if &correctIndicator = 2 %then %do;
					%goto saveConstraint;
				%end;
				%else %do;
					%let incorrectIndicator = 1;
					%goto incorrect;
				%end;
			 %end;
		%end;
		%if ("&operator" = "IN" and "&dtype" = "NUMERIC") or  ("&operator" = "NOT IN" and "&dtype" = "NUMERIC")
			or ("&operator" = "IN" and "&dtype" = "DATE") or  ("&operator" = "NOT IN" and "&dtype" = "DATE")
			or  ("&operator" = "IN" and "&dtype" = "TIMESTAMP") or  ("&operator" = "NOT IN" and "&dtype" = "TIMESTAMP") 
			or  ("&operator" = "IN" and "&dtype" = "TEXT") or  ("&operator" = "NOT IN" and "&dtype" = "TEXT") %then %do;
			
			
			
			%let correctIndicator = 0;
			%let countVar = %sysfunc(countw(&value, |));
			%let count = 1;

		    %do %while (%scan(&value, &count, |) ne );
		        %let currentValue = %scan(&value, &count, |);
		        %initTest;
		        %numericTest(dtype=&dtype, value=&currentValue);
		        %dateTest(dtype=&dtype, value=&currentValue);
		        %timestampTest(dtype=&dtype, value=&currentValue);
		        %textTest(dtype=&dtype, value=&currentValue);
		        
				PROC SQL noprint;
					SELECT Max(validNumeric) INTO :validNumeric FROM work.correctIndicators;
					SELECT Max(validDate) INTO :validDate FROM work.correctIndicators;
					SELECT Max(validRelativeDate) INTO :validRelativeDate FROM work.correctIndicators;
					SELECT Max(validTimestamp) INTO :validTimestamp FROM work.correctIndicators;
					SELECT Max(validRelativeTimestamp) INTO :validRelativeTimestamp FROM work.correctIndicators;
					SELECT Max(validText) INTO :validText FROM work.correctIndicators;
				QUIT;
				
				%let correctIndicator = %eval(&correctIndicator + &validNumeric + &validDate + &validRelativeDate + &validTimestamp + &validRelativeTimestamp + &validText);
		        %let count = %eval(&count + 1);
		    %end;

		    %if &correctIndicator = &countVar %then %do;
				%goto saveConstraint;
			%end;
			%else %do;
				%let incorrectIndicator = 1;
				%goto incorrect;
			%end;
		%end;
		%saveConstraint: %put Done, correct score for &correctIndicator variables;
		%updateConstraint(id=&constraintId, name=&name, value=&value);
		%let incorrectIndicator = 0;
		%incorrect: %if &incorrectIndicator = 1 %then %put Check your data!;
	%end;
	%else %do;
		%put Constraint &name or attribute &attribute not exist!;
		
	%end;
%mend;

/* %updateConstraintValue(name=TestConstraint1, value='T', source=WORK, context=TEST); */
