#!/usr/bin/env bash
# Read-only inventory of common developer storage locations.
# Prints free space, then the measured size of each known location that exists,
# largest first. Rows overlap (a parent and its child can both appear): never sum
# them. Deletes nothing; writes only a temporary error log.
set -u

if [[ "$(uname -s)" == "Darwin" && -d /System/Volumes/Data ]]; then
  df -h /System/Volumes/Data | tail -n 1
else
  df -h / | tail -n 1
fi
echo

H="$HOME"
candidates=(
  "$H/Library/Caches"
  "$H/Library/Caches/Homebrew"
  "$H/Library/Caches/pnpm"
  "$H/Library/Caches/CocoaPods"
  "$H/Library/Caches/ms-playwright"
  "$H/Library/Developer/Xcode/DerivedData"
  "$H/Library/Developer/Xcode/Archives"
  "$H/Library/Developer/Xcode/iOS DeviceSupport"
  "$H/Library/Developer/CoreSimulator/Devices"
  "$H/Library/Android/sdk"
  "$H/Library/pnpm"
  "$H/Library/Containers/com.docker.docker"
  "$H/.android/avd"
  "$H/.gradle/caches"
  "$H/.dartServer"
  "$H/.pub-cache"
  "$H/.npm"
  "$H/.cache"
  "$H/.local/share/mise"
  "$H/.local/share/pnpm"
  "$H/.cargo"
  "$H/.rustup"
  "$H/.ollama/models"
  "$H/.orbstack"
  "$H/.colima"
  "$H/go/pkg/mod"
  "$H/Downloads"
)

errlog="$(mktemp)"
trap 'rm -f "$errlog"' EXIT

for path in "${candidates[@]}"; do
  # Skip symlinks so a link cannot point the measurement somewhere unexpected.
  if [[ -d "$path" && ! -L "$path" ]]; then
    du -sh "$path" 2>>"$errlog"
  fi
done | sort -hr

errors=$(wc -l <"$errlog" | tr -d ' ')
if [[ "$errors" -gt 0 ]]; then
  echo "($errors entries could not be read; sizes above may be undercounted)"
fi

if command -v xcrun >/dev/null 2>&1; then
  echo
  echo "Booted simulators (in use):"
  xcrun simctl list devices booted 2>/dev/null | grep -E '\(Booted\)' || echo "  none"
fi
