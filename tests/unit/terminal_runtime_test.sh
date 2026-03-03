#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../src/core/terminal.sh
source "$SCRIPT_DIR/../../src/core/terminal.sh"

pass_count=0
fail_count=0

assert_eq() {
  local expected="$1"
  local actual="$2"
  local label="$3"

  if [ "$expected" = "$actual" ]; then
    pass_count=$((pass_count + 1))
    printf 'PASS: %s\n' "$label"
  else
    fail_count=$((fail_count + 1))
    printf 'FAIL: %s (expected=%s actual=%s)\n' "$label" "$expected" "$actual"
  fi
}

assert_contains() {
  local content="$1"
  local snippet="$2"
  local label="$3"

  if [[ "$content" == *"$snippet"* ]]; then
    pass_count=$((pass_count + 1))
    printf 'PASS: %s\n' "$label"
  else
    fail_count=$((fail_count + 1))
    printf 'FAIL: %s (missing=%s content=%s)\n' "$label" "$snippet" "$content"
  fi
}

reset_state() {
  TERMINAL_CLEANED=0
  TERMINAL_SETUP_DONE=0
  TERMINAL_STTY_ORIG=""
  TERMINAL_ALTSCREEN_ACTIVE=0
  TERMINAL_RESIZE_PENDING=0
}

test_cleanup_idempotent() {
  reset_state
  terminal::cleanup
  local first="$TERMINAL_CLEANED"
  terminal::cleanup
  local second="$TERMINAL_CLEANED"

  assert_eq "1" "$first" "cleanup marks terminal as cleaned"
  assert_eq "1" "$second" "cleanup remains stable on second call"
}

test_setup_idempotent() {
  reset_state
  LINUX_SETUP_TERMINAL_DISABLE_STTY=1
  LINUX_SETUP_TERMINAL_DISABLE_ALTSCREEN=1
  LINUX_SETUP_TERMINAL_DISABLE_CURSOR=1

  terminal::setup
  local first="$TERMINAL_SETUP_DONE"
  terminal::setup
  local second="$TERMINAL_SETUP_DONE"

  assert_eq "1" "$first" "setup marks runtime as configured"
  assert_eq "1" "$second" "setup remains stable on second call"
}

test_alt_screen_flag() {
  reset_state
  LINUX_SETUP_TERMINAL_DISABLE_ALTSCREEN=0

  terminal::enter_alternate_screen >/dev/null
  assert_eq "1" "$TERMINAL_ALTSCREEN_ACTIVE" "alternate screen flag enabled"

  terminal::leave_alternate_screen >/dev/null
  assert_eq "0" "$TERMINAL_ALTSCREEN_ACTIVE" "alternate screen flag disabled"
}

test_winch_runtime_flag_and_trap() {
  reset_state
  terminal::handle_winch
  assert_eq "1" "$TERMINAL_RESIZE_PENDING" "WINCH handler marks resize as pending"

  terminal::consume_resize_event
  assert_eq "0" "$TERMINAL_RESIZE_PENDING" "resize pending flag is cleared after consume"

  terminal::install_traps
  assert_contains "$(trap -p WINCH)" "terminal::handle_winch" "WINCH trap is installed"
}

main() {
  test_cleanup_idempotent
  test_setup_idempotent
  test_alt_screen_flag
  test_winch_runtime_flag_and_trap

  printf '\nTotal: %s pass, %s fail\n' "$pass_count" "$fail_count"
  [ "$fail_count" -eq 0 ]
}

main "$@"
