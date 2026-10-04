---
name: verify-before-done
description: >-
  Run the repository's required checks and report their real results before
  calling work finished. Use before saying a change is done, before any commit
  or PR request, and whenever asked to verify, validate, or test a change.
---
# Verify before done

Finished means the repo's required checks ran and their results are reported as they happened. Compiling, or a passing subset, is not finished.

## 1. Find the checks

Read the repo contract first (`AI.md`, `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`). It names the required commands. Then confirm them against what CI actually runs:

```bash
ls .github/workflows 2>/dev/null && grep -hE '^\s*(run|- run):' .github/workflows/*.yml
ls Makefile justfile package.json pyproject.toml tox.ini noxfile.py .pre-commit-config.yaml 2>/dev/null
```

When the contract and CI disagree, CI is the fact and the contract is stale; say so. When neither names a check, use the tools the repo already configures (lint config, test directory) and state that you inferred them.

Include any post-edit steps the contract requires, such as migrations, asset builds, cache clears, or restarts.

## 2. Run targeted, then full

1. Run the tests and lint for the files you touched. Fix failures before going wider.
2. Run the full required set the contract names before a commit or PR.
3. Exercise the changed behavior at least once outside the test suite when the repo has a way to (CLI call, local site, script). Tests prove the code; this proves the feature.

Do not change a test's expectation to make it pass unless the expectation itself was wrong, and say so when you do.

## 3. Check the diff

```bash
git status -sb
git diff --stat
git diff --check
```

The diff must contain only the intended change: no debug prints, stray files, unrelated formatting churn, or edits to tool-owned files (lockfiles, generated code, snapshots) made by hand.

## 4. Report

One line per check: command, then `passed`, `failed`, or `skipped`, with the reason for any skip and the error summary for any failure. Then list residual risk: untested paths, flaky results, checks that could not run here.

Never write "all checks pass" when any check was skipped, partly run, or not run in this session. A failure that existed before your change is still reported, marked as pre-existing, with evidence (the same failure on the integration branch).

## Behavioral checks

- Contract says `pytest`, CI also runs `ruff`: run both; note the contract gap.
- Lint fails in a file you did not touch: report it as pre-existing; do not fix it in this change.
- Full suite takes too long to run here: run the targeted set, report the full suite as skipped with the reason.
- A test was edited to pass: say which and why the old expectation was wrong.
