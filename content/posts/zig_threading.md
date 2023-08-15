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

As one can see, we let the values `.prev` and `.next` to `undefined`, then the function `put` will set the correct values.

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

A thread pool is designed to optimize the number of running threads. Instead of popping a thread for any task, it maintains
a pool of thread waiting for a task without being stopped.

### Manual

First, I create a slice (because it size cannot be evaluated at compilation) of `std.Thread`.

```zig
var pool = try arena.alloc(std.Thread, cpu_count);
defer arena.free(pool);

for (pool) |*thread| {
    thread.* = try std.Thread.spawn(.{}, isPrimeRoutine, .{ &int_to_test, &int_prime });
}
```

Each thread runs a function `isPrimeRoutine` which reads a queue containing values to be tested. The loop quits when
the queue is empty, because it means no more work.

```zig
pub fn isPrimeRoutine(int_to_test: *U64Queue, int_prime: *U64Queue) void {
    while (true) {
        if (int_to_test.get()) |node| {
            const value = node.data;

            var is_value_prime = true;
            var i: u64 = 2;
            while (i < value) : (i += 1) {
                if (value % i == 0) {
                    is_value_prime = false;
                    break;
                }
            }

            if (is_value_prime) {
                node.prev = undefined;
                node.next = undefined;
                int_prime.put(node);
            }
        } else {
            // empty queue
            return;
        }
    }
}
```

This example shows an interesting behavior of queues, as `int_to_test.get()` returns a pointer. It is not deleted
by the function, still allocated. So, you can reuse it as a new node of `is_prime` thanks to reset `.prev` and
`.next`.

Finally, we use the classical `.join()` function which waits for threads to end.

```zig
for (pool) |thread| {
    thread.join();
}
```

{{<hint>}}
Previously, I presented the thread-safe allocator with the name `arena`. In this implementation, a thread-safe
allocator is not required.
{{</hint>}}

`prime_manual.zig`: [Github](https://github.com/NoelM/zig-playground/blob/main/prime_numbers_parallel/prime_manual.zig)

### Standard Library

We propose to compare and use the standard-library implementation. It is not documented, but its purpose is to maintain
a pool of threads, and spawning tasks; they are queued within a `RunQueue`. The instantiation is quite simple:

```zig
const Pool = std.Thread.Pool;

var thread_pool: Pool = undefined;
try thread_pool.init(Pool.Options{
    .allocator = arena,   // this is an arena allocator from `std.heap.ArenaAllocator`
    .n_jobs = cpu_count,  // optional, by default the number of CPUs available
});
defer thread_pool.deinit();
```

{{<hint>}}
Do not forget that the `try` in front of `thread_pool.init()` catches and return an error
if the function returns one. Whenever a function returns an error, you must [catch it](https://ziglearn.org/chapter-1/#errors).
The function that returns error returns a type `!T` where the `!` notifies a possible error returned instead of the type `T`.
{{</hint>}}

Instead of spawning a task per integer, I shard them. Actually, testing a single integer is a too small task compared to
spawning the task itself.

```zig
const value_max: u64 = 1000000;
const shard_size: u64 = 1000;

var value: u64 = 0;
while (value < value_max) : (value += shard_size) {
    try thread_pool.spawn(isPrimeRoutine, .{ &wait_group, &arena, value, shard_size, &int_prime });
}
```

Each task will verify from `value` to `value + shard_size` all the possible prime numbers. In contrast with
the previous example, here one requires an allocator to create new nodes. This allocator is called simultaneously
from each thread, so, ensure it is a thread-safe one.

#### Wait Group

The thread pool does not have a public `join` member, but it gets `waitAndWork` instead, and it requires a
wait group (the _stdlib_ contains an implementation of wait groups). First of all, you should `reset` your
wait group before using it. Actually, it contains an `std.Thread.ResetEvent` which is not initialized by default.

```zig
const WaitGroup = std.Thread.WaitGroup;

var wait_group: WaitGroup = undefined;
wait_group.reset();

// create thread pool, spawn tasks

thread_pool.waitAndWork(&wait_group);
```

`prime_std.zig`: [Github](https://github.com/NoelM/zig-playground/blob/main/prime_numbers_parallel/prime_std.zig)