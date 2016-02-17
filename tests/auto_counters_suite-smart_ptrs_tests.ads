-- Auto_Counters_Suite.Smart_Ptrs_Tests
-- Unit tests for Auto_Counters Smart_Ptrs package

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package Auto_Counters_Suite.Smart_Ptrs_Tests is

   type Smart_Ptrs_Test is new Test_Cases.Test_Case with null record;

   procedure Register_Tests (T: in out Smart_Ptrs_Test);

   function Name (T : Smart_Ptrs_Test) return Test_String;

   procedure Set_Up (T : in out Smart_Ptrs_Test);

   procedure Check_Smart_Ptr (T : in out Test_Cases.Test_Case'Class);

   procedure Check_Weak_Ptrs (T : in out Test_Cases.Test_Case'Class);

end Auto_Counters_Suite.Smart_Ptrs_Tests;
