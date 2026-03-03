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

assert_fails() {
  local message="$1"
  shift

  if "$@" >/dev/null 2>&1; then
    printf 'FAIL: %s\n' "$message" >&2
    exit 1
  fi
}

dirty_regions_init 8 3

dirty_regions_add 0 0 2 2
dirty_regions_add 4 0 2 2
assert_eq '2' "$(dirty_regions_count)" 'non-adjacent regions should stay split'
assert_fails 'get should reject out-of-range index' dirty_regions_get 2
assert_fails 'get should reject negative index' dirty_regions_get -1

dirty_regions_remove_at 0
assert_eq '1' "$(dirty_regions_count)" 'remove_at should shrink registry'
assert_eq '4|0|2|2' "$(dirty_regions_get 0)" 'remove_at should reindex remaining regions'
assert_fails 'remove_at should reject out-of-range index' dirty_regions_remove_at 9

assert_eq '0|0|8|3' "$(dirty_regions_clip_rect -4 -4 20 20)" 'clip_rect should clamp to full viewport'

if dirty_regions_clip_rect 8 0 2 1 >/dev/null 2>&1; then
  printf 'FAIL: clip_rect should reject fully outside rect\n' >&2
  exit 1
fi

if dirty_regions_init 8 0 >/dev/null 2>&1; then
  printf 'FAIL: init should reject invalid viewport\n' >&2
  exit 1
fi

printf 'PASS: dirty regions boundary tests\n'
