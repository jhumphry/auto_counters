-- kvflyweights-basic_hashtables.adb
-- A package of non-task-safe hash tables for the KVFlyweights packages

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

package body KVFlyweights.Protected_Hashtables is

   use KVLists_Spec;

   protected body KVFlyweight is

      procedure Insert (Bucket : out Ada.Containers.Hash_Type;
                        K : in Key;
                        Key_Ptr : out Key_Access;
                        Value_Ptr : out Value_Access) is
      begin
         Bucket := (Hash(K) mod Capacity);
         Insert(L         => Lists(Bucket),
                K         => K,
                Key_Ptr   => Key_Ptr,
                Value_Ptr => Value_Ptr);
      end Insert;

      procedure Increment (Bucket : in Ada.Containers.Hash_Type;
                           Key_Ptr : in Key_Access) is
      begin
         Increment(L => Lists(Bucket),
                   Key_Ptr => Key_Ptr);
      end Increment;

      procedure Remove (Bucket : in Ada.Containers.Hash_Type;
                        Key_Ptr : in Key_Access) is
      begin
         pragma Assert(Check => Lists(Bucket) /= Empty_List,
                       Message => "Attempting to remove an element where the " &
                         "relevant bucket in the hashtable is null");
         Remove(L => Lists(Bucket),
                Key_Ptr => Key_Ptr);
      end Remove;

   end KVFlyweight;

   procedure Insert (F : aliased in out KVFlyweight;
                     Bucket : out Ada.Containers.Hash_Type;
                     K : in Key;
                     Key_Ptr : out Key_Access;
                     Value_Ptr : out Value_Access) is
   begin
      F.Insert(Bucket    => Bucket,
               K         => K,
               Key_Ptr   => Key_Ptr,
               Value_Ptr => Value_Ptr);
   end Insert;

   procedure Increment (F : aliased in out KVFlyweight;
                        Bucket : in Ada.Containers.Hash_Type;
                        Key_Ptr : in Key_Access) is
   begin
      F.Increment(Bucket  => Bucket,
                  Key_Ptr => Key_Ptr);
   end Increment;

   procedure Remove (F : in out KVFlyweight;
                     Bucket : in Ada.Containers.Hash_Type;
                     Key_Ptr : in Key_Access)is
   begin
      F.Remove(Bucket  => Bucket,
               Key_Ptr => Key_Ptr);
   end Remove;

end KVFlyweights.Protected_Hashtables;
