-- flyweights_refcount_lists.adb
-- A package of singly-linked reference-counting lists for the Flyweights
-- packages

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

package body Flyweights_Refcount_Lists is

   procedure Deallocate_Element is new Ada.Unchecked_Deallocation(Object => Element,
                                                                  Name => Element_Access);

   procedure Deallocate_Node is new Ada.Unchecked_Deallocation(Object => Node,
                                                                  Name => Node_Access);

   procedure Insert (L : in out List;
                     E : in out Element_Access) is
      Node_Ptr : Node_Access := L;
   begin

      if Node_Ptr = null then
         -- List is empty:

         -- Create a new node as the first list element
         L := new Node'(Next => null,
                           Data => E,
                           Use_Count => 1);
      else
         -- List is not empty

         -- Loop over existing elements
         loop
            if E = Node_Ptr.Data then
               -- E is a pointer to inside the Flyweight
               Node_Ptr.Use_Count := Node_Ptr.Use_Count + 1;
               exit;
            elsif E.all = Node_Ptr.Data.all then
               -- E's value is a copy of a value already in the Flyweight
               Deallocate_Element(E);
               E := Node_Ptr.Data;
               Node_Ptr.Use_Count := Node_Ptr.Use_Count + 1;
               exit;
            elsif Node_Ptr.Next = null then
               -- We have reached the end of the relevant bucket's list and E is
               -- not already in the Flyweight, so add it.
               Node_Ptr.Next := new Node'(Next => null,
                                          Data => E,
                                          Use_Count => 1);
               exit;
            else
               Node_Ptr := Node_Ptr.Next;
            end if;
         end loop;
      end if;
   end Insert;

   procedure Increment (L : in out List;
                        E : in Element_Access) is
      Node_Ptr : Node_Access := L;
   begin

      pragma Assert (Check => Node_Ptr /= null,
                     Message => "Attempting to increment reference counter " &
                       "but the element falls into an empty bucket");

      -- List is not empty

         -- Loop over existing elements
      loop
         if E = Node_Ptr.Data then
            Node_Ptr.Use_Count := Node_Ptr.Use_Count + 1;
            exit;
         elsif Node_Ptr.Next = null then
            raise Program_Error with "Attempting to increment reference " &
              "counter but the element is not in the relevant bucket's list";
         else
            Node_Ptr := Node_Ptr.Next;
         end if;
      end loop;

   end Increment;

   procedure Remove (L : in out List;
                     Data_Ptr : in Element_Access) is

      Node_Ptr, Last_Ptr : Node_Access;
      Found : Boolean := False;
   begin
      Node_Ptr := L;

      if Data_Ptr = Node_Ptr.Data then

         Node_Ptr.Use_Count := Node_Ptr.Use_Count - 1;
         if Node_Ptr.Use_Count = 0 then
            Deallocate_Element(Node_Ptr.Data);
            L := Node_Ptr.Next;
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

      pragma Assert (Check => Found,
                     Message => "Could not find element resource to adjust " &
                       "use count!");
   end Remove;

end Flyweights_Refcount_Lists;
