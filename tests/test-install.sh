#!/bin/sh
# Behavior matrix for install() in bin/qnap-plex-updater.
#
# Extracts the real log/die/install functions and runs them against stubbed
# QNAP dependencies (installer, init script, config reader, server probe),
# asserting the outcome for each installer-exit-code / verification
# combination. Runs on any POSIX system; no QNAP required.
#
# Usage: sh tests/test-install.sh
set -u

TESTDIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="${TESTDIR}/../bin/qnap-plex-updater"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

FUNCS="$WORK/funcs.sh"
sed -n '/^log()/,/^}/p;/^die()/,/^}/p;/^install()/,/^}/p' "$SCRIPT" > "$FUNCS"

REMOTE=1.43.3.10828-00f62d37d
PASS=0; FAIL=0

# run_install <installer-rc> <probe-version> <enable> <alive-after-n-polls|never> [stop-marker]
run_install() {
  _rc=$1 _probe=$2 _enable=$3 _alive=$4 _marker=${5-}

  printf '#!/bin/sh\necho "INSTALLER NOISE"\nexit %s\n' "$_rc" > "$WORK/fake.qpkg"
  printf '#!/bin/sh\necho "Stopping Plex Media Server..."\n%s\n' \
    "${_marker:+echo \"$_marker\"}" > "$WORK/fake-stop.sh"
  chmod +x "$WORK/fake-stop.sh"
  : > "$WORK/polls"

  OUT="$(sh -eu -c "
    . '$FUNCS'
    get_local_version() { LOCAL_PLEX_VERSION='$_probe'; }
    parse_config_file() { echo '$_enable'; }
    server_alive() {
      echo x >> '$WORK/polls'
      [ '$_alive' != never ] && [ \"\$(wc -l < '$WORK/polls')\" -ge '$_alive' ]
    }
    sleep() { :; }
    LOG_FILE=''; NOTIFY=0; CHANGELOG=0; VERBOSE=0
    PLEX_INIT_SCRIPT='$WORK/fake-stop.sh'
    QPKG_FILE='$WORK/fake.qpkg'
    QPKG_CONF=/etc/config/qpkg.conf
    QPKG_NAME=PlexMediaServer
    REMOTE_PLEX_VERSION='$REMOTE'
    AARCH=x86_64
    install
  " 2>&1)"
  EXIT=$?
}

# assert <name> <want-exit> <want-success y/n> <want-note y/n> <want-warning y/n>
assert() {
  _name=$1 _wexit=$2 _wok=$3 _wnote=$4 _wwarn=$5

  _ok=n;   case "$OUT" in *"installed successfully!"*) _ok=y ;; esac
  _note=n; case "$OUT" in *"verifying installed version"*) _note=y ;; esac
  _warn=n; case "$OUT" in *"force-killed"*)            _warn=y ;; esac

  _v=PASS
  [ "$EXIT" -eq "$_wexit" ] || _v=FAIL
  [ "$_ok" = "$_wok" ]      || _v=FAIL
  [ "$_note" = "$_wnote" ]  || _v=FAIL
  [ "$_warn" = "$_wwarn" ]  || _v=FAIL

  if [ "$_v" = PASS ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi
  printf '%-4s %-42s exit=%s/%s success=%s/%s note=%s/%s warn=%s/%s\n' \
    "$_v" "$_name" "$EXIT" "$_wexit" "$_ok" "$_wok" "$_note" "$_wnote" "$_warn" "$_wwarn"
  [ "$_v" = PASS ] || printf '     output: %s\n' "$(printf '%s' "$OUT" | tr '\n' '|')"
}

#           rc  probe                    enable alive         name                                        exit ok note warn
run_install 10 "$REMOTE"                 TRUE   1;           assert "rc=10 success (QDK default)"          0    y  n    n
run_install 0  "$REMOTE"                 TRUE   1;           assert "rc=0 success (QDK keep-file)"         0    y  n    n
run_install 7  "$REMOTE"                 TRUE   1;           assert "rc=7 unexpected but verified"         0    y  y    n
run_install 10 "1.43.3.10793-fb0000000"  TRUE   1;           assert "rc=10 but version mismatch"           1    n  n    n
run_install 1  "1.43.3.10793-fb0000000"  TRUE   1;           assert "rc=1 wrapper failure + mismatch"      1    n  y    n
run_install 10 "$REMOTE"                 FALSE  1;           assert "installer auto-disabled the package"  1    n  n    n
run_install 10 "$REMOTE"                 TRUE   never;       assert "server never comes up (liveness)"     1    n  n    n
run_install 10 "$REMOTE"                 TRUE   4;           assert "server up after a few polls"          0    y  n    n
run_install 10 "$REMOTE"                 TRUE   1 "Terminating residual service processes"; \
                                                             assert "stop-phase force-kill warned"         0    y  n    y

# The LD_LIBRARY_PATH strip is a single top-level builtin; assert it exists.
if grep -qx 'unset LD_LIBRARY_PATH' "$SCRIPT"; then
  PASS=$((PASS+1)); echo "PASS unset LD_LIBRARY_PATH present at top level"
else
  FAIL=$((FAIL+1)); echo "FAIL unset LD_LIBRARY_PATH missing"
fi

echo "----"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
