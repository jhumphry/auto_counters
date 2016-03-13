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

pragma Profile (No_Implementation_Extensions);

with Ada.Finalization;

with Counters_Spec;

generic
   type T (<>) is limited private;
   type T_Ptr is access T;
   with package Counters is new Counters_Spec(others => <>);
   with procedure Delete (X : in out T) is null;
package Smart_Ptrs is

   type T_Ref (Element : access T) is null record with
      Implicit_Dereference => Element;

   Smart_Ptr_Error : exception;
   -- Smart_Ptr_Error indicates an attempt to carry out an erroneous operation
   -- such as creating a Weak_Ptr from a null Smart_Ptr, or that internal
   -- corruption has been detected.

   type Smart_Ptr is new Ada.Finalization.Controlled with private;
   -- Smart_Ptr is an implementation of a reference-counted pointer type that
   -- automatically releases the storage associated with the underlying value
   -- when the last Smart_Ptr that points to it is destroyed. Smart_Ptr can
   -- only point to values created in a storage pool, not static values or local
   -- stack values. Smart_Ptr can also be null. A Smart_Ptr created without
   -- initialization will be null.

   function P (S : in Smart_Ptr) return T_Ref with Inline;
   -- Returns a generalised reference type that points to the target of the
   -- Smart_Ptr.

   function Get (S : in Smart_Ptr) return T_Ptr with Inline;
   -- Returns an access value that points to the target of the Smart_Ptr.
   -- This should not be saved as it can become invalid without warning if all
   -- Smart_Ptr values are destroyed and the underlying storage reclaimed. In
   -- particular do not attempt to duplicate Smart_Ptr by passing the result
   -- to Make_Smart_Ptr.

   function Make_Smart_Ptr (X : T_Ptr) return Smart_Ptr with Inline;
   -- Make_Smart_Ptr creates a Smart_Ptr from an access value to an object
   -- stored in a pool. Null can also be passed. Note that mixing the use of
   -- regular access values and Smart_Ptr types is not wise, as the storage may
   -- be reclaimed when all Smart_Ptr values are destroyed, leaving the access
   -- values invalid.

   type Smart_Ref;

   function Make_Smart_Ptr (S : Smart_Ref) return Smart_Ptr with Inline;
   -- Make_Smart_Ptr creates a Smart_Ptr from an existing Smart_Ref. It will
   -- share the reference counters with the Smart_Ref so the two types can be
   -- used together.

   function Use_Count (S : in Smart_Ptr) return Natural with Inline;
   -- Returns the number of Smart_Ptr and Smart_Ref currently pointing to the
   -- object.

   function Unique (S : in Smart_Ptr) return Boolean is (Use_Count (S) = 1);
   -- Returns True if this is the only Smart_Ptr pointing to the object.

   function Weak_Ptr_Count (S : in Smart_Ptr) return Natural with Inline;
   -- Returns the number of Weak_Ptr currently pointing to the object.

   function Is_Null (S : in Smart_Ptr) return Boolean with Inline;
   -- Returns True if this is a null Smart_Ptr.

   Null_Smart_Ptr : constant Smart_Ptr;
   -- A constant that can be used to set a Smart_Ptr to null (and release the
   -- associated target's storage if it was the last Smart_Ptr pointing to it).

   type Smart_Ref (Element : not null access T) is
     new Ada.Finalization.Controlled with private
       with Implicit_Dereference => Element;
   -- Smart_Ref is an implementation of a reference-counted reference type that
   -- automatically releases the storage associated with the underlying value
   -- when the last Smart_Ref that points to it is destroyed. Smart_Ref can
   -- only point to values created in a storage pool, not static values or local
   -- stack values. A Smart_Ref cannot be null.

   function Get (S : in Smart_Ref) return T_Ptr with Inline;
   -- Returns an access value that points to the target of the Smart_Ref.
   -- This should not be saved as it can become invalid without warning if all
   -- Smart_Ref values are destroyed and the underlying storage reclaimed. In
   -- particular do not attempt to duplicate Smart_Ref by passing the result
   -- to Make_Smart_Ptr.

   function Make_Smart_Ref (X : T_Ptr) return Smart_Ref
     with Inline, Pre => (X /= null);
   -- Make_Smart_Ref creates a Smart_Ref from an access value to an object
   -- stored in a pool. Note that mixing the use of regular access values and
   -- Smart_Ptr types is not wise, as the storage may be reclaimed when all
   -- Smart_Ptr values are destroyed, leaving the access values invalid.
   -- Smart_Ref cannot be null, so if null is passed a Smart_Ptr_Error will
   -- be raised.

   function Make_Smart_Ref (S : Smart_Ptr'Class) return Smart_Ref
     with Inline, Pre => (not Is_Null(S));
   -- Make_Smart_Ptr creates a Smart_Ptr from an existing Smart_Ref. It will
   -- share the reference counters with the Smart_Ref so the two types can be
   -- used together. Note that while Smart_Ptr can be null, Smart_Ref cannot,
   -- so Smart_Ptr_Error will be raised if you try to create a Smart_Ref from
   -- a null Smart_Ptr.

   function Use_Count (S : in Smart_Ref) return Natural with Inline;
   -- Use_Count gives the number of Smart_Ptr and Smart_Ref pointing to the same
   -- target.

   function Unique (S : in Smart_Ref) return Boolean is (Use_Count (S) = 1);
   -- Returns True if this is the only Smart_Ref pointing to the object.

   function Weak_Ptr_Count (S : in Smart_Ref) return Natural with Inline;
   -- Returns the number of Weak_Ptr currently pointing to the object.

   type Weak_Ptr (<>) is new Ada.Finalization.Controlled with private;
   -- The Weak_Ptr type is a companion to a (non-null) Smart_Ptr. It can be used
   -- to recreate a Smart_Ptr providing the target object still exists, but it
   -- does not prevent the release of storage associated with the target if all
   -- of the associated Smart_Ptr have been destroyed.

   function Make_Weak_Ptr (S : in Smart_Ptr'Class) return Weak_Ptr
     with Inline, Pre => (not Is_Null(S));
   -- Make_Weak_Ptr makes a Weak_Ptr from a non-null Smart_Ptr.

   function Make_Weak_Ptr (S : in Smart_Ref'Class) return Weak_Ptr with Inline;
   -- Make_Weak_Ptr makes a Weak_Ptr from a Smart_Ref.

   function Use_Count (W : in Weak_Ptr) return Natural with Inline;
   -- Use_Count gives the number of Smart_Ptr and Smart_Ref pointing to the same
   -- target.

   function Weak_Ptr_Count (W : in Weak_Ptr) return Natural with Inline;
   -- Returns the number of Weak_Ptr currently pointing to the object.

   function Expired (W : in Weak_Ptr) return Boolean with Inline;
   -- Indicates if the target of the Weak_Ptr no longer exists because all
   -- associated Smart_Ptr have been released.

   function Lock (W : in Weak_Ptr'Class) return Smart_Ptr;
   -- If the target of the Weak_Ptr has not been destroyed, return a Smart_Ptr
   -- that points to it, otherwise raise Smart_Ptr_Error.

   function Lock (W : in Weak_Ptr'Class) return Smart_Ref;
   -- If the target of the Weak_Ptr has not been destroyed, return a Smart_Ref
   -- that points to it, otherwise raise Smart_Ptr_Error.

   function Lock_Or_Null (W : in Weak_Ptr'Class) return Smart_Ptr;
   -- If the target of the Weak_Ptr has not been destroyed, return a Smart_Ptr
   -- that points to it, otherwise return Null_Smart_Ptr.

private

   use Counters;

   type Smart_Ptr is new Ada.Finalization.Controlled with
      record
         Element  : T_Ptr       := null;
         Counter  : Counter_Ptr := null;
      end record with
     Type_Invariant => Valid (Smart_Ptr);

   function Valid (S : in Smart_Ptr) return Boolean is
     (
        (S.Element = null and S.Counter = null)
      or
        ((S.Element /= null and S.Counter/=null)
         and then
           Use_Count(S.Counter.all) > 0)
     ) with Inline;

   overriding procedure Adjust (Object : in out Smart_Ptr);
   overriding procedure Finalize (Object : in out Smart_Ptr);

   Null_Smart_Ptr : constant Smart_Ptr := (Ada.Finalization.Controlled with
                                           Element  => null,
                                           Counter  => null);

   type Smart_Ref (Element : not null access T) is
     new Ada.Finalization.Controlled with
      record
         Counter : Counter_Ptr := null;
      end record with
     Type_Invariant => Valid (Smart_Ref);

   function Valid (S : in Smart_Ref) return Boolean is
     (
        (S.Counter/=null and then Use_Count(S.Counter.all) > 0)
     ) with Inline;

   overriding procedure Initialize (Object : in out Smart_Ref);
   overriding procedure Adjust (Object : in out Smart_Ref);
   overriding procedure Finalize (Object : in out Smart_Ref);

   type Weak_Ptr is new Ada.Finalization.Controlled with
      record
         Element  : T_Ptr       := null;
         Counter  : Counter_Ptr := null;
      end record with
     Type_Invariant => Valid (Weak_Ptr);

   function Valid (W : in Weak_Ptr) return Boolean is
     (
        (W.Element /= null and
           (W.Counter/=null and then Weak_Ptr_Count(W.Counter.all) > 0))
     ) with Inline;

   overriding procedure Adjust (Object : in out Weak_Ptr);
   overriding procedure Finalize (Object : in out Weak_Ptr);

end Smart_Ptrs;
