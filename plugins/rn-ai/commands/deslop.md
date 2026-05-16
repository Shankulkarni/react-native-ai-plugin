---
name: deslop
description: Scan the codebase for legacy patterns, New Architecture violations, and common AI-generated mistakes
---

# /rn-deslop

Scans `src/` and `app/` for patterns that violate New Architecture rules or rn-claude conventions.

## Usage

```
/rn-deslop
```

## What it checks

### Critical (must fix)
- `NativeModules` usage
- `requireNativeComponent` usage
- `UIManager` usage
- `AsyncStorage` imports
- `TouchableOpacity` / `TouchableHighlight`
- `fetch(` calls outside `src/libs/`
- `useEffect` with data fetching patterns
- Hardcoded API URLs (`http://`, `https://` literals in source)
- `console.log` inside worklet functions
- `&&` with potentially falsy left operands in JSX

### Medium (should fix)
- `form.watch()` instead of `useWatch()`
- `interface ` declarations (use `type` instead)
- Missing `accessibilityRole` on `Pressable` elements
- `Image` from `react-native` (use `expo-image`)
- `PanResponder` usage
- String navigation: `router.push('/path')`
- `style=` props where `className=` should be used

## Steps

```bash
bash .claude/plugins/rn-claude/scripts/deslop.sh
```

## Output

Prints findings grouped by severity with file paths and line numbers. Exit code 1 if any critical issues found.
