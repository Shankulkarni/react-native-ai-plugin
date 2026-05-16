#!/usr/bin/env bash
# Validates EAS configuration before triggering a build or submit

set -euo pipefail

errors=0
warnings=0
PASS="✓"
FAIL="✗"
WARN="!"

pass() { echo "  $PASS $1"; }
fail() { echo "  $FAIL $1"; errors=$((errors + 1)); }
warn() { echo "  $WARN $1"; warnings=$((warnings + 1)); }

echo ""
echo "EAS configuration check"
echo "========================"

# eas.json exists
if [ ! -f "eas.json" ]; then
  fail "eas.json not found -- run: bunx eas init"
else
  pass "eas.json exists"

  # Required profiles
  for profile in development preview production; do
    if grep -q "\"$profile\"" eas.json; then
      pass "Profile '$profile' defined"
    else
      fail "Profile '$profile' missing from eas.json"
    fi
  done

  # autoIncrement on production
  if command -v jq &>/dev/null; then
    if jq -e '.build.production.autoIncrement == true' eas.json &>/dev/null 2>&1; then
      pass "autoIncrement: true on production profile"
    else
      warn "autoIncrement not set on production profile"
    fi
  elif grep -q '"autoIncrement".*true' eas.json 2>/dev/null; then
    pass "autoIncrement: true found (verify it is on the production profile)"
  else
    warn "autoIncrement not set -- add to production profile in eas.json"
  fi
fi

# app.json checks
if [ -f "app.json" ]; then
  # expo-updates url
  if grep -q '"url"' app.json && grep -q 'updates.expo.io' app.json; then
    pass "expo-updates URL configured"
  else
    warn "expo-updates URL not found in app.json -- OTA updates won't work"
  fi

  # runtimeVersion
  if grep -q '"runtimeVersion"' app.json || grep -q '"policy"' app.json; then
    pass "runtimeVersion configured"
  else
    warn "runtimeVersion not configured -- add policy to app.json"
  fi

  # EAS project ID
  if grep -q '"projectId"' app.json; then
    pass "EAS projectId in app.json"
  else
    warn "EAS projectId missing -- run: bunx eas init"
  fi
fi

# No hardcoded URLs in source
hardcoded=$(grep -rn --include="*.ts" --include="*.tsx" -E "https?://[a-zA-Z0-9]" src app 2>/dev/null || true)
if [ -n "$hardcoded" ]; then
  fail "Hardcoded URLs found in source -- use EXPO_PUBLIC_API_URL:"
  echo "$hardcoded"
else
  pass "No hardcoded URLs in source"
fi

# .env files not committed
if git ls-files | grep -q "^\.env" 2>/dev/null; then
  fail ".env file tracked by git -- remove and add to .gitignore"
else
  pass ".env files not in git"
fi

# EXPO_TOKEN warning (can't verify remotely)
warn "Verify EXPO_TOKEN is set as an EAS secret or CI environment variable"

echo ""
echo "========================"
echo "Errors:   $errors"
echo "Warnings: $warnings"
echo ""

if [ $errors -gt 0 ]; then
  echo "Fix errors before triggering EAS build."
  exit 1
else
  echo "EAS config looks good."
fi
