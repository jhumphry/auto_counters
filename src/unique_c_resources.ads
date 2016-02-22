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

   function Element (U : Unique_T) return T with Inline;

private

   type Unique_T is new Ada.Finalization.Limited_Controlled with
      record
         Element : T;
      end record;

   overriding procedure Initialize (Object : in out Unique_T) with Inline;
   overriding procedure Finalize (Object : in out Unique_T) with Inline;

end Unique_C_Resources;