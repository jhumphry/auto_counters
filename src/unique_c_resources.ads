-- unique_c_resources.ads
-- A convenience package to wrap a C type that requires initialization and
-- finalization.

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
   type T is private;
   with function Initialize return T;
   with procedure Finalize (X : in T);
package Unique_C_Resources is

   type Unique_T is new Ada.Finalization.Limited_Controlled with private;
   -- Unique_T wraps a type T which is anticipated to be a pointer to an opaque
   -- struct provided by a library written in C. Typically it is necessary
   -- to call library routines to initialize the underlying resources and to
   -- release them when no longer required. Unique_T ensures that it is the only
   -- holder of the resources so they are freed when the Unique_T is destroyed.

   function Make_Unique_T (X : in T) return Unique_T with Inline;
   -- Usually a Unique_T will be default initialized with the function used
   -- to instantiate the package in the formal parameter Initialize. The
   -- Make_Unique_T function can be used where an explicit initialization
   -- is preferred.

   function Element (U : Unique_T) return T with Inline;
   -- Element returns the underlying value of the Unique_T representing the
   -- resources managed by the C library.

   type Unique_T_No_Default(<>) is new Unique_T with private;
   -- Unique_T_No_Default manages a C resource that requires initialization and
   -- finalization just as Unique_T does, except that no default initialization
   -- is felt to be appropriate so values must always be made with
   -- Make_Unique_T.

private

   type Unique_T is new Ada.Finalization.Limited_Controlled with
      record
         Element : T;
      end record;

   overriding procedure Initialize (Object : in out Unique_T) with Inline;
   overriding procedure Finalize (Object : in out Unique_T) with Inline;

   type Unique_T_No_Default is new Unique_T with null record;

end Unique_C_Resources;
