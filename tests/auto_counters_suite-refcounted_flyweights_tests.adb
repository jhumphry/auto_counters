-- Auto_Counters_Suite.Refcounted_Flyweights_Tests
-- Unit tests for Auto_Counters Refcounted Flyweights packages

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with Ada.Containers, Ada.Finalization;

with AUnit.Assertions;

with Basic_Refcounted_Flyweights;
with Protected_Refcounted_Flyweights;

package body Auto_Counters_Suite.Refcounted_Flyweights_Tests is

   subtype Hash_Type is Ada.Containers.Hash_Type;
   use type Ada.Containers.Hash_Type;

   use AUnit.Assertions;

   Resources_Released : Natural := 0;

   type TestObj is new Ada.Finalization.Controlled with
      record
         Hash : Hash_Type;
         Value : Integer;
      end record;

   type TestObj_Access is access TestObj;

   pragma Warnings (Off, "not dispatching");
   function Hash (E : TestObj) return Ada.Containers.Hash_Type is (E.Hash);
   pragma Warnings (On, "not dispatching");

   overriding procedure Finalize (Object : in out TestObj) is
   begin
      Resources_Released := Resources_Released + 1;
      Object.Hash := 0;
      Object.Value := -1;
   end Finalize;

   package TestObj_Basic_Flyweights is
     new Basic_Refcounted_Flyweights(Element        => TestObj,
                                     Element_Access => TestObj_Access,
                                     Hash           => Hash,
                                     Capacity       => 4);

   package TestObj_Protected_Flyweights is
     new Protected_Refcounted_Flyweights(Element        => TestObj,
                                         Element_Access => TestObj_Access,
                                         Hash           => Hash,
                                         Capacity       => 4);

   --------------------
   -- Register_Tests --
   --------------------

   procedure Register_Tests (T: in out Refcounted_Flyweights_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Check_Basic_Usage'Access,
                        "Check Basic_Refcounted_Flyweights functionality");
      Register_Routine (T, Check_Basic_Refs_Usage'Access,
                        "Check Basic_Refcounted_Flyweights Element_Refs functionality");
      Register_Routine (T, Check_Protected_Usage'Access,
                        "Check Protected_Refcounted_Flyweights functionality");
      Register_Routine (T, Check_Protected_Refs_Usage'Access,
                        "Check Protected_Refcounted_Flyweights Element_Refs functionality");
   end Register_Tests;

   ----------
   -- Name --
   ----------

   function Name (T : Refcounted_Flyweights_Test) return Test_String is
      pragma Unreferenced (T);
   begin
      return Format ("Tests of Refcounted Flyweights packages functionality");
   end Name;

   ------------
   -- Set_Up --
   ------------

   procedure Set_Up (T : in out Refcounted_Flyweights_Test) is
   begin
      null;
   end Set_Up;

   -----------------------
   -- Check_Basic_Usage --
   -----------------------

   procedure Check_Basic_Usage (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      use TestObj_Basic_Flyweights;

      F : aliased Flyweight;

      E : TestObj_Access;

      P : array (Integer range 0..3) of Element_Ptr;

   begin

      -- Tests where elements are spread between buckets.

      Resources_Released := 0;

      for I in 0..3 loop
         E := new TestObj'(Ada.Finalization.Controlled with
                           Hash  => Hash_Type(I),
                           Value => I);
         P(I) := Insert_Ptr(F, E);
      end loop;

      Assert(Resources_Released = 0,
             "Resources being released on insertion into an empty Flyweight.");

      for I in 0..3 loop
         Assert(P(I).Get.Hash = Hash_Type(I) and P(I).Get.Value = I,
                "Flyweight not storing values correctly.");
         Assert(P(I).P.Hash = Hash_Type(I) and P(I).P.Value = I,
                "Flyweight not storing values correctly.");
      end loop;

      Resources_Released := 0;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 0);
         Q : Element_Ptr := Insert_Ptr(F, E);
         pragma Unreferenced(Q);
      begin
         Assert(Resources_Released = 1,
                "Resources not being released on inserting duplicate " &
                  "resource into Flyweight.");
      end;

      Resources_Released := 0;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 1);
         R : Element_Ptr;
         pragma Unreferenced (R);
      begin
         R := Insert_Ptr(F, E);
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into " &
                  "Flyweight despite it not being a duplicate.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last pointer is destroyed.");

      Resources_Released := 0;

      declare
         E : TestObj_Access := P(1).Get;
         Q : constant Element_Ptr := Insert_Ptr(F, E);
      begin
         Assert(E = P(1).Get,
                "Inserting an access value that is already in the Flyweight " &
                  "changes the access value unnecessarily.");
         Assert(Q = P(1),
                "Inserting an access value that is already in the Flyweight " &
                  "does not return the same Element_Ptr as already exists.");
         Assert(Resources_Released = 0,
                "Inserting an access value that is already in the Flyweight " &
                  "deallocates the object.");
      end;

      -- Tests where all values hit same hash bucket

      for I in 0..3 loop
         E := new TestObj'(Ada.Finalization.Controlled with
                           Hash  => 0,
                           Value => I);
         P(I) := Insert_Ptr(F, E);
      end loop;

      for I in 0..3 loop
         Assert(P(I).P.Hash = 0 and P(I).P.Value = I,
                "Flyweight not storing values correctly.");
      end loop;

      Resources_Released := 0;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 0);
         Q : Element_Ptr := Insert_Ptr(F, E);
         pragma Unreferenced(Q);
      begin
         Assert(Resources_Released = 1,
                "Resources not being released on inserting duplicate " &
                  "resource into Flyweight.");
      end;

      Resources_Released := 0;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 4);
         R : Element_Ptr;
         pragma Unreferenced (R);
      begin
         R := Insert_Ptr(F, E);
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into " &
                  "Flyweight despite it not being a duplicate.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last pointer is destroyed.");

      Resources_Released := 0;

      declare
         E : TestObj_Access := P(1).Get;
         Q : constant Element_Ptr := Insert_Ptr(F, E);
      begin
         Assert(E = P(1).Get,
                "Inserting an access value that is already in the Flyweight " &
                  "changes the access value unnecessarily.");
         Assert(Q = P(1),
                "Inserting an access value that is already in the Flyweight " &
                  "does not return the same Element_Ptr as already exists.");
         Assert(Resources_Released = 0,
                "Inserting an access value that is already in the Flyweight " &
                  "deallocates the object.");
      end;

   end Check_Basic_Usage;

   ----------------------------
   -- Check_Basic_Refs_Usage --
   ----------------------------

   procedure Check_Basic_Refs_Usage (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      use TestObj_Basic_Flyweights;

      F : aliased Flyweight;

   begin

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 0);
         P1 : constant Element_Ptr := Insert_Ptr(F, E);
         R1 : constant Element_Ref := Make_Ref(P1);
      begin
         Assert(P1.Get = R1.Get,
                "Element_Ref created from Element_Ptr does not point to the" &
               "same value");
         Assert(P1.Get.all = R1,
                "Element_Ref created from Element_Ptr does not dereference to " &
                  "the same value");
      end;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 1,
                                            Value => 1);
         R2 : constant Element_Ref := Insert_Ref(F, E);
         P2 : constant Element_Ptr := Make_Ptr(R2);
      begin
         Assert(P2.Get = R2.Get,
                "Element_Ptr created from Element_Ref does not point to the" &
               "same value");
         Assert(P2.Get.all = R2,
                "Element_Ptr created from Element_Ref does not dereference to " &
                  "the same value");
      end;

      Resources_Released := 0;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 4);
         R : Element_Ref := Insert_Ref(F, E);
         pragma Unreferenced (R);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into " &
                  "Flyweight despite it not being a duplicate.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last Element_Ref is destroyed.");

   end Check_Basic_Refs_Usage;

   ---------------------------
   -- Check_Protected_Usage --
   ---------------------------

   procedure Check_Protected_Usage (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      use TestObj_Protected_Flyweights;

      F : aliased Flyweight;

      E : TestObj_Access;

      P : array (Integer range 0..3) of Element_Ptr;

   begin

      -- Tests where elements are spread between buckets.

      Resources_Released := 0;

      for I in 0..3 loop
         E := new TestObj'(Ada.Finalization.Controlled with
                           Hash  => Hash_Type(I),
                           Value => I);
         P(I) := Insert_Ptr(F, E);
      end loop;

      Assert(Resources_Released = 0,
             "Resources being released on insertion into an empty Flyweight.");

      for I in 0..3 loop
         Assert(P(I).Get.Hash = Hash_Type(I) and P(I).Get.Value = I,
                "Flyweight not storing values correctly.");
         Assert(P(I).P.Hash = Hash_Type(I) and P(I).P.Value = I,
                "Flyweight not storing values correctly.");
      end loop;

      Resources_Released := 0;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 0);
         Q : Element_Ptr := Insert_Ptr(F, E);
         pragma Unreferenced(Q);
      begin
         Assert(Resources_Released = 1,
                "Resources not being released on inserting duplicate " &
                  "resource into Flyweight.");
      end;

      Resources_Released := 0;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 1);
         R : Element_Ptr;
         pragma Unreferenced (R);
      begin
         R := Insert_Ptr(F, E);
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into " &
                  "Flyweight despite it not being a duplicate.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last pointer is destroyed.");

      Resources_Released := 0;

      declare
         E : TestObj_Access := P(1).Get;
         Q : constant Element_Ptr := Insert_Ptr(F, E);
      begin
         Assert(E = P(1).Get,
                "Inserting an access value that is already in the Flyweight " &
                  "changes the access value unnecessarily.");
         Assert(Q = P(1),
                "Inserting an access value that is already in the Flyweight " &
                  "does not return the same Element_Ptr as already exists.");
         Assert(Resources_Released = 0,
                "Inserting an access value that is already in the Flyweight " &
                  "deallocates the object.");
      end;

      -- Tests where all values hit same hash bucket

      for I in 0..3 loop
         E := new TestObj'(Ada.Finalization.Controlled with
                           Hash  => 0,
                           Value => I);
         P(I) := Insert_Ptr(F, E);
      end loop;

      for I in 0..3 loop
         Assert(P(I).P.Hash = 0 and P(I).P.Value = I,
                "Flyweight not storing values correctly.");
      end loop;

      Resources_Released := 0;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 0);
         Q : Element_Ptr := Insert_Ptr(F, E);
         pragma Unreferenced(Q);
      begin
         Assert(Resources_Released = 1,
                "Resources not being released on inserting duplicate " &
                  "resource into Flyweight.");
      end;

      Resources_Released := 0;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 4);
         R : Element_Ptr;
         pragma Unreferenced (R);
      begin
         R := Insert_Ptr(F, E);
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into " &
                  "Flyweight despite it not being a duplicate.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last pointer is destroyed.");

      Resources_Released := 0;

      declare
         E : TestObj_Access := P(1).Get;
         Q : constant Element_Ptr := Insert_Ptr(F, E);
      begin
         Assert(E = P(1).Get,
                "Inserting an access value that is already in the Flyweight " &
                  "changes the access value unnecessarily.");
         Assert(Q = P(1),
                "Inserting an access value that is already in the Flyweight " &
                  "does not return the same Element_Ptr as already exists.");
         Assert(Resources_Released = 0,
                "Inserting an access value that is already in the Flyweight " &
                  "deallocates the object.");
      end;

   end Check_Protected_Usage;

   --------------------------------
   -- Check_Protected_Refs_Usage --
   --------------------------------

   procedure Check_Protected_Refs_Usage (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced(T);

      use TestObj_Protected_Flyweights;

      F : aliased Flyweight;

   begin

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 0);
         P1 : constant Element_Ptr := Insert_Ptr(F, E);
         R1 : constant Element_Ref := Make_Ref(P1);
      begin
         Assert(P1.Get = R1.Get,
                "Element_Ref created from Element_Ptr does not point to the" &
               "same value");
         Assert(P1.Get.all = R1,
                "Element_Ref created from Element_Ptr does not dereference to " &
                  "the same value");
      end;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 1,
                                            Value => 1);
         R2 : constant Element_Ref := Insert_Ref(F, E);
         P2 : constant Element_Ptr := Make_Ptr(R2);
      begin
         Assert(P2.Get = R2.Get,
                "Element_Ptr created from Element_Ref does not point to the" &
               "same value");
         Assert(P2.Get.all = R2,
                "Element_Ptr created from Element_Ref does not dereference to " &
                  "the same value");
      end;

      Resources_Released := 0;

      declare
         E : TestObj_Access := new TestObj'(Ada.Finalization.Controlled
                                              with Hash  => 0,
                                            Value => 4);
         R : Element_Ref := Insert_Ref(F, E);
         pragma Unreferenced (R);
      begin
         Assert(Resources_Released = 0,
                "Resources being released on inserting resource into " &
                  "Flyweight despite it not being a duplicate.");
      end;
      Assert(Resources_Released = 1,
             "Resources not being released when last Element_Ref is destroyed.");

   end Check_Protected_Refs_Usage;

end Auto_Counters_Suite.Refcounted_Flyweights_Tests;
