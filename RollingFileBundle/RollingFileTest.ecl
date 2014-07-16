IMPORT STD;
						
						
personData := $.RollingFile	(
											'~mutableroot',
											'person',
											$.SampleCopier,
										);		
//Use this to delete the contents. There will be no going back. Data will be lost forever
del := personData.Delete();

/*
	Initialize the mutable file. This has to be called only once. It can be called again after the the delete
	method is used to delete the file
*/
create := personData.Create();

//Write the first batch of data
s1 := personData.write($.CommonTestUtils.source1Data);

//Write the second batch of data
s2 :=personData.write($.CommonTestUtils.source2Data);

//Write the third batch of data
s3 :=personData.write($.CommonTestUtils.source3Data);		

SEQUENTIAL(del,create,s1,s2,s3);

allPersonData  := DATASET(personData.getSuperFileName(),$.CommonTestUtils.PersonRec,THOR);

OUTPUT(allPersonData,NAMED('AllPersonData'));





