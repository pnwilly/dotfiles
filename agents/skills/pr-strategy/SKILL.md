---
name: pr-strategy
description: >-
  Decide how dirty or in-flight work should be divided into commits and pull
  requests before staging. Use for explicit PR-strategy questions and for any
  commit, push, rebase, or PR request when the branch contains multiple user
  outcomes, schema migrations, security changes, or unrelated concerns.
---
# PR strategy

Decide the shape of the delivery before touching git. This is the decision layer; executing an approved split is a separate step.

## Default

1. One batch PR with one commit per concern. Propose separate PRs only when a piece qualifies to land alone: hotfix, blocking production, or high isolated-revert value (schema migrations, auth changes).
2. Every PR targets the integration branch directly. No stacked PRs.
3. Confirm each PR is independently mergeable.
4. If changes are too coupled to split cleanly, say so and recommend a single PR.
5. Propose the split by file and concern, never by size.

| Situation | Guidance |
|---|---|
| Default | Prefer one PR unless each slice has its own test plan and merges cleanly alone. |
| Ride-along polish | Copy, aria labels, and small layout tweaks from the same user-facing flow may ship with the primary change when the squash title names one outcome. |
| Split when | Boundaries are obvious: schema + migration + API for one feature vs unrelated UI; security fix vs new feature; refactors the user did not ask for. |
| Do not split | Only to reduce file count. |

## Before staging or committing

1. Read the applicable repo instructions for land-alone and merge constraints.
2. Run `git status`, `git diff --stat`, and enough of the diff to inventory every distinct user-requested outcome.
3. Map every outcome to exactly one proposed commit and PR before staging.
4. If unrelated concerns are mixed, split them into commits even when the user wants one coordinated PR.
5. Split into separate PRs when repo policy or isolated-revert value requires it. If the user authorized only one PR, get approval before opening several.
6. Do not commit unless asked. When the user says "put this in a branch", confirm scope first if the tree mixes concerns.

## Red flags

Stop and split unless the user chooses one coordinated PR:

- Schema or migration plus unrelated UI in one commit
- Security fix plus new feature plus unrelated refresh together
- "While we're here" refactors mixed with the actual request
- A squash-merge title that must describe multiple unrelated outcomes
- A proposed commit subject that needs "and", "cleanup", "workflows", or "improvements" to cover distinct outcomes
- Multiple user requests collapsed because they touch the same file

## Shared files are not coupling

A manifest, registry, changelog, generated index, or test file can belong to several concerns. Stage individual hunks with `git add -p` or an equivalent index patch. Each commit must include only its own entries and must leave every referenced file present. Do not collapse concerns merely to avoid partial staging.

## Output

For each proposed PR: suggested branch name and PR title, which files go in it, why it can merge independently, and any merge-order risk. If a proposed PR would only make sense after another merges, collapse them into one.
