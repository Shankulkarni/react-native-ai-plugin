---
name: eas
description: "Use when configuring EAS Build, Submit, or Update -- eas.json profiles, OTA updates, App Store/Play Store submission, GitHub Actions CI, EAS secrets."
---

# EAS -- Build + Submit + Update

Expo Application Services. Builds, submits, and updates your app.

## `eas.json`

```json
{
  "cli": { "version": ">= 12.0.0", "appVersionSource": "remote" },
  "build": {
    "base": {
      "node": "22.0.0",
      "env": {
        "EXPO_PUBLIC_API_URL": "https://api.example.com"
      }
    },
    "development": {
      "extends": "base",
      "developmentClient": true,
      "distribution": "internal",
      "env": { "EXPO_PUBLIC_API_URL": "https://dev-api.example.com" },
      "ios": { "simulator": true }
    },
    "preview": {
      "extends": "base",
      "distribution": "internal",
      "channel": "preview"
    },
    "production": {
      "extends": "base",
      "autoIncrement": true,
      "channel": "production"
    }
  },
  "submit": {
    "production": {
      "ios": { "appleId": "dev@example.com", "ascAppId": "1234567890" },
      "android": { "serviceAccountKeyPath": "./service-account.json", "track": "internal" }
    }
  }
}
```

## Build Commands

```bash
# Development build (custom dev client)
bunx eas build --profile development --platform ios
bunx eas build --profile development --platform android

# Preview (internal distribution)
bunx eas build --profile preview --platform all

# Production
bunx eas build --profile production --platform all

# Local build (no EAS servers)
bunx eas build --profile development --platform ios --local
```

## OTA Updates

```bash
# Publish update to a channel
bunx eas update --channel preview --message "Fix login crash"
bunx eas update --channel production --message "v1.2.3 release"

# Check update status
bunx eas update:list
```

`app.json` update config:
```json
{
  "expo": {
    "updates": {
      "url": "https://u.expo.dev/YOUR-PROJECT-ID",
      "enabled": true,
      "fallbackToCacheTimeout": 0,
      "checkAutomatically": "ON_LOAD"
    },
    "runtimeVersion": { "policy": "appVersion" }
  }
}
```

Handle updates in root `_layout.tsx`:
```tsx
import * as Updates from 'expo-updates'
import { useEffect } from 'react'

export default function RootLayout() {
  // OTA update check is an SDK imperative call, not server data fetching --
  // React Query doesn't apply here. This is the only acceptable useEffect+async pattern.
  useEffect(() => {
    async function checkUpdate() {
      if (__DEV__) return
      const update = await Updates.checkForUpdateAsync()
      if (update.isAvailable) {
        await Updates.fetchUpdateAsync()
        await Updates.reloadAsync()
      }
    }
    checkUpdate()
  }, [])
  // ...
}
```

## Submit to Stores

```bash
# After a production build
bunx eas submit --platform ios --latest
bunx eas submit --platform android --latest

# Submit specific build
bunx eas submit --platform ios --id BUILD_ID
```

## EAS Secrets

```bash
# Set secrets (never commit these)
bunx eas secret:create --scope project --name API_SECRET_KEY --value "..."
bunx eas secret:create --scope project --name SENTRY_DSN --value "..."

# List secrets
bunx eas secret:list
```

Access in build via `eas.json` `env`:
```json
{ "build": { "production": { "env": { "SENTRY_DSN": "$SENTRY_DSN" } } } }
```

## GitHub Actions CI

`.github/workflows/eas-build.yml`:
```yaml
name: EAS Build
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    concurrency:
      group: ${{ github.workflow }}-${{ github.ref }}
      cancel-in-progress: false
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile
      - uses: expo/expo-github-action@v8
        with:
          eas-version: latest
          token: ${{ secrets.EXPO_TOKEN }}
      - run: bunx eas build --profile production --platform all --non-interactive
```

`.github/workflows/eas-update.yml`:
```yaml
name: EAS Update
on:
  push:
    branches: [main]

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile
      - uses: expo/expo-github-action@v8
        with: { eas-version: latest, token: '${{ secrets.EXPO_TOKEN }}' }
      - run: bunx eas update --channel production --message "${{ github.event.head_commit.message }}" --non-interactive
```

## Rules

- `eas.json` must have `development`, `preview`, and `production` profiles
- Never hardcode API URLs in `eas.json` -- use EAS secrets or env vars
- Never commit `service-account.json` or Apple credentials -- use EAS secrets
- `concurrency.cancel-in-progress: false` in CI -- never cancel in-flight builds
- `runtimeVersion` policy must be consistent across OTA updates and builds
- Always test OTA update compatibility before shipping to production
