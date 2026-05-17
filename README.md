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
  <a href="https://jestjs.io"><img src="https://img.shields.io/badge/Jest-C21325?style=flat-square&logo=jest&logoColor=white" alt="Jest"></a>
  <a href="LICENSE"><img src="https://img.shields.io/npm/l/react-native-ai-plugin?style=flat-square" alt="MIT"></a>
</p>

---

## Install

```bash
# One-time, no install needed
npx react-native-ai-plugin install

# Or globally
npm install -g react-native-ai-plugin
rn-ai install
```

Checks `~/.claude`, `~/.cursor`, `~/.codex`, and `~/.gemini` — installs into whichever tools you have.

---

## Why this plugin exists

AI tools don't ship with React Native opinions. Left to their own devices, they'll fetch data in `useEffect`, navigate with string paths, and reach for the wrong animation API.

- Using `useEffect` for data fetching. React Query is the right answer — this enforces it.
- String-based navigation with `router.push('/home')`. Expo Router typed routes block that.
- Reanimated v2 patterns, Animated API from RN core. The plugin locks to Reanimated v3.
- `NativeModules` and `requireNativeComponent` on every new project. New Architecture only.
- Setting these rules once per tool, then forgetting them next project. One install covers all tools, all projects.
- `npm` and `npx` everywhere. `bun` and `bunx` always.

---

## ⚡ Commands

| Command | What it does |
|---|---|
| `rn-ai install` | Detect installed AI tools and install the plugin into each |
| `rn-ai update` | Re-install with the latest plugin files |
| `rn-ai status` | Show which tools have the plugin active |
| `rn-ai uninstall` | Remove the plugin from all tools |

---

## 🧠 Skills

14 skills loaded on demand. Only the relevant skill enters context — the rest cost 0 tokens.

| | Skill | What it covers |
|---|---|---|
| 🏗️ | `scaffold` | New library or project setup end-to-end |
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

## 🤖 Agents

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

## 🔌 Supported Tools

| Tool | Skills | Agents | Hard rules | Config location |
|---|---|---|---|---|
| Claude Code | ✓ | ✓ | ✓ | `~/.claude/CLAUDE.md` |
| Cursor | — | — | ✓ | `.cursorrules` |
| Codex | ✓ | ✓ | ✓ | `~/.codex/AGENTS.md` |
| Gemini CLI | ✓ | ✓ | ✓ | `~/.gemini/AGENTS.md` |

---

## 🛡️ Hard Rules

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
