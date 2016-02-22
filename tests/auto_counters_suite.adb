-- Auto_Counters_Suite
-- Unit tests for Auto_Counters packages

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with Smart_Ptrs_Tests;
with Auto_Counters_Suite.Unique_Ptrs_Tests;

with Basic_Counters;
with Protected_Counters;

package body Auto_Counters_Suite is
   use AUnit.Test_Suites;

   package Basic_Smart_Ptrs_Tests is
     new Smart_Ptrs_Tests(Counters => Basic_Counters.Basic_Counters_Spec,
                          Counter_Type_Name => "basic counters");

   Test_Basic_Smart_Ptrs : aliased Basic_Smart_Ptrs_Tests.Smart_Ptrs_Test;

   package Protected_Smart_Ptrs_Tests is
     new Smart_Ptrs_Tests(Counters => Protected_Counters.Protected_Counters_Spec,
                          Counter_Type_Name => "protected counters");

   Test_Protected_Smart_Ptrs : aliased Protected_Smart_Ptrs_Tests.Smart_Ptrs_Test;

   Test_Unique_Ptrs : aliased Unique_Ptrs_Tests.Unique_Ptrs_Test;

   Result : aliased Test_Suite;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   begin
      Add_Test (Result'Access, Test_Basic_Smart_Ptrs'Access);
      Add_Test (Result'Access, Test_Protected_Smart_Ptrs'Access);
      Add_Test (Result'Access, Test_Unique_Ptrs'Access);
      return Result'Access;
   end Suite;

end Auto_Counters_Suite;
