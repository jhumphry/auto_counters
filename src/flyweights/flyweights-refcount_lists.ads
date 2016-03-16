-- flyweights-refcount_lists.ads
-- A package of singly-linked reference-counting lists for the Flyweights
-- packages

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

with Flyweights_Lists_Spec;

generic
   type Element(<>) is limited private;
   type Element_Access is access Element;
   with function "=" (Left, Right : in Element) return Boolean is <>;
package Flyweights.Refcount_Lists is

   type Node is private;

   type List is access Node;

   Empty_List : constant List := null;

   procedure Insert (L : in out List;
                     E : in out Element_Access);

   procedure Increment (L : in out List;
                        E : in Element_Access);

   procedure Remove (L : in out List;
                     Data_Ptr : in Element_Access);

   package Lists_Spec is
     new Flyweights_Lists_Spec(Element_Access => Element_Access,
                               List           => List,
                               Empty_List     => Empty_List,
                               Insert         => Insert,
                               Increment      => Increment,
                               Remove         => Remove);

private

   subtype Node_Access is List;

   type Node is
      record
         Next : Node_Access;
         Data : Element_Access;
         Use_Count : Natural;
      end record;

end Flyweights.Refcount_Lists;
