-- protected_refcount_flyweights.ads
-- A package for ensuring resources are not duplicated in a manner similar
-- to the C++ Boost flyweight classes. This package provides a task-safe
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
with Flyweights_Protected_Hashtables;
with Flyweights_Refcount_Ptrs;

generic
   type Element(<>) is limited private;
   type Element_Access is access Element;
   with function Hash (E : Element) return Ada.Containers.Hash_Type;
   Capacity : Ada.Containers.Hash_Type := 256;
   with function "=" (Left, Right : in Element) return Boolean is <>;
package Protected_Refcount_Flyweights is

   package Lists is
     new Flyweights_Refcount_Lists(Element        => Element,
                                   Element_Access => Element_Access,
                                   "="            => "=");

   package Hashtables is
     new Flyweights_Protected_Hashtables(Element        => Element,
                                         Element_Access => Element_Access,
                                         Hash           => Hash,
                                         Lists_Spec     => Lists.Lists_Spec,
                                         Capacity       => Capacity);

   package Ptrs is
     new Flyweights_Refcount_Ptrs(Element              => Element,
                                  Element_Access       => Element_Access,
                                  Flyweight_Hashtables => Hashtables.Hashtables_Spec);

   subtype Flyweight is Hashtables.Flyweight;
   -- This Flyweight type is an implementation of the flyweight pattern, which
   -- helps prevent the resource usage caused by the storage of duplicate
   -- values. Reference counting is used to release resources when they are
   -- no longer required. This implementation is protected so it is safe to
   -- use even if multiple tasks could attempt to add or remove resources
   -- simultaneously.

   subtype E_Ref is Ptrs.E_Ref;
   -- This is a generic generalised reference type which is used to make
   -- Element_Ptr easier to use and which should not be stored or reused.

   subtype Element_Ptr is Ptrs.Refcounted_Element_Ptr;
   -- The Element_Ptr type points to a resource inside a Flyweight. It is
   -- reference-counted (shared with Element_Ref) so that when the last
   -- Element_Ptr or Element_Ref pointing to a resource is destroyed, the
   -- resource will be deallocated as well. The 'Get' function returns an
   -- access value to the resource.

   subtype Element_Ref is Ptrs.Refcounted_Element_Ref;
   -- The Element_Ref type points to a resource inside a Flyweight. It is
   -- reference-counted (shared with Element_Ptr) so that when the last
   -- Element_Ptr or Element_Ref pointing to a resource is destroyed, the
   -- resource will be deallocated as well. The Element_Ref type can be
   -- implicitly derefenced to return the resource.

   function P (P : Ptrs.Refcounted_Element_Ptr) return E_Ref
               renames Ptrs.P;
   -- P returns an E_Ref which is a generalised reference to the stored value.
   -- This is an alternative to calling the Get function and dereferencing the
   -- access value returned with '.all'.

   function Get (P : Ptrs.Refcounted_Element_Ptr) return Element_Access
                 renames Ptrs.Get;
   -- Get returns an access value that points to a resource inside a
   -- Flyweight.

   function Make_Ref (P : Ptrs.Refcounted_Element_Ptr'Class)
                      return Ptrs.Refcounted_Element_Ref
                      renames Ptrs.Make_Ref;
   -- Make_Ref converts a Refcounted_Element_Ptr into a Refcounted_Element_Ref.

   function Insert_Ptr (F : aliased in out Hashtables.Flyweight;
                        E : in out Element_Access)
                        return Ptrs.Refcounted_Element_Ptr
                        renames Ptrs.Insert_Ptr;
   -- Insert_Ptr looks to see if the Element pointed to by E already exists
   -- inside the Flyweight F. If so, the Element pointed to by E is deallocated
   -- and E is set to the existing copy. Otherwise, F stores E for future use. A
   -- Refcounted_Element_Ptr is returned.

   function Make_Ptr (R : Ptrs.Refcounted_Element_Ref'Class)
                      return Ptrs.Refcounted_Element_Ptr
                      renames Ptrs.Make_Ptr;
   -- Make_Ref converts a Refcounted_Element_Ref into a Refcounted_Element_Ptr.

   function Insert_Ref (F : aliased in out Hashtables.Flyweight;
                        E : in out Element_Access)
                        return Ptrs.Refcounted_Element_Ref
                        renames Ptrs.Insert_Ref;
   -- Insert_Ref looks to see if the Element pointed to by E already exists
   -- inside the Flyweight F. If so, the Element pointed to by E is deallocated
   -- and E is set to the existing copy. Otherwise, F stores E for future use. A
   -- Refcounted_Element_Ref is returned.

   -- Note - ideally Insert_Ptr and Insert_Ref could both be overloadings of
   -- Insert. However this seems to cause problems for GNAT GPL 2015 so for now
   -- the type is suffixed to the name.

end Protected_Refcount_Flyweights;
