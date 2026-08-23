#!/usr/bin/env bash
# Shared helpers for stripping / rejecting AI attribution in commit messages.
#
# Sourced by prepare-commit-msg and commit-msg. Not meant to be run directly.

# Trailers injected by assistant tooling. Legitimate human Co-authored-by lines
# (without these product names) are left alone.
AI_ATTRIBUTION_TRAILER_ERE='^Co-authored-by:[[:space:]]*.*(Cursor|Claude|Copilot|ChatGPT|OpenAI|Anthropic|Gemini|Cody|Aider|Continue)'

# Optional markdown link after the product name: Made with [Cursor](https://cursor.com)
AI_ATTRIBUTION_BRANDING_ERE='^[[:space:]]*((Made|Generated) with[[:space:]]+\[?(Cursor|Claude|Copilot|ChatGPT|OpenAI|Anthropic|Gemini)\]?(\([^)]*\))?\.?|Made-with:.*|Generated-by:.*)$'

strip_ai_attribution() {
	local file=$1
	local tmp
	tmp=$(mktemp)
	grep -Evi "$AI_ATTRIBUTION_TRAILER_ERE" "$file" \
		| grep -Evi "$AI_ATTRIBUTION_BRANDING_ERE" \
		| sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba' >"$tmp" || true
	mv "$tmp" "$file"
}

has_ai_attribution() {
	local file=$1
	grep -Eqi "$AI_ATTRIBUTION_TRAILER_ERE" "$file" && return 0
	grep -Eqi "$AI_ATTRIBUTION_BRANDING_ERE" "$file" && return 0
	grep -Eqi 'Co-authored-by:[[:space:]]*.*(cursoragent@|noreply@cursor\.com)' "$file" && return 0
	return 1
}

# core.hooksPath replaces .git/hooks, so chain the repo's own hook when present.
run_repo_hook() {
	local name=$1
	shift
	local git_dir repo_hook self other
	git_dir=$(git rev-parse --git-dir 2>/dev/null) || return 0
	repo_hook="$git_dir/hooks/$name"
	[[ -x $repo_hook ]] || return 0

	self=$(readlink -f "$(dirname "${BASH_SOURCE[1]}")/$name" 2>/dev/null || true)
	other=$(readlink -f "$repo_hook" 2>/dev/null || true)
	if [[ -n $self && -n $other && $self == "$other" ]]; then
		return 0
	fi
	"$repo_hook" "$@"
}
