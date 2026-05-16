---
name: scaffold
description: "Use when creating a new React Native app from scratch -- Expo SDK 52+ managed workflow, NativeWind v4, Expo Router, React Query, zustand-x, EAS config, ESLint/Prettier/Husky."
user_invocable: true
---

# App Scaffolding

## Stack
Expo SDK 52+ (managed), Expo Router v4, NativeWind v4, React Query, axios, react-hook-form + zod v4, zustand-x, Reanimated v3, Gesture Handler v2, MMKV, expo-secure-store, EAS.

## Before You Start

Gather from user:
- **App name** (display name + slug)
- **Bundle ID** (e.g. `com.myorg.myapp`)
- **API base URL** (or "set up later")
- **Auth type** (email/password, OAuth, magic link, or none)
- **Tab structure** (main tabs of the app)

## Step 1: Create Expo App

```bash
bunx create-expo-app@latest MyApp --template blank-typescript
cd MyApp
```

## Step 2: Install Core Dependencies

```bash
bunx expo install expo-router react-native-safe-area-context react-native-screens expo-linking expo-constants expo-status-bar
bunx expo install nativewind react-native-reanimated react-native-gesture-handler
bun add tailwindcss@^3.4.0
bunx expo install @tanstack/react-query axios
bunx expo install react-hook-form @hookform/resolvers zod zod-empty
bunx expo install expo-secure-store react-native-mmkv
bunx expo install expo-image
bun add zustand-x mutative
```

> **Note:** Install `tailwindcss` separately with `bun add tailwindcss@^3.4.0` — do NOT use `bunx expo install tailwindcss` as it resolves Tailwind v4 which NativeWind v4 does not support. NativeWind v4 requires Tailwind CSS v3.

## Step 3: `app.json`

```json
{
  "expo": {
    "name": "MyApp",
    "slug": "my-app",
    "version": "1.0.0",
    "scheme": "myapp",
    "newArchEnabled": true,
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.myorg.myapp"
    },
    "android": {
      "adaptiveIcon": { "foregroundImage": "./assets/adaptive-icon.png" },
      "package": "com.myorg.myapp"
    },
    "plugins": [
      "expo-router",
      "expo-secure-store"
    ]
  }
}
```

## Step 4: NativeWind v4 Setup

`tailwind.config.js`:
```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/**/*.{js,jsx,ts,tsx}', './src/**/*.{js,jsx,ts,tsx}'],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        primary: '#6366f1',
        background: '#ffffff',
      },
    },
  },
}
```

`global.css`:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

`metro.config.js`:
```js
const { getDefaultConfig } = require('expo/metro-config')
const { withNativeWind } = require('nativewind/metro')
const config = getDefaultConfig(__dirname)
module.exports = withNativeWind(config, { input: './global.css' })
```

`babel.config.js`:
```js
module.exports = function (api) {
  api.cache(true)
  return {
    presets: [
      ['babel-preset-expo', { jsxImportSource: 'nativewind' }],
      'nativewind/babel',
    ],
  }
}
```

## Step 5: Folder Structure

```
app/
├── (auth)/
│   ├── _layout.tsx
│   ├── login.tsx
│   └── register.tsx
├── (app)/
│   ├── _layout.tsx
│   └── (tabs)/
│       ├── _layout.tsx
│       └── index.tsx
├── _layout.tsx
└── +not-found.tsx

src/
├── api/
├── components/
│   ├── ui/
│   └── app/
├── hooks/
├── stores/
├── libs/
│   ├── cn.ts
│   ├── query-client.ts
│   └── axios.ts
└── types/
```

## Step 6: Core Libs

`src/libs/cn.ts`:
```ts
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'
export function cn(...inputs: ClassValue[]) { return twMerge(clsx(inputs)) }
```

`src/libs/query-client.ts`:
```ts
import { QueryClient } from '@tanstack/react-query'
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: { staleTime: Infinity, gcTime: Infinity, retry: false, refetchOnMount: false, refetchOnWindowFocus: false },
    mutations: { retry: false },
  },
})
```

`src/libs/axios.ts`:
```ts
import axios from 'axios'
export const api = axios.create({
  baseURL: process.env.EXPO_PUBLIC_API_URL,
  timeout: 30_000,
})
// Add auth interceptor: attach token from SecureStore
```

## Step 7: Root Layout (`app/_layout.tsx`)

```tsx
import '../global.css'
import { QueryClientProvider } from '@tanstack/react-query'
import { Stack } from 'expo-router'
import { queryClient } from '@/libs/query-client'

export default function RootLayout() {
  return (
    <QueryClientProvider client={queryClient}>
      <Stack screenOptions={{ headerShown: false }} />
    </QueryClientProvider>
  )
}
```

## Step 8: EAS

```bash
bun add -D eas-cli
bunx eas init
bunx eas build:configure
```

`eas.json`:
```json
{
  "cli": { "version": ">= 12.0.0" },
  "build": {
    "development": { "developmentClient": true, "distribution": "internal" },
    "preview": { "distribution": "internal" },
    "production": { "autoIncrement": true }
  },
  "submit": {
    "production": {}
  }
}
```

## Step 9: ESLint + Prettier + Husky

```bash
bun add -D eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser prettier husky lint-staged
bunx husky init
```

`eslint.config.js`:
```js
import tsPlugin from '@typescript-eslint/eslint-plugin'
import tsParser from '@typescript-eslint/parser'
export default [
  { files: ['src/**/*.{ts,tsx}', 'app/**/*.{ts,tsx}'], languageOptions: { parser: tsParser },
    plugins: { '@typescript-eslint': tsPlugin },
    rules: { '@typescript-eslint/no-explicit-any': 'error', 'no-console': 'error' } },
]
```

`.prettierrc`:
```json
{ "singleQuote": true, "semi": false, "trailingComma": "all", "useTabs": true }
```

`.husky/pre-commit`:
```bash
bun run typecheck && bun run lint
```

## Post-Scaffold Checklist
- [ ] `bun run typecheck` passes
- [ ] `bunx expo start` opens in Expo Go
- [ ] `newArchEnabled: true` in `app.json`
- [ ] `(auth)/` and `(app)/` layouts created
- [ ] `.env.local` with `EXPO_PUBLIC_API_URL` (never committed)
