#!/usr/bin/env bash

set -o errexit
set -o pipefail

DROPLET_SHELL_PATH=${DROPLET_SHELL_PATH:-${HOME}/.droplet}
droplet__GNU_READLINK="readlink"

debug::on() { set -o xtrace; }

droplet::is_darwin()  { [[ "${OSTYPE}" == "darwin"* ]]; }

droplet::has_command() { command -v "$1" >/dev/null 2>&1; }

droplet::echo_error() { cat <<< "$@" 1>&2; }

droplet::is_gnu_command() { "$1" --version 2>/dev/null | grep -q "GNU"; }

droplet::use_gnu_command() {
  local command="$1"

  if droplet::is_gnu_command "${command}"; then
    echo "${command}"
    return
  fi

  if droplet::is_darwin \
    && droplet::has_command "g${command}" \
    && droplet::is_gnu_command "g${command}"; then
    echo "g${command}"
    return
  fi

  droplet::echo_error "GNU command \"${command}\" not found"
  if droplet::is_darwin; then
    droplet::echo_error "You are MacOS user, \"brew install coreutils\" is a good choice!"
  fi
  exit 1
}

droplet::debug() {
  if [[ ${DROPLET_DEBUG:-notset} == "on" ]]; then
    printf "[DROPLET] %s\n" "$*" >&2
  fi
}

droplet::lookfor_paths() {
  local name="$1"
  local candidates=()

  if [[ "${name}" != "/"* ]]; then
    local sourced_by_dir
    sourced_by_dir="$( cd "$( dirname "$0" )" && pwd )"
    candidates+=("${sourced_by_dir}")
  fi

  if [[ "${name}" != "."* ]]; then
    candidates+=("${sourced_by_dir}/vendor")
    candidates+=("${DROPLET_SHELL_PATH}")
  fi
  echo "${candidates[@]}"
}

droplet::canonical_name() {
  local name="$1"

  echo "$( ${droplet__GNU_READLINK} -f -e -q "${name}" )"
}

droplet::import_once() {
  local name="$1"

  droplet::debug "import \"${name}\""
  local candidate_files=()

  if [[ "${name}" == "/"* ]]; then
    droplet::debug "  - candidate dir: (no candidate, absolute path)"
    candidate_files+=("${name}")
  else
    local candidate_dirs
    candidate_dirs="$( droplet::lookfor_paths "${name}" )"
    local candidate_file=""
    for candidate_dir in ${candidate_dirs[@]-}; do
      droplet::debug "  - candidate dir: \"${candidate_dir}\""

      candidate_file="$( droplet::canonical_name "${candidate_dir}/${name}" )"
      if [[ "${candidate_file}" != "" ]]; then
        candidate_files+=("${candidate_file}")
      fi
    done
  fi

  for candidate_file in "${candidate_files[@]}"; do
    if [[ -f "${candidate_file}" ]]; then
      droplet::debug "    > candidate file: ${candidate_file} (exists)"
      droplet::import_once_file "${candidate_file}"
      return
    else
      droplet::debug "    > candidate file: ${candidate_file} (not found)"
    fi
  done

  >&2 echo "[DROPLET] import \"${name}\" failed"
  exit 1
}

droplet::already_imported_before() {
  local canonical_name="$1"

  local arr
  local IFS=:
  set -f
  arr=( ${_DROPLET_IMPORT_ONCE:-} )

  for x in "${arr[@]-}"; do
    droplet::debug "import once check \"${x}\" vs. \"${canonical_name}\""
    if [[ "${x}" == "${canonical_name}" ]]; then
      return 0
    fi
  done

  return 1
}

droplet::import_once_file() {
  local filename="$1"

  # check whether imported before
  if droplet::already_imported_before "${filename}"; then
    droplet::debug "import \"${filename}\" (skip)"
    return 0
  fi

  droplet::debug "import \"${filename}\""

  # shellcheck disable=SC1090
  source "${filename}"

  # add to imported collection
  _DROPLET_IMPORT_ONCE="${_DROPLET_IMPORT_ONCE:-}:${filename}"
  droplet::debug "_DROPLET_IMPORT_ONCE=${_DROPLET_IMPORT_ONCE}"
  export _DROPLET_IMPORT_ONCE
}

droplet::env_check() {
  droplet__GNU_READLINK="$( droplet::use_gnu_command readlink )"
}

droplet() { droplet::import_once "$@"; }

# Check environment, quit if necessary
droplet::env_check

