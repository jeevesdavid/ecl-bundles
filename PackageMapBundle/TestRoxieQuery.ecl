IMPORT RollingFileBundle;

allPersonData  := INDEX(RollingFileBundle.CommonTestUtils.PersonIndexRec,RollingFileBundle.CommonTestUtils.PersonPayloadRec,$.CommonUtils.AllPersonsSK);

OUTPUT(allPersonData);