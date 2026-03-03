#!/usr/bin/env bash

# Terminal runtime helpers for setup/cleanup with idempotent restoration.

TERMINAL_CLEANED=0
TERMINAL_SETUP_DONE=0
TERMINAL_STTY_ORIG=""
TERMINAL_ALTSCREEN_ACTIVE=0

terminal::has_tty() {
  [ -t 0 ] && [ -t 1 ]
}

terminal::enter_alternate_screen() {
  if [ "${LINUX_SETUP_TERMINAL_DISABLE_ALTSCREEN:-0}" = "1" ]; then
    return 0
  fi

  if command -v tput >/dev/null 2>&1 && terminal::has_tty; then
    tput smcup >/dev/null 2>&1 || printf '\033[?1049h'
  else
    printf '\033[?1049h'
  fi
  TERMINAL_ALTSCREEN_ACTIVE=1
}

terminal::leave_alternate_screen() {
  if [ "$TERMINAL_ALTSCREEN_ACTIVE" -ne 1 ]; then
    return 0
  fi

  if command -v tput >/dev/null 2>&1 && terminal::has_tty; then
    tput rmcup >/dev/null 2>&1 || printf '\033[?1049l'
  else
    printf '\033[?1049l'
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

terminal::install_traps() {
  trap 'terminal::cleanup' EXIT INT TERM
}

terminal::setup() {
  if [ "$TERMINAL_SETUP_DONE" -eq 1 ]; then
    return 0
  fi

  TERMINAL_SETUP_DONE=1
  terminal::install_traps
  terminal::enter_alternate_screen
  terminal::hide_cursor
  terminal::enable_raw_mode
}
