# Software factory — design

This is the kernel extracted from three repositories that each grew a factory around an agent. The skills in `.agents/skills/` are the product. This page records why they are shaped this way, so a later edit has something to disagree with.

## Problem

Agent generation is cheap relative to review. Left alone, a model takes the shortest path that satisfies the stated ticket: a local edit, a green test, a small diff. That path systematically under-invests in:

- encapsulation and a single home per fact;
- a data model that can accept a known next feature without a migration;
- bugs still open in the same area;
- splitting work so a reviewer can actually see it.

It also *over*-invests in the other direction: adapter interfaces for one caller, generic registries, compatibility layers with no owner. The factory already had a compression pass to fight that. Compression, without a cost-of-reversal test, will flatten a seam that was the whole point.

A second problem is duplication. Finch, Daybook, and Pyramid each maintain ticket-creation, triage, implement, autonomous-loop, contract, packet, claim, and review files that differ mainly in tracker verbs and a handful of machine-local gates. The generic loop was not written down once.

## Goals

- One generic loop a public post can link to.
- GitHub Issues as the default tracker, with bindings for others.
- Scoring on by default.
- Engineering judgment as a loaded reference, not a blog post nobody opens during a ticket.
- Product repos migrate later; this kernel ships first.

## Non-goals

- Rewiring Finch, Daybook, or Pyramid in the same change.
- A hosted service, MCP server, or new tracker.
- Encoding taste as hard rules ("always inject dependencies", "never duplicate three lines").
- Replacing a consuming repo's `AGENTS.md` lore.

## Architecture

```text
skills (invocable)          references (one home per fact)        bindings
─────────────────          ──────────────────────────────        ────────
ticket-creation            engineering-judgment.md               github.md   (default)
backlog-grooming           solution-contract.md                  pyramid.md
implement                  work-claims.md
backlog-loop               task-packet.md
coordinate                 review-protocol.md
review                     queue.md
codebase-audit             parallel-coordination.md
                           issue-readiness.md
                           execution-efficiency.md
                           factory-rationale.md
                           load-binding.md
```

A skill is a short orchestrator. If a fact appears in two skills, it does not belong in either; it belongs in `references/`. Bindings name tracker verbs and may replace the ranking function. They do not restate the loop.

### Why these seven skills

The legacy skill in the source repos was one page named `backlog` that grew intake, ranking, claims, review, and merge. It is **not** in this kernel. The factored pieces, plus two skills the factoring did not originally add:

| Skill | Job it owns | Job it refuses |
| --- | --- | --- |
| ticket-creation | Evidence-based item on the tracker | Implementation, claims, ranking |
| backlog-grooming | Readiness, scores, blockers, dispatch packets | Implementation, merge |
| backlog-loop | Replenishing pool over the poset | Merging because a worker said it was done |
| implement | One ready packet → a reviewable candidate | Queue policy, sibling coordination, review |
| coordinate | Exclusive scope, frozen interfaces, integration | Choosing *which* item |
| review | Perspectives, confirmation, split/stack, follow-ups | Implementing the original ticket |
| codebase-audit | Whole-tree shape, dead code, earned abstractions | Riding along on a bugfix |

`implement` is the thin worker that should have replaced `backlog` instead of leaving the mega-file behind. `codebase-audit` is the other addition: feature work never asks "is this module still reached?" and a bugfix review never sees the third copy of a pattern. `coordinate` exists because parallel work happens on a direct request, not only on a backlog item. Failure lore that explains *why* a step exists lives in [`factory-rationale.md`](.agents/references/factory-rationale.md) and is not loaded during ordinary issue work.

### Why judgment is not a skill

A skill that is not on the path of a ticket does not run. The cost-of-reversal test has to fire when the contract is written, when the candidate is reviewed, and when someone occasionally walks the tree. Those three skills load [`engineering-judgment.md`](.agents/references/engineering-judgment.md). There is no fourth "principles" skill.

## Key decisions

**Generic kernel first, migrate later.** Publishing a kernel nobody uses yet is cheaper than a three-repo cutover that has to be right on day one. The source repos keep their copies until this text is stable enough to point at.

**GitHub Issues is the default binding.** Two of the three source repos use it. Skills, scripts, and examples speak `gh` and claim comments. A non-GitHub tracker is a binding, not a fork.

**Scoring is kernel, ranking function is replaceable.** Default order is `(value × certainty × (1 + unblocking)) / cost` on 1–5 axes, recorded on the item. Review attention is the scarce resource that formula spends. A binding may substitute another scarce-resource function. Pyramid will, with *points* — internal currency so dependencies have a cost, the way a real economy does. Until that exists, the Pyramid binding must not invent the four-axis score the deployment does not store; it uses the domain frontier and leaves a hole for points.

**Review the candidate that will land.** GitHub squash-merge is allowed if the squash message carries the reviewed tip. A tracker that treats commit identity as evidence (Pyramid) fast-forwards `main` to that tip and does not squash after review.

**Proportionality.** Every process step must demonstrably reduce defect risk or improve shipping confidence at a cost proportional to the change; otherwise remove it. Tiers are about blast radius, not diff size.

**Tooling is advisory.** `ticket_poset.py` and `ticket_triage.py` report. They do not claim, assign, or close. People own those acts.

**Holes vs abstractions.** Leave the durable record shaped for a known next feature. Do not build the framework for a hypothetical caller. See engineering-judgment.

## Binding contract

A binding must map:

| Kernel concept | Required mapping |
| --- | --- |
| item | Durable record with title, body, acceptance criteria |
| claim | Exclusive ownership of file and semantic scope, with a terminal event |
| blocker | A relationship, not a note in prose |
| score / rank | Default four-axis formula, or a named substitute |
| ready | Acceptance criteria + owner + (for delegated work) repo, base revision, authority |
| packet | The fields in `task-packet.md` |
| land | The reviewed candidate becomes current `main`, one squash per feature or fix |

If the tracker cannot express blockers as edges, the binding says so and the poset script cannot be used as-is. Do not encode blockers only in prose; grooming will not see them.

## Scripts

| Script | Role |
| --- | --- |
| `.agents/scripts/ticket_poset.py` | GitHub `blockedBy` edges → dependency waves. Advisory. |
| `.agents/scripts/ticket_triage.py` | Scores, missing readiness fields, declared-scope conflicts. Advisory. |
| `.agents/scripts/issue_export.py` | Open issues → triage JSON (parses scores/files from the body). Advisory. |
| `.agents/scripts/emit_claim.py` | Prints a `work-claim:v1` comment body. Does not post. |
| `.agents/scripts/issue_worktree.sh` | Add/remove `.worktrees/issue-N`. Does not claim. |
| `.agents/scripts/test-skill-docs` | Mechanical lint that the kernel docs still encode the invariants. Advisory; confers no authority. |

Both are GitHub-binding helpers. A Pyramid deployment already computes a frontier (`pyr ready`); it does not run these.

## Adoption

Consuming repos **vendor** a snapshot. They run `install.sh <repo>` once (or copy `.agents/{skills,references,bindings,scripts}` and symlink `.claude/skills`), set `.agents/binding`, and then own the tree. Product-specific hard rules — language build mutexes, serialized browser suites, `pyr` verbs, scoring vs points — are local edits, not a fork of this git history.

Do not submodule. A live pointer to this kernel would fight the reason to copy: Finch, Daybook, and Pyramid already adapted the loop and must keep doing so. `install.sh` overlays and **three-way-merges** kernel text (including `SKILL.md`) using `.agents/.factory-base`. Dest-only skills are never deleted. `--force` takes the kernel file. Binding is unchanged unless `--tracker` is passed. Consuming repos should commit `.factory-base`.

## Open questions

None that block v1. Vendoring is decided.

## PR Plan

1. **Publish v1** — done (`schancel/software-factory`, MIT).
2. **Blog post** — out of repo.
3. **Vendor into Finch/Daybook** — copy the snapshot, delete the overlapping legacy skills, keep machine-local lore in `AGENTS.md`.
4. **Vendor into Pyramid** — same, with `tracker: pyramid` and the points hole. Depends on (3) only as a rehearsal, not on points existing.
