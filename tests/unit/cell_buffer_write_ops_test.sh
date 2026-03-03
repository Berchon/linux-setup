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

cell_buffer_init 6 3

cell_buffer_write_cell back 1 0 'A' 2 3 4
assert_eq 'A|2|3|4' "$(cell_buffer_get_cell back 1 0)" 'write_cell stores char and style'

if cell_buffer_write_cell back 9 0 'Z' 1 1 1 >/dev/null 2>&1; then
  printf 'FAIL: write_cell out-of-bounds should fail\n' >&2
  exit 1
fi

cell_buffer_write_cell back 2 0 'AB' 5 6 7
assert_eq 'A|5|6|7' "$(cell_buffer_get_cell back 2 0)" 'write_cell keeps a single character per cell'

cell_buffer_write_text back 0 1 'HELLO' 6 1 2
assert_eq 'H|6|1|2' "$(cell_buffer_get_cell back 0 1)" 'write_text writes first character'
assert_eq 'O|6|1|2' "$(cell_buffer_get_cell back 4 1)" 'write_text writes sequential characters'

cell_buffer_write_text back -1 0 'AB' 3 4 5
assert_eq 'B|3|4|5' "$(cell_buffer_get_cell back 0 0)" 'write_text clips left overflow'

cell_buffer_write_text back 5 2 'XYZ' 8 9 1
assert_eq 'X|8|9|1' "$(cell_buffer_get_cell back 5 2)" 'write_text clips right overflow'

cell_buffer_clear_rect back 1 1 3 2
assert_eq ' |7|0|0' "$(cell_buffer_get_cell back 1 1)" 'clear_rect clears clipped region'
assert_eq ' |7|0|0' "$(cell_buffer_get_cell back 3 2)" 'clear_rect clears end of region'

printf 'PASS: cell buffer write ops tests\n'
