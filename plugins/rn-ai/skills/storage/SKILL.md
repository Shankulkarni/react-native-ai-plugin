---
name: storage
description: "Use when persisting local data -- MMKV for fast non-sensitive storage, expo-secure-store for sensitive data, decision guide for which to use."
---

# Local Storage

Two options. Pick based on sensitivity. Never AsyncStorage.

## Decision Guide

| Data | Storage |
|---|---|
| Auth tokens, passwords, keys | `expo-secure-store` |
| User preferences, settings, cache | `MMKV` |
| Draft content, offline queue | `MMKV` |
| Onboarding state, feature flags | `MMKV` |
| Biometric keys, encryption keys | `expo-secure-store` |

**Never `AsyncStorage`** -- synchronous MMKV is always faster, SecureStore is always safer for sensitive data.

## MMKV Setup

```bash
bun add react-native-mmkv
```

`src/libs/storage.ts`:
```ts
import { MMKV } from 'react-native-mmkv'

export const storage = new MMKV({ id: 'app-storage' })

// Typed helpers
export const appStorage = {
  // Preferences
  getTheme: () => storage.getString('theme') as 'light' | 'dark' | 'auto' | undefined,
  setTheme: (theme: 'light' | 'dark' | 'auto') => storage.set('theme', theme),

  // Onboarding
  getOnboardingDone: () => storage.getBoolean('onboarding_done') ?? false,
  setOnboardingDone: () => storage.set('onboarding_done', true),

  // Cache timestamps
  getLastSync: () => storage.getNumber('last_sync'),
  setLastSync: (ts: number) => storage.set('last_sync', ts),

  // Clear
  clear: () => storage.clearAll(),
}
```

## MMKV with zustand-x (Persist)

```ts
import { createStore } from 'zustand-x'
import { storage } from '@/libs/storage'

type SettingsState = { theme: 'light' | 'dark' | 'auto'; language: string }

export const settingsStore = createStore<SettingsState>(
  {
    theme: storage.getString('theme') as 'light' | 'dark' | 'auto' ?? 'auto',
    language: storage.getString('language') ?? 'en',
  },
  { name: 'settings', mutative: true },
).extendActions((set, get) => ({
  setTheme: (theme: SettingsState['theme']) => {
    set.theme(theme)
    storage.set('theme', theme)   // persist immediately
  },
  setLanguage: (language: string) => {
    set.language(language)
    storage.set('language', language)
  },
}))
```

## expo-secure-store

```ts
// src/libs/token.ts
import * as SecureStore from 'expo-secure-store'

export const tokenStorage = {
  getAccess: () => SecureStore.getItemAsync('access_token'),
  setAccess: (token: string) => SecureStore.setItemAsync('access_token', token),
  getRefresh: () => SecureStore.getItemAsync('refresh_token'),
  setRefresh: (token: string) => SecureStore.setItemAsync('refresh_token', token),
  clear: () => Promise.all([
    SecureStore.deleteItemAsync('access_token'),
    SecureStore.deleteItemAsync('refresh_token'),
  ]),
}
```

SecureStore is async (reads from Keychain/Keystore). For app startup:
```ts
// Preload token at app start to avoid waterfall
const token = await SecureStore.getItemAsync('access_token')
```

## Offline Queue Pattern (MMKV)

```ts
type QueuedAction = { id: string; type: string; payload: unknown; timestamp: number }

const QUEUE_KEY = 'offline_queue'

export const offlineQueue = {
  get: (): QueuedAction[] => {
    const raw = storage.getString(QUEUE_KEY)
    return raw ? JSON.parse(raw) : []
  },
  add: (action: Omit<QueuedAction, 'id' | 'timestamp'>) => {
    const queue = offlineQueue.get()
    queue.push({ ...action, id: crypto.randomUUID(), timestamp: Date.now() })
    storage.set(QUEUE_KEY, JSON.stringify(queue))
  },
  remove: (id: string) => {
    const queue = offlineQueue.get().filter(a => a.id !== id)
    storage.set(QUEUE_KEY, JSON.stringify(queue))
  },
  clear: () => storage.delete(QUEUE_KEY),
}
```

## Rules

- `SecureStore` for anything sensitive -- tokens, keys, passwords
- `MMKV` for preferences, cache, state that survives app restart
- Never `AsyncStorage` -- deprecated by community, synchronous MMKV is better
- Persist zustand stores to MMKV at action level (not via middleware) for explicit control
- Always `deleteItemAsync` on sign out to clear SecureStore
