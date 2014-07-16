IMPORT STD;

/*
 * Use this if you have a need to keep adding rows to a logical file 
 *  and are considering using a superfile to accomplish that. 
 *
 * This component encapsulates the plumbing required to maintain a superfile hierarchy.
 */
EXPORT RollingFile	(
						STRING rootPath ='~rollingfile',
						STRING fileName,
						$.FileCopier copier,	
						$.FileIndexer indexer = $.DoNothingIndexer,
						$.FileIndexer indexer2 = $.DoNothingIndexer,
						String indexer2Name = ''
					) := MODULE


	SHARED helper := $.RollingFileImpl(rootPath,fileName,copier,indexer,indexer2,indexer2Name);
	
	SHARED noPackageToDeploy  := DATASET([],$.RollingFileStructures.PackageMapRec);
	
	EXPORT STRING PrimarySKName := helper.kPrimarySK;
	
	EXPORT STRING SecondarySKName := helper.kSecondarySK;
	
	
	/*
	 * This Initializes the file. The write method can be invoked only after create is invoked
	 */
	
	EXPORT BOOLEAN Create() := FUNCTION
	
		act := helper.initialize();
		
		RETURN WHEN(TRUE,act);
	
	END;
	
	/*
	 * Use this to add new data to the MutableFile
	 */	
	EXPORT BOOLEAN write(DATASET dataIn) := FUNCTION
		
		id := RANDOM():INDEPENDENT;
		act := SEQUENTIAL(helper.write(dataIn,id ));
		
		RETURN WHEN(TRUE,act);
	
	END;
/*	
	EXPORT STRING GetCurrentFileName() := FUNCTION
		RETURN helper.GetFileNameForThisMinute();
	END;
*/	
	
	
	/*
	 * Get the name of the superfile which holds all the data
	 */		
	EXPORT STRING getSuperFileName() := FUNCTION
		
		RETURN helper.kAllSF;
	
	END;
	
	/*
	 * If a primary indexer had been specified. This returns the list of primary index files
	 */		
	 
	EXPORT SET OF STRING getPrimaryIndexFiles() := FUNCTION
		
		RETURN SET(helper.getPrimaryIndexFiles(),name);
	
	END;
	
	/*
	 * If a secondary indexer had been specified. This returns the list of secondary index files
	 */			
	EXPORT DATASET(STD.File.FsLogicalFileNameRecord) getSecondaryIndexFiles() := FUNCTION
		
		RETURN helper.getSecondaryIndexFiles();
	
	END;
	
	
	/*
     * If a primary indexer had been specified. This returns a super key(super file) file
     *	with all the primary index files. This can be used in roxie queries or used to create 
	 *  the packagae map xml.
     */
	EXPORT  getPrimarySuperKeyAct() := FUNCTION
	
		RETURN helper.UpdatePrimarySuperKeyAct();
	
	END;	
	
	/*
     * If a secondary indexer had been specified. This returns a super key(super file) file
     *	with all the secondary index files. This can be used in roxie queries or used to create 
	 *  a packagae map xml.
     */	
	EXPORT  getSecondarySuperKeyAct() := FUNCTION
	
		RETURN helper.UpdateSecondarySuperKeyAct();
	
	END;		
	
	 
	/*
	 * Call this to cleanup unused index files.
     */
     
	EXPORT Cleanup() := FUNCTION
	
		RETURN helper.Cleanup();
	
	END;
	
	/*
	 * Call this to delete all the data in the mutable file.
     * You will lose the data forever.
     */	
	EXPORT BOOLEAN delete() := FUNCTION
		
		RETURN WHEN(TRUE,helper.delete());
	
	END;	
	

END;