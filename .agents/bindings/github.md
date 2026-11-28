# Binding: GitHub Issues (default)

The kernel's default tracker is GitHub Issues, with pull requests as the review and land surface, and `work-claim:v1` comments as the lock.

Skills speak this binding when `.agents/binding` sets `tracker: github` (the default). See [load-binding.md](../references/load-binding.md).

## Mapping

| Kernel | GitHub |
| --- | --- |
| item | Issue |
| claim | Issue comment containing `work-claim:v1` ([work-claims.md](../references/work-claims.md)) |
| blocker | Native `blocked-by` edge ([write path](#blocked-by-edges)), not a sentence in the body |
| score | Four-axis formula recorded in the issue body or a maintainer comment ([queue.md](../references/queue.md)) |
| ready | Acceptance criteria + owner present; delegated work also names repo, base SHA, authority |
| packet | Posted on the issue or handed to a worker; not a substitute for the issue |
| land | `gh pr merge --squash`. The squash message carries the reviewed tip SHA and, for a fix, the base revision and both outcomes. Distinct features are not combined into one squash. |

When a consuming repository opts into [boundary-load evidence](../references/boundary-load.md), post or link the separate `software-factory/boundary-load-evidence/v1` JSON from the terminal issue comment or pull request. Do not place it inside `work-claim:v1`; ownership parsers must remain unaffected. The emitter reports locally and never posts by itself.

## Scripts

- `.agents/scripts/ticket_poset.py` reads open issues and native `blockedBy` edges, prints dependency waves. Pass `--repo owner/name` (defaults to `gh repo view`).
- `.agents/scripts/ticket_triage.py` reads a JSON issue export, prints scores, `NEEDS_SPECIFICATION`, and declared-scope conflicts.

Both report. Neither claims, assigns, comments, or merges.

## Blocked-by edges

`ticket_poset.py` reads native `blockedBy` relationships. A sentence in the issue body such as "blocked by #N" is not an edge.

This `gh` has no `--blocked-by` or `--add-blocked-by` (`gh issue create --help`, `gh issue edit --help`). Do not invent those flags. Add and remove edges with GraphQL. `issueId` is the blocked issue; `blockingIssueId` is the issue it waits on:

```sh
gh api graphql -f query='
mutation($issueId:ID!, $blockingIssueId:ID!) {
  addBlockedBy(input: {issueId: $issueId, blockingIssueId: $blockingIssueId}) {
    issue { number }
    blockingIssue { number }
  }
}' -f issueId=BLOCKED_NODE_ID -f blockingIssueId=BLOCKER_NODE_ID

gh api graphql -f query='
mutation($issueId:ID!, $blockingIssueId:ID!) {
  removeBlockedBy(input: {issueId: $issueId, blockingIssueId: $blockingIssueId}) {
    issue { number }
    blockingIssue { number }
  }
}' -f issueId=BLOCKED_NODE_ID -f blockingIssueId=BLOCKER_NODE_ID
```

Resolve a number to a node ID first:

```sh
gh api graphql -f query='
query($owner:String!, $name:String!, $number:Int!) {
  repository(owner:$owner, name:$name) { issue(number:$number) { id } }
}' -F owner=OWNER -F name=REPO -F number=N
```

## Land rule

Review the candidate that will land. GitHub's squash button rewrites SHAs; that is acceptable here because the issue and the squash message record the reviewed tip, and a later regression is fixed forward. Do not require a ritual rebase solely to reproduce a SHA.

If a consuming repo treats commit identity as evidence (see [pyramid.md](pyramid.md)), it must not use this land rule.

GitHub's native [Stacked Pull Requests](https://docs.github.com/en/pull-requests/get-started/about-stacked-prs) feature auto-retargets the next PR in a stack on merge — but only when the PRs are backed by that formal stack (created via its own tooling; merging one through the ordinary REST/CLI merge path errors, asking for the async stack-merge API instead). An ordinary pull request whose `--base` simply happens to be another branch is not that — `gh pr create --base <branch>`, which is what a coordinator or `$implement` worker normally does, never creates a formal stack. `gh pr merge --delete-branch` deletes the head branch immediately, and for an ordinary (non-formal-stack) base relationship GitHub does not retarget the dependent pull request to the default branch — it closes it, irrecoverably. Land or retarget every dependent pull request before deleting a branch anything else is based on; see [work-claims.md](../references/work-claims.md#workspace-cleanup).

**Check the target before every merge, and the result after it.** GitHub merges a pull request into whatever its base branch currently is, and it reports success. When a stacked parent has landed but its branch was kept, the dependent pull request still targets the parent's leftover branch. Merging it then lands nothing on the default branch.
- **Before merging:** confirm that `gh pr view <n> --json baseRefName` is the default branch (or the integration branch the land intends). If the base is another pull request's branch and that pull request has merged, retarget first with `gh pr edit <n> --base <default>`. Then confirm the reviewed tip is unchanged and the merge is still clean.
- **After merging:** fetch, and confirm `gh pr view <n> --json state,mergeCommit` shows `MERGED` and that `mergeCommit.oid` is an ancestor of `origin/<default>`. With this binding's squash land, the reviewed tip itself never reaches the default branch. Instead, confirm the squash commit's tree equals the tree that was verified. A repository that lands with merge commits or fast-forward can also confirm `git merge-base --is-ancestor <reviewed tip> origin/<default>`. When several pull requests land together after a combined verification, confirm that `origin/<default>^{tree}` equals the verified tree.
- **If either check fails, stop landing.** Restore the verified state forward, for example by opening a pull request from the same unchanged head against the default branch. Don't rewrite history.

## Publishing boundary

Creating, editing, labeling, or commenting on GitHub is an external mutation and requires the user's explicit confirmation of the prepared artifact, except where the user already authorized the backlog loop to claim and comment as part of dispatch.
