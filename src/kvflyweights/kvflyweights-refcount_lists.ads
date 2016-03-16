-- kvflyweights-refcount_lists.ads
-- A package of singly-linked reference-counting lists for the Flyweights
-- packages. Resources are associated with a key that can be used to create
-- them if they have not already been created.

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

with KVFlyweights_Lists_Spec;

generic
   type Key(<>) is private;
   type Key_Access is access Key;
   type Value(<>) is limited private;
   type Value_Access is access Value;
   with function Factory (K : in Key) return Value_Access;
   with function "=" (Left, Right : in Key) return Boolean is <>;
package KVFlyweights.Refcount_Lists is

   type Node is private;

   type List is access Node;

   Empty_List : constant List := null;

   procedure Insert (L : in out List;
                     K : in Key;
                     Key_Ptr : out Key_Access;
                     Value_Ptr : out Value_Access);

   procedure Increment (L : in out List;
                        Key_Ptr : in Key_Access);

   procedure Remove (L : in out List;
                     Key_Ptr : in Key_Access);

   package Lists_Spec is
     new KVFlyweights_Lists_Spec(Key          => Key,
                                 Key_Access   => Key_Access,
                                 Value_Access => Value_Access,
                                 List         => List,
                                 Empty_List   => Empty_List,
                                 Insert       => Insert,
                                 Increment    => Increment,
                                 Remove       => Remove);

private

   subtype Node_Access is List;

   type Node is
      record
         Next : Node_Access;
         Key_Ptr : Key_Access;
         Value_Ptr : Value_Access;
         Use_Count : Natural;
      end record;

end KVFlyweights.Refcount_Lists;
