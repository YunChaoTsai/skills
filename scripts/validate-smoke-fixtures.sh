#!/usr/bin/env bash
# Checks that each smoke fixture still covers the regressions it exists for.
# A fixture is a decision walkthrough, not an executable test: this only proves
# the scenarios are written down, not that an agent behaves as expected.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT"

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require() {
  grep -Eiq -- "$2" "$1" || fail "$1: $3"
}

for fixture in fixtures/smoke/*.md; do
  require "$fixture" '^## Prompt' "missing ## Prompt"
  require "$fixture" '^## Expected Behavior' "missing ## Expected Behavior"
done

f=fixtures/smoke/yc-disk-cleanup.md
require "$f" 'booted|in use' "must cover a simulator another session is using"
require "$f" 'volume' "must cover a Docker volume request"
require "$f" 'autoremove|--zap|side effect' "must cover reporting side effects"
require "$f" 'whatever you think' "must cover the open-ended approval"
require "$f" 'sum|df' "must cover reporting measured free space"

printf 'Validated smoke fixtures.\n'
