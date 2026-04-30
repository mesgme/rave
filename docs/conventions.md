# RAVE Development Conventions

## Language & Runtime

- **Language:** TypeScript 5.x throughout
- **Runtime:** Node.js 22+ (`rave-cli`, `ravegraph`), Deno 1.43+ (`rave-swamp`)
- **Package manager:** npm (Node.js projects), Deno native (`rave-swamp`)
- **Formatter/linter:** ESLint + Prettier (`rave-cli`, `ravegraph`); `deno fmt` + `deno lint` (`rave-swamp`)
- **Validation:** Zod in every project — no raw unvalidated inputs cross a boundary

## Directory Structure

### rave-cli, ravegraph

```
src/
  domain/        # Entities, value objects, pure domain logic
  adapters/      # Repository implementations, external service clients
  service/       # Use cases, orchestration
  entrypoints/   # CLI commands, Next.js routes/pages
  db/            # Drizzle schema and migrations
tests/
  unit/          # Fast, isolated — no I/O
  integration/   # Real adapters (real SQLite, real filesystem)
  e2e/           # Full system (Playwright for ravegraph)
```

### rave-swamp

```
rave/
  claims/        # Claim YAML (git-tracked source of truth)
  evidence/      # Evidence methodology config
  falsifiers/    # Falsifier condition definitions
  scopes/        # Scope hierarchy
  incidents/     # Machine-written incident records
extensions/
  models/        # TypeScript Swamp extension models
workflows/       # YAML automation workflows
```

## Naming Conventions

- **Files:** `kebab-case.ts` for modules, `PascalCase.ts` for classes
- **Functions/variables:** `camelCase`
- **Types/interfaces:** `PascalCase`
- **Database tables:** `snake_case`
- **YAML claim IDs:** `claim-<scope>-<description>-<sequence>` (e.g. `claim-branch-protection-001`)
- **Swamp model types:** `rave/<noun>` (e.g. `rave/claim`, `rave/confidence-engine`)

## Testing

- **Unit tests required** for all domain logic and service layer
- **Integration tests required** for all adapters (use real SQLite, not mocks)
- **E2E tests required** for ravegraph golden paths (Playwright)
- Test files live alongside source or in `tests/` — be consistent within a repo
- No test skips without a comment explaining why

## Git Workflow

- **Never push directly to main** — all changes via PR
- **Always use worktrees** for feature branches — never switch branches in the main worktree
- **Never merge PRs** — create and leave merging to the maintainer
- Commit author for AI-assisted commits: `Claude Code <claude-code@anthropic.com>`
- Worktree naming: `../<repo>-<feature>` with branch `feature/<feature-name>`

```bash
git worktree add ../<repo>-<feature> -b feature/<feature-name>
# work, commit, push, open PR
git worktree remove ../<repo>-<feature>
```

## Error Handling

- Validate at system boundaries (user input, external APIs, file reads) — trust internal guarantees
- Propagate errors explicitly — no swallowed exceptions
- In CLI: print a human-readable message and exit non-zero; never stack traces to end users
- In ravegraph: return structured error responses; log server-side

## GitHub Issues

- Apply the `planned` label immediately when an issue contains an implementation plan
- Close issues after the implementing PR merges — do not leave them open

## Agent Feedback Loop

`rave-swamp` is designed to be queried by agents as part of change workflows. The intended loop is:

1. **Check readiness before starting** — confirm the scope is in a good state before making changes
2. **Make the change** — implement, test locally (see CI checks below), open PR
3. **Merge triggers evidence gathering** — CI evidence is gathered automatically post-merge
4. **Re-check readiness** — confidence scores update; the agent can verify the change didn't degrade reliability

```bash
# Step 1: Check readiness
swamp data get readiness-reporter-001 latest --json
# or: rave swamp gate <scope>   (exits 0=ready, 1=not-ready)

# Step 3: After merge, trigger evidence refresh
swamp workflow run gather-all-evidence

# Step 4: Re-check
swamp workflow run readiness-check --json
```

**Confidence threshold for proceed/abort:** `>= 0.70` (default). Claims below this threshold or in `contradicted` state mean the scope is not ready — the agent should surface the issue rather than proceed.

**Agents must not bypass a not-ready gate** by retrying with a lower threshold or skipping the check. If the gate is failing, investigate the underlying claim, do not work around it.

## Swamp Extension Rules

See `rave-swamp/CLAUDE.md` for Swamp-specific rules (extension models, CEL expressions, destructive operation verification).
