<p align="center">
  <h1 align="center">react-native-ai-plugin</h1>
  <p align="center">
    <strong>AI-guided React Native development for Claude Code, Cursor, Codex, and Gemini CLI.</strong>
  </p>
  <p align="center">
    <code>14 skills</code> · <code>7 agents</code> · <code>4 AI tools</code> · <code>New Architecture</code>
  </p>
</p>

<p align="center">
  <a href="https://www.npmjs.com/package/react-native-ai-plugin"><img src="https://img.shields.io/npm/v/react-native-ai-plugin?style=flat-square" alt="npm"></a>
  <a href="https://reactnative.dev"><img src="https://img.shields.io/badge/React_Native-61DAFB?style=flat-square&logo=react&logoColor=black" alt="React Native"></a>
  <a href="https://www.typescriptlang.org"><img src="https://img.shields.io/badge/TypeScript-3178C6?style=flat-square&logo=typescript&logoColor=white" alt="TypeScript"></a>
  <a href="https://expo.dev"><img src="https://img.shields.io/badge/Expo-000020?style=flat-square&logo=expo&logoColor=white" alt="Expo"></a>
  <a href="https://docs.swmansion.com/react-native-reanimated"><img src="https://img.shields.io/badge/Reanimated_v3-6B52AE?style=flat-square&logo=react&logoColor=white" alt="Reanimated v3"></a>
  <a href="https://docs.swmansion.com/react-native-gesture-handler"><img src="https://img.shields.io/badge/Gesture_Handler_v2-6B52AE?style=flat-square&logo=react&logoColor=white" alt="Gesture Handler v2"></a>
  <a href="https://bun.sh"><img src="https://img.shields.io/badge/Bun-000000?style=flat-square&logo=bun&logoColor=white" alt="Bun"></a>
  <a href="LICENSE"><img src="https://img.shields.io/npm/l/react-native-ai-plugin?style=flat-square" alt="MIT"></a>
</p>

---

## What this does

Installs React Native skills, agents, and hard rules into your AI coding tool. Once installed, your AI assistant knows the right stack (Expo Router, React Query, NativeWind, Reanimated v3) and refuses legacy patterns — on every project, without repeating yourself.

---

## Setup (one-time)

**Step 1 — Install the plugin**

```bash
npx react-native-ai-plugin install
```

This scans for `~/.claude`, `~/.cursor`, `~/.codex`, `~/.gemini` and installs into whichever tools you have. You'll see a checkmark for each one that succeeded.

> **Note:** If you want the `rn-ai` command available globally (for `rn-ai update`, `rn-ai status`, `rn-ai uninstall`), install it globally instead:
> ```bash
> npm install -g react-native-ai-plugin
> rn-ai install
> ```
> The `npx` approach above is enough for a one-time install.

**Step 2 — Scaffold a new app**

Open Claude Code in an empty directory and say:

```
Scaffold a new Expo app
```

Claude will ask for your app name, bundle ID, auth type, and tab structure — then generate the full project: dependencies, config files, folder structure, EAS setup, and linting.

That's it. The plugin runs silently from here. Every time you start a task, Claude loads the relevant skill automatically.

---

## Using skills in Claude Code

Skills are loaded on demand — only the relevant one enters context, the rest cost zero tokens.

Ask Claude naturally and it will pick the right skill:

| What you say | Skill loaded |
|---|---|
| "Scaffold a new Expo app" | `scaffold` |
| "Add a login screen with email/password" | `auth` |
| "Set up navigation with tabs and a stack" | `navigation` |
| "Build a form with validation" | `forms` |
| "Add a swipe gesture to dismiss" | `animations` |
| "Wire up the API to this screen" | `data` |
| "Set up EAS Build for TestFlight" | `eas` |
| "Store the user token securely" | `storage` |
| "Write tests for this component" | `testing` |
| "Scan this code for bad patterns" | `deslop` |

---

## Commands

| Command | What it does |
|---|---|
| `rn-ai install` | Detect installed AI tools and install the plugin into each |
| `rn-ai update` | Re-install with the latest plugin files |
| `rn-ai status` | Show which tools have the plugin active |
| `rn-ai uninstall` | Remove the plugin from all tools |

> These require a global install (`npm install -g react-native-ai-plugin`). The `npx` one-liner only runs install — it doesn't persist the `rn-ai` binary.

---

## Skills

14 skills loaded on demand. Only the relevant skill enters context — the rest cost 0 tokens.

| | Skill | What it covers |
|---|---|---|
| 🏗️ | `scaffold` | New app setup end-to-end |
| 🗺️ | `navigation` | Expo Router routes, layouts, typed paths, deep links |
| 🎨 | `ui` | NativeWind v4, `className` props, shadcn-style components |
| 📡 | `data` | React Query hooks, API modules, Zod schemas |
| 📝 | `forms` | react-hook-form, field validation, form state |
| 🗂️ | `state` | Zustand, global and local UI state |
| ✨ | `animations` | Reanimated v3 worklets, GestureDetector, GPU-only properties |
| 🔑 | `auth` | Supabase Auth, session handling, protected routes |
| 🚀 | `eas` | EAS Build profiles, store submissions, OTA updates |
| 🔔 | `notifications` | Expo Notifications, push token setup |
| 💾 | `storage` | MMKV, Expo FileSystem |
| 🧪 | `testing` | Jest, React Native Testing Library, Maestro E2E |
| ⚡ | `performance` | FlatList, bundle size, FPS targets, memoization |
| 🧹 | `deslop` | AI slop detection, legacy bridge violations, code quality scan |

---

## Agents

**7 specialists. Work solo or as a coordinated team.**

```
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║  📱 APP                      🔗 BACKEND                              ║
║  ─────────                   ────────                                ║
║  App Architect               Backend Integrator                      ║
║  Screen Developer                                                    ║
║  Navigation Architect        🎛️  ORCHESTRATION                       ║
║                              ────────────────                        ║
║  ✅ QUALITY                  Orchestrator                            ║
║  ────────                    (full feature lifecycle)                ║
║  Code Reviewer                                                       ║
║  EAS Engineer                                                        ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

| | Agent | Role |
|---|---|---|
| 🎯 | `orchestrator` | Coordinates feature work across the other agents |
| 🏛️ | `app-architect` | App structure, navigation shape, data flow decisions |
| 📱 | `screen-developer` | Screens, components, interactions |
| 🗺️ | `navigation-architect` | Expo Router layouts, tab stacks, deep link config |
| 🔗 | `backend-integrator` | React Query hooks, API modules, Zod validation schemas |
| 🚀 | `eas-engineer` | EAS Build profiles, store submissions, OTA strategy |
| ✅ | `code-reviewer` | Catches New Architecture violations, bad patterns, skipped rules |

---

## Supported Tools

| Tool | Skills | Agents | Hard rules | Config location |
|---|---|---|---|---|
| Claude Code | ✓ | ✓ | ✓ | `~/.claude/CLAUDE.md` |
| Cursor | — | — | ✓ | `.cursorrules` |
| Codex | ✓ | ✓ | ✓ | `~/.codex/AGENTS.md` |
| Gemini CLI | ✓ | ✓ | ✓ | `~/.gemini/AGENTS.md` |

---

## Hard Rules

The plugin enforces these on every project, without you having to say them:

```
  ┌─────────────────────────────────────────────┐
  │  Architecture                               │
  │  New Architecture only — RN 0.76+           │
  │  No NativeModules, requireNativeComponent   │
  │  No UIManager                               │
  ├─────────────────────────────────────────────┤
  │  Navigation                                 │
  │  Expo Router typed routes only              │
  │  No string path concatenation               │
  ├─────────────────────────────────────────────┤
  │  Data Fetching                              │
  │  React Query — no useEffect for data        │
  ├─────────────────────────────────────────────┤
  │  Animations & Gestures                      │
  │  Reanimated v3 — no RN Animated API         │
  │  Gesture Handler v2 — no PanResponder       │
  ├─────────────────────────────────────────────┤
  │  Package Manager                            │
  │  bun always — bunx not npx                  │
  ├─────────────────────────────────────────────┤
  │  TypeScript                                 │
  │  Strict mode, type not interface            │
  │  No any, no as                              │
  └─────────────────────────────────────────────┘
```

---

## Requirements

- Node.js 18+
- At least one of: Claude Code, Cursor, Codex, Gemini CLI
