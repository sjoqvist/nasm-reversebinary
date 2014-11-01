NASM Implementation of Reversed Binary Numbers
==============================================
Introduction
------------
This is a simple x86 assembly program that solves the puzzle [Reverse
Binary Numbers](https://open.kattis.com/problems/reversebinary) as seen
on [Open Kattis](https://open.kattis.com/). It compiles to a statically
linked ELF32 executable (Linux) for the Intel 80386 architecture. Since
ELF32 is forward compatible, it will compile and run on x86-64 Linux
distributions as well.

Basically, the program reads a decimal integer _N_, where
1≤_N_≤1,000,000,000. It reverses the integer's binary representation,
and writes back the result in its decimal form. For example, 13 ("1101")
returns 11 ("1011") and 47 ("101111") returns 61 ("111101").

Note that Kattis doesn't permit solutions in assembly language, so this
project can't really help you to cheat. Anyone who can read and
understand this code could surely also have solved the problem in
another language without assistance.

Details about the implementation can be found in the source code.

Building
--------
Install the basic build tools (from which you need `make` and `ld`) and
`nasm` on your Linux machine. Then, in the project directory, run

```
make
```

What this project is not
------------------------
* _An instruction on how to create small executables._ The machine code
  version of the program is 86 bytes long, but the executable is around
  396 bytes. There are ways to create ELF files with less overhead than
  that by handcrafting them.
* _An example of completely optimized code._ I'm sure there's room for
  more optimizations. Readability was taken into account, and the I only
  removed some obvious redundancies.
* _An example of how to write robust code._ There are no checks in place
  to verify the validity of the input.
* _An example of how to do anything in real life._ I wrote this just for
  fun. There are definitely uses for assembly language, but this is not
  one of them. Play around with the project as much as you want, but
  remember that you should rarely have to consider writing a program
  purely in assembly language nowadays. When you do, it'll most likely
  be for an embedded system, and not for server/desktop/laptop.
