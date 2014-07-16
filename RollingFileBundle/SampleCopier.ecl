EXPORT SampleCopier := MODULE($.FileCopier)

	
	EXPORT  Copy(STRING source, STRING destination) := FUNCTION
	
		contents := DATASET(source,$.CommonTestUtils.PersonRec,THOR);
		
		RETURN OUTPUT(contents,,destination,THOR);
		
		
	END;

END;

