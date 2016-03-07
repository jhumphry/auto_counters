-- flyweights.ads
-- A package for ensuring resources are not duplicated in a manner similar
-- to the C++ Boost flyweight classes.

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

with Ada.Assertions;
with Ada.Unchecked_Conversion;

package body Flyweights is

   type Access_Element is access all Element;

   function Access_Element_To_Element_Access is new Ada.Unchecked_Conversion(Source => Access_Element,
                                                                             Target => Element_Access);

   subtype Hash_Type is Ada.Containers.Hash_Type;

   function Insert (F : aliased in out Flyweight;
                    E : in out Element_Access) return Refcounted_Element_Ref is
      Bucket_Number : constant Hash_Type := (Hash(E.all) mod Capacity);
   begin

      Insert(L => F.Lists(Bucket_Number),
             E => E);

      return Refcounted_Element_Ref'(Ada.Finalization.Limited_Controlled with
                                       E => E,
                                     Containing_Flyweight => F'Access,
                                     Containing_Bucket    => Bucket_Number);
   end Insert;

   procedure Remove (F : in out Flyweight;
                     Bucket : Ada.Containers.Hash_Type;
                     Data_Ptr : in Element_Access) is
      use Ada.Assertions;
   begin
      Assert(F.Lists(Bucket) /= null,
             "Removing a reference to an element that isn't in the flyweight");
      Remove(L => F.Lists(Bucket),
             Data_Ptr => Data_Ptr);
   end Remove;

   overriding procedure Initialize (Object : in out Refcounted_Element_Ref) is
   begin
      raise Program_Error
        with "Refcounted_Element_Ref should not be created outside the package";
   end Initialize;

   overriding procedure Finalize (Object : in out Refcounted_Element_Ref) is
   begin
      Remove(F => Object.Containing_Flyweight.all,
             Bucket => Object.Containing_Bucket,
             Data_Ptr => Access_Element_To_Element_Access(Object.E));
   end Finalize;

end Flyweights;
