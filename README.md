# Auto_Counters

## Introduction

This is an Ada 2012 project that implements reference counting approaches to
resource management with an emphasis on safety and usability. The project is
licensed under the ISC licence - see the file LICENSE for details.

## `Smart_Ptrs`

This generic package is based on the `smart_ptr` and `weak_ptr` types in C++.
When it is instantiated it provides three types:

 - `Smart_Ptr` - this is a classic smart pointer type which either points to
 an allocated object or is a null pointer. It can be reassigned to point to
 different objects. `Smart_Ptr` can be duplicated, passed around and
 destroyed. When the last `Smart_Ptr` pointing to an object is destroyed, the
 object will be automatically destroyed and the allocated space reclaimed.

 - `Smart_Ref` - this is a generalised reference type that inter-operates with
 the `Smart_Ptr` type and shares the same reference counters. It has the
 advantage that an Ada compiler will implicitly dereference it where
 appropriate. However due to the rules surrounding generalised reference types
 in Ada it cannot be reassigned to point to another object after creation.
 Null `Smart_Ref` would not be very useful so are not permitted.

 - `Weak_Ptr` - these can only be created from non-null `Smart_Ptr` or
 `Smart_Ref` values. They do not prevent the target object from being
 destroyed and the storage reclaimed when all associated `Smart_Ptr` and
 `Smart_Ref` are destroyed or reassigned. However, if this has not happened it
 is possible to create new `Smart_Ptr` or `Smart_Ref` types from a `Weak_Ptr`.
 `Weak_Ptr` are useful when circular references between objects are needed, as
 otherwise the objects would never be destroyed.

A set of `Make_Smart_Ptr` (etc) creation functions exist. A `Smart_Ptr`
created without using one of these functions will be a null pointer, but the
use of the functions is mandatory for the other types.

Reference counts will only be shared between multiple pointers if they are
created from one another. Creating multiple `Smart_Ptr` or `Smart_Ref` from a
raw access value to an object will give multiple reference counters, and the
object will be destroyed when the first of these counters hits zero. This
will give unpredictable and probably erroneous results. A similar problem
occurs if `Smart_Ptr` and raw access values are mixed in a program.

The formal parameters of the `Smart_Ptrs` package are as follows:

```ada
 generic
   type T (<>) is limited private;
   type T_Ptr is access T;
   with package Counters is new Counters_Spec(T => T,
                                              T_Ptr => T_Ptr,
                                              others => <>);
   with procedure Delete (X : in out T) is null;
package Smart_Ptrs
```

Types `T` is the type of the values to which the `Smart_Ptr` will be pointing.
`T_Ptr` is a named access type for type `T`. `Counters` is a package meeting
the `Counters_Spec` specification that provides an implementation of the
underlying reference counters. By choosing which package is used, properties
of the counters such as their task-safety can be selected at compile-time.
`Delete` is an optional procedure that will be run on the underlying resource
before it is destroyed with `Ada.Unchecked_Deallocation`. This may be more
convenient than making type `T` a controlled type.

### `Counters_Spec`, `Basic_Counters` and `Protected_Counters`

The `Counters_Spec` package describes the functions and procedures that are
needed for a type to be usable as the counter. `Basic_Counters` and
`Protected_Counters` are non-task-safe and task-safe implementations
respectively. The child packages `Basic_Counters_Spec` and
`Protected_Counters_Spec` can be used to instantiate `Smart_Ptrs`.

Note that while `Protected_Counters` has been designed so that simultaneous
changes to reference counts from multiple tasks will not cause corruption, the
pointers themselves are not protected and should not be shared between tasks.
Also, the task-safety of the pointed-to object is outside the scope of this
project.

### `Basic_Smart_Ptrs` and `Protected_Smart_Ptrs`

These convenience packages can be instantiated with just a reference to a type
`T` and an optional `Delete` procedure. The child package `Ptr_Types` will be
created with usable `Smart_Ptr`, `Smart_Ref` and `Weak_Ref` types. Either this
child package can be `use`d or, to prevent namespace pollution, they can be
renamed into the current scope with suitable unconstrained `subtype`
declarations.

## `Unique_Ptrs`

This generic package declares two simple types which are somewhat similar to
the `unique_ptr` type in C++. Only one `Unique_Ptr` can be created for a given
object, making them much simpler to implement than the `Smart_Ptrs` types. In
essence this package provides a fast way to create a `Limited_Controlled` type
from an uncontrolled type. A `Delete` procedure can be provided on
instantiation if additional work is required before `Finalization`.

 - `Unique_Ptr` - this is a generalised reference type which points to an
 object allocated on the heap. It is a limited type so it cannot be
 reassigned. When it is destroyed, the object it points to will be destroyed
 and the associated storage will be reclaimed. They can only be created using
 the `Make_Unique_Ptr` function in order to ensure that they are only pointed
 at allocated objects, and not static or local objects.

 - `Unique_Const_Ptr` - this functions in a similar manner to `Unique_Ptr`
 except that the target is declared as `constant`. Note that despite this,
 `Make_Unique_Const_Ptr` requires a pointer to a non-constant value as the
 value will be changed by the `Delete` procedure, if present, and by the final
 `Ada.Unchecked_Deallocation`.

As with `Smart_Ptrs`, creating two `Unique_Ptr` from a raw access value will
probably lead to errors and should be avoided.

## `Smart_C_Resources` and `Unique_C_Resources`

It is common for libraries exporting an API written in C to follow a pattern
of requiring a context or resource handle to be passed to routines. Typically
these resource handles are pointers to opaque, hidden, 'struct's which are
created by a library routine and hold pointers to internally allocated
resources. They must be passed to another library routine when no longer
needed so the resources can be released.

`Smart_C_Resources` and `Unique_C_Resources` are generic packages that wrap
these handles inside Ada Controlled types and ensure that they are
automatically initialized before use and destroyed after use. The `Unique_T`
type prevents more than on Ada value existing for a given C resource, whereas
the `Smart_T` type uses one of the reference counting packages discussed above
to allow copying while ensuring the resources are released at the correct
point. It is expected that in normal use one of the packages would be
instantiated and then either the `Smart_T` or `Unique_T` type would be renamed
to something more meaningful in the user package. Alternatively the type could
be used as the base for a 'thick' Ada binding, with wrappers around the C
library routines added to types derived from one of the types.

## Flyweights

The interchangeable packages ```Basic_Refcounted_Flyweights```,
```Basic_Untracked_Flyweights```, ```Protected_Refcounted_Flyweights``` and
```Protected_Untracked_Flyweights``` implement the flyweight pattern. The aim
is to prevent the duplication of values and the associated memory usage in the
case where large resources may be required by or referred to by many parts of
a program. A ```Flyweight``` keeps track of these resources and ensures that
each is only stored once.

The ```Flyweight``` types work by maintaining a hash-table of the values
already stored. When an access value pointing to a new value is passed to the
```Insert``` functions this hash-table is checked. If the value is not already
present it is added to the hash-table. If the value already exists in the
hash-table the new value passed to the function will be deleted and the
existing value returned. The return value from the functions can be a wrapped
pointer type or a generalised reference type. Functions are provided to
convert between the two types and to access the underlying value.

The distinction between the 'basic' and 'protected' packages is in whether the
```Flyweight``` objects can cope with resources being added and deleted from
different tasks concurrently. Note that simply using (de-referencing) one of
the pointers or reference types does not require interaction with the
```Flyweight``` so this is not affected. In either case the task-safety of the
underlying resource itself remains the responsibility of the package user.

The distinction between the 'Refcounted' and 'Untracked' packages relates to
how the associated resources are managed. 'Refcounted' packages operate in a
similar manner to the ```Smart_Ptr``` packages - the pointers and reference
types are reference-counted so that when the last pointer to a resource is
destroyed the resource will be deleted and the associated storage will be
deallocated. The types in the 'Untracked' packages do not do this, so any
resources stored inside the ```Flyweight``` are not released until the program
ends. Note that the 'Untracked' packages will still deallocate duplicate
values passed into one of the ```Insert``` functions.

## KVFlyweights

The packages for KVFlyweights (Key-Value Flyweights) work in a very similar
manner to the Flyweights. The main distinction is that the KVFlyweights
associate every resource with a key. A factory function must be provided to
return the value associated with a key. Rather than inserting values directly
into KVFlyweights, keys are inserted. If a key is not already present the
associated value will be obtained via the factory function and stored. The
generation of values from keys must be deterministic, so each key-value pair
only has to be stored once. This allows comparison to be done on keys, which
may be much faster than comparing the values for equality.

A typical use-case for KVFlyweights might be for the keys to be ```String```s
giving the filenames of resources, and for the factory function to load and
return the resource from the file with the provided filename. The KVFlyweight
will only load the file the first time one of the Insert functions is called,
and subsequent Insert calls will return a pointer to the existing object.

## Examples and unit tests

Various simple example programs and a suite of AUnit-based unit tests with
good coverage are provided.

## Build files

Two GPRbuild project files are provided. `auto_counters.gpr` builds the core
packages and `auto_counters_examples.gpr` builds the examples and unit test
routines. There is a external variable `mode` which has four possible
settings:

 - `debug` (default) - build with many checks, assertions and compiler
 warnings enabled.

 - `memdebug` - as with `debug` but includes support for the `gnatmem` tool
 which can be used to check if the example and unit test programs leak any
 memory. When used on the unit tests, any memory leaks inside AUnit should be
 ignored.

 - `coverage` - as with `debug` but make executables produce traces so `gcov`
 can produce coverage information.

 - `optimize` - build with checks and assertions turned off and optimization
 turned on.

The project file `auto_counters.gpr` is not a library project file, and so can
only function as a sub-project included within another project. In this case,
building the routines directly into the code that uses them is probably more
sensible than building an intermediate library, given the small size of each
type's support code and the increased opportunities presented for inlining and
optimization.
