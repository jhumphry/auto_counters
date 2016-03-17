-- Auto_Counters_Suite.Refcount_KVFlyweights_Tests
-- Unit tests for Auto_Counters Refcounted KVFlyweights packages

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package Auto_Counters_Suite.Refcount_KVFlyweights_Tests is

   type Refcount_KVFlyweights_Test is new Test_Cases.Test_Case with null record;

   procedure Register_Tests (T: in out Refcount_KVFlyweights_Test);

   function Name (T : Refcount_KVFlyweights_Test) return Test_String;

   procedure Set_Up (T : in out Refcount_KVFlyweights_Test);

   procedure Check_Basic_Usage (T : in out Test_Cases.Test_Case'Class);

   procedure Check_Basic_Refs_Usage (T : in out Test_Cases.Test_Case'Class);

   procedure Check_Protected_Usage (T : in out Test_Cases.Test_Case'Class);

   procedure Check_Protected_Refs_Usage (T : in out Test_Cases.Test_Case'Class);

end Auto_Counters_Suite.Refcount_KVFlyweights_Tests;
