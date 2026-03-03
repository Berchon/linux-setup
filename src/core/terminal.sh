#!/usr/bin/env bash

# Terminal runtime helpers for setup/cleanup with idempotent restoration.

TERMINAL_CLEANED=0
TERMINAL_SETUP_DONE=0
TERMINAL_STTY_ORIG=""
TERMINAL_ALTSCREEN_ACTIVE=0
TERMINAL_RESIZE_PENDING=0
TERMINAL_CAP_CURSOR_POSITIONING=0
TERMINAL_CAP_CLEAR_SCREEN=0
TERMINAL_CAP_CURSOR_VISIBILITY=0
TERMINAL_SUPPORTS_MINIMUM=0

terminal::has_tput() {
  command -v tput >/dev/null 2>&1
}

terminal::tput() {
  tput "$@"
}

terminal::emit_ansi() {
  printf '%b' "$1"
}

terminal::has_tty() {
  [ -t 0 ] && [ -t 1 ]
}

terminal::detect_capabilities() {
  TERMINAL_CAP_CURSOR_POSITIONING=0
  TERMINAL_CAP_CLEAR_SCREEN=0
  TERMINAL_CAP_CURSOR_VISIBILITY=0
  TERMINAL_SUPPORTS_MINIMUM=0

  if ! terminal::has_tty || ! terminal::has_tput; then
    return 0
  fi

  if terminal::tput cup 0 0 >/dev/null 2>&1; then
    TERMINAL_CAP_CURSOR_POSITIONING=1
  fi

  if terminal::tput clear >/dev/null 2>&1; then
    TERMINAL_CAP_CLEAR_SCREEN=1
  fi

  if terminal::tput civis >/dev/null 2>&1 && terminal::tput cnorm >/dev/null 2>&1; then
    TERMINAL_CAP_CURSOR_VISIBILITY=1
  fi

  if [ "$TERMINAL_CAP_CURSOR_POSITIONING" -eq 1 ] \
    && [ "$TERMINAL_CAP_CLEAR_SCREEN" -eq 1 ] \
    && [ "$TERMINAL_CAP_CURSOR_VISIBILITY" -eq 1 ]; then
    TERMINAL_SUPPORTS_MINIMUM=1
  fi
}

terminal::enter_alternate_screen() {
  if [ "$TERMINAL_ALTSCREEN_ACTIVE" -eq 1 ]; then
    return 0
  fi

  if [ "${LINUX_SETUP_TERMINAL_DISABLE_ALTSCREEN:-0}" = "1" ]; then
    return 0
  fi

  if ! terminal::has_tty; then
    return 0
  fi

  if terminal::has_tput && terminal::tput smcup >/dev/null 2>&1; then
    TERMINAL_ALTSCREEN_ACTIVE=1
    return 0
  fi

  if terminal::emit_ansi '\033[?1049h' >/dev/null 2>&1; then
    TERMINAL_ALTSCREEN_ACTIVE=1
  fi
}

terminal::leave_alternate_screen() {
  if [ "$TERMINAL_ALTSCREEN_ACTIVE" -ne 1 ]; then
    return 0
  fi

  if terminal::has_tty && terminal::has_tput && terminal::tput rmcup >/dev/null 2>&1; then
    TERMINAL_ALTSCREEN_ACTIVE=0
    return 0
  fi

  if terminal::has_tty; then
    terminal::emit_ansi '\033[?1049l' >/dev/null 2>&1 || true
  fi

  TERMINAL_ALTSCREEN_ACTIVE=0
}

terminal::hide_cursor() {
  [ "${LINUX_SETUP_TERMINAL_DISABLE_CURSOR:-0}" = "1" ] && return 0
  printf '\033[?25l'
}

terminal::show_cursor() {
  printf '\033[?25h'
}

terminal::enable_raw_mode() {
  if [ "${LINUX_SETUP_TERMINAL_DISABLE_STTY:-0}" = "1" ]; then
    return 0
  fi

  if terminal::has_tty && command -v stty >/dev/null 2>&1; then
    TERMINAL_STTY_ORIG="$(stty -g 2>/dev/null || true)"
    stty -echo -icanon time 0 min 1 2>/dev/null || true
  fi
}

terminal::restore_stty() {
  if [ -n "$TERMINAL_STTY_ORIG" ] && command -v stty >/dev/null 2>&1 && terminal::has_tty; then
    stty "$TERMINAL_STTY_ORIG" 2>/dev/null || true
  fi
}

terminal::cleanup() {
  if [ "$TERMINAL_CLEANED" -eq 1 ]; then
    return 0
  fi

  TERMINAL_CLEANED=1
  terminal::restore_stty
  terminal::show_cursor
  terminal::leave_alternate_screen
}

terminal::handle_winch() {
  TERMINAL_RESIZE_PENDING=1
}

terminal::consume_resize_event() {
  if [ "$TERMINAL_RESIZE_PENDING" -eq 0 ]; then
    return 1
  fi

  TERMINAL_RESIZE_PENDING=0
  return 0
}

terminal::handle_exit() {
  terminal::cleanup
}

terminal::handle_interrupt() {
  terminal::cleanup
  exit 130
}

terminal::handle_terminate() {
  terminal::cleanup
  exit 143
}

terminal::install_traps() {
  trap 'terminal::handle_exit' EXIT
  trap 'terminal::handle_interrupt' INT
  trap 'terminal::handle_terminate' TERM
  trap 'terminal::handle_winch' WINCH
}

terminal::setup() {
  if [ "$TERMINAL_SETUP_DONE" -eq 1 ]; then
    return 0
  fi

  TERMINAL_SETUP_DONE=1
  terminal::detect_capabilities
  terminal::install_traps
  terminal::enter_alternate_screen
  terminal::hide_cursor
  terminal::enable_raw_mode
}
