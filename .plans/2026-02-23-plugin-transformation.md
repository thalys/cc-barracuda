# Plugin Transformation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the terminal skill repo into a Claude Code plugin while keeping install.fish for dev use.

**Architecture:** Add `.claude-plugin/plugin.json` manifest, flatten agents/commands from `*/terminal/` subdirectories to root-level `*/`, update install scripts and docs.

**Tech Stack:** Fish shell, Markdown, JSON

---

### Task 1: Create plugin manifest

**Files:**
- Create: `.claude-plugin/plugin.json`

**Step 1: Create the manifest file**

```json
{
  "name": "terminal",
  "description": "CLI tool ingestion, Fish shell completions authoring, and bash-to-fish conversion. Turns any CLI tool into a specialized AI agent with Fish shell completions.",
  "version": "1.0.0",
  "author": {
    "name": "Thalys"
  },
  "repository": "https://github.com/thalys/claude-terminal-skill",
  "license": "MIT",
  "keywords": ["cli", "fish-shell", "completions", "terminal", "bash-to-fish"]
}
```

**Step 2: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "feat: add plugin manifest"
```

---

### Task 2: Flatten agents and commands directories

**Files:**
- Move: `agents/terminal/cli-collector.md` → `agents/cli-collector.md`
- Move: `commands/terminal/ingest-cmd.md` → `commands/ingest-cmd.md`
- Remove: empty `agents/terminal/` and `commands/terminal/` directories

**Step 1: Move agent file**

```bash
mv agents/terminal/cli-collector.md agents/cli-collector.md
rmdir agents/terminal
```

**Step 2: Move command file**

```bash
mv commands/terminal/ingest-cmd.md commands/ingest-cmd.md
rmdir commands/terminal
```

**Step 3: Commit**

```bash
git add -A agents/ commands/
git commit -m "refactor: flatten agents and commands to plugin root layout"
```

---

### Task 3: Update install.fish

**Files:**
- Modify: `install.fish`

**Step 1: Update source paths**

Change line 60:
```fish
# Before:
_link $script_dir/agents/terminal/cli-collector.md $claude_dir/agents/terminal/cli-collector.md
# After:
_link $script_dir/agents/cli-collector.md $claude_dir/agents/terminal/cli-collector.md
```

Change line 65:
```fish
# Before:
_link $script_dir/commands/terminal/ingest-cmd.md $claude_dir/commands/terminal/ingest-cmd.md
# After:
_link $script_dir/commands/ingest-cmd.md $claude_dir/commands/terminal/ingest-cmd.md
```

Note: destination paths stay the same — Claude Code expects agents/commands at `~/.claude/agents/terminal/` and `~/.claude/commands/terminal/` for the `terminal` namespace.

**Step 2: Verify with dry run**

```bash
fish install.fish --dry-run
```

Expected output shows updated source paths but same destination paths.

**Step 3: Commit**

```bash
git add install.fish
git commit -m "fix: update install.fish source paths for flattened layout"
```

---

### Task 4: Update uninstall.fish

**Files:**
- Modify: `uninstall.fish`

No changes needed — uninstall.fish only references destination paths (`$claude_dir/...`), which haven't changed.

**Step 1: Verify with dry run**

```bash
fish uninstall.fish --dry-run
```

Expected: same output as before (targets `~/.claude/` paths).

---

### Task 5: Update AGENTS.md

**Files:**
- Modify: `AGENTS.md`

**Step 1: Update project structure section**

Replace the project structure block to reflect flattened layout:

```
skills/terminal/          → Main skill (SKILL.md + references/)
agents/                   → cli-collector subagent
commands/                 → /terminal:ingest-cmd slash command
examples/agents/          → Sample generated output (fzf-expert.md)
.claude-plugin/           → Plugin manifest
install.fish              → Symlink-based installer (dev workflow)
uninstall.fish            → Symlink remover
```

Update any other references to `agents/terminal/` or `commands/terminal/` paths.

**Step 2: Commit**

```bash
git add AGENTS.md
git commit -m "docs: update AGENTS.md for plugin layout"
```

---

### Task 6: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Add plugin install section**

After the Prerequisites section, add a "Plugin Install" section as the primary method:

```markdown
### Plugin Install

If you have the terminal plugin marketplace registered:

```
/plugin install terminal
```

Or install directly from the repository:

```
/plugin install github:YOUR_USERNAME/terminal-skill
```
```

**Step 2: Rename existing install to "Development Install (Fish)"**

Change "Quick Install (Fish)" heading to "Development Install" and add a note that this is for contributors who clone the repo.

**Step 3: Update project structure**

Replace the project structure tree to show flattened layout with `.claude-plugin/` directory.

**Step 4: Update Customization section paths**

Change `agents/terminal/cli-collector.md` → `agents/cli-collector.md` in the Collector Behavior section.

**Step 5: Commit**

```bash
git add README.md
git commit -m "docs: update README for plugin distribution"
```

---

### Task 7: Final verification

**Step 1: Run install dry run**

```bash
fish install.fish --dry-run
```

Verify source paths point to flattened locations, destinations unchanged.

**Step 2: Run uninstall dry run**

```bash
fish uninstall.fish --dry-run
```

Verify targets unchanged.

**Step 3: Check git status is clean**

```bash
git status
```

No untracked or modified files remaining.
