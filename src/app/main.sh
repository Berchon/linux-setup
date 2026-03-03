#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../core/terminal.sh
source "$SCRIPT_DIR/../core/terminal.sh"
# shellcheck source=app_shell.sh
source "$SCRIPT_DIR/app_shell.sh"

app::main() {
  app_shell::main
}

app::main "$@"
