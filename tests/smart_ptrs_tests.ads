-- Smart_Ptrs_Tests
-- Unit tests for Auto_Counters Smart_Ptrs package

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

private with Ada.Strings.Unbounded;

with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

with Counters_Spec;

generic
   with package Counters is new Counters_Spec(others => <>);
   Counter_Type_Name : String;
package Smart_Ptrs_Tests is

   type Smart_Ptrs_Test is new Test_Cases.Test_Case with null record;

   procedure Register_Tests (T: in out Smart_Ptrs_Test);

   function Name (T : Smart_Ptrs_Test) return Test_String;

   procedure Set_Up (T : in out Smart_Ptrs_Test);

   procedure Check_Smart_Ptr (T : in out Test_Cases.Test_Case'Class);

   procedure Check_Weak_Ptrs (T : in out Test_Cases.Test_Case'Class);

   procedure Check_WP_SR (T : in out Test_Cases.Test_Case'Class);

   procedure Check_Smart_Ref (T : in out Test_Cases.Test_Case'Class);

   procedure Check_SP_SR (T : in out Test_Cases.Test_Case'Class);

private

   -- RM 3.10.2(32) means we cannot hide this away inside the body of the
   -- generic unit - the use of unbounded strings and the Test_Details type
   -- is just to make things less irritating.

   use Ada.Strings.Unbounded;

   function "+"(Source : in String) return Unbounded_String
                renames To_Unbounded_String;

   type Test_Details is
      record
         T : Test_Routine;
         D : Unbounded_String;
      end record;

   Test_Details_List: array (Positive range <>) of Test_Details :=
     ( (Check_Smart_Ptr'Access, +"Check basic Smart_Ptr functionality"),
       (Check_Weak_Ptrs'Access, +"Check basic Weak_Ptr & Smart_Ptr functionality"),
       (Check_WP_SR'Access, +"Check basic Weak_Ptr & Smart_Ref functionality"),
       (Check_Smart_Ref'Access, +"Check basic Smart_Ref functionality"),
       (Check_SP_SR'Access, +"Check basic Smart_Ptr & Smart_Ref functionality")
      );

end Smart_Ptrs_Tests;
