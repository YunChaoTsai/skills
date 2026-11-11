#!/usr/bin/env bash
# Offline repository checks: skill layout, frontmatter, agent metadata,
# README list, and pinned install commands.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT"

SKILLS_CLI_VERSION="1.5.3"

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

frontmatter_of() {
  awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { exit }
    in_fm { print }
  ' "$1"
}

frontmatter_value() {
  printf '%s\n' "$1" | awk -v key="$2" '
    $0 ~ "^" key ":" {
      value = $0
      sub("^" key ":[[:space:]]*", "", value)
      gsub(/^"|"$/, "", value)
      print value
      exit
    }
  '
}

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

find skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort >"$tmp_dir/actual"
awk '/^### yc-/{print $2}' README.md >"$tmp_dir/readme-order"
sort "$tmp_dir/readme-order" >"$tmp_dir/readme"

diff_output="$(comm -3 "$tmp_dir/actual" "$tmp_dir/readme")"
[ -z "$diff_output" ] || fail "README skill list does not match skills/*:
$diff_output"
cmp -s "$tmp_dir/readme-order" "$tmp_dir/readme" || fail "README skill sections are not in alphabetical order"

if grep -RInE 'npx -y skills( |$)' README.md AGENTS.md scripts .github skills; then
  fail "found an unpinned npx skills command; use npx -y skills@${SKILLS_CLI_VERSION}"
fi

while IFS= read -r skill_dir; do
  skill="$(basename "$skill_dir")"
  skill_md="$skill_dir/SKILL.md"
  [ -f "$skill_md" ] || fail "$skill is missing SKILL.md"
  case "$skill" in yc-*) ;; *) fail "$skill must use the yc- prefix" ;; esac

  fm="$(frontmatter_of "$skill_md")"
  [ "$(frontmatter_value "$fm" name)" = "$skill" ] || fail "$skill frontmatter name must be $skill"
  [ -n "$(frontmatter_value "$fm" description)" ] || fail "$skill is missing frontmatter description"

  if [ -d "$skill_dir/references" ]; then
    while IFS= read -r ref; do
      grep -Fq "${ref#"$skill_dir"/}" "$skill_md" || fail "$ref is not linked from $skill_md"
    done < <(find "$skill_dir/references" -type f | sort)
  fi

  if [ -d "$skill_dir/scripts" ]; then
    while IFS= read -r script; do
      [ -x "$script" ] || fail "$script is not executable"
      case "$script" in *.sh) bash -n "$script" ;; esac
    done < <(find "$skill_dir/scripts" -type f | sort)
  fi

  yaml="$skill_dir/agents/openai.yaml"
  [ -f "$yaml" ] || fail "$skill is missing agents/openai.yaml"
  for key in display_name short_description default_prompt; do
    grep -Fq "$key:" "$yaml" || fail "$yaml is missing $key"
  done
  grep -Eq "\\\$${skill}([^[:alnum:]_-]|\$)" "$yaml" || fail "$yaml default_prompt must mention \$$skill"

  [ -f "fixtures/smoke/$skill.md" ] || fail "$skill is missing fixtures/smoke/$skill.md"
done < <(find skills -mindepth 1 -maxdepth 1 -type d | sort)

printf 'Validated %s skills.\n' "$(wc -l <"$tmp_dir/actual" | tr -d ' ')"
