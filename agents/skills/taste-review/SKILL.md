---
name: taste-review
description: >-
  Review a diff for maintainability and code taste, not bugs: size,
  complexity, naming, comments, needless abstraction, and fit with existing
  patterns. Use when asked for a style, readability, quality, or taste review,
  or to tidy a change before a PR.
---
# Taste review

Judge whether the change reads like the best code already in the repo. Bugs belong to a correctness review; this pass is about what a maintainer will curse in six months.

## 1. Set the bar

Read the repo contract (`AI.md`, `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`) and any lint config. Its rules and limits replace the defaults below wherever they differ. Read two or three neighboring files to learn local idiom before judging.

Review only the diff (`git diff <integration-branch>...HEAD` plus uncommitted changes) and the code it directly touches. Pre-existing problems elsewhere are out of scope unless the change makes them worse.

## 2. Default rules

**Less code**
- Delete before adding: could existing code be simplified or reused instead?
- Use standard library and existing repo helpers before custom logic.
- No speculative parameters, layers, flags, or compatibility shims for futures nobody asked for.
- A single-use one-line helper usually reads better inline.

**Shape**
- Functions do one thing; around 25 lines is a signal to look, not a rule to split.
- Deep nesting or many branches: look for early returns or a lookup table.
- Behavior lives in the domain object or layer that owns it, not in thin entry points (routes, CLI handlers, views).
- One owner for state that can drift; no temporary state leaking across boundaries.

**Names**
- Full words, no abbreviations the codebase does not already use.
- Booleans read as questions: `is_`, `has_`, `can_`.
- Names describe what a thing is or returns, not how it is computed.

**Comments**
- Explain why, never restate what. Delete comments the code already says.
- No commented-out code, no change narration ("now uses X instead of Y"); that belongs in the commit message.

**Failure**
- Fail loudly near the bug. Flag broad `except`, silent fallbacks, and defaults that hide corrupt or partial state.
- Retries only around operations that are safe to repeat.

**Tests**
- Behavior changes come with tests that would fail without the change.
- Tests assert behavior, not implementation details.

## 3. Report

Findings first, ordered by how much they will cost a future reader. Each one: `file:line`, the problem in one sentence, and the concrete rewrite. Separate **should change** from **optional**. Skip anything a formatter or linter will fix on its own.

Apply fixes only when asked. When applying, keep behavior identical and rerun the targeted checks.

## Behavioral checks

- Repo contract sets complexity <= 8 and the default says "look around 25 lines": use the contract.
- New helper wraps one call and has one caller: suggest inlining.
- Diff adds a config flag with one possible value: flag as speculative.
- Neighboring files use a pattern the diff ignores: point to the existing pattern with a path.
