#!/usr/env/bin bash
# io

# References:
# - https://stackoverflow.com/q/5947742/1592264
# - https://github.com/aristocratos/bashtop

# Print to stderr
io::echo_error() { cat <<< "$@" 1>&2; }

# Check if value(s) is integer
io::_is_int() {
  local param
  for param; do
    if [[ ! $param =~ ^[\-]?[0-9]+$ ]]; then return 1; fi
  done
}

# Print text, set true-color foreground/background color, add effects
# Args:
#   Effects: [-fg, -foreground <RGB Hex>|<R Dec> <G Dec> <B Dec>]
#            [-bg, -background <RGB Hex>|<R Dec> <G Dec> <B Dec>]
#            [-rs, -reset]
#            [-/+b, -/+bold]
#            [-/+ul, -/+underline]
#            [-/+i, -/+italic]
#            [-/+bl, -/+blink]
#   Text: [-v, -variable "variable-name"] [-stdin] [-t, -text "string"] ["string"]
io::print() {
  # Return if no arguments is given
  if [[ $# -eq 0 ]]; then return; fi

  # Just echo and return if only one argument and not a valid option
  if [[ $# -eq 1 && "${1:0:1}" != "-" ]]; then
    echo -en "$1"
    return
  fi

  local text val fgc bgc effect var ext_var out

  # Loop function until we are out of arguments
  until (( $# == 0 )); do
    # Argument parsing
    effect=""
    until (( $# == 0 )); do
      case $1 in
        -t|-text)
          text="$2"
          shift 2
          break
          ;;
        -stdin)
          text="$(</dev/stdin)"
          shift
          break
          ;;
        -fg|-foreground)
          # Set text foreground color, accepts either 6 digits hexadeciaml
          # "#RRGGBB" or decimal RGB "<0-255> <0-255> <0-255>"
          if [[ "${2:0:1}" == "#" ]]; then
            val=${2//\#/}
            fgc="\033[38;2;$(( 16#${val:0:2} ));$(( 16#${val:2:2} ));$(( 16#${val:4:2}))m"
            shift
          elif io::_is_int "${@:2:3}"; then
            fgc="\033[38;2;${2};${3};${4}m"
            shift 3
          fi
          ;;
        -bg|-background)
          # Set text background color, accepts either 6 digits hexadeciaml
          # "#RRGGBB" or decimal RGB "<0-255> <0-255> <0-255>"
          if [[ "${2:0:1}" == "#" ]]; then
            val=${2//\#/}
            bgc="\033[48;2;$(( 16#${val:0:2} ));$(( 16#${val:2:2} ));$(( 16#${val:4:2} ))m"
            shift
          elif is_int "${@:2:3}"; then
            bgc="\033[48;2;${2};${3};${4}m"
            shift 3
          fi
          ;;
        -rs|-reset)
          effect="0${effect}"
          ;;
        -b|-bold)
          effect="${effect}${effect:+;}1"
          ;;
        +b|+bold)
          effect="${effect}${effect:+;}21"
          ;;
        -i|-italic)
          effect="${effect}${effect:+;}3"
          ;;
        +i|+italic)
          effect="${effect}${effect:+;}23"
          ;;
        -ul|-underline)
          effect="${effect}${effect:+;}4"
          ;;
        +ul|+underline)
          effect="${effect}${effect:+;}24"
          ;;
        -bl|-blink)
          effect="${effect}${effect:+;}5"
          ;;
        +bl|+blink)
          effect="${effect}${effect:+;}25"
          ;;
        -v|-variable)
          local -n var=$2
          ext_var=1
          shift
          ;;
        *)
          text="$1"
          shift
          break
          ;;
      esac
      shift
    done

    # Create text string
    if [[ "${effect}" != "" ]]; then
      effect="\033[${effect}m"
    fi
    out="${out:-""}${effect}${bgc:-""}${fgc:-""}${text:-""}"
    unset effect bgc fgc text
  done

  # Print the string to stdout if variable not set
  if [[ "${ext_var:-0}" -eq 1 ]]; then
    var="${var}${out}"
    return
  fi
  echo -en "${out}"
}

