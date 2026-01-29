#!/usr/bin/env bash
set -euo pipefail

FILES=$(git ls-files | grep -E '\.(md|txt)$' || true)

if [ -z "$FILES" ]; then
  echo "No markdown/text files found to scan."
  exit 0
fi

BANNED_REGEX='(as an ai|i can\x27t|i cannot|i will\b|note:|internal\b|do not share|safety\b|assistant\b|instructions\b|paste here|next step|i recommend)'
EM_DASH='—'

fail=0

while IFS= read -r f; do
  if grep -Ein "$BANNED_REGEX" "$f" >/dev/null 2>&1; then
    echo "FAIL: banned phrasing found in $f"
    grep -Ein "$BANNED_REGEX" "$f" || true
    echo
    fail=1
  fi
  if grep -n "$EM_DASH" "$f" >/dev/null 2>&1; then
    echo "FAIL: em dash found in $f"
    grep -n "$EM_DASH" "$f" || true
    echo
    fail=1
  fi

done <<< "$FILES"

if [ $fail -eq 1 ]; then
  echo "Public copy check failed."
  exit 1
fi

echo "Public copy check OK."
