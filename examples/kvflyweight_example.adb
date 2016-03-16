-- kvflyweight_example.adb
-- An example of using the KVFlyweight package

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

with Basic_Refcount_KVFlyweights;
--  with Protected_Refcount_KVFlyweights;

procedure KVFlyweight_Example is

   type String_Ptr is access String;

   function Make_String_Value (K : in String) return String_Ptr is
   begin
      return new String'("VALUE: " & K);
   end Make_String_Value;

   package String_KVFlyweights is
     new Basic_Refcount_KVFlyweights(Key          => String,
                                     Value        => String,
                                     Value_Access => String_Ptr,
                                     Factory      => Make_String_Value,
                                     Hash         => Ada.Strings.Hash,
                                     Capacity     => 16);

--     package String_KVFlyweights is
--       new Protected_Refcount_KVFlyweights(Key          => String,
--                                           Value        => String,
--                                           Value_Access => String_Ptr,
--                                           Factory      => Make_String_Value,
--                                           Hash         => Ada.Strings.Hash,
--                                           Capacity     => 16);

   use String_KVFlyweights;

   Resources : aliased KVFlyweight;

   HelloWorld : constant Value_Ptr
     := Insert_Ptr (F => Resources, K => "Hello, World!");

begin

   Put_Line("An example of using the KVFlyweights package."); New_Line;

   Put_Line("The key string ""Hello, World!"" has been added to the Resources");
   Put_Line("Retrieving value string via pointer HelloWorld: " &
              HelloWorld.P);

   Put_Line("Adding the same key string again...");
   declare
      HelloWorld2: constant Value_Ref
        := Insert_Ref (F => Resources, K => "Hello, World!");
   begin
      Put_Line("Retrieving value string via reference HelloWorld2: " &
                 HelloWorld2);
      Put_Line("Changing the comma to a colon via HelloWorld2");
      HelloWorld2(13) := ':';
      Put_Line("Now HelloWorld and HelloWorld2 should both have altered, as " &
                 "they should both point to the same string");
      Put_Line("Retrieving string value via pointer HelloWorld: " &
                 HelloWorld.P);
      Put_Line("Retrieving string value via reference HelloWorld2: " &
                 HelloWorld2);
      declare
         HelloWorld3 : constant Value_Ptr
           := Make_Ptr (HelloWorld2);
      begin
         Put_Line("Make a pointer HelloWorld3 from ref HelloWorld2: " &
                    HelloWorld3.P);
      end;
   end;

   Put_Line("Now HelloWorld2 and HelloWorld3 are out of scope.");
   Put_Line("HelloWorld should still point to the same string value: " &
              HelloWorld.P);

end KVFlyweight_Example;
