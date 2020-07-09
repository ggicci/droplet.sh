#!/usr/bin/env bash
# env

# OS type detection
# https://stackoverflow.com/a/18434831/1592264
# https://en.wikipedia.org/wiki/Comparison_of_operating_system_kernels
env::os() { #? Tell the generic kernel name of the OS
  case "$( uname | tr '[:upper:]' '[:lower:]' )" in
    linux*)
      echo "linux"
      ;;
    darwin*)
      echo "darwin"
      ;;
    msys* | windows*)
      echo "windows"
      ;;
    freebsd*)
      echo "freebsd"
      ;;
    # TODO: can add more test cases here
    *)
      echo "notset"
      ;;
  esac
}

env::is_linux()   { [[ "$( env::os )" == "linux" ]]; }
env::is_darwin()  { [[ "$( env::os )" == "darwin" ]]; }
env::is_windows() { [[ "$( env::os )" == "windows" ]]; }

# Shell type
env::is_login_shell() { [[ "$0" == "-"* ]]; }
env::is_interactive_shell() { [[ -n "$PS1" ]]; }

# Tell if a command exists
env::has_command() { command -v "$1" >/dev/null 2>&1; }
env::is_gnu_command() { "$1" --version 2>/dev/null | grep -q "GNU";  }

