#!/usr/bin/env bash

# OS type detection
env::is_linux()   { [[ "${OSTYPE}" == "linux-gnu" ]]; }
env::is_darwin()  { [[ "${OSTYPE}" == "darwin"* ]]; }
env::is_freebsd() { [[ "${OSTYPE}" == "freebsd"* ]]; }
env::is_cygwin()  { [[ "${OSTYPE}" == "cygwin" ]]; }
env::is_msys()    { [[ "${OSTYPE}" == "msys" ]]; }

# OS type
env::ostype() {
  if env::is_darwin; then echo "darwin"; fi; return
  if env::is_freebsd; then echo "freebsd"; fi; return
  echo "${OSTYPE}"
}

# Shell type
env::is_login_shell() { [[ "$0" == "-"* ]]; }
env::is_interactive_shell() { [[ -n "$PS1" ]]; }

# Tell if a command exists
env::has_command() { command -v "$1" >/dev/null 2>&1; }
env::is_gnu_command() { [[ -n "$("$1" --version 2>/dev/null | grep "GNU")" ]]; }
