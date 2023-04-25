# Simple Forth Interpreter
An interpreter for the Forth programming lanuage, written in Ruby.

## Description

This is an interpreter for the Forth programming language. It is a simple
interpreter written for learning purposes, as part of the course *Programming
Languages* at the University of Victoria.

To ensure compatability when evaluating / testing, this interpreter was designed and is intended to be executed on a POSIX system. It is written in Ruby, and is intended to be executed with the Ruby interpreter.

It has been tested with: ruby 3.0.2p107 (2021-07-07 revision 0db68f0233)
[x86_64-linux-gnu].

## Usage

A series of sample programs has been provided in the `programs/` directory. Tests have been provided in the `tests/` directory. To understand how to write Forth programs, please refer to the `programs/` directory for examples, more information can be found on the [Forth Wikipedia page](https://en.wikipedia.org/wiki/Forth_(programming_language)).


To run the interpreter, simply execute the `forth.rb` file with the Ruby interpreter, then pipe the Forth program into the interpreter. For example:

```bash
ruby forth.rb < programs/basic.fth
```
It is expected that you provide the location of a Forth program file as input to the interpreter. The interpreter will then execute the program, and print the result to standard output.

Alternatively you can run the interpreter without providing a Forth program file,
and instead type the program directly into the interpreter. For example:

```bash
ruby forth.rb
1 2 + .
CTRL-D
3
```

There is no REPL behaviour implemented, so you must provide the entire program
at once, and then signify the end-of-input with CTRL-D.


