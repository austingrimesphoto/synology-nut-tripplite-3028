#!/bin/sh
set -eu
if [ "$(id -u)" -eq 0 ]; then exec /volume1/ups-native/scripts/rollback.sh "$@"; else exec sudo /volume1/ups-native/scripts/rollback.sh "$@"; fi
