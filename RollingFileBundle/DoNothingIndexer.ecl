EXPORT DoNothingIndexer := MODULE($.FileIndexer)


	EXPORT BOOLEAN IndexingSupported := False;
	
	EXPORT IndexFile(STRING fileName, STRING indexFileName) := FUNCTION
	
		RETURN SEQUENTIAL(OUTPUT('Override this'));
		
	END;
	


END;