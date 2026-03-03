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

assert_contains_not() {
  local content="$1"
  local snippet="$2"
  local message="$3"

  if [[ "$content" == *"$snippet"* ]]; then
    printf 'FAIL: %s (snippet=%q)\n' "$message" "$snippet" >&2
    exit 1
  fi
}

ansi_output=''
runtime_emit_ansi() {
  ansi_output+="$1"
}

cell_buffer_init 10 3
dirty_regions_init 10 3

cell_buffer_write_text front 0 0 'HEADER....' 7 0 0
cell_buffer_write_text back 0 0 'HEADER....' 7 0 0
cell_buffer_write_text front 0 1 'ITEM A....' 7 0 0
cell_buffer_write_text back 0 1 'ITEM A....' 7 0 0

cell_buffer_write_cell back 5 1 'X' 2 0 1
dirty_regions_add 5 1 1 1

diff_renderer_render_dirty

assert_eq '1' "$(diff_renderer_run_count)" 'single-cell delta should produce a single run'
assert_contains_not "$ansi_output" $'\033[2J' 'incremental render should not emit full clear sequence'
if ((${#ansi_output} > 24)); then
  printf 'FAIL: incremental ansi payload should stay compact (len=%s)\n' "${#ansi_output}" >&2
  exit 1
fi

printf 'PASS: diff renderer incremental integration tests\n'
