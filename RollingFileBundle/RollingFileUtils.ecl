import std;

EXPORT RollingFileUtils := MODULE


	EXPORT STRING kIndexSuffix := '_ind';	
	
	EXPORT ToIndexFileName(STRING fileName, STRING indexId='') := FUNCTION
	
		String indexSuffix := IF(indexId='',kIndexSuffix,'_'+indexId+kIndexSuffix);
		RETURN fileName+indexSuffix;
	
	END;
	
	EXPORT  GetSuperFileContents(String  SFName) := FUNCTION
			FilesList  := NOTHOR(STD.File.SuperFileContents(SFName,TRUE));
	RETURN FilesList;
	END;


END;
