-- kvflyweights-refcounted_lists.adb
-- A package of singly-linked reference-counting lists for the KVFlyweights
-- packages. Resources are associated with a key that can be used to create
-- them if they have not already been created.

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

package body KVFlyweights.Refcounted_Lists is

   procedure Deallocate_Key is new Ada.Unchecked_Deallocation(Object => Key,
                                                              Name => Key_Access);

   procedure Deallocate_Value is new Ada.Unchecked_Deallocation(Object => Value,
                                                                Name => Value_Access);

   procedure Deallocate_Node is new Ada.Unchecked_Deallocation(Object => Node,
                                                               Name => Node_Access);

   procedure Insert (L : in out List;
                     K : in Key;
                     Key_Ptr : out Key_Access;
                     Value_Ptr : out Value_Access) is
      Node_Ptr : Node_Access := L;
   begin

      if Node_Ptr = null then
         -- List is empty:

         -- Create a new node as the first list element
         Key_Ptr := new Key'(K);
         Value_Ptr := Factory(K);
         L := new Node'(Next      => null,
                        Key_Ptr   => Key_Ptr,
                        Value_Ptr => Value_Ptr,
                        Use_Count => 1);
      else
         -- List is not empty

         -- Loop over existing elements
         loop
            if K = Node_Ptr.Key_Ptr.all then
               -- K's value is already in the KVFlyweight
               Key_Ptr := Node_Ptr.Key_Ptr;
               Value_Ptr := Node_Ptr.Value_Ptr;
               Node_Ptr.Use_Count := Node_Ptr.Use_Count + 1;
               exit;
            elsif Node_Ptr.Next = null then
               -- We have reached the end of the relevant bucket's list and K is
               -- not already in the KVFlyweight, so add it.
               Key_Ptr := new Key'(K);
               Value_Ptr := Factory(K);
               Node_Ptr.Next := new Node'(Next       => null,
                                          Key_Ptr    => Key_Ptr,
                                          Value_Ptr  => Value_Ptr,
                                          Use_Count  => 1);
               exit;
            else
               Node_Ptr := Node_Ptr.Next;
            end if;
         end loop;
      end if;
   end Insert;

   procedure Increment (L : in out List;
                        Key_Ptr : in Key_Access) is
      Node_Ptr : Node_Access := L;
   begin

      pragma Assert (Check => Node_Ptr /= null,
                     Message => "Attempting to increment reference counter " &
                       "but the element falls into an empty bucket");

      -- Loop over existing elements, comparing keys by pointer rather than
      -- by value as there should never be duplicate key values in a Flyweight
      loop
         if Key_Ptr = Node_Ptr.Key_Ptr then
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
                     Key_Ptr : in Key_Access) is

      Node_Ptr : Node_Access := L;
      Last_Ptr : Node_Access;

   begin
      pragma Assert (Check => Node_Ptr /= null,
                     Message => "Attempting to remove an element from a null " &
                       "list.");

      if Key_Ptr = Node_Ptr.Key_Ptr then
         -- The element is the first in the list
         Node_Ptr.Use_Count := Node_Ptr.Use_Count - 1;
         if Node_Ptr.Use_Count = 0 then
            Deallocate_Key(Node_Ptr.Key_Ptr);
            Deallocate_Value(Node_Ptr.Value_Ptr);
            L := Node_Ptr.Next; -- L might be set to null here - this is valid
            Deallocate_Node(Node_Ptr);
         end if;

      elsif Node_Ptr.Next = null then
         -- Element is not first in the list and there are no more elements
         raise Program_Error with "Could not find element resource to " &
           "decrement use count.";

      else
         -- Search remaining elements
         Last_Ptr := Node_Ptr;
         Node_Ptr := Node_Ptr.Next;
         loop
            if Key_Ptr = Node_Ptr.Key_Ptr then
               Node_Ptr.Use_Count := Node_Ptr.Use_Count - 1;
               if Node_Ptr.Use_Count = 0 then
                  Deallocate_Key(Node_Ptr.Key_Ptr);
                  Deallocate_Value(Node_Ptr.Value_Ptr);
                  Last_Ptr.Next := Node_Ptr.Next;
                  Deallocate_Node(Node_Ptr);
               end if;
               exit;
            elsif Node_Ptr.Next = null then
               raise Program_Error with "Could not find element resource to " &
                 "decrement use count.";
            else
               Last_Ptr := Node_Ptr;
               Node_Ptr := Node_Ptr.Next;
            end if;
         end loop;

      end if;

   end Remove;

end KVFlyweights.Refcounted_Lists;
