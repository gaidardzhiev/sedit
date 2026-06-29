# SEDIT

SEDIT is a stack first programming language whose interpreter is written in `sed`. The project treats `sed` not as a toy text filter but as a rigorous computational substrate: its pattern space becomes the active execution state, its hold space becomes auxiliary memory, and its branching and substitution commands become the control machinery of a real interpreter.

## Status

The project is in initial design phase. The interpreter does not exist yet. This document is the specification and the commitment.

## On the Inversion of Method

A language implemented in `sed` is not a novelty for its own sake. It is an inquiry into whether a stream editor, with only line oriented transformation, two persistent buffers, and a small command vocabulary, can sustain the architecture of a higher order language. SEDIT answers that question by building a stack language on top of `sed`'s own primitives, so that the interpreter and the interpreted language arise from the same formal economy.

The result is a peculiar but disciplined recursion: `sed` edits text, SEDIT manipulates a stack, and the interpreter itself is expressed through `sed`'s transformation cycle.

## The Principle

SEDIT rejects the comforts of contemporary mainstream language design. The language is concatenative and explicit: values are pushed, words consume and produce stack effects, and quoted blocks carry executable code as first class data. A program is not a tree of expressions but a sequence of transformations, each one visible in the order it occurs.

This makes SEDIT severe, but also honest. The logic of the machine is never hidden behind decorative syntax. Everything that can be stated directly is stated directly.

## The Approach

One interpreter: the `sed` interpreter. It reads SEDIT source, rewrites it into internal command forms, and executes those forms against a stack based runtime held in `sed`'s pattern and hold spaces. There is no compilation stage in the conventional sense, only a disciplined sequence of pattern space transformations.

Everything is done manually in the interpreter:
- Lexer: tokenization via `sed` pattern matching and substitution.
- Parser: block and quotation structure recognized by explicit delimiters.
- Runtime: data stack represented in textual form.
- Memory: auxiliary state kept in hold space and selected encoded variables.
- Dispatch: command execution driven by `b`, `t`, labels, and substitution results.

Uses `sed` primitives:
- Pattern space and hold space for runtime state.
- `s` for rewriting and decoding.
- `h`, `H`, `g`, `G`, `x` for state transfer.
- `b`, `t`, `T`, labels for branching and flow control.
- `n`, `N`, `d`, `D`, `p`, `P`, `q` for cycle management.

## The Language

SEDIT is a minimal stack language in the concatenative tradition. Its syntax is intentionally bare: values are pushed, words are executed, and quoted blocks defer execution until a word explicitly consumes them. The language is designed so that its own interpreter can remain small, legible, and expressible in `sed`.

Every feature exists only if it serves that goal:
- Literals push themselves.
- Words execute left to right.
- Quoted blocks are data until called.
- Control flow is composed from explicit stack effects.
- Functions are named quotations.
- No hidden coercions, no precedence, no syntactic mercy.

## The Grammar

The grammar is compact and unforgiving:
- `123` pushes a number.
- `"text"` pushes a string.
- `true` and `false` push booleans.
- `word` executes a primitive or user-defined word.
- `[ ... ]` creates a quoted block.
- `def name [ ... ]` binds a quotation to a name.
- `call` executes a quotation on the stack.
- `if` consumes a condition and two blocks.
- `while` consumes a test block and a body block.

## Runtime Model

The runtime is intentionally minimal:
- A data stack for values.
- A call stack for nested execution.
- A dictionary mapping names to quotations.
- A pattern space representation of current state.
- A hold space representation of persistent auxiliary state.

This design embraces `sed`'s own execution cycle rather than pretending to be a different machine. The interpreter does not fight the host; it formalizes it.

## Core Words

The first implementation begins with a small and complete vocabulary:
- Stack: `dup`, `drop`, `swap`, `over`, `rot`.
- Arithmetic: `add`, `sub`, `mul`, `div`, `mod`.
- Comparison: `eq`, `ne`, `lt`, `le`, `gt`, `ge`.
- Boolean: `and`, `or`, `not`.
- Control: `call`, `if`, `while`, `exit`.
- State: `store`, `load`.
- Text: `cat`, `len`, `split`, `join`, `substr`.
- I/O: `print`, `read`.

The intention is not breadth but sufficiency. The core must be strong enough to write real programs and small enough to be self hosted in principle.

## Quoted Blocks

Quoted blocks are the language's central abstraction. They are not syntax containers; they are executable values that can be stored, passed, and invoked. Quotation is the bridge between syntax and behavior, between text and action.

A stack language becomes expressive only when code itself can move through the stack as data. Without quotations, the language is a calculator. With them, it is a control system.

## Control Flow

Control flow in SEDIT is explicit and stack driven. A conditional is a word with a fixed stack contract. A loop is a repeated quotation execution governed by a boolean result. There is no hidden parser level branching, only visible runtime behavior.

Control words:
- `if` for branching.
- `while` for repetition.
- `call` for quotation execution.
- `exit` for termination.

## Why `sed`

`sed` is an apt host because it already works as a stateful transformer over text, with a small but expressive command set and a clear cycle of reading, transforming, branching, and printing. Its pattern space and hold space provide just enough persistence to model state, while its substitution and branching commands provide the control skeleton needed for interpretation.

SEDIT is not using `sed` as a crutch. It is exploring the computational consequences of `sed` at full seriousness.

## Machine Encoding

The interpreter represents all runtime state as plain text in `sed`'s pattern space and hold space. Five delimiter characters are reserved for internal structure. These characters are non printable ASCII control codes, unreachable from SEDIT source syntax, and must never appear in any user visible value or identifier. This is the one invariant the interpreter never violates!

| Code | Hex    | Name                  | Role                                              |
|------|--------|-----------------------|---------------------------------------------------|
| SOH  | `\x01` | Stack separator       | Separates items on the data stack                 |
| STX  | `\x02` | Frame separator       | Separates frames on the call stack                |
| ETX  | `\x03` | Dict field separator  | Separates a dictionary entry's name from its body |
| EOT  | `\x04` | Dict record separator | Separates dictionary entries from each other      |
| ENQ  | `\x05` | Quotation delimiter   | Wraps stored quotation body content               |

Example data stack holding three values `1`, `2`, `3` from bottom to top:

```
1\x012\x013
```

Example dictionary with two entries:

```
double\x03[ dup add ]\x04square\x03[ dup mul ]
```

Any code path that writes to pattern space or hold space is responsible for ensuring none of these bytes appear in data. No exceptions!

## License

This project is provided under the [GPL3 License](./COPYING) Copyright (C) 2026 Ivan Gaydardzhiev
