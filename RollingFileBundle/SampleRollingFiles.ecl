EXPORT SampleRollingFiles := MODULE


	EXPORT PersonFileIndexed := $.RollingFile('~RFroot','person',$.SampleCopier,$.SampleIndexer);	

END;