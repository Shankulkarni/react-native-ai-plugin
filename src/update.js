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
