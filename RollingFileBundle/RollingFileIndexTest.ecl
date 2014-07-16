

file := $.SampleRollingFiles.PersonFileIndexed;

//Use this to delete the contents. There will be no going back. Data will be lost forever

del := file.Delete();

/*
	Initialize the Rolling file. This has to be called only once. It can be called again after the the delete
	method is used to delete the file
*/
create := file.Create();

//Write the first batch of data
s1 := file.write($.CommonTestUtils.source1Data);

//Write the second batch of data
s2 :=file.write($.CommonTestUtils.source2Data);

//Write the third batch of data
s3 :=file.write($.CommonTestUtils.source3Data);		

allPersonData  := DATASET(file.getSuperFileName(),$.CommonTestUtils.PersonRec,THOR);

printData := OUTPUT(allPersonData,NAMED('AllPersonData'));

printIndexFiles := OUTPUT(file.getPrimaryIndexFiles(),NAMED('IndexFiles'));

SEQUENTIAL(del,create,s1,s2,s3,printData,printIndexFiles);









