#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/etc/ups" "$T/etc.defaults/ups" "$T/usr/lib/udev/devicetable" "$T/usr/syno/etc/ups" "$T/bin" "$T/base"
cat > "$T/usr/lib/udev/devicetable/usb.nut-hid" <<'EOF'
# TrippLite
libhidups      0x0003      0x09ae   0x3024    0x0000       0x0000
EOF
cat > "$T/etc/ups/nutscan-usb.h" <<'EOF'
	{ 0x09ae, 0x3024, "usbhid-ups" },
EOF
cat > "$T/etc/ups/ups.conf" <<'EOF'
pollinterval = 5
[ups]
	driver = usbhid-ups
	port = auto
EOF
cp "$T/etc/ups/ups.conf" "$T/etc.defaults/ups/ups.conf"
echo 'ups_enabled="no"' > "$T/usr/syno/etc/ups/synoups.conf"
: > "$T/bin/usbhid-ups"

export UPS_NATIVE_BASE="$T/base"
export USB_TABLE="$T/usr/lib/udev/devicetable/usb.nut-hid"
export SCAN_TABLE="$T/etc/ups/nutscan-usb.h"
export LIVE_CONF="$T/etc/ups/ups.conf"
export DEFAULT_CONF="$T/etc.defaults/ups/ups.conf"
export SYNO_CONF="$T/usr/syno/etc/ups/synoups.conf"
export STOCK_DRIVER="$T/bin/usbhid-ups"
. "$ROOT/scripts/common.sh"

ensure_3028_usb_table
ensure_3028_scan_table
ensure_ups_conf "$LIVE_CONF"
ensure_ups_conf "$DEFAULT_CONF"

grep -q '0x09ae.*0x3028' "$USB_TABLE"
grep -q '0x09ae,.*0x3028,.*"usbhid-ups"' "$SCAN_TABLE"
grep -q '^driverpath = .*/base/bin$' "$LIVE_CONF"
grep -q 'vendorid = 09ae' "$LIVE_CONF"
grep -q 'productid = 3028' "$LIVE_CONF"
grep -q 'usb_hid_rep_index = 1' "$LIVE_CONF"
grep -q 'usb_hid_ep_in = 2' "$LIVE_CONF"

h1=$(sha256sum "$USB_TABLE" "$SCAN_TABLE" "$LIVE_CONF" "$DEFAULT_CONF")
ensure_3028_usb_table
ensure_3028_scan_table
ensure_ups_conf "$LIVE_CONF"
ensure_ups_conf "$DEFAULT_CONF"
h2=$(sha256sum "$USB_TABLE" "$SCAN_TABLE" "$LIVE_CONF" "$DEFAULT_CONF")
[ "$h1" = "$h2" ] || { echo "idempotence failed" >&2; exit 1; }

# Existing wrong mappings must fail closed.
printf '%s\n' '{ 0x09ae, 0x3028, "tripplite_usb" },' > "$SCAN_TABLE"
if ensure_3028_scan_table; then echo "wrong scan mapping was accepted" >&2; exit 1; fi

echo TEST_CONFIG_PASS
