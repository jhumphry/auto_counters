-- smart_ptrs.ads
-- A reference-counted "smart pointer" type similar to that in C++

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

with Ada.Finalization;

generic
   type T (<>) is limited private;
   with procedure Delete (X : in out T) is null;
package Smart_Ptrs is

   type T_Ptr is access T;
   type T_Ref (Element : access T) is null record with
      Implicit_Dereference => Element;

   Smart_Ptr_Error : exception;
   -- Smart_Ptr_Error indicates an attempt to carry out an erroneous operation
   -- such as creating a Weak_Ptr from a null Smart_Ptr, or that internal
   -- corruption has been detected.

   type Smart_Ptr is new Ada.Finalization.Controlled with private;
   -- Smart_Ptr is an implementation of a reference-counted pointer type that
   -- automatically releases the storage associated with the underlying value
   -- when the last Smart_Ptr that points to it is destroyed. An additional
   -- procedure Delete can be passed when instantiating the package and this
   -- procedure will be called before the storage is released.
   --
   -- Smart_Ptr can only point to values created in a storage pool, not static
   -- values or local stack values. Smart_Ptr can also be null. All null
   -- Smart_Ptr act as though they were singletons - all values are
   -- equivalent. A Smart_Ptr created without initialization will be null.

   function P (S : in Smart_Ptr) return T_Ref with Inline;
   -- Returns a generalised reference type that points to the target of the
   -- Smart_Ptr.

   function Get (S : in Smart_Ptr) return T_Ptr with Inline;
   -- Returns an access value that points to the target of the Smart_Ptr. This
   -- should not be saved as it can become invalid without warning if all
   -- Smart_Ptr values are destroyed and the underlying storage reclaimed.

   function Make_Smart_Ptr (X : T_Ptr) return Smart_Ptr with Inline;
   -- Make_Smart_Ptr creates a Smart_Ptr from an access value to an object
   -- stored in a pool. Null can also be passed. Note that mixing regular access
   -- values and Smart_Ptr types is not wise as the storage may be reclaimed
   -- when all Smart_Ptr values are destroyed, leaving the access values
   -- invalid.
   --
   -- Note that if two Smart_Ptr are created using Make_Smart_Ptr they wil not
   -- share the same reference counters, and so when the first Smart_Ptr leaves
   -- its scope it will free the target's storage. The second Smart_Ptr will be
   -- left pointing erroneously to invalid storage.

   function Use_Count (S : in Smart_Ptr) return Natural with Inline;
   -- Returns the number of Smart_Ptr currently pointing to the object.

   function Unique (S : in Smart_Ptr) return Boolean is (Use_Count (S) = 1);
   -- Returns True if this is the only Smart_Ptr pointing to the object.

   function Weak_Ptr_Count (S : in Smart_Ptr) return Natural with Inline;
   -- Returns the number of Weak_Ptr currently pointing to the object.

   function Is_Null (S : in Smart_Ptr) return Boolean with Inline;
   -- Returns True if this is a null Smart_Ptr.

   Null_Smart_Ptr : constant Smart_Ptr;
   -- A constant that can be used to set a Smart_Ptr to null (and release the
   -- associated target's storage if it was the last Smart_Ptr pointing to it).

   type Weak_Ptr (<>) is new Ada.Finalization.Controlled with private;
   -- The Weak_Ptr type is a companion to a (non-null) Smart_Ptr. It can be used
   -- to recreate a Smart_Ptr providing the target object still exists, but it
   -- does not prevent the release of storage associated with the target if all
   -- of the associated Smart_Ptr have been destroyed.

   function Make_Weak_Ptr (S : in Smart_Ptr'Class) return Weak_Ptr with Inline;
   -- Make_Weak_Ptr makes a Weak_Ptr from a non-null Smart_Ptr.

   function Use_Count (W : in Weak_Ptr) return Natural with Inline;
   -- Use_Count gives the number of Smart_Ptr pointing to the same target.

   function Weak_Ptr_Count (W : in Weak_Ptr) return Natural with Inline;
   -- Returns the number of Weak_Ptr currently pointing to the object.

   function Expired (W : in Weak_Ptr) return Boolean with Inline;
   -- Indicates if the target of the Weak_Ptr no longer exists because all
   -- associated Smart_Ptr have been released.

   function Lock (W : in Weak_Ptr'Class) return Smart_Ptr;
   -- If the target of the Weak_Ptr has not been destroyed, return a Smart_Ptr
   -- that points to it.

private

   type Smart_Ptr_Counter;
   type Counter_Ptr is access Smart_Ptr_Counter;

   type Smart_Ptr is new Ada.Finalization.Controlled with
      record
         Element  : T_Ptr       := null;
         Counter  : Counter_Ptr := null;
         Null_Ptr : Boolean     := True;
      end record;

   overriding procedure Adjust (Object : in out Smart_Ptr);
   overriding procedure Finalize (Object : in out Smart_Ptr);

   function Valid (S : in Smart_Ptr) return Boolean with Inline;

   Null_Smart_Ptr : constant Smart_Ptr := (Ada.Finalization.Controlled with
                                           Element  => null,
                                           Counter  => null,
                                           Null_Ptr => True);

   type Weak_Ptr is new Ada.Finalization.Controlled with
      record
         Counter : Counter_Ptr;
      end record;

   overriding procedure Adjust (Object : in out Weak_Ptr);
   overriding procedure Finalize (Object : in out Weak_Ptr);

end Smart_Ptrs;
