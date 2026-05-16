---
name: deslop
description: "Use when scanning a React Native app for code quality issues -- hardcoded URLs/secrets, console.logs, legacy bridge APIs, missing error boundaries, placeholder code."
---

# Deslop -- RN App Code Quality

Run the scanner:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/deslop.sh" ${ARGUMENT:-.}
```

## What It Scans

### Critical (exit 1, block deploy)
- `NativeModules` usage -- legacy bridge, banned in New Architecture
- `requireNativeComponent` -- use `codegenNativeComponent` instead
- `UIManager` usage -- legacy bridge, banned
- `AsyncStorage` usage -- banned, use MMKV or SecureStore
- `TouchableOpacity` / `TouchableHighlight` -- banned, use Pressable
- `PanResponder` -- banned, use Gesture Handler v2 `GestureDetector`
- `fetch(` outside `src/libs/` -- use axios instance
- `useEffect` with `fetch(` -- use React Query
- Hardcoded URLs (`https://`, `http://`) in source -- use `EXPO_PUBLIC_` env vars
- `{expr && <Component>}` -- renders `0` or `false`; use ternary or `Boolean()`

### Medium (warn, review before release)
- `console.log` / `console.warn` anywhere in `src/` -- crashes in Reanimated worklets, banned everywhere
- `TODO` / `FIXME` / `HACK` comments
- `form.watch(` -- use `useWatch`
- `interface` declaration -- use `type` instead
- RN `Image` from `react-native` -- use `expo-image`
- `router.push('/` string -- use typed routes
- `style={}` inline prop -- use `className` with NativeWind
- Missing `accessibilityRole` on interactive elements

### Low (info)
- `eslint-disable` comments
- `@ts-ignore` / `@ts-expect-error`
- Default exports in `src/` (except route files in `app/`)
- `any` type annotations

## Never Auto-Fix
- Hardcoded secrets -- flag only, user removes
- Legacy bridge APIs -- requires architectural change

## After Scanning
List critical issues with `file:line` format. Suggest fix for each. Group by severity.
