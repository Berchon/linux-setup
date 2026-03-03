#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../src/render/dirty_regions.sh
source "$SCRIPT_DIR/../../src/render/dirty_regions.sh"

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [ "$expected" != "$actual" ]; then
    printf 'FAIL: %s (expected=%s actual=%s)\n' "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

dirty_regions_init 20 10

dirty_regions_invalidate_menu_delta 2 3 8 1 4
assert_eq '2' "$(dirty_regions_count)" 'menu delta should invalidate previous and next rows'
assert_eq '2|4|8|1' "$(dirty_regions_get 0)" 'menu delta should invalidate old selected row'
assert_eq '2|7|8|1' "$(dirty_regions_get 1)" 'menu delta should invalidate new selected row'

dirty_regions_reset
dirty_regions_invalidate_clock 0 0 20
assert_eq '1' "$(dirty_regions_count)" 'clock tick should invalidate a single line'
assert_eq '0|0|20|1' "$(dirty_regions_get 0)" 'clock invalidation should target provided line'

dirty_regions_reset
dirty_regions_invalidate_modal 5 2 6 4
assert_eq '1' "$(dirty_regions_count)" 'modal open should invalidate modal rect'
assert_eq '5|2|6|4' "$(dirty_regions_get 0)" 'modal open invalidation should match modal area'

dirty_regions_reset
dirty_regions_invalidate_modal 7 2 6 4 5 2 6 4
assert_eq '1' "$(dirty_regions_count)" 'modal move should merge old and new rects'
assert_eq '5|2|8|4' "$(dirty_regions_get 0)" 'modal move invalidation should cover old and new areas'

dirty_regions_reset
dirty_regions_invalidate_resize
assert_eq '1' "$(dirty_regions_count)" 'resize should invalidate full viewport'
assert_eq '0|0|20|10' "$(dirty_regions_get 0)" 'resize invalidation should match full viewport'

printf 'PASS: dirty regions invalidation policy tests\n'
