#!/usr/env/bin bash

out__GNU_PRINTF="$( droplet::use_gnu_command printf )"

# Print error information to standard error output.
out::echo_error() { cat <<< "$@" 1>&2; }

# Colored outputs.
# http://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# Num  Colour    #define         R G B
# 0    black     COLOR_BLACK     0,0,0
# 1    red       COLOR_RED       1,0,0
# 2    green     COLOR_GREEN     0,1,0
# 3    yellow    COLOR_YELLOW    1,1,0
# 4    blue      COLOR_BLUE      0,0,1
# 5    magenta   COLOR_MAGENTA   1,0,1
# 6    cyan      COLOR_CYAN      0,1,1
# 7    white     COLOR_WHITE     1,1,1

out__COLOR_BLACK='0'
out__COLOR_RED='1'
out__COLOR_GREEN='2'
out__COLOR_YELLOW='3'
out__COLOR_BLUE='4'
out__COLOR_MAGENTA='5'
out__COLOR_CYAN='6'
out__COLOR_WHITE='7'

out__COLOR_CODE='\033['
out__COLOR_NC='0'
out__COLOR_FG='3'
out__COLOR_BG='4'
out__COLOR_FG_HI='9'
out__COLOR_BG_HI='10'
out__COLOR_BOLD='1'
out__COLOR_UNDERLINE='4'
out__COLOR_BLINK='5'

out::printf_style() {
  printf "${out__COLOR_CODE}$1m"
  shift 1
  ${out__GNU_PRINTF} "${@}"
  ${out__GNU_PRINTF} "${out__COLOR_CODE}${out__COLOR_NC}m"
}


out::printf_none()    { printf "$@"; }
out::printf_black()   { out::printf_style "${out__COLOR_FG}${out__COLOR_BLACK}" "$@"; }
out::printf_red()     { out::printf_style "${out__COLOR_FG}${out__COLOR_RED}" "$@"; }
out::printf_green()   { out::printf_style "${out__COLOR_FG}${out__COLOR_GREEN}" "$@"; }
out::printf_yellow()  { out::printf_style "${out__COLOR_FG}${out__COLOR_YELLOW}" "$@"; }
out::printf_blue()    { out::printf_style "${out__COLOR_FG}${out__COLOR_BLUE}" "$@"; }
out::printf_magenta() { out::printf_style "${out__COLOR_FG}${out__COLOR_MAGENTA}" "$@"; }
out::printf_cyan()    { out::printf_style "${out__COLOR_FG}${out__COLOR_CYAN}" "$@"; }
out::printf_white()   { out::printf_style "${out__COLOR_FG}${out__COLOR_WHITE}" "$@"; }
