#!/usr/bin/env bash
# Verifies the project environment is correctly set up for rn-claude

set -euo pipefail

PASS="✓"
FAIL="✗"
WARN="!"
errors=0

check() {
  local label="$1"
  local result="$2"
  if [ "$result" = "ok" ]; then
    echo "  $PASS $label"
  elif [ "$result" = "warn" ]; then
    echo "  $WARN $label"
  else
    echo "  $FAIL $label"
    errors=$((errors + 1))
  fi
}

echo ""
echo "rn-claude setup check"
echo "====================="

# bun
if command -v bun &>/dev/null; then
  check "bun installed ($(bun --version))" "ok"
else
  check "bun not found -- install from bun.sh" "fail"
fi

# eas-cli
if command -v eas &>/dev/null || bunx eas --version &>/dev/null 2>&1; then
  check "eas-cli available" "ok"
else
  check "eas-cli not found -- run: bun add -g eas-cli" "warn"
fi

# app.json / app.config.ts
if [ -f "app.json" ]; then
  if grep -q '"newArchEnabled": true' app.json 2>/dev/null; then
    check "newArchEnabled: true in app.json" "ok"
  else
    check "newArchEnabled: true missing from app.json" "fail"
  fi
elif [ -f "app.config.ts" ] || [ -f "app.config.js" ]; then
  check "app.config file found -- verify newArchEnabled: true manually" "warn"
else
  check "app.json not found -- are you in the project root?" "fail"
fi

# NativeWind
if grep -q '"nativewind"' package.json 2>/dev/null; then
  check "nativewind installed" "ok"
else
  check "nativewind not in package.json" "fail"
fi

# metro.config.js
if [ -f "metro.config.js" ] || [ -f "metro.config.ts" ]; then
  if grep -q "withNativeWind" metro.config.js 2>/dev/null || grep -q "withNativeWind" metro.config.ts 2>/dev/null; then
    check "NativeWind metro config wired" "ok"
  else
    check "withNativeWind not found in metro config" "fail"
  fi
else
  check "metro.config.js not found" "fail"
fi

# React Query
if grep -q '"@tanstack/react-query"' package.json 2>/dev/null; then
  check "@tanstack/react-query installed" "ok"
else
  check "@tanstack/react-query not in package.json" "warn"
fi

# eas.json
if [ -f "eas.json" ]; then
  check "eas.json exists" "ok"
else
  check "eas.json not found -- run: bunx eas init" "warn"
fi

echo ""
if [ $errors -eq 0 ]; then
  echo "All checks passed."
else
  echo "$errors check(s) failed. Fix the issues above before proceeding."
  exit 1
fi
