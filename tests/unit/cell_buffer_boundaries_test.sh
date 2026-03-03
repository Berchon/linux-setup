#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../src/render/cell_buffer.sh
source "$SCRIPT_DIR/../../src/render/cell_buffer.sh"

assert_eq() {
  local expected="$1"
  local actual="$2"
  local label="$3"

  if [ "$expected" != "$actual" ]; then
    printf 'FAIL: %s (expected=%s actual=%s)\n' "$label" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_fails() {
  local label="$1"
  shift

  if "$@" >/dev/null 2>&1; then
    printf 'FAIL: %s\n' "$label" >&2
    exit 1
  fi
}

cell_buffer_init 5 4
cell_buffer_write_text back 0 0 'ABCDE' 1 2 3
cell_buffer_write_text back 0 1 'ABCDE' 1 2 3
cell_buffer_write_text back 0 2 'ABCDE' 1 2 3
cell_buffer_write_text back 0 3 'ABCDE' 1 2 3

assert_fails 'index rejects out-of-bounds x' cell_buffer_index 5 0
assert_fails 'index rejects non-integer values' cell_buffer_index x 0

cell_buffer_clear_rect back -2 -1 3 3
assert_eq ' |7|0|0' "$(cell_buffer_get_cell back 0 0)" 'clear_rect clips negative origin into viewport'
assert_eq 'B|1|2|3' "$(cell_buffer_get_cell back 1 0)" 'clear_rect clipping does not overflow extra columns'

cell_buffer_clear_rect back 0 0 0 0
assert_eq 'E|1|2|3' "$(cell_buffer_get_cell back 4 3)" 'zero-size clear_rect is a no-op'

cell_buffer_write_text back 0 -1 'DROP' 9 9 9
assert_eq 'A|1|2|3' "$(cell_buffer_get_cell back 0 3)" 'write_text outside viewport y is a no-op'

assert_fails 'clear_rect rejects invalid width' cell_buffer_clear_rect back 0 0 -1 2
assert_fails 'write_cell rejects invalid buffer name' cell_buffer_write_cell invalid 0 0 A 1 1 1

printf 'PASS: cell buffer boundary tests\n'
