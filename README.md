# react-native-ai-plugin

AI tools don't ship with React Native opinions. Left to their own devices, they'll fetch data in `useEffect`, navigate with string paths, and reach for the wrong animation API. This plugin fixes that.

It installs 14 skills, 7 specialist agents, and a set of hard rules into Claude Code, Cursor, Gemini CLI, and Codex. One command, all your tools.

## What it enforces

New Architecture only — no `NativeModules`, `requireNativeComponent`, or `UIManager`. RN 0.76+ minimum. Expo Router with typed routes (no string path concatenation). React Query for data fetching (no `useEffect`). Reanimated v3 and Gesture Handler v2. NativeWind v4 with `className` props. `bun` and `bunx` everywhere.

All of this goes into your AI tool's global config on install, so it applies to every project without you repeating yourself.

## Skills

14 skills loaded on demand:

`scaffold` `navigation` `ui` `data` `forms` `state` `animations` `auth` `eas` `notifications` `storage` `testing` `performance` `deslop`

## Agents

- **orchestrator** — coordinates feature work across the other agents
- **app-architect** — app structure, navigation shape, data flow
- **screen-developer** — screens, components, interactions
- **navigation-architect** — Expo Router, layouts, deep links
- **backend-integrator** — React Query hooks, API modules, Zod schemas
- **eas-engineer** — builds, submissions, OTA updates
- **code-reviewer** — catches what breaks the hard rules

## Supported tools

| Tool | Skills | Agents | Hard rules |
|---|---|---|---|
| Claude Code | ✓ | ✓ | ✓ |
| Cursor | — | — | — |
| Codex | ✓ | ✓ | ✓ |
| Gemini CLI | ✓ | ✓ | ✓ |

## Install

```bash
npx react-native-ai-plugin install
```

Or globally:

```bash
npm install -g react-native-ai-plugin
rn-ai install
```

Checks `~/.claude`, `~/.cursor`, `~/.codex`, and `~/.gemini` — installs into whichever tools you have.

## Commands

| Command | What it does |
|---|---|
| `rn-ai install` | Install into all detected AI tools |
| `rn-ai update` | Re-install with latest plugin files |
| `rn-ai status` | Show which tools are active |
| `rn-ai uninstall` | Remove from all tools |

## Requirements

- Node.js 18+
- At least one of: Claude Code, Cursor, Codex, Gemini CLI
