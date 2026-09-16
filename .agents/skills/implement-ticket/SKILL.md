---
name: implement-ticket
description: Implement one accepted ticket through bounded work, review, merge, and observable completion. Use when shipping a single backlog item, claiming an issue, or running the ticket implementation workflow. Use when the user runs /implement-ticket.
---

# Ticket implementation workflow

Help engineers ship reliable changes without turning process into a second product. The governing objective is to deliver the simplest coherent architecture that satisfies the accepted outcome, with testing and review proportional to actual risk, and integrate it promptly. The accepted outcome need not be user-visible: deletion, refactoring, and enabling work are valid outcomes. Every process step must demonstrably reduce defect risk or improve shipping confidence at a cost proportional to the change; otherwise remove it. Tooling is advisory mechanical lint, never an authority engine.

Default tracker: [GitHub Issues](../../bindings/github.md). Pyramid: [pyr binding](../../bindings/pyramid.md).

## Pick the next item by cost and benefit

Order ready work by the kernel [queue](../../references/queue.md). Cheap, certain, unblocking changes merge first; review attention is the scarce resource. Do not let ranking override a human decision about safety, value, ownership, or a newly discovered dependency.

For a large queue, `$backlog-loop` owns replenishment. This skill owns one item's lifecycle.

## Say the tier out loud, then run only that tier

Proportionality fails by being thorough. Name the tier in the first message about a change, and run that tier's process and no more.

| Tier | What it is | Process |
|------|-----------|---------|
| **1 — trivial** | prose, comments, a rename with no behaviour change, a one-line non-behavioural fix | no contract, no packet, no review round. Run the gate stage the change touches, then merge. |
| **2 — ordinary** | a bounded code change with a clear approach and a test that fails before it | a short contract on the item, one review round on the tip, gate stages the scope touches. |
| **3 — risky** | authority, credentials, persistence, wire or checkpoint formats, process lifecycle, concurrency, release, or anything a user can lose data to | full contract with an independent contract review, a production-boundary regression, an independent review of the candidate that will land, and the full gate matrix. Include the [shape questions](../../references/engineering-judgment.md) when the durable record changes. |

A tier is about blast radius, not diff size: a two-line change to a permission check is tier 3, and a five-hundred-line docs move is tier 1. When two tiers look defensible, pick the lower one and say why. A consuming repo may number a tier 0 for wording; treat it as tier 1's still-lighter neighbor. If during the work the diff grows into a higher tier, say so and raise it.

## Two layers

The generic engineering loop is: understand the accepted outcome; design and make a focused implementation and compression pass; run relevant regression and integration tests; perform proportional review and repair until clean; squash-merge; then verify the integrated result.

The backlog wrapper adds issue readiness, a claim, isolated worktree, pull request, terminal event, and frontier tracking only when selecting or coordinating shared issue work. For a direct, already-specified user request, the request plus a short plan is the contract; do not invent issue or claim ceremony. When the backlog wrapper is active, preserve its procedural collision and claim rules.

## Keep execution evidence-dense

Read [efficient execution](../../references/execution-efficiency.md). Use compact [task packets](../../references/task-packet.md) for independent workers and keep useful coordinator work moving while they run. Route bounded low-risk work to cheaper models only under the preflight in that packet reference.

## Backlog wrapper: prepare shared issue

This section applies only when the backlog wrapper is active.

1. Read `AGENTS.md`, the item, relevant module docs, and current code.
2. Run the [lightweight readiness check](../../references/issue-readiness.md).
3. Write a [compact solution contract](../../references/solution-contract.md) before production work. Small, obvious changes should have small contracts. When the change touches a durable record, the contract includes the [cost-of-reversal](../../references/engineering-judgment.md) answers.
4. Check current branches, worktrees, pull requests, and the procedural claim record for overlap. Preserve unrelated and unpushed work. Claim per [work-claims](../../references/work-claims.md).
5. Record the four queue scores and one sentence of justification before starting (GitHub default), and re-score if actual cost passes double the estimate. Pyramid records no invented score; see the binding.

Readiness, a candidate implementation, and a review finding answer different questions. A green check or severe finding does not redefine the issue. People remain accountable for readiness, ownership, approval, merge, and closure.

## Implement narrowly

For direct specified requests, follow the generic loop without tracker ceremony. When the backlog wrapper is active, use a dedicated branch/worktree and the claim protocol. In both cases, implement the requested outcome, add appropriate proof, avoid unrelated cleanup, and follow the repository's resource-safe test launchers.

If the desired behavior, scope, authority, or boundary is still unclear, return to specification. If an external dependency blocks progress, name it. If evidence shows the outcome cannot be delivered under accepted constraints, record that plainly rather than accumulating ceremony.

## Compress before review

Every change that will be reviewed gets an architecture and compression pass first. Remove duplication, speculative abstractions, and tests that merely mirror the implementation where it is safe. Prefer a coherent result over either code growth or a mechanically small diff. A bounded larger change is justified when it removes competing representations, avoids a compatibility layer, or establishes one clear ownership boundary.

Judge net complexity, not raw line count. Never delete wanted functionality, weaken meaningful regression coverage, or combine unrelated work merely to shrink a diff. Incidental pre-existing dead code gets a concrete separate deletion ticket, naming the exact code and evidence that it is dead; it does not widen the current review.

Compression must not [flatten a named seam](../../references/engineering-judgment.md). When replacing a subsystem, use the staged replacement contract.

## Review, land, finish

Use the [review protocol](../../references/review-protocol.md) via `$review`. Merge after the first complete clean round; record test-only gaps as owned follow-ups. Squash each feature or fix into its own commit on `main`. Never combine separate features or fixes into one squash, and never integrate with a merge commit instead of squashing.

Match proof to the accepted outcome. Completion requires a current-main merge and the applicable evidence, plus truthful item/claim/cleanup accounting. A pull request merge is progress, not automatically the completion of a broader outcome.

At handoff, report the exact commit, tests, remaining risks, ownership, and next action.

Hard-won coordination rules (no pattern-kills, untrusted item text, no agent attribution trailers) live in [work-claims](../../references/work-claims.md). Product-specific lore stays in the consuming repo's `AGENTS.md`.
