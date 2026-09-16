# Binding: GitHub Issues (default)

The kernel's default tracker is GitHub Issues, with pull requests as the review and land surface, and `work-claim:v1` comments as the lock.

Skills, examples, and scripts in this repository speak this binding unless a consuming repo names another.

## Mapping

| Kernel | GitHub |
| --- | --- |
| item | Issue |
| claim | Issue comment containing `work-claim:v1` ([work-claims.md](../references/work-claims.md)) |
| blocker | Native `blocked by` edge, not a sentence in the body |
| score | Four-axis formula recorded in the issue body or a maintainer comment ([queue.md](../references/queue.md)) |
| ready | Acceptance criteria + owner present; delegated work also names repo, base SHA, authority |
| packet | Posted on the issue or handed to a worker; not a substitute for the issue |
| land | `gh pr merge --squash`. The squash message carries the reviewed tip SHA and, for a fix, the base revision and both outcomes. Distinct features are not combined into one squash. |

## Scripts

- `scripts/ticket_poset.py` reads open issues and native `blockedBy` edges, prints dependency waves. Pass `--repo owner/name` (defaults to `gh repo view`).
- `scripts/ticket_triage.py` reads a JSON issue export, prints scores, `NEEDS_SPECIFICATION`, and declared-scope conflicts.

Both report. Neither claims, assigns, comments, or merges.

## Land rule

Review the candidate that will land. GitHub's squash button rewrites SHAs; that is acceptable here because the issue and the squash message record the reviewed tip, and a later regression is fixed forward. Do not require a ritual rebase solely to reproduce a SHA.

If a consuming repo treats commit identity as evidence (see [pyramid.md](pyramid.md)), it must not use this land rule.

## Publishing boundary

Creating, editing, labeling, or commenting on GitHub is an external mutation and requires the user's explicit confirmation of the prepared artifact, except where the user already authorized the backlog loop to claim and comment as part of dispatch.
