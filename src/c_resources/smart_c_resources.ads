-- smart_c_resources.ads
-- A reference counting package to wrap a C type that requires initialization
-- and finalization.

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
   type T is private;
   with function Initialize return T;
   with procedure Finalize (X : in T);
   with package Counters is new Counters_Spec (others => <>);
package Smart_C_Resources is

   type Smart_T is new Ada.Finalization.Controlled with private;
   -- Smart_T wraps a type T which is anticipated to be a pointer to an opaque
   -- struct provided by a library written in C. Typically it is necessary
   -- to call library routines to initialize the underlying resources and to
   -- release them when no longer required. Smart_T ensures this is done in a
   -- reference counted manner so the resources will only be released when the
   -- last Smart_T is destroyed.

   function Make_Smart_T (X : in T) return Smart_T with Inline;
   -- Usually a Smart_T will be default initialized with the function used
   -- to instantiate the package in the formal parameter Initialize. The
   -- Make_Smart_T function can be used where an explicit initialization
   -- is preferred.

   function Element (S : in Smart_T) return T with Inline;
   -- Element returns the underlying value of the Smart_T representing the
   -- resources managed by the C library.

   function Use_Count (S : in Smart_T) return Natural with Inline;
   -- Use_Count returns the number of Smart_T in existence for a given C
   -- resource.

   function Unique (S : in Smart_T) return Boolean is
      (Use_Count(S) = 1);
   -- Unique tests whether a Smart_T is the only one in existence for a given
   -- C resource. If it is, then the resource will be freed when the Smart_T
   -- is destroyed.

   type Smart_T_No_Default(<>) is new Smart_T with private;
   -- Smart_T_No_Default manages a C resource that requires initialization and
   -- finalization just as Smart_T does, except that no default initialization
   -- is felt to be appropriate so values must always be made with Make_Smart_T.

private

   use Counters;

   type Smart_T is new Ada.Finalization.Controlled with
      record
         Element : T;
         Counter : Counter_Ptr;
      end record
     with Type_Invariant => Valid (Smart_T);

   function Valid (S : Smart_T) return Boolean is
     (S.Counter /= null and then Use_Count(S.Counter.all) > 0)
   with Inline;

   overriding procedure Initialize (Object : in out Smart_T) with Inline;
   overriding procedure Adjust (Object : in out Smart_T) with Inline;
   overriding procedure Finalize (Object : in out Smart_T) with Inline;

   type Smart_T_No_Default is new Smart_T with null record;

end Smart_C_Resources;
