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
      Found : Boolean := False;
   begin

      if Node_Ptr = null then
         -- List is empty:

         -- Create a new node as the first list element
         L := new Node'(Next => null,
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

      if not Found then
         raise Program_Error with "Could not find element resource to adjust use count!";
      end if;
   end Remove;

end Flyweights_Refcount_Lists;
