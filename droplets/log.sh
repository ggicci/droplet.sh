#!/usr/bin/env bash

import "github.com/ggicci/droplet/droplets/out.sh"
import "github.com/ggicci/droplet/droplets/moment.sh"

log__LEVEL=5

log::set_level() {
  local level="$1"

  case "${level}" in
    debug)
      log__LEVEL=8
      ;;
    info)
      log__LEVEL=5
      ;;
    warn)
      log__LEVEL=3
      ;;
    error)
      log__LEVEL=1
      ;;
    *)
      log__LEVEL=5
      ;;
  esac
}


log::__proxy_write() {
  local levelno="$1"
  local color="$2"
  local level="$3"

  if [[ ${levelno} -gt ${log__LEVEL} ]]; then
    return
  fi

  out::printf_none "$( moment::format "$( moment::now_unix_nano )" "%F %T.%N " )"
  if [[ "${level}" == "ERRO" ]]; then
    out::printf_${color} "["
    out::printf_style "${out__COLOR_BLINK};${out__COLOR_UNDERLINE};${out__COLOR_FG}${out__COLOR_RED}" "${level}"
    out::printf_${color} "]"
  else
    out::printf_${color} "[${level}]"
  fi
  out::printf_none " "
  shift 3
  out::printf_none "$@"
  out::printf_none "\n"
}


log::debug() { log::__proxy_write 8 "blue" "DEBU" "$@"; }
log::info()  { log::__proxy_write 5 "none" "INFO" "$@"; }
log::warn()  { log::__proxy_write 3 "yellow" "WARN" "$@"; }
log::error() { log::__proxy_write 1 "red" "ERRO" "$@"; }
