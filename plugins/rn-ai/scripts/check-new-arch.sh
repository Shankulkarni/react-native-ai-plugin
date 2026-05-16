#!/usr/bin/env bash
# Verifies New Architecture is enabled and no legacy bridge APIs are in use

set -euo pipefail

errors=0
PASS="✓"
FAIL="✗"

check_pass() { echo "  $PASS $1"; }
check_fail() { echo "  $FAIL $1"; errors=$((errors + 1)); }

echo ""
echo "New Architecture check"
echo "======================"

# newArchEnabled in app.json
if [ -f "app.json" ]; then
  if grep -q '"newArchEnabled": true' app.json; then
    check_pass "newArchEnabled: true in app.json"
  else
    check_fail "newArchEnabled missing or false in app.json"
  fi
else
  echo "  ! app.json not found -- check app.config.ts manually"
fi

# Scan for bridge APIs
TARGETS="src app"
bridge_hits=$(grep -rn --include="*.ts" --include="*.tsx" -E "NativeModules|requireNativeComponent|UIManager\." $TARGETS 2>/dev/null || true)
if [ -n "$bridge_hits" ]; then
  check_fail "Legacy bridge APIs found:"
  echo "$bridge_hits"
else
  check_pass "No legacy bridge APIs (NativeModules, requireNativeComponent, UIManager)"
fi

# AsyncStorage
async_hits=$(grep -rn --include="*.ts" --include="*.tsx" "AsyncStorage" $TARGETS 2>/dev/null || true)
if [ -n "$async_hits" ]; then
  check_fail "AsyncStorage found (use MMKV or SecureStore):"
  echo "$async_hits"
else
  check_pass "No AsyncStorage usage"
fi

echo ""
if [ $errors -eq 0 ]; then
  echo "New Architecture compliance: OK"
else
  echo "$errors issue(s) found. Fix before building."
  exit 1
fi
