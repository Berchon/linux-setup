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
    printf 'FAIL: %s\nexpected: %q\nactual:   %q\n' "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

ansi_output=''
runtime_emit_ansi() {
  ansi_output+="$1"
}

cell_buffer_init 4 1
dirty_regions_init 4 1

cell_buffer_write_cell back 0 0 'A' 2 3 1
cell_buffer_write_cell back 2 0 'C' 2 3 1
dirty_regions_add 0 0 4 1

diff_renderer_render_dirty

assert_eq $'\033[1;1H\033[1;32;43mA\033[1;3HC' "$ansi_output" 'renderer should emit cursor moves and avoid repeating style sequence'
assert_eq 'A|2|3|1' "$(cell_buffer_get_cell front 0 0)" 'render should swap back buffer into front'
assert_eq 'C|2|3|1' "$(cell_buffer_get_cell front 2 0)" 'render should keep changed cells after swap'
assert_eq ' |7|0|0' "$(cell_buffer_get_cell back 0 0)" 'swap should move previous front into back buffer'
assert_eq '0' "$(dirty_regions_count)" 'render should clear dirty regions after flush'

printf 'PASS: diff renderer emit and swap tests\n'
