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
