//class=index
//class=keyedjoin

import perform.config;
import perform.format;
import perform.files;
import perform.util;

unsigned scale := IF(config.smokeTest, 0x10000, 0x100);
ds := files.generateSimpleScaled(0, scale);

j := JOIN(ds, files.manyIndex321,
            RIGHT.id3a = util.byte(LEFT.id3, 0) AND 
            RIGHT.id3b = util.byte(LEFT.id3, 1) AND 
            RIGHT.id3c = util.byte(LEFT.id3, 2) AND 
            RIGHT.id3d = util.byte(LEFT.id3, 3) AND 
            RIGHT.id3e = util.byte(LEFT.id3, 4) AND 
            RIGHT.id3f = util.byte(LEFT.id3, 5) AND 
            RIGHT.id3g = util.byte(LEFT.id3, 6), LIMIT(256)); 
cnt := COUNT(NOFOLD(j));

OUTPUT(cnt = config.simpleRecordCount DIV scale);
