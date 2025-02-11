/* %let source = work; */
/* %let context = TEST; */

/*
v.0.3 - 21.01.2025
Change query variable to dtype.
Add constarint for dtype in constraint library.
Add constarint for operator in constraint library.
v.0.2 - 20.01.2025
Add context variable to set-up runable context.
Add source variable to set-up database.
Add isActive to SegmentDetails.
v.0.1 - 16.01.2025
Create basic structures.
*/
%macro createStructs(source, context);
	%let Trigger = &source..&context._Trigger;
	%let SegmentDetails = &source..&context._SegmentDetails;
	%let Constraint = &source..&context._Constraint;
	%let SubSegmentDetails = &source..&context._SubSegmentDetails;
	%let Rules = &source..&context._Rules;
	%let DecisionsRepository = &source..&context._DecisionsRepository;
	
	PROC SQL;
	
	/* Set up Trigger library*/
		CREATE TABLE &Trigger( 
			triggerId INT PRIMARY KEY,
			triggerName VARCHAR(30) NOT NULL,
			query VARCHAR(2048) NOT NULL,
			fkSegmentId INT NOT NULL,
			isActive INT NOT NULL
		);
		
	/* Add boolean constraint to boolean variables in Trigger library */
		ALTER TABLE &Trigger
	    	ADD CONSTRAINT boolean check(
	    		isActive in (0,1)
	    	)
	      	message = "Variables bool can only take values 0 or 1.";
	      	
	/* Set up SegmentsDetails library */
		CREATE TABLE &SegmentDetails (
			segmentId INT PRIMARY KEY,
			segmentName VARCHAR(30) UNIQUE NOT NULL,
			holidaysFlag INT NOT NULL,
			monday INT NOT NULL,
			tuesday INT NOT NULL,
			wednesday INT NOT NULL,
			thursday INT NOT NULL,
			friday INT NOT NULL,
			saturday INT NOT NULL,
			sunday INT NOT NULL,
			priority INT NOT NULL,
			isActive INT NOT NULL
		);
	/* Add boolean constraint to boolean variables in Segment Details library */
		ALTER TABLE &SegmentDetails
	    	ADD CONSTRAINT boolean check(
	    		holidaysFlag in (0,1)
	    		AND monday in (0,1)
	    		AND tuesday in (0,1)
	    		AND wednesday in (0,1)
	    		AND thursday in (0,1)
	    		AND friday in (0,1)
	    		AND saturday in (0,1)
	    		AND sunday in (0,1)
	    		AND isActive in (0,1)
	    	)
	      	message = "Variables bool can only take values 0 or 1.";
	
	/* Set up Constraint library */
		CREATE TABLE &Constraint. (
			constraintId INT PRIMARY KEY,
			constraintName VARCHAR(30) UNIQUE NOT NULL,
			fkSegmentId INT NOT NULL,
			attribute VARCHAR(50) NOT NULL,
			operator VARCHAR(20) NOT NULL,
			constraintValue VARCHAR(240) NOT NULL,
	 		dtype VARCHAR(10) NOT NULL, 
			isActive INT NOT NULL
		);
		
	/* Add boolean constraint to boolean variables in Constraint library */
		ALTER TABLE &Constraint.
	    	ADD CONSTRAINT boolean check(
	    		isActive in (0,1) 
	    	)
	      	message = "Variables bool can only take values 0 or 1.";
		
		ALTER TABLE &Constraint.
	    	ADD CONSTRAINT operator check(
	    		operator in ("<", "<=", ">", ">=", "=", "IN", "NOT IN", "BETWEEN", "NOT BETWEEN", "<>", "LIKE", "NOT LIKE")
	    	)
	      	message = "Variable operator can only take values <, <=, >, >=, =, IN, NOT IN, BETWEEN, NOT BETWEEN, <>, LIKE, NOT LIKE.";
	      	
	    ALTER TABLE &Constraint.
	    	ADD CONSTRAINT dtype check(
	    		dtype in ("NUMERIC", "TEXT", "BOOL", "DATE", /*"TIMESTAMP"*/)
	    	)
	      	message = "Variable dtype can only take values NUMERIC, TEXT, BOOL, DATE"/*, TIMESTAMP*/;
	
	/* Set up Sub-Segments Details library */
		CREATE TABLE &SubSegmentDetails (
			subSegmentId INT PRIMARY KEY,
			subSegmentName VARCHAR(30) UNIQUE NOT NULL,
			fkSegmentId INT NOT NULL,
			isActive INT NOT NULL
		);
		
		ALTER TABLE &SubSegmentDetails.
	    	ADD CONSTRAINT boolean check(
	    		isActive in (0,1) 
	    	)
	      	message = "Variables bool can only take values 0 or 1.";
	/* Set up Rules library */
		CREATE TABLE &Rules (
			ruleId INT PRIMARY KEY,
			type VARCHAR(30) NOT NULL,
			fkSubSegmentId INT NOT NULL,
			query VARCHAR(2048) NOT NULL,
			isActive INT NOT NULL
		);
		
		ALTER TABLE &Rules.
	    	ADD CONSTRAINT type check(
	    		type in ("CONSTRAINT", "SPLIT", "LIMIT")
	    	)
	      	message = "Variable type can only take values CONSTRAINT, SPLIT, LIMIT";
		
	/* Add boolean constraint to boolean variables in Constraint library */
		ALTER TABLE &Rules
	    	ADD CONSTRAINT boolean check(
	    		isActive in (0,1)
	    	)
	      	message = "Variables bool can only take values 0 or 1.";
	      	
	/* Set up Decisions Repository */
		CREATE TABLE &DecisionsRepository (
			decisionId INT PRIMARY KEY,
			fkConstraintId INT,
			fkSegmentId INT NOT NULL,
			result INT NOT NULL,
			decisionDateTime DATETIME NOT NULL
		);
	
	/* Add boolean constraint to boolean variables in Decisions Repository library */
		ALTER TABLE &DecisionsRepository
	    	ADD CONSTRAINT boolean check(
	    		result in (0,1)
	    	)
	      	message = "Variables bool can only take values 0 or 1.";
	QUIT;
%mend;

/* %createStructs(source=work, context=TEST) */