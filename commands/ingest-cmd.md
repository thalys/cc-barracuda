---
description: Ingest a CLI tool to generate a specialized Claude agent and Fish shell completions
allowed-tools: Bash(which:*), Bash(*:--help), Bash(*:-h), Bash(*:help), Bash(man:*), Bash(col:*), Bash(mkdir:*), Bash(fish:*), Bash(wc:*), Task, TaskOutput, Write, Read, Skill, WebSearch, WebFetch
argument-hint: "<command-name> [--docs]"
model: sonnet
---

# Ingest CLI Tool

Parse `$ARGUMENTS` to extract:
- `CMD` = first non-flag token
- `FETCH_DOCS` = true if `--docs` is present

Verify CMD exists:
```bash
which CMD 2>/dev/null
```

If not found, stop with: "`CMD` not found in PATH. Is it installed?"

Invoke the **terminal** skill (Skill tool) and follow its **Ingest Workflow** from Step 1 onward,
substituting CMD and FETCH_DOCS throughout.
