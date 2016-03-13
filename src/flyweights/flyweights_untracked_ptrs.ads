-- flyweights_untracked_ptrs.ads
-- A package of generalised references which point to resources inside a
-- Flyweight without tracking or releasing those resources

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

with Flyweights_Hashtables_Spec;

generic
   type Element(<>) is limited private;
   type Element_Access is access Element;
   with package Flyweight_Hashtables is
     new Flyweights_Hashtables_Spec(Element_Access => Element_Access,
                                    others => <>);
package Flyweights_Untracked_Ptrs is

   type E_Ref(E : access Element) is null record
     with Implicit_Dereference => E;

   type Untracked_Element_Ptr is tagged private;

   function P (P : Untracked_Element_Ptr) return E_Ref
     with Inline;

   function Get (P : Untracked_Element_Ptr) return Element_Access
     with Inline;

   function Insert_Ptr (F : aliased in out Flyweight_Hashtables.Flyweight;
                        E : in out Element_Access) return Untracked_Element_Ptr
     with Inline;

   type Untracked_Element_Ref (E : access Element) is tagged private
         with Implicit_Dereference => E;

   function Get (P : Untracked_Element_Ref) return Element_Access
     with Inline;

   function Insert_Ref (F : aliased in out Flyweight_Hashtables.Flyweight;
                        E : in out Element_Access) return Untracked_Element_Ref
     with Inline;

   function Make_Ptr (R : Untracked_Element_Ref'Class)
                      return Untracked_Element_Ptr
     with Inline;

   function Make_Ref (P : Untracked_Element_Ptr'Class)
                      return Untracked_Element_Ref
     with Inline, Pre => (Get(P) /= null);

private

   type Flyweight_Ptr is access all Flyweight_Hashtables.Flyweight;

   type Untracked_Element_Ptr is tagged
      record
         E : Element_Access := null;
         Containing_Flyweight : Flyweight_Ptr := null;
         Containing_Bucket : Ada.Containers.Hash_Type;
      end record;

   type Untracked_Element_Ref (E : access Element) is tagged
      record
         Containing_Flyweight : Flyweight_Ptr := null;
         Containing_Bucket : Ada.Containers.Hash_Type;
      end record;

end Flyweights_Untracked_Ptrs;
