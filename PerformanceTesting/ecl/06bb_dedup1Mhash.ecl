//class=memory
//class=hashdedup

import perform.config, perform.format, perform.files;

ds := files.generateSimple();
unsigned8 numBins := 1000000;

t := DEDUP(ds, id3 % numBins, HASH);
numResults := COUNT(NOFOLD(t));

//It is hard to know what this number is likely to be:
//  If simpleRecordCount << numBins it is likely to be ~simpleRecordCount.
//  If simpleRecordCount >> numBins it is likely to be ~numBins.
output(numResults BETWEEN 1 AND numBins);
