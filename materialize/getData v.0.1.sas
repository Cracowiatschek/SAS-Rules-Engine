%macro getData(source, context);

	PROC SQL;
		CREATE TABLE &source..&context._CustomerData AS (
			SELECT DISTINCT Index as customerId, SubscriptionDate, Country FROM customer.customer
			WHERE Index IN (
				SELECT customerId FROM &source..&context._segment
			)
		);
	QUIT;
%mend;

/* %getData(source=work, context=TEST); */