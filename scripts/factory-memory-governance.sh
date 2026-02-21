#!/usr/bin/env sh
set -eu

cd "$(git rev-parse --show-toplevel)" || exit 1

if [ "${FACTORY_MEMORY_BYPASS:-0}" = "1" ]; then
  echo "[factory-memory] bypass enabled"
  exit 0
fi

title_lc="$(printf '%s' "${PR_TITLE:-}" | tr '[:upper:]' '[:lower:]')"

requires_memory_update=0
case "$title_lc" in
  *"[incident]"*|*"[hotfix]"*|*"[sev]"*|*"incident"*|*"hotfix"*|*"postmortem"*)
    requires_memory_update=1
    ;;
esac

if [ "$requires_memory_update" -eq 0 ]; then
  echo "[factory-memory] no incident marker in PR title, skipping"
  exit 0
fi

if [ -z "${PR_BASE_SHA:-}" ] || [ -z "${PR_HEAD_SHA:-}" ]; then
  echo "[factory-memory] PR_BASE_SHA and PR_HEAD_SHA are required for incident PRs" >&2
  exit 1
fi

if ! git diff --name-only "$PR_BASE_SHA" "$PR_HEAD_SHA" | rg -q '^docs/factory-memory\.md$'; then
  echo "[factory-memory] incident PR must update docs/factory-memory.md" >&2
  exit 1
fi

echo "[factory-memory] governance check passed"
