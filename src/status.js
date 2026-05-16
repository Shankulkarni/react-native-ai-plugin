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
