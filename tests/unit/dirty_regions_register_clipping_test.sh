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

if dirty_regions_init 0 24 >/dev/null 2>&1; then
  printf 'FAIL: dirty_regions_init should reject invalid viewport\n' >&2
  exit 1
fi

dirty_regions_init 10 4
assert_eq '10' "$dirty_regions_screen_width" 'viewport width should be initialized'
assert_eq '4' "$dirty_regions_screen_height" 'viewport height should be initialized'
assert_eq '0' "$(dirty_regions_count)" 'registry should start empty'

dirty_regions_add -2 -1 4 3
assert_eq '1' "$(dirty_regions_count)" 'negative origin should be clipped into viewport'
assert_eq '0|0|2|2' "$(dirty_regions_get 0)" 'clipped region should keep only visible area'

dirty_regions_add 8 3 5 3
assert_eq '2' "$(dirty_regions_count)" 'right and bottom overflow should be clipped and kept'
assert_eq '8|3|2|1' "$(dirty_regions_get 1)" 'region should clip to viewport limits'

dirty_regions_add 15 0 2 2
dirty_regions_add 0 8 3 3
assert_eq '2' "$(dirty_regions_count)" 'out-of-viewport regions should be ignored'

dirty_regions_add 2 1 0 3
assert_eq '2' "$(dirty_regions_count)" 'zero-size regions should be ignored'

if dirty_regions_add x 1 2 2 >/dev/null 2>&1; then
  printf 'FAIL: dirty_regions_add should reject invalid coordinates\n' >&2
  exit 1
fi

dirty_regions_reset
assert_eq '0' "$(dirty_regions_count)" 'reset should clear all regions'

printf 'PASS: dirty regions register clipping tests\n'
