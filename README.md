# Software factory

A portable set of coding skills for agent-assisted engineering: intake, contracts, claims, a scored dependency-aware queue, proportional review, and a periodic audit of the tree itself.

The leverage is not the model. Generation scales with spend; review and decision latency do not. These skills are the system around the agent — the part that decides what to work on, how to isolate it, what proof it owes, and when to stop.

They were extracted from three production repositories (Finch, which is public at [darwin-finch/finch](https://github.com/darwin-finch/finch); two private siblings) after each independently grew the same four artifacts: a solution contract, a task packet, a review protocol, and a work claim. This repository is the generic kernel. GitHub Issues is the default binding. Other trackers plug in as bindings; they do not fork the kernel.

Copy `.agents/` into a repository and point agents at it. Tooling here is advisory mechanical lint, never an authority engine. People remain accountable for readiness, ownership, approval, merge, and closure.

## The loop

```text
idea / bug
    │
    ▼
ticket-creation ──► backlog-grooming ──► backlog-loop
                         │                    │
                         │                    ▼
                         │                 implement
                         │                    │
                         │         coordinate (contracts, claims,
                         │          packets, isolated worktrees)
                         │                    │
                         │                    ▼
                         │                 review
                         │                    │
                         └── new tickets ◄────┘
                                              │
                                              ▼
                                       codebase-audit
                                       (occasionally)
```

| Skill | When to load it |
| --- | --- |
| [`ticket-creation`](.agents/skills/ticket-creation/SKILL.md) | Someone described a bug, regression, or improvement. Outcome is a ticket, not a patch. |
| [`backlog-grooming`](.agents/skills/backlog-grooming/SKILL.md) | Rank, block, and packetize the queue. Does not implement. |
| [`backlog-loop`](.agents/skills/backlog-loop/SKILL.md) | Keep a bounded pool of workers busy on the poset. |
| [`implement`](.agents/skills/implement/SKILL.md) | Code one ready packet or a direct specified request. Hands off to review. |
| [`coordinate`](.agents/skills/coordinate/SKILL.md) | Parallel workers, exclusive scope, frozen interfaces, integration ownership. |
| [`review`](.agents/skills/review/SKILL.md) | Multi-perspective review of the candidate that will land. May split, stack, or file follow-ups. |
| [`codebase-audit`](.agents/skills/codebase-audit/SKILL.md) | Occasional whole-tree look: dead code, missing seams, patterns that have earned an abstraction, modules nobody can hold in working memory. |

Shared facts live in [`.agents/references/`](.agents/references/). Skills point there. Do not restate them.

## Holes, not frameworks

Agents default to the shortest path that makes a test pass. The existing factory already fights *too much* process; it did not fight *the wrong shape*.

Two futures get confused:

- **An abstraction for a caller you do not have** (adapter interface, plugin registry, generic `Manager`) — wait until you have built the similar thing three times. [The rule of three](https://holdenrehg.com/blog/2021-09-20_rule-of-three) is a warning sign, not a law.
- **The shape of the durable record** (identity, cardinality, ownership, public format) — if this is wrong, the fix is a migration. Leave the hole now. A column you add later is cheap; a primary key you have to change is not.

The test is cost of reversal, not taste. It lives in one place: [`engineering-judgment.md`](.agents/references/engineering-judgment.md). The solution contract, the review, and the audit all load it. A principles file that nothing invokes does not fire.

Related: [Miller's number](https://schancel.github.io/2019-07-14-software-and-magic-number-seven.html) as a chunkability constraint, and [code review as editing](https://schancel.github.io/2019-07-14-code-reviews-incomplete-guide.html) rather than as a gate.

## Bindings

The kernel talks in *items, claims, contracts, packets, scores, and a frontier*. A binding names how those map onto a tracker.

| Binding | Tracker | Ranking |
| --- | --- | --- |
| [`github`](.agents/bindings/github.md) (default) | GitHub Issues + PR claim comments | `(value × certainty × (1 + unblocking)) / cost` |
| [`pyramid`](.agents/bindings/pyramid.md) | `pyr` on a live deployment | Domain-enforced frontier today; scarce *points* later, as internal cost accounting |

A consuming repo that is not on GitHub Issues records its binding in `AGENTS.md` (or `.agents/binding`) and substitutes verbs. It does not copy and edit the kernel.

Scoring is part of the kernel. A binding may replace the ranking function; it may not invent scores the tracker does not store, and it may not skip readiness. Pyramid's points are a different answer to the same problem — capacity as a scarce currency — not a reason to drop ranking from the default loop.

## Using this in another repository

```sh
# from the consuming repo
mkdir -p .agents
cp -R path/to/software-factory/.agents/skills \
      path/to/software-factory/.agents/references \
      path/to/software-factory/.agents/bindings \
      path/to/software-factory/.agents/scripts \
      .agents/
```

Then:

1. Keep GitHub Issues as the tracker, or name another binding in `AGENTS.md`.
2. Point `scripts/factory/gates` (or equivalent) at your real gate stages. Packets name a stage, never a recited command line.
3. Do not copy product-specific lore (a lookup that must not return zero, a `private/` tree, a `cfg` pitfall) into the kernel. That lore belongs in the consuming repo's `AGENTS.md`.

Finch, Daybook, and Pyramid still carry their own copies. They will thin to adapters after this kernel is something you would actually point a post at.

## What this is not

- Not an authority engine. Scripts report; they do not claim, merge, or close.
- Not a prompt pack for "write the feature." Intake, isolation, proof, and a merge gate are the product.
- Not IMPRD. The writing methodology is a sibling; the review skill is the same idea applied to a diff (independent perspectives, iterate to a stopping rule).
