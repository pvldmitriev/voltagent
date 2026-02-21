# Factory Memory

Persistent operational memory for incident-driven improvements.

## Usage Rules

1. Update this file for every PR that contains `[incident]`, `[hotfix]`, `[sev]`, or equivalent incident markers in the title.
2. Keep entries short and factual: root cause, guardrail, and verification signal.
3. Never remove old entries; append new rows.

## Incident Ledger

| Date | PR/Issue | Scope | Root Cause | Guardrail Added | Verification |
| --- | --- | --- | --- | --- | --- |
| 2026-02-21 | bootstrap | factory-governance | Initial activation of factory councils and runtime guards | Added CI councils, runtime guard, and memory governance gate | `Factory Gates` required in PR checks |
