# Fish Shell Converter & Validator

Convert bash scripts to fish shell and validate fish code for bash-isms and syntax errors.

## When to Use This Skill

1. **Convert bash to fish:** Any bash script needs to be ported to fish
2. **Validate fish scripts:** Existing fish scripts that may contain bash syntax
3. **Fix AI-generated fish code:** AI-generated fish code that sneaks in bash syntax
4. **Audit existing scripts:** Check fish scripts for correctness

## Core Workflow

### 1. Conversion Mode (Bash to Fish)

When converting bash scripts to fish:

1. **Read the reference guide** to understand all differences:
   ```
   Read references/fish-bash-differences.md
   ```

2. **Analyze the bash script** for these high-frequency patterns:
   - Variable assignments (`VAR=value`)
   - Export statements (`export VAR=value`)
   - Command substitutions (backticks)
   - String manipulation (`${var%suffix}`, `${var#prefix}`, `${var/old/new}`)
   - Arithmetic (`$((expr))`)
   - Conditionals (`[[`, `==`)
   - Special variables (`$?`, `$1`, `$#`)
   - Heredocs
   - Arrays/word splitting assumptions

3. **Convert systematically** section by section:
   - Start with variable declarations
   - Convert command substitutions
   - Replace string operations with `string` builtin
   - Update conditionals and loops to fish syntax
   - Convert functions
   - Handle special cases (heredocs, process substitution)

4. **Output format:**
   - Provide clean, corrected fish code
   - After the code, list notable changes in a brief summary
   - Format: "Notable changes: [list key conversions]"

### 2. Validation Mode (Fish to Fish)

When validating existing fish scripts:

1. **Scan for bash-isms** - common mistakes:
   - `VAR=value` assignments (should be `set VAR value`)
   - `export` command (should be `set -x`)
   - `local` keyword (should be `set -l`)
   - Backticks (should be `()` or `$()`)
   - `${var}` parameter expansion (should use `string` builtin)
   - `$((math))` (should use `math` command)
   - `[[` conditionals (should use `test` or `[`)
   - `==` in tests (should be `=`)
   - `$1, $2` args (should be `$argv[1], $argv[2]`)
   - `$#` (should be `count $argv`)
   - `$?` (should be `$status`)
   - Heredocs (should use pipes or echo)
   - Incorrect quoting patterns
   - Word splitting assumptions

2. **Check fish-specific correctness:**
   - Proper `set` syntax and scoping flags
   - Correct use of `string` builtin
   - Proper command substitution syntax
   - Block structure (`end` keywords)
   - Function definitions

3. **Output format:**
   - Provide corrected fish code
   - List notable fixes: "Fixed: [list issues found and corrected]"

## Common Conversion Patterns

### Variable Operations

```fish
# Bash -> Fish
VAR=value              -> set VAR value
export VAR=value       -> set -x VAR value
local VAR=value        -> set -l VAR value
unset VAR              -> set -e VAR
$1, $2, $3            -> $argv[1], $argv[2], $argv[3]
$#                     -> count $argv
$?                     -> $status
```

### String Operations

```fish
# Bash -> Fish
${var%suffix}          -> string replace -r 'suffix$' '' $var
${var#prefix}          -> string replace -r '^prefix' '' $var
${var/old/new}         -> string replace old new $var
${var//old/new}        -> string replace -a old new $var
${var^^}               -> string upper $var
${var,,}               -> string lower $var
```

### Command Substitution

```fish
# Bash -> Fish
`command`              -> (command)
$(command)             -> (command) or $(command)
```

### Conditionals

```fish
# Bash -> Fish
if [[ $x == "foo" ]]   -> if test $x = "foo"
if [[ -f $file ]]      -> if test -f $file
if [ $x -eq 5 ]        -> if test $x -eq 5
```

### Arithmetic

```fish
# Bash -> Fish
$((i + 1))             -> math $i + 1
$[i + 1]               -> math $i + 1
```

### Loops & Blocks

```fish
# Bash -> Fish
for x in ...; do       -> for x in ...
  ...                      ...
done                   -> end

while ...; do          -> while ...
  ...                      ...
done                   -> end

{ ... }                -> begin ... end
```

### Functions

```fish
# Bash -> Fish
foo() {                -> function foo
  ...                      ...
}                      -> end
```

## Special Considerations

### Quoting

Fish doesn't do word splitting, so many quotes are unnecessary:
```fish
# In bash, must quote to prevent word splitting:
echo "$var"

# In fish, quoting is optional for word splitting prevention:
echo $var    # Works fine even if $var contains spaces
```

However, quotes are still needed for:
- Literal strings with spaces
- Preserving empty strings
- Glob prevention

### Globs

Globs don't expand in variables:
```fish
set pattern "*.txt"
echo $pattern    # Prints literal "*.txt", doesn't match files
```

### Subshells

Fish has no subshells. Variables set in pipes are visible:
```fish
echo foo | read bar
echo $bar    # Works! $bar is visible
```

For isolation, use: `fish -c 'code here'`

## Validation Checklist

Before finalizing converted/validated code, verify:

- [ ] All `VAR=value` converted to `set VAR value`
- [ ] All `export` converted to `set -x`
- [ ] All backticks converted to `()`
- [ ] All `${var%pattern}` etc. converted to `string` commands
- [ ] All `$((math))` converted to `math` command
- [ ] All `[[` converted to `test` or `[`
- [ ] All `==` in tests converted to `=`
- [ ] All `$1`, `$#`, `$?` converted to fish equivalents
- [ ] All `do/done/then/fi` converted to fish block structure
- [ ] No semicolons (optional but clean to remove)
- [ ] Heredocs converted to pipes/echo/printf
- [ ] Functions use fish syntax

## Output Style Guidelines

### Code Output
- Clean, production-ready fish code
- Use modern fish idioms
- Remove unnecessary quotes (fish doesn't word-split)

### Change Summary
After code, provide a brief "Notable changes:" or "Fixed:" section listing:
- Key syntax conversions
- Major pattern replacements
- Critical fixes
Only mention significant changes, not trivial syntax adjustments

### Example Output Format

```fish
#!/usr/bin/env fish

# [Clean converted code here]

function my_function
  set -l result (command)
  if test -n "$result"
    echo $result
  end
end
```

**Notable changes:**
- Converted `VAR=$(cmd)` to `set VAR (cmd)`
- Replaced `export PATH=...` with `set -x PATH ...`
- Changed `${var%suffix}` to `string replace`
- Updated `$1` to `$argv[1]`

## Reference

For comprehensive details on all bash/fish differences, see [fish-bash-differences.md](fish-bash-differences.md).
