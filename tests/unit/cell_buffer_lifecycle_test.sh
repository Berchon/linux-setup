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

if cell_buffer_init 0 3 >/dev/null 2>&1; then
  printf 'FAIL: init must reject zero dimensions\n' >&2
  exit 1
fi

cell_buffer_init 3 2
assert_eq '3' "$cell_buffer_width" 'init stores width'
assert_eq '2' "$cell_buffer_height" 'init stores height'
assert_eq '6' "${#cell_front_chars[@]}" 'front buffer has all cells'
assert_eq '6' "${#cell_back_chars[@]}" 'back buffer has all cells'
assert_eq ' |7|0|0' "$(cell_buffer_get_cell front 0 0)" 'front starts at defaults'
assert_eq ' |7|0|0' "$(cell_buffer_get_cell back 2 1)" 'back starts at defaults'

cell_buffer_set_cell_at_index front 0 'F' 1 2 3
cell_buffer_set_cell_at_index back 0 'B' 4 5 6
cell_buffer_swap
assert_eq 'B|4|5|6' "$(cell_buffer_get_cell front 0 0)" 'swap moves back to front'
assert_eq 'F|1|2|3' "$(cell_buffer_get_cell back 0 0)" 'swap keeps old front in back'

cell_buffer_reset_buffer back
assert_eq ' |7|0|0' "$(cell_buffer_get_cell back 0 0)" 'reset_buffer resets a single buffer'

cell_buffer_set_cell_at_index front 1 'X' 1 1 1
cell_buffer_set_cell_at_index back 1 'Y' 2 2 2
cell_buffer_reset
assert_eq ' |7|0|0' "$(cell_buffer_get_cell front 1 0)" 'reset resets front'
assert_eq ' |7|0|0' "$(cell_buffer_get_cell back 1 0)" 'reset resets back'

printf 'PASS: cell buffer lifecycle tests\n'
