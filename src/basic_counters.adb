-- basic_counters.adb
-- Basic non-task safe counters for use with smart_ptrs

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

package body Basic_Counters is

   function Make_New_Counter(Element : T_Ptr)
                                       return Counter_Ptr is
     (new Counter'(Element  => Element,
                             SP_Count => 1,
                             WP_Count => 0
                            )
     );

   procedure Deallocate_Counter is new Ada.Unchecked_Deallocation
     (Object => Counter,
      Name   => Counter_Ptr);

   procedure Deallocate_If_Unused (C : in out Counter_Ptr) is

   begin
      if C.SP_Count = 0 and C.WP_Count = 0 then
         Deallocate_Counter(C);
      end if;
   end Deallocate_If_Unused;

   procedure Check_Increment_Use_Count (C : in out Counter) is
   begin
      if C.SP_Count > 0 then
         C.SP_Count := C.SP_Count + 1;
      end if;
   end Check_Increment_Use_Count;

   procedure Decrement_Use_Count (C : in out Counter)  is
   begin
      C.SP_Count := C.SP_Count - 1;
   end Decrement_Use_Count;

   procedure Increment_Weak_Ptr_Count (C : in out Counter) is
   begin
      C.WP_Count := C.WP_Count + 1;
   end Increment_Weak_Ptr_Count;

   procedure Decrement_Weak_Ptr_Count (C : in out Counter) is
   begin
      C.WP_Count := C.WP_Count - 1;
   end Decrement_Weak_Ptr_Count;

end Basic_Counters;
