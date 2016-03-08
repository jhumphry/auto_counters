-- flyweights_basic_hashtables.ads
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

package Flyweights_Basic_Hashtables is

   use type Ada.Containers.Hash_Type;

   type List_Array is array (Ada.Containers.Hash_Type range <>) of Lists_Spec.List;

   type Flyweight is limited
      record
         Lists : List_Array (0..(Capacity-1))
           := (others => Lists_Spec.Empty_List);
      end record;

   procedure Insert (F : aliased in out Flyweight;
                     Bucket : out Ada.Containers.Hash_Type;
                     Data_Ptr : in out Element_Access);

   procedure Increment (F : aliased in out Flyweight;
                        Bucket : in Ada.Containers.Hash_Type;
                        Data_Ptr : in Element_Access);

   procedure Remove (F : in out Flyweight;
                     Bucket : in Ada.Containers.Hash_Type;
                     Data_Ptr : in Element_Access);

   package Hashtables_Spec is
     new Flyweights_Hashtables_Spec(Element_Access => Element_Access,
                                    Flyweight      => Flyweight,
                                    Insert         => Insert,
                                    Increment      => Increment,
                                    Remove         => Remove);

end Flyweights_Basic_Hashtables;
