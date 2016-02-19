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
   type T (<>) is limited private;
   type T_Ptr is access T;
   type Counter(<>) is limited private;
   type Counter_Ptr is access Counter;

   with function Make_New_Counter(Element : T_Ptr) return Counter_Ptr is <>;

   with procedure Deallocate_If_Unused (C : in out Counter_Ptr) is <>;

   with function Element(C : in Counter) return T_Ptr is <>;

   with function Use_Count (C : in Counter) return Natural is <>;

   with procedure Increment_Use_Count (C : in out Counter) is <>;

   with procedure Decrement_Use_Count (C : in out Counter) is <>;

   with function Weak_Ptr_Count (C : in Counter) return Natural is <>;

   with procedure Increment_Weak_Ptr_Count (C : in out Counter) is <>;

   with procedure Decrement_Weak_Ptr_Count (C : in out Counter) is <>;

package Counters_Spec is

end Counters_Spec;
