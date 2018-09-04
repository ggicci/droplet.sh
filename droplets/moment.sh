#!/usr/env/bin bash

import "github.com/ggicci/droplet/droplets/out.sh"
import "github.com/ggicci/droplet/droplets/env.sh"

moment__GNU_DATE="$( droplet::use_gnu_command date )"

# moment::parse Parse a datetime string to a float number formatted as "<unix>.<nanoseconds>"
moment::parse() {
  local param_time="$1"
  local result

  result=$( ${moment__GNU_DATE} -d"${param_time}" +%s.%N 2>/dev/null )
  if [[ $? -eq 0 ]]; then
    echo ${result}
    return
  fi
  result=$( ${moment__GNU_DATE} -d"@${param_time}" +%s.%N 2>/dev/null )
  if [[ $? -eq 0 ]]; then
    echo ${result}
    return
  fi
  return 1
}

# moment::now Get current datetime
moment::now() { ${moment__GNU_DATE} --iso-8601='ns'; }

# moment::now_unix Get current unix time (seconds)
moment::now_unix() { ${moment__GNU_DATE} +%s; }

# moment::now_unix_nano Get current unix time with nano seconds
moment::now_unix_nano() { ${moment__GNU_DATE} +%s.%N; }

# moment::unix Convert a datetime to unix time
moment::unix() { ${moment__GNU_DATE} -d"@$( moment::parse "$1" )" +%s; }

# moment::format Format a datetime
moment::format() {
  local param_time="$1"
  local param_format="${2:-notset}"

  if [[ "${param_format}" == "notset" ]]; then
    ${moment__GNU_DATE} -d"@$( moment::parse "${param_time}" )" --iso-8601='ns'
    return
  fi

  ${moment__GNU_DATE} -d"@$( moment::parse "${param_time}" )" +"${param_format}"
}
