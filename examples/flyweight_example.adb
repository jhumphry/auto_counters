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

procedure Flyweight_Example is

   type String_Ptr is access String;

   package String_Flyweights is
     new Basic_Refcount_Flyweights(Element        => String,
                                   Element_Access => String_Ptr,
                                   Hash           => Ada.Strings.Hash,
                                   Capacity       => 16);
   use String_Flyweights;

   Resources : aliased Flyweight;

   HelloWorld_Ptr : String_Ptr := new String'("Hello, World!");

   HelloWorld : constant Refcounted_Element_Ref
     := Insert(F => Resources, E => HelloWorld_Ptr);

begin

   Put_Line("An example of using the Flyweights package."); New_Line;

   Put_Line("The string ""Hello, World!"" has been added to the Resources");
   Put_Line("Retrieving string via reference HelloWorld: " & HelloWorld);

   Put_Line("Adding the same string again...");
   declare
      HelloWorld2_Ptr : String_Ptr := new String'("Hello, World!");

      HelloWorld2 : constant Refcounted_Element_Ref
        := Insert(F => Resources, E => HelloWorld2_Ptr);
   begin
      Put_Line("Retrieving string via reference HelloWorld2: " & HelloWorld2);
      Put("Check references point to same copy: ");
      Put((if HelloWorld2.E = HelloWorld.E then "OK" else "ERROR"));
      New_Line;
   end;
   Put_Line("Now HelloWorld2 is out of scope.");
   Put_Line("HelloWorld should still point to the string: " & HelloWorld);

end Flyweight_Example;
