---
name: implement
description: Implement one ready ticket or a direct specified request. Use when a packet, accepted issue, or already-specified user request is ready to code. Does not groom the queue, dispatch siblings, or run review. Use when the user runs /implement.
---

# Implement one unit of work

Take a ready packet (or a direct, already-specified request) and produce a candidate that can be reviewed. This is the worker `$backlog-loop` dispatches. It is not the old all-in-one `backlog` skill: it does not rank the queue, claim sibling scopes, or run the review protocol.

Load the tracker from [`.agents/binding`](../../references/load-binding.md) before any tracker verb.

## Say the tier, then run only that tier

Name the tier in the first message about the change.

| Tier | What it is | Process |
|------|-----------|---------|
| **1 — trivial** | prose, comments, a rename with no behaviour change | no contract, no packet. Run the gate stage the change touches. |
| **2 — ordinary** | a bounded code change with a clear approach and a test that fails before it | a short [contract](../../references/solution-contract.md), gate stages the scope touches, then `$review`. |
| **3 — risky** | authority, credentials, persistence, wire formats, concurrency, release, or data loss | full contract, production-boundary regression, `$review` of the candidate that will land. Include the [shape questions](../../references/engineering-judgment.md) when the durable record changes. |

A tier is blast radius, not diff size. When two look defensible, pick the lower one and say why. If the diff grows into a higher tier, say so and raise it.

## Direct request vs backlog wrapper

A direct, already-specified user request skips issue and claim ceremony; the request plus a short plan is the contract.

When the [backlog wrapper](../../references/issue-readiness.md) is active: confirm readiness, write the contract on the item, emit a [claim](../../references/work-claims.md) with `.agents/scripts/emit_claim.py` and post it, use `.agents/scripts/issue_worktree.sh`, then implement. Preserve unrelated work. Hard-won coordination rules live with the claim protocol.

## Implement, prove, compress

Implement the accepted outcome only. Add outcome-appropriate proof: fail-before/pass-after at the visible boundary for a defect; equivalence, integration, and dependency-boundary proof for a refactor; reachability plus tests for a deletion; a usable downstream seam for enabling work. Follow [execution efficiency](../../references/execution-efficiency.md): short handoffs, no recap, do not open the review protocol. Isolate with `.agents/scripts/issue_worktree.sh add <n>`. Cheap-model preflight is in the [task packet](../../references/task-packet.md).

If the outcome, scope, or authority is still unclear, return to specification. If an external dependency blocks progress, name it. If evidence shows the outcome cannot be delivered under accepted constraints, record that rather than accumulating ceremony.

Before `$review`, compress: remove duplication, speculative abstractions, and tests that merely mirror the implementation. Prefer a coherent result over a mechanically small diff. Do not [flatten a named seam](../../references/engineering-judgment.md). Incidental dead code becomes its own deletion ticket; it does not widen this change.

If this outcome **requires** a refactor or a migration, do not mix it with the feature. Stack: tests that pin behavior, then the refactor/migration, then the feature. Each lands. Staged replacements use create / switch / delete with an owner and removal trigger. Boy scout cleanup that the feature does not need is a later ticket.

## Hand off

Do not merge because the tests are green. `$review` is the only skill that lands. Report the exact commit, gates, remaining risks, and next action. Sibling coordination belongs to `$coordinate`.
