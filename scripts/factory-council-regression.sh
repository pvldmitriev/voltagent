#!/usr/bin/env sh
set -eu

cd "$(git rev-parse --show-toplevel)" || exit 1

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
  echo "[regression-council] no changed files"
  exit 0
fi

package_names="$(
  printf '%s\n' "$changed_files" | awk -F/ '/^packages\/[^\/]+\//{print $2}' | sort -u
)"
if [ -z "$package_names" ]; then
  echo "[regression-council] no package changes, tests skipped"
  exit 0
fi

echo "[regression-council] test changed packages"
for pkg in $package_names; do
  if [ "$pkg" = "create-voltagent-app" ]; then
    scope="create-voltagent-app"
  else
    scope="@voltagent/$pkg"
  fi
  lerna run test --scope "$scope" --include-dependencies
done
