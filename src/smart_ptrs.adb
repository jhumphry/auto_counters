-- smart_ptrs.adb
-- A reference-counted "smart pointer" type similar to that in C++

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
with Ada.Unchecked_Conversion;

package body Smart_Ptrs is

   -- *
   -- * Internal implementation definitions
   -- *

   procedure Deallocate_T is new Ada.Unchecked_Deallocation
     (Object => T,
      Name   => T_Ptr);

   type Smart_Ptr_Counter is record
      Element  : T_Ptr;
      SP_Count : Natural;
      WP_Count : Natural;
   end record;

   procedure Deallocate_Smart_Ptr_Counter is new Ada.Unchecked_Deallocation
     (Object => Smart_Ptr_Counter,
      Name   => Counter_Ptr);

   type Access_T is not null access all T;

   function Access_T_to_T_Ptr is new Ada.Unchecked_Conversion
     (Source => Access_T,
      Target => T_Ptr);

   -- *
   -- * Public routines
   -- *

   ---------------
   -- Smart_Ptr --
   ---------------

   function P (S : in Smart_Ptr) return T_Ref is
     (T_Ref'(Element => S.Element));

   function Get (S : in Smart_Ptr) return T_Ptr is
     (S.Element);

   function Make_Smart_Ptr (X : T_Ptr) return Smart_Ptr is
     (Smart_Ptr'(Ada.Finalization.Controlled with
                 Element => X,
                 Counter => (if X = null then
                                null
                             else
                                new Smart_Ptr_Counter'(Element  => X,
                                                       SP_Count => 1,
                                                       WP_Count => 0
                                                      )
                            ),
                 Null_Ptr => (X = null)
                )
     );

   function Make_Smart_Ptr (S : Smart_Ref) return Smart_Ptr is
   begin
      if S.Invalid then
         raise Smart_Ptr_Error
           with "Attempting to make a Smart_Ptr from an invalid Smart_Ref";
      end if;
      S.Counter.SP_Count := S.Counter.SP_Count + 1;
      -- As we ensure Smart_Ref is always made from a T_Ptr, the unchecked
      -- reverse conversion is always safe.
      return Smart_Ptr'(Ada.Finalization.Controlled with
                          Element => Access_T_to_T_Ptr(S.Element),
                        Counter => S.Counter,
                        Null_Ptr => False);
   end Make_Smart_Ptr;

   function Use_Count (S : in Smart_Ptr) return Natural is
     (if S.Null_Ptr then 1 else S.Counter.SP_Count);

   function Weak_Ptr_Count (S : in Smart_Ptr) return Natural is
     (if S.Null_Ptr then 0 else S.Counter.WP_Count);

   function Is_Null (S : in Smart_Ptr) return Boolean is
     (S.Null_Ptr);

   function Get (S : in Smart_Ref) return T_Ptr is
     (Access_T_to_T_Ptr(S.Element));

   ---------------
   -- Smart_Ref --
   ---------------

   function Make_Smart_Ref (X : T_Ptr) return Smart_Ref is
   begin
      if X = null then
         raise Smart_Ptr_Error
           with "Attempting to make a Smart_Ref from a null access value";
      end if;
      return Smart_Ref'(Ada.Finalization.Controlled with
                          Element => X,
                        Counter => new Smart_Ptr_Counter'(Element  => X,
                                                          SP_Count => 1,
                                                          WP_Count => 0
                                                         ),
                        Invalid => False
                       );

   end Make_Smart_Ref;

   function Make_Smart_Ref (S : Smart_Ptr'Class) return Smart_Ref is
   begin
      if S.Null_Ptr then
         raise Smart_Ptr_Error
           with "Attempting to make a Smart_Ref from a null Smart_Ptr";
      end if;
      S.Counter.SP_Count := S.Counter.SP_Count + 1;
      return Smart_Ref'(Ada.Finalization.Controlled with
                          Element => S.Element,
                        Counter => S.Counter,
                        Invalid => False);
   end Make_Smart_Ref;

   function Use_Count (S : in Smart_Ref) return Natural is
     (S.Counter.SP_Count);

   function Weak_Ptr_Count (S : in Smart_Ref) return Natural is
     (S.Counter.WP_Count);

   --------------
   -- Weak_Ptr --
   --------------

   function Make_Weak_Ptr (S : in Smart_Ptr'Class) return Weak_Ptr is
   begin
      if S.Null_Ptr then
         raise Smart_Ptr_Error
           with "Cannot create Weak_Ptr from a null pointer.";
      else
         S.Counter.WP_Count := S.Counter.WP_Count + 1;
         return Weak_Ptr'
             (Ada.Finalization.Controlled with Counter => S.Counter);
      end if;
   end Make_Weak_Ptr;

   function Make_Weak_Ptr (S : in Smart_Ref'Class) return Weak_Ptr is
   begin
      S.Counter.WP_Count := S.Counter.WP_Count + 1;
      return Weak_Ptr'
        (Ada.Finalization.Controlled with Counter => S.Counter);
   end Make_Weak_Ptr;

   function Use_Count (W : in Weak_Ptr) return Natural is
     (W.Counter.SP_Count);

   function Weak_Ptr_Count (W : in Weak_Ptr) return Natural is
     (W.Counter.WP_Count);

   function Expired (W : in Weak_Ptr) return Boolean is
     (W.Counter.SP_Count = 0);

   function Lock (W : in Weak_Ptr'Class) return Smart_Ptr is
   begin
      if W.Counter.SP_Count = 0 then
         raise Smart_Ptr_Error with "Attempt to lock an expired Weak_Ptr.";
      end if;
      W.Counter.SP_Count := W.Counter.SP_Count + 1;
      return Smart_Ptr'
          (Ada.Finalization.Controlled with
           Element  => W.Counter.Element,
           Counter  => W.Counter,
           Null_Ptr => False);
   end Lock;

   function Lock (W : in Weak_Ptr'Class) return Smart_Ref is
   begin
      if W.Counter.SP_Count = 0 then
         raise Smart_Ptr_Error with "Attempt to lock an expired Weak_Ptr.";
      end if;
      W.Counter.SP_Count := W.Counter.SP_Count + 1;
      return Smart_Ref'
          (Ada.Finalization.Controlled with
           Element => W.Counter.Element,
           Counter => W.Counter,
           Invalid => False);
   end Lock;

   function Get (W : in Weak_Ptr'Class) return Smart_Ptr is
   begin
      if W.Counter.SP_Count = 0 then
         return Null_Smart_Ptr;
      end if;
      W.Counter.SP_Count := W.Counter.SP_Count + 1;
      return Smart_Ptr'
          (Ada.Finalization.Controlled with
           Element  => W.Counter.Element,
           Counter  => W.Counter,
           Null_Ptr => False);
   end Get;

   -- *
   -- * Private routines
   -- *

   ---------------
   -- Smart_Ptr --
   ---------------

   procedure Adjust (Object : in out Smart_Ptr) is
   begin
      if not Object.Null_Ptr then
         if Object.Counter = null then
            raise Smart_Ptr_Error
              with "Corruption during Smart_Ptr assignment.";
         else
            Object.Counter.SP_Count := Object.Counter.SP_Count + 1;
         end if;
      end if;
   end Adjust;

   procedure Finalize (Object : in out Smart_Ptr) is
   begin

      if Object.Counter /= null then
         -- Finalize is required to be idempotent to cope with rare
         -- situations when it may be called multiple times. By setting
         -- Object.Counter to null, I ensure that there can be no
         -- double-decrementing of counters or double-deallocations.

         Object.Counter.SP_Count := Object.Counter.SP_Count - 1;

         if Object.Counter.SP_Count = 0 then

            Delete (Object.Element.all);
            Deallocate_T (Object.Element);

            if Object.Counter.WP_Count = 0 then
               Deallocate_Smart_Ptr_Counter (Counter_Ptr (Object.Counter));
            else
               Object.Counter.Element := null;
            end if;

            Object.Counter := null;
         end if;
      end if;
   end Finalize;

   ---------------
   -- Smart_Ref --
   ---------------

   procedure Initialize (Object : in out Smart_Ref) is
   begin
      if Object.Invalid then
         raise Smart_Ptr_Error
           with "Smart_Ref should be created via Make_Smart_Ref only";
      end if;
   end Initialize;

   procedure Adjust (Object : in out Smart_Ref) is
   begin
      if Object.Counter = null then
         raise Smart_Ptr_Error
           with "Corruption during Smart_Ptr assignment.";
      else
         Object.Counter.SP_Count := Object.Counter.SP_Count + 1;
      end if;
   end Adjust;

   procedure Finalize (Object : in out Smart_Ref) is
      Converted_Ptr : T_Ptr;
   begin

      if not Object.Invalid then
         -- Finalize is required to be idempotent to cope with rare
         -- situations when it may be called multiple times.

         Object.Counter.SP_Count := Object.Counter.SP_Count - 1;

         if Object.Counter.SP_Count = 0 then

            Converted_Ptr := Access_T_to_T_Ptr(Object.Element);
            -- We know U.Element was set from a T_Ptr so the unchecked
            -- conversion will in fact always be valid.

            Delete (Converted_Ptr.all);
            Deallocate_T (Converted_Ptr);

            if Object.Counter.WP_Count = 0 then
               Deallocate_Smart_Ptr_Counter (Counter_Ptr (Object.Counter));
            else
               Object.Counter.Element := null;
            end if;

            Object.Counter := null;
            Object.Invalid := True;
         end if;
      end if;
   end Finalize;

   --------------
   -- Weak_Ptr --
   --------------

   procedure Adjust (Object : in out Weak_Ptr) is
   begin
      if Object.Counter = null then
         raise Smart_Ptr_Error
           with "Corruption during Weak_Ptr assignment.";
      else
         Object.Counter.WP_Count := Object.Counter.WP_Count + 1;
      end if;
   end Adjust;

   procedure Finalize (Object : in out Weak_Ptr) is
   begin
      -- Make sure this procedure is idempotent.

      if Object.Counter /= null then
         Object.Counter.WP_Count := Object.Counter.WP_Count - 1;
         if Object.Counter.WP_Count = 0 and Object.Counter.SP_Count = 0 then
            Deallocate_Smart_Ptr_Counter (Object.Counter);
         end if;
      end if;

   end Finalize;

end Smart_Ptrs;
