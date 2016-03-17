-- kvflyweights-untracked_ptrs.ads
-- A package of generalised references which point to resources inside a
-- KVFlyweight. Resources are associated with a key that can be used to
-- create them if they have not already been created.

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

with KVFlyweights_Hashtables_Spec;

generic
   type Key(<>) is private;
   type Key_Access is access Key;
   type Value(<>) is limited private;
   type Value_Access is access Value;
   with package KVFlyweight_Hashtables is
     new KVFlyweights_Hashtables_Spec(Key          => Key,
                                      Key_Access   => Key_Access,
                                      Value_Access => Value_Access,
                                      others       => <>);
package KVFlyweights.Untracked_Ptrs is

   type V_Ref(V : access Value) is null record
     with Implicit_Dereference => V;

   type Untracked_Value_Ptr is tagged private;

   function P (P : Untracked_Value_Ptr) return V_Ref
     with Inline;

   function Get (P : Untracked_Value_Ptr) return Value_Access
     with Inline;

   function Insert_Ptr (F : aliased in out KVFlyweight_Hashtables.KVFlyweight;
                        K : in Key) return Untracked_Value_Ptr
     with Inline;

   type Untracked_Value_Ref (V : not null access Value) is tagged private
   with Implicit_Dereference => V;

   function Get (P : Untracked_Value_Ref) return Value_Access
     with Inline;

   function Insert_Ref (F : aliased in out KVFlyweight_Hashtables.KVFlyweight;
                        K : in Key) return Untracked_Value_Ref
     with Inline;

   function Make_Ptr (R : Untracked_Value_Ref'Class)
                      return Untracked_Value_Ptr
     with Inline;

   function Make_Ref (P : Untracked_Value_Ptr'Class)
                      return Untracked_Value_Ref
     with Inline, Pre => (Get(P) /= null or else
                              (raise KVFlyweights_Error with "Cannot make a " &
                                 "Untracked_Value_Ref from a null Untracked_Value_Ptr"));

private

   type KVFlyweight_Ptr is access all KVFlyweight_Hashtables.KVFlyweight;

   type Untracked_Value_Ptr is tagged
      record
         V : Value_Access := null;
         K : Key_Access := null;
         Containing_KVFlyweight : KVFlyweight_Ptr := null;
         Containing_Bucket : Ada.Containers.Hash_Type;
      end record;

   type Untracked_Value_Ref (V : access Value) is tagged
      record
         K : Key_Access := null;
         Containing_KVFlyweight : KVFlyweight_Ptr := null;
         Containing_Bucket : Ada.Containers.Hash_Type;
      end record;

end KVFlyweights.Untracked_Ptrs;
