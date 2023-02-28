-- smart_ref_example.adb
-- An example of using the Smart_Ref types

-- Copyright (c) 2016-2023, James Humphry
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

with Basic_Smart_Ptrs;

procedure Smart_Ref_Example is

   procedure Custom_Deleter(X : in out String) is
   begin
      Put_Line("Freeing resources relating to a string: " & X);
   end Custom_Deleter;

   package String_Ptrs is new Basic_Smart_Ptrs(T => String,
                                               Delete => Custom_Deleter);
   use String_Ptrs.Ptr_Types;

   SR1 : constant Smart_Ref := Make_Smart_Ref(new String'("Hello, World!"));

begin

   Put_Line("An example of using Smart_Ref from the Smart_Ptrs package.");
   New_Line;

   Put_Line("Smart_Ref SR1 => " & SR1);
   Put("SR1.Use_Count => "); Put(SR1.Use_Count); New_Line;
   New_Line; Flush;

   declare
      SP1 : Smart_Ptr := Make_Smart_Ptr(SR1);
      SR2 : constant Smart_Ref := Make_Smart_Ref(SP1);
   begin
      Put_Line("- New block");
      Put_Line("- Created Smart_Ptr SP1 from SR1 and Smart_Ref SR2 from SP1");
      Put_Line("- SP1 => " & SP1.P);
      Put_Line("- SR2 => " & SR2);
      Put("- SR1.Use_Count => "); Put(SR1.Use_Count); New_Line;
      Put("- SP1.Use_Count => "); Put(SP1.Use_Count); New_Line;
      Put_Line("- SR2(6) := ':'");
      SR2(6) := ':';
      Put_Line("- SR2 => " & SR2);
      Put_Line("- Nulling SP1"); Flush;
      SP1 := Null_Smart_Ptr;
      Put_Line("- SR2 => " & SR2);
      Put("- SR2.Use_Count => "); Put(SR2.Use_Count); New_Line;
   end;

   New_Line; Flush;
   Put_Line("Out of the block - SP1 and SR2 no longer exist.");
   Put_Line("Smart_Ref SR1 => " & SR1);
   Put("SR1.Use_Count => "); Put(SR1.Use_Count); New_Line;
   New_Line; Flush;

   Put_Line("Resources should be freed when the program ends.");

end Smart_Ref_Example;
