# Changelog

All notable changes to this project will be documented in this file.

This file format is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).\
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### New
### Changes
### Deprecated
### Removed
### Fixes
### Security

## [1.1.0] - 08-12-2025

### Security

- Implemented SHA-1 checksum verification for downloaded .qpkg packages using Plex JSON API
  - Helps prevent installation of corrupted or malicious packages
  - Fetches checksums from `https://plex.tv/api/downloads/5.json`
  - Installation aborts if checksum verification fails

- Moved Plex authentication token from URL parameters to HTTP headers
  - Prevents token exposure in process listings (`ps aux`)
  - Prevents token leakage in shell history and system logs
  - Uses `X-Plex-Token` HTTP header instead of query parameter

- Enhanced HTTPS/TLS validation for all curl operations
  - Added `--fail` flag to fail on HTTP errors
  - Enforced HTTPS-only protocol with `--proto '=https'`
  - Set minimum TLS version to 1.2 with `--tlsv1.2`
  - Limited redirect chains to 3 with `--max-redirs 3`
  - Added connection timeout (30s) and operation timeout (5min)
  - Prevents MITM attacks and ensures proper error handling

- Added comprehensive init script path validation
  - Verifies init script exists before execution
  - Validates path contains only safe characters
  - Resolves symlinks to prevent symlink attacks
  - Checks script is owned by root (prevents privilege escalation)
  - Ensures script is not world-writable
  - Prevents command injection via compromised config files

### Changes

- Quoted all variables in `parse_config_file` calls to prevent word splitting
- Added security-focused helper functions:
  - `fetch_checksum_from_api()`: Retrieves SHA-1 checksums from Plex API
  - `verify_checksum()`: Validates package integrity before installation
  - `validate_init_script()`: Ensures init script path is secure
- Improved error messages for download and verification failures

## [1.0.1] - 24-10-2023

### Fixes

- fix default value for `${LOCAL_PLEX_VERSION}`

## [1.0.0] - 30-10-2022

### New

- use `-n / --notify` to output QTS/QuTS notice board notification on successful install

### Fixes

- set default value for `${LOCAL_PLEX_VERSION}`

## [0.3.2] - 24-06-2022

### New

- Add 'Prerequisites' section to `README`

### Fixes

- Fix path in `README` usage instructions (Closes: #2)
- Replace BASH parameter expansion with good ol' trusty `awk` (Closes: #1)

## [0.3.1] - 07-06-2022

### Fixes

- Stop PMS to prevent script being killed

## [0.3.0] - 06-06-2022

### New

- Specify package download directory using `-d/--directory <path>`

## [0.2.0] - 03-06-2022

### New

- `AARCH` and `REGEX_PLEX_VERSION` variables

### Changes

- Return `$AARCH` in Plex Media Server version

### Fixes

- Fix `[[ ]]` string comparisons

## [0.1.0] - 31-05-2022

Initial release.
