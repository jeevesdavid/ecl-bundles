
EXPORT SampleIndexer := MODULE($.FileIndexer)

	EXPORT BOOLEAN IndexingSupported := TRUE;	
	


	EXPORT IndexFile(STRING fileName, STRING indexFileName) := FUNCTION
	

		ds := DATASET(fileName,$.CommonTestUtils.PersonRec,THOR);
 		ind := INDEX(ds,{fname},{sourceName,lName,UUID},indexFileName);
   		BuildIDX := BUILDINDEX(ind,OVERWRITE);
        RETURN BuildIDX;

  END;
  
END;