# Efficient execution and evidence

Reduce context and tool-output cost without reducing engineering proof. Do not use hard token budgets that can truncate work, omit evidence, or change priorities.

## Prose

Write short. Do not recap the ticket, the packet, or the skill. Do not narrate tool calls or "I will now…". One sentence of status when a state changes; otherwise work silently until the handoff. Prefer a link to a durable record over quoting it.

A final handoff is: commit, gates, remaining risk, owner, next action. Nothing else.

## Load only the next step

Do not open a reference until the current step needs it. Tier 1 does not open the review protocol, the claim protocol, or engineering-judgment. `$implement` does not open the review protocol. `$review` opens protocol sections as needed (findings, convergence, land), not the file as a preamble.

Prefer [the scripts](../scripts/) over composing claim blocks, triage JSON, or worktree paths by hand.

## Bound discovery and command output

Search narrowly before opening a file and read only relevant ranges of large files. Bound command output and filter compiler or test output to result summaries and actionable failures. Never paste complete issue histories, CI logs, warning streams, diffs, or source files into conversation. Retain the exact failure, relevant state, and reproduction command needed to understand and repeat the problem.

## Preserve context durably

When an item or pull request exists, record accepted decisions, measurements, score changes, solution contracts, findings, and terminal status there. Keep those records understandable without chat history. Later sessions read the concise durable record instead of reconstructing exploration. This does not add issue or pull-request ceremony to a direct request.

## Parallelize bounded work

Parallelize independent tasks when that reduces elapsed time. Use the compact packet in [task packets](task-packet.md); do not delegate overlapping semantic or file scopes, duplicate an investigation, or send the whole conversation. Workers return findings and proof, not exploration logs. The coordinator continues useful independent work while workers run.

Use a [replenishing pool](parallel-coordination.md), not fixed waves.

## Test once at the narrowest sufficient level

Run the smallest relevant local gate first and broaden only when risk or repository rules require it. Do not rerun unchanged broad suites. Prefer `scripts/factory/gates` (or the consuming repo's equivalent), which should emit bounded summaries and actionable failure tails. Summarize successful tests by command and result count; on failure retain actionable diagnostics and suppress unrelated warnings. Check CI after meaningful intervals rather than polling frequently.

Efficiency never weakens fail-before/pass-after regression proof, production-boundary coverage, required gate stages, or risk-proportional review.
