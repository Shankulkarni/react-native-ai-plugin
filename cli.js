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
