//class=memory
//class=distribute

import perform.config, perform.format, perform.files;

ds := files.generateSimple();

d := distribute(ds, hash32(id3));

output(COUNT(NOFOLD(d)) = config.simpleRecordCount);
