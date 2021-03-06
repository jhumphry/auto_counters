// c_resource_lib.c
// An example C resource that requires initialization and finalization, which
// needs wrapping for safe use from Ada

// Copyright (c) 2016, James Humphry
//
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
// REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
// AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
// INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
// LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
// OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
// PERFORMANCE OF THIS SOFTWARE.

#include <stdlib.h>
#include <stdio.h>

typedef struct { int ready; } c_resource_t;

typedef c_resource_t *c_resource;

int allocations = 0;

c_resource c_resource_init() {
  c_resource x;
  x = (c_resource)malloc(sizeof(c_resource_t));
  x->ready = 1;
  puts("Allocated a c_resource in C code!");
  ++allocations;
  return x;
}

int c_resource_is_valid(c_resource x) { return (x != 0) && (x->ready == 1); }

void c_resource_destroy(c_resource x) {
  free(x);
  --allocations;
  puts("Freed a c_resource in C code!");
}

int c_resource_net_allocations() { return allocations; }
