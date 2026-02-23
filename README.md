# Terminal Skill for Claude Code

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that turns any CLI tool into a specialized AI agent with Fish shell completions — automatically.

Run `/terminal:ingest-cmd git` and get:
- A **Claude agent** that knows every `git` subcommand, flag, and gotcha — no internet or `--help` lookups needed
- A **Fish shell completion** script with proper subcommand scoping, descriptions, and dynamic completions

Also includes reference knowledge for writing Fish completions from scratch and converting bash scripts to Fish.

## What It Does

### CLI Tool Ingestion

Point it at any CLI tool and it generates two artifacts:

1. **Expert Agent** — A Claude Code subagent pre-loaded with the tool's full documentation (subcommands, flags, options, common patterns, gotchas). Claude invokes this agent proactively when you ask about the tool, giving instant answers without running `--help`.

2. **Fish Completions** — A tab-completion script following Fish shell best practices: subcommand descriptions, `__fish_seen_subcommand_from` scoping, dynamic completions with `2>/dev/null`, proper `-r`/`-x` flag usage.

### Fish Shell Knowledge

The skill includes comprehensive reference documents that Claude loads on demand:

- **Fish Completions Guide** — Critical rules, patterns, helper functions, and common mistakes for writing `complete` scripts
- **Fish Completion Options** — Every flag of the `complete` builtin with interaction details
- **Bash-to-Fish Converter** — Systematic workflow for porting bash scripts to Fish
- **Bash vs Fish Differences** — Complete reference covering variables, loops, conditionals, string operations, and 20+ other categories

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- [Fish shell](https://fishshell.com/) (for completions output; the skill itself works in any shell)

### Plugin Install

If you have the terminal plugin marketplace registered:

```
/plugin install terminal
```

Or install directly from the repository:

```
/plugin install github:thalys/cc-barracuda
```

### Development Install

For contributors who clone the repo:

```fish
git clone https://github.com/thalys/cc-barracuda.git
cd cc-barracuda
fish install.fish
```

This creates symlinks from the repo to `~/.claude/`, so updates are picked up with `git pull`.

### Manual Install

Copy or symlink these paths:

```
# Skill (main instructions + reference docs)
~/.claude/skills/terminal/  ->  skills/terminal/

# Subagent (background data collector)
~/.claude/agents/terminal/cli-collector.md  ->  agents/cli-collector.md

# Slash command
~/.claude/commands/terminal/ingest-cmd.md  ->  commands/ingest-cmd.md
```

### Verify

Restart Claude Code, then run:
```
/terminal:ingest-cmd --help
```

You should see the argument hint: `<command-name> [--docs]`.

## Usage

### Ingest a CLI Tool

```
/terminal:ingest-cmd docker
```

This runs a 6-step pipeline:

1. **Collect** — A background Haiku agent runs `--help`, `-h`, `help`, and `man` for every subcommand
2. **Fetch docs** (optional) — Add `--docs` to also search and fetch online documentation
3. **Cache** — Raw corpus saved to `~/.claude/skills/terminal/.cache/` for re-synthesis
4. **Generate agent** — Comprehensive expert agent written to `~/.claude/agents/terminal/`
5. **Generate completions** — Fish completion script written to `~/.config/fish/completions/`
6. **Report** — Summary of what was generated

After ingestion, Claude will proactively invoke the expert agent whenever you ask about that tool.

### Write Fish Completions

Just ask Claude to write completions for a tool:

```
Write Fish completions for mycli
```

The terminal skill activates automatically and Claude loads the completions reference, producing a script that follows all the critical rules (proper `-f` scoping, `-r` on valued options, subcommand descriptions, etc.).

### Convert Bash to Fish

```
Convert this bash script to Fish: [paste script]
```

Claude loads the converter workflow and bash-fish differences reference, producing correct Fish code with a summary of changes.

### Validate Fish Scripts

```
Check this Fish script for bash-isms: [paste script]
```

Scans for common mistakes like `VAR=value`, `export`, backticks, `[[`, `$?`, and provides corrected code.

## Project Structure

```
cc-barracuda/
├── .claude-plugin/
│   └── plugin.json                     # Plugin manifest
├── skills/terminal/
│   ├── SKILL.md                        # Main skill definition
│   ├── .cache/                         # Collected data (gitignored)
│   └── references/
│       ├── agent-template.md           # Template for generated agents
│       ├── collector-prompt.md         # Data collection protocol reference
│       ├── fish-completions.md         # Fish completions guide
│       ├── fish-completion-options.md  # complete builtin reference
│       ├── fish-bash-differences.md    # Bash vs Fish reference
│       └── fish-shell-converter.md     # Conversion workflow
├── agents/
│   └── cli-collector.md                # Background data collection agent
├── commands/
│   └── ingest-cmd.md                   # /terminal:ingest-cmd slash command
├── examples/agents/
│   └── fzf-expert.md                   # Example generated agent
├── install.fish                        # Installer (dev workflow)
├── uninstall.fish                      # Uninstaller
├── LICENSE                             # MIT
└── README.md
```

## Generated Output

After running `/terminal:ingest-cmd CMD`, you get:

| Artifact | Location | Purpose |
|----------|----------|---------|
| Expert Agent | `~/.claude/agents/terminal/CMD-expert.md` | Claude Code discovers and invokes it |
| Fish Completions | `~/.config/fish/completions/CMD.fish` | Fish auto-loads on next `<TAB>` |
| Raw Cache | `~/.claude/skills/terminal/.cache/CMD-collected.md` | Re-run synthesis without re-collecting |

See [`examples/agents/fzf-expert.md`](examples/agents/fzf-expert.md) for a real generated agent.

## How It Works

The ingestion pipeline has three layers:

**Collection** — A Haiku-powered `cli-collector` subagent runs in the background, executing `--help`, `-h`, `help`, and `man` for the base command and every discovered subcommand. It returns raw, unprocessed output.

**Synthesis** — The main agent reads the raw corpus and the agent template, then generates a comprehensive expert document covering: overview, subcommands table, global options, per-subcommand reference with all flags, common patterns, and gotchas.

**Completions** — Using the Fish completions reference as a ruleset, the agent generates a completion script with proper structure: global `-f` disable, subcommand conditions, `-r`/`-x` on valued options, dynamic completions with stderr suppression, and mandatory `-d` descriptions.

## Customization

### Agent Template

Edit `skills/terminal/references/agent-template.md` to change the structure of generated agents. The template uses `{{CMD}}` placeholders.

### Collector Behavior

Edit `agents/cli-collector.md` to change what data is collected. The collector runs on Haiku with Bash-only tools and a 50-turn limit.

### Completion Rules

The hard requirements in `SKILL.md` (Step 5) enforce completion quality. Modify these if your team has different conventions.

## Uninstall

```fish
fish uninstall.fish
```

Removes symlinks only. Generated agents and completions in `~/.claude/agents/terminal/` and `~/.config/fish/completions/` are not touched — delete them manually if desired.

## License

MIT
