-- Auto_Counters_Suite.Smart_Ptrs_Tests
-- Unit tests for Auto_Counters Smart_Ptrs package

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with AUnit.Assertions;

with Smart_Ptrs;

package body Auto_Counters_Suite.Smart_Ptrs_Tests is

   use AUnit.Assertions;

   Resources_Released : Natural := 0;

   procedure Deletion_Recorder (X : in out String) is
      pragma Unreferenced (X);
   begin
      Resources_Released := Resources_Released + 1;
   end Deletion_Recorder;

   package String_Smart_Ptrs is new Smart_Ptrs(T => String,
                                               Delete => Deletion_Recorder);
   use String_Smart_Ptrs;

   --------------------
   -- Register_Tests --
   --------------------

   procedure Register_Tests (T: in out Smart_Ptrs_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Check_Reference_Counting'Access,
                        "Check basic reference-counting functionality");
   end Register_Tests;

   ----------
   -- Name --
   ----------

   function Name (T : Smart_Ptrs_Test) return Test_String is
      pragma Unreferenced (T);
   begin
      return Format ("Tests of Smart_Ptrs package functionality");
   end Name;

   ------------
   -- Set_Up --
   ------------

   procedure Set_Up (T : in out Smart_Ptrs_Test) is
   begin
      null;
   end Set_Up;

   ------------------------------
   -- Check_Reference_Counting --
   ------------------------------

   procedure Check_Reference_Counting (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      SP1 : Smart_Ptr := Make_Smart_Ptr(new String'("Hello, World!"));
      SP2 : Smart_Ptr;

   begin
      Assert((not SP1.Is_Null and
               SP1.Use_Count = 1 and
                 SP1.Unique and
                   SP1.Weak_Ptr_Count = 0),
             "Initialized non-null Smart_Ptr has incorrect properties");

      Assert((SP2.Is_Null and
               SP2.Use_Count = 1 and
                 SP2.Unique and
                   SP2.Weak_Ptr_Count = 0),
             "Initialized null Smart_Ptr has incorrect properties");

      SP2 := SP1;

      Assert(SP1 = SP2, "Assignment of Smart_Ptrs does not make them equal");

      Assert(SP1.Use_Count = 2 and
               not SP1.Unique and
                 SP1.Weak_Ptr_Count = 0,
                   "Assignment of Smart_Ptrs does not make them equal");

      Resources_Released := 0;
      SP2 := Null_Smart_Ptr;

      Assert((SP2.Is_Null and
               SP2.Use_Count = 1 and
                 SP2.Unique and
                   SP2.Weak_Ptr_Count = 0),
             "Assigning null to a Smart_Ptr does not give correct properties");

      Assert(Resources_Released = 0, "Resources released incorrectly");

      SP1 := Null_Smart_Ptr;

      Assert((SP1.Is_Null and
               SP1.Use_Count = 1 and
                 SP1.Unique and
                   SP1.Weak_Ptr_Count = 0),
             "Assigning null to a Smart_Ptr does not give correct properties");

      Assert(Resources_Released = 1,
             "Resources were not released when last Smart_Ptr destroyed");

   end Check_Reference_Counting;

end Auto_Counters_Suite.Smart_Ptrs_Tests;
