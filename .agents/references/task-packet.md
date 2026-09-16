# Implementation task packet

Give a collaborator enough context to act safely without making them reconstruct the project plan. Keep the packet proportional to the delegated change.

Send the packet, not the coordinator's conversation history. Include only the files, interfaces, base revision, constraints, and proof relevant to the worker's bounded scope. Do not assign duplicate investigations or overlapping file or semantic scopes. Ask for conclusions and actionable diagnostics, not raw exploration logs, and keep independent coordinator work moving.

## Minimum packet

- Item and accepted outcome, including whether it is user-facing, refactoring, deletion, or downstream-enabling work.
- Compact [solution contract](solution-contract.md) or equivalent accepted behavior.
- Repository, branch/worktree, starting commit, and exact allowed files.
- Dependencies, known risks, and work that must remain untouched.
- Required regression and outcome-appropriate proof: user-visible, equivalence/integration/dependency, reference/reachability plus tests, or usable downstream seam.
- For a staged replacement: current stage, integration switch, predecessor-deletion owner, immediate successor, temporary-coexistence removal trigger, and proof that closes the parent outcome.
- When architecture is in scope: subsystem facade, private internals, dependency direction, co-located context/tests, boundary integration checks, and the [shape questions](engineering-judgment.md) the worker must not collapse.
- Who owns implementation, review, integration, and unresolved decisions.
- Explicit permission or prohibition for edits, prototypes, external messages, push, merge, item closure, claim termination, and cleanup.
- Execution boundary: repository fixtures, temporary local state, loopback services, and any specifically authorized integrations; `repository-only` when the checkout and its tests suffice.
- Context boundary: start the worker without inherited conversation history (`fork_turns="none"` when available) unless a named dependency requires a small, explicit excerpt.
- Expected handoff: commit, changed files, **the gate matrix** (below), failures, residual risks, and next action.

The handoff does not repeat the item or pull-request history. Link durable evidence and report only the change, verification, remaining risk, ownership, and next action.

## Name a gate stage, never a recipe

A packet names `scripts/factory/gates <stage>` (or the consuming repo's equivalent) and any test filter. It does not recite which checker to run, in which order, with which wrapper: that recitation drifts from the scripts and is how two workers end up running different things and calling both green.

A handoff without its gate matrix is incomplete. List the stages the scope required and what each returned:

```text
gates docs   ok 3/3
gates arch   ok 4/4
gates test   ok 3/3 (filter: named::package)
gates ci     not run — no workflow or script change
```

A worker that touched a subsystem facade and never ran the architecture stage has not finished, whatever its summary says.

Authority comes from the responsible person or controlling instruction, not from this packet, a role name, a status label, review, or CI. Tooling is advisory mechanical lint, never an authority engine. When authority is unclear, say so and ask rather than manufacturing a proof structure.

Every process step must demonstrably reduce defect risk or improve shipping confidence at a cost proportional to the change; otherwise remove it. For a small local edit, the packet should be short. Add isolation, concurrency, rollout, or recovery detail only when the actual risk requires it.

## Cheap-model preflight for bounded low-risk work

A cheaper model may draft or implement a bounded, low-risk task when the packet could state the full contract in a page: explicit acceptance criteria already recorded on the item, no authority, credential, security, persistence, wire-format, concurrency, process-lifecycle, or release impact, and allowed files and proof named exactly. Suitable work is mechanical prose, comments, formatting, narrowly scoped test-only edits, and small flagged repairs.

Give that worker the same packet shape as any other. It must stop and escalate rather than improvise when it discovers a behavior change, an ambiguity, a failing pre-existing gate, a scope mismatch, or any higher-risk surface. The coordinator or designated reviewer still owns triage, acceptance, review, integration, and every external message. A cheap worker's success signal is never proof a ticket is safe or complete.
