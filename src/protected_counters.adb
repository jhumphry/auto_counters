-- protected_counters.adb
-- Task safe counters for use with smart_ptrs

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

package body Protected_Counters is

   procedure Deallocate_Counter is new Ada.Unchecked_Deallocation
     (Object => Counter,
      Name   => Counter_Ptr);

   protected body Counter is

      entry Lock when not Locked is
      begin
         Locked := True;
      end Lock;

      procedure Unlock is
      begin
         Locked := False;
      end Unlock;

      procedure Initialize_New_Counter (Element : T_Ptr) is
      begin
         Locked := False;
         Element_Ptr := Element;
         SP_Count := 1;
         WP_Count := 0;
      end Initialize_New_Counter;

      function Element return T_Ptr is
         (Element_Ptr);

      function Use_Count return Natural is
         (SP_Count);

      entry Check_Increment_Use_Count when not Locked is
      begin
         if SP_Count > 0 then
            SP_Count := SP_Count + 1;
         end if;
      end Check_Increment_Use_Count;

      entry Decrement_Use_Count when not Locked is
      begin
         SP_Count := SP_Count - 1;
      end Decrement_Use_Count;

      function Weak_Ptr_Count return Natural is
         (WP_Count);

      entry Increment_Weak_Ptr_Count when not Locked is
      begin
         WP_Count := WP_Count + 1;
      end Increment_Weak_Ptr_Count;

      entry Decrement_Weak_Ptr_Count when not Locked is
      begin
         WP_Count := WP_Count - 1;
      end Decrement_Weak_Ptr_Count;

   end Counter;

   function Make_New_Counter (Element : T_Ptr) return Counter_Ptr is
      Result : constant Counter_Ptr := new Counter;
   begin
      Result.Initialize_New_Counter(Element);
      return Result;
   end Make_New_Counter;

   procedure Deallocate_If_Unused (C : in out Counter_Ptr) is
   begin
      C.Lock;
      if C.Use_Count = 0 and C.Weak_Ptr_Count = 0 then
         Deallocate_Counter(C);
      else
         C.Unlock;
      end if;
   end Deallocate_If_Unused;

   procedure Check_Increment_Use_Count (C : in out Counter) is
   begin
      C.Check_Increment_Use_Count;
   end Check_Increment_Use_Count;

   procedure Decrement_Use_Count (C : in out Counter) is
   begin
      C.Decrement_Use_Count;
   end Decrement_Use_Count;

   procedure Increment_Weak_Ptr_Count (C : in out Counter) is
   begin
      C.Increment_Weak_Ptr_Count;
   end Increment_Weak_Ptr_Count;

   procedure Decrement_Weak_Ptr_Count (C : in out Counter) is
   begin
      C.Decrement_Weak_Ptr_Count;
   end Decrement_Weak_Ptr_Count;

end Protected_Counters;
