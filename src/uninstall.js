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
