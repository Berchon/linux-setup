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
