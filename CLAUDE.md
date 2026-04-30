# RAVE — Reliability & Validation Engineering

RAVE is an open-source, claim-centric framework for making reliability explicit, falsifiable, and continuously validated. Teams define structured reliability claims, link them to machine-referenceable evidence, and track confidence scores that decay over time. When evidence goes stale or a falsifier fires, confidence drops — making silent reliability failures visible before they become incidents.

## Core Principles

1. **Reliability is a claim, not a metric.** Every reliability statement is falsifiable, scoped, and evidence-linked — not a dashboard number.
2. **Working in public.** All repos are open source. Development happens visibly; the community can follow, fork, and contribute.
3. **Spec first.** The RAVE specification is the source of truth. Implementations follow the spec, not the other way around.
4. **One tool, one job.** `rave-cli` and `ravegraph` are interfaces to the same data store — they do not duplicate logic.
5. **Automation is a first-class citizen.** `rave-swamp` is not a demo — it is a production reliability layer that governs itself.

## Architecture Overview

The RAVE system has four layers:

- **Specification** (`rave-spec`) — defines the data model, semantics, and protocol
- **Runtime** (shared SQLite) — persists claims, evidence, confidence scores, and falsifier state
- **Interfaces** (`rave-cli`, `ravegraph`) — CLI and web UI over the shared runtime
- **Automation** (`rave-swamp`) — continuous evidence gathering, confidence decay, and falsifier evaluation via Swamp

See [`docs/architecture/L1-system-context.md`](docs/architecture/L1-system-context.md) and [`docs/architecture/L2-containers.md`](docs/architecture/L2-containers.md).

## Repos

| Repo | Description |
|---|---|
| [`rave-spec`](https://github.com/mesgme/rave-spec) | The RAVE specification — data model, semantics, YAML examples |
| [`rave-cli`](https://github.com/mesgme/rave-cli) | CLI for managing claims, evidence, scopes, and readiness |
| [`ravegraph`](https://github.com/mesgme/ravegraph) | Web scorecard — claim listing, confidence visualisation, claim creation |
| [`rave-swamp`](https://github.com/mesgme/rave-swamp) | RAVE applied to itself; canonical automation pattern using Swamp |

## Development Standards

See [`docs/conventions.md`](docs/conventions.md).

## Before Pushing

Run these checks locally and fix all failures before opening a PR.

**rave-cli**
```bash
npm run lint
npm run build
npm test
```

**ravegraph**
```bash
npm run lint
npm run build
npm test
npx playwright test   # e2e — run against a local dev server
```

**rave-swamp**
```bash
deno fmt --check extensions/models/
deno lint extensions/models/
deno check extensions/models/*.ts
deno task dashboard:test
swamp extension validate   # validate manifest before push
```

**rave-spec**
No build step. Ensure YAML examples parse cleanly against the spec schema before merging.

## Readiness Gate

`rave-swamp` provides a machine-readable readiness signal. Agents must check readiness before reliability-sensitive operations (deployments, releases, infrastructure changes):

```bash
# Check readiness for a scope — exits 0=ready, 1=not-ready, 2=error
rave swamp gate <scope>

# Or via Swamp directly
swamp workflow run readiness-check --json
swamp data get readiness-reporter-001 latest --json
```

A scope is ready when no active claims are contradicted and all claims have `confidence_score >= 0.70`. See [`docs/conventions.md`](docs/conventions.md#agent-feedback-loop) for the full agent feedback loop pattern.

## Commands

```bash
# Cross-repo orchestration (from workspace root)
make get      # Clone all repos
make status   # Git status across all repos
make build    # Build all projects
make test     # Test all projects

# Per-repo dev
npm run dev     # ravegraph local dev server
swamp --help    # rave-swamp
```
