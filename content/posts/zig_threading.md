+++
author = "Noël"
title = "Zig Threading Tutorial"
date = "2023-08-13"
draft = false
+++

## Prequel

With the release of Zig `0.11.0`, they introduced [channels](https://ziglang.org/documentation/0.11.0/std/#A;std:event.Channel)
like in Go. However, in the same release the announced that the support of
[async function is postponed](https://ziglang.org/documentation/0.11.0/#Async-Functions), and the related
[Github issue](https://github.com/ziglang/zig/issues/6025). So, the async support is expected for the release `0.13.0` by the
last milestone modification the 2023-08-06.

Finally, I was in the situation where:

* `0.11.0`, `Channel.get` is unusable because it has to be [awaited](https://ziglang.org/documentation/0.11.0/std/#A;std:event.Channel.get)
* `0.10.0`, `async/await` are available with the option `-fstage1` but the `Channel` are not part of the language

Thus, I switched to the good old solution of _threading_.

## Introduction

Previously, I benchmarked the [Zig versus C](https://noelmrtn.fr/posts/zig_and_c/) using a prime-number algorithm. This implementation
is single threaded. So, I sound interesting to test the same algorithm in a multi-threaded implementation.

The standard library of Zig has a type `std.Thread` that includes the basics of threading: `spawn`, `join`, `Mutex`... But also some
more advanced like [thread pool](https://ziglang.org/documentation/0.11.0/std/#A;std:Thread.Pool), which is absolutely not documented.
The only solution I've found was searching `Ctrl + Shift + F` on the Zig lang repository.

We will declare a pool of threads which compute synchronously for a integer candidate if it is prime or not. Each thread will read a
queue of integer candidates and return if the value is prime.

The complete implementation is published on [Github](https://github.com/NoelM/zig-playground/tree/main/prime_numbers_parallel).

## Thread-safe Structures

### Allocator

As you probably know, in Zig there is no hidden allocation. So, every time a type requires allocation, you must declare an allocator.
By default the allocator are single threaded and not suitable for concurrency. Allocator are similar to `malloc` functions in `C`, but
with more options: heap, fixed buffer, arena.

In our case here is an example of a thread-safe-arena allocator:

```zig
var single_threaded_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer single_threaded_arena.deinit();

var thread_safe_arena: std.heap.ThreadSafeAllocator = .{
    .child_allocator = single_threaded_arena.allocator(),
};
const arena = thread_safe_arena.allocator();
```

### Queues

You have a namespace `std.atomic` which contains a type `std.atomic.Queue(T: type)`. They allow multiple producers and readers at the
same time. You can safely call `put`, `get`, and `remove` from any thread. This queue contains nodes defined as:

```zig
pub const Node = struct {
    .prev: ?*Node = null,
    .next: ?*Node = null,
    .data: T,
}
```

When a pointer is prefixed with `?` it is called [_optional pointer_](https://ziglang.org/documentation/0.11.0/#Optional-Pointers),
it allows the value of the pointer to be `null` (by default not possible). When a function returns a `?*T`, you can either check
with an `if`:

```zig
if (optional_ptr) |ptr| {
    // acceded only if optional_ptr != null
    // the pointer address is casted to `ptr`
} else {
    // the optional_ptr = null
}
```

Or directly when accessing to the value:

```zig
const val = optional_ptr.?.*;
```

#### Initialize and Fill Queues

This is pretty easy to setup a thread-safe queue, first of all initialize it. Then allocate nodes with the previously defined
thread-safe allocator.

```zig
const U64Queue = std.atomic.Queue(u64);

var int_to_test = U64Queue.init();

const node: *Node = try arena.create(Node);
node.* = .{
    .prev = undefined,
    .next = undefined,
    .data = value,
};
int_to_test.put(node);
```
As one can see, we let the value 

#### Get Nodes from Queue

The elements in a `Queue` can be safely accessed from any thread of the program with the function `get`. It returns
an optional node pointer, because the queue can be empty. Thus when consuming test the returned values:

```zig
if (int_to_test.get()) |node| {
    const value = node.data;

    // do sth. with the data
} else {
    // empty queue
}
```

## Thread Pool

If you want to instantiate you need to declare it as:

```zig
const Pool = std.Thread.Pool;

var thread_pool: Pool = undefined;
try thread_pool.init(Pool.Options{
    .allocator = arena,   // this is an arena allocator from `std.heap.ArenaAllocator`
    .n_jobs = cpu_count,  // here I prefer to use as many thread as many CPUs
});
defer thread_pool.deinit();
```


Do not forget that the `try` in front of `thread_pool.init()` catches and return an error
if the function returns one. Whenever a function returns an error, you must [catch it](https://ziglearn.org/chapter-1/#errors).
The function that returns error returns a type `!T` where the `!` notifies a possible error returned instead of the type `T`.
