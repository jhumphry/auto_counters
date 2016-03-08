-- flyweights_basic_hashtables.adb
-- A package of non-task-safe hash tables for the Flyweights packages

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

pragma Profile (No_Implementation_Extensions);

with Ada.Assertions;
with Ada.Unchecked_Conversion;

package body Flyweights_Basic_Hashtables is

   type Access_Element is access all Element;

   function Access_Element_To_Element_Access is new Ada.Unchecked_Conversion(Source => Access_Element,
                                                                             Target => Element_Access);

   subtype Hash_Type is Ada.Containers.Hash_Type;

   procedure Insert (F : aliased in out Flyweight;
                    Bucket : out Hash_Type;
                    Data_Ptr : in out Element_Access) is
   begin
      Bucket := (Hash(Data_Ptr.all) mod Capacity);
      Insert(L => F.Lists(Bucket),
             E => Data_Ptr);
   end Insert;

   procedure Remove (F : in out Flyweight;
                     Bucket : in Ada.Containers.Hash_Type;
                     Data_Ptr : in Element_Access) is
      use Ada.Assertions;
   begin
      Assert(F.Lists(Bucket) /= null,
             "Attempting to remove an element where the relevant bucket in " &
               "the hashtable is null");
      Remove(L => F.Lists(Bucket),
             Data_Ptr => Data_Ptr);
   end Remove;

end Flyweights_Basic_Hashtables;
