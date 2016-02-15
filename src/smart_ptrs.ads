-- smart_ptrs.ads
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

with Ada.Finalization;

generic
   type T(<>) is limited private;
   with procedure Delete(X : in out T) is null;
package Smart_Ptrs is

   type T_Ptr is access T;
   type T_Ref(Element : access T) is null record
     with Implicit_Dereference => Element;

   Smart_Ptr_Error : exception;

   type Smart_Ptr is new Ada.Finalization.Controlled with private;

   function P(S : in Smart_Ptr) return T_Ref with Inline;
   function Get(S : in Smart_Ptr) return T_Ptr with Inline;
   function Make_Smart_Ptr(X : T_Ptr) return Smart_Ptr with Inline;
   function Use_Count(S : in Smart_Ptr) return Natural with Inline;
   function Unique(S : in Smart_Ptr) return Boolean is
     (Use_Count(S) = 1);
   function Weak_Ptr_Count(S : in Smart_Ptr) return Natural with Inline;

   Null_Smart_Ptr : constant Smart_Ptr;

   type Weak_Ptr(<>) is new Ada.Finalization.Controlled with private;

   function Make_Weak_Ptr(S : in Smart_Ptr'Class) return Weak_Ptr with Inline;

   function Use_Count(W : in Weak_Ptr) return Natural with Inline;
   function Expired(W : in Weak_Ptr) return Boolean with Inline;
   function Lock(W : in Weak_Ptr'Class) return Smart_Ptr;

private

   type Smart_Ptr_Counter;
   type Counter_Ptr is access Smart_Ptr_Counter;

   type Smart_Ptr is new Ada.Finalization.Controlled
     with
      record
         Element : T_Ptr := null;
         Counter : Counter_Ptr := null;
         Null_Ptr : Boolean := True;
      end record;

    overriding procedure Initialize (Object : in out Smart_Ptr) is null;
    overriding procedure Adjust     (Object : in out Smart_Ptr);
    overriding procedure Finalize   (Object : in out Smart_Ptr);

   Null_Smart_Ptr : constant Smart_Ptr := (Ada.Finalization.Controlled with
                                           Element => null,
                                           Counter => null,
                                           Null_Ptr => True);

   type Weak_Ptr is
     new Ada.Finalization.Controlled with
      record
         Counter : Counter_Ptr;
      end record;

    overriding procedure Initialize (Object : in out Weak_Ptr) is null;
    overriding procedure Adjust     (Object : in out Weak_Ptr);
    overriding procedure Finalize   (Object : in out Weak_Ptr);

end Smart_Ptrs;
