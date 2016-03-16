-- kvflyweights-refcount_ptrs.ads
-- A package of reference-counting generalised references which point to
-- resources inside a Flyweight. Resources are associated with a key that can
-- be used to create them if they have not already been created.

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

with KVFlyweights_Hashtables_Spec;

generic
   type Key(<>) is private;
   type Value(<>) is limited private;
   type Value_Access is access Value;
   with package KVFlyweight_Hashtables is
     new KVFlyweights_Hashtables_Spec(Key          => Key,
                                      Value_Access => Value_Access,
                                      others       => <>);
package KVFlyweights.Refcount_Ptrs is

   type V_Ref(V : access Value) is null record
     with Implicit_Dereference => V;

   type Refcounted_Value_Ptr is
     new Ada.Finalization.Controlled with private;

   function P (P : Refcounted_Value_Ptr) return V_Ref
     with Inline;

   function Get (P : Refcounted_Value_Ptr) return Value_Access
     with Inline;

   function Insert_Ptr (F : aliased in out KVFlyweight_Hashtables.KVFlyweight;
                        K : in Key) return Refcounted_Value_Ptr
     with Inline;

   type Refcounted_Value_Ref (V : not null access Value) is
     new Ada.Finalization.Controlled with private
   with Implicit_Dereference => V;

   function Get (P : Refcounted_Value_Ref) return Value_Access
     with Inline;

   function Insert_Ref (F : aliased in out KVFlyweight_Hashtables.KVFlyweight;
                        K : in Key) return Refcounted_Value_Ref
     with Inline;

   function Make_Ptr (R : Refcounted_Value_Ref'Class)
                      return Refcounted_Value_Ptr
     with Inline;

   function Make_Ref (P : Refcounted_Value_Ptr'Class)
                      return Refcounted_Value_Ref
     with Inline, Pre => (Get(P) /= null or else
                              (raise KVFlyweights_Error with "Cannot make a " &
                                 "Refcounted_Value_Ref from a null Refcounted_Value_Ptr"));

private

   type KVFlyweight_Ptr is access all KVFlyweight_Hashtables.KVFlyweight;

   type Refcounted_Value_Ptr is
     new Ada.Finalization.Controlled with
      record
         V : Value_Access := null;
         Containing_KVFlyweight : KVFlyweight_Ptr := null;
         Containing_Bucket : Ada.Containers.Hash_Type;
      end record;

   overriding procedure Adjust (Object : in out Refcounted_Value_Ptr);
   overriding procedure Finalize (Object : in out Refcounted_Value_Ptr);

   type Refcounted_Value_Ref (V : access Value) is
     new Ada.Finalization.Controlled with
      record
         Containing_KVFlyweight : KVFlyweight_Ptr := null;
         Containing_Bucket : Ada.Containers.Hash_Type;
      end record;

   overriding procedure Initialize (Object : in out Refcounted_Value_Ref);
   overriding procedure Adjust (Object : in out Refcounted_Value_Ref);
   overriding procedure Finalize (Object : in out Refcounted_Value_Ref);

end KVFlyweights.Refcount_Ptrs;
