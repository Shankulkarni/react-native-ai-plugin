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
  try {
    writeFileSync(LOCKFILE, JSON.stringify({
      version: pkgVersion(),
      installedAt: new Date().toISOString(),
      tools: installed,
    }, null, 2))
  } catch (err) {
    console.error(`Failed to write lockfile: ${err.message}`)
    throw err
  }

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
    writeFileSync(claudeMdPath, `\n\n${FENCE}\n${rules}\n${FENCE}\n`)
  }
}

function writeAgentsMd(tool) {
  const agentsMd = readFileSync(join(PLUGIN_SRC, 'AGENTS.md'), 'utf8')
  writeFileSync(join(tool.configDir, 'rn-ai-AGENTS.md'), agentsMd)
}
