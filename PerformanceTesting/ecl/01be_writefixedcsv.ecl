//class=disk
//class=diskwrite

import perform.config;
import perform.format;
import perform.files;

ds := DATASET(config.simpleRecordCount, format.createSimple(COUNTER), DISTRIBUTED);

OUTPUT(ds,,files.simpleName+'_uncompressed_csv',overwrite,csv);
