#!/usr/bin/env bash

export _BASHER_IMPORT_ONCE=""
_BASHER_VENDOR_FOLDER="vendor"

_boot::has_command() { command -v "$1" >/dev/null 2>&1; }
_boot::debug() {
  if [[ ${BASHER_DEBUG} == "on" ]]; then
    printf "%s\n" "$*" >&2
  fi
}

_boot::import_from_local() {
  local name="$1"

  local canonical_name=""
  if ! canonical_name="$(realpath -qe "${name}")"; then
    _boot::debug "\"${name}\" not found"
    return 1
  fi

  if [ -d "${canonical_name}" ]; then
    local file="$(basename "${canonical_name}").sh"
    canonical_name="${canonical_name}/${file}"
  fi

  if [ -f "${canonical_name}" ]; then
    echo "${canonical_name}"
    return 0
  fi

  _boot::debug "\"${name}\" not found"
  return 1
}

_boot::import_from_github() {
  local name="$1"

  if [[ "${name}" != github.com/* ]]; then
    _boot::debug "not a github repo"
    return 1
  fi

  local repo="$(cut -d'/' -f 1,2,3 <<< "${name}")"
  local repo_url="https://${repo}"
  local repo_local="${_BASHER_VENDOR_FOLDER}/${repo}"
  local canonical_name="${_BASHER_VENDOR_FOLDER}/${name}"

  # find it in the vendor folder
  if [[ -d "${repo_local}" ]]; then
    if _boot::import_from_local "${canonical_name}"; then
      return 0
    fi
  fi

  # check git command
  if ! _boot::has_command "git"; then
    _boot::debug "command \"git\" not available"
    return 1
  fi

  # clone repo from remote
  _boot::debug "clone \"${repo_url}\" to \"${repo_local}\""

  if [[ ${BASHER_DEBUG} == "on" ]]; then
    git clone "${repo_url}" "${repo_local}"
  else
    git clone "${repo_url}" "${repo_local}" >/dev/null 2>&1
  fi
  local ret=$?
  if [[ ${ret} -ne 0 ]]; then
    _boot::debug "clone failed, exit code: ${ret}"
    return 1
  fi

  _boot::debug "clone successfully, exit code: ${ret}"
  _boot::import_from_local "${canonical_name}"
}

_boot::import_from_http() {
  # TODO
  _boot::debug "todo"
  return 1
}

_boot::already_imported_before() {
  local canonical_name="$1"

  local arr
  local IFS=:
  set -f
  arr=( ${_BASHER_IMPORT_ONCE} )

  for x in "${arr[@]}"; do
    if [[ "$x" == "${canonical_name}" ]]; then
      return 0
    fi
  done

  return 1
}

_boot::import_once() {
  local name="$1"

  _boot::debug "import ${name}"

  local handlers=(
    _boot::import_from_local
    _boot::import_from_github
    _boot::import_from_http
  )

  local handler
  local canonical_name=""
  for handler in "${handlers[@]}"; do
    _boot::debug "try handler: ${handler}"
    if canonical_name="$(${handler} "${name}")"; then
      break
    else
      canonical_name=""
    fi
  done

  if [[ "${canonical_name}" == "" ]]; then
    >&2 echo "import error: \"${name}\""
    exit 1
  fi

  # check whether imported before
  if _boot::already_imported_before "${canonical_name}"; then
    _boot::debug "import skip: \"${name}\" --> \"${canonical_name}\" already imported before"
    return 0
  fi

  # import (source)
  source "${canonical_name}"
  # add to imported collection
  _BASHER_IMPORT_ONCE="${_BASHER_IMPORT_ONCE}:${canonical_name}"
  export _BASHER_IMPORT_ONCE
  _boot::debug "import successfully: \"${name}\" --> \"${canonical_name}\""
}

import() { _boot::import_once "$@"; }
