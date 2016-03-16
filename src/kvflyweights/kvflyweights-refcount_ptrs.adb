-- kvflyweights-refcount_ptrs.adb
-- A package of reference-counting generalised references which point to
-- resources inside a Flyweight. Resources are associated with a key that can
-- be used to create them if they have not already been created.

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

package body KVFlyweights.Refcount_Ptrs is

   type Access_Value is access all Value;

   function Access_Value_To_Value_Access is
     new Ada.Unchecked_Conversion(Source => Access_Value,
                                  Target => Value_Access);

   subtype Hash_Type is Ada.Containers.Hash_Type;
   use type Ada.Containers.Hash_Type;

   --------------------------
   -- Refcounted_Value_Ptr --
   --------------------------

   function P (P : Refcounted_Value_Ptr) return V_Ref is
      (V_Ref'(V => P.V));

   function Get (P : Refcounted_Value_Ptr) return Value_Access is
     (P.V);

   function Make_Ref (P : Refcounted_Value_Ptr'Class)
                      return Refcounted_Value_Ref is
   begin
      KVFlyweight_Hashtables.Increment(F => P.Containing_KVFlyweight.all,
                                       Bucket => P.Containing_Bucket,
                                       Data_Ptr => P.V);
      return Refcounted_Value_Ref'(Ada.Finalization.Controlled
                                   with V => P.V,
                                   Containing_KVFlyweight => P.Containing_KVFlyweight,
                                   Containing_Bucket    => P.Containing_Bucket);
   end Make_Ref;

   function Insert_Ptr (F : aliased in out KVFlyweight_Hashtables.KVFlyweight;
                        K : in Key) return Refcounted_Value_Ptr is
      Bucket : Hash_Type;
      V : Value_Access;
   begin

      V := KVFlyweight_Hashtables.Insert (F => F,
                                          Bucket => Bucket,
                                          K => K);
      return Refcounted_Value_Ptr'(Ada.Finalization.Controlled
                                   with V => V,
                                   Containing_KVFlyweight => F'Access,
                                   Containing_Bucket    => Bucket);
   end Insert_Ptr;

   overriding procedure Adjust (Object : in out Refcounted_Value_Ptr) is
   begin
      if Object.V /= null and Object.Containing_KVFlyweight /= null then
         KVFlyweight_Hashtables.Increment(F => Object.Containing_KVFlyweight.all,
                                          Bucket => Object.Containing_Bucket,
                                          Data_Ptr => Object.V);
      end if;
   end Adjust;

   overriding procedure Finalize (Object : in out Refcounted_Value_Ptr) is
   begin
      if Object.V /= null and Object.Containing_KVFlyweight /= null then
         KVFlyweight_Hashtables.Remove(F => Object.Containing_KVFlyweight.all,
                                     Bucket => Object.Containing_Bucket,
                                     Data_Ptr => Object.V);
         Object.Containing_KVFlyweight := null;
      end if;
   end Finalize;

   --------------------------
   -- Refcounted_Value_Ref --
   --------------------------

   function Make_Ptr (R : Refcounted_Value_Ref'Class)
                      return Refcounted_Value_Ptr is
   begin
      KVFlyweight_Hashtables.Increment(F => R.Containing_KVFlyweight.all,
                                       Bucket => R.Containing_Bucket,
                                       Data_Ptr => Access_Value_To_Value_Access(R.V));
      return Refcounted_Value_Ptr'(Ada.Finalization.Controlled
                                   with V                 => Access_Value_To_Value_Access(R.V),
                                   Containing_KVFlyweight => R.Containing_KVFlyweight,
                                   Containing_Bucket      => R.Containing_Bucket);
   end Make_Ptr;

   function Get (P : Refcounted_Value_Ref) return Value_Access is
     (Access_Value_To_Value_Access(P.V));

   function Insert_Ref (F : aliased in out KVFlyweight_Hashtables.KVFlyweight;
                        K : in Key) return Refcounted_Value_Ref is
      Bucket : Hash_Type;
      V : Value_Access;
   begin

      V := KVFlyweight_Hashtables.Insert (F => F,
                                          Bucket => Bucket,
                                          K => K);
      return Refcounted_Value_Ref'(Ada.Finalization.Controlled
                                   with V => V,
                                   Containing_KVFlyweight => F'Access,
                                   Containing_Bucket    => Bucket);
   end Insert_Ref;

   overriding procedure Initialize (Object : in out Refcounted_Value_Ref) is
   begin
      raise Program_Error
        with "Refcounted_Value_Ref should not be created outside the package";
   end Initialize;

   overriding procedure Adjust (Object : in out Refcounted_Value_Ref) is
   begin
      if Object.Containing_KVFlyweight /= null then
         KVFlyweight_Hashtables.Increment(F => Object.Containing_KVFlyweight.all,
                                        Bucket => Object.Containing_Bucket,
                                        Data_Ptr => Access_Value_To_Value_Access(Object.V));
      end if;
   end Adjust;

   overriding procedure Finalize (Object : in out Refcounted_Value_Ref) is
   begin
      if Object.Containing_KVFlyweight /= null then
         KVFlyweight_Hashtables.Remove(F => Object.Containing_KVFlyweight.all,
                                     Bucket => Object.Containing_Bucket,
                                     Data_Ptr => Access_Value_To_Value_Access(Object.V));
         Object.Containing_KVFlyweight := null;
      end if;
   end Finalize;

end KVFlyweights.Refcount_Ptrs;
