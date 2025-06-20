# BrainFuck Zero

BrainFuck Zero (`bfz` for short), is a fully functional Brainfuck interpreter, written in under 500 bytes.

It is written in pure Intel syntax x86-64 assembly.

## How does this work?

Rather than using a linker at all, `bfz` has an ELF64 header encoded directly into the binary.

This means the linker never needs to be run, minimising size. It can just be assembled as a raw binary (using NASM at the moment), and run.

If you want to see a more techinal view of the program, either read `bfz_elf64.asm` or the technical documentation `TECHNICAL.md`.

## Building

You will need to assemble it yourself. Thankfully, it is very easy to do.

### Prerequisites

- A x86-64 Linux (or compatible, see below) system
- NASM
- 1-2 KiB of free hard drive space

**NOTE**: While bfz is designed for Linux, it may work on other *nix systems, provided they have an ELF64 loader.

### Obtaining the Source

Run something like:

```sh
git clone https://github.com/OldUser101/bfz
```

Or download the source from GitHub any other way you want.

### Assembling

Change into the source directory and simply run:

```sh
nasm -f bin bfz_elf64.asm -o bfz
```

This will assemble the BrainFuck Zero binary `bfz`.

You will probably need to make it executable as well:

```sh
chmod +x bfz
```

## Usage

`bfz` is incredibly lightweight, thus, it only has one argument. 

```
bfz <source file>
```

The source file is any plaintext Brainfuck file.

If you do not specify any arguments, or specify too many, `bfz` will exit without running your program.

`bfz` doesn't do any sanity checking beyond this, so badly written programs may crash it.

An example of something that will crash `bfz` is simply:

```
[
```

Since `[` moves to the next matching `]` if the current data is zero, and there is no matching `]`, 
`bfz` will just run off the end of the program, until it finds one, or causes a segfault.

## Copyright

BrainFuck Zero © 2025, Nathan Gill. See LICENSE for details.
