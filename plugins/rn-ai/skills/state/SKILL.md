---
name: state
description: "Use when managing client-side UI state -- zustand-x v6 store creation, boundary rules, theme system, what belongs in store vs URL vs React Query vs SecureStore."
---

# State -- zustand-x v6

UI state only. Server data lives in React Query. Auth tokens live in SecureStore. URL state lives in Expo Router.

## State Boundary Rules

| State type | Where it lives |
|---|---|
| Server data (posts, users, products) | React Query |
| Auth tokens | SecureStore |
| Current user/session object | React Query cache |
| URL params, current route | Expo Router |
| Form values | react-hook-form |
| UI state (sidebar, modals, filters, theme) | zustand-x |

## Store Creation

```ts
// src/stores/ui-store.ts
import { createStore } from 'zustand-x'

type UIState = {
  sidebarOpen: boolean
  activeModal: string | null
  theme: 'light' | 'dark' | 'auto'
}

export const uiStore = createStore<UIState>(
  { sidebarOpen: false, activeModal: null, theme: 'auto' },
  { name: 'ui', mutative: true },
)
```

## Selectors + Actions

```ts
export const uiStore = createStore<UIState>(
  { sidebarOpen: false, activeModal: null, theme: 'auto' },
  { name: 'ui', mutative: true },
)
  .extendSelectors((state) => ({
    isDark: () => state.theme === 'dark' ||
      (state.theme === 'auto' && Appearance.getColorScheme() === 'dark'),
  }))
  .extendActions((set) => ({
    openModal: (id: string) => set.activeModal(id),
    closeModal: () => set.activeModal(null),
    toggleSidebar: () => set.sidebarOpen((prev) => !prev),
    setTheme: (theme: UIState['theme']) => set.theme(theme),
  }))
```

## Reading State

```tsx
import { useStoreValue, useStoreState, useTracked } from 'zustand-x'

// Read a single value
const sidebarOpen = useStoreValue(uiStore, 'sidebarOpen')

// Read + setter tuple (like useState)
const [theme, setTheme] = useStoreState(uiStore, 'theme')

// Proxy-based -- for nested objects, only re-renders when accessed property changes
const profile = useTracked(uiStore, 'profile')
const name = profile.name  // only re-renders if profile.name changes
```

## Theme System

```ts
// src/stores/theme-store.ts
import { Appearance } from 'react-native'
import { createStore } from 'zustand-x'

type ThemeState = { mode: 'light' | 'dark' | 'auto' }

export const themeStore = createStore<ThemeState>(
  { mode: 'auto' },
  { name: 'theme', mutative: true },
)
  .extendSelectors((state) => ({
    isDark: () => {
      if (state.mode === 'light') return false
      if (state.mode === 'dark') return true
      return Appearance.getColorScheme() === 'dark'
    },
  }))
```

In root `_layout.tsx` -- listen to system theme:
```tsx
useEffect(() => {
  const sub = Appearance.addChangeListener(() => {
    // Re-render when system theme changes
    themeStore.set.mode(themeStore.get.mode())
  })
  return () => sub.remove()
}, [])
```

## One Store Per Concern

```
src/stores/
├── ui-store.ts       ← sidebar, modals, loading states
├── theme-store.ts    ← dark/light/auto mode
├── filter-store.ts   ← list filters, sort order
└── player-store.ts   ← media player state (if applicable)
```

## Rules

- Never put server data in zustand -- use React Query
- Never put auth tokens in zustand -- use SecureStore
- Never put form values in zustand -- use react-hook-form
- Prefer URL params over zustand for state that should survive navigation
- One store per concern -- not one global store
- Use `mutative: true` always for immer-style mutations
