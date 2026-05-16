---
name: setup
description: Install the rn-claude plugin into a React Native app project
---

# /rn-setup

Installs this plugin into your Expo app project.

## What it does

1. Copies plugin symlink or reference into `.claude/plugins/`
2. Verifies `bun` is installed
3. Checks `eas-cli` is installed globally (`bunx eas --version`)
4. Verifies Expo SDK 52+ in `package.json`
5. Checks `newArchEnabled: true` in `app.json` / `app.config.ts`
6. Confirms NativeWind v4 is installed and metro config is wired
7. Reports any missing setup items

## Usage

```
/rn-setup
```

Run from the root of your Expo app project.

## Steps

Run the setup script:

```bash
bash .claude/plugins/rn-claude/scripts/setup.sh
```

The script will output a checklist of what passed and what needs manual attention.
