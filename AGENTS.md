# AGENTS.md
This file provides guidance to AI coding assistants working in this repository.

**Note:** CLAUDE.md, .clinerules, .cursorrules, .windsurfrules, .replit.md, GEMINI.md, .github/copilot-instructions.md, and .idx/airules.md are symlinks to AGENTS.md.

# Terminal Skill for Claude Code

A Claude Code skill that turns any CLI tool into a specialized AI agent with Fish shell completions. Provides a toolkit for CLI tool ingestion, Fish shell completions authoring, and bash-to-fish conversion.

## Architecture

Three-layer pipeline for CLI ingestion:
1. **Collection** — Background Haiku subagent (`cli-collector`) runs bash commands to capture help text, man pages, subcommand docs
2. **Synthesis** — Sonnet agent reads corpus + template, generates expert agent markdown
3. **Completion** — Generates Fish shell completion script with enforced rules

### Project Structure
```
skills/terminal/          → Main skill (SKILL.md + references/)
agents/terminal/          → cli-collector subagent
commands/terminal/        → /terminal:ingest-cmd slash command
examples/agents/          → Sample generated output (fzf-expert.md)
install.fish              → Symlink-based installer
uninstall.fish            → Symlink remover
```

### Generated Artifacts (per-user, not in repo)
- Agent: `~/.claude/agents/terminal/CMD-expert.md`
- Completions: `~/.config/fish/completions/CMD.fish`
- Cache: `~/.claude/skills/terminal/.cache/CMD-collected.md`

## Build & Commands

No build system — this is a pure markdown + Fish shell project. No package.json, no dependencies.

| Command | Purpose |
|---------|---------|
| `fish install.fish` | Install via symlinks to `~/.claude/` |
| `fish install.fish --dry-run` | Preview installation without changes |
| `fish uninstall.fish` | Remove symlinks (keeps generated agents/completions) |
| `fish uninstall.fish --dry-run` | Preview uninstallation |

### Usage (after installation)
- `/terminal:ingest-cmd <tool> [--docs]` — Ingest a CLI tool (main entry point)
- Skill triggers automatically for Fish completions, bash-to-fish conversion tasks

## Code Style

### Fish Shell
- Use `set -g` (global) for variables accessed inside helper functions — `set -l` is NOT visible inside `function` bodies
- Clean up globals with `set -e` after use
- Use `path dirname`, `path join` builtins for path manipulation
- Use `test -e`, `test -L` for existence/symlink checks before operations
- Wrap compound `and`/`or` conditionals in `begin...end` blocks
- Use `"--"` before variable args in string builtins
- Use `command ls` in completions to bypass aliases
- Never use `exit` in sourced files — use `return`

### Markdown (Skill/Agent/Reference files)
- YAML frontmatter is required: `name` and `description` at minimum
- Agent frontmatter includes: `name`, `description`, `tools`, `model`, `maxTurns`
- Use tables for structured reference data
- Use code blocks with language tags for examples
- Keep SKILL.md under 200 lines — split details into `references/`

### Naming Conventions
- Agents: `CMD-expert.md` (e.g., `fzf-expert.md`)
- Completions: `CMD.fish` (e.g., `fzf.fish`)
- Cache: `CMD-collected.md` (e.g., `fzf-collected.md`)
- References: kebab-case descriptive names (e.g., `fish-completions.md`)

## Testing

No automated test suite. Validation is manual:
1. Run `fish install.fish --dry-run` to verify symlink targets
2. Run `/terminal:ingest-cmd <tool>` on a real CLI tool
3. Verify generated agent loads in Claude Code
4. Verify Fish completions work with `complete -C "<tool> "` in Fish shell
5. Check generated completions follow rules in `references/fish-completions.md`

### Key Validation Points
- Every subcommand has a `-d` description in completions
- File completion scoping (`-f`) is correctly applied
- Optional vs required arguments use correct flags (`-r` for required)
- One option per `complete` call (never combine `-s` and `-l` on same line)

## Security

- `.claude/settings.local.json` is gitignored (contains local permissions)
- Cache files are gitignored (may contain sensitive CLI output)
- Install script only creates symlinks — never modifies source files
- Uninstall script checks targets are symlinks before removing

## Configuration

No environment variables or external dependencies required beyond:
- **Claude Code** — the host environment
- **Fish shell** — for installation scripts and generated completions
- Bash commands available for the cli-collector subagent

## Available AI Subagents

| Agent | Model | Purpose |
|-------|-------|---------|
| `cli-collector` | Haiku | Background data collection — captures help text, man pages, subcommand docs for a CLI tool |

## Key References

| File | Lines | Content |
|------|-------|---------|
| `references/fish-completions.md` | 278 | Critical rules for writing Fish completions |
| `references/fish-completion-options.md` | 194 | Complete `complete` builtin reference |
| `references/fish-bash-differences.md` | 414 | Comprehensive bash vs Fish syntax guide |
| `references/fish-shell-converter.md` | 244 | Bash-to-Fish conversion workflow |
| `references/agent-template.md` | 47 | Template for generated expert agents |
| `references/collector-prompt.md` | 91 | Data collection protocol spec |
