# SEDIT

SEDIT is a stack first programming language whose interpreter is written in `sed`. The project treats `sed` not as a toy text filter but as a rigorous computational substrate: its pattern space becomes the active execution state, its hold space becomes auxiliary memory, and its branching and substitution commands become the control machinery of a real interpreter.

## On the Inversion of Method

A language implemented in `sed` is not a novelty for its own sake. It is an inquiry into whether a stream editor, with only line oriented transformation, two persistent buffers, and a small command vocabulary, can sustain the architecture of a higher order language. SEDIT answers that question by building a stack language on top of `sed`'s own primitives, so that the interpreter and the interpreted language arise from the same formal economy.

The result is a peculiar but disciplined recursion: `sed` edits text, SEDIT manipulates a stack, and the interpreter itself is expressed through `sed`'s transformation cycle.

## The Principle

SEDIT rejects the comforts of contemporary mainstream language design. The language is concatenative and explicit: values are pushed, words consume and produce stack effects, and quoted blocks now carry code as first class data, while `call` turns that stored code back into execution inside the same sed machine. A program is not a tree of expressions but a sequence of transformations, each one visible in the order it occurs.

This makes SEDIT severe, but also honest. The logic of the machine is never hidden behind decorative syntax. Everything that can be stated directly is stated directly.

## The Approach

One interpreter: the `sed` interpreter. It reads SEDIT source, rewrites it into internal command forms, and executes those forms against a stack based runtime held in `sed`'s pattern and hold spaces. There is no compilation stage in the conventional sense, only a disciplined sequence of pattern space transformations. The lexer may still be used as a producer of tagged tokens, and the evaluator may still consume that token stream one line at a time, but the native runner now closes the loop inside the same `sed` program by reusing the lexer's own emission point as an execution sink.

Everything is done manually in the interpreter:
- Lexer: tokenization via `sed` pattern matching and substitution.
- Runtime: data stack represented in textual form.
- Arithmetic: digit by digit decimal computation over lookup tables.
- Comparison: lexical magnitude comparison over padded decimal strings.
- Dispatch: command execution driven by `b`, `t`, labels, and substitution results.
- Memory: auxiliary state kept in hold space and selected encoded variables.

Uses `sed` primitives:
- Pattern space and hold space for runtime state.
- `s` for rewriting and decoding.
- `h`, `H`, `g`, `G`, `x` for state transfer.
- `b`, `t`, `T`, labels for branching and flow control.
- `n`, `N`, `d`, `D`, `p`, `P`, `q` for cycle management.

## The Language

SEDIT is a minimal stack language in the concatenative tradition. Its syntax is intentionally bare: values are pushed, words are executed, and quoted blocks are recognized lexically, assembled by the native runner into quotation values, and executed by `call` without rebuilding source text or invoking a second lexer. The language is designed so that its own interpreter can remain small, legible, and expressible in `sed`.

Every feature exists only if it serves that goal:
- Literals push themselves.
- Words execute left to right.
- Stack effects are the contract.
- Arithmetic is explicit and decimal.
- Comparisons return textual booleans.
- No hidden coercions, no precedence, no syntactic mercy.

## Current Implemented Surface

The current implementation is not a complete language yet. It is the working lower half of the interpreter plus the first source runner and the first real code-as-data object: lexical tokenization, stack primitives, arithmetic primitives, comparison primitives, underflow guards, a fully tail-preserving dispatcher for the current word surface, token-stream evaluation over that dispatcher, native source execution through `op_run`, nested quotation literal assembly, and quotation execution through `call`.

Implemented now:
- `123` lexes as `N:123`.
- `-5` lexes as `N:-5`.
- `"text"` lexes as `S:text`.
- `""` lexes as `S:`.
- `word` lexes as `W:word`.
- `[` and `]` lex as `B:[` and `B:]`.
- `N:x` dispatches by pushing `x`.
- `S:x` dispatches by pushing `x`.
- `W:true` and `W:false` dispatch as boolean literals.
- `W:dup`, `W:drop`, `W:swap`, `W:over`, and `W:rot` dispatch to stack primitives.
- `W:add`, `W:sub`, `W:eq`, `W:ne`, `W:lt`, `W:le`, `W:gt`, and `W:ge` dispatch to arithmetic and comparison primitives.
- `W:call` consumes a `Q:` quotation value and executes its stored tagged token body against the current stack.
- token streams can be evaluated by `op_eval`, one token per line, with the final SOH stack printed at end of input.
- source can be executed directly by `op_run` inside the same `sed` program, so `4 5 add 2 sub` now runs from source and produces `7` without an external shell runner.
- the native runner reuses the existing lexer recognition and changes only the token sink at `emit`; normal lex mode still prints tagged tokens, while run mode dispatches the recognized token.
- bracketed source is assembled as an inert quotation literal, pushed as one `Q:` stack item.
- quotation bodies store the lexer’s own tagged tokens separated by ENQ.
- nested quotation literals are captured by depth, so inner `B:[` and `B:]` tokens become part of the outer quotation body rather than closing it prematurely.
- empty quotations are valid and produce `Q:`.
- unterminated quotations fail with `ERR:UNTERMINATED_QUOTE` and a nonzero exit status.
- `[ 1 2 add ] call` executes the quotation body and produces `3`.
- quotation execution preserves older stack tail, continues with following source, accepts empty quotations, reconstructs nested quotation values, and allows a called quotation to call an inner quotation.
- `call` underflow fails with `ERR:UNDERFLOW`; calling a non-quotation fails with `ERR:CALL_NON_QUOTE`.
- the evaluator has been verified across the current language surface: arithmetic, stack reordering, comparison, preserved tails, underflow, unknown words, malformed tokens, and multi line lexed input.
- the native runner has been verified for source execution, stack preservation, multi line input, underflow, unknown word failure, quotation assembly, nested quotation assembly, quotation non-execution, empty quotations, and unterminated quotation failure.

Not implemented yet:
- `if`.
- `while`.
- recursion.
- user defined words.
- dictionary storage.
- `mul`, `div`, and `mod`.

This boundary is deliberate. The project grows by making each layer executable and verified before the next layer is allowed to depend on it. At this point source text can be run inside the same `sed` instance, the current primitive surface can be entered through one dispatcher boundary, and source fragments can become runtime values and can be re-entered as execution without leaving the interpreter. The evaluator owns tagged token streams, the runner owns source continuation and quotation capture, `call` owns quotation re-entry, the dispatcher owns one token plus the stack, and the primitive owns only the operands it was given. The current verifier prints 109 passing lines, not as a vanity count but as a pressure test that every layer still composes after quotation execution was added.

## Lexical Constructs

[sedit.sed](./sedit.sed) is the interpreter that reads SEDIT source one line at a time and emits one token per output line, each tagged with a single letter prefix identifying its kind. This tagged stream is the contract between the lexer and every later phase.

Four token kinds exist at this stage:

- `N:` a number, e.g. `N:123` or `N:-5`. Numbers are signed integers only; a leading `-` is part of the literal, not a separate operator token.
- `S:` a string, e.g. `S:hello world`. The surrounding double quotes are stripped before emission. An empty string literal `""` produces `S:` with nothing after the colon.
- `W:` a word, e.g. `W:dup`, `W:true`, `W:add`. Any token that is not a number, string, or bracket falls through to this case. Whether a word is a primitive, a user-defined name, or a boolean literal is not decided at lex time; that distinction belongs to dispatch, not lexing.
- `B:` a block bracket, either `B:[` or `B:]`. Brackets are matched individually by the lexer. Pairing and nesting depth are not a lexer concern; in run mode, quotation capture owns that structure while the lexer remains only the recognizer of bracket tokens.

Whitespace between tokens is required for numbers and words to be recognized as separate tokens, except where brackets are involved: brackets are matched before falling through to the word case, so `[[]]` lexes correctly as four separate bracket tokens with no surrounding whitespace needed. A token glued directly to a bracket with no space, such as `123[`, is not split; the whole sequence is read as a single word. SEDIT source is written with whitespace separating all tokens except adjacent brackets.

The lexer operates as a single cycle over each input line: strip leading whitespace, attempt each token pattern in a fixed order, emit the first match, delete the matched prefix from pattern space, and repeat until the line is empty. The fixed match order matters: string and bracket patterns are tried before number and word patterns specifically so that quoted content and structural brackets are never misread as part of a word.

This cycling is implemented with `D`, restarting the script against whatever remains of the line after each emitted token, rather than reading a fresh line from input on every token. One correctness detail follows directly from this: `sed`'s substitution flag, used by the `t` command to branch on whether a prior substitution succeeded, is not reset by `D` the way it is reset at the start of a normal new input cycle. Without an explicit reset at the top of the loop, a restarted cycle can inherit a stale success flag from the substitution that produced the previous token, causing the current token's own match and tag step to be skipped even though it succeeded. The lexer clears this flag explicitly on every loop iteration before attempting any token match. This is a general lesson for every later phase that uses `D` to drive a cycle: the flag must be treated as dirty on entry to any `D`-restarted block.

## Machine Encoding

The interpreter represents runtime state as plain text in `sed`'s pattern space and hold space. Eight delimiter characters are reserved for internal structure. These characters are non printable ASCII control codes, unreachable from normal SEDIT source syntax, and must never appear in any user visible value or identifier. This is the one invariant the interpreter never violates!

| Code | Hex    | Name                  | Role                                              |
|------|--------|-----------------------|---------------------------------------------------|
| SOH  | `\x01` | Stack separator       | Separates items on the data stack                 |
| STX  | `\x02` | Frame separator       | Separates the protected runner source frame now, and is reserved for future call frames |
| ETX  | `\x03` | Quote frame marker    | Marks active quotation capture in hold space      |
| EOT  | `\x04` | Quote depth separator | Separates saved stack/source from quote depth     |
| ENQ  | `\x05` | Quotation token separator | Separates stored tokens inside a quotation body |
| ACK  | `\x06` | Quote body separator  | Separates quote depth from accumulated quote body |
| BEL  | `\x07` | Call frame marker     | Marks active quotation execution in the protected run frame |
| BS   | `\x08` | Call quote separator  | Separates call-local quote depth from call-local quote body |

The current data stack uses SOH directly, with the top of stack at the left end. The reversal from the usual human drawing of a stack is intentional: `sed` anchors cheaply at the beginning of pattern space. The top item therefore appears first, followed by older items separated by SOH. In run mode, STX is not a stack item. It protects the remaining source from the data stack so that stack words cannot reorder, duplicate, or delete the future program. During quotation capture, ETX/EOT/ACK mark the private quote frame in hold space; ENQ is the separator stored inside the finished `Q:` value. During quotation execution, BEL marks the active call frame and BS separates call-local quote depth from the reconstructed nested quotation body.

Example stack after pushing `1`, then `2`, then `3`:

```
3\x012\x011
```

This orientation is the law of the runtime. Every primitive is written against it, and every test encodes it.

## Stack Primitives

The first runtime layer is the data stack. `dup`, `drop`, `swap`, `over`, and `rot` operate directly on the SOH encoded stack. They do not parse source and they do not know about tokens. They are raw runtime operations, entered by branch during testing or by dispatcher during execution.

Current stack effects, with top of stack on the left:

- `dup`: `a rest` becomes `a a rest`.
- `drop`: `a rest` becomes `rest`.
- `swap`: `a b rest` becomes `b a rest`.
- `over`: `a b rest` becomes `b a b rest`.
- `rot`: `a b c rest` becomes `c a b rest`.

Each operation is intentionally small. In the simple cases it is a single substitution guarded by arity. The project prefers visible stack rewrites over helper abstractions that would hide the machine state.

## Addition

`add` is the first arithmetic word and the first place real computation enters the interpreter, since `sed` has no native arithmetic. It accepts the current pre dispatch arithmetic ABI, `top|second`, and returns the decimal sum as plain text.

The operation is implemented exactly as hand addition: pad both operands to equal length, reverse both digit strings so the loop walks units digit first, consume one digit from each operand plus carry, and look up the result in a flat table. The table covers every `(digit, digit, carry in)` case. Once the loop is exhausted, the accumulated result is reversed back to normal reading order and leading zeros are stripped.

The table is deliberately kept as a flat truth table rather than compressed into clever pattern logic. In a language without arithmetic, explicitness is not waste. It is proof material.

Through the dispatcher, `add` follows the general tail-preserving binary word path. A stack such as `4 SOH 5 SOH keep` dispatched with `W:add` becomes `9 SOH keep`. The dispatcher consumes only the two required operands, adapts them to the existing `op_add` pipe ABI, and restores the untouched stack tail after the arithmetic result returns. Carry is verified through this path with a tail still present.

## Subtraction

`sub` uses the same decimal discipline as `add`, but with borrow instead of carry and with an explicit magnitude comparison before digit arithmetic begins. Because `sed` has no native sign, the operation first decides which absolute value is larger, performs the subtraction in the order that produces a nonnegative magnitude, then attaches a sign when the standard RPN result is negative.

Operand order follows the stack language convention: `a b sub` computes `a - b`. Internally, because the top of stack is on the left, the two input fields are swapped at entry so that the second pushed operand is treated as the left hand side and the top of stack is treated as the right hand side.

`sub` still retains the two item pipe interface when entered directly, but through the dispatcher it now follows the same tail-preserving binary word law as `add`. A stack such as `4 SOH 5 SOH keep` dispatched with `W:sub` becomes `1 SOH keep`, and a case such as `5 SOH 4 SOH keep` becomes `-1 SOH keep`. The wrapper does not make subtraction aware of the larger stack; it extracts the required operands, lets the existing subtraction engine do its work, and then restores the tail.

## Comparison Words

The six comparison words are `eq`, `ne`, `lt`, `le`, `gt`, and `ge`. They share the same conceptual structure: pad operands to equal length, strip matching leading digits until the first differing pair, look up LT/EQ/GT from a 100 entry table, then map the comparison result to `true` or `false` depending on the word.

Each comparison word has its own uniquely prefixed internal labels. This is not decoration. During development, duplicate labels caused every branch to jump to the first occurrence of the shared label, making all six comparison words produce identical behavior. The test suite caught it immediately, because six distinct relations cannot all agree on the same inputs. The resulting rule is permanent: repeated structure may be copied, but labels must remain local by name.

Operand order follows the same standard RPN convention as `sub`: `a b lt` means `a < b`, so the second pushed operand is the left hand side and the top of stack is the right hand side. Each comparison word swaps its input fields at entry, identically to `op_sub`.

The comparison words still retain the pipe based pre dispatch interface when entered directly, but through the dispatcher they now share the same tail-preserving binary word discipline as arithmetic. A comparison consumes the top two operands, produces one textual boolean, and leaves the untouched stack tail behind it. The comparison logic itself remains isolated from the larger stack; the dispatcher owns extraction and restoration.

## Dispatcher

The dispatcher is the first execution bridge. It consumes a token line and a stack state, then performs the stack effect belonging to that token. Its input form during testing is the stack in pattern space, followed by a newline, followed by one token such as `N:7`, `S:hi`, or `W:add`.

Literal dispatch is direct:
- `N:x` pushes `x`.
- `S:x` pushes `x`.
- `W:true` pushes `true`.
- `W:false` pushes `false`.

Primitive word dispatch branches to the existing operation labels:
- `W:dup` -> `op_dup`.
- `W:drop` -> `op_drop`.
- `W:swap` -> `op_swap`.
- `W:over` -> `op_over`.
- `W:rot` -> `op_rot`.
- `W:call` -> the call re-entry path when the top stack item is a `Q:` value.

Arithmetic and comparison dispatch deliberately reuse the older pipe operations instead of rewriting them prematurely:
- `W:add` extracts two SOH stack items, adapts them to `op_add`, then restores the tail.
- `W:sub` extracts two SOH stack items, adapts them to `op_sub`, then restores the tail.
- `W:eq`, `W:ne`, `W:lt`, `W:le`, `W:gt`, and `W:ge` extract two SOH stack items, adapt them to their comparison operation, then restore the tail.

This makes the dispatcher a boundary, not a revolution. It allows source tokens to execute against the SOH stack while preserving the arithmetic and comparison code that already exists and already passes tests. The stable law is now explicit: the dispatcher owns the larger stack, the primitive owns only the operands it was given.

Dispatcher failure states are explicit:
- underflow prints `ERR:UNDERFLOW` and exits nonzero.
- unknown words print `ERR:UNKNOWN_WORD` and exit nonzero.
- malformed tokens print `ERR:BAD_TOKEN` and exits nonzero.
- calling a non-quotation prints `ERR:CALL_NON_QUOTE` and exits nonzero.

## Evaluator Loop

`op_eval` is the first complete execution loop. It consumes a stream of already tagged tokens, starts with an empty stack, dispatches one token, preserves the resulting stack, reads the next token, and repeats until the input stream is exhausted. At end of input it prints the final SOH encoded stack.

This is the point where SEDIT crosses from tested pieces into program execution. The dispatcher still executes only one token. The evaluator gives that single-token mechanism duration.

Example token stream:

```
N:4
N:5
W:add
N:2
W:sub
```

produces:

```
7
```

The lexer and evaluator compose through their shared tagged-token contract. Source such as:

```
4 5 add 2 sub
```

can be lexed into tagged tokens and then evaluated to the same final stack. This remains useful as a test harness and as a visible phase boundary, but it is no longer the only execution path. `op_run` now executes source directly inside the same `sed` instance.

The evaluator is now tested as a program executor, not merely as an arithmetic demo. It executes stack words such as `swap`, `over`, and `rot`; comparison words such as `lt`; comparison with preserved stack tail; underflow through the evaluator boundary; unknown word failure; bad token failure; multi line lexed source; and lexed source that leaves an older stack tail intact. The loop itself remains small because the dispatcher already has the correct shape: after each word finishes, `op_end` either stops at end of input or reads the next token and re-enters dispatch.

The evaluator establishes the third runtime law:

- the evaluator owns the token stream.
- the dispatcher owns one token and the current stack.
- the primitive owns only its declared stack prefix.

This separation is now the spine of the interpreter. Future quotation, dictionary, and control-flow work must preserve it rather than bypass it.

## Native Runner

`op_run` is the first source execution entry point. It is not a shell script, not an external pipeline, and not a second interpreter. It runs SEDIT source inside `sedit.sed` by reusing the original lexer as the ground of execution.

The earlier temptation was to treat the lexer as an external producer and then feed its printed output into the evaluator. That is useful for testing, but it is not the language runtime. The native runner closes that gap. It lets the lexer recognize tokens exactly as before, but changes the destination of the recognized token.

The switch is at `emit`:

- normal lex mode keeps the old behavior: print the tagged token and continue lexing with `P` and `D`.
- run mode marks hold space with STX, so `emit` branches to `emit_run` instead of printing.
- `emit_run` joins the recognized token with the protected run frame and enters `op_dispatch`.

This is the important architectural point: the runner does not copy the lexer. There is no second string rule, no second number rule, no second word rule. The lexer remains the single source of token truth. The runner changes only the sink.

The run frame uses STX to separate the live data stack from the remaining source. This delimiter is not ordinary stack tail. It is a protected boundary owned by the runner. After a word executes, `op_end` detects the run frame and returns to `op_run_next`, which saves the updated stack, restores the remaining source, and re-enters the lexer at `line`.

The runtime laws are now:

- the lexer owns token recognition.
- the runner owns source continuation.
- the evaluator owns already tagged token streams.
- the dispatcher owns one token plus the current stack.
- the primitive owns only its declared stack prefix.

A direct source program such as:

```
4 5 add 2 sub
```

now runs through `op_run` and produces:

```
7
```

A source program with an older stack tail also preserves that tail through the runner, because the source continuation is protected from stack operations and the dispatcher restores the real data tail after every binary word.

The same sink switch now gives the runner quotation capture. When `emit_run` receives `B:[`, it does not dispatch the bracket as a word. It opens a protected quote frame in hold space and returns to the lexer. While that frame is active, `emit` branches to `emit_quote`. The lexer still recognizes every token, but the sink appends the tagged token to the quotation body instead of executing it. A closing `B:]` at depth zero ends the quotation, prefixes the body with `Q:`, pushes the quotation as a single stack item, and returns to the runner. Inner brackets modify quote depth and are kept as body tokens.

This keeps the architecture single-spined. There is still one lexer. There is still one source runner. Quotation capture is not a second parser; it is a different token sink under the runner.


## Underflow Guards

Every operation checks its own arity before executing. The check is per operation rather than shared, since each operation genuinely knows its own requirements and a shared guard would hide that contract behind an indirection the project's design explicitly rejects.

On underflow, the operation prints `ERR:UNDERFLOW` and exits nonzero via `q1`. GNU sed's `q1` autoprints the current pattern space before quitting, so no explicit `p` is needed and using one causes a double print in non-`-n` mode. The two signals together, a readable error token on stdout and a nonzero exit code, make failures both diagnosable by a human and detectable by a calling script without parsing output.

Current guard shapes:
- 1 operand stack operations guard against empty stack via `/^$/`.
- 2 operand stack operations guard against fewer than two SOH delimited items.
- 3 operand `rot` guards against fewer than three SOH delimited items.
- pipe based arithmetic and comparison operations guard against a missing pipe delimiter.
- dispatcher arithmetic and comparison guards before attempting to extract two stack operands.

The comparison underflow tests iterate over all six comparison words rather than duplicating the function body six times in the verifier. This keeps the tests compact without hiding the fact that every comparison word has its own operation entry and its own guard.

## Verification

[verify.sh](./verify.sh) is the executable specification of the current interpreter. Every feature described here is represented by a test before it is trusted as part of the language.

The verifier covers:
- lexical tokens for numbers, negative numbers, strings, empty strings, words, brackets, multi token lines, and small programs.
- stack primitives `dup`, `drop`, `swap`, `over`, and `rot`.
- addition basics, carry, overflow, zero, and unequal length operands.
- subtraction basics, negative results, borrow, zero, unequal length operands, and boundary behavior.
- underflow for all stack and arithmetic primitives.
- all six comparison words with true and false outcomes.
- underflow for all six comparison words.
- dispatcher literal pushes.
- dispatcher stack primitive calls.
- dispatcher arithmetic calls.
- dispatcher underflow.
- dispatcher boolean literals and error states.
- tail preserving dispatch for `add`, including carry with a tail still present.
- tail preserving dispatch for `sub`, including negative subtraction with a tail still present.
- tail preserving dispatch for `eq`, `ne`, `lt`, `le`, `gt`, and `ge`.
- evaluator execution of tagged token streams.
- chained evaluator arithmetic.
- evaluator tail preservation across multiple tokens.
- evaluator execution of stack words `swap`, `over`, and `rot`.
- evaluator execution of comparison words.
- evaluator comparison with preserved tail.
- evaluator underflow, unknown word, and bad token failure states.
- lexer-to-evaluator execution of a small source program.
- lexer-to-evaluator execution over multi line source.
- lexer-to-evaluator execution where a computed result preserves an older stack tail.
- native runner source execution through `op_run`.
- native runner stack preservation.
- native runner multi line source execution.
- native runner underflow and unknown word failure states.
- `call` execution of a quotation body.
- `call` preservation of older stack tail.
- continuation after `call` returns to the source runner.
- empty quotation execution.
- `call` underflow and non-quotation failure states.
- `call` reconstruction of nested quotation values.
- nested call execution through a called quotation.
- quotation literal assembly through the native runner.
- quotation preservation of an older stack tail.
- quotation non-execution.
- empty quotation literals.
- nested quotation literals.
- unterminated flat and nested quotation failure states.

The current verifier prints 109 passing lines. The number itself is not a goal. It is a checkpoint: lexer, primitive operations, dispatcher, evaluator, native runner, quotation capture, and `call` now agree on the same machine encoding and the same stack laws.

The test style is intentionally plain shell. Each function sets up one direct entry point into `sedit.sed`, runs one operation, compares exact output, prints a fixed `PASSED` or `FAILED` line, and returns a unique error code. This is not ornamentation. It is how the interpreter remains honest while the internal representation is still changing.

## Development Rule

No feature is allowed to enter the interpreter only because it is theoretically elegant. It must survive the verifier. This matters especially in `sed`, where the visible source can look correct while pattern space is wrong by one marker, one branch target, one stale substitution flag, or one invisible control byte.

The interpreter therefore grows by small mechanical victories:
- first a direct operation.
- then underflow.
- then correctness cases.
- then dispatcher entry.
- then tail preservation where the operation needs to compose with a real stack.
- then evaluator entry when the operation must compose with real token streams.
- then runner entry when source itself must execute inside the same `sed` instance.
- then quotation entry when source must become data without being executed.
- then call entry when stored code data must become execution again.

`mul` is intentionally not forced at this point. The more rewarding current path has been the dispatcher, evaluator, native runner, quotation literal machinery, and `call`, because they connect working pieces into execution and code-as-data without disturbing the arithmetic core before it is ready. The next natural boundary is not more local arithmetic heroism, but conditional control over executable quotations.

## Quoted Blocks

Quoted blocks are now real runtime literals. They are no longer merely bracket tokens, and they are no longer permanently inert: they remain data until `call` consumes them. In run mode, a bracketed source fragment is captured as one stack value prefixed with `Q:`. The body of the quotation is not raw source text. It is the lexer’s own tagged token stream, separated internally by ENQ, so the quotation preserves exactly what the interpreter already knows how to dispatch later.

Example:

```
[ 1 2 add ]
```

pushes:

```
Q:N:1 ENQ N:2 ENQ W:add
```

The contents are inert at capture time. This is essential. `[ 4 5 add ]` does not produce `9`; it produces code data. A program such as:

```
[ 4 5 add ] 2
```

leaves `2` above the quotation value. That test exists specifically to prevent a false quotation implementation that secretly evaluates while capturing.

Nested quotation literals are also captured. In:

```
[ 1 [ 2 ] 3 ]
```

the inner `[` and `]` are preserved as `B:[` and `B:]` inside the outer quotation body. They do not close the outer quotation. The quote sink owns depth; the lexer only recognizes bracket tokens.

Empty quotations are valid and produce `Q:`. Unterminated quotations fail with `ERR:UNTERMINATED_QUOTE` and a nonzero exit status. This failure is detected by the lexer loop at end of source when hold space still carries an active quote frame.

This is the point where SEDIT has code as data. `call` is the next point where that data becomes execution again. Quotation capture and quotation execution are deliberately separate: capture constructs a `Q:` value, and `call` consumes that value later.

## Call

`call` is the first re-entry word. It consumes one `Q:` value from the top of the stack, takes the ENQ-separated tagged token body stored inside that quotation, and executes those tokens against the current stack. It does not reconstruct source text. It does not ask the shell to pipe one sed process into another. It does not introduce a second lexer. The quotation body is already the lexer’s own token stream, so `call` feeds that stream back into the same dispatcher discipline that executes ordinary source.

Example:

```
[ 1 2 add ] call
```

produces:

```
3
```

`call` preserves the caller’s older stack tail. A source fragment such as:

```
"keep" [ 4 5 add ] call
```

produces the result above the preserved older value. A called quotation also returns to the native runner, so following source continues normally:

```
[ 1 2 add ] call 3 add
```

produces:

```
6
```

Empty quotations are legal. `[ ] call` executes nothing and returns to the caller. Nested quotations inside a called quotation are reconstructed as quotation values rather than executed by accident, so `[ [ 1 2 add ] ] call` leaves the inner quotation as data. If that inner quotation is explicitly called, as in `[ [ 1 2 add ] call ] call`, execution re-enters one level deeper and produces `3`.

The call frame is protected by BEL. The saved caller continuation is separated from the quotation body by EOT, while ENQ remains the internal separator between stored quotation tokens. When `call` meets a bracket token inside the quoted body, it uses a call-local quote collector so nested quotation values can be rebuilt during execution. This is not a parser fork. It is the same token stream being interpreted under a new sink.

Failure remains explicit: `call` on an empty stack is `ERR:UNDERFLOW`, and `call` on a non-quotation value is `ERR:CALL_NON_QUOTE`.

SEDIT is still not Turing complete at this boundary. `call` gives code-as-data re-entry, but not yet conditional choice or repetition. The next semantic boundary is `if`, followed by `while`.

## Runtime Model

The runtime model is intentionally minimal:
- a data stack encoded with SOH.
- a protected runner/source frame encoded with STX.
- active quotation capture frames encoded with ETX, EOT, and ACK.
- finished quotation bodies encoded with ENQ-separated tagged tokens.
- active call frames encoded with BEL and EOT.
- call-local quotation reconstruction encoded with BS and ACK.
- future dictionary records still to be assigned a stable final discipline.
- pattern space as active state.
- hold space as auxiliary state.

This design embraces `sed`'s own execution cycle rather than pretending to be a different machine. The interpreter does not fight the host; it formalizes it.

## Why `sed`

`sed` is an apt host because it already works as a stateful transformer over text, with a small but expressive command set and a clear cycle of reading, transforming, branching, and printing. Its pattern space and hold space provide just enough persistence to model state, while its substitution and branching commands provide the control skeleton needed for interpretation.

SEDIT is not using `sed` as a crutch. It is exploring the computational consequences of `sed` at full seriousness.

## License

This project is provided under the [GPL3 License](./COPYING) Copyright (C) 2026 Ivan Gaydardzhiev
