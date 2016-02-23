-- Auto_Counters_Suite.C_Resources_Tests
-- Unit tests for Auto_Counters Unique_C_Resources and Smart_C_Resources
-- packages

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with AUnit.Assertions;

with Unique_C_Resources;
with Smart_C_Resources;
with Basic_Counters;

package body Auto_Counters_Suite.C_Resources_Tests  is

   use AUnit.Assertions;

   Net_Resources_Allocated : Integer := 0;

   type Dummy_Resource is new Boolean;

   function Make_Resource return Dummy_Resource is
   begin
      Net_Resources_Allocated := Net_Resources_Allocated + 1;
      return True;
   end Make_Resource;

   procedure Release_Resource (X : in Dummy_Resource) is
      pragma Unreferenced (X);
   begin
      Net_Resources_Allocated := Net_Resources_Allocated - 1;
   end Release_Resource;

   package Unique_Dummy_Resources is new Unique_C_Resources(T => Dummy_Resource,
                                                           Initialize => Make_Resource,
                                                           Finalize   => Release_Resource);

   subtype Unique_Dummy_Resource is Unique_Dummy_Resources.Unique_T;
   use type Unique_Dummy_Resources.Unique_T;
   subtype Unique_Dummy_Resource_No_Default is Unique_Dummy_Resources.Unique_T_No_Default;
   use type Unique_Dummy_Resources.Unique_T_No_Default;

   package Smart_Dummy_Resources is new Smart_C_Resources(T => Dummy_Resource,
                                                          Initialize => Make_Resource,
                                                          Finalize   => Release_Resource,
                                                          Counters => Basic_Counters.Basic_Counters_Spec);

   subtype Smart_Dummy_Resource is Smart_Dummy_Resources.Smart_T;
   use type Smart_Dummy_Resources.Smart_T;
   subtype Smart_Dummy_Resource_No_Default is Smart_Dummy_Resources.Smart_T_No_Default;
   use type Smart_Dummy_Resources.Smart_T_No_Default;

   --------------------
   -- Register_Tests --
   --------------------

   procedure Register_Tests (T: in out C_Resource_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Check_Unique_C_Resource'Access,
                        "Check basic Unique_T C resource handling");
       Register_Routine (T, Check_Smart_C_Resource'Access,
                        "Check basic Smart_T C resource handling");
   end Register_Tests;

   ----------
   -- Name --
   ----------

   function Name (T : C_Resource_Test) return Test_String is
      pragma Unreferenced (T);
   begin
      return Format ("Tests of Unique_C_Resources and Smart_C_Resources");
   end Name;

   ------------
   -- Set_Up --
   ------------

   procedure Set_Up (T : in out C_Resource_Test) is
   begin
      null;
   end Set_Up;

   -----------------------------
   -- Check_Unique_C_Resource --
   -----------------------------

   procedure Check_Unique_C_Resource (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

   begin
      Net_Resources_Allocated := 0;

      declare
         UDR1 : Unique_Dummy_Resource;
      begin
         Assert (Net_Resources_Allocated = 1,
                 "Default initialization of a Unique_T did not call the " &
                   "initialization routine");
         Assert (UDR1.Element = True,
                   "Default initialization of a Unique_T did not set up " &
                   "the contents correctly");
      end;

      Assert (Net_Resources_Allocated = 0,
              "Destruction of a Unique_T did not call the finalization " &
                "routine");

      declare
         UDR2 : constant Unique_Dummy_Resource_No_Default
           := Unique_Dummy_Resources.Make_Unique_T(False);
      begin
         Assert (Net_Resources_Allocated = 0,
                 "Non-default initialization of a Unique_T_No_Default called " &
                   "the initialization routine");
         Assert (UDR2.Element = False,
                   "Default initialization of a Unique_T did not set up " &
                   "the contents correctly");
      end;
      Assert (Net_Resources_Allocated = -1,
              "Destruction of a Unique_T_No_Default did not call the " &
                "finalization routine");

   end Check_Unique_C_Resource;

   ----------------------------
   -- Check_Smart_C_Resource --
   ----------------------------

   procedure Check_Smart_C_Resource (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      SDR1 : Smart_Dummy_Resource;

   begin
      Assert (SDR1.Element = True,
              "Default initialization of a Smart_T did not set up " &
                "the contents correctly");

      Assert (SDR1.Unique,
              "Default initialization of a Smart_T did not set up " &
                "the reference counter properly");

      Net_Resources_Allocated := 0;

      declare
         SDR2 : Smart_Dummy_Resource;
      begin
         Assert (Net_Resources_Allocated = 1,
                 "Default initialization of a second independent Smart_T did " &
                   "not call the initialization routine");
         Assert (SDR2.Element = True,
                   "Default initialization of a second independent Smart_T " &
                   "did not set up the contents correctly");
         Assert (SDR2.Use_Count = 1,
                   "Default initialization of a second independent Smart_T " &
                   "did not set up the reference counter properly");
      end;
      Assert (Net_Resources_Allocated = 0,
              "Destruction of a second independent Smart_T did not call the " &
                "finalization routine");

      declare
         SDR3 : constant Smart_Dummy_Resource_No_Default
           := Smart_Dummy_Resources.Make_Smart_T(False);
      begin
         Assert (SDR3.Element = False,
                   "Explicit of a second independent Smart_T " &
                   "did not set up the contents correctly");
      end;

      Net_Resources_Allocated := 0;

      declare
         SDR4 : constant Smart_Dummy_Resource := SDR1;
      begin
         Assert (Net_Resources_Allocated = 0,
                 "Copying a Smart_T called the initialization again");
         Assert (SDR1 = SDR4,
                 "Copying a Smart_T did not copy the contents");
         Assert (SDR4.Use_Count = 2,
                 "Copying a Smart_T did not increment the Use_Count");
      end;

      Assert (SDR1.Use_Count = 1,
                 "Destroying a copied Smart_T did not decrement the Use_Count");

      Assert (Net_Resources_Allocated = 0,
              "Destruction of a copied Smart_T called the finalization " &
                "finalization routine although the original still exists");

   end Check_Smart_C_Resource;

end Auto_Counters_Suite.C_Resources_Tests ;
