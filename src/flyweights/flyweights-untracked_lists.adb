-- flyweights-untracked_lists.adb
-- A package of singly-linked lists for the Flyweights packages without resource
-- tracking or release

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

package body Flyweights.Untracked_Lists is

   procedure Deallocate_Element is
     new Ada.Unchecked_Deallocation(Object => Element,
                                    Name => Element_Access);

   procedure Insert (L : in out List;
                     E : in out Element_Access) is
      Node_Ptr : Node_Access := L;
   begin

      if Node_Ptr = null then
         -- List is empty:

         -- Create a new node as the first list element
         L := new Node'(Next => null,
                        Data => E);
      else
         -- List is not empty

         -- Check for existing element
         loop
            if E = Node_Ptr.Data then
               -- E is already a pointer to inside the FlyWeight
               exit;
            elsif E.all = Node_Ptr.Data.all then
               -- E's value is a copy of a value already in the FlyWeight
               Deallocate_Element(E);
               E := Node_Ptr.Data;
               exit;
            end if;
            if Node_Ptr.Next = null then
               -- List not empty but element not already present. Add to the end of
               -- the list.
               Node_Ptr.Next := new Node'(Next => null,
                                          Data => E);
            else
               Node_Ptr := Node_Ptr.Next;
            end if;
         end loop;

      end if;
   end Insert;

   procedure Increment (L : in out List;
                        E : in Element_Access) is
   begin
      raise Program_Error
        with "Attempting to adjust a use-count in an untracked list!";
   end Increment;

   procedure Remove (L : in out List;
                     Data_Ptr : in Element_Access) is
   begin
      raise Program_Error
        with "Attempting to free element in an untracked list!";
   end Remove;

end Flyweights.Untracked_Lists;
