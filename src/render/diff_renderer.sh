#!/usr/bin/env bash

declare -ag diff_renderer_changed_xs=()
declare -ag diff_renderer_changed_ys=()
declare -ag diff_renderer_run_xs=()
declare -ag diff_renderer_run_ys=()
declare -ag diff_renderer_run_texts=()
declare -ag diff_renderer_run_fgs=()
declare -ag diff_renderer_run_bgs=()
declare -ag diff_renderer_run_attrs=()

diff_renderer_reset_changed_cells() {
  diff_renderer_changed_xs=()
  diff_renderer_changed_ys=()
}

diff_renderer_changed_count() {
  printf '%s\n' "${#diff_renderer_changed_xs[@]}"
}

diff_renderer_get_changed_cell() {
  local index="$1"

  if [[ ! "$index" =~ ^[0-9]+$ ]]; then
    return 1
  fi

  if ((index >= ${#diff_renderer_changed_xs[@]})); then
    return 1
  fi

  printf '%s|%s\n' "${diff_renderer_changed_xs[index]}" "${diff_renderer_changed_ys[index]}"
}

diff_renderer_reset_runs() {
  diff_renderer_run_xs=()
  diff_renderer_run_ys=()
  diff_renderer_run_texts=()
  diff_renderer_run_fgs=()
  diff_renderer_run_bgs=()
  diff_renderer_run_attrs=()
}

diff_renderer_run_count() {
  printf '%s\n' "${#diff_renderer_run_xs[@]}"
}

diff_renderer_get_run() {
  local index="$1"

  if [[ ! "$index" =~ ^[0-9]+$ ]]; then
    return 1
  fi

  if ((index >= ${#diff_renderer_run_xs[@]})); then
    return 1
  fi

  printf '%s|%s|%s|%s|%s|%s\n' \
    "${diff_renderer_run_xs[index]}" \
    "${diff_renderer_run_ys[index]}" \
    "${diff_renderer_run_texts[index]}" \
    "${diff_renderer_run_fgs[index]}" \
    "${diff_renderer_run_bgs[index]}" \
    "${diff_renderer_run_attrs[index]}"
}

diff_renderer_cell_differs_at_index() {
  local idx="$1"

  if [[ "${cell_front_chars[idx]}" != "${cell_back_chars[idx]}" ]]; then
    return 0
  fi

  if [[ "${cell_front_fgs[idx]}" != "${cell_back_fgs[idx]}" ]]; then
    return 0
  fi

  if [[ "${cell_front_bgs[idx]}" != "${cell_back_bgs[idx]}" ]]; then
    return 0
  fi

  if [[ "${cell_front_attrs[idx]}" != "${cell_back_attrs[idx]}" ]]; then
    return 0
  fi

  return 1
}

diff_renderer_collect_changed_cells() {
  local dirty_count=0
  local dirty_index=0
  local rect=""
  local rect_x=0
  local rect_y=0
  local rect_width=0
  local rect_height=0
  local y=0
  local x=0
  local idx=0
  local changed_index=0

  if ! declare -F dirty_regions_count >/dev/null 2>&1 || ! declare -F dirty_regions_get >/dev/null 2>&1; then
    return 1
  fi

  diff_renderer_reset_changed_cells
  dirty_count="$(dirty_regions_count)"

  for ((dirty_index = 0; dirty_index < dirty_count; dirty_index++)); do
    rect="$(dirty_regions_get "$dirty_index")"
    IFS='|' read -r rect_x rect_y rect_width rect_height <<< "$rect"

    for ((y = rect_y; y < rect_y + rect_height; y++)); do
      for ((x = rect_x; x < rect_x + rect_width; x++)); do
        idx=$((y * cell_buffer_width + x))

        if ! diff_renderer_cell_differs_at_index "$idx"; then
          continue
        fi

        changed_index="${#diff_renderer_changed_xs[@]}"
        diff_renderer_changed_xs[changed_index]="$x"
        diff_renderer_changed_ys[changed_index]="$y"
      done
    done
  done
}

diff_renderer_collect_runs() {
  local dirty_count=0
  local dirty_index=0
  local rect=""
  local rect_x=0
  local rect_y=0
  local rect_width=0
  local rect_height=0
  local x=0
  local y=0
  local idx=0
  local run_active=0
  local run_x=0
  local run_y=0
  local run_fg=0
  local run_bg=0
  local run_attrs=0
  local run_text=""
  local cell_char=""
  local cell_fg=0
  local cell_bg=0
  local cell_attrs=0
  local run_index=0

  if ! declare -F dirty_regions_count >/dev/null 2>&1 || ! declare -F dirty_regions_get >/dev/null 2>&1; then
    return 1
  fi

  diff_renderer_reset_runs
  dirty_count="$(dirty_regions_count)"

  for ((dirty_index = 0; dirty_index < dirty_count; dirty_index++)); do
    rect="$(dirty_regions_get "$dirty_index")"
    IFS='|' read -r rect_x rect_y rect_width rect_height <<< "$rect"

    for ((y = rect_y; y < rect_y + rect_height; y++)); do
      run_active=0
      run_text=""

      for ((x = rect_x; x < rect_x + rect_width; x++)); do
        idx=$((y * cell_buffer_width + x))

        if ! diff_renderer_cell_differs_at_index "$idx"; then
          if ((run_active == 1)); then
            run_index="${#diff_renderer_run_xs[@]}"
            diff_renderer_run_xs[run_index]="$run_x"
            diff_renderer_run_ys[run_index]="$run_y"
            diff_renderer_run_texts[run_index]="$run_text"
            diff_renderer_run_fgs[run_index]="$run_fg"
            diff_renderer_run_bgs[run_index]="$run_bg"
            diff_renderer_run_attrs[run_index]="$run_attrs"
            run_active=0
            run_text=""
          fi
          continue
        fi

        cell_char="${cell_back_chars[idx]}"
        cell_fg="${cell_back_fgs[idx]}"
        cell_bg="${cell_back_bgs[idx]}"
        cell_attrs="${cell_back_attrs[idx]}"

        if ((run_active == 1)) && [[ "$cell_fg" == "$run_fg" ]] && [[ "$cell_bg" == "$run_bg" ]] && [[ "$cell_attrs" == "$run_attrs" ]]; then
          run_text+="$cell_char"
          continue
        fi

        if ((run_active == 1)); then
          run_index="${#diff_renderer_run_xs[@]}"
          diff_renderer_run_xs[run_index]="$run_x"
          diff_renderer_run_ys[run_index]="$run_y"
          diff_renderer_run_texts[run_index]="$run_text"
          diff_renderer_run_fgs[run_index]="$run_fg"
          diff_renderer_run_bgs[run_index]="$run_bg"
          diff_renderer_run_attrs[run_index]="$run_attrs"
        fi

        run_active=1
        run_x="$x"
        run_y="$y"
        run_fg="$cell_fg"
        run_bg="$cell_bg"
        run_attrs="$cell_attrs"
        run_text="$cell_char"
      done

      if ((run_active == 1)); then
        run_index="${#diff_renderer_run_xs[@]}"
        diff_renderer_run_xs[run_index]="$run_x"
        diff_renderer_run_ys[run_index]="$run_y"
        diff_renderer_run_texts[run_index]="$run_text"
        diff_renderer_run_fgs[run_index]="$run_fg"
        diff_renderer_run_bgs[run_index]="$run_bg"
        diff_renderer_run_attrs[run_index]="$run_attrs"
      fi
    done
  done
}

diff_renderer_emit_ansi() {
  local sequence="$1"

  if declare -F runtime_emit_ansi >/dev/null 2>&1; then
    runtime_emit_ansi "$sequence"
    return 0
  fi

  printf '%b' "$sequence"
}

diff_renderer_cursor_sequence() {
  local x="$1"
  local y="$2"

  printf '\033[%s;%sH' "$((y + 1))" "$((x + 1))"
}

diff_renderer_style_sequence() {
  local fg="$1"
  local bg="$2"
  local attrs="$3"
  local fg_code=30
  local bg_code=40

  if [[ ! "$fg" =~ ^-?[0-9]+$ ]]; then
    fg=7
  fi
  if [[ ! "$bg" =~ ^-?[0-9]+$ ]]; then
    bg=0
  fi

  if ((fg < 0)); then fg=0; fi
  if ((bg < 0)); then bg=0; fi
  fg=$((fg % 16))
  bg=$((bg % 16))

  if ((fg < 8)); then
    fg_code=$((30 + fg))
  else
    fg_code=$((90 + fg - 8))
  fi

  if ((bg < 8)); then
    bg_code=$((40 + bg))
  else
    bg_code=$((100 + bg - 8))
  fi

  if [[ "$attrs" == "1" ]]; then
    printf '\033[1;%s;%sm' "$fg_code" "$bg_code"
    return 0
  fi

  printf '\033[22;%s;%sm' "$fg_code" "$bg_code"
}

diff_renderer_render_dirty() {
  local run_count=0
  local run_index=0
  local run_x=0
  local run_y=0
  local run_text=""
  local run_fg=0
  local run_bg=0
  local run_attrs=0
  local current_fg=""
  local current_bg=""
  local current_attrs=""
  local ansi_buffer=""

  if ! declare -F cell_buffer_swap >/dev/null 2>&1 || ! declare -F dirty_regions_reset >/dev/null 2>&1; then
    return 1
  fi

  diff_renderer_collect_runs || return 1
  run_count="${#diff_renderer_run_xs[@]}"

  for ((run_index = 0; run_index < run_count; run_index++)); do
    run_x="${diff_renderer_run_xs[run_index]}"
    run_y="${diff_renderer_run_ys[run_index]}"
    run_text="${diff_renderer_run_texts[run_index]}"
    run_fg="${diff_renderer_run_fgs[run_index]}"
    run_bg="${diff_renderer_run_bgs[run_index]}"
    run_attrs="${diff_renderer_run_attrs[run_index]}"

    ansi_buffer+="$(diff_renderer_cursor_sequence "$run_x" "$run_y")"

    if [[ "$run_fg" != "$current_fg" || "$run_bg" != "$current_bg" || "$run_attrs" != "$current_attrs" ]]; then
      ansi_buffer+="$(diff_renderer_style_sequence "$run_fg" "$run_bg" "$run_attrs")"
      current_fg="$run_fg"
      current_bg="$run_bg"
      current_attrs="$run_attrs"
    fi

    ansi_buffer+="$run_text"
  done

  if [[ -n "$ansi_buffer" ]]; then
    diff_renderer_emit_ansi "$ansi_buffer"
  fi

  cell_buffer_swap
  dirty_regions_reset
}
