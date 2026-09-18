---
name: post-landing
description: >-
  Post-merge cleanup, stale-reference scan, and the release decision. Use when
  the user says "landed", "merged", "PR is merged", or equivalent after a pull
  request, or asks to clean up a merged branch.
---
# Post-landing

Treat "landed" as an explicit request to run cleanup. Do not stop after only confirming the PR merged. Merge is not a release.

## 1. Clean up

```bash
git fetch --prune origin
gh pr view <number> --json state,mergedAt,mergeCommit,headRefName,baseRefName

git switch <integration-branch>
git merge --ff-only origin/<integration-branch>

git branch -D <topic-branch>   # or -d when rebase-merged and ancestors match
git push origin --delete <topic-branch>

git worktree list
# git worktree remove <path-to-landed-worktree>

git branch -r --merged origin/<integration-branch>
git branch -r --no-merged origin/<integration-branch>
# delete only remote topic branches confirmed merged; never the integration branch
git fetch --prune origin
```

- Preserve unrelated worktree changes. If unrelated local changes block switching or pulling, stop and name the blocking files.
- Squash-merged branches are not ancestors of the integration branch. After verifying the PR merged (or that `git diff <integration> <branch>` is empty), delete with `git branch -D`. Rebase-merged with matching ancestors needs only `git branch -d`.
- If the remote branch is already gone, say so and continue.

## 2. Scan before stopping

1. Grep for stale references to renamed identifiers across source, tests, and schema paths.
2. Run the repo's required validation. Report failures immediately.
3. Check for `TODO` / `FIXME` comments introduced in the landed diff.
4. Fix issues before the release decision unless they need user input.
5. If the integration branch accepts direct post-landing cleanup commits, commit fixes there; otherwise open a short fix branch and PR.

## 3. Release decision

Repo `AI.md` / `AGENTS.md` wins. Default when the repo does not define a tighter cadence:

- Version numbers track the **last git tag**. Do not bump version in feature PRs.
- If the user says **release**, **tag**, **ship**, **deploy**, or **tester**, follow the repo's release bookwork.
- If the user only says **landed**, do not ask to tag. Report last tag and commits on the integration branch since that tag, in one line.
- Suggest a ship only when unreleased work has **accumulated** (a handful of features, end of a working day, or something that will actually be installed or deployed) or the landed change is a production hotfix. Recommend one version for the whole batch, then wait for an explicit yes.
- A single merged PR is not accumulation. Do not ask.
- If no release is cut, say so in that one line. Do not turn it into a question.

## Published attribution

Never leave AI, assistant, or bot identity as the publisher of a GitHub Release or similar public artifact — GitHub shows the release author in its UI.

Prefer running release bookwork (version bump, annotated tag, `gh release create`) from a local session authenticated as the human account, not a cloud or bot session.

```bash
gh release view <tag> --json author --jq .author.login   # must be the human account
gh pr view <n> --json body --jq .body                    # no injected footers or tool branding
```

If the published author is a bot, delete the release (keep the git tag) and recreate it with the same notes as the human account. Do not rewrite already-pushed release commits to scrub trailers — fix publisher metadata by recreating. Fix PR body branding with `gh pr edit` immediately.
