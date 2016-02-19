-- Auto_Counters_Suite.Smart_Ptrs_Tests
-- Unit tests for Auto_Counters Smart_Ptrs package

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with AUnit.Assertions;

with Basic_Counters;
with Smart_Ptrs;

package body Auto_Counters_Suite.Smart_Ptrs_Tests is

   use AUnit.Assertions;

   Resources_Released : Natural := 0;

   procedure Deletion_Recorder (X : in out String) is
      pragma Unreferenced (X);
   begin
      Resources_Released := Resources_Released + 1;
   end Deletion_Recorder;

   type String_Ptr is access String;

   package String_Counters is new Basic_Counters(T => String,
                                                 T_Ptr => String_Ptr);

   package String_Ptrs is new Smart_Ptrs(T => String,
                                         T_Ptr => String_Ptr,
                                         Delete => Deletion_Recorder,
                                         Counters => String_Counters.Basic_Counters_Spec);
   use String_Ptrs;

   --------------------
   -- Register_Tests --
   --------------------

   procedure Register_Tests (T: in out Smart_Ptrs_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Check_Smart_Ptr'Access,
                        "Check basic Smart_Ptr functionality");
      Register_Routine (T, Check_Weak_Ptrs'Access,
                        "Check basic Weak_Ptr & Smart_Ptr functionality");
      Register_Routine (T, Check_WP_SR'Access,
                        "Check basic Weak_Ptr & Smart_Ref functionality");
      Register_Routine (T, Check_Smart_Ref'Access,
                        "Check basic Smart_Ref functionality");
      Register_Routine (T, Check_SP_SR'Access,
                        "Check basic Smart_Ptr & Smart_Ref functionality");

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

   ---------------------
   -- Check_Smart_Ptr --
   ---------------------

   procedure Check_Smart_Ptr (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      SP1 : Smart_Ptr := Make_Smart_Ptr(new String'("Hello, World!"));
      SP2 : Smart_Ptr;

   begin

      Assert(Null_Smart_Ptr.Is_Null,
             "Null_Smart_Ptr.Is_Null is not true");

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
                   "Assignment does not increase reference counts properly");

      SP1.P := "World, Hello!";

      Assert(SP2.P = "World, Hello!",
             "Changing a value via a reference from one Smart_Ptr does not " &
               "change the value accessed via an equal Smart_Ptr");

      SP2.Get(6) := ':';

      Assert(SP1.Get.all = "World: Hello!",
             "Changing a value via an access value from one Smart_Ptr does " &
               "not change the value accessed via an equal Smart_Ptr");

      Resources_Released := 0;
      declare
         SP3 : constant Smart_Ptr := SP1;
      begin
         Assert(SP1 = SP3, "Creation of a Smart_Ptr in an inner block failed");
         Assert(SP3.Use_Count = 3,
                "Creation of a Smart_Ptr in a block fails to set counts");
      end;
      Assert(SP1.Use_Count = 2,
             "Destruction of inner block Smart_Ptr does not reduce Use_Count");
      Assert(Resources_Released = 0,
             "Resources released incorrectly when 2 Smart_Ptr remain");

      Resources_Released := 0;
      SP2 := Null_Smart_Ptr;

      Assert((SP2.Is_Null and
               SP2.Use_Count = 1 and
                 SP2.Unique and
                   SP2.Weak_Ptr_Count = 0),
             "Assigning null to a Smart_Ptr does not give correct properties");

      Assert(Resources_Released = 0,
             "Resources released incorrectly when 1 Smart_Ptr remains");

      SP1 := Null_Smart_Ptr;

      Assert((SP1.Is_Null and
               SP1.Use_Count = 1 and
                 SP1.Unique and
                   SP1.Weak_Ptr_Count = 0),
             "Assigning null to a Smart_Ptr does not give correct properties");

      Assert(Resources_Released = 1,
             "Resources were not released when last Smart_Ptr destroyed");

      Assert(SP1 = SP2, "Null Smart_Ptrs are not equal");

   end Check_Smart_Ptr;

   ---------------------
   -- Check_Weak_Ptrs --
   ---------------------

   procedure Check_Weak_Ptrs (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      SP1 : Smart_Ptr := Make_Smart_Ptr(new String'("Hello, World!"));
      SP2 : Smart_Ptr;
      WP1 : constant Weak_Ptr := Make_Weak_Ptr(SP1);

      procedure Make_WP_From_Null_SP is
         WP2 : constant Weak_Ptr := Make_Weak_Ptr(SP2);
         pragma Unreferenced (WP2);
      begin
         null;
      end Make_WP_From_Null_SP;

      Caught_Making_WP_From_Null_SP : Boolean := False;
      Caught_Lock_On_Expired_WP : Boolean := False;

   begin
      Assert(SP1.Weak_Ptr_Count = 1,
             "Initialized Weak_Ptr not reflected in Smart_Ptr");
      Assert(WP1.Use_Count = 1,
             "Weak_Ptr not reflecting the correct Use_Count");
      Assert(not WP1.Expired,
             "Weak_Ptr is (incorrectly) already expired just after creation");

      begin
         Make_WP_From_Null_SP;
      exception
         when Smart_Ptr_Error =>
            Caught_Making_WP_From_Null_SP := True;
      end;

      Assert(Caught_Making_WP_From_Null_SP,
             "Make_Weak_ptr failed to raise exception when called on a null" &
               "Smart_Ptr");

      SP2 := WP1.Lock;
      Assert(SP1 = SP2,
             "Smart_Ptr recovered from Weak_Ptr /= original Smart_Ptr");
      Assert(WP1.Use_Count = 2,
             "Weak_Ptr has incorrect Use_Count after making new Smart_Ptr");
      Assert(SP1.Use_Count = 2,
             "Smart_Ptr made from Weak_Ptr has incorrect Use_Count");

      SP2 := WP1.Get;
      Assert(SP1 = SP2,
             "Smart_Ptr recovered from Weak_Ptr.Get /= original Smart_Ptr");
      Assert(WP1.Use_Count = 2,
             "Weak_Ptr has incorrect Use_Count after new Smart_Ptr via Get");
      Assert(SP1.Use_Count = 2,
             "Smart_Ptr made from Weak_Ptr.Get has incorrect Use_Count");

      Resources_Released := 0;
      SP2 := Null_Smart_Ptr;

      Assert(SP1.Weak_Ptr_Count = 1,
             "Weak_Ptr_Count incorrect after discarding Smart_Ptr");
      Assert(WP1.Use_Count = 1,
             "Weak_Ptr not reflecting the correct Use_Count");
      Assert(not WP1.Expired,
             "Weak_Ptr is already expired after only 1/2 Smart_Ptrs deleted");

      Assert(Resources_Released = 0,
             "Resources released incorrectly when 1 Smart_Ptr remains");

      SP1 := Null_Smart_Ptr;
      Assert(SP1.Weak_Ptr_Count = 0,
             "Smart_Ptr does not have correct Weak_Ptr_Count after nulling");
      Assert(Resources_Released = 1,
             "Resources released incorrectly when only a Weak_Ptr remains");
      Assert(WP1.Expired,
             "Weak_Ptr should be expired as all Smart_Ptrs deleted");
      Assert(WP1.Weak_Ptr_Count = 1,
             "Weak_Ptr_Count incorrect after discarding all Smart_Ptr");
      Assert(WP1.Use_Count = 0,
             "Weak_Ptr not reflecting the correct Use_Count of 0");

      begin
         SP1 := WP1.Lock;
      exception
         when Smart_Ptr_Error =>
            Caught_Lock_On_Expired_WP := True;
      end;

      Assert(Caught_Lock_On_Expired_WP,
             "Weak_Ptr.Lock failed to raise exception when Lock was called " &
               "on an expired Weak_Ptr");

      SP1 := WP1.Get;

      Assert(SP1 = Null_Smart_Ptr,
             "Weak_Ptr.Get failed to return a null Smart_Ptr when Get was " &
               "called on an expired Weak_Ptr");

   end Check_Weak_Ptrs;

   -----------------
   -- Check_WP_SR --
   -----------------

   procedure Check_WP_SR (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      SR1 : constant Smart_Ref := Make_Smart_Ref(new String'("Hello, World!"));
      WP1 : Weak_Ptr := Make_Weak_Ptr(SR1);
      SP1 : Smart_Ptr;

      Caught_Lock_On_Expired_WP : Boolean := False;

   begin
      Assert(SR1.Weak_Ptr_Count = 1,
             "Initialized Weak_Ptr not reflected in Smart_Ref");
      Assert(WP1.Use_Count = 1,
             "Weak_Ptr not reflecting the correct Use_Count");
      Assert(not WP1.Expired,
             "Weak_Ptr is (incorrectly) already expired just after creation");

      SP1 := WP1.Lock;
      Assert(SR1 = SP1.P,
             "Smart_Ptr recovered from Weak_Ptr /= original Smart_Ref");
      Assert(WP1.Use_Count = 2,
             "Weak_Ptr has incorrect Use_Count after making new Smart_Ptr");
      Assert(SP1.Use_Count = 2,
             "Smart_Ptr made from Weak_Ptr has incorrect Use_Count");

      Resources_Released := 0;

      declare
         SR2 : constant Smart_Ref := WP1.Lock;
      begin
         Assert(SR2 = String'(SR1),
                "Smart_Ref recovered from Weak_Ptr /= original Smart_Ref");
         Assert(SR2.Use_Count = 3,
                "Smart_Ref recovered from Weak_Ptr not adjusting Use_Count");
      end;

      Assert(Resources_Released = 0,
             "Recovering and destroying Smart_Ref from Weak_Ptr has released " &
               "resources despite remaining Smart_Ref and Smart_Ptr");

      Assert(SR1.Use_Count = 2,
             "Recovering and destroying Smart_Ref from Weak_Ptr has resulted " &
               "in incorrect Use_Count on remaining Smart_Ref ");

      Resources_Released := 0;

      declare
         SR3 : constant Smart_Ref
           := Make_Smart_Ref(new String'("Goodbye, World!"));
      begin
         WP1 := SR3.Make_Weak_Ptr;
      end;

      Assert(Resources_Released = 1,
             "Creation of Weak_Ptr from Smart_Ref prevented resources from " &
               "being released.");

      Assert(WP1.Expired,
             "Weak_Ptr not expired when source Smart_Ref is destroyed");

      Assert(WP1.Use_Count = 0,
             "Expired Weak_Ptr has incorrect Use_Count");

      begin
         declare
            SR4 : constant Smart_Ref := WP1.Lock;
            pragma Unreferenced (SR4);
         begin
            null;
         end;
      exception
         when Smart_Ptr_Error =>
            Caught_Lock_On_Expired_WP := True;
      end;

      Assert(Caught_Lock_On_Expired_WP,
             "Weak_Ptr.Lock failed to raise exception when Lock was called " &
               "on an expired Weak_Ptr");

   end Check_WP_SR;

   ---------------------
   -- Check_Smart_Ref --
   ---------------------

   procedure Check_Smart_Ref (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      SR1 : constant Smart_Ref := Make_Smart_Ref(new String'("Hello, World!"));

      procedure Make_SR_from_Local is
         S : aliased String := "Test";
         SR : Smart_Ref(Element => S'Access);
         pragma Unreferenced (SR);
      begin
         null;
      end Make_SR_from_Local;

      procedure Make_SR_from_null is
         SR : Smart_Ref := Make_Smart_Ref(null);
         pragma Unreferenced (SR);
      begin
         null;
      end Make_SR_from_null;

      Caught_Make_SR_from_Local : Boolean := False;
      Caught_Make_SR_from_Null : Boolean := False;

   begin

      Assert((SR1.Use_Count = 1 and
                 SR1.Unique and
                   SR1.Weak_Ptr_Count = 0),
             "Initialized Smart_Ref has incorrect properties");

      Resources_Released := 0;

      declare
         SR2 : constant Smart_Ref := SR1;
      begin

         Assert(SR1.Element = SR2.Element,
                "Assignment of Smart_Ref does not make them equal");

         Assert(SR1.Use_Count = 2 and
                  not SR1.Unique and
                    SR1.Weak_Ptr_Count = 0,
                "Assignment does not increase reference counts properly");

         SR1 := "World, Hello!";

         Assert(SR2 = "World, Hello!",
                "Changing a value via a reference from one Smart_Ref does " &
                  "not change the value accessed via an equal Smart_Ref");

         SR2.Get(6) := ':';

         Assert(SR1.Get.all = "World: Hello!",
                "Changing a value via an access value from one Smart_Ref " &
                  "does not change the value accessed via an equal Smart_Ref");

      end;

      Assert(SR1.Use_Count = 1,
             "Destruction of inner block Smart_Ref does not reduce Use_Count");
      Assert(Resources_Released = 0,
             "Resources released incorrectly when 1 Smart_Ref remains");

      Resources_Released := 0;

      declare
         SR3 : constant Smart_Ref := Make_Smart_Ref(new String'("Goodbye, World!"));
      begin
         Assert(SR3 = "Goodbye, World!", "Create of Smart_Ref not working");
      end;

      Assert(Resources_Released = 1,
             "Resources not released when no Smart_Ref remain");

      begin
         Make_SR_from_Local;
      exception
         when Smart_Ptr_Error =>
            Caught_Make_SR_from_Local := True;
      end;

      Assert(Caught_Make_SR_from_Local,
             "Failed to identify Smart_Ref being set to a local");

      begin
         Make_SR_from_null;
      exception
         when Smart_Ptr_Error =>
            Caught_Make_SR_from_Null := True;
      end;

      Assert(Caught_Make_SR_from_Null,
             "Failed to identify Smart_Ref being made from a null");

   end Check_Smart_Ref;

   -----------------
   -- Check_SP_SR --
   -----------------

   procedure Check_SP_SR (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      SR1 : constant Smart_Ref := Make_Smart_Ref(new String'("Smart_Ref"));
      SP1 : constant Smart_Ptr := Make_Smart_Ptr(SR1);

      SP2 : constant Smart_Ptr := Make_Smart_Ptr(new String'("Smart_Ptr"));

      procedure Make_SR_from_null_SP is
         SP : Smart_Ptr;
         SR : Smart_Ref := Make_Smart_Ref(SP);
         pragma Unreferenced (SR);
      begin
         null;
      end Make_SR_from_null_SP;

      Caught_Make_SR_from_Null_SP : Boolean := False;

   begin

      Assert(SR1 = SP1.P,
             "Smart_Ptr and Smart_Ref do not have same contents after " &
               "assignment");

      Assert(SR1 = SP1.Get.all,
             "Smart_Ptr and Smart_Ref do not have same contents after " &
               "assignment (using Smart_Ptr.Get.all)");

      Assert(SR1.Use_Count = 2 and SP1.Use_Count = 2,
             "Smart_Ptr and Smart_Ref do not have correct Use_Count");

      Resources_Released := 0;

      declare
         SR2 : constant Smart_Ref := Make_Smart_Ref(SP2);
      begin
         Assert(SR2.Use_Count = 2 and SP2.Use_Count = 2,
             "Smart_Ptr and Smart_Ref do not have correct Use_Count");
      end;

      Assert(Resources_Released = 0,
             "Destruction of Smart_Ref released storage despite remaining "&
               "Smart_Ptr");

      Assert(SP2.Use_Count = 1,
             "Smart_Ptr does not have correct Use_Count after creation and" &
            "destruction of a Smart_Ref linked to it");

      begin
         Make_SR_from_null_SP;
      exception
         when Smart_Ptr_Error =>
            Caught_Make_SR_from_Null_SP := True;
      end;

      Assert(Caught_Make_SR_from_Null_SP,
             "Failed to identify Smart_Ref being made from a null Smart_Ptr");

   end Check_SP_SR;

end Auto_Counters_Suite.Smart_Ptrs_Tests;
