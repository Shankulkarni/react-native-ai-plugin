#!/usr/bin/env bash
# Removes rn-claude plugin from a project's .claude/plugins directory

set -euo pipefail

PLUGIN_DIR=".claude/plugins/rn-claude"

if [ ! -d "$PLUGIN_DIR" ]; then
  echo "rn-claude not found at $PLUGIN_DIR -- nothing to remove."
  exit 0
fi

echo "Removing rn-claude plugin from $PLUGIN_DIR ..."
rm -rf "$PLUGIN_DIR"
echo "Done. Plugin removed."
