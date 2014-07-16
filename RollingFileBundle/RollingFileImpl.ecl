IMPORT STD;
IMPORT * from $.RollingFileStructures;
IMPORT * from $.DateTimeLibrary;
IMPORT  $.RollingFileUtils;

EXPORT RollingFileImpl(String rootPath, String fileName, $.FileCopier copier, $.FileIndexer indexer, $.FileIndexer indexer2, STRING indexer2Name ) := MODULE
	
	EXPORT STRING kFileNameSep := '_';
		
	EXPORT STRING kMutableFilesDir := rootPath+'::'+fileName;
	
	EXPORT STRING kMinuteFilesDir := kMutableFilesDir+'::'+'MIN';
	
	EXPORT STRING kDailyFilesDir := kMutableFilesDir+'::'+'DAY';
	
	EXPORT STRING kHourlyFilesDir := kMutableFilesDir+'::'+'HOUR';
	
	EXPORT STRING kMonthlyFilesDir := kMutableFilesDir+'::'+'MONTH';
	
	EXPORT STRING kYearlyFilesDir := kMutableFilesDir+'::'+'YEAR';
	
	EXPORT STRING kSuperFilesDir := kMutableFilesDir+'::'+'SF';
	
	EXPORT STRING kLogFilesDir := kMutableFilesDir+'::'+'LOGS';
	
	EXPORT STRING kStatusLogFile := kLogFilesDir+'::'+'StatusLog';
	
	EXPORT STRING kAllSF := kSuperFilesDir+'::'+'AllSF';
	
	EXPORT STRING kPrimarySK := kSuperFilesDir+'::'+'PrimarySK';
	
	EXPORT STRING kSecondarySK := kSuperFilesDir+'::'+'SecondarySK';
	
	EXPORT STRING kTempSF := kSuperFilesDir+'::'+'TempSF';
	
	EXPORT STRING kCurrentYearSF := kSuperFilesDir+'::'+'CurrentYearSF';
	
	EXPORT STRING kCurrentYearSK := kSuperFilesDir+'::'+'CurrentYearSK';
	
	EXPORT STRING kCurrentMonthSF := kSuperFilesDir+'::'+'CurrentMonthSF';
	
	EXPORT STRING kCurrentMonthSK := kSuperFilesDir+'::'+'CurrentMonthSK';
	
	EXPORT STRING kCurrentDaySF := kSuperFilesDir+'::'+'CurrentDaySF';
	
	EXPORT STRING kCurrentDaySK := kSuperFilesDir+'::'+'CurrentDaySK';
	
	EXPORT STRING kCurrentHourSF := kSuperFilesDir+'::'+'CurrentHourSF';
	
	EXPORT STRING kCurrentHourSK := kSuperFilesDir+'::'+'CurrentHourSK';
	


	
	//YYYYMMDDHHMMmmss
	
	STRING tempDate := DateTimeLibrary.GetDateTime():INDEPENDENT;
	
	EXPORT CurrentRunTime := DateTime(tempDate);
	
	EXPORT DATASET(STD.File.FsLogicalFileNameRecord) activeFileList  := STD.File.SuperFileContents(kAllSF,TRUE);
	
	//EXPORT DATASET(STD.File.FsLogicalFileNameRecord) activeIndexFileList  := STD.File.SuperFileContents(kAllSK,TRUE);
	
	
	EXPORT AllIndexFiles := NOTHOR(STD.File.LogicalFileList(kMutableFilesDir[2..] + '::*' + $.RollingFileUtils.kIndexSuffix ));
	

	
	
/* NOT WORKING WITH MORE THAN ONE SUBFILE
	SHARED BOOLEAN CopyFile(STRING Source,STRING Destination, BOOLEAN AsSuperFile) := FUNCTION
		Act	:= STD.File.Copy(Source,'',Destination,,-1,,,allowoverwrite:=TRUE,AsSuperfile:=AsSuperFile);
		RETURN WHEN(TRUE,Act);
	 END;
*/  
  
	/**
	 *
	 * Return the minute from the current time 0 - 59
	 */
	EXPORT STRING GetMinuteOfHour() := FUNCTION
	
		RETURN '00';
		
	END;
	
	/**
	 *	Return file name in format 
	 *
	 */
	EXPORT STRING GetFileNameForThisMinute(UNSIGNED UUID) := FUNCTION
	
		//  (Nov 05 2013, 13 Hrs, 59 minutes)
		RETURN kMinuteFilesDir+'::'+CurrentRunTime.Year+kFileNameSep+CurrentRunTime.Month+kFileNameSep+
				CurrentRunTime.Day+kFileNameSep+CurrentRunTime.Hour+kFileNameSep+CurrentRunTime.Minute+kFileNameSep+CurrentRunTime.Second+'_'+UUID;
		
	END;	
	
	/**
	 *	
	 *	Returns Previous Year: Get current year and substract one from it 
	 */
	EXPORT STRING GetYearlyRollupFileName() := FUNCTION
		
		RETURN kYearlyFilesDir+'::'+(CurrentRunTime.Year-1);
		
	END;		
	
	/**
	 *
	 * <CurrentYear>_<PreviousMonth>
	 */
	EXPORT STRING GetMonthlyRollupFileName() := FUNCTION
		
		RETURN kMonthlyFilesDir+'::'+CurrentRunTime.Year+kFileNameSep+(CurrentRunTime.Month-1);
		
	END;			
	
	/**
	 *
	 * <CurrentYear>_<CurrentMonth>_<PreviousDay>
	 */
	EXPORT STRING GetDailyRollupFileName() := FUNCTION
		
		RETURN kDailyFilesDir+'::'+CurrentRunTime.Year+kFileNameSep+CurrentRunTime.Month+kFileNameSep+(CurrentRunTime.Day-1);
		
	END;				

	/**
	 *
	 * <CurrentYear>_<CurrentMonth>_<CurrentDay>_<PreviousHour>
	 */	
	EXPORT STRING GetHourlyRollupFileName() := FUNCTION
		
		RETURN kHourlyFilesDir+'::'+CurrentRunTime.Year+kFileNameSep+CurrentRunTime.Month+kFileNameSep
				+CurrentRunTime.Day+kFileNameSep+(CurrentRunTime.Hour-1);
		
	END;					
	


	EXPORT PersistStatus(FileStatus status) := FUNCTION

		temp := DATASET([{status,(UNSIGNED)CurrentRunTime.DateAsString}],FileStatusRec);

		act := SEQUENTIAL(OUTPUT(temp,,kStatusLogFile,CSV,OVERWRITE));
		
		RETURN act;
	
	END;
	
	EXPORT FileStatusRec GetStatusDetails() := FUNCTION
	
		RETURN DATASET(kStatusLogFile,FileStatusRec,CSV)[1];

	
	END;
	
	EXPORT BOOLEAN IsFirstRun() := FUNCTION

			RETURN IF(GetStatusDetails().fileStatus = FileStatus.INIT, TRUE,FALSE);
		
	END;
	/**
	 *
	 * Return HOURLY, DAILY, MONTHLY or YEARLY
	 */	
	EXPORT UNSIGNED GetRollupRequired() := FUNCTION
	
		lastStatus := GetStatusDetails();
		lastRunTime := DateTime((STRING)lastStatus.statusDate);
		
		//RETURN FileStatus.RL_YEARLY;
		
		//CurrentRunTime.Hour  = 7;

 		RETURN	MAP	(	
   						CurrentRunTime.Year-lastRunTime.Year > 0 => FileStatus.RL_YEARLY,
   						CurrentRunTime.Month-lastRunTime.Month > 0 => FileStatus.RL_MONTHLY,
   						CurrentRunTime.Day-lastRunTime.Day > 0 => FileStatus.RL_DAILY,						
   						CurrentRunTime.Hour-lastRunTime.Hour > 0 => FileStatus.RL_HOURLY,						
   						FileStatus.RL_NONE
   					);

					
	END;
	
	
	EXPORT  CreateSFAct(String  SFName) := FUNCTION
	
		act := SEQUENTIAL(NOTHOR(Std.File.CreateSuperFile(SFName,allow_exist:=TRUE)));
		
		RETURN act;
		
	END;		
	
	
	
	EXPORT  AddSFAct(STRING  SFName, STRING partName) := FUNCTION
	
		act := STD.File.AddSuperFile(SFName,partName);
		
		RETURN act;
		
	END;	
	
	//To be used only for add a superfile as a subfile
	EXPORT  AddSFIfNotEmpty(STRING  SFName, STRING partName) := FUNCTION
	
		subFileExists := STD.File.GetSuperFileSubCount(partName) > 0;
		act := IF(subFileExists,STD.File.AddSuperFile(SFName,partName));
		
		RETURN act;
		
	END;		
	
	EXPORT  CreateFileAct(STRING  FName, DATASET ds) := FUNCTION
	
		act := OUTPUT(ds,,FName,THOR,OVERWRITE);
		
		RETURN act;
		
	END;
	
	EXPORT clearSuperFileact(STRING fn, BOOLEAN del = TRUE) := FUNCTION
	
		RETURN IF(STD.File.SuperFileExists(fn), STD.File.ClearSuperFile(fn,del));
	
	END;	
	

	
	EXPORT IndexFile(STRING fileName) := FUNCTION
	
		indexNewFileAct := IF	(
									indexer.IndexingSupported,
									indexer.IndexFile(fileName,RollingFileUtils.ToIndexFileName(fileName))
								);
								
		indexNewFileSecondaryAct := IF	(
									indexer2.IndexingSupported,
									indexer2.IndexFile(fileName,RollingFileUtils.ToIndexFileName(fileName,indexer2Name))
								);								
		
		RETURN SEQUENTIAL(indexNewFileAct,indexNewFileSecondaryAct);
	
	END;
	
 	EXPORT subFileSection(STRING fileName) := FUNCTION
   		
						active_Files_List  := NOTHOR(STD.File.SuperFileContents(fileName,TRUE));
						
						STD.File.FsLogicalFileNameRecord active_File_List_Transform(active_Files_List L):= TRANSFORM
      					SELF.name := '<SubFile value="' + '~' + L.name + '_ind' + '"/>';
      			END;	
						
      			activeFileList_Ind := PROJECT(active_Files_List  , active_File_List_Transform(LEFT));
						
      			STD.File.FsLogicalFileNameRecord xform(activeFileList_Ind L , activeFileList_Ind R) := TRANSFORM
      				SELF.name := L.name + R.name;
      			END;
      			rollup_test := ROLLUP(activeFileList_Ind , 1 = 1 , xform(LEFT , RIGHT));

   
   	RETURN rollup_test[1].name ;
		//RETURN IF(Std.File.FileExists(fileName),SEQUENTIAL(OUTPUT(rollup_test[1].name)));
   	
   	END;

	
	EXPORT Initialize() := FUNCTION
	
		act := SEQUENTIAL	(
								CreateSFAct(kCurrentYearSF),
								//CreateSFAct(kCurrentYearSK),
								
								CreateSFAct(kCurrentMonthSF),
								//CreateSFAct(kCurrentMonthSK),
								
								CreateSFAct(kCurrentDaySF),
								//CreateSFAct(kCurrentDaySK),
								
								CreateSFAct(kCurrentHourSF),
								//CreateSFAct(kCurrentHourSK),
								
								CreateSFAct(kAllSF),
								//CreateSFAct(kAllSK),
								
								CreateSFAct(kTempSF),
								
								CreateSFAct(kPrimarySK);
								
								CreateSFAct(kSecondarySK);
								
								STD.File.StartSuperFileTransaction(),
								
								AddSFAct(kAllSF,kCurrentYearSF)	,
								//AddSFAct(kAllSK,kCurrentYearSK)	,
								
								AddSFAct(kAllSF,kCurrentMonthSF),								
								//AddSFAct(kAllSK,kCurrentMonthSK),	
								
								AddSFAct(kAllSF,kCurrentDaySF),								
								//AddSFAct(kAllSK,kCurrentDaySK),								
								
								AddSFAct(kAllSF,kCurrentHourSF),
								//AddSFAct(kAllSK,kCurrentHourSK),
								
								STD.File.FinishSuperFileTransaction(),
								PersistStatus(FileStatus.INIT);
							);
							
							
		RETURN IF(NOT STD.File.SuperFileExists(kAllSF),act);
							
	
	END;	
	
	EXPORT  DoYearlyRollup() := FUNCTION
	
		rolledUpFileName := GetYearlyRollupFileName();
		act := SEQUENTIAL	(
								//To be safe clear the temp SF
								STD.File.ClearSuperFile(kTempSF),
								
								//Prepare for rollup - Add constituent files to a temporary super file 
								AddSFIfNotEmpty(kTempSF,kCurrentHourSF),
								AddSFIfNotEmpty(kTempSF,kCurrentDaySF),
								AddSFIfNotEmpty(kTempSF,kCurrentMonthSF),
								AddSFIfNotEmpty(kTempSF,kCurrentYearSF),
								
								//This rolls up all files in the temp SF into one
								copier.Copy(kTempSF,rolledUpFileName),
								
								//Clear the files which have been rolled up
								STD.File.ClearSuperFile(kCurrentYearSF,TRUE),
								STD.File.ClearSuperFile(kCurrentMonthSF,TRUE),
								STD.File.ClearSuperFile(kCurrentDaySF,TRUE),
								STD.File.ClearSuperFile(kCurrentHourSF,TRUE),
								
								//Clear the index files which have been rolled up
								//STD.File.ClearSuperFile(kCurrentYearSK,TRUE),
								//STD.File.ClearSuperFile(kCurrentMonthSK,TRUE),
								//STD.File.ClearSuperFile(kCurrentDaySK,TRUE),
								//STD.File.ClearSuperFile(kCurrentHourSK,TRUE),								
								
								//To be safe clear the temporary SF
								STD.File.ClearSuperFile(kTempSF),
								
								//Add the newly generated file to the appropriate SF.
								AddSFAct(kAllSF,rolledUpFileName),
								
								//Index the newly generated file
								IndexFile(rolledUpFileName),
								
								//Add the new index to the appropriate SK(super Key)
								//AddSFAct(kAllSK,ToIndexFileName(rolledUpFileName))
							);


		RETURN act;
		
	END;
	
	EXPORT  DoMonthlyRollup() := FUNCTION
	
		rolledUpFileName := GetMonthlyRollupFileName();
		act := SEQUENTIAL	(
								//Clear the files which have been rolled up
								STD.File.ClearSuperFile(kTempSF),
								
								//Prepare for rollup - Add constituent files to a temporary super file 
								AddSFIfNotEmpty(kTempSF,kCurrentMonthSF),				
								AddSFIfNotEmpty(kTempSF,kCurrentDaySF),		
								AddSFIfNotEmpty(kTempSF,kCurrentHourSF),
								
								//This rolls up all files in the temp SF into one
								copier.Copy(kTempSF,rolledUpFileName),
								
								//Clear the files which have been rolled up
								STD.File.ClearSuperFile(kCurrentMonthSF,TRUE),								
								STD.File.ClearSuperFile(kCurrentDaySF,TRUE),
								STD.File.ClearSuperFile(kCurrentHourSF,TRUE),
								
								//Clear the index files which have been rolled up
								//STD.File.ClearSuperFile(kCurrentMonthSK,TRUE),
								//STD.File.ClearSuperFile(kCurrentDaySK,TRUE),
								//STD.File.ClearSuperFile(kCurrentHourSK,TRUE),									
								
								//To be safe clear the temporary SF
								STD.File.ClearSuperFile(kTempSF),
								
								//Add the newly generated file to the appropriate SF.
								AddSFAct(kCurrentYearSF,rolledUpFileName),
								
								//Index the newly generated file
								IndexFile(rolledUpFileName),
								
								//Add the new index to the appropriate SK(super Key)
								//AddSFAct(kCurrentYearSK,ToIndexFileName(rolledUpFileName))

							);


		RETURN act;
		
	END;			
	
	EXPORT  DoDailyRollup() := FUNCTION
	
		rolledUpFileName := GetDailyRollupFileName();
		act := SEQUENTIAL	(
								STD.File.ClearSuperFile(kTempSF),
								
								AddSFIfNotEmpty(kTempSF,kCurrentDaySF),		
								AddSFIfNotEmpty(kTempSF,kCurrentHourSF),
								
								copier.Copy(kTempSF,rolledUpFileName),
								
								STD.File.ClearSuperFile(kCurrentDaySF,TRUE),
								STD.File.ClearSuperFile(kCurrentHourSF,TRUE),
								
								//Clear the index files which have been rolled up
								//STD.File.ClearSuperFile(kCurrentDaySK,TRUE),
								//STD.File.ClearSuperFile(kCurrentHourSK,TRUE),								
								
								STD.File.ClearSuperFile(kTempSF),
								
								AddSFAct(kCurrentMonthSF,rolledUpFileName),
								
								//Index the newly generated file
								IndexFile(rolledUpFileName),
								
								//Add the new index to the appropriate SK(super Key)
								//AddSFAct(kCurrentMonthSK,ToIndexFileName(rolledUpFileName))

							);


		RETURN act;
		
	END;		
	
	EXPORT  DoHourlyRollup() := FUNCTION
	
		rolledUpFileName := GetHourlyRollupFileName();
		act := SEQUENTIAL	(
								//Copy Hour SF as Hour LF
								copier.copy(kCurrentHourSF,rolledUpFileName);
								//CopyFile(kCurrentHourSF,rolledUpFileName,FALSE),								
								//Add Hour LF to Day SF
								AddSFAct(kCurrentDaySF,rolledUpFileName),
								//Clear Hour SF
								STD.File.ClearSuperFile(kCurrentHourSF,TRUE),
								
								//Clear the index files which have been rolled up
								//STD.File.ClearSuperFile(kCurrentHourSK,TRUE),								
								
								IndexFile(rolledUpFileName),
								
								//Add the new index to the appropriate SK(super Key)
								//AddSFAct(kCurrentDaySK,ToIndexFileName(rolledUpFileName))								
							);

		RETURN act;
		
	END;	

	EXPORT GetIndexFiles(String indexId)  := FUNCTION
		
		emptyList := DATASET([],STD.File.FsLogicalFileNameRecord);
		fileList  := RollingFileUtils.GetSuperFileContents(kAllSF);
		
		STD.File.FsLogicalFileNameRecord FileListTransform(fileList L):= TRANSFORM
					
			SELF.name :=  '~'+RollingFileUtils.ToIndexFileName(L.name , indexId );
   												
   		END;	
		
		indexFileList :=  PROJECT(fileList , FileListTransform(LEFT));
		
		return IF(STD.File.SuperFileExists(kAllSF),indexFileList,emptyList);

	END;
	
	EXPORT DATASET(STD.File.FsLogicalFileNameRecord) getPrimaryIndexFiles() := FUNCTION
		
		RETURN NOTHOR(GetIndexFiles(''));
	
	END;
	
	
	EXPORT DATASET(STD.File.FsLogicalFileNameRecord) getSecondaryIndexFiles() := FUNCTION
		
		RETURN NOTHOR(IF(indexer2Name<>'',GetIndexFiles(indexer2Name) , DATASET([],STD.File.FsLogicalFileNameRecord)));
	
	END;	
	

	
	EXPORT UpdateSuperKeyAct(STRING skName,DATASET(STD.File.FsLogicalFileNameRecord) indexFiles) := FUNCTION
	
		
	  clear := clearSuperFileact(skName,false);//Do not delete index files
			
		//indexFiles := PROJECT(getIndexFiles(''),TRANSFORM(STD.File.FsLogicalFileNameRecord,SELF.name:='~'+LEFT.name));
		
		add := NOTHOR( APPLY ( indexFiles , AddSFAct(skName,name))); 
		act := IF(COUNT(indexFiles)>0, SEQUENTIAL(clear,add), SEQUENTIAL(clear));

		RETURN act;
	
	END;		
	
	EXPORT UpdatePrimarySuperKeyAct() := FUNCTION
	
		RETURN UpdateSuperKeyAct(kPrimarySK,getPrimaryIndexFiles());
	
	END;	
	
	EXPORT UpdateSecondarySuperKeyAct() := FUNCTION
	
		RETURN UpdateSuperKeyAct(kSecondarySK,getSecondaryIndexFiles());
	
	END;
	
	
//============================================================================================

	EXPORT write(DATASET dataIn, UNSIGNED UUID) := FUNCTION
		
		
		STRING minuteFile := GetFileNameForThisMinute(UUID);
			
		//createMinuteFileAct := CreateFileAct(minuteFile,dataIn);
		createMinuteFileAct := CreateFileAct(minuteFile,dataIn);
		//addMinuteFileAct :=AddSFAct(kCurrentHourSF,minuteFile);
		addMinuteFileAct :=AddSFAct(kCurrentHourSF,minuteFile);
		
		status := IF(IsFirstRun(),FileStatus.FIRSTRUN,GetRollupRequired());
		rollupAct := MAP	(
								status = FileStatus.RL_YEARLY=>DoYearlyRollup(),	
								status = FileStatus.RL_MONTHLY=>DoMonthlyRollup(),	
								status = FileStatus.RL_DAILY=>DoDailyRollup(),	
								status = FileStatus.RL_HOURLY=>DoHourlyRollup()

							);
							
		//Update the super keys. The super keys are not supposed to be published
		//They are only for testing.
							
		//updatePrimarySK := 
						
		act := SEQUENTIAL	(
								rollupAct,
								createMinuteFileAct,
								NOTHOR(addMinuteFileAct),
								IndexFile(minuteFile),
								NOTHOR(	
										SEQUENTIAL	(
														IF(indexer.IndexingSupported,UpdatePrimarySuperKeyAct()),
														IF(indexer2.IndexingSupported,UpdateSecondarySuperKeyAct())
														
													 )
										),
								IF(status<>FileStatus.RL_NONE,PersistStatus(status))
								
							);
		

		RETURN act;
		
	
	END;
	
	
	EXPORT Cleanup() := FUNCTION
		//LogicalFileList does not apend ~, which makes this code messy. 
		AllIndexFilesFilter := AllIndexFiles('~'+name NOT in SET((getPrimaryIndexFiles() + getSecondaryIndexFiles()),name));
		
		act := NOTHOR( APPLY ( AllIndexFilesFilter , STD.File.DeleteLogicalFile('~' + name))); 

		RETURN WHEN(TRUE,act);
	
	END;
	
	EXPORT Delete() := FUNCTION		
	
	
		deleteIndexFilesAct := APPLY ( AllIndexFiles , STD.File.DeleteLogicalFile('~' + name)); 
		act := NOTHOR(SEQUENTIAL	(
		
								//Cleanup(),
								//Clear all SF
								clearSuperFileact(kCurrentYearSF),
								clearSuperFileact(kCurrentMonthSF),
								clearSuperFileact(kCurrentDaySF),
								clearSuperFileact(kCurrentHourSF),
								clearSuperFileact(kCurrentHourSF),
								
								STD.File.DeleteSuperFile(kAllSF,TRUE),
								//STD.File.DeleteSuperFile(kPrimarySK,TRUE),
								//STD.File.DeleteSuperFile(kSecondarySK,TRUE),
								STD.File.DeleteSuperFile(kTempSF),
								STD.File.DeleteLogicalFile(kStatusLogFile),
								clearSuperFileact(kPrimarySK),
								clearSuperFileact(kSecondarySK),
								STD.File.DeleteSuperFile(kPrimarySK),
								STD.File.DeleteSuperFile(kSecondarySK),
								deleteIndexFilesAct
							));
							
							
		RETURN act;
	
	
	END;

	


	
END;	