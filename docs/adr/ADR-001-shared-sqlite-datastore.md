# ADR-001: Shared SQLite Data Store Between rave-cli and ravegraph

## Status: Accepted

## Context

`rave-cli` and `ravegraph` are two interfaces to the same RAVE runtime — one for terminal users, one for browser users. Both need to read and write claims, evidence results, confidence scores, and scope definitions. A decision was needed on whether each tool maintains its own database or both share a single data store.

## Decision

Both `rave-cli` and `ravegraph` read and write the same SQLite file. The schema is defined using Drizzle ORM and is logically owned by both repos. Migrations must be kept in sync across both.

## Consequences

**Good:**
- A claim created via CLI is immediately visible in the web UI, and vice versa
- No sync layer, no API between the two tools, no duplication of state
- SQLite is self-contained — no server to run, trivial to back up

**Bad:**
- Schema changes require coordinated migration across two repos — a source of friction
- If the repos diverge on schema, runtime conflicts will occur
- SQLite's single-writer constraint means concurrent writes from CLI and web server must be handled carefully (WAL mode recommended)

**Mitigation under consideration:**
If schema coordination becomes consistently painful, merging `rave-cli` and `ravegraph` into a single monorepo is the natural resolution — one schema, one migration history, two entry points. A GitHub issue tracks this option.
