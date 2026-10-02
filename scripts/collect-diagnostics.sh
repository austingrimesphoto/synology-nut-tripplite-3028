#!/bin/sh
set -eu
BASE=${UPS_NATIVE_BASE:-/volume1/ups-native}
. "$BASE/scripts/common.sh"
must_root
printf '%s\n' '=== platform ==='
printf 'model=%s\n' "$(nas_model)"
printf 'dsm=%s-%s-u%s\n' "$(dsm_version)" "$(dsm_build)" "$(dsm_smallfix)"
printf 'arch=%s\n' "$(uname -m)"
printf '%s\n' '=== hashes ==='
printf 'stock=%s\n' "$(sha "$STOCK_DRIVER")"
[ -f "$RUNTIME_DIR/bin/usbhid-ups" ] && printf 'private=%s\n' "$(sha "$RUNTIME_DIR/bin/usbhid-ups")"
printf '%s\n' '=== service ==='
systemctl status ups-native-compat.service ups-usb.service --no-pager -l 2>&1 || true
printf '%s\n' '=== config (safe fields) ==='
grep -E '^[[:space:]]*(driverpath|driver|port|vendorid|productid|usb_hid_rep_index|usb_hid_ep_in)[[:space:]]*=' "$LIVE_CONF" || true
printf '%s\n' '=== telemetry (serial omitted) ==='
upsc ups@localhost 2>/dev/null | grep -E '^(ups.status|ups.model|battery\.|input\.|output\.|ups.load):' | grep -v '^ups.serial:' || true
printf '%s\n' '=== recent compatibility log ==='
tail -100 "$LOG_DIR/compat.log" 2>/dev/null || true
