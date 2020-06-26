#!/usr/bin/env bash
# str

# Convert string to lowercase
str::to_lower() {
  local content="$1"
  echo "${content}" | awk '{print tolower($0)}'
}

