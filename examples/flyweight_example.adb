-- flyweight_example.adb
-- An example of using the Flyweight package

-- Copyright (c) 2016, James Humphry
--
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
-- REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
-- AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
-- INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
-- LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
-- OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
-- PERFORMANCE OF THIS SOFTWARE.

with Ada.Text_IO;
use Ada.Text_IO;

with Ada.Strings.Hash;

with Basic_Refcount_Flyweights;
--  with Basic_Untracked_Flyweights;
--  with Protected_Refcount_Flyweights;
--  with Protected_Untracked_Flyweights;

procedure Flyweight_Example is

   type String_Ptr is access String;

   package String_Flyweights is
     new Basic_Refcount_Flyweights(Element        => String,
                                   Element_Access => String_Ptr,
                                   Hash           => Ada.Strings.Hash,
                                   Capacity       => 16);

   -- By commenting out the definition above and uncommenting one of the
   -- definitions below, this example can use one of the other versions of the
   -- Flyweights with no other changes required. The gnatmem tool can be used
   -- to demonstrate the difference between the reference-counted and untracked
   -- versions.

--     package String_Flyweights is
--       new Basic_Untracked_Flyweights(Element        => String,
--                                      Element_Access => String_Ptr,
--                                      Hash           => Ada.Strings.Hash,
--                                      Capacity       => 16);

--     package String_Flyweights is
--       new Protected_Refcount_Flyweights(Element        => String,
--                                         Element_Access => String_Ptr,
--                                         Hash           => Ada.Strings.Hash,
--                                         Capacity       => 16);

--     package String_Flyweights is
--       new Protected_Untracked_Flyweights(Element        => String,
--                                          Element_Access => String_Ptr,
--                                          Hash           => Ada.Strings.Hash,
--                                          Capacity       => 16);

   use String_Flyweights;

   Resources : aliased Flyweight;

   HelloWorld_Raw_Ptr : String_Ptr := new String'("Hello, World!");

   HelloWorld_Ref : constant Element_Ref
     := Insert_Ref (F => Resources, E => HelloWorld_Raw_Ptr);

   HelloWorld_Ptr : constant Element_Ptr
     := Insert_Ptr (F => Resources, E => HelloWorld_Raw_Ptr);

begin

   Put_Line("An example of using the Flyweights package."); New_Line;

   Put_Line("The string ""Hello, World!"" has been added to the Resources");
   Put_Line("Retrieving string via reference HelloWorld: " & HelloWorld_Ref);
   Put_Line("Retrieving string via pointer HelloWorld: " &
              HelloWorld_Ptr.Get.all);

   Put_Line("Adding the same string again...");
   declare
      HelloWorld2_Raw_Ptr : String_Ptr := new String'("Hello, World!");

      HelloWorld2_Ref : constant Element_Ref
        := Insert_Ref (F => Resources, E => HelloWorld2_Raw_Ptr);
   begin
      Put_Line("Retrieving string via reference HelloWorld2: " & HelloWorld2_Ref);
      Put("Check references point to same copy: ");
      Put((if HelloWorld2_Ref.E = HelloWorld_Ref.E then "OK" else "ERROR"));
      New_Line;
      declare
         HelloWorld3_Ptr : constant Element_Ptr
           := Make_Ptr (HelloWorld2_Ref);
      begin
         Put_Line("Make a pointer HelloWorld3 from ref HelloWorld2: " &
                    HelloWorld3_Ptr.P);
      end;
   end;
   Put_Line("Now HelloWorld2 is out of scope.");
   Put_Line("HelloWorld should still point to the string: " & HelloWorld_Ref);

end Flyweight_Example;
