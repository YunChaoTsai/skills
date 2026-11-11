# Location catalog

What a common large location is, the command that owns its cleanup, and what
deleting it costs. Sizes vary; always measure. Paths are macOS unless marked.

## Tier 1 — caches

| Location | Clean with | Cost |
|---|---|---|
| `~/Library/Caches/Homebrew` and old formula versions | `brew cleanup -n -s` to preview, then `brew cleanup -s`; it also removes outdated installed versions, so name both effects | Re-download on reinstall; old versions gone |
| `~/.npm/_cacache` | `npm cache clean --force` | Re-download on install |
| pnpm store (`pnpm store path`) | `pnpm store prune`; the store is shared by every project | Packages no project references any more are removed |
| `~/Library/Caches/pnpm` (metadata) | delete contents; measure it separately from the store | Metadata re-fetched |
| `~/Library/Caches/Yarn` | `yarn cache clean` | Re-download |
| `~/Library/Caches/pip`, `~/.cache/pip` | `pip cache purge` | Re-download |
| `~/.cache/uv` | `uv cache clean` | Re-download |
| `~/Library/Caches/pipenv`, `~/Library/Caches/node-gyp`, `~/Library/Caches/typescript` | delete contents | Rebuilt on next use |
| `~/Library/Developer/Xcode/DerivedData` | delete contents (Xcode closed) | Next iOS build is a full build |
| `~/Library/Caches/CocoaPods` | `pod cache clean --all` | Re-download pods |
| `~/Library/Caches/ms-playwright`, `~/.cache/ms-playwright` | `npx playwright uninstall` for the current installation; `--all` also removes browsers other projects use — approve that explicitly | Re-download browsers |
| Go build cache (`go env GOCACHE`) | `go clean -cache` | Slower next build |

## Tier 2 — rebuildable state

| Location | Clean with | Cost |
|---|---|---|
| `~/Library/Developer/CoreSimulator/Devices` | List devices, approve each UDID, then `xcrun simctl delete <udid>`, or `xcrun simctl erase <udid>` to keep the device. `delete unavailable` removes every unavailable device — only when the user approves all of them | App data, sign-ins on that simulator. Check it is not booted or used (`pgrep -fl <udid>`) |
| Simulator runtimes | `xcrun simctl runtime list`, `xcrun simctl runtime delete <id>` | Re-download several GB from Xcode; never delete the folder by hand |
| `~/Library/Developer/Xcode/iOS DeviceSupport/<device os>` | delete the folders for OS versions no device you own runs | Re-copied when that device is next attached |
| `~/.android/avd/<name>.avd` | Android Studio Device Manager (`avdmanager delete avd -n <name>` still works but is deprecated) | Emulator state and installed apps |
| `~/Library/Android/sdk` | Android Studio SDK Manager — remove unused platforms / system images | Re-download |
| `~/.gradle/caches` | stop daemons (`./gradlew --stop`), then delete `caches/` or only old version dirs | Next Android build re-downloads dependencies |
| `~/.dartServer` | delete with the editor closed | Analysis cache rebuilt on next open |
| `~/.pub-cache` | `dart pub cache clean` | Every Flutter/Dart project needs `pub get`; globally activated tools (`dart pub global list`) are removed too |
| Go module cache (`go env GOMODCACHE`) | `go clean -modcache` | Re-download modules |
| `~/.local/share/mise/installs` | `mise uninstall <tool>@<version>` for a named version; `mise prune` only after the user approves what `mise ls --prunable` lists | Projects pinning that version reinstall it |
| `~/.nvm`, `~/.rustup` | `nvm uninstall <version>`, `rustup toolchain uninstall <name>` | Same |
| `node_modules` in projects | delete per project the user names | `npm install` / `pnpm install` again |
| Git worktrees | `git worktree remove <approved-path>`; stop if it refuses. Skip `git worktree prune`: it drops every stale record in the repo, including moved worktrees | Branch work if not pushed — check `git status` and upstream first |

## Tier 3 — user's call

| Location | Notes |
|---|---|
| `~/Downloads` | List the largest files; installers for apps already installed are the usual win |
| Apps (`brew list --cask`, `/Applications`) | `brew uninstall --cask <name>`; `--zap` also removes preferences — say so |
| Homebrew formulae | `brew leaves` lists top-level installs; `brew uses --installed <f>` before removing; `brew autoremove` removes orphaned dependencies |
| Docker / OrbStack / Colima images | `docker system df` first; `docker image prune` for dangling images. Never prune volumes without naming each one |
| VM disks (`Docker.raw`, OrbStack `data.img`, UTM, Parallels) | Shrinking needs the owning app; deleting loses the VM |
| Local models (`~/.ollama/models`, `~/.cache/huggingface`, LM Studio) | Re-download is large |
| `~/.Trash` | User empties it from Finder; terminal access is blocked by TCC |
| APFS local snapshots | `tmutil listlocalsnapshots /`; macOS removes them under pressure |

## Linux additions

| Location | Clean with |
|---|---|
| `~/.cache` | per tool, as above |
| `/var/cache/apt`, dnf, pacman | hand the user `sudo apt-get clean` / `sudo dnf clean all` / `sudo paccache -rk1` |
| systemd journal | hand the user `sudo journalctl --vacuum-size=200M` |
| Snap old revisions | `snap list --all`; hand the user `sudo snap remove <name> --revision <rev>` |
| Flatpak | `flatpak uninstall --unused` |
