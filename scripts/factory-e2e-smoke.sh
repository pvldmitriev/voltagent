#!/usr/bin/env sh
set -eu

cd "$(git rev-parse --show-toplevel)" || exit 1
SMOKE_DIST_DIR=".factory-smoke-dist"
trap 'rm -rf "$SMOKE_DIST_DIR"' EXIT INT TERM

echo "[factory:smoke] init -> run -> cycle -> assert"
pnpm exec tsup scripts/factory-smoke-project.ts \
  --format cjs \
  --target es2022 \
  --out-dir "$SMOKE_DIST_DIR" \
  --clean \
  --silent
node "$SMOKE_DIST_DIR/factory-smoke-project.js"
