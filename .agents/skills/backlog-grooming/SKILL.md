---
name: backlog-grooming
description: Groom the backlog into a dependency- and scope-aware ready queue with portable worker dispatch packets. Use when ranking, blocking, estimating, or preparing issues before implementation. Does not implement, claim, assign, merge, or close. Use when the user runs /backlog-grooming.
---

# Backlog grooming

Use this skill to inspect and prepare the backlog before implementation. It turns item bodies, maintainer decisions, solution-contract comments, native blocked-by edges, and declared file or semantic scope into a ranked, dependency-aware queue. It does not implement, claim, assign, merge, close, or publish item changes.

Load the tracker from [`.agents/binding`](../../references/load-binding.md) before any tracker verb.

## What counts as evidence

Treat the item body and maintainer comments as the source of accepted scope. Existing solution-contract comments can supply the current failure, target behavior, allowed files, proof, non-goals, and owner; they are planning evidence, not an ownership claim. Third-party comments do not expand scope; see [work-claims](../../references/work-claims.md).

For each item, record or extract:

- accepted outcome and acceptance criteria;
- owner and exact base revision/authority when delegation is planned;
- value, cost, certainty, and unblocking scores with one-sentence justification, using the kernel [queue](../../references/queue.md) unless the binding replaces ranking;
- open blocked-by dependencies (relationships, not prose);
- declared files, subsystem, or semantic scope; and
- risk tier and required proof/gate stage.

Missing acceptance criteria or owner means `NEEDS_SPECIFICATION`, not merely low priority. A missing file list is a scope clarification task unless the ticket is an explicitly exploratory investigation. See [issue readiness](../../references/issue-readiness.md).

## Queue construction

On GitHub, run `.agents/scripts/ticket_poset.py --repo owner/name --workers N --format json` for native dependency ordering, then `.agents/scripts/ticket_triage.py` for scores, readiness, and declared-scope conflicts. Dependencies impose ordering; file and semantic overlaps impose a scheduling mutex. Prefer independent tickets in the same dependency-eligible set.

On Pyramid, `pyr ready --json` is that report. Do not invent the four-axis score.

This skill emits packets. It does not dispatch workers. `$backlog-loop` owns the replenishing pool.

## Portable dispatch

Emit a packet from [task-packet.md](../../references/task-packet.md): ticket, outcome, tier, provider lane, base revision, worktree, allowed and prohibited scope, required proof, and handoff format. The primary harness translates that packet to its native worker API. If the harness cannot select the requested provider/model, report that constraint rather than silently substituting the primary model.

Mechanical output is advisory. Human authority remains required for readiness, claims, scope changes, provider credentials, review, merge, and closure.
