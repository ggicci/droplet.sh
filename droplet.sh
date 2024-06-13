#!/usr/bin/env bash

DROPLET_DEBUG=${DROPLET_DEBUG:-0}
WD="$( cd "$( dirname "$0" )" && pwd )"

droplet::debug() {
  if [[ ${DROPLET_DEBUG} == "1" ]]; then
    printf "[DROPLET] %s\n" "$*" >&2
  fi
}

# borrowed from bats-core
if command -v greadlink >/dev/null; then
  droplet::readlinkf() {
    greadlink -f "$1"
  }
else
  droplet::readlinkf() {
    readlink -f "$1"
  }
fi
__fallback_to_readlinkf_posix() {
  droplet::readlinkf() {
    [ "${1:-}" ] || return 1
    max_symlinks=40
    CDPATH='' # to avoid changing to an unexpected directory

    target=$1
    [ -e "${target%/}" ] || target=${1%"${1##*[!/]}"} # trim trailing slashes
    [ -d "${target:-/}" ] && target="$target/"

    cd -P . 2>/dev/null || return 1
    while [ "$max_symlinks" -ge 0 ] && max_symlinks=$((max_symlinks - 1)); do
      if [ ! "$target" = "${target%/*}" ]; then
        case $target in
          /*) cd -P "${target%/*}/" 2>/dev/null || break ;;
          *) cd -P "./${target%/*}" 2>/dev/null || break ;;
        esac
        target=${target##*/}
      fi

      if [ ! -L "$target" ]; then
        target="${PWD%/}${target:+/}${target}"
        printf '%s\n' "${target:-/}"
        return 0
      fi

      # `ls -dl` format: "%s %u %s %s %u %s %s -> %s\n",
      #   <file mode>, <number of links>, <owner name>, <group name>,
      #   <size>, <date and time>, <pathname of link>, <contents of link>
      # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html
      link=$(ls -dl -- "$target" 2>/dev/null) || break
      target=${link#*" $target -> "}
    done
    return 1
  }
}

droplet::lookfor_paths() {
  local name="$1"
  local candidates=( "$( pwd )" "$( pwd )/droplets" "${WD}" "${WD}/droplets" )
  echo "${candidates[@]}"
}

droplet::canonical_name() {
  local name="$1"

  echo "$( droplet::readlinkf "${name}" )"
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

droplet() { droplet::import_once "$@"; }

if ! droplet::readlinkf "${BASH_SOURCE[0]}" &>/dev/null; then
  __fallback_to_readlinkf_posix
fi
