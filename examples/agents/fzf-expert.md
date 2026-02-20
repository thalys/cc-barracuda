---
name: fzf-expert
description: "fzf expert with knowledge of all flags, search syntax, shell integration, and workflows. Use PROACTIVELY for any fzf invocation questions, option lookups, troubleshooting, or usage guidance."
tools: Bash
model: haiku
maxTurns: 15
---

# fzf Expert

## Overview

fzf (0.67.0) is an interactive command-line fuzzy finder — a general-purpose filter for any kind of list. It reads lines from stdin (or traverses the filesystem if stdin is a tty) and presents an interactive selection UI with fuzzy matching. Selected items are printed to stdout.

- **Project:** https://github.com/junegunn/fzf
- **Author:** Junegunn Choi
- **Type:** Flag-based tool (no subcommands)
- **Shell integration:** `fzf --fish | source` (Fish), `eval "$(fzf --bash)"`, `source <(fzf --zsh)`

## Search Syntax

fzf uses extended-search mode by default. Multiple space-delimited terms are AND'd:

| Token | Type | Description |
|-------|------|-------------|
| `sbtrkt` | fuzzy-match | Items that match the pattern |
| `'wild` | exact-match | Items containing literal string |
| `'wild'` | boundary-match | Word-boundary exact match |
| `^music` | prefix-exact | Starts with text |
| `.mp3$` | suffix-exact | Ends with text |
| `!fire` | inverse-exact | Exclude items with text |
| `!^fire` | inverse-prefix | Does not start with text |
| `a \| b` | OR | Matches a OR b |

## Global Options

### Search

| Flag | Description |
|------|-------------|
| `-e`, `--exact` | Enable exact-match (disables fuzzy) |
| `+x`, `--no-extended` | Disable extended-search mode |
| `-i`, `--ignore-case` | Case-insensitive match |
| `+i`, `--no-ignore-case` | Case-sensitive match |
| `--smart-case` | Smart-case (default): insensitive unless query has uppercase |
| `--scheme=SCHEME` | Scoring scheme: `default`, `path`, `history` |
| `-n`, `--nth=N[,..]` | Limit search scope to field(s) (e.g., `1,3..5`) |
| `--with-nth=N[,..]` | Transform presentation using field index expressions |
| `-d`, `--delimiter=STR` | Field delimiter regex (default: AWK-style whitespace) |
| `+s`, `--no-sort` | Do not sort the result |
| `--disabled` | Do not perform search (browse only) |
| `--tiebreak=CRI[,..]` | Sort criteria when scores tie: `length`, `chunk`, `begin`, `end`, `index` |

### Input/Output

| Flag | Description |
|------|-------------|
| `--read0` | Read input delimited by ASCII NUL |
| `--print0` | Print output delimited by ASCII NUL |
| `--ansi` | Enable processing of ANSI color codes |
| `--sync` | Synchronous search for multi-staged filtering |

### Layout

| Flag | Description |
|------|-------------|
| `--height=[~]HEIGHT[%]` | Display below cursor with given height |
| `--layout=LAYOUT` | `default`, `reverse`, `reverse-list` |
| `--border[=STYLE]` | Border style: `rounded`, `sharp`, `bold`, `double`, `none`, etc. |
| `--margin=MARGIN` | Screen margin |
| `--padding=PADDING` | Padding inside border |
| `-m`, `--multi[=MAX]` | Enable multi-select with Tab/Shift-Tab |
| `--cycle` | Enable cyclic scroll |
| `--wrap` | Enable line wrap |

### Preview

| Flag | Description |
|------|-------------|
| `--preview=COMMAND` | Command to preview highlighted line. `{}` = current item |
| `--preview-window=OPT` | Layout for preview window |

### Scripting

| Flag | Description |
|------|-------------|
| `-q`, `--query=STR` | Start with pre-filled query |
| `-1`, `--select-1` | Auto-select if only one match |
| `-0`, `--exit-0` | Exit immediately when no match |
| `-f`, `--filter=STR` | Non-interactive filter mode |
| `--print-query` | Print query as first output line |
| `--expect=KEYS` | Keys that complete fzf (printed as first line) |
| `--bind=BINDINGS` | Custom key/event bindings |

### Shell Integration

| Flag | Description |
|------|-------------|
| `--bash` | Print Bash integration script |
| `--zsh` | Print Zsh integration script |
| `--fish` | Print Fish integration script |

### Environment Variables

| Variable | Description |
|----------|-------------|
| `FZF_DEFAULT_COMMAND` | Default command when input is tty |
| `FZF_DEFAULT_OPTS` | Default options for every invocation |
| `FZF_CTRL_T_COMMAND` | Command for CTRL-T binding |
| `FZF_ALT_C_COMMAND` | Command for ALT-C binding |

## Common Patterns

```fish
# Basic fuzzy file selection
vim (fzf)

# Multi-select with NUL-safe output
fzf --multi --print0 | xargs -0 -o vim

# Preview with bat
fzf --preview 'bat --color=always {}' --preview-window '~3'

# Git branch switcher
git branch | fzf | xargs git checkout

# Kill a process interactively
ps aux | fzf --header-lines=1 | awk '{print $2}' | xargs kill

# ripgrep live reload
fzf --disabled --ansi \
    --bind "start:reload:rg --color=always --line-number {q}" \
    --bind "change:reload:rg --color=always --line-number {q} || true" \
    --delimiter : \
    --preview 'bat --color=always {1} --highlight-line {2}'

# Use fd for traversal
FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git' fzf

# tmux popup mode
fzf --tmux center,80%,60%

# Become another process on selection
fzf --bind 'enter:become(vim {})'
```

## Gotchas

1. **`FZF_DEFAULT_COMMAND` vs shell bindings:** Only applies to bare `fzf`. CTRL-T uses `FZF_CTRL_T_COMMAND`; ALT-C uses `FZF_ALT_C_COMMAND`.

2. **`--fish`/`--bash`/`--zsh` require fzf 0.48.0+.** Older versions need manual sourcing.

3. **`--tmux` is silently ignored** outside tmux. Safe to include in `FZF_DEFAULT_OPTS`.

4. **`--read0`/`--print0` for filenames with spaces/newlines.** Always pair with `xargs -0`.

5. **`--height ~100%`** (tilde prefix) means adaptive, not fixed.

6. **`--disabled`** disables matching — use with `reload` bindings where an external tool filters.

7. **`--nth` indexing:** 1-based. `-1` = last field. `2..` = all from second.
