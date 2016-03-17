-- kvflyweights-untracked_lists.adb
-- A package of singly-linked lists for the KVFlyweights packages. Resources
-- are associated with a key that can be used to create them if they have not
-- already been created.

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

package body KVFlyweights.Untracked_Lists is

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
                        Value_Ptr => Value_Ptr);
      else
         -- List is not empty

         -- Loop over existing elements
         loop
            if K = Node_Ptr.Key_Ptr.all then
               -- K's value is already in the KVFlyweight
               Key_Ptr := Node_Ptr.Key_Ptr;
               Value_Ptr := Node_Ptr.Value_Ptr;
               exit;
            elsif Node_Ptr.Next = null then
               -- We have reached the end of the relevant bucket's list and K is
               -- not already in the KVFlyweight, so add it.
               Key_Ptr := new Key'(K);
               Value_Ptr := Factory(K);
               Node_Ptr.Next := new Node'(Next       => null,
                                          Key_Ptr    => Key_Ptr,
                                          Value_Ptr  => Value_Ptr);
               exit;
            else
               Node_Ptr := Node_Ptr.Next;
            end if;
         end loop;
      end if;
   end Insert;

   procedure Increment (L : in out List;
                        Key_Ptr : in Key_Access) is
   begin
      raise Program_Error
        with "Attempting to adjust a use-count in an untracked list!";
   end Increment;

   procedure Remove (L : in out List;
                     Key_Ptr : in Key_Access) is
   begin
      raise Program_Error
        with "Attempting to free element in an untracked list!";
   end Remove;

end KVFlyweights.Untracked_Lists;
