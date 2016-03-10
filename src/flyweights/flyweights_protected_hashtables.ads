-- flyweights_protected_hashtables.ads
-- A package of task-safe hash tables for the Flyweights packages

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

with Flyweights_Lists_Spec;
with Flyweights_Hashtables_Spec;

generic
   type Element(<>) is limited private;
   type Element_Access is access Element;
   with function Hash (E : Element) return Ada.Containers.Hash_Type;
   with package Lists_Spec is
     new Flyweights_Lists_Spec(Element_Access => Element_Access,
                               others         => <>);
   Capacity : Ada.Containers.Hash_Type := 256;

package Flyweights_Protected_Hashtables is

   use type Ada.Containers.Hash_Type;

   type List_Array is array (Ada.Containers.Hash_Type range <>) of Lists_Spec.List;

   -- A possible enhancement would be to make Flyweight an unprotected array of
   -- protected objects, each protecting a single list. This would allow finer-
   -- grained locking and higher performance, at the cost of more memory and
   -- more complexity. Given that referring to the resources does not need to
   -- go through the protected barrier, and that resource creation and deletion
   -- should be rare, this has not been done so far.

   protected type Flyweight is
      procedure Insert (Bucket : out Ada.Containers.Hash_Type;
                        Data_Ptr : in out Element_Access);

      procedure Increment (Bucket : in Ada.Containers.Hash_Type;
                           Data_Ptr : in Element_Access);

      procedure Remove (Bucket : in Ada.Containers.Hash_Type;
                        Data_Ptr : in Element_Access);

   private
      Lists : List_Array (0..(Capacity-1)) := (others => Lists_Spec.Empty_List);
   end Flyweight;

   procedure Insert (F : aliased in out Flyweight;
                     Bucket : out Ada.Containers.Hash_Type;
                     Data_Ptr : in out Element_Access)
     with Inline;

   procedure Increment (F : aliased in out Flyweight;
                        Bucket : in Ada.Containers.Hash_Type;
                        Data_Ptr : in Element_Access)
     with Inline;

   procedure Remove (F : in out Flyweight;
                     Bucket : in Ada.Containers.Hash_Type;
                     Data_Ptr : in Element_Access)
     with Inline;

   package Hashtables_Spec is
     new Flyweights_Hashtables_Spec(Element_Access => Element_Access,
                                    Flyweight      => Flyweight,
                                    Insert         => Insert,
                                    Increment      => Increment,
                                    Remove         => Remove);

end Flyweights_Protected_Hashtables;
