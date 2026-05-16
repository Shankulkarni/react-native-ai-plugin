#!/usr/bin/env bash
set -euo pipefail

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

export HOME="$TMPDIR"
mkdir -p "$TMPDIR/.claude"

echo "=== smoke test: install ==="
node cli.js install

check_exists() {
  if [ -e "$1" ]; then
    echo "  ✓ $1"
  else
    echo "  ✗ MISSING: $1"
    exit 1
  fi
}

check_exists "$TMPDIR/.claude/plugins/rn-ai/skills/scaffold/SKILL.md"
check_exists "$TMPDIR/.claude/plugins/rn-ai/agents/orchestrator.md"
check_exists "$TMPDIR/.claude/plugins/rn-ai/commands/setup.md"
check_exists "$TMPDIR/.claude/plugins/rn-ai/plugin.json"
check_exists "$TMPDIR/.rn-ai-lock.json"

echo ""
echo "=== smoke test: status ==="
node cli.js status

echo ""
echo "=== smoke test: update ==="
node cli.js update

echo ""
echo "=== smoke test: uninstall ==="
node cli.js uninstall

if [ -d "$TMPDIR/.claude/plugins/rn-ai" ]; then
  echo "  ✗ Plugin dir not removed after uninstall"
  exit 1
fi
if [ -f "$TMPDIR/.rn-ai-lock.json" ]; then
  echo "  ✗ Lockfile not removed after uninstall"
  exit 1
fi
echo "  ✓ Cleanup verified"

echo ""
echo "All smoke tests passed."
