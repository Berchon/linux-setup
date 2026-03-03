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

cell_buffer_init 8 2
dirty_regions_init 8 2

cell_buffer_write_cell back 0 0 'A' 2 3 1
cell_buffer_write_cell back 1 0 'B' 2 3 1
cell_buffer_write_cell back 2 0 'C' 6 1 0
cell_buffer_write_cell back 4 0 'D' 2 3 1
cell_buffer_write_cell back 5 0 'E' 2 3 1
cell_buffer_write_cell back 7 1 'Z' 4 2 0

dirty_regions_add 0 0 6 1
diff_renderer_collect_runs

assert_eq '3' "$(diff_renderer_run_count)" 'runs should group only contiguous cells with same style'
assert_eq '0|0|AB|2|3|1' "$(diff_renderer_get_run 0)" 'first run should merge same-style contiguous cells'
assert_eq '2|0|C|6|1|0' "$(diff_renderer_get_run 1)" 'style change should create a new run'
assert_eq '4|0|DE|2|3|1' "$(diff_renderer_get_run 2)" 'unchanged gap should split runs even with same style'

dirty_regions_reset
dirty_regions_add 7 1 1 1
diff_renderer_collect_runs
assert_eq '1' "$(diff_renderer_run_count)" 'run collection should follow current dirty region set'
assert_eq '7|1|Z|4|2|0' "$(diff_renderer_get_run 0)" 'region run should keep coordinates and style'

printf 'PASS: diff renderer style runs tests\n'
