---
name: eas-check
description: Verify EAS configuration is correct before triggering a build
---

# /rn-eas-check

Validates your EAS setup before running a build or submit.

## Usage

```
/rn-eas-check
```

## What it checks

1. `eas.json` exists with `development`, `preview`, `production` profiles
2. `expo-updates` installed and `updates.url` set in `app.json`
3. `runtimeVersion` policy configured
4. `EXPO_PUBLIC_API_URL` set in `.env.local` (not hardcoded in source)
5. No committed `.env` files in git history
6. EAS project ID in `app.json` matches `eas.json`
7. `autoIncrement: true` on production profile
8. Submit config present for App Store / Play Store
9. `EXPO_TOKEN` secret exists (warns if not — CI will fail)

## Steps

```bash
bash .claude/plugins/rn-claude/scripts/eas-check.sh
```

## Output

Checklist of passed/failed items. Exit code 1 if any critical checks fail.
