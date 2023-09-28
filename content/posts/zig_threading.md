+++
author = "Noël"
title = "Zig Threading Tutorial"
date = "2023-08-16"
draft = false
+++

## Prequel

With the release of Zig `0.11.0`, the language introduced [channels](https://ziglang.org/documentation/0.11.0/std/#A;std:event.Channel)
like in Go. However, in the same release, they announced that the support of
[async function is postponed](https://ziglang.org/documentation/0.11.0/#Async-Functions) (related
[Github issue](https://github.com/ziglang/zig/issues/6025)). They expect the support of async functions by the `0.13.0`.

I initially wanted to test channels, but I'm in this situation:

* `0.11.0` gets `Channel`, but unusable because it requires [await](https://ziglang.org/documentation/0.11.0/std/#A;std:event.Channel.get) functions
* `0.10.0` gets `async/await` support with the option `-fstage1`, but the `Channel` is not part of the language

So, I switched to the solution of _thread pools_.

## Introduction

In a previous post, I benchmarked [Zig versus C](https://noelmrtn.fr/posts/zig_and_c/) with a naive prime-number algorithm.
It used to be a single-thread implementation. Now, the goal is porting it into multi-threading.

The standard library of Zig has a type `std.Thread` that includes the basics of threading: `spawn`, `join`, `Mutex`... But also some
more advanced ones like [thread pool](https://ziglang.org/documentation/0.11.0/std/#A;std:Thread.Pool). Tread pools are not documented yet,
and this tutorial intends to be one proposition.

The following implementation consists of a pool of threads waiting for a task to be executed. In our case, a task tests whether an integer is
prime or not. I will present two possible implementations: one with manually spawned threads and the other one with the help
of `std.Thread.Pool`.

The complete code is published on [Github](https://github.com/NoelM/zig-playground/tree/main/prime_numbers_parallel).

## Thread-safe Structures

### Allocator

In Zig, there is no hidden allocation. Every memory allocation is performed by an allocator of type `std.mem.Allocator`. It is
similar to the `malloc` function in `C` with more options: heap, fixed buffer, arena...

By default, the allocators are single-threaded and not suitable for concurrency. A thread-safe allocator reads as:

```zig
var single_threaded_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer single_threaded_arena.deinit();

var thread_safe_arena: std.heap.ThreadSafeAllocator = .{
    .child_allocator = single_threaded_arena.allocator(),
};
const arena = thread_safe_arena.allocator();
```

### Queues

The standard library (_stdlib_) provides a type `std.atomic.Queue(T: type)`. It allows multiple producers and readers to access
it concurrently, with functions: `put`, `get`, `remove`... Every item of the queue is of type `Node`:

```zig
pub const Node = struct {
    .prev: ?*Node = null,
    .next: ?*Node = null,
    .data: T,
}
```

A `?`-prefixed pointer is a so-called [_optional pointer_](https://ziglang.org/documentation/0.11.0/#Optional-Pointers),
and it allows its memory address to be null (by default, a pointer in Zig is not nullable).

To deal with an optional pointer `?*T` you must check whether it points to a memory location or not.
One of the options is within an `if` statement:

```zig
if (optional_ptr) |ptr| {
    // acceded only if optional_ptr != null
    // the pointer address is casted to `ptr`
} else {
    // the optional_ptr = null
}
```

Or directly when accessing the value:

```zig
const val = optional_ptr.?.*;
```

#### Initialize and Fill Queues

It is pretty easy to set up a thread-safe queue. First of all, initialize it. Then, allocate nodes with the previously defined
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

As one can see, we set the values `.prev` and `.next` to `undefined` because the function `put` sets them correctly.

#### Get Nodes from Queue

The elements in a `Queue` can be safely accessed from any thread with the function `get`. It returns
an optional node pointer because the queue might be empty. So, testing the value of the returned `Node` is mandatory:

```zig
if (int_to_test.get()) |node| {
    const value = node.data;
    // do sth. with the data
} else {
    // empty queue
}
```

## Thread Pool

A thread pool aims to optimize the number of running threads. Instead of popping a new thread for each task, it maintains
a pool of threads waiting for tasks without being stopped.

### Manual

First, I create a slice (a slice and not an array because its size cannot be evaluated at compilation) of `std.Thread`.

```zig
var pool = try arena.alloc(std.Thread, cpu_count);
defer arena.free(pool);

for (pool) |*thread| {
    thread.* = try std.Thread.spawn(.{}, isPrimeRoutine, .{ &int_to_test, &int_prime });
}
```

Each thread runs a function `isPrimeRoutine`. This function reads a queue, tests the queued values, and returns when the queue is empty.

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

The example shows an interesting behavior of queues, as `int_to_test.get()` returns a pointer that is not deallocated.
So, you can reuse it as a new node of `is_prime`, reminding you to reset `.prev` and `.next`.

Finally, the classical `.join()` waits for all threads to end.

```zig
for (pool) |thread| {
    thread.join();
}
```

{{<hint>}}
Previously, I presented an `arena` thread-safe allocator. The current implementation does not require a thread-safe
allocator anymore.
{{</hint>}}

`prime_manual.zig`: [Github](https://github.com/NoelM/zig-playground/blob/main/prime_numbers_parallel/prime_manual.zig)

### Standard Library

The type `std.Thread.Pool` from the _stdlib_ maintains a pool of threads. But instead of
putting integer to a queue, we spawn tasks (calls to a function) queued in a `RunQueue`.

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
Do not forget that the `try` in front of `thread_pool.init()` catches the function's error.
Whenever a function returns an error, you must [catch it](https://ziglearn.org/chapter-1/#errors). Those functions
return `!`-prefixed values.
{{</hint>}}

Instead of spawning a task per integer, I spawn them in batches. Testing a single integer is too small
compared to the effort required to spawn a task. Otherwise, it would spoil more computation power into spawning a task
than testing the integer itself.

```zig
const value_max: u64 = 1000000;
const shard_size: u64 = 1000;

var value: u64 = 0;
while (value < value_max) : (value += shard_size) {
    try thread_pool.spawn(isPrimeRoutine, .{ &wait_group, &arena, value, shard_size, &int_prime });
}
```

Each task will verify from `[value ; value + shard_size[` all the possible prime numbers. In contrast with
the previous example, now it requires a thread-safe allocator to create new nodes.

#### Wait Group

The thread pool does not have a public `join` member but gets a `waitAndWork` instead, which requires a
wait group (the _stdlib_ got one). It may sound odd, but mind to `reset` the wait group before using it.
Because it contains an `std.Thread.ResetEvent` not initialized by default.

```zig
const WaitGroup = std.Thread.WaitGroup;

var wait_group: WaitGroup = undefined;
wait_group.reset();

// create thread pool, spawn tasks

thread_pool.waitAndWork(&wait_group);
```

`prime_std.zig`: [Github](https://github.com/NoelM/zig-playground/blob/main/prime_numbers_parallel/prime_std.zig)

## Performances

_Soon_
