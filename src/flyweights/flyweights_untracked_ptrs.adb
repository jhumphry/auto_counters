-- flyweights_untracked_ptrs.adb
-- A package of generalised references which point to resources inside a
-- Flyweight without tracking or releasing those resources

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

with Ada.Unchecked_Conversion;

package body Flyweights_Untracked_Ptrs is

   type Access_Element is access all Element;

   function Access_Element_To_Element_Access is
     new Ada.Unchecked_Conversion(Source => Access_Element,
                                  Target => Element_Access);

   subtype Hash_Type is Ada.Containers.Hash_Type;
   use type Ada.Containers.Hash_Type;

   ---------------------------
   -- Untracked_Element_Ptr --
   ---------------------------

   function Get (P : Untracked_Element_Ptr) return Element_Access is
     (P.E);

   function Make_Ref (P : Untracked_Element_Ptr'Class)
                      return Untracked_Element_Ref is
   begin
      if P.E /= null then
         return Untracked_Element_Ref'(E => P.E,
                                       Containing_Flyweight => P.Containing_Flyweight,
                                       Containing_Bucket    => P.Containing_Bucket);
      else
         raise Program_Error with "Attempting to make a Untracked_Element_Ref "&
           "from a null Untracked_Element_Ptr";
      end if;
   end Make_Ref;

   function Insert_Ptr (F : aliased in out Flyweight_Hashtables.Flyweight;
                        E : in out Element_Access) return Untracked_Element_Ptr is
      Bucket : Hash_Type ;
   begin

      Flyweight_Hashtables.Insert (F => F,
                                   Bucket => Bucket,
                                   Data_Ptr => E);
      return Untracked_Element_Ptr'(E => E,
                                    Containing_Flyweight => F'Access,
                                    Containing_Bucket    => Bucket);
   end Insert_Ptr;

   ---------------------------
   -- Untracked_Element_Ref --
   ---------------------------

   function Make_Ptr (R : Untracked_Element_Ref'Class)
                      return Untracked_Element_Ptr is
   begin
      return Untracked_Element_Ptr'(E                    => Access_Element_To_Element_Access(R.E),
                                    Containing_Flyweight => R.Containing_Flyweight,
                                    Containing_Bucket    => R.Containing_Bucket);
   end Make_Ptr;

   function Insert_Ref (F : aliased in out Flyweight_Hashtables.Flyweight;
                        E : in out Element_Access) return Untracked_Element_Ref is
      Bucket : Hash_Type ;
   begin

      Flyweight_Hashtables.Insert (F => F,
                                   Bucket => Bucket,
                                   Data_Ptr => E);
      return Untracked_Element_Ref'(E => E,
                                    Containing_Flyweight => F'Access,
                                    Containing_Bucket    => Bucket);
   end Insert_Ref;

end Flyweights_Untracked_Ptrs;
