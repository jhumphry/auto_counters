-- Auto_Counters_Suite.Unique_Ptrs_Tests
-- Unit tests for Auto_Counters Unique_Ptrs package

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package Auto_Counters_Suite.Unique_Ptrs_Tests is

   type Unique_Ptrs_Test is new Test_Cases.Test_Case with null record;

   procedure Register_Tests (T: in out Unique_Ptrs_Test);

   function Name (T : Unique_Ptrs_Test) return Test_String;

   procedure Set_Up (T : in out Unique_Ptrs_Test);

   procedure Check_Unique_Ptrs (T : in out Test_Cases.Test_Case'Class);

   procedure Check_Unique_Const_Ptrs (T : in out Test_Cases.Test_Case'Class);

end Auto_Counters_Suite.Unique_Ptrs_Tests;
