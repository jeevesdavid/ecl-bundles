//class=index
//class=keyedjoin

import perform.config;
import perform.format;
import perform.files;
import perform.util;

unsigned scale := IF(config.smokeTest, 0x10000, 0x100);
ds := files.generateSimpleScaled(0, scale);

j := JOIN(ds, files.manyIndex123,
            RIGHT.id1a = util.byte(LEFT.id1, 0) AND 
            RIGHT.id1b = util.byte(LEFT.id1, 1) AND 
            RIGHT.id1c = util.byte(LEFT.id1, 2) AND 
            RIGHT.id1d = util.byte(LEFT.id1, 3) AND 
            RIGHT.id1e = util.byte(LEFT.id1, 4) AND 
            RIGHT.id1f = util.byte(LEFT.id1, 5) AND 
            RIGHT.id1g = util.byte(LEFT.id1, 6),
            TRANSFORM(LEFT), LIMIT(255, TRANSFORM(format.simpleRec, SELF := []))); 
cnt := COUNT(NOFOLD(j));

OUTPUT(cnt = 255*255 + (config.simpleRecordCount DIV scale) - 255);
