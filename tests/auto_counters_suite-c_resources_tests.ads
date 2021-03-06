-- Auto_Counters_Suite.C_Resources_Tests
-- Unit tests for Auto_Counters Unique_C_Resources and Smart_C_Resources
-- packages

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package Auto_Counters_Suite.C_Resources_Tests  is

   type C_Resource_Test is new Test_Cases.Test_Case with null record;

   procedure Register_Tests (T: in out C_Resource_Test);

   function Name (T : C_Resource_Test) return Test_String;

   procedure Set_Up (T : in out C_Resource_Test);

   procedure Check_Unique_C_Resource (T : in out Test_Cases.Test_Case'Class);

   procedure Check_Smart_C_Resource (T : in out Test_Cases.Test_Case'Class);

end Auto_Counters_Suite.C_Resources_Tests ;
