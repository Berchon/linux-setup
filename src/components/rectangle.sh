#!/usr/bin/env bash

rectangle_border_charset='auto'
rectangle_border_tl='+'
rectangle_border_tr='+'
rectangle_border_bl='+'
rectangle_border_br='+'
rectangle_border_h='-'
rectangle_border_v='|'

rectangle_is_integer() {
  [[ "$1" =~ ^-?[0-9]+$ ]]
}

rectangle_is_non_negative_integer() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

rectangle_border_style_is_valid() {
  case "$1" in
    none|single|double)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

rectangle_validate_render_args() {
  local x="$1"
  local y="$2"
  local width="$3"
  local height="$4"
  local border_style="$5"

  if ! rectangle_is_integer "${x}" || ! rectangle_is_integer "${y}"; then
    return 1
  fi

  if ! rectangle_is_non_negative_integer "${width}" || ! rectangle_is_non_negative_integer "${height}"; then
    return 1
  fi

  rectangle_border_style_is_valid "${border_style}"
}

rectangle_clip_rect() {
  local x="$1"
  local y="$2"
  local width="$3"
  local height="$4"
  local start_x=0
  local start_y=0
  local end_x=0
  local end_y=0

  if ! rectangle_is_integer "${x}" || ! rectangle_is_integer "${y}"; then
    return 1
  fi

  if ! rectangle_is_non_negative_integer "${width}" || ! rectangle_is_non_negative_integer "${height}"; then
    return 1
  fi

  if ! rectangle_is_non_negative_integer "${cell_buffer_width:-}" || ! rectangle_is_non_negative_integer "${cell_buffer_height:-}"; then
    return 1
  fi

  if ((width == 0 || height == 0)); then
    printf '0|0|0|0\n'
    return 0
  fi

  start_x="${x}"
  start_y="${y}"
  end_x=$((x + width))
  end_y=$((y + height))

  if ((start_x < 0)); then
    start_x=0
  fi
  if ((start_y < 0)); then
    start_y=0
  fi
  if ((end_x > cell_buffer_width)); then
    end_x="${cell_buffer_width}"
  fi
  if ((end_y > cell_buffer_height)); then
    end_y="${cell_buffer_height}"
  fi

  if ((start_x >= end_x || start_y >= end_y)); then
    printf '0|0|0|0\n'
    return 0
  fi

  printf '%s|%s|%s|%s\n' "${start_x}" "${start_y}" "$((end_x - start_x))" "$((end_y - start_y))"
}

rectangle_compute_geometry() {
  local x="$1"
  local y="$2"
  local width="$3"
  local height="$4"
  local border_style="$5"
  local inner_x="$x"
  local inner_y="$y"
  local inner_width="$width"
  local inner_height="$height"

  if [[ "${border_style}" != 'none' ]]; then
    inner_x=$((x + 1))
    inner_y=$((y + 1))
    if ((width >= 2)); then
      inner_width=$((width - 2))
    else
      inner_width=0
    fi
    if ((height >= 2)); then
      inner_height=$((height - 2))
    else
      inner_height=0
    fi
  fi

  printf '%s|%s|%s|%s|%s|%s|%s|%s\n' \
    "${x}" "${y}" "${width}" "${height}" \
    "${inner_x}" "${inner_y}" "${inner_width}" "${inner_height}"
}

rectangle_render_fill() {
  local buffer_name="$1"
  local x="$2"
  local y="$3"
  local width="$4"
  local height="$5"
  local fill_char="$6"
  local fg="$7"
  local bg="$8"
  local bold="$9"
  local clipped=''
  local start_x=0
  local start_y=0
  local clipped_width=0
  local clipped_height=0
  local end_x=0
  local end_y=0
  local current_x=0
  local current_y=0

  if ! declare -F cell_buffer_write_cell >/dev/null; then
    return 1
  fi

  clipped="$(rectangle_clip_rect "${x}" "${y}" "${width}" "${height}")" || return 1
  IFS='|' read -r start_x start_y clipped_width clipped_height <<< "${clipped}"

  if ((clipped_width == 0 || clipped_height == 0)); then
    return 0
  fi

  if [[ -z "${fill_char}" ]]; then
    fill_char=' '
  fi
  fill_char="${fill_char:0:1}"

  end_x=$((start_x + clipped_width))
  end_y=$((start_y + clipped_height))

  for ((current_y = start_y; current_y < end_y; current_y++)); do
    for ((current_x = start_x; current_x < end_x; current_x++)); do
      cell_buffer_write_cell "${buffer_name}" "${current_x}" "${current_y}" "${fill_char}" "${fg}" "${bg}" "${bold}"
    done
  done
}

rectangle_set_border_charset() {
  local charset="$1"

  case "${charset}" in
    auto|ascii|unicode)
      rectangle_border_charset="${charset}"
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

rectangle_runtime_charset_is_utf8() {
  local locale_value=''

  locale_value="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
  locale_value="${locale_value,,}"

  [[ "${locale_value}" == *"utf-8"* || "${locale_value}" == *"utf8"* ]]
}

rectangle_resolve_border_charset() {
  if [[ "${rectangle_border_charset}" == 'ascii' ]]; then
    printf 'ascii\n'
    return 0
  fi

  if [[ "${rectangle_border_charset}" == 'unicode' ]]; then
    printf 'unicode\n'
    return 0
  fi

  if rectangle_runtime_charset_is_utf8; then
    printf 'unicode\n'
    return 0
  fi

  printf 'ascii\n'
}

rectangle_border_chars() {
  local border_style="$1"
  local charset=''

  if [[ "${rectangle_border_charset}" != 'auto' && "${rectangle_border_charset}" != 'ascii' && "${rectangle_border_charset}" != 'unicode' ]]; then
    return 1
  fi

  charset="$(rectangle_resolve_border_charset)" || return 1

  case "${border_style}" in
    single)
      if [[ "${charset}" == 'unicode' ]]; then
        rectangle_border_tl='┌'
        rectangle_border_tr='┐'
        rectangle_border_bl='└'
        rectangle_border_br='┘'
        rectangle_border_h='─'
        rectangle_border_v='│'
      else
        rectangle_border_tl='+'
        rectangle_border_tr='+'
        rectangle_border_bl='+'
        rectangle_border_br='+'
        rectangle_border_h='-'
        rectangle_border_v='|'
      fi
      return 0
      ;;
    double)
      if [[ "${charset}" == 'unicode' ]]; then
        rectangle_border_tl='╔'
        rectangle_border_tr='╗'
        rectangle_border_bl='╚'
        rectangle_border_br='╝'
        rectangle_border_h='═'
        rectangle_border_v='║'
      else
        rectangle_border_tl='+'
        rectangle_border_tr='+'
        rectangle_border_bl='+'
        rectangle_border_br='+'
        rectangle_border_h='='
        rectangle_border_v='|'
      fi
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

rectangle_write_visible_cell() {
  local buffer_name="$1"
  local x="$2"
  local y="$3"
  local cell_char="$4"
  local fg="$5"
  local bg="$6"
  local bold="$7"

  if ((x < 0 || y < 0 || x >= cell_buffer_width || y >= cell_buffer_height)); then
    return 0
  fi

  cell_buffer_write_cell "${buffer_name}" "${x}" "${y}" "${cell_char}" "${fg}" "${bg}" "${bold}"
}

rectangle_render_border() {
  local buffer_name="$1"
  local x="$2"
  local y="$3"
  local width="$4"
  local height="$5"
  local border_style="$6"
  local fg="$7"
  local bg="$8"
  local bold="$9"
  local right=0
  local bottom=0
  local current_x=0
  local current_y=0

  if [[ "${border_style}" == 'none' ]] || ((width == 0 || height == 0)); then
    return 0
  fi

  rectangle_border_chars "${border_style}" || return 1

  right=$((x + width - 1))
  bottom=$((y + height - 1))

  rectangle_write_visible_cell "${buffer_name}" "${x}" "${y}" "${rectangle_border_tl}" "${fg}" "${bg}" "${bold}"

  if ((width > 1)); then
    rectangle_write_visible_cell "${buffer_name}" "${right}" "${y}" "${rectangle_border_tr}" "${fg}" "${bg}" "${bold}"
  fi

  if ((height > 1)); then
    rectangle_write_visible_cell "${buffer_name}" "${x}" "${bottom}" "${rectangle_border_bl}" "${fg}" "${bg}" "${bold}"
    if ((width > 1)); then
      rectangle_write_visible_cell "${buffer_name}" "${right}" "${bottom}" "${rectangle_border_br}" "${fg}" "${bg}" "${bold}"
    fi
  fi

  for ((current_x = x + 1; current_x < right; current_x++)); do
    rectangle_write_visible_cell "${buffer_name}" "${current_x}" "${y}" "${rectangle_border_h}" "${fg}" "${bg}" "${bold}"
    if ((height > 1)); then
      rectangle_write_visible_cell "${buffer_name}" "${current_x}" "${bottom}" "${rectangle_border_h}" "${fg}" "${bg}" "${bold}"
    fi
  done

  for ((current_y = y + 1; current_y < bottom; current_y++)); do
    rectangle_write_visible_cell "${buffer_name}" "${x}" "${current_y}" "${rectangle_border_v}" "${fg}" "${bg}" "${bold}"
    if ((width > 1)); then
      rectangle_write_visible_cell "${buffer_name}" "${right}" "${current_y}" "${rectangle_border_v}" "${fg}" "${bg}" "${bold}"
    fi
  done
}

rectangle_title_compute_start_x() {
  local x="$1"
  local border_style="$2"

  if [[ "${border_style}" == 'none' ]]; then
    printf '%s\n' "${x}"
    return 0
  fi

  printf '%s\n' "$((x + 1))"
}

rectangle_title_compute_max_width() {
  local width="$1"
  local border_style="$2"

  if [[ "${border_style}" == 'none' ]]; then
    printf '%s\n' "${width}"
    return 0
  fi

  if ((width <= 2)); then
    printf '0\n'
    return 0
  fi

  printf '%s\n' "$((width - 2))"
}

rectangle_render_title() {
  local buffer_name="$1"
  local x="$2"
  local y="$3"
  local width="$4"
  local height="$5"
  local border_style="$6"
  local title="$7"
  local fg="$8"
  local bg="$9"
  local bold="${10}"
  local title_start_x=0
  local title_max_width=0
  local clipped_title=''

  if [[ -z "${title}" ]]; then
    return 0
  fi

  if ! declare -F cell_buffer_write_text >/dev/null; then
    return 1
  fi

  if ((width == 0 || height == 0)); then
    return 0
  fi

  title_start_x="$(rectangle_title_compute_start_x "${x}" "${border_style}")" || return 1
  title_max_width="$(rectangle_title_compute_max_width "${width}" "${border_style}")" || return 1
  if ((title_max_width <= 0)); then
    return 0
  fi

  clipped_title="${title:0:title_max_width}"
  cell_buffer_write_text "${buffer_name}" "${title_start_x}" "${y}" "${clipped_title}" "${fg}" "${bg}" "${bold}"
}

# x,y,width,height always represent the full rectangle area drawn on screen.
rectangle_render() {
  local buffer_name="$1"
  local x="$2"
  local y="$3"
  local width="$4"
  local height="$5"
  local fill_char="$6"
  local fg="$7"
  local bg="$8"
  local bold="$9"
  local border_style="${10:-none}"
  local title="${11:-}"
  local geometry=''
  local outer_x=0
  local outer_y=0
  local outer_width=0
  local outer_height=0

  rectangle_validate_render_args "${x}" "${y}" "${width}" "${height}" "${border_style}" || return 1
  geometry="$(rectangle_compute_geometry "${x}" "${y}" "${width}" "${height}" "${border_style}")" || return 1
  IFS='|' read -r outer_x outer_y outer_width outer_height _ _ _ _ <<< "${geometry}"

  if ((outer_width == 0 || outer_height == 0)); then
    return 0
  fi

  rectangle_render_fill "${buffer_name}" "${outer_x}" "${outer_y}" "${outer_width}" "${outer_height}" "${fill_char}" "${fg}" "${bg}" "${bold}" || return 1
  rectangle_render_border "${buffer_name}" "${x}" "${y}" "${width}" "${height}" "${border_style}" "${fg}" "${bg}" "${bold}" || return 1
  rectangle_render_title "${buffer_name}" "${x}" "${y}" "${width}" "${height}" "${border_style}" "${title}" "${fg}" "${bg}" "${bold}"
}
