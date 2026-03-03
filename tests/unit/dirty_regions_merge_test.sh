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

dirty_regions_init 80 24

dirty_regions_add 0 0 4 2
dirty_regions_add 2 1 4 3
assert_eq '1' "$(dirty_regions_count)" 'overlapping regions should be merged'
assert_eq '0|0|6|4' "$(dirty_regions_get 0)" 'merge should keep union bounds'

dirty_regions_reset
dirty_regions_add 0 0 2 2
dirty_regions_add 2 0 2 2
assert_eq '1' "$(dirty_regions_count)" 'touching edges should merge as adjacent regions'
assert_eq '0|0|4|2' "$(dirty_regions_get 0)" 'adjacent merge should include full combined extent'

dirty_regions_reset
dirty_regions_add 0 0 2 2
dirty_regions_add 3 0 2 2
assert_eq '2' "$(dirty_regions_count)" 'regions separated by a gap should remain separated'

printf 'PASS: dirty regions merge tests\n'
