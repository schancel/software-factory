---
name: coordinate
description: Coordinate implementation with solution contracts, exclusive work claims, isolated worktrees, task packets, and a replenishing worker pool. Use when running parallel workers, locking file or semantic scope, writing an implementation contract, or integrating sibling changes. Use when the user runs /coordinate.
---

# Coordination

Deliver the smallest coherent change that satisfies the accepted outcome while keeping independently evolving subsystems understandable in bounded context. This workflow is model-neutral: use the runtime's available delegation and workspace-isolation facilities without depending on vendor-specific agent names.

Use this skill for production code, executable prototypes, or delegated implementation. Skip ordinary research and lightweight prose edits. A single backlog item with no siblings goes to `$implement`; load this when two or more workstreams, or an integration owner distinct from the workers, are in play.

## Establish the work boundary

Read `AGENTS.md` and only the design or subsystem material relevant to the requested outcome. Before production code, record a compact [solution contract](../../references/solution-contract.md). A direct, well-specified request may serve as most of that contract; do not invent tracker ceremony.

Do not begin implementation until the outcome, non-goals, affected authority, acceptance evidence, repository, exact base revision, and dependencies are sufficiently explicit. When the durable record changes, the contract includes the [cost-of-reversal](../../references/engineering-judgment.md) answers. New product decisions go through the responsible human; a worker or test result cannot manufacture authority.

Record ownership with the [work-claim protocol](../../references/work-claims.md) mapped by the repo's [binding](../../bindings/github.md).

## Decompose for bounded context

Use [parallel coordination](../../references/parallel-coordination.md) when two or more independently testable workstreams can proceed without concurrent ownership of the same files or semantic boundary. Keep work local when decomposition would add more interface negotiation than useful isolation.

The coordinator owns decomposition, shared interface decisions, dependency order, collision checks, integration, and completion evidence. Each delegated worker receives a [task packet](../../references/task-packet.md) with exclusive scope and returns a narrow handoff. Workers must not silently expand across another worker's subsystem or integrate sibling work themselves unless their packet grants that role.

Prefer cohesive subsystems with narrow facades, private internals, explicit dependency direction, co-located tests, and boundary-level integration proof. Do not create generic abstractions merely to manufacture parallel tasks.

## Implement, review, integrate

Implement narrowly and preserve unrelated work. For a defect, demonstrate fail-before and pass-after at the boundary where it was visible. For new behavior, prove the promised downstream seam or user loop. For persistence, authority, concurrency, or migration behavior, include deterministic failure and recovery cases.

Before review, compress the result without [flattening a named seam](../../references/engineering-judgment.md). Use `$review` when its risk triggers apply. Review a frozen candidate, repair confirmed findings, and run a fresh review of material repairs.

The integration owner verifies interface compatibility, combines work in dependency order, runs affected unit and boundary tests, and checks the resulting revision. Worker commits are handoff artifacts: squash each accepted feature or fix into its own commit and apply those commits linearly. Land per the binding. Completion means the integrated result satisfies the contract. Parallel workers finishing their local scopes is not completion by itself.
