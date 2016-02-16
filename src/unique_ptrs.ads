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

   Unique_Ptr_Error : exception;

   type Unique_Ptr(Element : not null access T) is
     new Ada.Finalization.Limited_Controlled with private
   with Implicit_Dereference => Element;

   function Get (U : in Unique_Ptr) return T_Ptr with Inline;

   function Make_Unique_Ptr (X : T_Ptr) return Unique_Ptr with Inline;

private

   type Unique_Ptr(Element : not null access T) is
     new Ada.Finalization.Limited_Controlled
     with
      record
         Invalid : Boolean := True;
      end record;

   overriding procedure Initialize (Object : in out Unique_Ptr);
   overriding procedure Finalize (Object : in out Unique_Ptr);

end Unique_Ptrs;
