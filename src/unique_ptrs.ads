-- unique_ptrs.ads
-- A "unique pointer" type similar to that in C++

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

with Ada.Finalization;

generic
   type T (<>) is limited private;
   with procedure Delete (X : in out T) is null;
package Unique_Ptrs is

   type T_Ptr is access T;
   subtype T_Ptr_Not_Null is not null T_Ptr;

   type T_Const_Ptr is access constant T;

   Unique_Ptr_Error : exception;
   -- Unique_Ptr_Error indicates an attempt to create a null Unique_Ptr or an
   -- attempt to create one directly without going through the Make_Unique_Ptr
   -- function.

   type Unique_Ptr(Element : not null access T) is
     new Ada.Finalization.Limited_Controlled with private
   with Implicit_Dereference => Element;
   -- Unique_Ptr is an implementation of a generalised reference type that
   -- automatically releases the storage associated with the underlying value
   -- when the Unique_Ptr is destroyed. Unique_Ptr can only point to values
   -- created in a storage pool, not static values or local stack values.

   function Get (U : in Unique_Ptr) return T_Ptr with Inline;
   -- Returns a named access value that points to the target of the Unique_Ptr.
   -- This should not be saved as it can become invalid without warning when
   -- the original Unique_Ptr is destroyed. In particular do not attempt to
   -- duplicate Unique_Ptr by passing the result to Make_Unique_Ptr as the
   -- result will be erroneous.

   function Make_Unique_Ptr (X : T_Ptr_Not_Null) return Unique_Ptr with Inline;
   -- Make_Unique_Ptr creates a Unique_Ptr from an access value to an object
   -- stored in a pool. Note that mixing the use of regular access values and
   -- Unique_Ptr types is not wise, as the storage may be reclaimed when the
   -- Unique_Ptr is destroyed, leaving the access values invalid.

   type Unique_Const_Ptr(Element : not null access constant T) is
     new Ada.Finalization.Limited_Controlled with private
   with Implicit_Dereference => Element;
   -- Unique_Const_Ptr is an implementation of a generalised reference type
   -- that automatically releases the storage associated with the underlying
   -- constant value when the Unique_Ptr is destroyed. Unique_Const_Ptr can
   -- only point to values created in a storage pool, not static values or
   -- local stack values.

   function Get (U : in Unique_Const_Ptr) return T_Const_Ptr with Inline;
   -- Returns a named access to constant value that points to the target of the
   -- Unique_Const_Ptr. This should not be saved as it can become invalid
   -- without warning when the original Unique_Const_Ptr is destroyed.

   function Make_Unique_Const_Ptr (X : T_Ptr_Not_Null)
                                   return Unique_Const_Ptr with Inline;
   -- Make_Unique_Const_Ptr creates a Unique_Const_Ptr from an access value to
   -- an object stored in a pool. Note that mixing the use of regular access
   -- values and Unique_Const_Ptr types is not wise, as the storage may be
   -- reclaimed when the Unique_Const_Ptr is destroyed, leaving the access
   -- values invalid.
   --
   -- Unique_Const_Ptr differs from a regular access-to-const type in that
   -- it must be able to call the Delete function and destroy the storage
   -- associated with the target. Therefore they can only point at variables,
   -- not constants.

private

   type Unique_Ptr(Element : not null access T) is
     new Ada.Finalization.Limited_Controlled
     with
      record
         Invalid : Boolean := True;
      end record;

   overriding procedure Initialize (Object : in out Unique_Ptr);
   overriding procedure Finalize (Object : in out Unique_Ptr);

   type Unique_Const_Ptr(Element : not null access constant T) is
     new Ada.Finalization.Limited_Controlled
     with
      record
         Invalid : Boolean := True;
      end record;

   overriding procedure Initialize (Object : in out Unique_Const_Ptr);
   overriding procedure Finalize (Object : in out Unique_Const_Ptr);

end Unique_Ptrs;
