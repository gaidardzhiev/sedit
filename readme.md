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

[sedit.sed](./sedit.sed) grows from the lexer into the runtime primitives that operate on the data stack. Stack words use the SOH separator from the machine encoding directly: `dup`, `drop`, `swap`, `over`, and `rot` are each a single substitution operating on the stack string with top-of-stack at the left end. Left-anchored matching was chosen specifically because `sed`'s pattern anchors (`^`) work cheaply and reliably from the start of a string; operating on the end would require captures of unknown length, which `sed` handles far more awkwardly.

`add` is the first arithmetic word and the first place real computation enters the interpreter, since `sed` has no native arithmetic of any kind. It is implemented as digit by digit decimal addition with carry, the same method anyone would use by hand: align the two operands, add from the units digit up, carry into the next column. Concretely, the operation pads both operands to equal length, reverses each digit string so the loop walks left to right over what is conceptually the rightmost digit first, then consumes one digit from each operand per iteration against a fixed lookup table covering every combination of (digit, digit, carry in) and producing (result digit, carry out). Once both operands are exhausted, any final carry becomes an extra leading digit, the accumulated result is reversed back into normal reading order, and leading zeros are stripped.

The lookup table is 200 lines, one substitution per combination of two digits and a carry bit. This is the least elegant part of the interpreter so far, and it is deliberately kept this way rather than replaced with something cleverer. The table is mechanically generated, every line follows the same shape, and that repetition is itself the documentation: the table is a truth table, not a piece of logic to be read line by line. A more compact arithmetic encoding was considered and set aside, since `sed`'s lack of native arithmetic means any alternative trades these 200 explicit, individually verifiable substitutions for fewer lines of more clever, harder to audit machinery, and explicitness has priority here over brevity.

Padding two operands to equal length is its own small routine, and the one place in the project so far where two numbers need to be compared without arithmetic, since arithmetic is exactly what's being built. The lengths are compared by converting each operand to a string of identical marker characters and stripping matched pairs from both simultaneously in hold space, leaving only the difference; the real digit strings are never touched during this comparison, only retrieved afterward to receive the computed padding. This is the same kind of indirection the project leans on throughout: when the host has no primitive for what's needed, build it from a more basic operation the host does support, rather than reaching outside `sed`.

String reversal, used both to walk addition in the right digit order and to restore the final result to normal reading order, is implemented once as a general routine and reused rather than duplicated. The technique is the standard `sed` idiom for reversal: peel one character at a time from the front of the remaining string and prepend it to an accumulator, separated from the remainder by a single rolling marker character, looping until the remainder is empty.

Every operation in this section was built and verified in isolation against fixed input before being folded into `sedit.sed`, following the same discipline established for the lexer. Two bugs surfaced during this work that are worth recording as standing lessons. First, a reversal substitution had its accumulator and remaining input positions reversed relative to where the rolling marker actually sat in the string, causing the pattern to silently fail to match rather than to reverse incorrectly; this kind of failure is invisible from reading the script and only showed up by tracing actual pattern-space state with `l` between steps. Second, when the digit table was generated programmatically, the host scripting language's own string escaping rules collapsed a literal two character backreference into a single control byte, corrupting the table with invisible characters that only surfaced as garbled output several stages downstream in the pipeline. Both failures reinforce the same practice: trust execution over inspection, and verify each primitive alone before composing it with anything else.

`sub` follows `add` and reuses several of its pieces directly: the same padding routine, the same reversal idiom, the same digit-by-digit loop structure, this time with a borrow table instead of a carry table. The added complexity in `sub` is sign. Unlike addition, subtraction can produce a negative result, and `sed` has no concept of sign to lean on, so the interpreter has to decide the sign itself before doing any digit arithmetic at all.

This is done with a separate magnitude comparison, a small routine that strips matching leading digits from both padded operands simultaneously until the first differing pair is found, then looks up which of the two is larger from a small ordering table over that single pair. If the operands are equal, the result is `0` and no borrow loop runs at all. Otherwise, the comparison result determines both which operand is subtracted from which, and whether the final result needs a `-` prepended. The borrow loop that follows is deliberately kept free of any sign logic, it always computes an unsigned `larger - smaller`, with sign handled entirely outside it: stashed in hold space once the comparison has decided operand order, left untouched through the entire digit loop, and retrieved exactly once at the end to prefix the result.

Building `sub` surfaced three real bugs, none visible from reading the script, all found only by tracing actual pattern space state with `l` between steps. A reversal substitution had its accumulator and rolling marker positions reversed relative to where the marker actually sat in the string, causing the pattern to fail to match at all rather than to reverse incorrectly. An early version of the sign and magnitude logic was developed and verified as two separate `sed` invocations connected by a shell pipe, where the sign and the digit data arrived as two genuinely separate lines; when that logic was folded into a single `sed -f` invocation to match the rest of the project's one script convention, the two lines no longer arrived as separate reads, they were already one buffer joined by an embedded newline, and the script needed to stop using `N` (which reads a new line from input) and instead operate directly on the newline already present in pattern space. The final join of sign and digits also originally assumed one more embedded newline than was actually present at that point in the pipeline, leaving the sign sitting on its own line in the output instead of prefixed to the result.

The lesson carried forward from all three: when a piece of logic is built and proven as a multi process pipeline for convenience during development, folding it into the project's single invocation convention is not a mechanical concatenation, the assumptions about what is a separate input line versus what is an embedded character in one buffer have to be re-verified from scratch, since `sed`'s read cycle treats the two very differently.

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
