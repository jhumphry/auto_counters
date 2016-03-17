-- basic_refcounted_kvflyweights.ads
-- A package for ensuring resources are not duplicated in a manner similar
-- to the C++ Boost flyweight classes. This package provides a non-task-safe
-- implementation that uses reference counting to release resources when the
-- last reference is released. Resources are associated with a key that can
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

with KVFlyweights.Refcounted_Lists;
with KVFlyweights.Basic_Hashtables;
with KVFlyweights.Refcounted_Ptrs;

generic
   type Key(<>) is private;
   type Value(<>) is limited private;
   type Value_Access is access Value;
   with function Factory (K : in Key) return Value_Access;
   with function Hash (K : in Key) return Ada.Containers.Hash_Type;
   Capacity : Ada.Containers.Hash_Type := 256;
   with function "=" (Left, Right : in Key) return Boolean is <>;
package Basic_Refcounted_KVFlyweights is

   type Key_Access is access Key;

   package Lists is
     new KVFlyweights.Refcounted_Lists(Key          => Key,
                                     Key_Access   => Key_Access,
                                     Value        => Value,
                                     Value_Access => Value_Access,
                                     Factory      => Factory,
                                     "="          => "=");

   package Hashtables is
     new KVFlyweights.Basic_Hashtables(Key          => Key,
                                       Key_Access   => Key_Access,
                                       Value        => Value,
                                       Value_Access => Value_Access,
                                       Hash         => Hash,
                                       KVLists_Spec => Lists.Lists_Spec,
                                       Capacity     => Capacity);

   package Ptrs is
     new KVFlyweights.Refcounted_Ptrs(Key                    => Key,
                                    Key_Access             => Key_Access,
                                    Value                  => Value,
                                    Value_Access           => Value_Access,
                                    KVFlyweight_Hashtables => Hashtables.Hashtables_Spec);

   subtype KVFlyweight is Hashtables.KVFlyweight;
   -- This KVFlyweight type is an implementation of the key-value flyweight
   -- pattern, which helps prevent the resource usage caused by the storage of
   -- duplicate values. Reference counting is used to release resources when
   -- they are no longer required. This implementation is not protected so it is
   -- not safe to use if multiple tasks could attempt to add or remove resources
   -- simultaneously.

   subtype V_Ref is Ptrs.V_Ref;
   -- This is a generic generalised reference type which is used to make
   -- Value_Ptr easier to use and which should not be stored or reused.

   subtype Value_Ptr is Ptrs.Refcounted_Value_Ptr;
   -- The Value_Ptr type points to a resource inside a Flyweight. It is
   -- reference-counted (shared with Value_Ref) so that when the last Value_Ptr
   -- or Value_Ref pointing to a resource is destroyed, the resource will be
   -- deallocated as well. The 'Get' function returns an access value to the
   -- resource.

   use type Ptrs.Refcounted_Value_Ptr;

   subtype Value_Ref is Ptrs.Refcounted_Value_Ref;
   -- The Value_Ref type points to a resource inside a Flyweight. It is
   -- reference-counted (shared with Value_Ptr) so that when the last Value_Ptr
   -- or Value_Ref pointing to a resource is destroyed, the resource will be
   -- deallocated as well. The Value_Ref type can be implicitly derefenced to
   -- return the resource.

   use type Ptrs.Refcounted_Value_Ref;

   function P (P : Ptrs.Refcounted_Value_Ptr) return V_Ref
               renames Ptrs.P;
   -- P returns an V_Ref which is a generalised reference to the stored value.
   -- This is an alternative to calling the Get function and dereferencing the
   -- access value returned with '.all'.

   function Get (P : Ptrs.Refcounted_Value_Ptr) return Value_Access
                 renames Ptrs.Get;
   -- Get returns an access value that points to a resource inside a Flyweight.

   function Get (P : Ptrs.Refcounted_Value_Ref) return Value_Access
                 renames Ptrs.Get;
   -- Get returns an access value that points to a resource inside a Flyweight.

   function Make_Ref (P : Ptrs.Refcounted_Value_Ptr'Class)
                      return Ptrs.Refcounted_Value_Ref
                      renames Ptrs.Make_Ref;
   -- Make_Ref converts a Refcounted_Value_Ptr into a Refcounted_Value_Ref.

   function Insert_Ptr (F : aliased in out Hashtables.KVFlyweight;
                        K : in Key)
                        return Ptrs.Refcounted_Value_Ptr
                        renames Ptrs.Insert_Ptr;
   -- Insert_Ref looks to see if the Key K already exists inside the KVFlyweight
   -- F. If not, F makes a new value from K using the specified Factory function
   -- and stores it for future use. A Refcounted_Value_Ptr is returned.

   function Make_Ptr (R : Ptrs.Refcounted_Value_Ref'Class)
                      return Ptrs.Refcounted_Value_Ptr
                      renames Ptrs.Make_Ptr;
   -- Make_Ref converts a Refcounted_Value_Ref into a Refcounted_Value_Ptr.

   function Insert_Ref (F : aliased in out Hashtables.KVFlyweight;
                        K : in Key)
                        return Ptrs.Refcounted_Value_Ref
                        renames Ptrs.Insert_Ref;
   -- Insert_Ref looks to see if the Key K already exists inside the KVFlyweight
   -- F. If not, F makes a new value from K using the specified Factory function
   -- and stores it for future use. A Refcounted_Value_Ref is returned.

   -- Note - ideally Insert_Ptr and Insert_Ref could both be overloadings of
   -- Insert. However this seems to cause problems for GNAT GPL 2015 so for now
   -- the type is suffixed to the name.

end Basic_Refcounted_KVFlyweights;
