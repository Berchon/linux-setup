#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../core/terminal.sh
source "$SCRIPT_DIR/../core/terminal.sh"

app::loop() {
  local key=""

  while true; do
    if terminal::consume_resize_event; then
      app::on_resize
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

app::on_resize() {
  :
}

app::main() {
  terminal::setup
  app::loop
  terminal::cleanup
}

app::main "$@"
