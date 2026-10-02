#!/bin/sh
# GPL-2.0-or-later
set -eu
BASE=${UPS_NATIVE_BASE:-/volume1/ups-native}; . "$BASE/scripts/common.sh"; must_root
label=$(build_label); stock=$(sha "$STOCK_DRIVER"); manifest="$MANIFEST_DIR/$label-$stock.manifest"; [ -f "$manifest" ] || { echo "ERROR: no same-build manifest for $label and stock driver $stock" >&2; exit 1; }
backup_root=$(awk -F= '$1=="BACKUP_ROOT"{print substr($0,index($0,"=")+1)}' "$manifest"); [ -d "$backup_root" ] || exit 1
systemctl stop ups-usb.service 2>/dev/null || true; systemctl disable ups-native-compat.service 2>/dev/null || true; systemctl stop ups-native-compat.service 2>/dev/null || true
for f in "$USB_TABLE" "$SCAN_TABLE" "$LIVE_CONF" "$DEFAULT_CONF" "$SYNO_CONF"; do src="$backup_root$f"; [ -f "$src" ] || { echo "ERROR: backup missing $src" >&2; exit 1; }; cp -a "$src" "$f"; done
set_syno_key ups_enabled no || true; set_syno_key ups_safeshutdown no || true
rm -f "$DROPIN_FILE" "$COMPAT_UNIT" "$RC_HOOK"; rmdir "$DROPIN_DIR" 2>/dev/null || true; systemctl daemon-reload
while read -r tag path expected; do [ "$tag" = ORIGINAL_SHA ] || continue; actual=$(sha "$path"); [ "$actual" = "$expected" ] || { echo "ERROR: rollback hash mismatch for $path" >&2; exit 1; }; done < "$manifest"
echo "Rollback complete. DSM UPS monitoring is disabled and the service remains stopped."
