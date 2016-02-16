-- unique_ptr_example.adb
-- An example of using the Unique_Ptr types

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

with Unique_Ptrs;

procedure Unique_Ptr_Example is

   procedure Custom_Deleter(X : in out String) is
   begin
      Put_Line("Freeing resources relating to a string: " & X);
   end Custom_Deleter;

   package String_Ptrs is new Unique_Ptrs(T => String,
                                          Delete => Custom_Deleter);
   use String_Ptrs;

   UP1 : constant Unique_Ptr := Make_Unique_Ptr(new String'("Hello, World!"));

begin

   Put_Line("An example of using the Unique_Ptrs package."); New_Line;

   Put_Line("UP1 => " & UP1);
   New_Line;

end Unique_Ptr_Example;
