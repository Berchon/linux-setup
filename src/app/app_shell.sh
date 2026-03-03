#!/usr/bin/env bash

APP_SHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../core/terminal.sh
source "$APP_SHELL_DIR/../core/terminal.sh"
# shellcheck source=../render/cell_buffer.sh
source "$APP_SHELL_DIR/../render/cell_buffer.sh"
# shellcheck source=../render/dirty_regions.sh
source "$APP_SHELL_DIR/../render/dirty_regions.sh"
# shellcheck source=../render/diff_renderer.sh
source "$APP_SHELL_DIR/../render/diff_renderer.sh"
# shellcheck source=../components/rectangle.sh
source "$APP_SHELL_DIR/../components/rectangle.sh"

app_shell_screen_width=80
app_shell_screen_height=24

runtime_emit_ansi() {
  terminal::emit_ansi "$1"
}

app_shell::read_terminal_size() {
  local width=80
  local height=24

  if terminal::has_tput && terminal::has_tty; then
    width="$(terminal::tput cols 2>/dev/null || printf '80')"
    height="$(terminal::tput lines 2>/dev/null || printf '24')"
  fi

  if [[ ! "$width" =~ ^[1-9][0-9]*$ ]]; then
    width=80
  fi

  if [[ ! "$height" =~ ^[1-9][0-9]*$ ]]; then
    height=24
  fi

  printf '%s|%s\n' "$width" "$height"
}

app_shell::init_render_context() {
  local size=""

  size="$(app_shell::read_terminal_size)" || return 1
  IFS='|' read -r app_shell_screen_width app_shell_screen_height <<< "$size"

  cell_buffer_init "$app_shell_screen_width" "$app_shell_screen_height" || return 1
  dirty_regions_init "$app_shell_screen_width" "$app_shell_screen_height" || return 1
}

app_shell::compute_demo_rectangle() {
  local margin_left=2
  local margin_top=1
  local margin_right=4
  local margin_bottom=0
  local x=10
  local y=10
  local width=40
  local height=8
  local max_width=0
  local max_height=0
  local max_x=0
  local max_y=0

  max_width=$((app_shell_screen_width - margin_left - margin_right))
  if ((max_width < 1)); then
    max_width=1
  fi
  if ((width > max_width)); then
    width="$max_width"
  fi

  max_height=$((app_shell_screen_height - margin_top - margin_bottom))
  if ((max_height < 1)); then
    max_height=1
  fi
  if ((height > max_height)); then
    height="$max_height"
  fi

  if ((x < margin_left)); then
    x="$margin_left"
  fi

  if ((y < margin_top)); then
    y="$margin_top"
  fi

  max_x=$((app_shell_screen_width - margin_right - width))
  if ((max_x < margin_left)); then
    max_x="$margin_left"
  fi
  if ((x > max_x)); then
    x="$max_x"
  fi

  max_y=$((app_shell_screen_height - margin_bottom - height))
  if ((max_y < margin_top)); then
    max_y="$margin_top"
  fi
  if ((y > max_y)); then
    y="$max_y"
  fi

  printf '%s|%s|%s|%s\n' "$x" "$y" "$width" "$height"
}

app_shell::render_demo_rectangle() {
  local rect=""
  local x=0
  local y=0
  local width=0
  local height=0

  cell_buffer_reset_buffer back || return 1
  rectangle_set_border_charset auto || return 1

  rect="$(app_shell::compute_demo_rectangle)" || return 1
  IFS='|' read -r x y width height <<< "$rect"

  rectangle_render back "$x" "$y" "$width" "$height" " " 7 4 0 single "linux-setup rectangle" 2 1 4 0 || return 1
  dirty_regions_add 0 0 "$app_shell_screen_width" "$app_shell_screen_height" || return 1
  diff_renderer_render_dirty
}

app_shell::render() {
  app_shell::render_demo_rectangle
}

app_shell::on_resize() {
  app_shell::init_render_context || return 1
  app_shell::render
}

app_shell::loop() {
  local key=""

  while true; do
    if terminal::consume_resize_event; then
      app_shell::on_resize
    fi

    if read -r -s -n 1 -t 0.1 key; then
      case "$key" in
        q|Q)
          break
          ;;
      esac
    fi
  done
}

app_shell::main() {
  terminal::setup
  app_shell::init_render_context || return 1
  app_shell::render || return 1
  app_shell::loop
  terminal::cleanup
}
