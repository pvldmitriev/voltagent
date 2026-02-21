#!/usr/bin/env sh
set -eu

cd "$(git rev-parse --show-toplevel)" || exit 1

: "${FACTORY_MAX_MINUTES:=120}"
: "${FACTORY_MAX_RETRIES:=3}"
: "${FACTORY_MAX_BUDGET_USD:=50}"
: "${FACTORY_ATTEMPT:=1}"
: "${FACTORY_SPEND_USD:=0}"
: "${FACTORY_START_EPOCH:=0}"

if [ "$FACTORY_ATTEMPT" -gt "$FACTORY_MAX_RETRIES" ]; then
  echo "[factory:guard] retry limit reached: attempt=$FACTORY_ATTEMPT max=$FACTORY_MAX_RETRIES" >&2
  exit 1
fi

if [ "$FACTORY_START_EPOCH" -gt 0 ]; then
  now_epoch="$(date +%s)"
  elapsed_minutes=$(( (now_epoch - FACTORY_START_EPOCH) / 60 ))
  if [ "$elapsed_minutes" -gt "$FACTORY_MAX_MINUTES" ]; then
    echo "[factory:guard] time limit reached: elapsed=${elapsed_minutes}m max=${FACTORY_MAX_MINUTES}m" >&2
    exit 1
  fi
fi

budget_check="$(
  awk -v spend="$FACTORY_SPEND_USD" -v max="$FACTORY_MAX_BUDGET_USD" 'BEGIN { if (spend <= max) print "ok"; else print "fail"; }'
)"
if [ "$budget_check" != "ok" ]; then
  echo "[factory:guard] budget limit reached: spend=$FACTORY_SPEND_USD max=$FACTORY_MAX_BUDGET_USD" >&2
  exit 1
fi

echo "[factory:guard] limits ok"
