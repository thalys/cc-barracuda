# Fish Shell vs Bash: Complete Reference Guide

This reference contains the complete differences between bash and fish shell syntax. Use this when converting bash scripts to fish or validating fish code.

## Command Substitutions

**Bash:** `` `command` `` or `$(command)`
**Fish:** `$(command)` or `(command)` (backticks NOT supported)

Fish only splits command substitutions on newlines, not on `$IFS`. Use `string split`, `string split0`, or `string collect` for custom splitting.

Example:
```fish
# Correct: handles filenames with spaces
for i in (find . -print0 | string split0)
  echo $i
end
```

## Variables

### Declaration and Assignment

**Bash:**
```bash
VAR=value
export VAR=value
local VAR=value
declare VAR=value
unset VAR
```

**Fish:**
```fish
set VAR value                    # Local scope
set -g VAR value                 # Global scope
set -x VAR value                 # Export (like bash export)
set -gx VAR value                # Global + exported
set -l VAR value                 # Local scope (explicit)
set -e VAR                       # Erase variable
```

**CRITICAL:** Never use `VAR=value` syntax in fish (except for environment overrides in commands).

### Variable Expansion

**Bash:** Word splitting requires double quotes to prevent
```bash
foo="bar baz"
printf '"%s"\n' $foo    # Prints two lines (word splitting)
printf '"%s"\n' "$foo"  # Prints one line
```

**Fish:** No word splitting - variables maintain their structure
```fish
set foo "bar baz"
printf '"%s"\n' $foo    # Prints one line - no quotes needed
```

### Lists (Arrays)

All fish variables are lists. Each element is preserved:

```fish
set var "foo bar" banana
printf %s\n $var
# Output:
# foo bar
# banana
```

Access specific elements:
```fish
echo $list[1]      # First element
echo $list[-1]     # Last element
echo $list[5..7]   # Range
```

### Environment Overrides

**Bash:** `VAR=value command`
**Fish:** `VAR=value command` (same syntax, but only for command overrides)

## Wildcards (Globs)

**Supported globs:** `*` and `**` (recursive)
**Deprecated:** `?` (avoid using)

### Key Differences

1. **Failed glob behavior:** Fails the command (like bash `failglob`)
2. **Exceptions:** `for`, `set`, `count` commands expand to nothing on no match
3. **No glob expansion on variables:**
   ```fish
   set foo "*"
   echo $foo    # Prints literal "*", doesn't match files
   ```
4. **Recursive globbing:** `**` works without options (unlike bash's `globstar`)
5. **Symlinks:** Fish follows symlinks (bash doesn't by default)
6. **Sorting:** Natural sort with numbers compared as numbers

## Quoting

**Double quotes (`""`):** Variables expanded
**Single quotes (`''`):** Nothing expanded

**No `$''` syntax.** Escape sequences work when unquoted:
```fish
echo a\nb    # Prints on two lines
```

## String Manipulation

**Bash:** `${foo%bar}`, `${foo#bar}`, `${foo/bar/baz}`
**Fish:** Use `string` builtin

### Common Operations

```fish
# Replace
string replace bar baz "bar luhrmann"     # "baz luhrmann"

# Split
string split "," "foo,bar"                # "foo" "bar"

# Match (like grep)
echo bababa | string match -r 'aba$'      # "aba"

# Pad
string pad -c x -w 20 "foo"               # "xxxxxxxxxxxxxxxxxfoo"

# Case conversion
string lower Foo                          # "foo"
string upper Foo                          # "FOO"

# Trim
string trim " foo "                       # "foo"

# Length
string length "foo"                       # 3

# Repeat
string repeat -n 3 "foo"                  # "foofoofoo"
```

## Special Variables

| Bash | Fish | Description |
|------|------|-------------|
| `$*`, `$@`, `$1`, `$2`... | `$argv`, `$argv[1]`, `$argv[2]`... | Arguments |
| `$?` | `$status` | Exit status |
| `$$` | `$fish_pid` | Process ID |
| `$#` | `count $argv` | Argument count |
| `$!` | `$last_pid` | Last background PID |
| `$0` | `status filename` | Script name |
| `$-` | `status is-interactive`, `status is-login` | Shell flags |

## Process Substitution

**Bash:** `<(command)` and `>(command)`
**Fish:** `(command | psub)` (no output redirect equivalent)

Better alternative - use pipes directly:
```fish
# Instead of: source (command | psub)
# Use:
command | source
```

## Heredocs

**Bash:**
```bash
cat <<EOF
some string
EOF
```

**Fish alternatives:**
```fish
# Using printf
printf %s\n "some string" "more string"

# Using echo with newlines
echo "some string
more string"

# Using pipes (equivalent to heredoc)
echo "foo" | cat
```

Heredocs are just syntactic sugar for pipes. Fish uses pipes directly.

## Test Command

**Fish:** POSIX-compatible `test` or `[` builtin
**NOT supported:** `[[` syntax

### Key Differences

- No `==` operator (use `=`)
- Can compare floating point numbers
- Use `set -q` to test if variable exists

```fish
# Variable existence
set -q foo          # True if $foo exists
set -q foo[2]       # True if $foo has at least 2 elements

# Comparisons
test $x -eq 5       # Numeric equality
test $x = "foo"     # String equality (not ==)
test -f $file       # File exists
```

## Arithmetic

**Bash:** `$((i + 1))` or `$[i + 1]`
**Fish:** `math` builtin

```fish
math $i + 1
math 5 / 2              # 2.5 (supports floats)
math "cos(2 * pi)"      # Supports functions
math '(5 + 2) * 4'      # Quote if using parentheses
```

Note: Use `x` or `*` for multiplication (`*` needs quoting as it looks like a glob).

## Blocks and Loops

### For Loop

**Bash:**
```bash
for i in 1 2 3; do
  echo $i
done
```

**Fish:**
```fish
for i in 1 2 3
  echo $i
end
```

### While Loop

**Bash:**
```bash
while true; do
  echo Weeee
done
```

**Fish:**
```fish
while true
  echo Weeeeeee
end
```

No `until` - use `while not` or `while !`

### Conditionals

**Bash:**
```bash
if true; then
  echo yes
else
  echo no
fi
```

**Fish:**
```fish
if true
  echo yes
else
  echo no
end
```

### Functions

**Bash:**
```bash
foo() {
  echo foo
}
```

**Fish:**
```fish
function foo
  echo foo
end
```

### Blocks

**Bash:** `{ commands; }`
**Fish:** `begin; commands; end`

## Subshells

**Critical:** Fish does NOT have subshells like bash.

**Bash subshells:**
```bash
(foo; bar) | baz        # Runs in subshell
foo | while read bar; do
  VAR=val               # Not visible outside
done
```

**Fish alternatives:**

1. **Use `begin/end` for grouping** (NOT for isolation):
   ```fish
   begin; foo; bar; end | baz
   ```

2. **Variables in pipes ARE visible**:
   ```fish
   foo | while read bar
     set -g VAR val     # This IS visible outside
   end
   ```

3. **For isolation, use explicit subshell**:
   ```fish
   fish -c 'your code here'
   ```

## Common Builtins

| Purpose | Fish Builtin | Replaces |
|---------|--------------|----------|
| String operations | `string` | `${var%foo}`, `grep`, `sed` |
| Math | `math` | `$((i+1))`, `bc` |
| Argument parsing | `argparse` | `getopt` |
| Counting | `count` | `$#`, `wc -l` |
| Shell status | `status` | `$-`, `$BASH_LINENO` |
| Sequences | `seq` | `{1..10}` |

## Prompts

**Bash:** `$PS1`, `$PS2` variables
**Fish:** Functions

- `fish_prompt` - Main prompt
- `fish_right_prompt` - Right side prompt
- `fish_mode_prompt` - Vi mode indicator

## Debugging

**Bash:** `set -x` or `set -o xtrace`
**Fish:** `set fish_trace 1`

Or use: `fish --profile` for performance profiling

## Common Pitfalls

### WRONG

```fish
export VAR=value           # No export command
VAR=value                  # Wrong assignment (unless command override)
if [[ $x == "foo" ]]      # No [[ syntax
echo ${var%suffix}         # No parameter expansion
var=$(cmd)                 # Wrong assignment
result=`command`          # Backticks not supported
$((i + 1))                # No arithmetic expansion
```

### CORRECT

```fish
set -x VAR value          # Export variable
set VAR value             # Assign variable
if test $x = "foo"        # Use test or [
string replace suffix "" $var  # Use string builtin
set var (cmd)             # Correct assignment
set result (command)      # Use parentheses
math $i + 1               # Use math builtin
```

## Quick Conversion Checklist

When converting bash to fish, check:

- [ ] Replace `VAR=value` with `set VAR value`
- [ ] Replace `export VAR=value` with `set -x VAR value`
- [ ] Replace `local VAR=value` with `set -l VAR value`
- [ ] Replace `unset VAR` with `set -e VAR`
- [ ] Replace backticks with `()` or `$()`
- [ ] Replace `${var%pattern}`, `${var#pattern}`, `${var/old/new}` with `string` commands
- [ ] Replace `$((math))` with `math` command
- [ ] Replace `[[` with `test` or `[`
- [ ] Replace `==` with `=` in test commands
- [ ] Replace `$1`, `$2`, etc. with `$argv[1]`, `$argv[2]`
- [ ] Replace `$#` with `count $argv`
- [ ] Replace `$?` with `$status`
- [ ] Replace heredocs with `echo` or `printf` piped to command
- [ ] Replace `do/done` with fish block syntax (end)
- [ ] Replace `then/fi` with fish conditionals (end)
- [ ] Replace `{ }` blocks with `begin/end`
- [ ] Remove semicolons (optional in fish)
- [ ] Check for word splitting assumptions
- [ ] Verify glob expansion behavior
- [ ] Update function definitions to fish syntax
