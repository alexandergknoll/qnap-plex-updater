# qnap-plex-updater

Shell script aimed at updating Plex Media Server on QNAP servers.

## Prerequisites:

None beyond what QTS/QuTS ships. The script is POSIX `sh` and calls only
QNAP's own tools (`getcfg`, `curl`, `notice_log_tool`) and busybox applets.

Entware is needed by the installation method below, not by the script: for
`git`, and to make `/opt` persistent. On QTS the root filesystem is a RAM
disk, so a checkout in `/opt` does not survive a reboot unless Entware backs
it with storage. To skip it, see [Without Entware](#without-entware).

## Installation

With [Entware](https://github.com/Entware/entware/wiki/Install-on-QNAP-NAS)
installed, clone the repository:

```bash
$ cd /opt/
$ git clone https://github.com/barnumbirr/qnap-plex-updater.git
$ cd qnap-plex-updater
$ chmod +x bin/qnap-plex-updater
```

Update it with `git -C /opt/qnap-plex-updater pull`.

### Without Entware

The script is a single file, so copy it onto a share, which survives reboots
as `/opt` on its own does not:

```bash
$ mkdir -p /share/Public/qnap-plex-updater
$ /sbin/curl -o /share/Public/qnap-plex-updater/qnap-plex-updater \
    https://raw.githubusercontent.com/barnumbirr/qnap-plex-updater/master/bin/qnap-plex-updater
$ chmod +x /share/Public/qnap-plex-updater/qnap-plex-updater
```

Adjust the paths in the examples below to match, and update by re-running the
`curl`.

## Usage

### Manual

```bash
[~] # /opt/qnap-plex-updater/bin/qnap-plex-updater --channel public --notify
Downloading Plex Media Server 1.43.2.10687-563d026ea-x86_64...
Stopping Plex Media Server...
Installing and restarting Plex Media Server...
Plex Media Server 1.43.2.10687-563d026ea-x86_64 installed successfully!
[~] #
```

The success message only prints after the install is verified: the installed
version is re-read, the package must still be enabled, and the server must
answer on `:32400` (up to 90 seconds). Anything short of that exits non-zero
— and with `--notify`, reports a failure instead.

When the latest version is already installed, the script exits cleanly:

```bash
[~] # /opt/qnap-plex-updater/bin/qnap-plex-updater --channel public
Latest Plex Media Server version (1.43.2.10687-563d026ea-x86_64) already installed, exiting...
[~] #
```

### Check for updates

Use `--check` to see if an update is available without installing:

```bash
[~] # /opt/qnap-plex-updater/bin/qnap-plex-updater --check --channel beta
Update available: 1.43.2.10687-563d026ea -> 1.43.3.10828-00f62d37d-x86_64
```

Exits 0 if an update is available, 1 if already up to date — useful for scripting:

```bash
if /opt/qnap-plex-updater/bin/qnap-plex-updater --check --channel public; then
  echo "Plex update available"
fi
```

### Changelog link

Use `--changelog` to show a link to the new version's release post in the
[Plex Media Server forum thread](https://forums.plex.tv/t/plex-media-server/30447):

```bash
[~] # /opt/qnap-plex-updater/bin/qnap-plex-updater --check --channel beta --changelog
Update available: 1.43.2.10687-563d026ea -> 1.43.3.10828-00f62d37d-x86_64
Changelog: https://forums.plex.tv/t/plex-media-server/30447/710
```

Combined with `--notify`, the link is also appended to the QTS success notification.
If the post can't be resolved (e.g. the release hasn't been announced on the forum
yet), the link falls back to the thread itself.

### Force reinstall

Use `--force` to reinstall even if the latest version is already installed:

```bash
[~] # /opt/qnap-plex-updater/bin/qnap-plex-updater --force --channel public
```

### Logging

Use `--log` to append timestamped output to a file (useful for cron jobs):

```bash
[~] # /opt/qnap-plex-updater/bin/qnap-plex-updater --channel public --notify --log /var/log/plex-updater.log
```

### Verbose output

Use `-V/--verbose` to enable shell tracing and pass through the QNAP qpkg installer output. By default the installer's output is suppressed for cleaner cron logs:

```bash
[~] # /opt/qnap-plex-updater/bin/qnap-plex-updater --channel beta --verbose
```

The Plex token is never included in the trace output.

### Cron job schedule

```bash
$ echo "0 */6 * * * /opt/qnap-plex-updater/bin/qnap-plex-updater --channel public --notify --log /var/log/plex-updater.log" >> /etc/config/crontab
$ crontab /etc/config/crontab && /etc/init.d/crond.sh restart
```

#### Important Notes for Automated Updates

**Security Considerations:**

When running via cron or other automated methods, the script implements additional security safeguards:

- **Checksum Verification**: The script will automatically abort if it cannot fetch or verify the package checksum from the Plex API. This prevents installation of potentially corrupted or compromised packages.
- **No Interactive Prompts**: In non-interactive mode (cron, scripts), security warnings cannot be confirmed and will cause the update to abort automatically.

**Monitoring Recommendations:**

To ensure updates are working correctly when running via cron:

1. **Check System Logs**: Review logs to identify when updates fail due to checksum verification or other security checks:
   ```bash
   grep "qnap-plex-updater" /var/log/messages
   ```

2. **Email Notifications**: Consider redirecting output to email instead of `/dev/null`:
   ```bash
   0 */6 * * * /opt/qnap-plex-updater/bin/qnap-plex-updater --channel public --notify 2>&1 | mail -s "Plex Update" admin@example.com
   ```

3. **Test Manually First**: Always test the updater manually before setting up automated runs:
   ```bash
   /opt/qnap-plex-updater/bin/qnap-plex-updater --channel public --notify
   ```

**Common Automated Failure Scenarios:**

- **Network Issues**: Temporary connectivity problems with plex.tv
- **API Unavailability**: Plex API may be temporarily down or rate-limited
- **Checksum Unavailable**: New releases may not immediately have checksums published
- **Authentication Issues**: Expired or invalid Plex authentication tokens

If automated updates consistently fail, run the script manually to see detailed error messages and resolve the underlying issue.

## License:

```
Copyright 2022-2026 Martin Simon

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Buy me a coffee?

If you feel like buying me a coffee (or a beer?), donations are welcome:

```
BTC : bc1qq04jnuqqavpccfptmddqjkg7cuspy3new4sxq9
DOGE: DRBkryyau5CMxpBzVmrBAjK6dVdMZSBsuS
ETH : 0x2238A11856428b72E80D70Be8666729497059d95
LTC : MQwXsBrArLRHQzwQZAjJPNrxGS1uNDDKX6
```
