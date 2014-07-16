

EXPORT RollingFileStructures := MODULE


	EXPORT FileStatus := ENUM(INIT,FIRSTRUN,RL_NONE,RL_YEARLY,RL_MONTHLY,RL_DAILY,RL_HOURLY);
	

	EXPORT FileStatusRec := RECORD
	
		FileStatus fileStatus;
		
		UNSIGNED statusDate;
	
	END;
	
	EXPORT FileDetailsRec := RECORD
	
		STRING queryName;
	
		STRING superFileName;
		
		STRING logicalFileList;
	
	END;
	
	EXPORT PackageMapRec := RECORD
	
		STRING superFileName;
		STRING queryName;
		STRING subFileName;
	
	END;
	
	EXPORT DateTime(STRING date='') := MODULE


		EXPORT INTEGER2 Year := (UNSIGNED)date[1..4];
		
		EXPORT UNSIGNED1 Month := (UNSIGNED)date[5..6];
		
		EXPORT UNSIGNED1 Day := (UNSIGNED)date[7..8];
		
		EXPORT UNSIGNED1 Hour := (UNSIGNED)date[9..10];
		
		EXPORT UNSIGNED1 Minute := (UNSIGNED)date[11..12];
		
		EXPORT UNSIGNED1 Second := (UNSIGNED)date[13..14];	
		
		EXPORT STRING DateAsString := date;
		
	
	END;
	


	

	




END;