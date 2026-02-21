# VoltAgent

VoltAgent is an open-source TypeScript framework for building and orchestrating AI agents.

## What is VoltAgent?

VoltAgent is a comprehensive framework that enables developers to build sophisticated AI agents with memory, tools, observability, and sub-agent capabilities. It provides direct AI SDK integration with comprehensive OpenTelemetry tracing built-in.

## Overview

- View [`docs/structure.md`](./docs/structure.md) for the repository structure and organization
- View [`docs/tooling.md`](./docs/tooling.md) for development tools and utilities
- View [`docs/testing.md`](./docs/testing.md) for testing guidelines and commands
- View [`docs/linting.md`](./docs/linting.md) for code formatting and linting

## Validating Changes

To validate your changes you can run the following commands:

```bash
pnpm test:all        # Run all tests
pnpm build:all       # Build all packages
pnpm lint            # Run linting checks
pnpm lint:fix        # Auto-fix linting issues
```

## Important Notes for AI Agents

1. **Always check existing patterns** before implementing new features
2. **Use the established registry patterns** for agent and tool management
3. **Maintain type safety** - this is a TypeScript-first codebase
4. **Follow the monorepo structure** - changes may impact multiple packages
5. **Test your changes** - ensure all tests pass before committing

## Autonomous Factory Additions (Applicable Now)

1. **Keep a strict project constitution** - keep this file concise and constraint-first; add new rules only after real review findings or incidents.
2. **Use deterministic completion gates** - treat work as complete only when changed scope passes lint, build, and relevant tests.
3. **Require a completion council before merge** - run focused checks for implementation quality, test/regression risks, and security/privacy risks.
4. **Maintain persistent engineering memory** - capture root causes, fixes, and guardrails for incidents so future agents reuse proven decisions.
5. **Orchestrate work in waves** - run small parallel batches, then synchronize and re-plan; avoid unbounded autonomous loops.
6. **Set hard run limits** - define max time, cost/token budget, and retry count for autonomous runs, and stop with a clear handoff when limits are reached.

## Gotchas

- **JSON.stringify** SHOULD NEVER BE USED, used the `safeStringify` function instead, imported from `@voltagent/internal`
