# Working Agreements

Personal defaults for agent-assisted work across repositories and tools.

## Precedence

- Follow system, security, and permission requirements first.
- Explicit task instructions and repository policies override this file.
- When a repo has `AI.md`, `AGENTS.md`, or equivalent, that file is the **repo contract** (merge style, CI facts, release mechanics, design and auth invariants). This file is **session style** (how to group commits, batch PRs, land branches). On conflict, the repo contract wins.
- Do not copy repo-specific release scripts, CI tier lists, or product invariants here; cite the repo doc.
- Do not store repository facts, credentials, hostnames, or secrets here.
- Name material conflicts before proceeding.

## Preparation

- Do not assume the repository is clean or that existing changes belong to you.
- Resolve ambiguous targets before acting. When a request names an element, page, or file indirectly, locate it and confirm the match before editing. Ask when more than one candidate fits.
- Separate current work from explicitly deferred phases. Do not implement deferred work because the current design anticipates it.
- Use an ADR when a decision will constrain future work or replace an earlier one. Record durable decisions separately from temporary implementation detail.

## Branches and worktrees

- Start each unit of work from a freshly synced integration branch: fetch, fast-forward, then branch. Re-sync before every unit when the integration branch may have advanced between tasks.
- **Confirm the working branch is the intended topic branch before editing or committing.** Make this a separate step that halts the work when it fails; never chain it into the same command as the commit or push.
- When the checkout may change underneath you (parallel sessions, automation, quick review merges, unrelated uncommitted changes), work in a dedicated worktree created from the synced integration branch. A worktree pins its branch and isolates its files, so a commit cannot land on the wrong branch or absorb unrelated edits.
- Use one worktree root for everything: `~/worktrees/<project>/<branch-slug>/`, slug replaces `/` with `-`. Never inside the repo, never as ad-hoc siblings of the primary clone, and never under `/tmp` — it is tmpfs and reaped on a timer, so uncommitted work does not survive a reboot.
- Preserve unrelated changes in every worktree. Never `reset --hard`, `checkout --`, or stash and drop work in another worktree unless explicitly asked.
- Name the branch and PR for the shared outcome, not the first commit. Broaden the name when scope expands. Once a PR is open the branch name is fixed — broaden the PR title instead.
- Never put `codex`, `ai`, `assistant`, or any assistant name in branch names or PR titles.
- Stage explicit paths rather than all changes when parallel edits may be present. Verify the staged set before committing and abort if it is not what you expect.

| Context switch | Do this |
|---|---|
| Same task, back in minutes | `git stash push -m "…"` then `git stash pop` |
| Same task, longer pause | `wip:` commit on the topic branch |
| Same task, remote backup | Push the topic branch; draft PR optional (each push to an open PR may bill CI) |
| Different task, current work dirty | New worktree |

Stashes are not branches: no history, no label, easy to lose. No ad-hoc parking branches.

## Commits

- Treat commits as durable, independently reviewable units. Design the intended final sequence before substantial implementation.
- Group by purpose, not chronology or file type. Tests, docs, and config ship inside the implementation commit they complete, never as separate "add tests" or "update docs" commits.
- Conventional Commit subjects describing complete concerns. No "follow-up", "review fixes", or "cleanup" subjects that only describe how the branch was developed.
- **Never add AI or assistant attribution** to commits, PR titles or bodies, GitHub Releases, or other published handoff text. No `Co-authored-by` for Claude, Cursor, Copilot, ChatGPT or similar; no "Generated with…"; no assistant branding. This includes self-coauthor trailers injected by cloud tooling.
- Fold corrective work into the commit it repairs before review. Keep a separate fix commit only when it corrects behavior already on the base branch, changes another concern, or has independent revert value.
- Rewrite only private history. Never rewrite commits already merged into the integration branch. Coordinate before rewriting shared history and use `--force-with-lease`, never `--force`.
- Do not commit, push, rewrite history, or open a pull request unless asked. Open PRs in the Open state unless a draft is explicitly requested.
- Review the log oldest to newest before opening a pull request.

## PR cadence

Prefer a low PR cadence when CI bills per open PR: one PR carries a batch of completed concerns, not one PR per change, unless the repo contract says otherwise.

- Continue the open batch branch when starting new work; cut a fresh one from the synced integration branch only when no batch is open.
- Push the branch freely for backup. Hold the PR until the batch is ready so CI runs once against the finished batch.
- Land the batch when it reaches a coherent set: a handful of features, the end of a working day, or something needing production, whichever comes first.
- **Land alone immediately, outside any batch:** `hotfix/` branches, anything blocking production, and changes whose isolated revert or blame value is high (schema migrations, auth changes). A batch must never delay a production fix.
- Follow the repo's merge style. With no rule, prefer rebase-merge for several durable commits and squash for one durable concern or review noise; never a plain merge commit when the target history is linear.

## Implementation

- Make the smallest coherent change that fully satisfies the requested outcome.
- Follow established repository patterns before introducing new abstractions.
- No speculative infrastructure, compatibility layers, or future-phase code.
- Preserve behavior outside the requested scope. Never revert or overwrite changes that were not created for the current task.
- Do not hand-edit files a tool owns (lockfiles, generated types, snapshot baselines). Run the tool that regenerates them.

## Verification

- Run targeted checks during implementation and the required repository checks before completion. Validate behavior, not only compilation.
- **Never claim a check passed unless it actually ran successfully.** Report skipped checks, unavailable tools, flaky failures, and residual risks explicitly.
- Confirm the final working tree and diff contain only intended changes.
- Every commit intended for permanent history must leave the repository in a valid state.
- When reviewing: findings before summaries, ordered by severity, with precise file and line references. Distinguish confirmed defects from questions, assumptions, and optional improvements.

## Safety

- Never expose, print, commit, or transmit secrets.
- Ask before destructive, irreversible, production, billing, or external-state changes.
- Treat code preparation and production execution as separate actions.
- Verify exact targets, prerequisites, rollback paths, and health checks before deployment.
- Stop and report unexpected changes that directly conflict with the task.

## Reporting

- State assumptions, material tradeoffs, and blockers directly.
- At completion, report the outcome, the validation performed, and remaining risks.
- State clearly when work remains uncommitted, unpushed, untested, or undeployed.
