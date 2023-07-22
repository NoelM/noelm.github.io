+++
author = "Noël"
title = "Prime Numbers Algorithm, in Zig and C -- Part I"
date = "2023-07-22"
draft = false
+++

_Draft, in progress_

A colleague of mine told me to try a new programming language named [Zig](https://ziglang.org/). It is designed
closely to the C/C++ and also inspired by Rust. I tried to learn Rust those last years as a replacement for C++,
however the syntax was too hard for me, and I've struggled too much with the compiler...

I tried Zig a few days ago with [Zig Learn](https://ziglearn.org/) which is an enough detailed tutorial to understand the basics.
I found the syntax clear and easy to read, but the most important for me, easy to code with!
The philosophy behind the language is named the Zen of Zig and accessible with `$ zig zen` in your terminal:
```
* Communicate intent precisely.
* Edge cases matter.
* Favor reading code over writing code.
* Only one obvious way to do things.
* Runtime crashes are better than bugs.
* Compile errors are better than runtime crashes.
* Incremental improvements.
* Avoid local maximums.
* Reduce the amount one must remember.
* Focus on code rather than style.
* Resource allocation may fail; resource deallocation must succeed.
* Memory is a resource.
* Together we serve the users.
```

## Prime number algorithm

It supposed to be [faster than C](https://news.ycombinator.com/item?id=21117669) because of LLVM, I've found it odd. Thus I wanted to try.
I though a good benchmark is a naive prime number algorithm up to 1 million.

I did two implementations, one in Zig, one in C. The algorithm is quite simple in both case:
```zig
pub fn isPrime(int: u64, stats: *Stats) bool {
    const start = std.time.nanoTimestamp();

    var i: u64 = 2;
    var is_prime = true;
    while (i < int) : (i += 1) {
        if (int % i == 0) {
            is_prime = false;
            break;
        }
    }

    updateStats(stats, i - 2, std.time.nanoTimestamp() - start);
    return is_prime;
}
```
and on the other hand:
```c
bool isPrime(uint64_t val, struct Stats* s) {
    clock_t start = clock();

    int i;
    bool is_prime = true;

    for(i = 2; i < val; i++) {
        if (val % i == 0) {
            is_prime = false;
            break;
        }
    } 

    updateStats(s, i - 2, clock() - start);
    return is_prime;
}
```
The complete implementations are [here](https://github.com/NoelM/zig-playground/tree/main/prime_numbers).

## Performances

For the C, at the end of the execution one reads:
```
id: 1000000, total_tries:37566404991, mean_tries:37566.441406, max_tries:999981, total_dur_µs:47239117, mean_dur_µs:37566.441406, max_dur_µs:1297
```
while for Zig
```
id:1000000, total_tries:37566404991, mean_tries:3.7566442557442555e+04, max_tries:999981, total_dur_ns:106620356000, mean_dur_ns:1.0662046262046263e+05, max_dur_ns:47848000
```
both ran on a MacBook Pro M1 2022, 10 cores, 32 GB of RAM.

Thus finally, for the exact same number of modulus computations (37566404991), it costed 47 seconds to the C program, while it costed 107 seconds.
**But why? That's the next part of the article**
