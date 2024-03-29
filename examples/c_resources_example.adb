-- wrap_resources_example.adb
-- An example of using the Wrap_C_Resources package

-- Copyright (c) 2016-2023, James Humphry
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

with Ada.Text_IO;
use Ada.Text_IO;

with Interfaces.C;

with System;

with Basic_Counters;
with Smart_C_Resources;
with Unique_C_Resources;

procedure C_Resources_Example is

   use type Interfaces.C.int;
   subtype C_Int is Interfaces.C.int;

   -- A common pattern for C libraries is to manage their own resources by using
   -- resource handles in the form of pointers to opaque structs, and requiring
   -- library users to remember to call initialisation and destruction functions
   -- before using them.

   type c_resource is new System.Address;
   -- Where the underlying type is not disclosed, System.Address should usually
   -- be acceptable as a (void *) equivalent.

   function init return c_resource;
   pragma Import (C, init, "c_resource_init");
   -- If the initialisation requires parameters an Ada function will have to be
   -- written as a go-between to provide defaults.

   procedure destroy (x : in c_resource);
   pragma Import (C, destroy, "c_resource_destroy");
   -- Note the parameter mode in contrast with Ada.Finalization.Finalize. Here
   -- we are passing in a pointer that will be invalidated but not cleared by
   -- the library. This is fairly standard for C. Re-using the pointer would
   -- give undefined behaviour, but we know that 'destroy' will only be called
   -- when the associated Ada object is being destroyed.

   function is_valid (x : in c_resource) return C_Int;
   pragma Import (C, is_valid, "c_resource_is_valid");

   function net_allocations return Interfaces.C.int;
   pragma Import (C, net_allocations, "c_resource_net_allocations");

   package Unique_C_Resource is new Unique_C_Resources(T => c_resource,
                                                       Initialize => init,
                                                       Finalize => destroy);
   subtype Ada_Unique_Resource is Unique_C_Resource.Unique_T;

   package Smart_C_Resource is new Smart_C_Resources(T => c_resource,
                                                     Initialize => init,
                                                     Finalize => destroy,
                                                     Counters => Basic_Counters.Basic_Counters_Spec);
   subtype Ada_Smart_Resource is Smart_C_Resource.Smart_T;

begin

   -- Unique_C_Resources

   Put_Line("An example of using the Unique_C_Resources package to make a " &
           "resource from a C library safe"); New_Line;

   Put_Line("A resource is about to be created and should be initialised by "&
              "C code automatically."); Flush;
   declare
      Unique_Resource : Ada_Unique_Resource;
   begin
      Put_Line("Check status of resource: " &
               (if is_valid(Unique_Resource.Element) = 1 then "valid"
                  else "invalid"));
      Put("Net (allocations - deallocations) done in C:");
      Put(C_Int'Image(net_allocations)); New_Line;
      Put_Line("Resource should be destroyed by C code when the block ends.");
      Flush;
   end;

   Put_Line("Resource should have been freed.");
   Put("Net (allocations - deallocations) done in C are now:");
   Put(C_Int'Image(net_allocations)); New_Line;
   New_Line; Flush;

   -- Smart_C_Resources

   Put_Line("An example of using the Smart_C_Resources package to make a " &
           "resource from a C library safe"); New_Line;

   Put_Line("A resource is about to be created and should be initialised by " &
              "C code automatically."); Flush;
   declare
      Smart_Resource : Ada_Smart_Resource;
   begin
      Put_Line("Check status of resource: " &
               (if is_valid(Smart_Resource.Element) = 1 then "valid"
                  else "invalid"));
      Put("Net (allocations - deallocations) done in C:");
      Put(C_Int'Image(net_allocations)); New_Line; Flush;

      Put_Line("A copy of the first resource is now going to be created.");
      Flush;
      declare
         Smart_Resource_2 : constant Ada_Smart_Resource := Smart_Resource;
      begin
         Put_Line("Check status of copied resource: " &
                  (if is_valid(Smart_Resource_2.Element) = 1 then "valid"
                     else "invalid"));
         Put("Net (allocations - deallocations) done in C:");
         Put(C_Int'Image(net_allocations)); New_Line;
         Put_Line("No C resource should be destroyed when the copy is " &
                    "destroyed in Ada");
         Flush;
      end;
      Put("Net (allocations - deallocations) done in C:");
      Put(C_Int'Image(net_allocations)); New_Line;
      Put_Line("Resource should be destroyed by C code when the last copy " &
              "of the resource is destroyed in Ada.");
      Flush;
   end;

   Put_Line("Resource should have been freed.");
   Put("Net (allocations - deallocations) done in C are now:");
   Put(C_Int'Image(net_allocations)); New_Line;
   Flush;

end C_Resources_Example;
