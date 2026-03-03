#!/usr/bin/env bash

cell_buffer_width=0
cell_buffer_height=0

cell_buffer_default_char=' '
cell_buffer_default_fg=7
cell_buffer_default_bg=0
cell_buffer_default_attrs=0

declare -ag cell_front_chars=()
declare -ag cell_front_fgs=()
declare -ag cell_front_bgs=()
declare -ag cell_front_attrs=()
declare -ag cell_back_chars=()
declare -ag cell_back_fgs=()
declare -ag cell_back_bgs=()
declare -ag cell_back_attrs=()

cell_buffer_is_positive_integer() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

cell_buffer_is_integer() {
  [[ "$1" =~ ^-?[0-9]+$ ]]
}

cell_buffer_cell_count() {
  printf '%s\n' "$((cell_buffer_width * cell_buffer_height))"
}

cell_buffer_validate_buffer_name() {
  case "$1" in
    front|back)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

cell_buffer_index() {
  local x="$1"
  local y="$2"

  if ! cell_buffer_is_integer "$x" || ! cell_buffer_is_integer "$y"; then
    return 1
  fi

  if ((x < 0 || y < 0 || x >= cell_buffer_width || y >= cell_buffer_height)); then
    return 1
  fi

  printf '%s\n' "$((y * cell_buffer_width + x))"
}

cell_buffer_set_cell_at_index() {
  local buffer_name="$1"
  local idx="$2"
  local cell_char="$3"
  local fg="$4"
  local bg="$5"
  local attrs="$6"

  if ! cell_buffer_validate_buffer_name "$buffer_name"; then
    return 1
  fi

  case "$buffer_name" in
    front)
      cell_front_chars[idx]="$cell_char"
      cell_front_fgs[idx]="$fg"
      cell_front_bgs[idx]="$bg"
      cell_front_attrs[idx]="$attrs"
      ;;
    back)
      cell_back_chars[idx]="$cell_char"
      cell_back_fgs[idx]="$fg"
      cell_back_bgs[idx]="$bg"
      cell_back_attrs[idx]="$attrs"
      ;;
  esac
}

cell_buffer_reset_buffer() {
  local buffer_name="$1"
  local count=0
  local idx=0

  if ! cell_buffer_validate_buffer_name "$buffer_name"; then
    return 1
  fi

  count="$(cell_buffer_cell_count)"
  for ((idx = 0; idx < count; idx++)); do
    cell_buffer_set_cell_at_index \
      "$buffer_name" \
      "$idx" \
      "$cell_buffer_default_char" \
      "$cell_buffer_default_fg" \
      "$cell_buffer_default_bg" \
      "$cell_buffer_default_attrs"
  done
}

cell_buffer_reset() {
  cell_buffer_reset_buffer front
  cell_buffer_reset_buffer back
}

cell_buffer_init() {
  local width="$1"
  local height="$2"

  if ! cell_buffer_is_positive_integer "$width" || ! cell_buffer_is_positive_integer "$height"; then
    printf "cell_buffer: invalid dimensions '%s'x'%s'\n" "$width" "$height" >&2
    return 1
  fi

  cell_buffer_width="$width"
  cell_buffer_height="$height"

  cell_front_chars=()
  cell_front_fgs=()
  cell_front_bgs=()
  cell_front_attrs=()
  cell_back_chars=()
  cell_back_fgs=()
  cell_back_bgs=()
  cell_back_attrs=()

  cell_buffer_reset
}

cell_buffer_swap() {
  local -a tmp_chars=("${cell_front_chars[@]}")
  local -a tmp_fgs=("${cell_front_fgs[@]}")
  local -a tmp_bgs=("${cell_front_bgs[@]}")
  local -a tmp_attrs=("${cell_front_attrs[@]}")

  cell_front_chars=("${cell_back_chars[@]}")
  cell_front_fgs=("${cell_back_fgs[@]}")
  cell_front_bgs=("${cell_back_bgs[@]}")
  cell_front_attrs=("${cell_back_attrs[@]}")

  cell_back_chars=("${tmp_chars[@]}")
  cell_back_fgs=("${tmp_fgs[@]}")
  cell_back_bgs=("${tmp_bgs[@]}")
  cell_back_attrs=("${tmp_attrs[@]}")
}

cell_buffer_get_cell() {
  local buffer_name="$1"
  local x="$2"
  local y="$3"
  local idx=0

  if ! idx="$(cell_buffer_index "$x" "$y")"; then
    return 1
  fi

  if ! cell_buffer_validate_buffer_name "$buffer_name"; then
    return 1
  fi

  case "$buffer_name" in
    front)
      printf '%s|%s|%s|%s\n' \
        "${cell_front_chars[idx]}" \
        "${cell_front_fgs[idx]}" \
        "${cell_front_bgs[idx]}" \
        "${cell_front_attrs[idx]}"
      ;;
    back)
      printf '%s|%s|%s|%s\n' \
        "${cell_back_chars[idx]}" \
        "${cell_back_fgs[idx]}" \
        "${cell_back_bgs[idx]}" \
        "${cell_back_attrs[idx]}"
      ;;
  esac
}
