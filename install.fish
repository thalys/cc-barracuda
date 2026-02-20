#!/usr/bin/env fish

# Terminal Skill Installer for Claude Code
# Creates symlinks from this repo to ~/.claude/ directories

set -l script_dir (path dirname (status filename))
set -l claude_dir $HOME/.claude
set -g _terminal_dry_run false

# Parse arguments
for arg in $argv
    switch $arg
        case --dry-run -n
            set -g _terminal_dry_run true
        case --uninstall -u
            echo "Use uninstall.fish instead"
            set -e _terminal_dry_run
            return 1
        case --help -h
            echo "Usage: install.fish [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --dry-run, -n  Show what would be done without making changes"
            echo ""
            echo "Installs the terminal skill, agents, and commands to ~/.claude/"
            echo "by creating symlinks back to this repository."
            set -e _terminal_dry_run
            return 0
    end
end

function _link --argument-names src dst
    if test "$_terminal_dry_run" = true
        echo "  [dry-run] $src -> $dst"
        return 0
    end

    # Create parent directory
    mkdir -p (path dirname $dst)

    # Remove existing target (file or symlink)
    if test -e $dst; or test -L $dst
        rm -rf $dst
    end

    ln -s $src $dst
    echo "  $src -> $dst"
end

echo "Installing terminal skill..."
echo ""

# Skill
echo "Skill:"
_link $script_dir/skills/terminal $claude_dir/skills/terminal

# Agents
echo ""
echo "Agents:"
_link $script_dir/agents/terminal/cli-collector.md $claude_dir/agents/terminal/cli-collector.md

# Commands
echo ""
echo "Commands:"
_link $script_dir/commands/terminal/ingest-cmd.md $claude_dir/commands/terminal/ingest-cmd.md

echo ""
if test "$_terminal_dry_run" = true
    echo "Dry run complete. No changes made."
else
    echo "Installed. Restart Claude Code to pick up changes."
end

set -e _terminal_dry_run
