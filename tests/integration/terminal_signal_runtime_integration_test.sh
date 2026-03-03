#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_MAIN="${ROOT_DIR}/src/app/main.sh"

assert_eq() {
  local expected="$1"
  local actual="$2"
  local label="$3"

  if [ "$expected" != "$actual" ]; then
    printf 'FAIL: %s (expected=%s actual=%s)\n' "$label" "$expected" "$actual" >&2
    exit 1
  fi
}

run_with_signal() {
  local signal_name="$1"
  local rc=0

  LINUX_SETUP_TERMINAL_DISABLE_STTY=1 \
  LINUX_SETUP_TERMINAL_DISABLE_ALTSCREEN=1 \
  LINUX_SETUP_TERMINAL_DISABLE_CURSOR=1 \
  setsid bash "$APP_MAIN" >/dev/null 2>&1 &
  local pid=$!

  sleep 0.2
  kill -s WINCH -- "-$pid" >/dev/null 2>&1 || true
  sleep 0.1
  kill -s "$signal_name" -- "-$pid"

  if wait "$pid"; then
    rc=0
  else
    rc=$?
  fi

  printf '%s' "$rc"
}

assert_setup_loop_cleanup_nominal() {
  local rc=0

  if printf 'q' | LINUX_SETUP_TERMINAL_DISABLE_STTY=1 LINUX_SETUP_TERMINAL_DISABLE_ALTSCREEN=1 LINUX_SETUP_TERMINAL_DISABLE_CURSOR=1 bash "$APP_MAIN" >/dev/null 2>&1; then
    rc=0
  else
    rc=$?
  fi

  assert_eq "0" "$rc" "nominal setup/loop/cleanup should exit with success"
}

main() {
  assert_setup_loop_cleanup_nominal

  local term_rc
  term_rc="$(run_with_signal TERM)"
  assert_eq "143" "$term_rc" "TERM signal should end runtime with 143"

  printf 'PASS: terminal signal runtime integration tests\n'
}

main "$@"
