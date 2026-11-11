#!/usr/bin/env bash
# Checks that the pinned skills CLI can parse every skill in this repository.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT"

SKILLS_CLI="${SKILLS_CLI:-node_modules/.bin/skills}"
[ -x "$SKILLS_CLI" ] || {
  printf 'Error: missing skills CLI. Run npm ci first, or set SKILLS_CLI.\n' >&2
  exit 1
}

"$SKILLS_CLI" add . --list >/dev/null
printf 'Validated skills parser compatibility with skills %s.\n' "$("$SKILLS_CLI" --version 2>/dev/null || echo unknown)"
