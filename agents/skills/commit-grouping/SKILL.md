---
name: commit-grouping
description: >-
  Shape a branch's commits into a clean reviewable sequence. Use for any request
  to commit accumulated work, and when folding fixups, amending, rebasing a
  topic branch, or preparing history before opening a pull request.
---
# Commit grouping

The PR is the delivery envelope; commits are the durable units inside it. Before implementation, write the intended final log in dependency order.

1. **Group by purpose, not chronology or file type.** One coherent change plus the docs, tests, and config that complete it. No separate "add tests" or "update docs" commits when those edits only support an implementation commit.
2. **Isolate durable planning when it stands alone.** A plan or ADR may form a documentation commit before implementation when it establishes a contract worth reviewing and citing independently.
3. **Name the PR and branch for the shared outcome.** If scope expands but stays one coherent outcome, broaden the framing. If commits no longer share a review context, split the work.
4. **Treat corrective commits as temporary unless they stand alone.** Amend the tip, or use `fixup!` and fold before opening the PR.
5. **Review the history as a deliverable.** Every subject must explain a complete concern without words like "follow-up", "review fixes", or "cleanup".

## Mandatory pre-staging gate

Before staging accumulated work:

1. Read the applicable repo instructions and identify land-alone changes.
2. Inventory each distinct user-requested outcome represented in the diff.
3. Map every outcome to exactly one proposed commit and PR.
4. Apply the PR-strategy rules when there is more than one outcome or any migration, auth change, hotfix, or independently revertible change.
5. State the proposed final log and PR split before staging. Do not proceed while an outcome is unassigned or a commit contains unrelated outcomes.

Reconsider the grouping when a subject needs "and", "cleanup", "workflows", or "improvements" to describe distinct outcomes; when one commit spans multiple user requests; or when reverting one concern would revert unrelated behavior.

A shared manifest, registry, changelog, or test file is not a reason to combine concerns. Stage its individual hunks with their owning commits. Every intermediate commit must reference only files present in that commit and leave the repository valid.

## Folding corrections

```bash
# Correction belongs to the current tip
git add <files>
git commit --amend --no-edit

# Correction belongs to an earlier commit
git add <files>
git commit --fixup <owning-commit>
GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <integration-branch>
```

## Verify after any rewrite

```bash
git status -sb
git log --reverse --oneline <integration-branch>..HEAD
git show --stat <commit>
git diff --check <integration-branch>...HEAD
```

Rewrite only private branch history. Never rewrite commits already merged into the integration branch. Coordinate before rewriting shared history and use `--force-with-lease`, never `--force`.
