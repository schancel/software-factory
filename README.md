# Software factory

After language models, writing the code stopped being the slow part. Deciding *what* to build, in what order, without two agents editing the same files, and without the model taking the shortest path that makes a test pass — that became the slow part.

The popular fix is a loop: one agent, one prompt file, persist via git, repeat until a completion promise fires. That is a good way to finish **one** well-specified job. It is a bad scheduler. It cannot say “these three are independent,” “those two share a semantic boundary,” or “do not start this until that lands.”

This repo is the other shape: a **work graph**. Tickets are nodes. Blockers are edges. Claims are locks. Each worker still runs a loop. The graph is what *schedules* the loops. Two laptops can share that graph if they share a tracker; the claim comment is a lock, not a distributed consensus protocol.

It is not an agent-runtime graph. Nodes here are work items, not prompt steps. There is no daemon and no new tracker. GitHub Issues is the default. The rest is markdown an agent already knows how to load, plus two small scripts that *report* a queue and do not claim, merge, or close anything.

## The bottleneck moved twice

Before LLMs, the scarce resource was **writing the code**. After them, it was humans: review, decisions, glue, noticing the bug. Generation scales with spend. Review does not.

In the repositories I run, spending the human hour *up front* — on tickets, contracts, and the shape of the data model — inverted that again. I can file well-scoped work faster than agents drain it. That is an observation from one person’s factory, not a study. The mechanism is not “remove the human.” It is that one hour of architecture now produces a graph many workers can consume, so the queue fills from intake and empties at generation speed.

I still pick the framework and the structure. I do not have to notice every crash, or type every “this should be an enum.” Filing is cheap. Landing is not free. A report is not a ready ticket. A pile of similar reports is a proposal until someone accepts what the node is allowed to mean.

## Shortest path is the default, and it is the wrong default for data

Left alone, a model ships the local edit that greens the test. Fine for a typo. Not fine for how you store the thing.

Two mistakes look like “thinking ahead” and are opposites:

**Overbuilding the code.** One call site, so the model invents a PluginManager “for later.” You have not needed it three times. Delete it. [Rule of three](https://holdenrehg.com/blog/2021-09-20_rule-of-three) — a warning, not a law.

**Underbuilding the data.** The product already talks about team invites next quarter, and the model stores `is_admin: true/false` on the user. Adding a column later is cheap. Changing what a row *means*, or what the primary key is, is a migration. Leave room in the *data* for the next thing you already know is coming. Do not build the unused framework.

Ask: *if this is wrong in six months, do we rename a function or rewrite the database?* That question lives in [`engineering-judgment.md`](.agents/references/engineering-judgment.md). The contract, the review, and an occasional audit load it. A principles file that nothing opens does not fire.

Related, from earlier and still the point: [working memory is about seven chunks](https://schancel.github.io/2019-07-14-software-and-magic-number-seven.html), and [a code review is an edit, not a gate](https://schancel.github.io/2019-07-14-code-reviews-incomplete-guide.html).

## How the graph runs

```text
report / idea ──┐
                ▼
          ticket-creation ──► backlog-grooming ──► backlog-loop
          (one item;              scores,           eligible work
           proposals are          blockers,         from the frontier
           not ready)             packets)
                ▲                                     │
                │                    pool sized by this machine:
                │                    cores, RAM, compile/test cost
                │                         ┌───────┼───────┐
                │                         ▼       ▼       ▼
                │                    implement implement implement …
                │                    (worktree)(worktree)(worktree)
                │                         └───────┬───────┘
                │                                 ▼
                │                    coordinate (siblings of one
                │                    outcome fan out the same way,
                │                    then join)
                │                                 ▼
                │                              review ──► land
                │                       (split / stack, or
                │                        file follow-ups) ──┐
                │                                           │
                └──── codebase-audit (occasionally) ────────┘
                      review follow-ups ─────────────────────┘
```

Eligible tickets (and siblings of one outcome) fan out to parallel `$implement` workers, each in its own worktree, then join for `$review`. How many at once is this laptop and this repo's tests, not a magic N. Audit and review do not ship code. They file tickets. Those re-enter at `ticket-creation`. Audit is not a step after every merge.

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
sh path/to/software-factory/install.sh --tracker pyramid /path/to/consuming-repo
```

`--tracker github` (default) or `pyramid` writes `.agents/binding`. Linear is not a tracker yet ([#17](https://github.com/schancel/software-factory/issues/17)). After install, edit that file if you picked wrong.

That **merges** `.agents/{skills,references,bindings,scripts}` into the dest: factory paths are added, dest-only skills (a food logger, a `cfg` mutex) stay. Existing files are left alone unless you pass `--force`, which overwrites kernel-owned paths only — it still does not delete dest-only names. `--force` does not overwrite `.agents/binding` unless you also pass `--tracker`. After that the copy is yours. Do not submodule this kernel.

Design notes, including why scoring is default and why one tracker uses a hole for scarce *points* instead, are in [`DESIGN.md`](DESIGN.md).

## What this is not

- Not a replacement for engineering. Architecture, framework choice, and what a ticket is allowed to mean stay human. Intake does not.
- Not a hosted factory, an MCP server, or a new Jira.
- Not a prompt pack for “write the feature.” Isolation, proof, and a merge gate are the product.
- Not authority. A green script is not permission to merge.

MIT. Extracted from production use, including public [Finch](https://github.com/darwin-finch/finch).
