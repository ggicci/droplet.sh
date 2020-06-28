#!/usr/bin/env bash

source "../droplet.sh"
droplet "../droplets/log.sh"

log::set_level "debug"

log::debug "debug message, a=1, b=hello"
log::info "info message, name=Ggicci, age=8"
log::warning "warn message, return=no"
log::error "error message, error=hahaha"

