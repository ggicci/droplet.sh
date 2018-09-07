#!/usr/bin/env bash

source ../droplet.sh
import "github.com/ggicci/droplet/droplets/moment.sh"

moment::parse "$( moment::now )"
moment::now
moment::now_unix
moment::now_unix_nano
moment::unix "$( moment::now )"
moment::format "$( moment::now )" "%Y-%m-%d %H:%M:%S"
moment::shift "$( moment::now )" "10 days ago"
moment::format "$( moment::shift "$( moment::now )" "+10 days" )" "%Y-%m-%d"
