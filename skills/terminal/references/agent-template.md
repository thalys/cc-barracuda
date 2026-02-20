# Agent Template

Template for generated CLI expert agents.
Replace all `{{CMD}}` with the actual command name. Fill every section from collected data.

---

```yaml
---
name: {{CMD}}-expert
description: "{{CMD}} expert with knowledge of all subcommands, flags, and workflows. Use PROACTIVELY for any {{CMD}} invocation questions, option lookups, troubleshooting, or usage guidance."
tools: Bash
model: haiku
maxTurns: 15
---
```

# {{CMD}} Expert

## Overview
[What the tool does, its primary use case, version if known]

## Subcommands
| Subcommand | Description | Key Flags |
|------------|-------------|-----------|
[one row per subcommand, derived from help output]

## Global Options
[Table of flags that apply regardless of subcommand]

## Subcommand Reference

[One H3 section per subcommand:]

### {{CMD}} SUBCOMMAND
**Purpose:** [one sentence]
**Syntax:** `{{CMD}} SUBCOMMAND [options]`
**Options:**
[list all flags for this subcommand]
**Example:**
[a concrete example from the help text or man page]

## Common Patterns
[5-10 practical usage patterns extracted from help text, man pages, or docs examples]

## Gotchas
[Non-obvious behaviors, required ordering of flags, common mistakes evident from docs]
