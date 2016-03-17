-- kvflyweights-untracked_ptrs.adb
-- A package of generalised references which point to resources inside a
-- KVFlyweight. Resources are associated with a key that can be used to
-- create them if they have not already been created.

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

package body KVFlyweights.Untracked_Ptrs is

   type Access_Value is access all Value;

   function Access_Value_To_Value_Access is
     new Ada.Unchecked_Conversion(Source => Access_Value,
                                  Target => Value_Access);

   subtype Hash_Type is Ada.Containers.Hash_Type;
   use type Ada.Containers.Hash_Type;

   -------------------------
   -- Untracked_Value_Ptr --
   -------------------------

   function P (P : Untracked_Value_Ptr) return V_Ref is
     (V_Ref'(V => P.V));

   function Get (P : Untracked_Value_Ptr) return Value_Access is
     (P.V);

   function Make_Ref (P : Untracked_Value_Ptr'Class)
                      return Untracked_Value_Ref is
     (Untracked_Value_Ref'(V => P.V,
                           K => P.K,
                           Containing_KVFlyweight => P.Containing_KVFlyweight,
                           Containing_Bucket    => P.Containing_Bucket));

   function Insert_Ptr (F : aliased in out KVFlyweight_Hashtables.KVFlyweight;
                        K : in Key) return Untracked_Value_Ptr is
      Bucket : Hash_Type;
      Key_Ptr : Key_Access;
      Value_Ptr : Value_Access;
   begin
      KVFlyweight_Hashtables.Insert (F => F,
                                     Bucket => Bucket,
                                     K => K,
                                     Key_Ptr => Key_Ptr,
                                     Value_Ptr => Value_Ptr);

      return Untracked_Value_Ptr'(V => Value_Ptr,
                                  K => Key_Ptr,
                                  Containing_KVFlyweight => F'Access,
                                  Containing_Bucket    => Bucket);
   end Insert_Ptr;

   -------------------------
   -- Untracked_Value_Ref --
   -------------------------

   function Make_Ptr (R : Untracked_Value_Ref'Class)
                      return Untracked_Value_Ptr is
     (Untracked_Value_Ptr'(V                      => Access_Value_To_Value_Access(R.V),
                           K                      => R.K,
                           Containing_KVFlyweight => R.Containing_KVFlyweight,
                           Containing_Bucket      => R.Containing_Bucket));

   function Get (P : Untracked_Value_Ref) return Value_Access is
     (Access_Value_To_Value_Access(P.V));

   function Insert_Ref (F : aliased in out KVFlyweight_Hashtables.KVFlyweight;
                        K : in Key) return Untracked_Value_Ref is
      Bucket : Hash_Type;
      Key_Ptr : Key_Access;
      Value_Ptr : Value_Access;
   begin
      KVFlyweight_Hashtables.Insert (F => F,
                                     Bucket => Bucket,
                                     K => K,
                                     Key_Ptr => Key_Ptr,
                                     Value_Ptr => Value_Ptr);
      return Untracked_Value_Ref'(V => Value_Ptr,
                                  K => Key_Ptr,
                                  Containing_KVFlyweight => F'Access,
                                  Containing_Bucket    => Bucket);
   end Insert_Ref;

end KVFlyweights.Untracked_Ptrs;
