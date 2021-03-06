//class=index
//class=indexwrite

import perform.config;
import perform.format;
import perform.files;

ds := DATASET(config.simpleRecordCount * config.indexScale, format.createSimple(COUNTER), DISTRIBUTED);

i:= INDEX(ds,{ 
    unsigned1 id3a := id3 >> 56;
    unsigned1 id3b := id3 >> 48;
    unsigned1 id3c := id3 >> 40;
    unsigned1 id3d := id3 >> 32;
    unsigned1 id3e := id3 >> 24;
    unsigned1 id3f := id3 >> 16;
    unsigned1 id3g := id3 >> 8;
    unsigned1 id3h := id3 >> 0;
    id2, id1 }, { id4 }, files.indexName+'_id3xid2id1id4');
    
BUILDINDEX(i, OVERWRITE);
