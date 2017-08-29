#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

debug::on() { set -o xtrace; }

BASHER_VENDOR_ROOT="vendor"

_boot::has_command() { command -v "$1" >/dev/null 2>&1; }

_boot::is_gnu_command() { [[ -n "$("$1" --version 2>/dev/null | grep "GNU")" ]]; }

_boot::debug() {
  if [[ ${BASHER_DEBUG:-notset} == "on" ]]; then
    printf "[BASHER] %s\n" "$*" >&2
  fi
}

_boot::import_from_local() {
  local name="$1"

  local candidates=(
    "${name}"
  )

  if [ -d "${BASHER_VENDOR_ROOT}" ]; then
    candidates+=("${BASHER_VENDOR_ROOT}/${name}")
  fi

  local err_messages=""

  local canonical_name=""
  for candidate in "${candidates[@]}"; do
    _boot::debug "candidate: ${candidate}"

    if _boot::is_gnu_command "readlink"; then
      canonical_name="$(readlink -f -e -q "${candidate}")"
    else
      canonical_name="$(realpath -q "${candidate}")"
    fi
    if [ "${canonical_name}" = "" ]; then
      err_message="${err_message}, \"${candidate}\" doesn't exist"
      continue
    fi

    if [[ "${canonical_name}" == *".sh" ]] && [[ ! -f "${canonical_name}" ]]; then
      err_message="${err_message}, \"${canonical_name}\" is not a file"
      continue
    fi

    if [[ "${canonical_name}" != *".sh" ]] && [[ ! -d "${canonical_name}" ]]; then
      err_message="${err_message}, \"${canonical_name}\" is not a dir"
      continue
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
  arr=( ${_BASHER_IMPORT_ONCE:-} )

  for x in "${arr[@]}"; do
    _boot::debug "import once check \"${x}\" vs. \"${canonical_name}\""
    if [[ "${x}" == "${canonical_name}" ]]; then
      return 0
    fi
  done

  return 1
}

_boot::import_once() {
  local name="$1"

  _boot::debug "import ${name}"

  local canonical_name=""
  local err_message=""
  if canonical_name="$(_boot::import_from_local "${name}")"; then
    :
  else
    err_message="${canonical_name}"
    canonical_name=""
  fi

  if [ -z "${canonical_name}" ]; then
    >&2 echo "import error: \"${name}\", ${err_message}"
    exit 1
  fi

  # import (source)
  if [ -d "${canonical_name}" ]; then
    # source every .sh file under this folder
    while read filename; do
      _boot::import_once_file "${filename}"
    done < <(find ${canonical_name} -maxdepth 1 -type f \( -iname "*.sh" ! -iname "_*.sh" \))
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
  _BASHER_IMPORT_ONCE="${_BASHER_IMPORT_ONCE:-}:${filename}"
  _boot::debug "_BASHER_IMPORT_ONCE=${_BASHER_IMPORT_ONCE}"
  export _BASHER_IMPORT_ONCE
}

import() { _boot::import_once "$@"; }
