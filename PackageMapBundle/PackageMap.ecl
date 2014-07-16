EXPORT PackageMap	(
						STRING packageName,
						String daliHost ,
						STRING roxieHost,
						STRING roxiePort ='8010',
						STRING roxieCluster ='roxie'
						
					) := MODULE


	SHARED STRING WsPackageProcessURL := 'http://'+ roxieHost + ':'+roxiePort+'/WsPackageProcess';
	
	EXPORT SuperFileRec := RECORD
		STRING superFileName;
		SET OF STRING subFileNames;
	END;
	
	EXPORT PackageRec := RECORD
		
		STRING queryName;
		STRING packageName;
		DATASET(SuperFileRec) superFiles;		
	
	END;
	
	SHARED TempRec := RECORD
			STRING sValue;
	END;
	
   	SHARED AddPackageRequestRec := RECORD
	
		STRING      packageMapData          {XPATH('Info')};
		BOOLEAN     overwritePackage        {XPATH('OverWrite')};
		BOOLEAN     activatePackage         {XPATH('Activate')};
		STRING      targetCluster           {XPATH('Target')};
		STRING      packageMapID            {XPATH('PackageMap')};
		STRING      Process                 {XPATH('Process')};
		STRING      DaliIp                  {XPATH('DaliIp')};
	END;	
	
	SHARED AddPackagResponseRec := RECORD
		STRING      code                    {XPATH('Code')};
		STRING      description             {XPATH('Description')};
	END;	


/*
	<SuperFile id="~thor::MyData_Key">
	<SubFile value="~thor::Mysubfile1"/>
	<SubFile value="~thor::Mysubfile2"/>
	</SuperFile>
*/
	EXPORT GetSuperFileXML(String superFileName, SET OF STRING subFileNames) := FUNCTION
	

		subFileData :=  DATASET(subFileNames,TempRec);
		STRING beginTag := '<SuperFile id="'+superFileName+'">';
		STRING endTag := '</SuperFile>';
		
		withXmls := PROJECT	(
						subFileData,
						TRANSFORM	(
										TempRec,
										SELF.sValue := '<SubFile value="'+LEFT.sValue+'"/>'
									)
					);
					
					
		rolledUp := ROLLUP(withXmls,TRUE,TRANSFORM(TempRec,SELF.sValue := LEFT.sValue+RIGHT.sValue));

					
		RETURN beginTag+rolledUp[1].sValue+endTag;
	END;
	
/*	
	<Package id="MyQuery">
	<Base id="thor::MyData_Key"/>
	</Package>	
	<Package id="thor::MyData_Key">
	[SuperFile XML]+
	</Package>
*/
	EXPORT  GetPackageXML(String queryName, String packageName, DATASET(SuperFileRec) superFiles) := FUNCTION
	
		
		superFileXmls := PROJECT	(
										superFiles,
										TRANSFORM	(
														TempRec,
														SELF.sValue := GetSuperFileXML(LEFT.superFileName,LEFT.subFileNames)
														)
									 );
														 
		DATASET(TempRec) rolledUpXmls := ROLLUP(superFileXmls,TRUE,TRANSFORM(TempRec,SELF.sValue := LEFT.sValue+RIGHT.sValue));													 
														 
		
		xmlVal :=  '<Package id="'+queryName+'"> ' +
					'<Base id="'+packageName+'"/>'+
					'</Package>'+
					'<Package id="'+packageName+'">'+
					rolledUpXmls[1].sValue+
					'</Package>';
					
		RETURN xmlVal;
	
	
	END;
	
	
	
	/*
		<RoxiePackages>
			[Package XML]+
		<RoxiePackages>
	*/
	EXPORT GetRoxiePackageXML(DATASET(PackageRec) packages) := FUNCTION
	
		packageXmls := PROJECT	(
									packages,
									TRANSFORM	(
													TempRec,
													SELF.sValue := GetPackageXML	(
																						LEFT.queryName,
																						LEFT.packageName,
																						LEFT.superFiles
																					)
													)
								 );	
								 
		DATASET(TempRec) rolledUpXmls := ROLLUP(packageXmls,TRUE,TRANSFORM(TempRec,SELF.sValue := LEFT.sValue+RIGHT.sValue));													 
	
	
		RETURN '<RoxiePackages>'+rolledUpXmls[1].sValue+'</RoxiePackages>';
	
	
	END;
	
	
	EXPORT DeployPackageAct(DATASET(PackageRec) packages) := FUNCTION
	
		request := DATASET
			(
					[
							{
									GetRoxiePackageXML(packages),
									TRUE,
									TRUE,
									roxieCluster,
									packageName,
									'*',
									daliHost
							}
					],
					AddPackageRequestRec
			);
			
		DeployPackage := SOAPCALL	(
										request,
										WsPackageProcessURL,
										'AddPackage',
										AddPackageRequestRec,
										TRANSFORM(LEFT),
										DATASET(AddPackagResponseRec),
										XPATH('AddPackageResponse/status')
									);			
			
		
		
		RETURN DeployPackage;
	
	END;

END;