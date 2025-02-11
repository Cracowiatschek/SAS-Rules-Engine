
%macro configSegmentDetails(name, holidaysFlag, runDays, priority, source, context); 
/*
name - segment name
holidaysFlag - if the segment is to ignore all holidays and days free from work set 1 else 0
runDays - if segment is to be calculate daile set Daily, 
if segment is to be calculate weekly set day when it will be calculate for example: Monday
if segment is to be calculate more then once at week set days separated by space for example: Monday Friday
priority - set up segment priority and recalculate other segments priorities
*/
	%let SegmentDetails = &source..&context._SegmentDetails;
	PROC SQL NOPRINT;
		SELECT Count(*) INTO :segmentsCnt FROM &SegmentDetails;
		SELECT Max(segmentId)+1 INTO :maxId FROM &SegmentDetails;
	QUIT;
	
	%if %Length(&priority) = 0 AND &maxId = . %then %do;
		%put Pierszy wpis ustawiono priority: 1;
		%let &priority = 1;
	%end;
	
	%if %Length(&holidaysFlag) = 0 %then %do;
		%put Automatycznie ustawiono wartość domyślną holidaysFlag: 0;
		%let &holidaysFlag = 0;
	%end;

	%if %Length(&priority) = 0 AND &maxId > 0 %then %do;
		PROC SQL NOPRINT;
			SELECT Max(priority)+1 INTO :priority FROM &SegmentDetails;
		QUIT;
		%put Automatycznie ustawiono wartość priority: &priority;
	%end;

	%if &maxId = . %then %do;
		%let maxId = 1;
	%end;

	%if &priority > &maxId+1 %then %do;
		%let priority = &maxId;
	%end;
	
	%macro updatePriority;
		%if &segmentsCnt > 0 %then %do;
			PROC SQL;
				UPDATE &SegmentDetails
				SET priority = priority + 1
				WHERE priority >= &priority;
			QUIT;
		%end;
	%mend;
	
	%macro setNoDailyFlags(runDays);
		
		%let newRunDays = &monday, &tuesday, &wednesday, &thursday, &friday, &saturday, &sunday;
	%mend;
	
	%if %upcase(&runDays) = DAILY %then %do;
		%updatePriority;
		PROC SQL;
			INSERT INTO &SegmentDetails (
				segmentId, 
				segmentName, 
				holidaysFlag, 
				monday, 
				tuesday, 
				wednesday, 
				thursday, 
				friday, 
				saturday, 
				sunday, 
				priority,
				isActive)
			VALUES (
				&maxId, 
				"&name", 
				&holidaysFlag, 
				1, 
				1, 
				1, 
				1, 
				1, 
				1, 
				1, 
				&priority,
				1);
		QUIT;
	%end;
	%if %upcase(&runDays) ne DAILY %then %do;
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
	    
		%updatePriority;

		PROC SQL;
			INSERT INTO &SegmentDetails (
				segmentId, 
				segmentName, 
				holidaysFlag, 
				monday, 
				tuesday, 
				wednesday, 
				thursday, 
				friday, 
				saturday, 
				sunday, 
				priority,
				isActive)
			VALUES (
				&maxId, 
				"&name", 
				&holidaysFlag, 
				&monday, 
				&tuesday, 
				&wednesday, 
				&thursday, 
				&friday, 
				&saturday, 
				&sunday,
				&priority,
				1);
		QUIT;
	%end;
%mend;
		
/* %configSegmentDetails(name=Test, holidaysFlag=0, runDays=THURSDAY WEDNESDAY TUESDAY, priority=2, source=work, context=TEST) */