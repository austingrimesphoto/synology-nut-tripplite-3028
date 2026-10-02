#!/bin/sh
case "${1:-start}" in start) /volume1/ups-native/scripts/compat.sh --boot >> /volume1/ups-native/logs/rc-hook.log 2>&1 || exit $?;; stop) :;; *) echo "Usage: $0 {start|stop}" >&2; exit 2;; esac
