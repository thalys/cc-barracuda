# Plugin Transformation Design

**Date:** 2026-02-23
**Status:** Approved

## Goal

Transform the terminal skill repository into a Claude Code plugin format for easy distribution, while keeping the symlink-based install.fish workflow for development.

## Approach

Plugin-first restructure: flatten agents/commands to root level (plugin convention), add `.claude-plugin/plugin.json` manifest, update install scripts and docs.

## Directory Structure (After)

```
terminal/
├── .claude-plugin/
│   └── plugin.json                    ← NEW: plugin manifest
├── skills/
│   └── terminal/
│       ├── SKILL.md
│       ├── .cache/
│       └── references/
├── agents/
│   └── cli-collector.md              ← MOVED from agents/terminal/
├── commands/
│   └── ingest-cmd.md                 ← MOVED from commands/terminal/
├── examples/
│   └── agents/fzf-expert.md
├── install.fish                       ← UPDATED paths
├── uninstall.fish                     ← UPDATED paths
├── AGENTS.md                          ← UPDATED structure docs
├── README.md                          ← UPDATED install instructions
├── .gitignore
└── LICENSE
```

## Changes

### New Files
- `.claude-plugin/plugin.json` — manifest with name, description, version, author, license, keywords

### Moved Files
- `agents/terminal/cli-collector.md` → `agents/cli-collector.md`
- `commands/terminal/ingest-cmd.md` → `commands/ingest-cmd.md`

### Updated Files
- `install.fish` — new source paths for agents/commands
- `uninstall.fish` — matching path updates
- `AGENTS.md` — updated project structure section
- `README.md` — add plugin install as primary method, keep fish install for dev

### Unchanged
- `skills/terminal/` — entire skill directory stays as-is
- `examples/` — stays as-is
- `.gitignore`, `LICENSE` — unchanged

## Plugin Manifest

```json
{
  "name": "terminal",
  "description": "CLI tool ingestion, Fish shell completions authoring, and bash-to-fish conversion.",
  "version": "1.0.0",
  "author": { "name": "Thalys" },
  "license": "MIT",
  "keywords": ["cli", "fish-shell", "completions", "terminal", "bash-to-fish"]
}
```

## Distribution

Deferred — plugin format is ready, distribution method (own marketplace, official marketplace, direct repo) to be decided later.
