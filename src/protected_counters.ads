-- protected_counters.ads
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

with Counters_Spec;

generic
   type T (<>) is limited private;
   type T_Ptr is access T;
package Protected_Counters is

   protected type Counter is
      entry Lock;
      procedure Unlock;
      procedure Initialize_New_Counter(Element : T_Ptr);

      function Element return T_Ptr;
      function Use_Count return Natural;
      entry Check_Increment_Use_Count;
      entry Decrement_Use_Count;
      function Weak_Ptr_Count return Natural;
      entry Increment_Weak_Ptr_Count;
      entry Decrement_Weak_Ptr_Count;

   private
      Locked : Boolean := True;
      Element_Ptr  : T_Ptr;
      SP_Count : Natural := 1;
      WP_Count : Natural := 0;
   end Counter;

   type Counter_Ptr is access Counter;

   function Make_New_Counter(Element : T_Ptr) return Counter_Ptr;

   procedure Deallocate_If_Unused (C : in out Counter_Ptr) with Inline;

   function Element(C : in Counter) return T_Ptr is
      (C.Element) with Inline;

   function Use_Count (C : in Counter) return Natural  is
     (C.Use_Count) with Inline;

   procedure Check_Increment_Use_Count (C : in out Counter) with Inline;

   procedure Decrement_Use_Count (C : in out Counter)  with Inline;

   function Weak_Ptr_Count (C : in Counter) return Natural is
     (C.Weak_Ptr_Count) with Inline;

   procedure Increment_Weak_Ptr_Count (C : in out Counter) with Inline;

   procedure Decrement_Weak_Ptr_Count (C : in out Counter) with Inline;

   package Protected_Counters_Spec is new Counters_Spec(T => T,
                                                        T_Ptr => T_Ptr,
                                                        Counter => Counter,
                                                        Counter_Ptr => Counter_Ptr);

end Protected_Counters;
