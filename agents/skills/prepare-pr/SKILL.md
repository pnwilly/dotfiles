---
name: prepare-pr
description: >-
  Prepare accumulated work for delivery when asked to commit, push, rebase, or
  open a pull request. Use before mutating git history so mixed concerns,
  migrations, and land-alone changes are split correctly.
---
# Prepare a pull request

Run the decision gates before touching the index or history. A request to commit or open a PR authorizes the requested git workflow, not an arbitrary grouping.

## 1. Establish constraints

Read the applicable repository instructions. Confirm the integration branch, current branch, working-tree ownership, merge style, and rules for changes that must land alone.

Inspect:

```bash
git status -sb
git diff --stat
git diff
git log --oneline --decorate -n 12
```

Preserve unrelated changes. Use an isolated worktree when the current checkout is dirty with work outside the requested delivery.

## 2. Inventory outcomes before staging

List every distinct user-requested outcome in the diff. Map each outcome to exactly one proposed commit and PR, including its implementation, tests, migration, docs, and config.

Use the PR-strategy rules whenever there is more than one outcome or any schema migration, auth change, hotfix, security change, or independently revertible concern. Use the commit-grouping rules to order the commits inside each PR.

Do not stage until the proposed final log and PR split have been stated. If the strategy requires multiple PRs but the user authorized only one, ask before opening additional PRs.

## 3. Reject false coupling

These do not justify combining concerns:

- touching the same source or test file;
- adding lines to the same manifest, registry, changelog, or patch list;
- being implemented in the same session;
- sharing a broad label such as Desk, UI, cleanup, workflow, or improvements.

Stage shared files by hunk with `git add -p` or an equivalent index patch. Each intermediate commit must be valid and may reference only files present in that commit.

Reconsider any commit subject that needs "and", "cleanup", "workflows", or "improvements" to cover distinct outcomes. Verify that reverting one commit would not remove unrelated behavior.

## 4. Execute and verify

Confirm the intended topic branch as a separate step before committing. Stage explicit paths or hunks, inspect the staged diff, and create the planned commits. Rebase only private history and use `--force-with-lease` when updating a previously pushed branch.

Before opening each PR, verify:

```bash
git status -sb
git log --reverse --oneline <integration-branch>..HEAD
git diff --check <integration-branch>...HEAD
git diff --stat <integration-branch>...HEAD
```

Open ready PRs unless the user requested drafts. Verify the published title and body after creation and remove injected attribution. Report uncommitted, unpushed, untested, or deliberately excluded work.

## Behavioral checks

- Several accumulated requests including a migration: isolate the migration PR and keep one commit per remaining concern.
- Two concerns add entries to one patch manifest: stage each entry with its own migration; do not combine the concerns.
- One feature spans backend, frontend, migration, and tests: keep those pieces together when they implement one revertible outcome.
- A proposed umbrella subject joins outcomes with "and": repeat the inventory and grouping review.
