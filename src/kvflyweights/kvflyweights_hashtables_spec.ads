-- kvflyweights_hashtables_spec.ads
-- A specification package that summarises the requirements for hashtables
-- used in the KVFlyweights

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

with Ada.Containers;

generic
   type Key(<>) is private;
   type Value_Access is private;
   type KVFlyweight is limited private;
   with function Insert (F : aliased in out KVFlyweight;
                         Bucket : out Ada.Containers.Hash_Type;
                         K : in Key) return Value_Access;
   with procedure Increment (F : aliased in out KVFlyweight;
                             Bucket : in Ada.Containers.Hash_Type;
                             Data_Ptr : in Value_Access);
   with procedure Remove (F : in out KVFlyweight;
                          Bucket : in Ada.Containers.Hash_Type;
                          Data_Ptr : in Value_Access);
package KVFlyweights_Hashtables_Spec is

end KVFlyweights_Hashtables_Spec;
