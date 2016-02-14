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

   Smart_Ptr_Error : exception;

   type Smart_Ptr(E : access T) is
     new Ada.Finalization.Controlled with private
     with Implicit_Dereference => E;

   function Make_Smart_Ptr(X : T_Ptr) return Smart_Ptr;
   function Use_Count(S : in Smart_Ptr) return Natural;
   function Unique(S : in Smart_Ptr) return Boolean is
     (Use_Count(S) = 1);
   function Weak_Ptr_Count(S : in Smart_Ptr) return Natural;

   type Weak_Ptr(<>) is new Ada.Finalization.Controlled with private;

   function Make_Weak_Ptr(S : in Smart_Ptr'Class) return Weak_Ptr;

   function Use_Count(W : in Weak_Ptr) return Natural;
   function Expired(W : in Weak_Ptr) return Boolean;
--     function Lock(W : in Weak_Ptr) return Smart_Ptr'Class;

private

   type Smart_Ptr_Counter;
   type Counter_Ptr is access Smart_Ptr_Counter;

   type Smart_Ptr(E : access T) is new Ada.Finalization.Controlled
     with
      record
         Element : T_Ptr;
         Counter : Counter_Ptr;
      end record;

    procedure Initialize (Object : in out Smart_Ptr);
    procedure Adjust     (Object : in out Smart_Ptr);
    procedure Finalize   (Object : in out Smart_Ptr);

   type Weak_Ptr is
     new Ada.Finalization.Controlled with
      record
         Counter : Counter_Ptr;
         Expired : Boolean;
      end record;

    procedure Initialize (Object : in out Weak_Ptr) is null;
    procedure Adjust     (Object : in out Weak_Ptr);
    procedure Finalize   (Object : in out Weak_Ptr);

end Smart_Ptrs;
