---
description: Personal agent working agreements for commits, PRs, branches, and workflow across repositories
alwaysApply: true
applyTo: '**'
---

# Personal Agent Working Agreements

## Scope and precedence

- These are personal defaults for work across repositories and tools.
- Follow system, security, and permission requirements first.
- Explicit task instructions and repository-specific policies override these defaults.
- When a repository has `AI.md`, `AGENTS.md`, or equivalent, that file is the **repo contract** (merge style, CI facts, release mechanics, design/auth invariants, CI-backed text rules). This file is **session style** (how to group commits, batch PRs, land branches, attribute releases). On conflict, the repo contract wins.
- Do not paste repo-specific release scripts, CI tier lists, or product invariants here; cite the repo doc.
- When instructions conflict materially, identify the conflict before proceeding.
- Do not store repository facts, credentials, hostnames, or secrets in this file.

## Task preparation

- Read applicable repository instructions before making changes.
- Inspect the working tree, current branch, recent history, and relevant code first.
- Do not assume the repository is clean or that existing changes belong to the agent.
- Clarify scope only when uncertainty creates meaningful implementation or safety risk.
- Resolve ambiguous targets before acting. When a request names an element, page, or file indirectly, locate it in the codebase and confirm the match before editing. Ask when more than one candidate fits.
- Separate current work from explicitly deferred phases.

## Planning and decisions

- Plan substantial or cross-cutting work before implementation.
- Define scope, non-goals, dependencies, acceptance criteria, and validation.
- Record durable architectural decisions separately from temporary implementation details.
- Use an ADR when a decision will constrain future work or replace an earlier decision.
- Do not implement deferred work merely because the current design anticipates it.

## Branches and worktrees

- Use a pull request as the delivery envelope for several outcomes; the pull request delivers that branch's commits as one or several reviewable units.
- Start each unit of work from a freshly synced integration branch: fetch and fast-forward it, then create the topic branch from it. Re-sync before every unit of work when the integration branch may have advanced between tasks, for example when review merges land quickly and return the checkout to the integration branch.
- Confirm the working branch is the intended topic branch, not the integration branch, before editing or committing. Make this a separate step that halts the work when it fails; never chain it into the same command as the commit or push.
- When the repository's checkout or working tree may change underneath you (parallel sessions, automation, quick review merges, or unrelated uncommitted changes already present), do the unit of work in a dedicated git worktree created from the synced integration branch, not the shared primary checkout. A worktree pins its branch and isolates its files, so a commit cannot land on the wrong branch or absorb unrelated edits.
- Prefer a dedicated worktree root per project (`~/aiwork/worktrees/<project>/<branch-slug>/`, slug replaces `/` with `-`). Do not create worktrees as ad-hoc siblings of the primary clone.
- Before committing, verify the staged set contains only the intended files. Stage explicit paths rather than all changes whenever unrelated or parallel edits may be present, and abort if the staged diff is not what you expect.
- Name the pull request and branch for the shared outcome, not merely the first commit.
- Do not include `codex`, `ai`, `assistant`, or any AI-assistant name in pull request titles; use product/feature-focused titles only.
- Broaden the branch name when the commit scope expands.
- Before opening the pull request, confirm the branch name is still in tandem with the full commit set being delivered; rename it if it is not.
- When a branch already has an open pull request, do not rename it. Broaden the pull request title instead, and treat the branch name as fixed for the life of that PR.
- Split work when changes no longer share a clear review or delivery context.
- Use separate worktrees for parallel tasks instead of large or long-lived stashes.
- Preserve unrelated changes in every worktree. Never `reset --hard`, `checkout --`, or stash/drop work in another worktree unless the user explicitly asks.

### Context switching

| Situation | Do this |
|---|---|
| Same task, back in minutes | `git stash push -m "…"` then `git stash pop` |
| Same task, longer pause | `wip:` commit on the current topic branch |
| Same task, visible remote backup | Push the topic branch. A draft PR is optional; every push to an open PR may bill CI, a plain branch push usually does not |
| Different task while current work stays dirty | New worktree (above) |

Stashes are not a substitute for branches: no history, no label, easy to lose. Do not create ad-hoc parking branches.

## Commits and history

- Treat commits as durable, independently reviewable units of work.
- Design the intended final commit sequence before substantial implementation.
- Group changes by purpose, not chronology or file type.
- Include supporting tests, documentation, and configuration in the implementation commit they complete.
- Isolate a plan or ADR when it has independent review, citation, or revert value.
- Use Conventional Commit subjects that describe complete concerns.
- Do not add AI or assistant authorship trailers or attribution to commit messages, pull request titles or bodies, GitHub Releases, or other published handoff text (for example `Co-authored-by` / `Co-Authored-By` for Claude, Cursor, Copilot, ChatGPT, or similar; "Generated with …"; "Made with …"; or other assistant branding). Never add `Co-authored-by` trailers from assistant sessions, including self-coauthor trailers injected by cloud tooling.
- Fold corrective work into the commit it repairs before review.
- Keep a separate fix commit only when it corrects behavior already on the base branch, changes another concern, or has independent revert value.
- Rewrite only private branch history.
- Coordinate before rewriting shared history and use `--force-with-lease`, never `--force`.
- Never rewrite commits already merged into the integration branch.
- Do not commit, push, rewrite history, or open a pull request unless requested.
- Open pull requests in the Open state, not as drafts, unless a draft is explicitly requested.
- Review the final log oldest to newest before opening a pull request.

### Commit-driven work grouping

Treat the PR as the delivery envelope and commits as the durable units inside it. Before implementation, write the intended final log in dependency order.

1. **Group by purpose, not chronology or file type.** One coherent change plus the docs, tests, and config that complete it. Do not create separate "add tests" or "update docs" commits when those edits only support an implementation commit.
2. **Isolate durable planning and decisions when useful on their own.** A plan and ADR may form a documentation commit before implementation when they establish a contract worth reviewing and citing independently.
3. **Name the PR and branch for the shared outcome.** If scope expands but remains one coherent outcome, broaden framing. If commits no longer share a clear outcome or review context, split the work.
4. **Treat corrective commits as temporary unless they stand alone.** Amend the tip, or use `fixup!` / temporary `fix:` and fold before opening the PR.
5. **Review the history as a deliverable.** Every remaining subject must explain a complete concern without words such as "follow-up", "review fixes", or "cleanup" that only describe how the branch was developed.

```bash
# Correction belongs to the current tip
git add <files>
git commit --amend --no-edit

# Correction belongs to an earlier commit
git add <files>
git commit --fixup <owning-commit>
GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <integration-branch>
```

After any rewrite:

```bash
git status -sb
git log --reverse --oneline <integration-branch>..HEAD
git show --stat <commit>
git diff --check <integration-branch>...HEAD
```

## PR batching and cadence

Prefer a low PR cadence when CI bills per open PR: one PR carries a batch of completed concerns, not one PR per change, unless the repo contract says otherwise.

1. Continue the open batch branch when starting new work; cut a fresh one from the synced integration branch only when no batch is open.
2. One concern, one commit. Fold corrective work into its owning commit before review.
3. Push the branch freely for backup. Hold off opening the PR until the batch is ready so CI runs once against the finished batch when that matches the repo's CI triggers.
4. Land the batch when it reaches a coherent set: a handful of features, the end of a working day, or something needing production, whichever comes first.

**Land alone immediately, outside any batch:** `hotfix/` branches, anything blocking production, and changes whose isolated revert or blame value is high (schema migrations, auth changes). A batch must never delay a production fix.

Follow the repo's merge style (rebase-merge vs squash). When the repo has no rule, prefer rebase-merge for several durable commits and squash for one durable concern or review noise; never a plain merge commit when the target history is linear.

## PR strategy for uncommitted work

When the user has uncommitted changes and asks for a PR strategy:

1. Default to one batch PR with one commit per concern. Propose separate PRs only when a piece qualifies to land alone (hotfix, high isolated-revert value, blocking production).
2. Each PR must target the integration branch directly (no stacked PRs).
3. Confirm each PR is independently mergeable.
4. If changes are too coupled to split cleanly, say so and recommend a single PR.
5. Propose the split by file/concern, not by size.

| Situation | Guidance |
|---|---|
| Default | Prefer one PR unless each slice has its own test plan and merges cleanly alone. |
| Ride-along polish | Copy, aria labels, and small layout tweaks from the same user-facing flow may ship with the primary change when the squash title names one outcome. |
| Split when | Boundaries are obvious: schema + migration + API for one feature vs unrelated UI; security fix vs new feature; refactors the user did not ask for. |
| Do not split | Only to reduce file count. |

### Before staging or committing

1. Run `git diff --stat` and name the concern this change belongs to.
2. If unrelated concerns are mixed, split before committing unless the user wants one coordinated PR.
3. Do not commit unless the user asked. When they ask to "put work in a branch", confirm scope first if the working tree mixes concerns.

### Red flags (stop and split unless the user chooses one coordinated PR)

- Schema/migration + unrelated UI in the same commit
- Security fix + new feature + unrelated refresh together
- "While we're here" refactors mixed with the user's actual request
- A squash-merge title that must describe multiple unrelated outcomes

For each proposed PR, output: suggested branch name and PR title, which files go in it, why it can merge independently, and any merge-order risk. If any proposed PR would only make sense after another is merged, collapse them into one.

## Post-landing workflow

When the user says **"landed"**, **"merged"**, **"PR is merged"**, or equivalent after a PR, treat that as an explicit request to run post-landing cleanup and make the release decision visible. Do not stop after only saying the PR merged.

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
# delete only remote topic branches confirmed merged; never delete the integration branch
git fetch --prune origin
```

Important details:

- Preserve unrelated worktree changes.
- If unrelated local changes block switching or pulling, stop and name the blocking files.
- If the PR was squash-merged, local branch commits may not be ancestors of the integration branch; after verifying the PR is merged (or `git diff <integration> <branch>` is empty), delete with `git branch -D`. If rebase-merged and commits are ancestors, `git branch -d` is enough.
- If the remote branch was already deleted, say so and continue.

After cleanup, run a post-landing scan before stopping:

1. Grep for stale references to renamed identifiers across the repo's source, tests, and schema paths when those exist.
2. Run the repo's required validation (for example `npm test` and `npx tsc --noEmit` when that is the project stack). Report failures immediately.
3. Check for `TODO` / `FIXME` comments introduced in the landed diff.
4. Fix issues before the release decision unless they need user input.
5. If cleanup fixes are needed and the integration branch accepts direct post-landing cleanup commits, commit them there; otherwise create a short fix branch and PR.

Then make the release decision explicit:

- If the user says **"release"**, **"tag"**, **"ship"**, **"deploy"**, **"tester"**, or otherwise asks for a versioned handoff, follow the **repo's** release bookwork (for example the repo `AI.md` release section).
- If the user only says **"landed"**, and the change is user-facing, fixes production behavior, or is stable enough to hand to a tester, ask one concise question before stopping: whether to cut a PATCH/MINOR release, with the recommended version.
- If no release is cut, say exactly why.

## Releases and published attribution

- Do not leave AI, assistant, or bot identity as the publisher of GitHub Releases or similar public handoff artifacts. GitHub shows the release author in the UI (for example "cursor released" when `cursor[bot]` created it).
- Prefer running release bookwork (version bump, annotated tag, `gh release create`) from a local session authenticated as the human GitHub account, not a cloud or bot session that publishes as `cursor[bot]` or similar.
- After creating or editing a GitHub Release, verify authorship immediately:

```bash
gh release view <tag> --json author --jq .author.login
```

  The author must be the human account, not a bot.
- If the published author is a bot, delete the release (keep the git tag) and recreate it with the same notes while authenticated as the human account. Do not rewrite already-pushed release commits on the integration branch to scrub trailers; fix publisher metadata via recreate when that is enough.
- Repository docs may still name product environments when that is operational fact (for example cloud setup notes). That is not the same as bot or assistant attribution on commits, PRs, or releases.
- After `gh pr create` or `gh pr edit`, verify the published body has no injected footers, session links, or tool branding (`gh pr view <n> --json body --jq .body`). Fix with `gh pr edit` immediately when needed.

## Implementation

- Make the smallest coherent change that fully satisfies the requested outcome.
- Follow established repository patterns before introducing new abstractions.
- Avoid speculative infrastructure, compatibility layers, or future-phase code.
- Preserve behavior outside the requested scope.
- Never revert or overwrite changes that were not created for the current task.
- Do not hand-edit files that a tool owns, such as lockfiles, generated types, and snapshot baselines. Run the tool that regenerates them.
- Add comments only where intent or constraints are not evident from the code.
- Prefer maintainable, explicit solutions over clever or compressed implementations.

## Testing and verification

- Run targeted checks during implementation and the required repository checks before completion.
- Validate behavior, not only syntax or compilation.
- Confirm the final working tree and diff contain only intended changes.
- Never claim a check passed unless it was actually run successfully.
- Report skipped checks, unavailable tools, flaky failures, and residual risks explicitly.
- Ensure every commit intended for permanent history leaves the repository in a valid state.

## Review

- Review for defects, regressions, security risks, operational risks, and missing tests.
- Present findings before summaries, ordered by severity.
- Include precise file and line references when possible.
- Distinguish confirmed defects from questions, assumptions, and optional improvements.
- Fold review corrections into their owning commits when history is still private.
- Re-run affected validation after corrections.

## Safety and operations

- Do not expose, print, commit, or transmit secrets.
- Ask before destructive, irreversible, production, billing, or external-state changes.
- Treat code preparation and production execution as separate actions.
- Verify exact targets, prerequisites, rollback paths, and health checks before deployment.
- Use least-privilege access and prefer reversible operations.
- Stop and report unexpected changes that directly conflict with the task.

## Communication

- Communicate assumptions, material tradeoffs, and blockers directly.
- Provide concise progress updates during substantial work.
- Avoid unnecessary narration, praise, or filler.
- At completion, report the outcome, validation performed, and remaining risks.
- State clearly when work remains uncommitted, unpushed, untested, or undeployed.
