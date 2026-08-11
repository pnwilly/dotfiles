#!/usr/bin/env bash
#
# Install agent configuration into each AI tool's native location.
#
#   ./install.sh --dry-run    show every destination, write nothing
#   ./install.sh              install
#   ./install.sh --uninstall  remove only what this script owns
#
# Skills use one schema (name + description in SKILL.md) across Claude Code,
# Codex, and Cursor, so each skill directory is symlinked whole — edit a skill
# and every tool sees it immediately, with room for scripts/ and references/
# alongside SKILL.md. Only Cursor's always-on rule needs tool-specific
# frontmatter, so it is the single generated file; rerun this script after
# editing agents/doctrine/core.md.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS="$ROOT/agents"
CORE="$AGENTS/doctrine/core.md"
MARKER='^# Working Agreements$'

SKILLS=(post-landing pr-strategy commit-grouping)

MODE=install
case "${1:-}" in
  --dry-run|-n) MODE=dry ;;
  --uninstall)  MODE=uninstall ;;
  "")           MODE=install ;;
  *) echo "usage: $0 [--dry-run|--uninstall]" >&2; exit 2 ;;
esac

fail=0
say() { printf '%s\n' "$*"; }
rel() { printf '%s' "${1#"$ROOT/"}"; }

# link <src> <dest> — src may be a file or a directory
link() {
  local src=$1 dest=$2
  if [[ ! -e $src ]]; then
    say "  MISSING  $(rel "$src")"; fail=1; return
  fi
  if [[ -L $dest ]]; then
    if [[ $(readlink -f "$dest") == "$(readlink -f "$src")" ]]; then
      say "  ok       $dest"; return
    fi
  elif [[ -e $dest ]]; then
    say "  CONFLICT $dest exists and is not a symlink — left alone"; fail=1; return
  fi
  if [[ $MODE == dry ]]; then
    say "  link     $dest -> $(rel "$src")"; return
  fi
  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  say "  linked   $dest"
}

# generate <frontmatter> <body> <dest>
generate() {
  local fm=$1 body=$2 dest=$3
  if [[ ! -e $fm || ! -e $body ]]; then
    say "  MISSING  $(rel "$fm") or $(rel "$body")"; fail=1; return
  fi
  if [[ -e $dest && ! -L $dest ]] && ! grep -q "$MARKER" "$dest" 2>/dev/null; then
    say "  CONFLICT $dest was not written by this script — left alone"; fail=1; return
  fi
  if [[ $MODE == dry ]]; then
    say "  generate $dest ($(basename "$fm") + $(basename "$body"))"; return
  fi
  mkdir -p "$(dirname "$dest")"
  cat "$fm" "$body" > "$dest"
  say "  wrote    $dest"
}

# remove <dest> — only symlinks into this repo, or files this script generated
remove() {
  local dest=$1
  if [[ ! -e $dest && ! -L $dest ]]; then
    say "  absent   $dest"; return
  fi
  if [[ -L $dest ]]; then
    if [[ $(readlink -f "$dest") != "$ROOT"/* ]]; then
      say "  SKIP     $dest points outside the repo"; return
    fi
  elif ! grep -q "$MARKER" "$dest" 2>/dev/null; then
    say "  SKIP     $dest not written by this script"; return
  fi
  if [[ $MODE == dry ]]; then say "  remove   $dest"; return; fi
  rm "$dest"
  rmdir "$(dirname "$dest")" 2>/dev/null || true
  say "  removed  $dest"
}

apply() {
  if [[ $MODE == uninstall ]]; then remove "${@: -1}"; else "$@"; fi
}

# install_tool <label> <tool-home> <core-dest> <link|generate> <skills-dir>
install_tool() {
  local label=$1 home=$2 core_dest=$3 core_kind=$4 skills_dir=$5 s
  say ""
  if [[ ! -d $home ]]; then
    say "$label — $home not present, skipped"; return
  fi
  say "$label"
  case $core_kind in
    link)     apply link "$CORE" "$core_dest" ;;
    generate) apply generate "$AGENTS/fm/cursor-core.yml" "$CORE" "$core_dest" ;;
  esac
  for s in "${SKILLS[@]}"; do
    apply link "$AGENTS/skills/$s" "$skills_dir/$s"
  done
}

say "dotfiles — mode: $MODE"
say "source: $ROOT"

install_tool "Claude Code" "$HOME/.claude" \
  "$HOME/.claude/CLAUDE.md" link "$HOME/.claude/skills"

install_tool "Codex" "$HOME/.codex" \
  "$HOME/.codex/AGENTS.md" link "$HOME/.codex/skills"

install_tool "Cursor" "$HOME/.cursor" \
  "$HOME/.cursor/rules/working-agreements.mdc" generate "$HOME/.cursor/skills-cursor"

say ""
if [[ -d $HOME/.local/bin ]]; then
  say "Commands"
  apply link "$ROOT/bin/new-worktree" "$HOME/.local/bin/new-worktree"
else
  say "Commands — $HOME/.local/bin not present, skipped"
fi

say ""
if (( fail )); then
  say "finished with conflicts — resolve the CONFLICT or MISSING lines above"
  exit 1
fi
say "done"
