#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../src/render/cell_buffer.sh
source "$SCRIPT_DIR/../../src/render/cell_buffer.sh"
# shellcheck source=../../src/render/dirty_regions.sh
source "$SCRIPT_DIR/../../src/render/dirty_regions.sh"
# shellcheck source=../../src/render/diff_renderer.sh
source "$SCRIPT_DIR/../../src/render/diff_renderer.sh"

assert_le() {
  local actual="$1"
  local expected="$2"
  local message="$3"

  if ((actual > expected)); then
    printf 'FAIL: %s (expected<=%s actual=%s)\n' "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

capture_ansi=''
diff_renderer_emit_ansi() {
  capture_ansi+="$1"
}

cell_buffer_init 80 24
dirty_regions_init 80 24

cell_buffer_write_text front 2 2 'Keyboard K380' 7 0 1
cell_buffer_write_text front 2 3 'Keyboard K270' 7 0 0
cell_buffer_write_text back 2 2 'Keyboard K380' 7 0 0
cell_buffer_write_text back 2 3 'Keyboard K270' 7 0 1

dirty_regions_invalidate_menu_delta 2 2 20 0 1

diff_renderer_render_dirty

assert_le "$(diff_renderer_run_count)" 2 'selection delta should keep run count bounded to two lines'
assert_le "${#capture_ansi}" 140 'ansi payload for single selection delta should stay within budget'

printf 'PASS: diff renderer delta render budget perf test\n'
