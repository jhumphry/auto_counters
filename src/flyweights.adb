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
with Ada.Unchecked_Deallocation;
with Ada.Unchecked_Conversion;

package body Flyweights is

   procedure Deallocate_Element is new Ada.Unchecked_Deallocation(Object => Element,
                                                                  Name => Element_Access);

   procedure Deallocate_Node is new Ada.Unchecked_Deallocation(Object => Node,
                                                                  Name => Node_Access);

   type Access_Element is access all Element;

   function Access_Element_To_Element_Access is new Ada.Unchecked_Conversion(Source => Access_Element,
                                                                             Target => Element_Access);

   subtype Hash_Type is Ada.Containers.Hash_Type;

   function Insert (F : aliased in out Flyweight;
                    E : in out Element_Access) return Refcounted_Element_Ref is
      Bucket_Number : constant Hash_Type := (Hash(E.all) mod Capacity);
      Node_Ptr : Node_Access;
   begin

      Node_Ptr := F.Nodes(Bucket_Number);
      Insert(List => Node_Ptr,
             E => E);
      F.Nodes(Bucket_Number) := Node_Ptr;

      return Refcounted_Element_Ref'(Ada.Finalization.Limited_Controlled with
                                       E => E,
                                     Containing_Flyweight => F'Access,
                                     Containing_Bucket    => Bucket_Number);
   end Insert;

   procedure Insert (List : in out Node_Access;
                     E : in out Element_Access) is
      Node_Ptr : Node_Access := List;
      Found : Boolean := False;
   begin

      if Node_Ptr = null then
         -- List is empty:

         -- Create a new node as the first list element
         List := new Node'(Next => null,
                           Data => E,
                           Use_Count => 1);
      else
         -- List is not empty

         -- Check for existing element
         loop
            if E.all = Node_Ptr.Data.all then
               Deallocate_Element(E);
               E := Node_Ptr.Data;
               Node_Ptr.Use_Count := Node_Ptr.Use_Count + 1;
               Found := True;
            end if;
            if Node_Ptr.Next = null then
               exit;
            else
               Node_Ptr := Node_Ptr.Next;
            end if;
         end loop;

         -- List not empty but element not already present. Add to the end of
         -- the list.
         if not Found then
            Node_Ptr.Next := new Node'(Next => null,
                                       Data => E,
                                       Use_Count => 1);
         end if;
      end if;
   end Insert;

   procedure Remove (List : in out Node_Access;
                     Data_Ptr : in Element_Access) is

      Node_Ptr, Last_Ptr : Node_Access;
      Found : Boolean := False;
   begin
      Node_Ptr := List;

      if Data_Ptr = Node_Ptr.Data then

         Node_Ptr.Use_Count := Node_Ptr.Use_Count - 1;
         if Node_Ptr.Use_Count = 0 then
            Deallocate_Element(Node_Ptr.Data);
            List := Node_Ptr.Next;
            Deallocate_Node(Node_Ptr);
         end if;
         Found := True;

      else

         Last_Ptr := Node_Ptr;
         Node_Ptr := Node_Ptr.Next;
         while Node_Ptr /= null loop
            if Data_Ptr = Node_Ptr.Data
            then
               Node_Ptr.Use_Count := Node_Ptr.Use_Count - 1;
               if Node_Ptr.Use_Count = 0 then
                  Deallocate_Element(Node_Ptr.Data);
                  Last_Ptr.Next := Node_Ptr.Next;
                  Deallocate_Node(Node_Ptr);
               end if;
               Found := True;
               exit;
            end if;
            Last_Ptr := Node_Ptr;
            Node_Ptr := Node_Ptr.Next;
         end loop;

      end if;

      if not Found then
         raise Program_Error with "Could not find element resource to adjust use count!";
      end if;
   end Remove;

   procedure Remove (F : in out Flyweight;
                     Bucket : Ada.Containers.Hash_Type;
                     Data_Ptr : in Element_Access) is
      use Ada.Assertions;
   begin
      Assert(F.Nodes(Bucket) /= null,
             "Removing a reference to an element that isn't in the flyweight");
      Remove(List => F.Nodes(Bucket),
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
