#!/usr/bin/env fish

# Terminal Skill Uninstaller for Claude Code
# Removes symlinks created by install.fish

set -l claude_dir $HOME/.claude
set -g _terminal_dry_run false

for arg in $argv
    switch $arg
        case --dry-run -n
            set -g _terminal_dry_run true
        case --help -h
            echo "Usage: uninstall.fish [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --dry-run, -n  Show what would be removed without making changes"
            set -e _terminal_dry_run
            return 0
    end
end

function _unlink --argument-names target
    if not test -L $target
        echo "  [skip] $target (not a symlink)"
        return 0
    end

    if test "$_terminal_dry_run" = true
        echo "  [dry-run] remove $target"
    else
        rm $target
        echo "  removed $target"
    end
end

echo "Uninstalling terminal skill..."
echo ""

# Commands
echo "Commands:"
_unlink $claude_dir/commands/terminal/ingest-cmd.md

# Agents
echo ""
echo "Agents:"
_unlink $claude_dir/agents/terminal/cli-collector.md

# Skill
echo ""
echo "Skill:"
_unlink $claude_dir/skills/terminal

# Clean up empty directories
echo ""
echo "Cleaning empty directories:"
for dir in $claude_dir/commands/terminal $claude_dir/agents/terminal
    if test -d $dir; and test (count $dir/*) -eq 0 2>/dev/null
        if test "$_terminal_dry_run" = true
            echo "  [dry-run] rmdir $dir"
        else
            rmdir $dir 2>/dev/null
            and echo "  removed $dir"
        end
    end
end

echo ""
if test "$_terminal_dry_run" = true
    echo "Dry run complete. No changes made."
else
    echo "Uninstalled. Restart Claude Code to pick up changes."
end

set -e _terminal_dry_run
