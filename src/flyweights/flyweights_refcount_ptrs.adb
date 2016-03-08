-- flyweights_refcount_ptrs.adb
-- A package of reference-counting generalised references which point to
-- resources inside a Flyweight

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

package body Flyweights_Refcount_Ptrs is

   type Access_Element is access all Element;

   function Access_Element_To_Element_Access is
     new Ada.Unchecked_Conversion(Source => Access_Element,
                                  Target => Element_Access);

   subtype Hash_Type is Ada.Containers.Hash_Type;
   use type Ada.Containers.Hash_Type;

   function Insert (F : aliased in out Flyweight_Hashtables.Flyweight;
                    E : in out Element_Access) return Refcounted_Element_Ref is
      Bucket : Hash_Type ;
   begin

      Flyweight_Hashtables.Insert (F => F,
                                   Bucket => Bucket,
                                   Data_Ptr => E);
      return Refcounted_Element_Ref'(Ada.Finalization.Controlled with
                                       E => E,
                                     Containing_Flyweight => F'Access,
                                     Containing_Bucket    => Bucket);
   end Insert;

   overriding procedure Initialize (Object : in out Refcounted_Element_Ref) is
   begin
      raise Program_Error
        with "Refcounted_Element_Ref should not be created outside the package";
   end Initialize;

   overriding procedure Adjust (Object : in out Refcounted_Element_Ref) is
   begin
      if Object.Containing_Flyweight /= null then
         Flyweight_Hashtables.Increment(F => Object.Containing_Flyweight.all,
                                        Bucket => Object.Containing_Bucket,
                                        Data_Ptr => Access_Element_To_Element_Access(Object.E));
      end if;
   end Adjust;

   overriding procedure Finalize (Object : in out Refcounted_Element_Ref) is
   begin
      if Object.Containing_Flyweight /= null then
         Flyweight_Hashtables.Remove(F => Object.Containing_Flyweight.all,
                                     Bucket => Object.Containing_Bucket,
                                     Data_Ptr => Access_Element_To_Element_Access(Object.E));
         Object.Containing_Flyweight := null;
      end if;
   end Finalize;

end Flyweights_Refcount_Ptrs;
