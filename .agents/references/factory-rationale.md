# Why the loop exists

Read this only when changing the workflow itself. These safeguards answer failures that have already occurred; they are evidence for the policy, not steps to load during ordinary issue work.

| Observed failure | Preventive step |
| --- | --- |
| Two workers began the same issue after both saw it as free. | Publish and verify one immutable claim before editing shared issue work. |
| A regression passed because it ran only on the fixed tip. | Run it against an isolated base and the candidate, recording both results. |
| A replacement left an adapter and duplicate implementation indefinitely. | Name create/switch/delete stages, an owner and a removal trigger before review. |
| Repeated process reviews added ceremony without changing the patch. | Stop after the first clean risk-proportional review round. |
| A wording fix consumed a feature's process. | Name the tier and run only that tier. |
| A test-harness finding opened another product review round. | Record test-only gaps as follow-up work; they do not open another round. |
| Interesting work displaced a small fix blocking three pull requests. | Score ready work and take the highest return on review attention. |
| A model took the shortest path and painted over a known next feature. | Cost-of-reversal questions in the contract, a shape perspective in review, and an occasional whole-tree audit. |
| One all-in-one `backlog` skill was loaded for the wrong job. | Separate intake, grooming, dispatch, implement, coordinate, review, and audit. |
| Loop refilled from taste after READY was empty. | Eligible work is READY ∩ dependency-eligible ∩ no mutex; empty READY is stop even if NEEDS_SPECIFICATION remains. |
