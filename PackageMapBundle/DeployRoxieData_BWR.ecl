/*

Run this to push all the data in file - RollingFileBundle.SampleRollingFiles.PersonFileIndexed 
to the super key - $.CommonUtils.AllPersonsSK, used by roxie query 'testroxiequery;

*/
IMPORT RollingFileBundle;

file := RollingFileBundle.SampleRollingFiles.PersonFileIndexed;


pkgMp  := $.PackageMap('HelloPackage','10.242.48.240','10.242.48.240','8010','roxie');

					

superFiles := DATASET	(
							[
								{ $.CommonUtils.AllPersonsSK,file.getPrimaryIndexFiles()}
							],
							pkgMp.SuperfileRec
						);
						
packageMap := DATASET	(
							[
								{'testroxiequery','package1',superFiles}
							],
							pkgMp.PackageRec
						);

//pkgMp.GetRoxiePackageXML(packageMap);
						
OUTPUT(pkgMp.DeployPackageAct(packageMap));						
