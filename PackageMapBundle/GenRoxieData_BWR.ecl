IMPORT RollingFileBundle;

IMPORT Std;

file := RollingFileBundle.SampleRollingFiles.PersonFileIndexed;

//Use this to delete the contents. There will be no going back. Data will be lost forever

del := file.Delete();

/*
	Initialize the mutable file. This has to be called only once. It can be called again after the the delete
	method is used to delete the file
*/
create := file.Create();

//Write the first batch of data
s1 := file.write(RollingFileBundle.CommonTestUtils.source1Data);

//Write the second batch of data
s2 :=file.write(RollingFileBundle.CommonTestUtils.source2Data);

//Write the third batch of data
s3 :=file.write(RollingFileBundle.CommonTestUtils.source3Data);		

//Write the fourth batch of data
s4 :=file.write(RollingFileBundle.CommonTestUtils.source3Data);		

allPersonData  := DATASET(file.getSuperFileName(),RollingFileBundle.CommonTestUtils.PersonRec,THOR);

dummyLF := OUTPUT(RollingFileBundle.CommonTestUtils.source1Data,,$.CommonUtils.DummyPersonFile,THOR,OVERWRITE);

indexLF := RollingFileBundle.SampleIndexer.IndexFile($.CommonUtils.DummyPersonFile,$.CommonUtils.DummyPersonIndex);
 

createSF := NOTHOR(Std.File.CreateSuperFile($.CommonUtils.AllPersonsSK,allow_exist:=TRUE));

clearSF := NOTHOR(Std.File.ClearSuperFile($.CommonUtils.AllPersonsSK));

addSF := NOTHOR(Std.File.AddSuperFile($.CommonUtils.AllPersonsSK,$.CommonUtils.DummyPersonIndex));

CreateDummySFAct := SEQUENTIAL(createSF,clearSF,dummyLF,indexLF,addSF );

SEQUENTIAL(del,create,s1,s2,s3,
CreateDummySFAct);

SEQUENTIAL(s4);

//CreateDummySFAct;
