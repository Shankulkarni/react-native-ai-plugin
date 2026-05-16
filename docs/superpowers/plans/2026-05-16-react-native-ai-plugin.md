# React Native AI Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename RN-Claude to `react-native-ai-plugin` and package it as an npm CLI (`rn-ai`) that installs into Claude Code, Cursor, Gemini CLI, and Codex.

**Architecture:** Single `cli.js` entry point dispatches to `src/` modules. `src/detect.js` identifies which AI tools are installed by checking known config dirs. `src/install.js` copies `plugins/rn-ai/` content into each tool's plugin dir and writes tool-specific manifests. A lockfile at `~/.rn-ai-lock.json` tracks what was installed.

**Tech Stack:** Node.js >=18, ESM (`type: module`), built-in `fs`/`os`/`path`/`crypto` only — no external dependencies.

---

## File Map

**Create:**
- `package.json` — npm package config with `bin: { "rn-ai": "./cli.js" }`
- `cli.js` — entry point, routes `install | uninstall | update | status`
- `src/detect.js` — checks `~/.claude`, `~/.cursor`, `~/.codex`, `~/.gemini` for installed tools
- `src/install.js` — copies plugin files, writes manifests, appends CLAUDE.md rules
- `src/uninstall.js` — removes plugin dirs, strips CLAUDE.md block, deletes lockfile
- `src/update.js` — reads lockfile, re-runs install for previously installed tools
- `src/status.js` — reads lockfile, prints tool table and update availability
- `manifests/claude-plugin.json` — Claude Code plugin manifest
- `manifests/codex-plugin.json` — Codex plugin manifest
- `manifests/openai.yaml` — Codex UI metadata for agents
- `plugins/rn-ai/AGENTS.md` — Codex/Gemini rules (same content as CLAUDE.md)
- `scripts/smoke-test.sh` — integration smoke test
- `.github/workflows/ci.yml` — CI pipeline

**Rename:**
- `plugins/rn-claude/` → `plugins/rn-ai/`

**Modify:**
- `plugins/rn-ai/CLAUDE.md` — update header from "RN-Claude" to "React Native AI Plugin"
- `plugins/rn-ai/commands/*.md` — replace `rn-claude` path refs with `rn-ai`
- `plugins/rn-ai/README.md` — update name and install instructions
- `README.md` — rewrite for npm package audience

**Delete:**
- `.claude-plugin/` — replaced by `manifests/claude-plugin.json`

---

## Task 1: Rename plugin directory and delete marketplace manifest

**Files:**
- Rename: `plugins/rn-claude/` → `plugins/rn-ai/`
- Delete: `.claude-plugin/`

- [ ] **Step 1: Rename the plugin directory**

```bash
git mv plugins/rn-claude plugins/rn-ai
```

- [ ] **Step 2: Delete the marketplace manifest directory**

```bash
git rm -r .claude-plugin/
```

- [ ] **Step 3: Verify the rename**

```bash
ls plugins/rn-ai/skills/ | head -5
```

Expected output: list of skill dirs (animations, auth, data, ...)

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor: rename rn-claude plugin dir to rn-ai, remove marketplace manifest"
```

---

## Task 2: Update plugin content references

**Files:**
- Modify: `plugins/rn-ai/CLAUDE.md`
- Modify: `plugins/rn-ai/commands/*.md`
- Modify: `plugins/rn-ai/README.md`

- [ ] **Step 1: Replace all `rn-claude` references in command files**

```bash
find plugins/rn-ai/commands -name "*.md" -exec \
  sed -i '' 's|rn-claude|rn-ai|g' {} \;
```

- [ ] **Step 2: Verify command files updated**

```bash
grep -r "rn-claude" plugins/rn-ai/commands/
```

Expected output: no matches.

- [ ] **Step 3: Update CLAUDE.md header**

Open `plugins/rn-ai/CLAUDE.md` and change line 1 from:
```
# RN-Claude -- Global Rules
```
to:
```
# React Native AI Plugin -- Global Rules
```

- [ ] **Step 4: Update plugins/rn-ai/README.md**

Replace the full content of `plugins/rn-ai/README.md` with:

```markdown
# React Native AI Plugin

AI-guided development for React Native apps with Expo. Install via npm:

\`\`\`bash
npx react-native-ai-plugin install
\`\`\`

Or with the CLI after global install:

\`\`\`bash
npm install -g react-native-ai-plugin
rn-ai install
\`\`\`

See [npmjs.com/package/react-native-ai-plugin](https://npmjs.com/package/react-native-ai-plugin) for full documentation.
```

- [ ] **Step 5: Commit**

```bash
git add plugins/rn-ai/
git commit -m "refactor: update plugin content refs from rn-claude to rn-ai"
```

---

## Task 3: Create AGENTS.md for Codex/Gemini

**Files:**
- Create: `plugins/rn-ai/AGENTS.md`

- [ ] **Step 1: Create AGENTS.md with the same content as CLAUDE.md**

Copy `plugins/rn-ai/CLAUDE.md` to `plugins/rn-ai/AGENTS.md`:

```bash
cp plugins/rn-ai/CLAUDE.md plugins/rn-ai/AGENTS.md
```

- [ ] **Step 2: Verify**

```bash
diff plugins/rn-ai/CLAUDE.md plugins/rn-ai/AGENTS.md
```

Expected output: no diff.

- [ ] **Step 3: Commit**

```bash
git add plugins/rn-ai/AGENTS.md
git commit -m "feat: add AGENTS.md for Codex and Gemini CLI support"
```

---

## Task 4: Create manifests/

**Files:**
- Create: `manifests/claude-plugin.json`
- Create: `manifests/codex-plugin.json`
- Create: `manifests/openai.yaml`

- [ ] **Step 1: Create manifests directory and claude-plugin.json**

```bash
mkdir -p manifests
```

Create `manifests/claude-plugin.json`:

```json
{
  "name": "rn-ai",
  "description": "React Native AI Plugin — AI-guided development for React Native apps with Expo",
  "version": "1.0.0",
  "author": {
    "name": "Utilities Studio"
  },
  "skills": "./skills/",
  "commands": "./commands/",
  "agents": [
    "./agents/orchestrator.md",
    "./agents/app-architect.md",
    "./agents/screen-developer.md",
    "./agents/navigation-architect.md",
    "./agents/backend-integrator.md",
    "./agents/eas-engineer.md",
    "./agents/code-reviewer.md"
  ]
}
```

- [ ] **Step 2: Create manifests/codex-plugin.json**

```json
{
  "name": "rn-ai",
  "description": "React Native AI Plugin — AI-guided development for React Native apps with Expo",
  "version": "1.0.0",
  "skills": "./skills/",
  "agents": [
    "./agents/orchestrator.md",
    "./agents/app-architect.md",
    "./agents/screen-developer.md",
    "./agents/navigation-architect.md",
    "./agents/backend-integrator.md",
    "./agents/eas-engineer.md",
    "./agents/code-reviewer.md"
  ]
}
```

- [ ] **Step 3: Create manifests/openai.yaml**

```yaml
agents:
  - name: orchestrator
    display_name: RN Orchestrator
    short_description: Coordinates React Native feature development end-to-end
  - name: app-architect
    display_name: App Architect
    short_description: Designs app structure, navigation, and data flow
  - name: screen-developer
    display_name: Screen Developer
    short_description: Implements screens, components, and UI interactions
  - name: navigation-architect
    display_name: Navigation Architect
    short_description: Designs and implements Expo Router navigation
  - name: backend-integrator
    display_name: Backend Integrator
    short_description: Integrates APIs, React Query hooks, and data layers
  - name: eas-engineer
    display_name: EAS Engineer
    short_description: Manages EAS builds, submissions, and OTA updates
  - name: code-reviewer
    display_name: Code Reviewer
    short_description: Reviews code for RN best practices and anti-patterns
```

- [ ] **Step 4: Commit**

```bash
git add manifests/
git commit -m "feat: add tool-specific manifests for Claude, Codex, and Gemini"
```

---

## Task 5: Initialize package.json

**Files:**
- Create: `package.json`

- [ ] **Step 1: Create package.json**

```json
{
  "name": "react-native-ai-plugin",
  "version": "0.1.0",
  "description": "AI-guided development for React Native apps with Expo. Works with Claude Code, Cursor, Gemini CLI, and Codex.",
  "type": "module",
  "bin": {
    "rn-ai": "./cli.js"
  },
  "files": [
    "cli.js",
    "plugins/",
    "manifests/",
    "src/"
  ],
  "engines": {
    "node": ">=18"
  },
  "keywords": [
    "react-native",
    "expo",
    "ai",
    "claude",
    "cursor",
    "gemini",
    "codex",
    "plugin"
  ],
  "author": "Utilities Studio",
  "license": "MIT"
}
```

- [ ] **Step 2: Verify it parses**

```bash
node -e "console.log(JSON.parse(require('fs').readFileSync('package.json','utf8')).name)"
```

Expected output: `react-native-ai-plugin`

- [ ] **Step 3: Commit**

```bash
git add package.json
git commit -m "feat: initialize npm package.json for react-native-ai-plugin"
```

---

## Task 6: Create src/detect.js

**Files:**
- Create: `src/detect.js`

- [ ] **Step 1: Create src directory and detect.js**

```bash
mkdir -p src
```

Create `src/detect.js`:

```js
import { existsSync } from 'fs'
import { homedir } from 'os'
import { join } from 'path'

const HOME = homedir()

export const TOOLS = {
  claude: {
    name: 'Claude Code',
    configDir: join(HOME, '.claude'),
    pluginDir: join(HOME, '.claude', 'plugins', 'rn-ai'),
    manifestFile: 'plugin.json',
    manifestSource: 'claude-plugin.json',
  },
  cursor: {
    name: 'Cursor',
    configDir: join(HOME, '.cursor'),
    pluginDir: join(HOME, '.cursor', 'rules', 'rn-ai'),
    manifestFile: null,
    manifestSource: null,
  },
  codex: {
    name: 'Codex',
    configDir: join(HOME, '.codex'),
    pluginDir: join(HOME, '.codex', 'plugins', 'rn-ai'),
    manifestFile: 'plugin.json',
    manifestSource: 'codex-plugin.json',
  },
  gemini: {
    name: 'Gemini CLI',
    configDir: join(HOME, '.gemini'),
    pluginDir: join(HOME, '.gemini', 'plugins', 'rn-ai'),
    manifestFile: null,
    manifestSource: null,
  },
}

export function detectInstalledTools() {
  return Object.entries(TOOLS)
    .filter(([, tool]) => existsSync(tool.configDir))
    .map(([id]) => id)
}
```

- [ ] **Step 2: Verify it loads without errors**

```bash
node -e "import('./src/detect.js').then(m => console.log(Object.keys(m.TOOLS)))"
```

Expected output: `[ 'claude', 'cursor', 'codex', 'gemini' ]`

- [ ] **Step 3: Commit**

```bash
git add src/detect.js
git commit -m "feat: add tool detection logic"
```

---

## Task 7: Create src/install.js

**Files:**
- Create: `src/install.js`

- [ ] **Step 1: Create src/install.js**

```js
import { cpSync, mkdirSync, existsSync, readFileSync, writeFileSync } from 'fs'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'
import { homedir } from 'os'
import { TOOLS } from './detect.js'

const __dirname = dirname(fileURLToPath(import.meta.url))
const PKG_ROOT = join(__dirname, '..')
const PLUGIN_SRC = join(PKG_ROOT, 'plugins', 'rn-ai')
const MANIFESTS_SRC = join(PKG_ROOT, 'manifests')
const HOME = homedir()
export const LOCKFILE = join(HOME, '.rn-ai-lock.json')

function pkgVersion() {
  return JSON.parse(readFileSync(join(PKG_ROOT, 'package.json'), 'utf8')).version
}

export function install(tools) {
  const results = []

  for (const toolId of tools) {
    const tool = TOOLS[toolId]
    try {
      mkdirSync(tool.pluginDir, { recursive: true })
      cpSync(PLUGIN_SRC, tool.pluginDir, { recursive: true })

      if (tool.manifestSource) {
        cpSync(
          join(MANIFESTS_SRC, tool.manifestSource),
          join(tool.pluginDir, tool.manifestFile),
        )
      }

      if (toolId === 'claude') appendClaudeRules()
      if (toolId === 'codex' || toolId === 'gemini') writeAgentsMd(tool)

      results.push({ tool: toolId, success: true })
    } catch (err) {
      results.push({ tool: toolId, success: false, error: err.message })
    }
  }

  const installed = results.filter(r => r.success).map(r => r.tool)
  writeFileSync(LOCKFILE, JSON.stringify({
    version: pkgVersion(),
    installedAt: new Date().toISOString(),
    tools: installed,
  }, null, 2))

  return results
}

function appendClaudeRules() {
  const claudeMdPath = join(HOME, '.claude', 'CLAUDE.md')
  const rules = readFileSync(join(PLUGIN_SRC, 'CLAUDE.md'), 'utf8')
  const FENCE = '# --- rn-ai managed block ---'

  if (existsSync(claudeMdPath)) {
    const existing = readFileSync(claudeMdPath, 'utf8')
    if (existing.includes(FENCE)) return
    writeFileSync(claudeMdPath, `${existing}\n\n${FENCE}\n${rules}\n${FENCE}\n`)
  } else {
    writeFileSync(claudeMdPath, `${FENCE}\n${rules}\n${FENCE}\n`)
  }
}

function writeAgentsMd(tool) {
  const agentsMd = readFileSync(join(PLUGIN_SRC, 'AGENTS.md'), 'utf8')
  writeFileSync(join(tool.configDir, 'rn-ai-AGENTS.md'), agentsMd)
}
```

- [ ] **Step 2: Verify it loads without errors**

```bash
node -e "import('./src/install.js').then(m => console.log(typeof m.install))"
```

Expected output: `function`

- [ ] **Step 3: Commit**

```bash
git add src/install.js
git commit -m "feat: add install logic — file copy and manifest writing"
```

---

## Task 8: Create src/uninstall.js

**Files:**
- Create: `src/uninstall.js`

- [ ] **Step 1: Create src/uninstall.js**

```js
import { rmSync, existsSync, readFileSync, writeFileSync } from 'fs'
import { join } from 'path'
import { homedir } from 'os'
import { TOOLS } from './detect.js'
import { LOCKFILE } from './install.js'

const HOME = homedir()
const FENCE = '# --- rn-ai managed block ---'

export function uninstall() {
  if (!existsSync(LOCKFILE)) {
    console.log('rn-ai is not installed.')
    return null
  }

  const { tools } = JSON.parse(readFileSync(LOCKFILE, 'utf8'))
  const results = []

  for (const toolId of tools) {
    const tool = TOOLS[toolId]
    try {
      if (existsSync(tool.pluginDir)) {
        rmSync(tool.pluginDir, { recursive: true, force: true })
      }
      if (toolId === 'claude') removeClaudeRulesBlock()
      if (toolId === 'codex' || toolId === 'gemini') {
        const agentsMdPath = join(tool.configDir, 'rn-ai-AGENTS.md')
        if (existsSync(agentsMdPath)) rmSync(agentsMdPath)
      }
      results.push({ tool: toolId, success: true })
    } catch (err) {
      results.push({ tool: toolId, success: false, error: err.message })
    }
  }

  rmSync(LOCKFILE, { force: true })
  return results
}

function removeClaudeRulesBlock() {
  const claudeMdPath = join(HOME, '.claude', 'CLAUDE.md')
  if (!existsSync(claudeMdPath)) return

  const content = readFileSync(claudeMdPath, 'utf8')
  const start = content.indexOf(`\n\n${FENCE}`)
  const end = content.lastIndexOf(FENCE)

  if (start === -1 || end === -1 || start === end) return

  const cleaned = content.slice(0, start) + content.slice(end + FENCE.length + 1)
  writeFileSync(claudeMdPath, cleaned)
}
```

- [ ] **Step 2: Verify it loads without errors**

```bash
node -e "import('./src/uninstall.js').then(m => console.log(typeof m.uninstall))"
```

Expected output: `function`

- [ ] **Step 3: Commit**

```bash
git add src/uninstall.js
git commit -m "feat: add uninstall logic — removes plugin dirs and CLAUDE.md block"
```

---

## Task 9: Create src/update.js

**Files:**
- Create: `src/update.js`

- [ ] **Step 1: Create src/update.js**

```js
import { existsSync, readFileSync } from 'fs'
import { install, LOCKFILE } from './install.js'

export function update() {
  if (!existsSync(LOCKFILE)) {
    console.log('rn-ai is not installed. Run: rn-ai install')
    return null
  }

  const { tools } = JSON.parse(readFileSync(LOCKFILE, 'utf8'))
  return install(tools)
}
```

- [ ] **Step 2: Verify it loads without errors**

```bash
node -e "import('./src/update.js').then(m => console.log(typeof m.update))"
```

Expected output: `function`

- [ ] **Step 3: Commit**

```bash
git add src/update.js
git commit -m "feat: add update logic — re-installs for previously installed tools"
```

---

## Task 10: Create src/status.js

**Files:**
- Create: `src/status.js`

- [ ] **Step 1: Create src/status.js**

```js
import { existsSync, readFileSync } from 'fs'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'
import { TOOLS } from './detect.js'
import { LOCKFILE } from './install.js'

const __dirname = dirname(fileURLToPath(import.meta.url))
const PKG_VERSION = JSON.parse(
  readFileSync(join(__dirname, '..', 'package.json'), 'utf8')
).version

export function status() {
  if (!existsSync(LOCKFILE)) {
    console.log('rn-ai is not installed. Run: rn-ai install')
    return
  }

  const lock = JSON.parse(readFileSync(LOCKFILE, 'utf8'))
  const updateAvailable = lock.version !== PKG_VERSION

  console.log(
    `rn-ai v${lock.version}` +
    (updateAvailable ? ` → v${PKG_VERSION} available (run: rn-ai update)` : ' (up to date)')
  )
  console.log(`Installed: ${new Date(lock.installedAt).toLocaleDateString()}`)
  console.log()

  for (const [id, tool] of Object.entries(TOOLS)) {
    const isInstalled = lock.tools.includes(id)
    const isPresent = isInstalled && existsSync(tool.pluginDir)
    const state = !isInstalled ? '—  not installed' : isPresent ? '✓  active' : '✗  missing (reinstall with: rn-ai update)'
    console.log(`  ${tool.name.padEnd(14)} ${state}`)
  }
}
```

- [ ] **Step 2: Verify it loads without errors**

```bash
node -e "import('./src/status.js').then(m => console.log(typeof m.status))"
```

Expected output: `function`

- [ ] **Step 3: Commit**

```bash
git add src/status.js
git commit -m "feat: add status reporting — lockfile diff and tool install state"
```

---

## Task 11: Create cli.js entry point

**Files:**
- Create: `cli.js`

- [ ] **Step 1: Create cli.js**

```js
#!/usr/bin/env node
import { detectInstalledTools } from './src/detect.js'
import { install } from './src/install.js'
import { uninstall } from './src/uninstall.js'
import { update } from './src/update.js'
import { status } from './src/status.js'

const [,, cmd] = process.argv

switch (cmd) {
  case 'install': {
    const tools = detectInstalledTools()
    if (tools.length === 0) {
      console.log('No supported AI tools found.')
      console.log('Checked: ~/.claude  ~/.cursor  ~/.codex  ~/.gemini')
      process.exit(0)
    }
    console.log(`Installing rn-ai for: ${tools.join(', ')}`)
    const results = install(tools)
    for (const r of results) {
      console.log(`  ${r.success ? '✓' : '✗'} ${r.tool}${r.error ? `: ${r.error}` : ''}`)
    }
    break
  }
  case 'uninstall': {
    const results = uninstall()
    if (results) {
      for (const r of results) {
        console.log(`  ${r.success ? '✓' : '✗'} ${r.tool}${r.error ? `: ${r.error}` : ''}`)
      }
      console.log('rn-ai uninstalled.')
    }
    break
  }
  case 'update': {
    const results = update()
    if (results) {
      for (const r of results) {
        console.log(`  ${r.success ? '✓' : '✗'} ${r.tool}${r.error ? `: ${r.error}` : ''}`)
      }
      console.log('rn-ai updated.')
    }
    break
  }
  case 'status': {
    status()
    break
  }
  default: {
    console.log('Usage: rn-ai <install|uninstall|update|status>')
    if (cmd) process.exit(1)
  }
}
```

- [ ] **Step 2: Make cli.js executable**

```bash
chmod +x cli.js
```

- [ ] **Step 3: Verify help output**

```bash
node cli.js
```

Expected output: `Usage: rn-ai <install|uninstall|update|status>`

- [ ] **Step 4: Commit**

```bash
git add cli.js
git commit -m "feat: add cli.js entry point wiring all four commands"
```

---

## Task 12: Create smoke test script

**Files:**
- Create: `scripts/smoke-test.sh`

- [ ] **Step 1: Create scripts/smoke-test.sh**

```bash
mkdir -p scripts
```

```bash
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
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x scripts/smoke-test.sh
```

- [ ] **Step 3: Run the smoke test**

```bash
bash scripts/smoke-test.sh
```

Expected output ends with: `All smoke tests passed.`

- [ ] **Step 4: Commit**

```bash
git add scripts/smoke-test.sh
git commit -m "test: add smoke test script for install/status/update/uninstall flow"
```

---

## Task 13: Create CI workflow

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Create .github/workflows/ci.yml**

```bash
mkdir -p .github/workflows
```

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Verify CLI help
        run: node cli.js

      - name: Run smoke test
        run: bash scripts/smoke-test.sh
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add GitHub Actions workflow running CLI help and smoke test"
```

---

## Task 14: Update root README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Replace README.md content**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README for npm package audience"
```
