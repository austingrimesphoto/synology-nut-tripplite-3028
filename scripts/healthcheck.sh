#!/bin/sh
# GPL-2.0-or-later
set -eu
BASE=${UPS_NATIVE_BASE:-/volume1/ups-native}; . "$BASE/scripts/common.sh"; must_root
echo "=== platform ==="; echo "model=$(nas_model)"; echo "dsm=$(dsm_version)-$(dsm_build)-u$(dsm_smallfix)"; echo "arch=$(uname -m)"; echo "stock_driver_sha=$(sha "$STOCK_DRIVER")"; [ -x "$RUNTIME_DIR/bin/usbhid-ups" ] && echo "private_driver_sha=$(sha "$RUNTIME_DIR/bin/usbhid-ups")"
echo "=== USB ==="; if usb_present; then echo "09ae:3028=present"; else echo "09ae:3028=NOT_PRESENT"; fi
echo "=== config ==="; grep -E '^[[:space:]]*(driverpath|driver|port|vendorid|productid|usb_hid_rep_index|usb_hid_ep_in)[[:space:]]*=' "$LIVE_CONF" || true
echo "=== services ==="; systemctl status ups-native-compat.service ups-usb.service --no-pager -l 2>&1 || true
echo "=== NUT processes ==="; nut_processes
echo "=== telemetry ==="; tmp=/tmp/ups-native-health.$$; err=/tmp/ups-native-health.err.$$
if upsc ups@localhost >"$tmp" 2>"$err"; then grep -E '^(ups.status|battery.charge|battery.runtime|battery.voltage|input.voltage|output.voltage|input.frequency|output.frequency|output.current|ups.load|ups.model|ups.serial):' "$tmp" || true; else cat "$err" >&2 || true; rm -f "$tmp" "$err"; exit 1; fi
awk -F': ' '/^(input.voltage|output.voltage|battery.voltage|input.frequency|output.frequency|battery.charge|ups.load):/{print $1"="$2}' "$tmp"
rm -f "$tmp" "$err"; echo "HEALTHCHECK_COMPLETE=1"
