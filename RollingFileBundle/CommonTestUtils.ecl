EXPORT CommonTestUtils := MODULE

	EXPORT PersonRec := RECORD

		STRING5 sourceName;
		STRING30 fname;
		STRING30 lname;
		STRING5 UUID;

	END;
	
	
	EXPORT PersonIndexRec := RECORD
	
		PersonRec.fName;
	
	END;
	
	EXPORT PersonPayloadRec := RECORD
	
		PersonRec.sourceName;
		PersonRec.lName;
		PersonRec.UUID;
	
	END;	
	

	

	EXPORT source1Data := DATASET	(
								[
									{'s1', 'Jake','Smith',1},{'s1', 'Bryan','York',2}
								],
								PersonRec
							);
							
	EXPORT source2Data := DATASET	(
								[
									{'s2', 'Jake','Smith',3},{'s2', 'Bryan','York',4}
								],
								PersonRec
							);						
							
	EXPORT source3Data := DATASET	(
								[
									{'s3', 'Jake','Smith',5},{'s3', 'Bryan','York',6}
								],
								PersonRec
							);		

END;