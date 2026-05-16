---
name: scaffold
description: Scaffold a new Expo app with the full rn-claude stack
---

# /rn-scaffold

Creates a new Expo app with the full stack: Expo Router, NativeWind v4, React Query, axios, zustand-x, Reanimated, Gesture Handler, MMKV, SecureStore, EAS.

## Usage

```
/rn-scaffold <app-name>
```

## What it does

Reads the `scaffold` skill and executes full app creation:

1. `bunx create-expo-app@latest <app-name> --template tabs`
2. Installs all required dependencies
3. Configures `app.json` (newArchEnabled, scheme, plugins)
4. Sets up NativeWind (metro config, babel config, global.css)
5. Sets up `QueryClient` in root `_layout.tsx`
6. Creates axios instance in `src/libs/axios.ts`
7. Creates folder structure: `src/api/`, `src/components/`, `src/libs/`, `src/stores/`
8. Sets up ESLint + Prettier + Husky
9. Runs `bunx eas init`
10. Creates `eas.json` with development/preview/production profiles

## After scaffolding

- Set `EXPO_PUBLIC_API_URL` in `.env.local`
- Run `bun run ios` or `bun run android` to verify
- Run `/rn-deslop` to confirm no legacy patterns crept in from template
