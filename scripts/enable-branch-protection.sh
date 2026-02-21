#!/usr/bin/env sh
set -eu

cd "$(git rev-parse --show-toplevel)" || exit 1

: "${GITHUB_REPO:=VoltAgent/voltagent}"
: "${GITHUB_BRANCH:=main}"

gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/${GITHUB_REPO}/branches/${GITHUB_BRANCH}/protection" \
  --input - <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "Commitlint",
      "Quality Council",
      "Regression Council",
      "Security Council",
      "Factory Memory Governance",
      "Factory Gates"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "required_approving_review_count": 1,
    "require_last_push_approval": true
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true,
  "lock_branch": false,
  "allow_fork_syncing": true
}
JSON

echo "Branch protection applied: ${GITHUB_REPO}@${GITHUB_BRANCH}"
