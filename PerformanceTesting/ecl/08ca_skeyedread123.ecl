//class=child
//class=index
//class=indexread

import perform.config;
import perform.format;
import perform.files;
import perform.util;

unsigned scale := IF(config.smokeTest, 0x10000, 0x100);
ds := files.generateSimpleScaled(0, scale);

resultRec := RECORD
    RECORDOF(ds);
    dataset(RECORDOF(files.manyIndex123)) matches;
END;

resultRec t(ds l) := TRANSFORM
    //Stepped read-only one matching record
    SELF.matches := SORTED(STEPPED(files.manyIndex123(
            id1a = util.byte(l.id1, 0) AND 
            id1b = util.byte(l.id1, 1) AND 
            id1c = util.byte(l.id1, 2) AND 
            id1d = util.byte(l.id1, 3) AND 
            id1e = util.byte(l.id1, 4) AND 
            id1f = util.byte(l.id1, 5) AND 
            id1g = util.byte(l.id1, 6) AND 
            id1h = util.byte(l.id1, 7)), id2), id2, ASSERT);
    SELF := l;
END;

p := PROJECT(ds, t(LEFT));
             
cnt := COUNT(NOFOLD(p)(COUNT(matches)=1));

OUTPUT(cnt = config.simpleRecordCount DIV scale);
