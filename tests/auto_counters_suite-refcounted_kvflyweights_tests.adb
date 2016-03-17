-- Auto_Counters_Suite.Refcounted_KVFlyweights_Tests
-- Unit tests for Auto_Counters Refcounted KVFlyweights packages

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with Ada.Containers, Ada.Finalization;

with AUnit.Assertions;

with Basic_Refcounted_KVFlyweights;
with Protected_Refcounted_KVFlyweights;

package body Auto_Counters_Suite.Refcounted_KVFlyweights_Tests is

   subtype Hash_Type is Ada.Containers.Hash_Type;
   use type Ada.Containers.Hash_Type;

   use AUnit.Assertions;

   Resources_Released : Natural := 0;

   subtype TestKey_Type is Hash_Type;

   type TestValue_Type is new Ada.Finalization.Controlled with
      record
         Value : Hash_Type;
      end record;

   type TestValue_Access is access TestValue_Type;

   function Hash (E : TestKey_Type) return Ada.Containers.Hash_Type is (E);

   pragma Warnings (Off, "not dispatching");
   function Factory (E : in TestKey_Type) return TestValue_Access is
     (new TestValue_Type'(Ada.Finalization.Controlled with Value => E));
   pragma Warnings (On, "not dispatching");

   overriding procedure Finalize (Object : in out TestValue_Type) is
   begin
      Resources_Released := Resources_Released + 1;
      Object.Value := 999;
   end Finalize;

   package TestObj_Basic_KVFlyweights is
     new Basic_Refcounted_KVFlyweights(Key          => TestKey_Type,
                                       Value        => TestValue_Type,
                                       Value_Access => TestValue_Access,
                                       Factory      => Factory,
                                       Hash         => Hash,
                                       Capacity     => 4);

   use type TestObj_Basic_KVFlyweights.Value_Ptr;
   use type TestObj_Basic_KVFlyweights.Value_Ref;

   package TestObj_Protected_KVFlyweights is
     new Protected_Refcounted_KVFlyweights(Key          => TestKey_Type,
                                           Value        => TestValue_Type,
                                           Value_Access => TestValue_Access,
                                           Factory      => Factory,
                                           Hash         => Hash,
                                           Capacity     => 4);

   use type TestObj_Protected_KVFlyweights.Value_Ptr;
   use type TestObj_Protected_KVFlyweights.Value_Ref;

   --------------------
   -- Register_Tests --
   --------------------

   procedure Register_Tests (T: in out Refcounted_KVFlyweights_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Check_Basic_Usage'Access,
                        "Check Basic_Refcounted_KVFlyweights functionality");
      Register_Routine (T, Check_Basic_Refs_Usage'Access,
                        "Check Basic_Refcounted_KVFlyweights Element_Refs functionality");
      Register_Routine (T, Check_Protected_Usage'Access,
                        "Check Protected_Refcounted_KVFlyweights functionality");
      Register_Routine (T, Check_Protected_Refs_Usage'Access,
                        "Check Protected_Refcounted_KVFlyweights Element_Refs functionality");
   end Register_Tests;

   ----------
   -- Name --
   ----------

   function Name (T : Refcounted_KVFlyweights_Test) return Test_String is
      pragma Unreferenced (T);
   begin
      return Format ("Tests of Refcounted FKVlyweights packages functionality");
   end Name;

   ------------
   -- Set_Up --
   ------------

   procedure Set_Up (T : in out Refcounted_KVFlyweights_Test) is
   begin
      null;
   end Set_Up;

   -----------------------
   -- Check_Basic_Usage --
   -----------------------

   procedure Check_Basic_Usage (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      use TestObj_Basic_KVFlyweights;

      F : aliased KVFlyweight;

      P : array (Integer range 0..3) of Value_Ptr;

   begin

      -- Tests where elements are spread between buckets.

      Resources_Released := 0;

      for I in 0..3 loop
         P(I) := Insert_Ptr(F => F,
                            K => Hash_Type(I));
      end loop;

      Assert(Resources_Released = 0,
             "Resources being released on insertion into an empty KVFlyweight.");

      for I in 0..3 loop
         Assert(P(I).Get.Value = Hash_Type(I),
                "Flyweight not storing values correctly.");
         Assert(P(I).P.Value = Hash_Type(I),
                "Flyweight not storing values correctly.");
      end loop;

      Resources_Released := 0;

      declare
         Q : Value_Ptr := Insert_Ptr(F, 0);
         pragma Unreferenced(Q);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting duplicate key into a " &
                  "KVFlyweight.");
      end;

      Resources_Released := 0;

      declare
         R : Value_Ptr := Insert_Ptr(F, 4);
         pragma Unreferenced (R);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into a " &
                  "KVFlyweight despite it not being a duplicate key.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last pointer is destroyed.");

      Resources_Released := 0;

      declare
         Q : constant Value_Ptr := Insert_Ptr(F, P(1).Get.Value);
      begin
         Assert(Q = P(1),
                "Inserting a key value that is already in the KVFlyweight " &
                  "does not return the same Element_Ptr as already exists.");
         Assert(Resources_Released = 0,
                "Inserting a key value that is already in the KVFlyweight " &
                  "deallocates something.");
      end;

      -- Tests where all values hit same hash bucket

      for I in 0..3 loop
         P(I) := Insert_Ptr(F, Hash_Type(I * 4));
      end loop;

      for I in 0..3 loop
         Assert(P(I).P.Value = Hash_Type(I * 4),
                "Flyweight not storing values correctly.");
      end loop;

      Resources_Released := 0;

      declare
         Q : Value_Ptr := Insert_Ptr(F, 0);
         pragma Unreferenced(Q);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting duplicate key into a " &
                  "KVFlyweight.");
      end;

      Resources_Released := 0;

      declare
         R : Value_Ptr := Insert_Ptr(F, 99);
         pragma Unreferenced (R);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into a " &
                  "KVFlyweight despite it not being a duplicate key.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last pointer is destroyed.");

      Resources_Released := 0;

      declare
         Q : constant Value_Ptr := Insert_Ptr(F,P(1).Get.Value);
      begin
         Assert(Q = P(1),
                "Inserting a key value that is already in the KVFlyweight " &
                  "does not return the same Value_Ptr as already exists.");
         Assert(Resources_Released = 0,
                "Inserting a key value that is already in the KVFlyweight " &
                  "deallocates something.");
      end;

   end Check_Basic_Usage;

   ----------------------------
   -- Check_Basic_Refs_Usage --
   ----------------------------

   procedure Check_Basic_Refs_Usage (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      use TestObj_Basic_KVFlyweights;

      F : aliased KVFlyweight;

   begin

      declare
         P1 : constant Value_Ptr := Insert_Ptr(F, 0);
         R1 : constant Value_Ref := Make_Ref(P1);
      begin
         Assert(P1.Get = R1.Get,
                "Value_Ref created from Value_Ptr does not point to the" &
               "same value");
         Assert(P1.Get.all = R1,
                "Value_Ref created from Value_Ptr does not dereference to " &
                  "the same value");
      end;

      declare
         R2 : constant Value_Ref := Insert_Ref(F, 1);
         P2 : constant Value_Ptr := Make_Ptr(R2);
      begin
         Assert(P2.Get = R2.Get,
                "Value_Ptr created from Value_Ref does not point to the" &
               "same value");
         Assert(P2.Get.all = R2,
                "Value_Ptr created from Value_Ref does not dereference to " &
                  "the same value");
      end;

      Resources_Released := 0;

      declare
         R : Value_Ref := Insert_Ref(F, 4);
         pragma Unreferenced (R);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into " &
                  "KVFlyweight despite it not being a duplicate.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last Value_Ref is destroyed.");

   end Check_Basic_Refs_Usage;

   ---------------------------
   -- Check_Protected_Usage --
   ---------------------------

   procedure Check_Protected_Usage (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      use TestObj_Protected_KVFlyweights;

      F : aliased KVFlyweight;

      P : array (Integer range 0..3) of Value_Ptr;

   begin

      -- Tests where elements are spread between buckets.

      Resources_Released := 0;

      for I in 0..3 loop
         P(I) := Insert_Ptr(F => F,
                            K => Hash_Type(I));
      end loop;

      Assert(Resources_Released = 0,
             "Resources being released on insertion into an empty KVFlyweight.");

      for I in 0..3 loop
         Assert(P(I).Get.Value = Hash_Type(I),
                "Flyweight not storing values correctly.");
         Assert(P(I).P.Value = Hash_Type(I),
                "Flyweight not storing values correctly.");
      end loop;

      Resources_Released := 0;

      declare
         Q : Value_Ptr := Insert_Ptr(F, 0);
         pragma Unreferenced(Q);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting duplicate key into a " &
                  "KVFlyweight.");
      end;

      Resources_Released := 0;

      declare
         R : Value_Ptr := Insert_Ptr(F, 4);
         pragma Unreferenced (R);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into a " &
                  "KVFlyweight despite it not being a duplicate key.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last pointer is destroyed.");

      Resources_Released := 0;

      declare
         Q : constant Value_Ptr := Insert_Ptr(F, P(1).Get.Value);
      begin
         Assert(Q = P(1),
                "Inserting a key value that is already in the KVFlyweight " &
                  "does not return the same Element_Ptr as already exists.");
         Assert(Resources_Released = 0,
                "Inserting a key value that is already in the KVFlyweight " &
                  "deallocates something.");
      end;

      -- Tests where all values hit same hash bucket

      for I in 0..3 loop
         P(I) := Insert_Ptr(F, Hash_Type(I * 4));
      end loop;

      for I in 0..3 loop
         Assert(P(I).P.Value = Hash_Type(I * 4),
                "Flyweight not storing values correctly.");
      end loop;

      Resources_Released := 0;

      declare
         Q : Value_Ptr := Insert_Ptr(F, 0);
         pragma Unreferenced(Q);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting duplicate key into a " &
                  "KVFlyweight.");
      end;

      Resources_Released := 0;

      declare
         R : Value_Ptr := Insert_Ptr(F, 99);
         pragma Unreferenced (R);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into a " &
                  "KVFlyweight despite it not being a duplicate key.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last pointer is destroyed.");

      Resources_Released := 0;

      declare
         Q : constant Value_Ptr := Insert_Ptr(F,P(1).Get.Value);
      begin
         Assert(Q = P(1),
                "Inserting a key value that is already in the KVFlyweight " &
                  "does not return the same Value_Ptr as already exists.");
         Assert(Resources_Released = 0,
                "Inserting a key value that is already in the KVFlyweight " &
                  "deallocates something.");
      end;

   end Check_Protected_Usage;

   --------------------------------
   -- Check_Protected_Refs_Usage --
   --------------------------------

   procedure Check_Protected_Refs_Usage (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      use TestObj_Protected_KVFlyweights;

      F : aliased KVFlyweight;

   begin

      declare
         P1 : constant Value_Ptr := Insert_Ptr(F, 0);
         R1 : constant Value_Ref := Make_Ref(P1);
      begin
         Assert(P1.Get = R1.Get,
                "Value_Ref created from Value_Ptr does not point to the" &
               "same value");
         Assert(P1.Get.all = R1,
                "Value_Ref created from Value_Ptr does not dereference to " &
                  "the same value");
      end;

      declare
         R2 : constant Value_Ref := Insert_Ref(F, 1);
         P2 : constant Value_Ptr := Make_Ptr(R2);
      begin
         Assert(P2.Get = R2.Get,
                "Value_Ptr created from Value_Ref does not point to the" &
               "same value");
         Assert(P2.Get.all = R2,
                "Value_Ptr created from Value_Ref does not dereference to " &
                  "the same value");
      end;

      Resources_Released := 0;

      declare
         R : Value_Ref := Insert_Ref(F, 4);
         pragma Unreferenced (R);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into " &
                  "KVFlyweight despite it not being a duplicate.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last Value_Ref is destroyed.");
   end Check_Protected_Refs_Usage;

end Auto_Counters_Suite.Refcounted_KVFlyweights_Tests;
