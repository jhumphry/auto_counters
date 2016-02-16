-- Auto_Counters_Suite.Unique_Ptrs_Tests
-- Unit tests for Auto_Counters Unique_Ptrs package

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with AUnit.Assertions;

with Unique_Ptrs;

package body Auto_Counters_Suite.Unique_Ptrs_Tests is

   use AUnit.Assertions;

   Resources_Released : Natural := 0;

   procedure Deletion_Recorder (X : in out String) is
      pragma Unreferenced (X);
   begin
      Resources_Released := Resources_Released + 1;
   end Deletion_Recorder;

   package String_Unique_Ptrs is new Unique_Ptrs(T => String,
                                                 Delete => Deletion_Recorder);
   use String_Unique_Ptrs;

   --------------------
   -- Register_Tests --
   --------------------

   procedure Register_Tests (T: in out Unique_Ptrs_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Check_Unique_Ptrs'Access,
                        "Check basic Unique_Ptr functionality");
   end Register_Tests;

   ----------
   -- Name --
   ----------

   function Name (T : Unique_Ptrs_Test) return Test_String is
      pragma Unreferenced (T);
   begin
      return Format ("Tests of Unique_Ptrs package functionality");
   end Name;

   ------------
   -- Set_Up --
   ------------

   procedure Set_Up (T : in out Unique_Ptrs_Test) is
   begin
      null;
   end Set_Up;

   -----------------------
   -- Check_Unique_Ptrs --
   -----------------------

   procedure Check_Unique_Ptrs (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      UP1 : Unique_Ptr := Make_Unique_Ptr(new String'("Hello, World!"));

      procedure Make_UP_from_Local is
         S : aliased String := "Test";
         UP2 : Unique_Ptr(Element => S'Access);
         pragma Unreferenced (UP2);
      begin
         null;
      end Make_UP_from_Local;

      Caught_Make_UP_from_Local : Boolean := False;

   begin
      Assert (UP1 = "Hello, World!",
             "Initialized Unique_Ptr not working");

      Resources_Released := 0;

      declare
         UP3 : Unique_Ptr := Make_Unique_Ptr(new String'("Goodbye, World!"));
         pragma Unreferenced (UP3);
      begin
         null;
      end;

      Assert (Resources_Released = 1,
              "Unique_Ptr did not delete contents when destroyed");

      begin
         Make_UP_from_Local;
      exception
         when Unique_Ptr_Error =>
            Caught_Make_UP_from_Local := True;
      end;

      Assert(Caught_Make_UP_from_Local,
             "Failed to identify Unique_Ptr being set to a local");

   end Check_Unique_Ptrs;

end Auto_Counters_Suite.Unique_Ptrs_Tests;
