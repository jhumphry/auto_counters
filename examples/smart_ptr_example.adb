-- smart_ptr_example.adb
-- An example of using the Smart_Ptr types

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

with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;

with Smart_Ptrs;

procedure Smart_Ptr_Example is

   procedure Custom_Deleter(X : in out String) is
   begin
      Put_Line("Freeing resources relating to a string: " & X);
   end Custom_Deleter;

   package String_Ptrs is new Smart_Ptrs(T => String,
                                         Delete => Custom_Deleter);
   use String_Ptrs;

   SP1 : constant Smart_Ptr := Make_Smart_Ptr(new String'("Hello, World!"));

begin

   Put_Line("An example of using the Smart_Ptrs package."); New_Line;

   Put_Line("SP1 => " & SP1);
   Put("SP1.Use_Count => "); Put(SP1.Use_Count); New_Line;
   New_Line;

   declare
      SP2 : constant Smart_Ptr := SP1;
   begin
      Put_Line("- In a new block");

      Put_Line("- SP2 := SP1");
      Put_Line("- SP2 => " & SP2);
      Put("- SP1.Use_Count => "); Put(SP1.Use_Count); New_Line;
      Put("- SP2.Use_Count => "); Put(SP2.Use_Count); New_Line;
      Put_Line("- SP2(6) := ';'");
      SP2(6) := ';';
      Put_Line("- SP2 => " & SP2);
      Put_Line("- End of block");
   end;
   New_Line;

   Put_Line("Now SP2 should have been destroyed.");
   Put_Line("SP1 should still show the changes made via SP2.");
   Put_Line("SP1 => " & SP1);
   Put("SP1.Use_Count => "); Put(SP1.Use_Count); New_Line;
   New_Line;

end Smart_Ptr_Example;
