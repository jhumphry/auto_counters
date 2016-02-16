-- Auto_Counters_Suite
-- Unit tests for Auto_Counters packages

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with Auto_Counters_Suite.Smart_Ptrs_Tests;
with Auto_Counters_Suite.Unique_Ptrs_Tests;

package body Auto_Counters_Suite is
   use AUnit.Test_Suites;

   Result : aliased Test_Suite;

   Test_Smart_Ptrs : aliased Smart_Ptrs_Tests.Smart_Ptrs_Test;
   Test_Unique_Ptrs : aliased Unique_Ptrs_Tests.Unique_Ptrs_Test;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   begin
      Add_Test (Result'Access, Test_Smart_Ptrs'Access);
      Add_Test (Result'Access, Test_Unique_Ptrs'Access);
      return Result'Access;
   end Suite;

end Auto_Counters_Suite;
