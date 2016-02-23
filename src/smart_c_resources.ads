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

   function Make_Smart_T (X : in T) return Smart_T with Inline;
   function Element (S : in Smart_T) return T with Inline;
   function Use_Count (S : in Smart_T) return Natural with Inline;
   function Unique (S : in Smart_T) return Boolean is
      (Use_Count(S) = 1);

   type Smart_T_No_Default(<>) is new Smart_T with private;

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
