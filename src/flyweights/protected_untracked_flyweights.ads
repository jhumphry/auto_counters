-- protected_untracked_flyweights.ads
-- A package for ensuring resources are not duplicated in a manner similar
-- to the C++ Boost flyweight classes. This package provides a task-safe
-- implementation that does not track usage so does not release resources when
-- the last reference is released

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

with Flyweights_Untracked_Lists;
with Flyweights_Protected_Hashtables;
with Flyweights_Untracked_Ptrs;

generic
   type Element(<>) is limited private;
   type Element_Access is access Element;
   with function Hash (E : Element) return Ada.Containers.Hash_Type;
   Capacity : Ada.Containers.Hash_Type := 256;
   with function "=" (Left, Right : in Element) return Boolean is <>;
package Protected_Untracked_Flyweights is

   package Lists is
     new Flyweights_Untracked_Lists(Element        => Element,
                                    Element_Access => Element_Access,
                                    "="            => "=");

   package Hashtables is
     new Flyweights_Protected_Hashtables(Element        => Element,
                                         Element_Access => Element_Access,
                                         Hash           => Hash,
                                         Lists_Spec     => Lists.Lists_Spec,
                                         Capacity       => Capacity);

   package Ptrs is
     new Flyweights_Untracked_Ptrs(Element              => Element,
                                   Element_Access       => Element_Access,
                                   Flyweight_Hashtables => Hashtables.Hashtables_Spec);

   subtype Flyweight is Hashtables.Flyweight;

   subtype Element_Ptr is Ptrs.Untracked_Element_Ptr;

   subtype Element_Ref is Ptrs.Untracked_Element_Ref;

   function Get (P : Ptrs.Untracked_Element_Ptr) return Element_Access
                 renames Ptrs.Get;

   function Make_Ref (P : Ptrs.Untracked_Element_Ptr'Class)
                      return Ptrs.Untracked_Element_Ref
                      renames Ptrs.Make_Ref;

   function Insert_Ptr (F : aliased in out Hashtables.Flyweight;
                        E : in out Element_Access)
                        return Ptrs.Untracked_Element_Ptr
                        renames Ptrs.Insert_Ptr;

   function Make_Ptr (R : Ptrs.Untracked_Element_Ref'Class)
                      return Ptrs.Untracked_Element_Ptr
                      renames Ptrs.Make_Ptr;

   function Insert_Ref (F : aliased in out Hashtables.Flyweight;
                        E : in out Element_Access)
                        return Ptrs.Untracked_Element_Ref
                        renames Ptrs.Insert_Ref;

   -- Note - ideally Insert_Ptr and Insert_Ref could both be overloadings of
   -- Insert. However this seems to cause problems for GNAT GPL 2015 so for now
   -- the type is suffixed to the name.

end Protected_Untracked_Flyweights;
