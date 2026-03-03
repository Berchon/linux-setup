#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../src/render/cell_buffer.sh
source "$SCRIPT_DIR/../../src/render/cell_buffer.sh"
# shellcheck source=../../src/render/dirty_regions.sh
source "$SCRIPT_DIR/../../src/render/dirty_regions.sh"
# shellcheck source=../../src/render/diff_renderer.sh
source "$SCRIPT_DIR/../../src/render/diff_renderer.sh"

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [ "$expected" != "$actual" ]; then
    printf 'FAIL: %s (expected=%s actual=%s)\n' "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

cell_buffer_init 6 3
dirty_regions_init 6 3

cell_buffer_write_cell back 1 0 'A' 2 3 1
cell_buffer_write_cell back 5 2 'Z' 4 5 0

dirty_regions_add 0 0 3 1
diff_renderer_collect_changed_cells
assert_eq '1' "$(diff_renderer_changed_count)" 'diff should compare only cells inside dirty regions'
assert_eq '1|0' "$(diff_renderer_get_changed_cell 0)" 'changed cell inside dirty region should be collected'

dirty_regions_reset
dirty_regions_add 4 2 2 1
diff_renderer_collect_changed_cells
assert_eq '1' "$(diff_renderer_changed_count)" 'second pass should only include newly tracked dirty area'
assert_eq '5|2' "$(diff_renderer_get_changed_cell 0)" 'change outside previous dirty region should be collected when region is marked'

dirty_regions_reset
diff_renderer_collect_changed_cells
assert_eq '0' "$(diff_renderer_changed_count)" 'no dirty regions should produce empty diff set'

printf 'PASS: diff renderer dirty-region compare tests\n'
