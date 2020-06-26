#!/usr/bin/env bash
# color

# Convert color from hex to rgb
# e.g. #67A3F0 -> 103,163,255
color::hex2rgb() {
  local hexcolor="$1" r g b

  # Remove prefixed '#'
  if [[ "${hexcolor:0:1}" == '#' ]]; then
    hexcolor="${hexcolor:1:6}"
  fi

  r=$(( 16#${hexcolor:0:2} ))
  g=$(( 16#${hexcolor:2:2} ))
  b=$(( 16#${hexcolor:4:2} ))
  echo "$r,$g,$b"
}

