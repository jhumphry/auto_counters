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

with Ada.Unchecked_Deallocation;

package body Smart_Ptrs is

   procedure Deallocate_T is new Ada.Unchecked_Deallocation(Object => T,
                                                            Name => T_Ptr);

   type Smart_Ptr_Counter is
      record
         Element : T_Ptr;
         SP_Count : Natural;
         WP_Count : Natural;
         Expired : Boolean;
      end record;

   procedure Deallocate_Smart_Ptr_Counter is
     new Ada.Unchecked_Deallocation(Object => Smart_Ptr_Counter,
                                    Name => Counter_Ptr);

   -------
   -- P --
   -------

   function P(S : in Smart_Ptr) return T_Ref is
     (T_Ref'(Element => S.Element));

   ---------
   -- Get --
   ---------

   function Get(S : in Smart_Ptr) return T_Ptr is
     (S.Element);

   --------------------
   -- Make_Smart_Ptr --
   --------------------

   function Make_Smart_Ptr(X : T_Ptr) return Smart_Ptr is
   begin
      if X = null then
         return Null_Smart_Ptr;
      else
         return Smart_Ptr'(Ada.Finalization.Controlled with
                           Element => X,
                           Counter => new Smart_Ptr_Counter'(Element => X,
                                                             SP_Count => 1,
                                                             WP_Count => 0,
                                                             Expired => False),
                           Null_Ptr => False
                          );
      end if;
   end Make_Smart_Ptr;

   ---------------
   -- Use_Count --
   ---------------

   function Use_Count (S : in Smart_Ptr) return Natural is
      (S.Counter.SP_Count);

   --------------------
   -- Weak_Ptr_Count --
   --------------------

   function Weak_Ptr_Count (S : in Smart_Ptr) return Natural is
      (S.Counter.WP_Count);

   -------------------
   -- Make_Weak_Ptr --
   -------------------

   function Make_Weak_Ptr (S : in Smart_Ptr'Class) return Weak_Ptr is
   begin
      S.Counter.WP_Count := S.Counter.WP_Count + 1;
      return Weak_Ptr'(Ada.Finalization.Controlled with
                         Counter => S.Counter);
   end Make_Weak_Ptr;

   ---------------
   -- Use_Count --
   ---------------

   function Use_Count (W : in Weak_Ptr) return Natural is
      (W.Counter.SP_Count);

   -------------
   -- Expired --
   -------------

   function Expired (W : in Weak_Ptr) return Boolean is
      (W.Counter.SP_Count = 0);

   ----------
   -- Lock --
   ----------

   function Lock (W : in Weak_Ptr'Class) return Smart_Ptr is
   begin
      if W.Counter.Expired then
         raise Smart_Ptr_Error with "Attempt to lock an expired Weak_Ptr.";
      end if;
      W.Counter.SP_Count := W.Counter.SP_Count + 1;
      return Smart_Ptr'(Ada.Finalization.Controlled with
                          Element => W.Counter.Element,
                        Counter => W.Counter,
                        Null_Ptr => (W.Counter.Element = null));
   end Lock;

   ------------
   -- Adjust --
   ------------

   procedure Adjust (Object : in out Smart_Ptr) is
   begin

      if not Object.Null_Ptr then
         if Object.Counter = null then
            raise Smart_Ptr_Error with "Possible self-assignment detected!";
         else
            Object.Counter.SP_Count := Object.Counter.SP_Count + 1;
         end if;
      end if;
   end Adjust;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (Object : in out Smart_Ptr) is
   begin

      if Object.Counter /= null then
         -- Finalize is required to be idempotent to cope with rare
         -- situations when it may be called multiple times. By setting
         -- Object.Counter to null, I ensure that there can be no
         -- double-decrementing of counters or double-deallocations.

         Object.Counter.SP_Count := Object.Counter.SP_Count - 1;

         if Object.Counter.SP_Count = 0 then

            Delete(Object.Element.all);
            Deallocate_T(Object.Counter.Element);

            if Object.Counter.WP_Count = 0 then
               Deallocate_Smart_Ptr_Counter(Counter_Ptr(Object.Counter));
            else
               Object.Counter.Expired := True;
               Object.Counter.Element := null;
            end if;

            Object.Counter := null;
         end if;
      end if;
   end Finalize;

   ------------
   -- Adjust --
   ------------

   procedure Adjust (Object : in out Weak_Ptr) is
   begin
      Object.Counter.WP_Count := Object.Counter.WP_Count + 1;
   end Adjust;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (Object : in out Weak_Ptr) is
   begin
      -- Make sure this procedure is idempotent.

      if Object.Counter /= null then
         Object.Counter.WP_Count := Object.Counter.WP_Count - 1;
         if Object.Counter.WP_Count = 0 and Object.Counter.Expired then
            -- Expired indicates that the last Smart_Ptr was Finalized some time
            -- beforehand, so the only remaining user of this Smart_Ptr_Counter is
            -- the weak reference.

            Deallocate_Smart_Ptr_Counter(Object.Counter);
         end if;
      end if;
   end Finalize;

end Smart_Ptrs;
