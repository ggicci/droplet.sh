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

_boot::lookfor_paths() {
  local name="$1"
  
  local candidates=()

  if [[ "${name}" != "/"* ]]; then
    local sourced_by_dir="$(cd "$(dirname "$0")" && pwd)"
    candidates+=("${sourced_by_dir}")
  fi

  if [[ "${name}" != "."* ]]; then
    candidates+=("${sourced_by_dir}/vendor")
    candidates+=("${DROPLET_SHELL_PATH}")
  fi
  echo "${candidates[@]}"
}

_boot::canonical_name() {
  local name="$1"

  if _boot::is_gnu_command "readlink"; then
    canonical_name="$(readlink -f -e -q "${name}")"
  else
    canonical_name="$(realpath -q "${name}")"
  fi

  echo "${canonical_name}"
}

_boot::import_once() {
  local name="$1"

  _boot::debug "import \"${name}\""
  local candidate_files=()

  if [[ "${name}" == "/"* ]]; then
    _boot::debug "  - candidate dir: (no candidate, absolute path)"
    candidate_files+=("${name}")
  else
    local candidate_dirs="$(_boot::lookfor_paths "${name}")"
    local candidate_file=""
    for candidate_dir in ${candidate_dirs[@]-}; do
      _boot::debug "  - candidate dir: \"${candidate_dir}\""

      candidate_file="$(_boot::canonical_name "${candidate_dir}/${name}")"
      if [[ "${candidate_file}" != "" ]]; then
        candidate_files+=("${candidate_file}")
      fi
    done
  fi

  for candidate_file in ${candidate_files[@]}; do
    if [[ -f "${candidate_file}" ]]; then
      _boot::debug "    > candidate file: ${candidate_file} (exists)"
      _boot::import_once_file "${candidate_file}"
      return
    else
      _boot::debug "    > candidate file: ${candidate_file} (not found)"
    fi
  done

  >&2 echo "[DROPLET] import \"${name}\" failed"
  exit 1
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
