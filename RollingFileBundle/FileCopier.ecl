EXPORT FileCopier := INTERFACE

	SHARED DummyRec := RECORD
	
		STRING hello;
		
	END;

	EXPORT  Copy(STRING source, STRING destination) := FUNCTION
	
		contents := DATASET(source,DummyRec,THOR);
		
		RETURN SEQUENTIAL(OUTPUT(contents,,destination,THOR,OVERWRITE));
		
	END;
	

END;