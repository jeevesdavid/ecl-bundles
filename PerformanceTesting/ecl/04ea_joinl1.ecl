//class=memory
//class=join

import perform.tests;

j := tests.join(1);
output(COUNT(NOFOLD(j.joinLocalNormal)) = j.numExpected);
