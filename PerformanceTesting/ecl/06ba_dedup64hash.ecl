//class=memory
//class=hashdedup

import perform.config, perform.format, perform.files;

ds := files.generateSimple();
unsigned8 numBins := 64;

t := DEDUP(ds, id3 % numBins, HASH);  //GH FEW should mean the same as HASH

output(COUNT(NOFOLD(t)) = numBins);
