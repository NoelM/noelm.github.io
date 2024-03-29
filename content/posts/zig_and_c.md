+++
author = "Noël"
title = "Prime Numbers Algorithm, in Zig and C"
date = "2023-07-22"
draft = false
+++

A colleague of mine told me to try a new programming language named [Zig](https://ziglang.org/). It is designed
closely to C/C++ and is also inspired by Rust. I tried to learn Rust those last years as a replacement for C++.
However, the syntax is too complex for me, and I've struggled too much with the compiler...

I tried Zig a few days ago with [Zig Learn](https://ziglearn.org/), which is a detailed tutorial to understand the basics.
I found the syntax straightforward and easy to read, but the most important for me was easy to play with; in less than a couple of hours, I found
myself comfortable with the language! Actually, this is one of the objectives of Zig's philosophy. You can access it by typing
`zig zen` in your terminal:
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

## Installation

The complete [installation procedure](https://ziglang.org/learn/getting-started/#direct-download) is succinct.
On macOS I used `homebrew`, while on Linux I did this:
```bash
wget https://ziglang.org/download/0.10.1/zig-linux-x86_64-0.10.1.tar.xz
sudo tar xvf zig-linux-x86_64-0.10.1.tar.xz -C /usr/local/
sudo mv zig-linux-x86_64-0.10.1 zig 
```
Then I added to `~/.profile` or your favorite config file (`bashrc, zshrc, ...`):
```bash
export PATH=$PATH:/usr/local/zig
```

## Prime Number Algorithm

Zig is supposed to be [faster than C](https://ziglang.org/learn/overview/#:~:text=Speaking%20of%20performance%2C%20Zig%20is%20faster%20than%20C.) because of LLVM, I've found it odd:
> Speaking of performance, Zig is faster than C.
> * The reference implementation uses LLVM as a backend for state of the art optimizations.
> [...]

### Implementation

I thought that a good benchmark is a naive (computation-intensive) prime number algorithm up to 1 million.
The algorithm is quite simple; a prime number can be divided only by one or itself. So, for any prime-number
candidate `a`, I test from `2` to `a-1` if the modulus equals 0; if yes, the number is not prime.

Here are the two implementations in Zig and C:

#### Zig

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

#### C

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

### Compiling Rules

For sake of simplicity, the compiling rules are within a `Makefile`, those read as:

```makefile
all:
    zig build-exe prime.zig -O ReleaseFast
    clang -O3 prime.c
```

With the following versions:

```
➜ clang --version
Apple clang version 14.0.3 (clang-1403.0.22.14.1)
Target: arm64-apple-darwin22.5.0
Thread model: posix
InstalledDir: /Library/Developer/CommandLineTools/usr/bin

➜ zig version
0.10.1
```

## Performances

I ran my tests on a MacBook Pro, M1 10 cores, 32 GB of RAM. Here are the "one-shot" results:

| Lang | Modulus Tries | Total Duration (µs) | Modulus duration (ns) |
| ---- | ----        | ----     | ----  |
| Zig  | 37566404991 | 23 803 142 | 0.633 |
| C    | 37566404991 | 24 032 267 | 0.640 |

In conclusion, the benchmark shows a Zig code about 200 ms faster than C, and approximately 7 picoseconds faster
per modulus computation.

However, the difference is really small and during the test, my computer ran other processes. So I've reproduced
the benchmark 10 times each:

| Lang | Avg. Tot. Duration (µs) | StDev. Tot. Duration (µs) | Avg. Modulus Duration (ns) |
| ---- | ----       | ----    | ----  |
| Zig  | 23 410 056 | 15 747  | 0.623 |
| C    | 23 799 143 | 117 680 | 0.633 |

## Conclusion

A series of tests show that Zig is about 1.6% faster than C, and the execution duration fluctuates less in
Zig than in C. So it seems that the authors of Zig's documentation are right! This topic was also a thread of discussion
in [Y Combinator](https://news.ycombinator.com/item?id=21117669), and it contains a few more benchmarks.
