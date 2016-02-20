-- Auto_Counters_Suite
-- Unit tests for Auto_Counters packages

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with Smart_Ptrs_Tests;
with Auto_Counters_Suite.Unique_Ptrs_Tests;

with Basic_Counters;

package body Auto_Counters_Suite is
   use AUnit.Test_Suites;

   type String_Ptr is access String;

   package String_Basic_Counters is new Basic_Counters(T => String,
                                                       T_Ptr => String_Ptr);
   package Basic_Smart_Ptrs_Tests is
     new Smart_Ptrs_Tests(Counters => String_Basic_Counters.Basic_Counters_Spec,
                          Counter_Type_Name => "basic counters");

   Test_Smart_Ptrs : aliased Basic_Smart_Ptrs_Tests.Smart_Ptrs_Test;

   Test_Unique_Ptrs : aliased Unique_Ptrs_Tests.Unique_Ptrs_Test;

   Result : aliased Test_Suite;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   begin
      Add_Test (Result'Access, Test_Smart_Ptrs'Access);
      Add_Test (Result'Access, Test_Unique_Ptrs'Access);
      return Result'Access;
   end Suite;

end Auto_Counters_Suite;
