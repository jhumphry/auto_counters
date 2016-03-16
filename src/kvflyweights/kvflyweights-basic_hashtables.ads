-- kvflyweights-basic_hashtables.ads
-- A package of non-task-safe hash tables for the KVFlyweights packages

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

with KVFlyweights_Lists_Spec;
with KVFlyweights_Hashtables_Spec;

generic
   type Key(<>) is private;
   type Value(<>) is limited private;
   type Value_Access is access Value;
   with function Hash (K : Key) return Ada.Containers.Hash_Type;
   with package KVLists_Spec is
     new KVFlyweights_Lists_Spec(Key          => Key,
                                 Value_Access => Value_Access,
                                 others       => <>);
   Capacity : Ada.Containers.Hash_Type := 256;

package KVFlyweights.Basic_Hashtables is

   use type Ada.Containers.Hash_Type;

   type List_Array is array (Ada.Containers.Hash_Type range <>) of KVLists_Spec.List;

   type KVFlyweight is limited
      record
         Lists : List_Array (0..(Capacity-1))
           := (others => KVLists_Spec.Empty_List);
      end record;

   function Insert (F : aliased in out KVFlyweight;
                    Bucket : out Ada.Containers.Hash_Type;
                    K : in Key) return Value_Access
     with Inline;

   procedure Increment (F : aliased in out KVFlyweight;
                        Bucket : in Ada.Containers.Hash_Type;
                        Data_Ptr : in Value_Access)
     with Inline;

   procedure Remove (F : in out KVFlyweight;
                     Bucket : in Ada.Containers.Hash_Type;
                     Data_Ptr : in Value_Access)
     with Inline;

   package Hashtables_Spec is
     new KVFlyweights_Hashtables_Spec(Key          => Key,
                                      Value_Access => Value_Access,
                                      KVFlyweight  => KVFlyweight,
                                      Insert       => Insert,
                                      Increment    => Increment,
                                      Remove       => Remove);

end KVFlyweights.Basic_Hashtables;
