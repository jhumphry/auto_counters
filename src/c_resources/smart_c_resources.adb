-- smart_c_resources.adb
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

package body Smart_C_Resources is

   -------------
   -- Smart_T --
   -------------

   function Make_Smart_T (X : in T) return Smart_T is
     (Ada.Finalization.Controlled
      with Element => X,
      Counter => Make_New_Counter);

   function Element (S : Smart_T) return T is
     (S.Element);

   function Use_Count (S : in Smart_T) return Natural is
     (Use_Count(S.Counter.all));

   overriding procedure Initialize (Object : in out Smart_T) is
   begin
      Object.Element := Initialize;
      Object.Counter := Make_New_Counter;
   end Initialize;

   overriding procedure Adjust (Object : in out Smart_T) is
   begin
      if Object.Counter = null then
         raise Program_Error
           with "Corruption during Smart_T assignment.";
      else
         Check_Increment_Use_Count(Object.Counter.all);
      end if;
   end Adjust;

   overriding procedure Finalize (Object : in out Smart_T) is
   begin
      if Object.Counter /= null then
         -- Finalize is required to be idempotent to cope with rare
         -- situations when it may be called multiple times. By setting
         -- Object.Counter to null, I ensure that there can be no
         -- double-decrementing of counters or double-deallocations.

         Decrement_Use_Count(Object.Counter.all);

         if Use_Count(Object.Counter.all) = 0 then

            Finalize(Object.Element);

            Deallocate_If_Unused(Object.Counter);

         end if;

         Object.Counter := null;
      end if;
   end Finalize;

end Smart_C_Resources;
