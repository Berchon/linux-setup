#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../src/render/cell_buffer.sh
source "$SCRIPT_DIR/../../src/render/cell_buffer.sh"
# shellcheck source=../../src/components/rectangle.sh
source "$SCRIPT_DIR/../../src/components/rectangle.sh"

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [ "$expected" != "$actual" ]; then
    printf 'FAIL: %s (expected=%s actual=%s)\n' "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_fails() {
  local message="$1"
  shift

  if "$@" >/dev/null 2>&1; then
    printf 'FAIL: %s\n' "$message" >&2
    exit 1
  fi
}

cell_buffer_init 12 6
rectangle_set_border_charset ascii

rectangle_render_fill back 1 1 3 2 "." 2 4 1
assert_eq '.|2|4|1' "$(cell_buffer_get_cell back 1 1)" 'fill should write first clipped cell'
assert_eq '.|2|4|1' "$(cell_buffer_get_cell back 3 2)" 'fill should write last clipped cell'

rectangle_render_fill back -2 0 3 2 "x" 1 3 0
assert_eq 'x|1|3|0' "$(cell_buffer_get_cell back 0 0)" 'fill should clip left overflow'

cell_buffer_reset_buffer back
rectangle_render back 1 1 6 3 "." 2 5 1 single
assert_eq '+|2|5|1' "$(cell_buffer_get_cell back 1 1)" 'single border should render top-left corner'
assert_eq '-|2|5|1' "$(cell_buffer_get_cell back 3 1)" 'single border should render top horizontal edge'
assert_eq '||2|5|1' "$(cell_buffer_get_cell back 1 2)" 'single border should render vertical edge'
assert_eq '.|2|5|1' "$(cell_buffer_get_cell back 3 2)" 'single border should keep inner fill'

cell_buffer_reset_buffer back
rectangle_render back 1 1 6 3 "." 3 6 0 double
assert_eq '+|3|6|0' "$(cell_buffer_get_cell back 1 1)" 'double border ascii should render corner fallback'
assert_eq '=|3|6|0' "$(cell_buffer_get_cell back 2 1)" 'double border ascii should render horizontal fallback'

cell_buffer_reset_buffer back
rectangle_render back 1 1 8 3 "." 6 1 1 single "TITLE-LONG"
assert_eq 'T|6|1|1' "$(cell_buffer_get_cell back 2 1)" 'title should start after left border'
assert_eq '-|6|1|1' "$(cell_buffer_get_cell back 7 1)" 'title should be clipped by border width'
assert_eq '+|6|1|1' "$(cell_buffer_get_cell back 8 1)" 'title should preserve right corner'

cell_buffer_reset_buffer back
rectangle_render back 0 0 4 2 "." 5 2 0 none "HELLO"
assert_eq 'H|5|2|0' "$(cell_buffer_get_cell back 0 0)" 'title without border should start at x'
assert_eq 'L|5|2|0' "$(cell_buffer_get_cell back 3 0)" 'title without border should clip to rectangle width'

cell_buffer_reset_buffer back
rectangle_render back -1 0 4 3 "." 1 2 0 single
assert_eq '-|1|2|0' "$(cell_buffer_get_cell back 0 0)" 'border should clip top edge when x is negative'
assert_eq '+|1|2|0' "$(cell_buffer_get_cell back 2 0)" 'border should render visible top-right corner'

cell_buffer_reset_buffer back
rectangle_render back 1 1 10 5 "." 2 3 0 single "M" 2 1 1 0
assert_eq '.|2|3|0' "$(cell_buffer_get_cell back 1 1)" 'outer area should remain filled when margin is used'
assert_eq '+|2|3|0' "$(cell_buffer_get_cell back 3 2)" 'border should be inset by external margins'
assert_eq 'M|2|3|0' "$(cell_buffer_get_cell back 4 2)" 'title should follow inset border origin'

cell_buffer_write_cell back 0 5 'Z' 9 9 9
rectangle_render back 2 2 0 3 "." 1 1 0 none "IGNORED"
assert_eq 'Z|9|9|9' "$(cell_buffer_get_cell back 0 5)" 'zero-width rectangle should not mutate buffer'

assert_fails 'render should reject non-integer x' rectangle_render back foo 0 2 2 "." 1 1 0 none
assert_fails 'render should reject negative width' rectangle_render back 0 0 -1 2 "." 1 1 0 none
assert_fails 'render should reject invalid border style' rectangle_render back 0 0 2 2 "." 1 1 0 weird

printf 'PASS: rectangle component and boundary tests\n'
