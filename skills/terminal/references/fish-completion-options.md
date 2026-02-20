# Complete Command Options Reference

## Command Specification

| Option | Description |
|--------|-------------|
| `-c`/`--command` COMMAND | Command name to complete for |
| `-p`/`--path` COMMAND | Absolute path to command (supports wildcards) |
| `-e`/`--erase` | Delete completions (all for command, or specific option) |

## Option Types

| Option | Syntax | Groupable | Value attachment |
|--------|--------|-----------|-----------------|
| `-s`/`--short-option` X | `-X` | Yes (`-abc` = `-a -b -c`) | `-Xvalue` or `-X value` (with `-r`) |
| `-l`/`--long-option` NAME | `--NAME` | No | `--name=value` or `--name value` (with `-r`) |
| `-o`/`--old-option` NAME | `-NAME` | No | `-name value` or `-name=value` |

**One option per `complete` call.** Multiple `-s`/`-l`/`-o` on one call: last one wins silently.

## Arguments

| Option | Description |
|--------|-------------|
| `-a`/`--arguments` ARGS | Completion candidates |
| `-d`/`--description` DESC | Description shown in completion pager |
| `-k`/`--keep-order` | Preserve argument order (don't alphabetize) |

### `-a` argument rules

**Static:** Space/tab-separated tokens. Each token = one candidate.
```fish
-a "json yaml xml"    # Three candidates
```

**Dynamic:** Command substitution. Each output **line** = one candidate. Tab character in output separates `value\tdescription`.
```fish
-a "(cmd --list 2>/dev/null)"                        # Each line = candidate
-a "(cmd --list 2>/dev/null | jq -r '.[] | .name')"  # Parsed JSON
```

**Binding:** Without `-s`/`-l`/`-o`, arguments are positional (subcommands). With option flags, arguments are values for that option.

### `-k` ordering

Multiple `-k` calls: **later calls' arguments display first**. Order your `complete` calls accordingly.

## Parameter Behavior

| Option | Description |
|--------|-------------|
| `-r`/`--require-parameter` | Option requires an argument — offered after space and `=` |
| `-f`/`--no-files` | Suppress filename completions |
| `-F`/`--force-files` | Re-enable filename completions (overrides `-f`) |
| `-x`/`--exclusive` | Shorthand for `-r -f` |

### How `-f` and `-F` interact

`-f` on **any** matching completion rule suppresses files for that command context. `-F` on a specific rule overrides this suppression.

```fish
# Pattern: global disable + selective enable
complete -c cmd -f                        # No files for entire command
complete -c cmd -l output -rF -d "File"   # Force files for --output
complete -c cmd -l format -xa "json xml"  # No files (inherited from global -f)
```

### Optional vs required arguments

| Flag | Behavior | `--opt <TAB>` | `--opt=<TAB>` |
|------|----------|---------------|----------------|
| (none) | Optional | No completions | Shows `-a` candidates |
| `-r` | Required | Shows `-a` candidates + files | Shows `-a` candidates + files |
| `-x` (`-r -f`) | Required, no files | Shows `-a` candidates only | Shows `-a` candidates only |

**This is the #1 source of subtle bugs.** If your option takes a value, always use `-r`, `-x`, `-ra`, or `-xa`.

### Flag combinations

Fish allows combining single-letter flags:

| Shorthand | Expands to | Use case |
|-----------|------------|----------|
| `-ra "args"` | `-r -a "args"` | Required param with candidates |
| `-xa "args"` | `-x -a "args"` | Exclusive with candidates |
| `-rF` | `-r -F` | Required param, force file completion |
| `-kxa "args"` | `-k -x -a "args"` | Keep order, exclusive with candidates |

## Conditions

| Option | Description |
|--------|-------------|
| `-n`/`--condition` SCRIPT | Completion offered only when SCRIPT returns 0 |

The condition is a fish script string. It has access to `commandline` and all fish builtins.

```fish
# Common patterns
-n "not __fish_seen_subcommand_from $commands"        # No subcommand yet
-n "__fish_seen_subcommand_from start"                # After "start" subcommand
-n "__fish_contains_opt -s d debug"                   # After -d or --debug
-n "__fish_use_subcommand"                            # No non-switch arg given
-n "not __fish_contains_opt system global"            # Neither --system nor --global
```

Multiple conditions can be combined with `; and` / `; or`:
```fish
-n "__fish_seen_subcommand_from config; and not __fish_seen_subcommand_from $config_cmds"
```

## `commandline` Builtin (for conditions and helpers)

| Flag | Returns |
|------|---------|
| `-opc` | Tokenized args, current process, up to cursor (raw) |
| `-xpc` | Expanded args, current process, up to cursor (variables resolved) |
| `-ct` | Current token being completed |
| `-pxc` | Expanded, tokenized current process (used by `__fish_seen_subcommand_from`) |

**Use `-opc` for subcommand detection** (matches raw tokens). Use `-xpc` when variables need expansion.

```fish
# Typical pattern for custom condition functions
function __fish_mycli_using_subcommand
    set -l cmd (commandline -opc)
    test (count $cmd) -ge 2; and test "$cmd[2]" = "$argv[1]"
end
```

## Wrapping

| Option | Description |
|--------|-------------|
| `-w`/`--wraps` COMMAND | Inherit completions from COMMAND |

- Transitive: A wraps B, B wraps C -> A gets C's completions
- Only works with `-c`/`--command`, not `-p`/`--path`
- A command can wrap multiple commands

## Querying

| Option | Description |
|--------|-------------|
| `-C`/`--do-complete` STRING | Output possible completions for STRING |
| `--escape` | Escape special chars in output (with `-C`) |

```fish
# Test completions
complete -C "mycli "           # What completes after "mycli "?
complete -C "mycli start --"   # What options after "mycli start --"?
```

## Built-in Helper Functions

### Condition helpers (return 0/1)

| Function | True when |
|----------|-----------|
| `__fish_seen_subcommand_from CMD...` | Any CMD found on commandline |
| `__fish_use_subcommand` | No non-switch argument given yet |
| `__fish_contains_opt -s X name` | `-X` or `--name` found on commandline |
| `__fish_not_contain_opt -s X name` | Neither `-X` nor `--name` found |
| `__fish_number_of_cmd_args_wo_opts` | Returns count of non-option arguments |

### Completion generators (return candidates)

| Function | Output format | Purpose |
|----------|---------------|---------|
| `__fish_complete_directories [STR [DESC]]` | `value\tdesc` | Directory paths |
| `__fish_complete_path [STR [DESC]]` | `value\tdesc` | File/directory paths |
| `__fish_complete_suffix .ext` | `value\tdesc` | Files with extension (sorted first) |
| `__fish_complete_users` | `value\tdesc` | Users with full names |
| `__fish_complete_groups` | `value\tdesc` | Groups with member info |
| `__fish_complete_pids` | `value\tdesc` | PIDs with command names |
| `__fish_complete_subcommand [--fcs-skip=N]` | completions | Recursive subcommand completion |

### List generators (return values only)

| Function | Purpose |
|----------|---------|
| `__fish_print_hostnames` | From ssh config, /etc/hosts, fstab |
| `__fish_print_interfaces` | Network interfaces |
| `__fish_print_filesystems` | Known filesystem types |

## File Locations (search order)

Fish searches `$fish_complete_path` — first match wins:

1. `~/.config/fish/completions` — user completions
2. `/etc/fish/completions` — sysadmin
3. `~/.local/share/fish/vendor_completions.d` — user third-party
4. `/usr/share/fish/vendor_completions.d` — vendor
5. `/usr/share/fish/completions` — shipped with fish
6. `~/.cache/fish/generated_completions` — auto-generated from man pages
