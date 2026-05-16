# react-native-ai-plugin

AI-guided development for React Native apps with Expo. Works with Claude Code, Cursor, Gemini CLI, and Codex.

## Install

```bash
npx react-native-ai-plugin install
```

Or globally:

```bash
npm install -g react-native-ai-plugin
rn-ai install
```

The installer detects which AI tools you have installed (`~/.claude`, `~/.cursor`, `~/.codex`, `~/.gemini`) and sets up the plugin for each one automatically.

## Commands

| Command | Description |
|---|---|
| `rn-ai install` | Detect installed AI tools and install the plugin |
| `rn-ai update` | Re-install updated plugin files |
| `rn-ai status` | Show which tools have the plugin installed |
| `rn-ai uninstall` | Remove the plugin from all tools |

## What's included

**14 skills** loaded on demand — scaffold, navigation, ui, data, forms, state, animations, auth, eas, notifications, storage, testing, performance, deslop

**7 specialist agents** — orchestrator, app-architect, screen-developer, navigation-architect, backend-integrator, eas-engineer, code-reviewer

**Hard rules** enforced globally — New Architecture only, Expo Router typed routes, React Query, Reanimated v3, NativeWind v4, bun

## Supported tools

| Tool | Skills | Agents | Global rules |
|---|---|---|---|
| Claude Code | ✓ | ✓ | ✓ (CLAUDE.md) |
| Cursor | — | — | ✓ (.cursorrules) |
| Codex | ✓ | ✓ | ✓ (AGENTS.md) |
| Gemini CLI | ✓ | ✓ | ✓ (AGENTS.md) |

## Requirements

- Node.js >=18
- At least one of: Claude Code, Cursor, Codex, Gemini CLI
