---
name: backlog-loop
description: Continuously triage the backlog and replenish a bounded pool of harness-native workers on eligible tickets using a dependency poset. Use when asked to work through the backlog, keep workers busy, or run the autonomous ticket loop. Use when the user runs /backlog-loop.
---

# Autonomous backlog coordinator

Use this skill when asked to work through the backlog or keep multiple ticket workers busy. Invoke `$backlog-grooming`, then delegate each selected packet to `$implement-ticket` through the current harness's native subagent mechanism.

Default tracker: [GitHub Issues](../../bindings/github.md). Pyramid: [pyr binding](../../bindings/pyramid.md). Pool mechanics: [parallel coordination](../../references/parallel-coordination.md).

Maintain at most the requested worker count. Dispatch eligible, ready, non-overlapping tickets until full. As soon as any worker finishes, record its result, release or hand off its claim, refresh the item/poset state, and dispatch the next eligible ticket immediately. Dependency waves are ordering constraints, not barriers.

On GitHub, `scripts/ticket_poset.py --workers N --format json` produces the waves; combine with `scripts/ticket_triage.py` for scores and readiness. On Pyramid, `pyr ready --json` is that report — do not invent scores.

Every delegation packet includes the ticket, accepted outcome, tier, provider/model lane, base revision, worktree, allowed and prohibited scope, proof/gates, and handoff format from [task-packet.md](../../references/task-packet.md). Use the native mechanism for the active harness. Preserve the packet fields and report the provider/model actually selected. If the harness cannot select the requested lane, report that instead of silently substituting the primary model.

Machine-local constraints (browser suites serialized, one writer of a given store, worktree helpers that wire `node_modules`) belong in the consuming repo's `AGENTS.md`. This skill will not guess them.

Stop when the user-requested budget is exhausted, no eligible work remains, or authority, safety, claim, dependency, or scope decisions require the user. Do not merge or close items merely because a worker reports success. `$implement-ticket` owns each individual ticket lifecycle; this skill owns selection, dispatch, replenishment, and coordinator reporting.
