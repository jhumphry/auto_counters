-- counters_spec.ads
-- Counters specification for use with smart_ptrs

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

generic
   type Counter(<>) is limited private;
   type Counter_Ptr is access Counter;

   with function Make_New_Counter return Counter_Ptr is <>;
   -- Make a new counter that points to the Element

   with procedure Deallocate_If_Unused (C : in out Counter_Ptr) is <>;
   -- Deallocate the Counter object if the Use_Count and Weak_Ptr_Count are
   -- both zero

   with function Use_Count (C : in Counter) return Natural is <>;
   -- Return the number of Smart_Ptr / Smart_Ref using the counter

   with procedure Check_Increment_Use_Count (C : in out Counter) is <>;
   -- Increment the Use_Count if the current use count is greater than zero,
   -- otherwise do nothing. These sematics help the Weak_Ptr.Lock code ensure
   -- that the target object does not get deallocated between the Weak_Ptr
   -- routine checking that it still exists (Use_Count > 0) and creating a
   -- new Smart_Ptr to it.

   with procedure Decrement_Use_Count (C : in out Counter) is <>;
   -- Decrement the Use_Count of the counter

   with function Weak_Ptr_Count (C : in Counter) return Natural is <>;
   -- Return the number of Weak_Ptr using the counter

   with procedure Increment_Weak_Ptr_Count (C : in out Counter) is <>;
   -- Increment the Weak_Ptr_Count of the counter, unconditionally.

   with procedure Decrement_Weak_Ptr_Count (C : in out Counter) is <>;
   -- Decrement the Weak_Ptr_Count of the counter

package Counters_Spec is

end Counters_Spec;
