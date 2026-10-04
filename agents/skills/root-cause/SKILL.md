---
name: root-cause
description: >-
  Fix a bug by finding its cause before changing code: reproduce, locate,
  prove with a failing test, fix, verify. Use for any bug report, error,
  traceback, regression, or "this doesn't work" request.
---
# Root cause

A fix that makes the symptom disappear without explaining it is a guess. Do not edit production code until you can state the cause.

## 1. Reproduce

Turn the report into a command, request, or test that shows the failure. Capture the exact error and input. If it does not reproduce, stop and report what you tried and what information is missing; do not fix blind.

## 2. Locate

Trace from the symptom back to the first place the state goes wrong: read the traceback bottom-up, follow the data, and check recent history for the area.

```bash
git log --oneline -n 20 -- <path>
git log -S '<identifier>' --oneline
```

When the bug is a regression and a known-good revision exists, `git bisect` beats reading. Confirm each hypothesis with evidence (a print, a debugger, a narrower test) before acting on it.

## 3. State the cause

Write one or two sentences: what is wrong, where, and why it produces the symptom. If you cannot write them, you are not done locating.

Search for the same pattern elsewhere; the cause often has siblings.

```bash
grep -rn '<pattern>' <source-dirs>
```

## 4. Prove, then fix

1. Add a test that fails for the stated reason. Run it and see it fail.
2. Fix the cause at the point it goes wrong, not where it surfaces. Prefer the smallest change that removes the cause.
3. Run the new test and the surrounding suite.

Do not wrap the symptom in a `try`, a null check, or a fallback default unless the cause analysis shows that input is legitimately possible there. Do not fix unrelated issues found along the way; list them instead.

If data already written in the broken state needs repair, say so and handle it separately (migration or patch), since it has a different revert story.

## 5. Report

The cause in one or two sentences, the fix, the test that now guards it, siblings found (fixed or listed), and any existing bad data.

## Behavioral checks

- `KeyError` in a view: trace where the dict is built and why the key is missing; do not add `.get()` with a default.
- Cannot reproduce from the report: ask for the missing input; do not guess-patch.
- Same bug pattern in three call sites: fix all three in the same change, or list the ones left.
- Bug also corrupted stored records: fix the code, then propose the data repair as its own step.
