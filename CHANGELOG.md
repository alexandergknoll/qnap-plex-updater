# Changelog

All notable changes to this project will be documented in this file.

This file format is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.0] - 2026-09-01

### Security

- Implemented SHA-1 checksum verification for downloaded .qpkg packages using the Plex JSON API (`https://plex.tv/api/downloads/5.json`); if the checksum can't be fetched, the script prompts for confirmation interactively and aborts automatically when run non-interactively (cron)
- Enforced HTTPS-only, TLS 1.2 minimum, and a 3-redirect cap on all outbound curl requests
- Added init script path validation before execution: existence, path traversal, a safe-character allowlist, symlink resolution, root ownership, and world-writable checks

## [2.2.0] - 2026-08-17

### Added

- `--changelog` flag: log a link to the new version's changelog post on [forums.plex.tv](https://forums.plex.tv/t/plex-media-server/30447) when an update is found or installed; with `--notify`, the link is appended to the QTS success notification
- Warn when Plex has to be force-killed during the stop phase (a known database-corruption hazard)

### Fixed

- Install success is now verified instead of inferred: the installed version is re-read, the package's `Enable` flag is checked (the installer silently disables Plex when its post-install service start fails), and the server must answer on `:32400` (up to 90s) before success is reported. The qpkg installer exits 10 on success by design, which since v2.0.0 silently killed the script before the success message — and with `--notify`, sent a false failure notification for successful installs
- `LD_LIBRARY_PATH` is unset at startup, so a stray export in the calling shell can no longer crash the freshly restarted server

## [2.1.0] - 2026-05-05

### Added

- Retry transient curl failures up to 3 times (`--retry 3 --retry-delay 5`) on both the version probe and the package download
- `--notify` now fires on install failure as well as success, so silent cron failures surface in the QTS notice board

### Changed

- Silence QNAP qpkg installer output by default; pass it through only when `-V/--verbose` is set
- Route Plex token through a wrapper function that disables `set -x` for the curl call so the token does not leak into `--verbose` trace output
- Raise download timeout from 5 minutes to 10 minutes to accommodate slow connections

### Fixed

- Fall back to `"$PLEX_DIR/Plex Media Server" --version` when the running Plex server is unreachable, so the up-to-date comparison works while Plex is stopped — no more spurious reinstalls or "Update available: none -> X.Y.Z" output from `--check`. The QPKG manifest can't be used because it only stores the marketing major.minor.patch and drops the build hash.
- Suppress the failure notification on `--check`'s documented "up-to-date" exit code (1), so `--check --notify` no longer posts a false-alarm error to the QTS notice board
- Validate that the `--log` file's parent directory exists at parse time, instead of crashing on the first `log()` call when the redirect fails
- Avoid script abort under `set -e` when `plex.sh stop` returns non-zero (e.g. Plex not running)
- Detect a missing Plex install up front with a clear error instead of failing later on a token read against a non-existent preferences file
- Validate that the download directory exists before invoking `df` against it

## [2.0.0] - 2026-03-21

### Added

- `--check` flag to check for updates without installing
- `--force` flag to reinstall even if already up to date
- `--log FILE` flag to append timestamped output to a file
- Timeouts on all `curl` calls (30s for version checks, 300s for download)
- Free space check for auto-detected download directory
- Download verification via `--fail` and non-empty file check
- Cleanup trap to remove partial downloads on failure
- Validation for `--channel` and `--directory` option values

### Changed

- Switch from `bash` to POSIX `sh` for portability
- Move Plex token from URL query parameter to `X-Plex-Token` request header
- "Already installed" now exits 0 instead of 1
- Rewrite script structure to match shell template conventions
- Rewrite `--help` output format
- Refactor `main()` into discrete functions (`detect_plex`, `get_local_version`, `get_remote_version`, `download`, `install`)

### Fixed

- Escape dots in version regex to match literal dots only
- Validate channel before making API calls, not after
- `--version` now exits 0 instead of 1

## [1.0.1] - 2023-10-24

### Fixed

- Fix default value for `${LOCAL_PLEX_VERSION}`

## [1.0.0] - 2022-10-30

### Added

- Use `-n / --notify` to output QTS/QuTS notice board notification on successful install

### Fixed

- Set default value for `${LOCAL_PLEX_VERSION}`

## [0.3.2] - 2022-06-24

### Added

- Add 'Prerequisites' section to `README`

### Fixed

- Fix path in `README` usage instructions (Closes: #2)
- Replace BASH parameter expansion with good ol' trusty `awk` (Closes: #1)

## [0.3.1] - 2022-06-07

### Fixed

- Stop PMS to prevent script being killed

## [0.3.0] - 2022-06-06

### Added

- Specify package download directory using `-d/--directory <path>`

## [0.2.0] - 2022-06-03

### Added

- `AARCH` and `REGEX_PLEX_VERSION` variables

### Changed

- Return `$AARCH` in Plex Media Server version

### Fixed

- Fix `[[ ]]` string comparisons

## [0.1.0] - 2022-05-31

Initial release.
