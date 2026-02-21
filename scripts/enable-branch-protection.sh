#!/usr/bin/env sh
set -eu

cd "$(git rev-parse --show-toplevel)" || exit 1

: "${GITHUB_REPO:=VoltAgent/voltagent}"
: "${GITHUB_BRANCH:=main}"

gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/${GITHUB_REPO}/branches/${GITHUB_BRANCH}/protection" \
  -F required_status_checks.strict=true \
  -F required_status_checks.contexts[]="Commitlint" \
  -F required_status_checks.contexts[]="Quality Council" \
  -F required_status_checks.contexts[]="Regression Council" \
  -F required_status_checks.contexts[]="Security Council" \
  -F required_status_checks.contexts[]="Factory Memory Governance" \
  -F required_status_checks.contexts[]="Factory Gates" \
  -F enforce_admins=true \
  -F required_pull_request_reviews.dismiss_stale_reviews=true \
  -F required_pull_request_reviews.required_approving_review_count=1 \
  -F required_pull_request_reviews.require_last_push_approval=true \
  -F restrictions= \
  -F required_linear_history=true \
  -F allow_force_pushes=false \
  -F allow_deletions=false \
  -F block_creations=false \
  -F required_conversation_resolution=true \
  -F lock_branch=false \
  -F allow_fork_syncing=true

echo "Branch protection applied: ${GITHUB_REPO}@${GITHUB_BRANCH}"
