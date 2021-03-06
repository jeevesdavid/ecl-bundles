//class=memory
//class=sort

import perform.config, perform.format, perform.files;

ds := files.generateSimple();

s := sort(ds, id3 % 0x100000);  // limit to 1M unique keys

output(COUNT(NOFOLD(s)) = config.simpleRecordCount);
