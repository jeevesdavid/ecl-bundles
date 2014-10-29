/* 
Run this once after executing GenRoxieData_BWR.ecl to see the query output before package map is used to
update the superkey used by this query.

Next run this after executing DeployRoxieData_BWR.ecl to see new data being added using package maps.

*/

IMPORT RollingFileBundle;

allPersonData  := INDEX(RollingFileBundle.CommonTestUtils.PersonIndexRec,RollingFileBundle.CommonTestUtils.PersonPayloadRec,$.CommonUtils.AllPersonsSK);

OUTPUT(allPersonData);
