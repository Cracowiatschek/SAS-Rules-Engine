
%macro updateSegmentRunDays(name, runDays, holidaysFlag, source, context);
	%let SegmentDetails = &source..&context._SegmentDetails;

	PROC SQL NOPRINT;
		SELECT Max(segmentId)+1 INTO :maxId FROM &SegmentDetails;
	QUIT;
	
	%if &maxId = . %then %do;
		%put Segment library is empty.;
		%return;
	%end;
	
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :isExist FROM &SegmentDetails WHERE segmentName = "&name.";
	QUIT;
	
	%if &isExist = 1 %then %do;
		%if &holidaysFlag = 1 %then %do;
			PROC SQL;
				UPDATE &SegmentDetails
				SET holidaysFlag = 1
				WHERE SegmentName = "&name.";
			QUIT;
		%end;
		%if &holidaysFlag = 0 %then %do;
			PROC SQL;
				UPDATE &SegmentDetails
				SET holidaysFlag = 0
				WHERE SegmentName = "&name.";
			QUIT;
		%end;
		%if &holidaysFlag ne 1 and &holidaysFlag ne 0 %then %do;
			%put holidaysFlag is not valid!;
		%end;
		
		%if %upcase(&runDays) = DAILY %then %do;
			PROC SQL;
				UPDATE &SegmentDetails
				SET monday = 1,
				tuesday = 1,
				wednesday = 1,
				thursday = 1,
				friday = 1,
				saturday = 1,
				sunday = 1
				WHERE SegmentName = "&name.";
			QUIT;
		%end;
		%else %do;
			%let monday = 0; 
			%let tuesday = 0; 
			%let wednesday = 0; 
			%let thursday = 0; 
			%let friday = 0; 
			%let saturday = 0; 
			%let sunday = 0;
			
			%let count = 1;
		    %do %while (%scan(&runDays, &count) ne );
		        %let runDay = %upcase(%scan(&runDays, &count)); /* Pobierz wartość z listy */
		        
		        %if &runDay = MONDAY %then %do;
		        	%let monday = 1;
		        %end;
		        
		        %if &runDay = TUESDAY %then %do;
		        	%let tuesday = 1;
		        %end;
		        
		        %if &runDay = WEDNESDAY %then %do;
		        	%let wednesday = 1;
		        %end;
		        
		        %if &runDay = THURSDAY %then %do;
		        	%let thursday = 1;
		        %end;
		        
		        %if &runDay = FRIDAY %then %do;
		        	%let friday = 1;
		        %end;
		        
		        %if &runDay = SATURDAY %then %do;
		        	%let saturday = 1;
		        %end;
		        
		        %if &runDay = SUNDAY %then %do;
		        	%let sunday = 1;
		        %end;
		        
		        %let count = %eval(&count + 1);
		    %end;
		    
		    PROC SQL;
				UPDATE &SegmentDetails
				SET monday = &monday,
				tuesday = &tuesday,
				wednesday = &wednesday,
				thursday = &thursday,
				friday = &friday,
				saturday = &saturday,
				sunday = &sunday
				WHERE SegmentName = "&name.";
			QUIT;
		%end;
	%end;
	%else %do;
		%put Segment name not found.;
	%end;
%mend;

/* %updateSegmentRunDays(context=TEST, source=work, name=Test, runDays = Monday, holidaysFlag=0); */

