#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../src/core/terminal.sh
source "$SCRIPT_DIR/../../src/core/terminal.sh"

assert_eq() {
  local expected="$1"
  local actual="$2"
  local label="$3"

  if [ "$expected" != "$actual" ]; then
    printf 'FAIL: %s (expected=%s actual=%s)\n' "$label" "$expected" "$actual" >&2
    exit 1
  fi
}

terminal::has_tty() {
  return 0
}

terminal::has_tput() {
  return 0
}

terminal::tput() {
  case "$1" in
    cup|clear|civis|cnorm)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

terminal::detect_capabilities
assert_eq "1" "$TERMINAL_CAP_CURSOR_POSITIONING" "cursor positioning capability should be detected"
assert_eq "1" "$TERMINAL_CAP_CLEAR_SCREEN" "clear screen capability should be detected"
assert_eq "1" "$TERMINAL_CAP_CURSOR_VISIBILITY" "cursor visibility capability should be detected"
assert_eq "1" "$TERMINAL_SUPPORTS_MINIMUM" "minimum terminal capabilities should be supported"

terminal::tput() {
  case "$1" in
    cup|civis|cnorm)
      return 0
      ;;
    clear)
      return 1
      ;;
    *)
      return 1
      ;;
  esac
}

terminal::detect_capabilities
assert_eq "1" "$TERMINAL_CAP_CURSOR_POSITIONING" "cursor positioning should stay available in degraded profile"
assert_eq "0" "$TERMINAL_CAP_CLEAR_SCREEN" "clear capability should be marked unavailable"
assert_eq "1" "$TERMINAL_CAP_CURSOR_VISIBILITY" "cursor visibility should remain available"
assert_eq "0" "$TERMINAL_SUPPORTS_MINIMUM" "minimum capability flag should fail when any required capability is missing"

terminal::has_tty() {
  return 1
}

terminal::detect_capabilities
assert_eq "0" "$TERMINAL_SUPPORTS_MINIMUM" "non-tty session should not report minimum capabilities"

printf 'PASS: terminal capabilities tests\n'
