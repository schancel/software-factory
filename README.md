# Software factory

After language models, writing the code stopped being the slow part. Deciding *what* to build, in what order, without two agents editing the same files, and without the model taking the shortest path that makes a test pass — that became the slow part.

The popular fix is a loop: one agent, one prompt file, persist via git, repeat until a completion promise fires. That is a good way to finish **one** well-specified job. It is a bad scheduler. It cannot say “these three are independent,” “those two share a semantic boundary,” or “do not start this until that lands.”

This repo is the other shape: a **work graph**. Tickets are nodes. Blockers are edges. Claims are locks. Each worker still runs a loop. The graph is what *schedules* the loops. Two laptops can share that graph if they share a tracker; the claim comment is a lock, not a distributed consensus protocol.

It is not an agent-runtime graph. Nodes here are work items, not prompt steps. There is no daemon and no new tracker. GitHub Issues is the default. The rest is markdown an agent already knows how to load, plus two small scripts that *report* a queue and do not claim, merge, or close anything.

## The bottleneck moved twice

Before LLMs, the scarce resource was production. After them, it was humans: review, decisions, glue, noticing the bug. Generation scales with spend. Review does not.

In the repositories I run, spending the human hour *up front* — on tickets, contracts, and the shape of the data model — inverted that again. I can file well-scoped work faster than agents drain it. That is an observation from one person’s factory, not a study. The mechanism is not “remove the human.” It is that one hour of architecture now produces a graph many workers can consume, so the queue fills from intake and empties at generation speed.

I still pick the framework and the structure. I do not have to notice every crash, or type every “this should be an enum.” Filing is cheap. Landing is not free. A report is not a ready ticket. A pile of similar reports is a proposal until someone accepts what the node is allowed to mean.

## Shortest path is the default, and it is the wrong default for data models

Left alone, a model ships the local edit that greens the test. That is correct for a typo. It is wrong for a schema, an identity, or a module boundary. The fix six months later is a migration, not a rename.

Two futures get confused:

- **A framework for a caller you do not have** — adapter interfaces, plugin registries, a `Manager` whose only job is to look like architecture. Wait until you have built the similar thing three times. [The rule of three](https://holdenrehg.com/blog/2021-09-20_rule-of-three) is a warning sign, not a law.
- **The shape of the durable record** — identity, cardinality, ownership, public format. If this is wrong, you migrate. Leave the hole now. A column you add later is cheap; a primary key you have to change is not.

The test is cost of reversal, not taste: *if this is wrong in six months, is the fix a local edit or a migration?* That question lives in one file, [`engineering-judgment.md`](.agents/references/engineering-judgment.md), and is loaded by the contract, the review, and an occasional whole-tree audit. A principles document that nothing invokes does not fire.

Related, from earlier and still the point: [working memory is about seven chunks](https://schancel.github.io/2019-07-14-software-and-magic-number-seven.html), and [a code review is an edit, not a gate](https://schancel.github.io/2019-07-14-code-reviews-incomplete-guide.html).

## How the graph runs

```text
report / idea
    │
    ▼
ticket-creation ──► backlog-grooming ──► backlog-loop
    (one item;          scores,             replenish N
     proposals are      blockers,           workers from
     not ready)         packets             the frontier)
                                              │
                                              ▼
                                          implement
                                              │
                         coordinate ──► isolated worktrees,
                         (siblings,     claims, frozen
                          contracts)    interfaces
                                              │
                                              ▼
                                           review
                                    (may split, stack,
                                     or file follow-ups)
                                              │
                                              ▼
                                      codebase-audit
                                       (occasionally)
```

| Skill | Owns | Refuses |
| --- | --- | --- |
| [`ticket-creation`](.agents/skills/ticket-creation/SKILL.md) | Evidence-based item on the tracker | Implementation |
| [`backlog-grooming`](.agents/skills/backlog-grooming/SKILL.md) | Readiness, scores, blockers, packets | Shipping |
| [`backlog-loop`](.agents/skills/backlog-loop/SKILL.md) | A bounded pool over the dependency graph | Merging because a worker said it was done |
| [`implement`](.agents/skills/implement/SKILL.md) | One ready packet → a reviewable candidate | Queue policy, review |
| [`coordinate`](.agents/skills/coordinate/SKILL.md) | Exclusive scope, frozen interfaces, sibling integration | Choosing *which* item |
| [`review`](.agents/skills/review/SKILL.md) | Perspectives, confirmation, split/stack | Implementing the original ticket |
| [`codebase-audit`](.agents/skills/codebase-audit/SKILL.md) | Whole-tree dead code, collapsed seams, earned abstractions | A refactor in place |

Ready work is scored, on the item, as `(value × certainty × (1 + unblocking)) / cost`. Cheap, certain, unblocking changes go first because **review attention is the scarce half of cost**. A missing owner or acceptance criteria is not “low priority”; it is not ready. Bugs in the same area outrank the feature that touches them.

Scripts under [`.agents/scripts/`](.agents/scripts/) print a dependency-ordered frontier and flag missing readiness fields. They do not assign work. People remain accountable for readiness, ownership, approval, merge, and closure.

The old all-in-one `backlog` skill is not here. It was doing five jobs, so agents loaded it for the wrong one.

## Use it

```sh
git clone https://github.com/schancel/software-factory
sh path/to/software-factory/install.sh /path/to/consuming-repo
```

That copies `.agents/{skills,references,bindings,scripts}`, writes `.agents/binding` if missing (`tracker: github`), and symlinks `.claude/skills` so Claude Code sees the same skills. Point agents at `.agents/skills/`. Change `.agents/binding` to use another tracker; do not fork the skills. Language-specific build mutexes, serialized test browsers, and other machine lore stay in *that* repo’s `AGENTS.md`.

Design notes, including why scoring is default and why one tracker uses a hole for scarce *points* instead, are in [`DESIGN.md`](DESIGN.md).

## What this is not

- Not a replacement for engineering. Architecture, framework choice, and what a ticket is allowed to mean stay human. Intake does not.
- Not a hosted factory, an MCP server, or a new Jira.
- Not a prompt pack for “write the feature.” Isolation, proof, and a merge gate are the product.
- Not authority. A green script is not permission to merge.

MIT. Extracted from production use, including public [Finch](https://github.com/darwin-finch/finch).
