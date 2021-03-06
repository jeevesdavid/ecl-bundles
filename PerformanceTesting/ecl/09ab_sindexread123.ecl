//class=index
//class=indexread

import perform.config;
import perform.format;
import perform.files;
import perform.util;

//Stepped index read
ds := SORTED(STEPPED(files.manyIndex123(
            id1a = 0 AND 
            id1b = 0 AND 
            id1c = 0 AND 
            id1d = 0 AND 
            id1e = 0 AND 
            id1f IN [1,3]), id2), id2, ASSERT);
             
cnt := COUNT(NOFOLD(ds));

OUTPUT(cnt = 256 * 256 * 2);
