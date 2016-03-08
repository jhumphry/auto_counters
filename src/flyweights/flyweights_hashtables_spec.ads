-- flyweights_hashtables_spec.ads
-- A specification package that summarises the requirements for hashtables
-- used in the Flyweights

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
   type Element_Access is private;
   type Flyweight is limited private;
   with procedure Insert (F : aliased in out Flyweight;
                          Bucket : out Ada.Containers.Hash_Type;
                          Data_Ptr : in out Element_Access);
   with procedure Remove (F : in out Flyweight;
                          Bucket : in Ada.Containers.Hash_Type;
                          Data_Ptr : in Element_Access);
package Flyweights_Hashtables_Spec is

end Flyweights_Hashtables_Spec;
