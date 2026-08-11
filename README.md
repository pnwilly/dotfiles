# dotfiles

Personal configuration, installed into each tool's native location by symlink.

```
agents/
  doctrine/core.md      always-on working agreements
  skills/<name>/        triggered runbooks, one directory per skill
  fm/                   per-tool frontmatter for generated files
install.sh
```

## Install

```sh
./install.sh --dry-run    # print every destination, write nothing
./install.sh              # install
./install.sh --uninstall  # remove only what this script owns
```

The script never overwrites a file it did not create. Anything unexpected at a
destination is reported as `CONFLICT` and left alone, and the run exits `1`.

## agents/

Three kinds of instruction, separated because they load differently.

**Doctrine** (`agents/doctrine/core.md`) is always in context. It holds only
what changes agent behavior — rules that contradict a tool default, and
machine- or workflow-specific facts. Generic advice current models already
follow is deliberately absent: every line in an always-on file competes for
attention with the lines that matter.

**Skills** (`agents/skills/`) are procedures that load when their trigger
appears, so they cost nothing the rest of the time. Claude Code, Codex, and
Cursor all read `SKILL.md` with `name` and `description` frontmatter, so one
directory serves all three and each is symlinked whole.

**Hooks** are not here yet. The hard prohibitions in the doctrine — no AI
attribution on commits, no `--force` — are currently prose, which means they
depend on the model attending to the right line at the right moment. Real
enforcement needs `~/.claude/settings.json` hooks and is Claude Code only.

## Destinations

| Tool | Doctrine | Skills |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` (link) | `~/.claude/skills/` |
| Codex | `~/.codex/AGENTS.md` (link) | `~/.codex/skills/` |
| Cursor | `~/.cursor/rules/working-agreements.mdc` (generated) | `~/.cursor/skills-cursor/` |

Claude Code and Codex read plain markdown, so their doctrine is a symlink and
edits apply immediately. Cursor needs `alwaysApply: true` frontmatter, so its
copy is generated from `agents/fm/cursor-core.yml` — rerun `install.sh` after
editing `core.md`.

## Precedence

A repository's own `AI.md` or `AGENTS.md` outranks everything here. The
doctrine is session style: how to group commits, batch PRs, land branches. The
repo contract owns merge style, CI facts, release mechanics, and product
invariants. Do not copy repo-specific facts into this repo; cite the repo doc.
