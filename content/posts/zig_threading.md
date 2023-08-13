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
[GitHub issue](https://github.com/ziglang/zig/issues/6025). So, the async support is expected for the release `0.13.0` by the
last milestone modification the 2023-08-06.

Finally, I was in the situation where:

* With `0.11.0` but I cannot use `Channel.get` because it has to be [awaited](https://ziglang.org/documentation/0.11.0/std/#A;std:event.Channel.get)
* With `0.10.0` I can use `async/await` but the `Channel` are not part of the language

Thus, I switched to the old-good solution of _threading_.

## Introduction

Previously, I benchmarked the [Zig versus C](https://noelmrtn.fr/posts/zig_and_c/) using a prime-number algorithm. This implementation
is purely single threaded. So, I sound interesting to test the same algorithm in a multi-threaded implementation. I learned concurrency
in C++ with the famous `std::thread` and OpenMPI.

The standard library of Zig has a type `std.Thread` that includes the basics of threading: `spawn`, `join`, `Mutex`... But also some
more advanced like [thread pools](https://ziglang.org/documentation/0.11.0/std/#A;std:Thread.Pool), which is absolutely not documented.
The only solution I've found was searching `Ctrl + Shift + F` on the Zig lang repository. However, I want to present you step-by-step
my implementation.

## Pool Type

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

### Allocator

Because the pool allocates as many thread as required, and in Zig you have not hidden allocations, an allocator is required!
Here, more specifically it must be thread-safe, it exists a type [`std.heap.ThreadSafeAllocator`](https://ziglang.org/documentation/0.11.0/std/#A;std:heap.ThreadSafeAllocator). I used the implementation from `build_runner.zig:19`

```zig
var single_threaded_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer single_threaded_arena.deinit();

var thread_safe_arena: std.heap.ThreadSafeAllocator = .{
    .child_allocator = single_threaded_arena.allocator(),
};
const arena = thread_safe_arena.allocator();
```
