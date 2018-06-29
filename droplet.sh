#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DROPLET_SHELL_PATH=${DROPLET_SHELL_PATH:-${HOME}/.droplet}

debug::on() { set -o xtrace; }

_boot::has_command() { command -v "$1" >/dev/null 2>&1; }

_boot::is_gnu_command() { [[ -n "$("$1" --version 2>/dev/null | grep "GNU")" ]]; }

_boot::debug() {
  if [[ ${DROPLET_DEBUG:-notset} == "on" ]]; then
    printf "[DROPLET] %s\n" "$*" >&2
  fi
}

_boot::import_from_local() {
  local name="$1"

  local candidates=(
    "${name}"
  )

  if [[ "${name}" == "."* ]] || [[ "${name}" == "."* ]]; then
    _boot::debug "skip candidates in vendor and droplet path"
  else
    if [ -d "vendor" ]; then
      candidates+=("vendor/${name}")
    fi
    candidates+=("${DROPLET_SHELL_PATH}/${name}")
  fi

  local err_messages=""

  local canonical_name=""
  for candidate in "${candidates[@]-}"; do
    _boot::debug "candidate: \"${candidate}\""

    if _boot::is_gnu_command "readlink"; then
      canonical_name="$(readlink -f -e -q "${candidate}")"
    else
      canonical_name="$(realpath -q "${candidate}")"
    fi

    if [ "${canonical_name}" = "" ]; then
      err_message="${err_message}, \"${candidate}\" doesn't exist"
      continue
    fi

    if [[ -d "${canonical_name}" ]]; then
      # check droplet.sh under this directory
      canonical_name="${canonical_name}/droplet.sh"
      if [[ ! -e "${canonical_name}" ]]; then
        err_message="${err_message}, \"${canonical_name}\" doesn't exist"
        continue
      fi
    fi

    break
  done

  if [ "${canonical_name}" = "" ]; then
    echo "${err_message}"
    return 1
  fi

  echo "${canonical_name}"
}


_boot::already_imported_before() {
  local canonical_name="$1"

  local arr
  local IFS=:
  set -f
  arr=( ${_DROPLET_IMPORT_ONCE:-} )

  for x in "${arr[@]-}"; do
    _boot::debug "import once check \"${x}\" vs. \"${canonical_name}\""
    if [[ "${x}" == "${canonical_name}" ]]; then
      return 0
    fi
  done

  return 1
}

_boot::import_once() {
  local name="$1"

  _boot::debug "import \"${name}\""

  local canonical_name=""
  local err_message=""
  if canonical_name="$(_boot::import_from_local "${name}")"; then
    :
  else
    err_message="${canonical_name}"
    canonical_name=""
  fi

  if [ -z "${canonical_name}" ]; then
    >&2 echo "import \"${name}\" failed${err_message}"
    exit 1
  fi

  # import (source)
  if [ -d "${canonical_name}" ]; then
    # source droplet.sh file under this folder
    _boot::import_once_file "${canonical_name}/droplet.sh"
  else
    _boot::import_once_file "${canonical_name}"
  fi
}

_boot::import_once_file() {
  local filename="$1"

  # check whether imported before
  if _boot::already_imported_before "${filename}"; then
    _boot::debug "import \"${filename}\" (skip)"
    return 0
  fi

  _boot::debug "import \"${filename}\""
  source "${filename}"
  # add to imported collection
  _DROPLET_IMPORT_ONCE="${_DROPLET_IMPORT_ONCE:-}:${filename}"
  _boot::debug "_DROPLET_IMPORT_ONCE=${_DROPLET_IMPORT_ONCE}"
  export _DROPLET_IMPORT_ONCE
}

import() { _boot::import_once "$@"; }

