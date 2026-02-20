---
name: terminal
description: "Terminal toolkit for CLI tool management, Fish shell completions, and bash-to-fish conversion. Use when: (1) ingesting CLI tools for documentation and completions, (2) writing or editing Fish shell tab-completion scripts, (3) converting bash scripts to Fish shell syntax, (4) validating Fish scripts for bash-isms, or (5) looking up Fish completion patterns and options."
allowed-tools: Read, Bash, Glob, Grep
---

# Terminal Toolkit

Self-contained plugin for CLI tool workflows, Fish shell completions, and shell script conversion.

## Capabilities

### 1. CLI Tool Ingestion (`/terminal:ingest-cmd`)

Generates a specialized Claude agent and Fish completions from any CLI tool.
See [Ingest Workflow](#ingest-workflow) below.

### 2. Fish Shell Completions

Write tab-completion scripts for CLI applications in Fish shell.

**When to use:** Writing new completions, fixing completion scripts, or adding completions to a tool.

Load the full reference:
```
Read references/fish-completions.md
```
For detailed option documentation:
```
Read references/fish-completion-options.md
```

### 3. Fish Shell Converter

Convert bash scripts to Fish syntax or validate existing Fish scripts for bash-isms.

**When to use:** Converting bash snippets from Stack Overflow, porting install scripts, or auditing Fish code.

Load the full reference:
```
Read references/fish-shell-converter.md
```
For comprehensive bash-to-fish differences:
```
Read references/fish-bash-differences.md
```

---

## Ingest Workflow

This workflow is executed by the `/terminal:ingest-cmd` command. It expects:
- **CMD** — the CLI tool name (e.g., `git`, `docker`, `bun`)
- **FETCH_DOCS** — boolean: whether to fetch online documentation

### Step 1: Data Collection (cli-collector subagent, background)

Launch a **Task** delegating to the `cli-collector` subagent:
- **subagent_type:** `cli-collector`
- **run_in_background:** true
- **Prompt:** `Collect all help data for the \`CMD\` CLI tool.`

The `cli-collector` subagent runs on Haiku with Bash-only tools. It collects `--help` output,
subcommand help, and man pages, returning a structured markdown document.

This runs in the background. Note the agent ID / output file for later retrieval.

**While the collector runs**, proceed to Step 2 if FETCH_DOCS is true, or wait for completion if false.

### Step 2: Online Documentation (conditional, parallel with Step 1)

Skip if FETCH_DOCS is false.

If FETCH_DOCS is true:
1. WebSearch: `"CMD" official documentation`
2. Identify the official docs URL (prefer project site over GitHub README)
3. WebFetch the docs landing page, extracting:
   - Tool overview / description
   - Quick start or common usage examples
   - Any "pitfalls", "gotchas", or "important notes" sections
4. Limit to 2 pages maximum
5. Store as supplementary data for synthesis

### Step 3: Retrieve Collection Results

Read the background task output (use TaskOutput or Read the output file).

Save the raw corpus to the cache for debugging/re-runs:
```bash
Write ~/.claude/skills/terminal/.cache/CMD-collected.md
```

This cached file can be re-read later if synthesis needs to be re-run without re-collecting.

### Step 4: Generate Agent File

Read the agent template:
```
Read references/agent-template.md
```

```bash
mkdir -p ~/.claude/agents/terminal
```

Write to: `~/.claude/agents/terminal/CMD-expert.md`

Replace `{{CMD}}` in the template, then fill every section from the collected data corpus.

**Section guidance:**
- **Overview**: What the tool does, primary use case, version if known
- **Subcommands table**: One row per subcommand with description and key flags
- **Global Options**: Flags that apply regardless of subcommand
- **Per-subcommand sections**: Purpose, syntax, all options, concrete example
- **Common Patterns**: 5-10 practical usage patterns from help/man/docs
- **Gotchas**: Non-obvious behaviors, required flag ordering, common mistakes

Be thorough — this agent answers questions about CMD without needing to re-run help.

### Step 5: Generate Fish Completions

Load the fish completions reference:
```
Read references/fish-completions.md
```

Write to: `~/.config/fish/completions/CMD.fish`

Apply all rules from the fish completions reference. Additionally enforce these hard requirements:

1. **Every subcommand completion MUST include `-d "description"`**
   - Derive from the first sentence of `CMD SUBCOMMAND --help`
   - If help gives nothing useful, write a concise imperative phrase
   - A bare `-a "subcommand"` with no description is not acceptable

2. Use `complete -c CMD -f` at top if the tool doesn't accept arbitrary file paths

3. Scope subcommand-specific flags using `__fish_seen_subcommand_from` conditions

4. Use `2>/dev/null` on every external command in dynamic `-a "(...)"` completions

5. For CLIs with global flags that take values, write custom `__fish_CMD_needs_command` and `__fish_CMD_using_subcommand` helpers using the `argparse` pattern from the completions reference

### Step 6: Report

Output:
```
Agent:       ~/.claude/agents/terminal/CMD-expert.md
Completions: ~/.config/fish/completions/CMD.fish
Cache:       ~/.claude/skills/terminal/.cache/CMD-collected.md

Collection:
  Subcommands: N ingested
  Man page:    found / not found
  Help levels: single / short+full
  Online docs: fetched (N pages) / skipped

To activate completions immediately:
  source ~/.config/fish/completions/CMD.fish
```

## Output Locations

| Artifact | Path | Reason |
|----------|------|--------|
| Agent | `~/.claude/agents/terminal/CMD-expert.md` | Claude Code discovers agents from `~/.claude/agents/` |
| Completions | `~/.config/fish/completions/CMD.fish` | Fish auto-loads from this directory |
| Cache | `~/.claude/skills/terminal/.cache/CMD-collected.md` | Debugging and re-synthesis |
