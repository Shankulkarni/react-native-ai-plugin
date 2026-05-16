# React Native AI Plugin — Design Spec

**Date:** 2026-05-16
**Status:** Approved
**Package:** `react-native-ai-plugin`
**CLI command:** `rn-ai`

## Overview

Rename RN-Claude to React Native AI Plugin and repackage it as an npm CLI that installs into Claude Code, Cursor, Gemini CLI, and Codex. Replaces the Claude Code marketplace plugin entirely. The existing skill/agent content is already tool-agnostic — the work is structural (packaging + content migration) not conceptual.

Reference implementations: `vibe-code-audit` (vibeAudit) for the npm CLI pattern, `dotagent` for the shared-core + tool-specific-manifests pattern.

---

## Section 1: Package Structure

```
react-native-ai-plugin/
├── cli.js                        # single entry point, #!/usr/bin/env node
├── package.json                  # name: react-native-ai-plugin, bin: { rn-ai: ./cli.js }
├── plugins/
│   └── rn-ai/
│       ├── skills/               # 14 skills, tool-agnostic markdown
│       │   ├── scaffold/SKILL.md
│       │   ├── component/SKILL.md
│       │   ├── animations/SKILL.md
│       │   └── ... (all 14)
│       ├── agents/               # 7 agents, tool-agnostic
│       │   ├── orchestrator.md
│       │   ├── app-architect.md
│       │   └── ...
│       ├── commands/             # slash commands (Claude Code only)
│       │   └── *.md
│       ├── scripts/              # bash utilities
│       │   └── *.sh
│       ├── CLAUDE.md             # global rules block for Claude
│       └── AGENTS.md             # global rules block for Codex/Gemini
├── manifests/
│   ├── claude-plugin.json        # Claude Code plugin manifest
│   ├── codex-plugin.json         # Codex plugin manifest
│   └── openai.yaml               # Codex UI metadata for agents
└── src/
    ├── detect.js                 # detects which AI tools are installed
    ├── install.js                # copies files, writes manifests
    ├── uninstall.js              # removes installed files
    ├── update.js                 # re-copies changed files
    └── status.js                 # reads lockfile, reports what's installed
```

Skill and agent content lives in `plugins/rn-ai/` (renamed from `plugins/rn-claude/`). A `.rn-ai-lock.json` in the user's home directory tracks installed version and which tools were installed.

---

## Section 2: CLI Architecture

### Commands

```
rn-ai install     Detect installed AI tools, copy plugin files, write manifests
rn-ai uninstall   Remove all installed plugin files and manifests
rn-ai update      Re-copy changed files for already-installed tools
rn-ai status      Show installed version, which tools are active, any updates available
```

### Install Flow

1. Detect which tools are installed by checking known config dirs (`~/.claude/`, `~/.cursor/`, `~/.codex/`, `~/.gemini/`)
2. For each detected tool, copy `plugins/rn-ai/` content into its plugin directory
3. Write tool-specific manifest
4. For Claude: append CLAUDE.md rules block into `~/.claude/CLAUDE.md`
5. For Codex/Gemini: write AGENTS.md into their config dirs
6. Write `~/.rn-ai-lock.json` with version + installed tools list

### Tool Install Targets

| Tool | Plugin dir | Manifest |
|---|---|---|
| Claude Code | `~/.claude/plugins/rn-ai/` | `plugin.json` |
| Cursor | `~/.cursor/rules/rn-ai/` | `.cursorrules` block |
| Codex | `~/.codex/plugins/rn-ai/` | `plugin.json` + `openai.yaml` |
| Gemini CLI | `~/.gemini/plugins/rn-ai/` | `AGENTS.md` |

### Update Flow

Reads lockfile to know which tools were installed. Re-copies only files whose content hash differs from installed version.

### Status Flow

Reads lockfile, compares installed version against package version, prints a table of tools + install state.

---

## Section 3: Content Migration from RN-Claude

### Repo Cleanup

Remove the existing `.claude-plugin/` directory from the repo root — this is the old marketplace plugin manifest and is replaced by `manifests/claude-plugin.json` inside the npm package. The repo itself becomes the npm package source, not a Claude marketplace plugin.

### What Changes

| Item | Current | New |
|---|---|---|
| Package name | `rn-claude` | `rn-ai` |
| Plugin dir | `plugins/rn-claude/` | `plugins/rn-ai/` |
| Skill tool refs | `Use the Read tool`, `Use Bash` | Generic: `Read the file`, `Run the command` |
| Command prefix | `/rn-claude:setup` etc. | `/rn-ai:setup` etc. |
| CLAUDE.md header | "RN-Lib-Claude" | "React Native AI Plugin" |
| Marketplace refs | `shankulkarni/claude-plugin-marketplace` | `npmjs.com/package/react-native-ai-plugin` |
| `plugin.json` `id` | `rn-claude` | `rn-ai` |

### What Stays Identical

All skill content (scaffold, component, animations, hooks, testing, performance, deslop, etc.), all agent role definitions, all bash scripts, all TypeScript/RN hard rules. The expertise is React Native knowledge, not Claude knowledge.

### New Files

- **AGENTS.md** — same hard rules as CLAUDE.md, adapted for Codex/Gemini format (identical content, different filename)
- **`.cursorrules` block** — condensed version of hard rules for Cursor injection. Cursor doesn't support the full skill system, so only the global rules (New Arch, bun, TypeScript strict, etc.) are written. Skills are not supported in Cursor's format.

---

## Section 4: Error Handling, Testing & Publishing

### Error Handling

- Tool detection is non-fatal — if no tools found, print what was checked and exit 0
- File copy failures print which tool failed and continue with remaining tools (partial install is valid)
- Missing home directory or permission errors exit 1 with a human-readable message
- No silent swallowing — every failure surfaces to the user

### Testing

- No unit tests for v1 — the CLI is file I/O glue
- Manual smoke test: `scripts/smoke-test.sh` installs into a temp dir, checks all expected files exist, uninstalls, verifies cleanup
- CI: GitHub Actions runs `node cli.js --help` and the smoke test on each push

### Publishing

- `npm publish` (not `bunx publish`) — npm registry requirement
- Changesets required before every publish
- `package.json` `files` array explicitly lists `cli.js`, `plugins/`, `manifests/`, `src/`
- `engines: { node: ">=18" }`

### Version Tracking

- `~/.rn-ai-lock.json` stores `{ version, installedAt, tools: ["claude", "cursor"] }`
- `rn-ai status` compares lockfile version against `package.json` version to detect available updates
