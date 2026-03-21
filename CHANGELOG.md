# Changelog

All notable changes to this project will be documented in this file.

This file format is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
