-- Auto_Counters_Suite.BR_Flyweights_Tests
-- Unit tests for Auto_Counters Basic_Refcount_Flyweights package

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package Auto_Counters_Suite.BR_Flyweights_Tests is

   type BR_Flyweights_Test is new Test_Cases.Test_Case with null record;

   procedure Register_Tests (T: in out BR_Flyweights_Test);

   function Name (T : BR_Flyweights_Test) return Test_String;

   procedure Set_Up (T : in out BR_Flyweights_Test);

   procedure Check_Basic_Usage (T : in out Test_Cases.Test_Case'Class);

   procedure Check_Refs_Usage (T : in out Test_Cases.Test_Case'Class);

end Auto_Counters_Suite.BR_Flyweights_Tests;
