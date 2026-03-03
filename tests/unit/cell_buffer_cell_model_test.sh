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

cell_buffer_width=2
cell_buffer_height=2
cell_front_chars=(' ' ' ' ' ' ' ')
cell_front_fgs=(7 7 7 7)
cell_front_bgs=(0 0 0 0)
cell_front_attrs=(0 0 0 0)
cell_back_chars=(' ' ' ' ' ' ' ')
cell_back_fgs=(7 7 7 7)
cell_back_bgs=(0 0 0 0)
cell_back_attrs=(0 0 0 0)

cell_buffer_set_cell_at_index front 0 'A' 1 2 3
cell_buffer_set_cell_at_index back 3 'Z' 4 5 6

assert_eq 'A|1|2|3' "$(cell_buffer_get_cell front 0 0)" 'front cell stores char/fg/bg/attrs'
assert_eq 'Z|4|5|6' "$(cell_buffer_get_cell back 1 1)" 'back cell stores char/fg/bg/attrs'
assert_eq '4' "$(cell_buffer_cell_count)" 'cell count uses width and height'

if cell_buffer_get_cell invalid 0 0 >/dev/null 2>&1; then
  printf 'FAIL: invalid buffer name should fail\n' >&2
  exit 1
fi

printf 'PASS: cell buffer cell model tests\n'
