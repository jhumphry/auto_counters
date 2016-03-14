-- auto_counters_tests_config.ads
-- Configuration for Unit tests for Auto_Counters

-- Configuration for optimized builds

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

package Auto_Counters_Tests_Config is
   pragma Pure;

   Assertions_Enabled : constant Boolean := False;
   -- Some unit tests are checking that appropriate preconditions and assertions
   -- are in place. In optimized builds where assertions are disabled these
   -- tests will cause incorrect failure notifications or segfaults. The
   -- Assertions_Enabled flag indicates whether these tests should be run.

end Auto_Counters_Tests_Config;
