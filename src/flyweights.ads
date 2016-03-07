-- flyweights.ads
-- A package for ensuring resources are not duplicated in a manner similar
-- to the C++ Boost flyweight classes.

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

with Ada.Containers;
with Ada.Finalization;

generic
   type Element(<>) is limited private;
   type Element_Access is access Element;
   with function Hash (E : Element) return Ada.Containers.Hash_Type;
   Capacity : Ada.Containers.Hash_Type := 256;
   with function "=" (Left, Right : in Element) return Boolean is <>;
package Flyweights is

   type Refcounted_Element_Ref (E : access Element) is
     new Ada.Finalization.Limited_Controlled with private
   with Implicit_Dereference => E;

   type Flyweight is limited private;

   function Insert (F : aliased in out Flyweight;
                    E : in out Element_Access) return Refcounted_Element_Ref;

private

   use type Ada.Containers.Hash_Type;

   type Node;

   type Node_Access is access Node;

   type Node is
      record
         Next : Node_Access;
         Data : Element_Access;
         Use_Count : Natural;
      end record;

   procedure Insert (List : in out Node_Access;
                     E : in out Element_Access);

   procedure Remove (List : in out Node_Access;
                     Data_Ptr : in Element_Access);

   type Node_Array is array (Ada.Containers.Hash_Type range <>) of Node_Access;

   type Flyweight is
      record
         Nodes : Node_Array (0..(Capacity-1)) := (others => null);
      end record;

   procedure Remove (F : in out Flyweight;
                     Bucket : Ada.Containers.Hash_Type;
                     Data_Ptr : in Element_Access);

   type Refcounted_Element_Ref (E : access Element) is
     new Ada.Finalization.Limited_Controlled with
      record
         Containing_Flyweight : access Flyweight;
         Containing_Bucket : Ada.Containers.Hash_Type;
      end record;

   overriding procedure Initialize (Object : in out Refcounted_Element_Ref);
   overriding procedure Finalize (Object : in out Refcounted_Element_Ref);

end Flyweights;
