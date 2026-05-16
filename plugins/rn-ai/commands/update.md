---
name: update
description: Update the rn-claude plugin to the latest version
---

# /rn-update

Pulls the latest version of this plugin.

## What it does

1. `git pull` in the plugin directory
2. Reports what changed (new skills, updated agents, new commands)

## Usage

```
/rn-update
```

## Steps

```bash
bash .claude/plugins/rn-claude/scripts/update.sh
```
