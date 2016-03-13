-- flyweights_refcount_ptrs.ads
-- A package of reference-counting generalised references which point to
-- resources inside a Flyweight

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

with Flyweights_Hashtables_Spec;

generic
   type Element(<>) is limited private;
   type Element_Access is access Element;
   with package Flyweight_Hashtables is
     new Flyweights_Hashtables_Spec(Element_Access => Element_Access,
                                    others => <>);
package Flyweights_Refcount_Ptrs is

   type E_Ref(E : access Element) is null record
     with Implicit_Dereference => E;

   type Refcounted_Element_Ptr is
     new Ada.Finalization.Controlled with private;

   function P (P : Refcounted_Element_Ptr) return E_Ref
     with Inline;

   function Get (P : Refcounted_Element_Ptr) return Element_Access
     with Inline;

   function Insert_Ptr (F : aliased in out Flyweight_Hashtables.Flyweight;
                        E : in out Element_Access) return Refcounted_Element_Ptr
     with Inline;

   type Refcounted_Element_Ref (E : access Element) is
     new Ada.Finalization.Controlled with private
   with Implicit_Dereference => E;

   function Get (P : Refcounted_Element_Ref) return Element_Access
     with Inline;

   function Insert_Ref (F : aliased in out Flyweight_Hashtables.Flyweight;
                        E : in out Element_Access) return Refcounted_Element_Ref
     with Inline;

   function Make_Ptr (R : Refcounted_Element_Ref'Class)
                      return Refcounted_Element_Ptr
     with Inline;

   function Make_Ref (P : Refcounted_Element_Ptr'Class)
                      return Refcounted_Element_Ref
     with Inline, Pre => (Get(P) /= null);

private

   type Flyweight_Ptr is access all Flyweight_Hashtables.Flyweight;

   type Refcounted_Element_Ptr is
     new Ada.Finalization.Controlled with
      record
         E : Element_Access := null;
         Containing_Flyweight : Flyweight_Ptr := null;
         Containing_Bucket : Ada.Containers.Hash_Type;
      end record;

   overriding procedure Adjust (Object : in out Refcounted_Element_Ptr);
   overriding procedure Finalize (Object : in out Refcounted_Element_Ptr);

   type Refcounted_Element_Ref (E : access Element) is
     new Ada.Finalization.Controlled with
      record
         Containing_Flyweight : Flyweight_Ptr := null;
         Containing_Bucket : Ada.Containers.Hash_Type;
      end record;

   overriding procedure Initialize (Object : in out Refcounted_Element_Ref);
   overriding procedure Adjust (Object : in out Refcounted_Element_Ref);
   overriding procedure Finalize (Object : in out Refcounted_Element_Ref);

end Flyweights_Refcount_Ptrs;
