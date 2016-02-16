-- unique_ptrs.adb
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

with Ada.Unchecked_Deallocation;

package body Unique_Ptrs is

   procedure Deallocate_T is new Ada.Unchecked_Deallocation
     (Object => T,
      Name   => T_Ptr);

   ---------
   -- Get --
   ---------

   function Get (U : in Unique_Ptr) return T_Ptr is
      (U.E);

   ---------------------
   -- Make_Unique_Ptr --
   ---------------------

   function Make_Unique_Ptr (X : T_Ptr) return Unique_Ptr is
   begin
      if X = null then
         raise Unique_Ptr_Error with "Cannot create null Unique_Ptr";
      end if;
      return Unique_Ptr'(Ada.Finalization.Limited_Controlled with
                           Element => X,
                         E => X,
                         Finalized => False);
   end;

   ----------------
   -- Initialize --
   ----------------

   overriding procedure Initialize (Object : in out Unique_Ptr) is
   begin
      if Object.Element = null then
         raise Unique_Ptr_Error with "Cannot create null Unique_Ptr";
      elsif Object.E = null then
         raise Unique_Ptr_Error
           with "Unique_Ptr should be created via Make_Unique_Ptr only";
      end if;
   end Initialize;

   --------------
   -- Finalize --
   --------------

   overriding procedure Finalize (Object : in out Unique_Ptr) is
   begin
      if not Object.Finalized then
         Object.Finalized := True;
         Delete (Object.Element.all);
         Deallocate_T (Object.E);
      end if;
   end Finalize;

end Unique_Ptrs;
