-- basic_refcount_flyweights.ads
-- A package for ensuring resources are not duplicated in a manner similar
-- to the C++ Boost flyweight classes. This package provides a non-task-safe
-- implementation that uses reference counting to release resources when the
-- last reference is released

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

with Flyweights_Refcount_Lists;
with Flyweights_Basic_Hashtables;
with Flyweights_Refcount_Ptrs;

generic
   type Element(<>) is limited private;
   type Element_Access is access Element;
   with function Hash (E : Element) return Ada.Containers.Hash_Type;
   Capacity : Ada.Containers.Hash_Type := 256;
   with function "=" (Left, Right : in Element) return Boolean is <>;
package Basic_Refcount_Flyweights is

   package Lists is
     new Flyweights_Refcount_Lists(Element        => Element,
                                   Element_Access => Element_Access,
                                   "="            => "=");

   package Hashtables is
     new Flyweights_Basic_Hashtables(Element        => Element,
                                     Element_Access => Element_Access,
                                     Hash           => Hash,
                                     Lists_Spec     => Lists.Lists_Spec,
                                     Capacity       => Capacity);

   package Ptrs is
     new Flyweights_Refcount_Ptrs(Element              => Element,
                                  Element_Access       => Element_Access,
                                  Flyweight_Hashtables => Hashtables.Hashtables_Spec);

   subtype Flyweight is Hashtables.Flyweight;
   subtype Refcounted_Element_Ref is Ptrs.Refcounted_Element_Ref;

   function Insert (F : aliased in out Hashtables.Flyweight;
                    E : in out Element_Access) return Ptrs.Refcounted_Element_Ref
     renames Ptrs.Insert;

end Basic_Refcount_Flyweights;