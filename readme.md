# SEDIT

SEDIT is a stack first programming language whose interpreter is written in `sed`. The project treats `sed` not as a toy text filter but as a rigorous computational substrate: its pattern space becomes the active execution state, its hold space becomes auxiliary memory, and its branching and substitution commands become the control machinery of a real interpreter.

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

## Lexical Constructs

[sedit.sed](./sedit.sed) is the the interpreter that reads SEDIT source one line at a time and emits one token per output line, each tagged with a single letter prefix identifying its kind. This tagged stream is the contract between the lexer and every later phase.

Four token kinds exist at this stage:

- `N:` a number, e.g. `N:123` or `N:-5`. Numbers are signed integers only; a leading `-` is part of the literal, not a separate operator token.
- `S:` a string, e.g. `S:hello world`. The surrounding double quotes are stripped before emission. An empty string literal `""` produces `S:` with nothing after the colon.
- `W:` a word, e.g. `W:dup`, `W:true`, `W:add`. Any token that is not a number, string, or bracket falls through to this case. Whether a word is a primitive, a user-defined name, or a boolean literal is not decided at lex time; that distinction belongs to dispatch, not lexing.
- `B:` a block bracket, either `B:[` or `B:]`. Brackets are matched individually here, not paired. Pairing and nesting depth are a parser concern, addressed when quoted blocks are implemented.

Whitespace between tokens is required for numbers and words to be recognized as separate tokens, except where brackets are involved: brackets are matched before falling through to the word case, so `[[]]` lexes correctly as four separate bracket tokens with no surrounding whitespace needed. A token glued directly to a bracket with no space, such as `123[`, is not split; the whole sequence is read as a single word. SEDIT source is written with whitespace separating all tokens except adjacent brackets.

The lexer operates as a single cycle over each input line: strip leading whitespace, attempt each token pattern in a fixed order (string, then open bracket, then close bracket, then number, then word), emit the first match, delete the matched prefix from pattern space, and repeat until the line is empty. The fixed match order matters: string and bracket patterns are tried before the number and word patterns specifically so that quoted content and structural brackets are never misread as part of a word.

This cycling is implemented with `D`, restarting the script against whatever remains of the line after each emitted token, rather than reading a fresh line from input on every token. One correctness detail follows directly from this: `sed`'s substitution flag, used by the `t` command to branch on whether a prior substitution succeeded, is not reset by `D` the way it is reset at the start of a normal new input cycle. Without an explicit reset at the top of the loop, a restarted cycle can inherit a stale success flag from the substitution that produced the previous token, causing the current token's own match and tag step to be skipped even though it succeeded. The lexer clears this flag explicitly on every loop iteration before attempting any token match. This is a general lesson for every later phase that uses `D` to drive a cycle: the flag must be treated as dirty on entry to any `D`-restarted block.

## Stack and Arithmetic Primitives

[sedit.sed](./sedit.sed) grows from the lexer into the runtime primitives that operate on the data stack. Stack words use the SOH separator from the machine encoding directly: `dup`, `drop`, `swap`, `over`, and `rot` are each a single substitution operating on the stack string with top-of-stack at the left end, since `sed`'s `^` anchor works cheaply from the start of a string but not from the end.

`add` and `sub` are the first arithmetic words and the first place real computation enters the interpreter, since `sed` has no native arithmetic. Both are implemented as digit by digit decimal arithmetic, the same method anyone would use by hand: pad both operands to equal length, reverse each digit string so the loop walks units digit first, then consume one digit from each operand per iteration against a fixed lookup table. `add` uses a 200 line carry table over every (digit, digit, carry in) combination; `sub` uses an equivalent borrow table, plus a separate magnitude comparison to decide operand order and sign before any digit arithmetic runs, since `sed` has no concept of sign to lean on. Once digits are exhausted, results are reversed back to normal reading order and leading zeros are stripped. `sub` follows the standard RPN convention: `a b sub` computes `a - b`, the first pushed operand minus the second.

The 200 line tables are deliberately kept as flat, mechanically generated lookups rather than replaced with cleverer arithmetic encodings. The repetition is itself the documentation, a truth table rather than logic to read line by line, and explicitness was prioritized over brevity given `sed`'s lack of native arithmetic.

Both operations surfaced real bugs during development, none visible from reading the script, all found only by tracing actual pattern space state with `l`: a reversal substitution with its accumulator and marker positions swapped, a digit table corrupted by the host scripting language's own string escaping collapsing a literal backreference into a control byte, a confusion between `sed`'s line read cycle and an already embedded newline within one buffer when folding a two process prototype into a single invocation, and an initial operand order bug where `sub` computed the reverse of standard RPN convention. Each is a standing argument for verifying every primitive by execution before composing it with anything else.

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
