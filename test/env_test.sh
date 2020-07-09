#!/usr/bin/env bash

source "../droplet.sh"
droplet "../droplets/env.sh"

echo "Your OS: $( env::os )"

if env::is_darwin; then
    if ! env::is_gnu_command "date" && env::has_command "gdate" && env::is_gnu_command "gdate"; then
        echo "[NOTE] You are macOS user, and you have installed coreutils, brilliant!"
    else
        echo "[NOTE] You are macOS user, \"brew install coreutils\" is a good choice for you!"
    fi
fi
