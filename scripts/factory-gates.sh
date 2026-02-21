#!/usr/bin/env sh
set -eu

cd "$(git rev-parse --show-toplevel)" || exit 1

echo "[factory:gates] runtime guard"
pnpm factory:guard

echo "[factory:gates] quality council"
pnpm factory:council:quality

echo "[factory:gates] security council"
pnpm factory:council:security

echo "[factory:gates] regression council"
pnpm factory:council:regression
