//class=index
//class=keyedjoin

import perform.config;
import perform.format;
import perform.files;
import perform.util;

unsigned scale := IF(config.smokeTest, 0x10000, 0x100);
ds := files.generateSimpleScaled(0, scale);

j := JOIN(ds, files.manyIndex321,
            WILD(RIGHT.id3a) AND 
            KEYED(RIGHT.id3b = util.byte(LEFT.id3, 1)) AND 
            KEYED(RIGHT.id3c = util.byte(LEFT.id3, 2)) AND
            KEYED(RIGHT.id3d = util.byte(LEFT.id3, 3)), 
            TRANSFORM(LEFT), LIMIT(1, TRANSFORM(format.simpleRec, SELF := []))); 
cnt := COUNT(NOFOLD(j));

OUTPUT(cnt = config.simpleRecordCount DIV scale);
