#!/usr/bin/env bash
# log

_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
droplet "${_ROOT}/io.sh"
droplet "${_ROOT}/moment.sh"

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
  local level="$2"
  shift 2

  if [[ ${levelno} -gt ${log__LEVEL} ]]; then
    return
  fi


  local time
  time="$( moment::format "$( moment::now_unix_nano )" "%F %T.%N" )"

  if [[ "${levelno}" -eq 1 ]]; then
    io::print "${time}" -fg "#FF0000" " [${level}] " -rs "$@" "\n"
  elif [[ "${levelno}" -eq 3 ]]; then
    io::print "${time}" -fg "#FFFF00" " [${level}] " -rs "$@" "\n"
  elif [[ "${levelno}" -eq 8 ]]; then
    io::print "${time}" -fg "#666666" " [${level}] " -rs "$@" "\n"
  else
    io::print "${time}" " [${level}] " "$@" "\n"
  fi
}


log::debug() { log::__proxy_write 8 "DEBU" "$@"; }
log::info()  { log::__proxy_write 5 "INFO" "$@"; }
log::warning()  { log::__proxy_write 3 "WARN" "$@"; }
log::error() { log::__proxy_write 1 "ERRO" "$@"; }

