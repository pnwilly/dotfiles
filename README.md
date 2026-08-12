# dotfiles

Personal configuration, installed into each tool's native location by symlink.

```
agents/
  doctrine/core.md      always-on working agreements
  skills/<name>/        triggered runbooks, one directory per skill
  fm/                   per-tool frontmatter for generated files
bin/
  new-worktree          create a worktree at the path the doctrine specifies
install.sh
```

## Requirements

- `git` and `bash` 4+
- GNU coreutils — `install.sh` uses `readlink -f`, which BSD and macOS lack
- `~/.local/bin` on `PATH`, for `bin/`. The installer skips commands if that
  directory does not exist; create it first if you want them
- `gh`, authenticated. The post-landing skill drives `gh pr view`,
  `gh release view`, and `gh pr edit`

## Install

```sh
git clone https://github.com/pnwilly/dotfiles ~/dotfiles
cd ~/dotfiles

./install.sh --dry-run    # print every destination, write nothing
./install.sh              # install
./install.sh --uninstall  # remove only what this script owns
```

The location is not fixed — the script resolves paths from its own directory —
but everything below assumes `~/dotfiles`.

The script never overwrites a file it did not create. Anything unexpected at a
destination is reported as `CONFLICT` and left alone, and the run exits `1`.

## Verify

```sh
ls -l ~/.claude/CLAUDE.md ~/.codex/AGENTS.md   # should be symlinks into this repo
new-worktree                                    # should print its usage
```

Then start a session in each tool and confirm the doctrine is in context and
the skills are listed. Two things are worth checking rather than assuming:

- Whether Cursor reads user-level rules from `~/.cursor/rules/` or only from
  its settings UI.
- Whether each tool's skill scanner follows directory symlinks. If skills do
  not appear, linking each `SKILL.md` file instead of its directory is a small
  change to `install.sh`.

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

**Hooks** (`agents/hooks/`) are mechanical enforcement. `install.sh` symlinks
them to `~/.config/git/hooks` and sets `core.hooksPath` there. Because they
are git hooks, they run for **every** `git commit` on this machine — Cursor,
Claude Code, Codex, and ordinary shell use alike — unless the caller passes
`--no-verify`. They are not Cursor-specific.

Today the hooks strip and then refuse AI attribution trailers
(`Co-authored-by: Cursor`, `Made with Cursor`, and similar). They do **not**
catch product UI that edits a PR body after `gh pr create`; scrub that in the
PR skill or with a `gh` wrapper if it keeps coming back.

## bin/

Commands that make a rule executable instead of remembered. `new-worktree`
puts a worktree where the doctrine says it goes, branching from a freshly
fetched integration branch so the primary checkout is never disturbed:

```sh
new-worktree feat/list-header             # from inside the repo
new-worktree feat/list-header ~/code/app  # or name the repo
```

It refuses `/tmp` and in-repo paths outright. Override the root with
`WORKTREE_ROOT` if a project needs to live elsewhere.

## Destinations

| Tool | Doctrine | Skills | Hooks |
|---|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` (link) | `~/.claude/skills/` | — |
| Codex | `~/.codex/AGENTS.md` (link) | `~/.codex/skills/` | — |
| Cursor | `~/.cursor/rules/working-agreements.mdc` (generated) | `~/.cursor/skills-cursor/` | — |
| Git (all tools) | — | — | `~/.config/git/hooks` + `core.hooksPath` |
| Commands | — | `~/.local/bin/new-worktree` (link) | — |

A tool whose directory is absent is skipped, so the same script runs on a
machine with only one of them installed.

Claude Code and Codex read plain markdown, so their doctrine is a symlink and
edits apply immediately. Cursor needs `alwaysApply: true` frontmatter, so its
copy is generated from `agents/fm/cursor-core.yml` — rerun `install.sh` after
editing `core.md`.

## Precedence

A repository's own `AI.md` or `AGENTS.md` outranks everything here. The
doctrine is session style: how to group commits, batch PRs, land branches. The
repo contract owns merge style, CI facts, release mechanics, and product
invariants. Do not copy repo-specific facts into this repo; cite the repo doc.
