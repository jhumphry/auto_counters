-- basic_smart_ptrs.ads
-- Implements a reference counted Smart_Ptr type that is not task-safe.

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

with Basic_Counters;
with Smart_Ptrs;

generic
   type T (<>) is limited private;
   with procedure Delete (X : in out T) is null;
package Basic_Smart_Ptrs is

   type T_Ptr is access T;

   package T_Basic_Counters is new Basic_Counters(T => T,
                                                  T_Ptr => T_Ptr);

   package Ptr_Types is new Smart_Ptrs(T => T,
                                       T_Ptr => T_Ptr,
                                       Delete => Delete,
                                       Counters => T_Basic_Counters.Basic_Counters_Spec);

end Basic_Smart_Ptrs;
