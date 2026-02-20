# Fish Shell Completions

Create completion files for CLI applications in Fish shell.

## Critical Rules

These non-obvious behaviors cause most completion bugs. Read before writing any completion.

### 1. File Completion Scoping

`-f` on ANY matching completion rule suppresses file completions for the command. Use a standalone `complete -c cmd -f` to disable globally, then `-F` to re-enable per-option.

```fish
# CORRECT: Global disable, selective re-enable
complete -c cmd -f                          # No files anywhere
complete -c cmd -l config -rF -d "Config"   # Except --config

# WRONG: -f only on -a lines doesn't disable files for other completions
complete -c cmd -f -a "sub1 sub2"           # -f only affects this line's context
complete -c cmd -l verbose                  # Files STILL show here
```

### 2. Optional vs Required Arguments

Without `-r`, option arguments are **optional** — only offered when directly attached (`--opt=<TAB>` or `-o<TAB>`). With `-r`, also offered after space (`--opt <TAB>`).

```fish
# BUG: `--format <TAB>` shows NOTHING (optional args need direct attachment)
complete -c cmd -l format -a "json yaml"

# FIX: -r makes arguments appear after space too
complete -c cmd -l format -ra "json yaml"

# ALSO: -x = -r + -f (required, no file fallback)
complete -c cmd -l format -xa "json yaml"
```

### 3. `-a` Binding Rules

`-a` without option flags (`-s`/`-l`/`-o`) = positional/subcommand arguments.
`-a` with option flags = arguments FOR that specific option.

```fish
# Positional: "start" offered as subcommand argument
complete -c cmd -f -a "start stop"

# Option-bound: "json" offered only as value for --format
complete -c cmd -l format -xa "json yaml"
```

### 4. One Option Per `complete` Call

Each call defines ONE option. Multiple `-l` flags silently overwrite.

```fish
# SILENT BUG: only --allowed-tools takes effect
complete -c cmd -l allowedTools -l allowed-tools -x

# CORRECT: separate calls
complete -c cmd -l allowedTools -x -d "Tool names"
complete -c cmd -l allowed-tools -x -d "Tool names"
```

### 5. Flag Combinations

Fish allows combining single-letter flags in `complete`:

```fish
-ra "args"   # = -r -a "args"  (required + arguments)
-xa "args"   # = -x -a "args"  (exclusive + arguments)
-rF          # = -r -F         (required + force files)
-kxa "args"  # = -k -x -a "args"
```

### 6. `-k` Ordering Gotcha

`-k` preserves order but multiple `-k` calls display **later calls first**.

```fish
# Display order: gamma, delta, alpha, beta (later -k calls shown first!)
complete -c cmd -kxa "alpha beta"
complete -c cmd -kxa "gamma delta"
```

### 7. Subcommand Descriptions Are Mandatory

Every subcommand completion MUST include `-d "description"`. A bare `-a "name"` with no description is incomplete.

Derive the description from the tool's help text (first sentence of the subcommand's own help output). If help text is absent, write a concise imperative phrase.

```fish
# WRONG: subcommand with no description
complete -c cmd -n "not __fish_seen_subcommand_from $commands" -a "start"

# CORRECT: always derive and include -d
complete -c cmd -n "not __fish_seen_subcommand_from $commands" -a "start" -d "Start the service in the foreground"
```

## Quick Reference

```fish
complete -c COMMAND [OPTIONS]

# Option types
-s X          # Short: -X (single char, groupable: -abc = -a -b -c)
-l name       # Long: --name (GNU-style, value via = or space with -r)
-o name       # Old-style: -name (single hyphen, NOT groupable)

# Arguments
-a "arg1 arg2"              # Static (space/tab separated)
-a "(command)"              # Dynamic (each output LINE = candidate)
-d "Description"            # Shown in completion pager

# Argument behavior
-r            # Requires parameter (offered after space)
-f            # No file completions (alias: --no-files)
-F            # Force file completions (overrides -f)
-x            # Exclusive: -r + -f combined

# Control
-n "CONDITION"  # Offer only when CONDITION returns 0
-k              # Keep order (don't alphabetize)
-w other_cmd    # Inherit completions (transitive: A->B->C)
-e              # Erase completions
-C "string"     # Query: output completions for string
```

## Workflow

1. Read `cmd --help` or man page — catalog all subcommands, options, and their arguments
2. `complete -c cmd -f` — disable file completions globally (if command doesn't take arbitrary files)
3. Define subcommands with `not __fish_seen_subcommand_from` condition
4. Add global options (no subcommand condition needed)
5. Add subcommand-specific options with `__fish_seen_subcommand_from` conditions
6. Add dynamic completions with `2>/dev/null` on all external commands
7. Test with `complete -C "cmd "` and `complete -C "cmd sub "` to verify

## Patterns

### Subcommand-Based CLI

```fish
set -l commands start stop status config

complete -c mycli -f
complete -c mycli -n "not __fish_seen_subcommand_from $commands" -a "$commands"
complete -c mycli -n "__fish_seen_subcommand_from start" -l daemon -d "Run as daemon"
complete -c mycli -n "__fish_seen_subcommand_from config" -l file -rF -d "Config file"
```

### Options with Arguments

```fish
# Enumerated values (no files)
complete -c tool -s f -l format -xa "json yaml xml" -d "Output format"

# File path argument
complete -c tool -s o -l output -rF -d "Output file"

# Specific file types
complete -c tool -l config -r -a "(__fish_complete_suffix .toml)" -d "Config"

# Directory only
complete -c tool -l dir -xa "(__fish_complete_directories)" -d "Directory"
```

### Dynamic Completions

```fish
# Each output line = one candidate (always suppress stderr)
complete -c docker -n "__fish_seen_subcommand_from rm" \
    -a "(docker ps -aq 2>/dev/null)"

# Tab-separated value\tdescription
complete -c git -n "__fish_seen_subcommand_from checkout" \
    -a "(git branch --format='%(refname:short)\t%(upstream:short)' 2>/dev/null)"

# JSON: use jq (never regex for JSON parsing)
complete -c tool -n "__fish_seen_subcommand_from use" \
    -a "(tool list --json 2>/dev/null | jq -r '.[].name')"
```

### Multi-Level Subcommands

```fish
set -l commands config run help
set -l config_commands get set list

complete -c app -f
complete -c app -n "not __fish_seen_subcommand_from $commands" -a "$commands"

# Level 2: only show config subcommands when "config" is the active subcommand
complete -c app -n "__fish_seen_subcommand_from config; and not __fish_seen_subcommand_from $config_commands" \
    -a "$config_commands"

# Level 2 options
complete -c app -n "__fish_seen_subcommand_from config; and __fish_seen_subcommand_from set" \
    -l global -d "Set globally"
```

### Custom Condition Functions

For CLIs with global options that consume arguments (confusing `__fish_seen_subcommand_from`):

```fish
function __fish_mycli_needs_command
    set -l cmd (commandline -opc)
    set -e cmd[1]
    # Strip global options that take arguments
    argparse -s 'c/config=' 'v/verbose' -- $cmd 2>/dev/null
    or return
    not set -q argv[1]  # True if no subcommand yet
end

function __fish_mycli_using_subcommand
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s 'c/config=' 'v/verbose' -- $cmd 2>/dev/null
    or return 1
    set -q argv[1]; and test "$argv[1]" = "$argv[-1]"
end
```

**When to use custom functions vs `__fish_seen_subcommand_from`:**
- Simple CLI (no global options with values): use `__fish_seen_subcommand_from`
- CLI with global `-o VALUE` options: use `argparse`-based custom functions

### `commandline` Builtin for Conditions

```fish
commandline -opc   # Tokenized args (raw), current process, up to cursor
commandline -xpc   # Expanded args (variables resolved), current process, up to cursor
commandline -ct    # Current token being completed
```

Use `-opc` for subcommand detection (raw tokens). Use `-xpc` when you need variable expansion.

## Helper Functions

| Function | Returns | Purpose |
|----------|---------|---------|
| `__fish_seen_subcommand_from CMD...` | 0/1 | Any CMD appears on cmdline |
| `__fish_use_subcommand` | 0/1 | No non-switch arg given yet |
| `__fish_contains_opt -s X name` | 0/1 | `-X` or `--name` present |
| `__fish_complete_directories [STR [DESC]]` | tab-sep | Directory paths |
| `__fish_complete_path [STR [DESC]]` | tab-sep | File/dir paths |
| `__fish_complete_suffix .ext` | tab-sep | Files with extension (sorted first) |
| `__fish_complete_users` | tab-sep | System users with names |
| `__fish_complete_groups` | tab-sep | Groups with members |
| `__fish_complete_pids` | tab-sep | PIDs with command names |
| `__fish_print_hostnames` | newline | From ssh config, /etc/hosts |
| `__fish_print_interfaces` | newline | Network interfaces |
| `__fish_print_filesystems` | newline | Known filesystems |

**`__fish_complete_*`** returns tab-separated `value\tdescription` (for `-a`).
**`__fish_print_*`** returns newline-separated values only.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Missing `-r` on options with values | Use `-r`, `-x`, `-ra`, or `-xa` — without it, values only show on `=` attachment |
| `-f` only on `-a` lines, not standalone | Add `complete -c cmd -f` on its own line first |
| Two `-l` flags on one `complete` call | Separate `complete` calls — second `-l` silently wins |
| Missing `2>/dev/null` on dynamic `-a` | Always: `-a "(cmd 2>/dev/null)"` |
| Parsing JSON with regex | Use `jq -r` — regex breaks on escaping/field order changes |
| Not testing completions | Run `complete -C "cmd "` to verify |
| Expensive commands in `-a` without cache | Runs on every `<TAB>` — cache results or limit output |
| `commandline -opc` vs `-xpc` confusion | `-opc` = raw tokens, `-xpc` = expanded. Use `-opc` for subcommand checks |
| Missing `-d` on subcommand `-a` lines | Always include `-d "description"` for every subcommand — derive from help text |

## File Location

Save to `~/.config/fish/completions/COMMAND.fish` (autoloaded by fish).

## Option Reference

See [fish-completion-options.md](fish-completion-options.md) for complete option documentation and interaction details.
