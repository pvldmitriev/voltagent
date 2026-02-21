#!/usr/bin/env sh
set -eu

cd "$(git rev-parse --show-toplevel)" || exit 1

if ! command -v rg >/dev/null 2>&1; then
  echo "[security-council] rg is required" >&2
  exit 1
fi

scan_range=""
if git rev-parse --verify origin/main >/dev/null 2>&1; then
  scan_range="origin/main...HEAD"
else
  scan_range="HEAD~1...HEAD"
fi

changed_files="$(git diff --name-only "$scan_range" || true)"
if [ -z "$changed_files" ]; then
  changed_files="$(
    {
      git diff --name-only --cached || true
      git diff --name-only || true
    } | sort -u
  )"
fi
if [ -z "$changed_files" ]; then
  echo "[security-council] no changed files"
  exit 0
fi

secret_regex='(AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9_]{30,}|AIza[0-9A-Za-z\-_]{35}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN (RSA|EC|OPENSSH|DSA|PGP) PRIVATE KEY-----)'
found=0

for file in $changed_files; do
  if [ ! -f "$file" ]; then
    continue
  fi

  case "$file" in
    *.png|*.jpg|*.jpeg|*.gif|*.ico|*.pdf|*.lock|pnpm-lock.yaml)
      continue
      ;;
  esac

  if rg -n "$secret_regex" "$file" >/dev/null 2>&1; then
    echo "[security-council] potential secret pattern in $file" >&2
    found=1
  fi
done

if [ "$found" -ne 0 ]; then
  exit 1
fi

echo "[security-council] checks passed"
