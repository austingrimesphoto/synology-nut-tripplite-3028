#!/bin/sh
# GPL-2.0-or-later
set -eu
SRC=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd); BASE=/volume1/ups-native; ART="$SRC/artifacts/nut-2.8.5-3028"
[ "$(id -u)" -eq 0 ] || { echo "ERROR: run with sudo/root" >&2; exit 1; }; [ "$(uname -m)" = x86_64 ] || { echo "ERROR: only x86_64 supported" >&2; exit 1; }
model=""; [ -r /proc/sys/kernel/syno_hw_version ] && model=$(cat /proc/sys/kernel/syno_hw_version); [ "$model" = "DS923+" ] || { echo "ERROR: validated NAS model is DS923+; detected '$model'" >&2; exit 1; }
build=$(/bin/get_key_value /etc.defaults/VERSION buildnumber 2>/dev/null || true); version=$(/bin/get_key_value /etc.defaults/VERSION productversion 2>/dev/null || true); [ "$version-$build" = "7.4.1-90080" ] || { echo "ERROR: fresh installs validated only on DSM 7.4.1-90080; detected $version-$build" >&2; exit 1; }
[ -x "$ART/bin/usbhid-ups" ] || { echo "ERROR: build artifact missing; run ./scripts/build-driver.sh first" >&2; exit 1; }; (cd "$ART" && sha256sum -c SHA256SUMS >/dev/null) || { echo "ERROR: artifact manifest failed" >&2; exit 1; }
systemctl is-active --quiet ups-usb.service && { echo "ERROR: disable DSM UPS support before installation" >&2; exit 1; } || true
ups_enabled=$(/bin/get_key_value /usr/syno/etc/ups/synoups.conf ups_enabled 2>/dev/null || true); [ "$ups_enabled" = "no" ] || { echo "ERROR: disable DSM UPS support in Control Panel first (ups_enabled=$ups_enabled)" >&2; exit 1; }
ups_safe=$(/bin/get_key_value /usr/syno/etc/ups/synoups.conf ups_safeshutdown 2>/dev/null || true); [ "$ups_safe" != "yes" ] || { echo "ERROR: disable UPS output shutdown before installation" >&2; exit 1; }
ps wwaux 2>/dev/null | grep -Eq '[u]sbhid-ups|[u]psmon|[u]pssched|[u]psd([^a-z]|$)' && { echo "ERROR: NUT process is running" >&2; exit 1; } || true
mkdir -p "$BASE/bin" "$BASE/runtime/nut-2.8.5-3028" "$BASE/scripts" "$BASE/templates" "$BASE/logs" "$BASE/manifests" "$BASE/backups" "$BASE/patches"
cp -a "$ART/." "$BASE/runtime/nut-2.8.5-3028/"; cp -f "$SRC/scripts/common.sh" "$SRC/scripts/compat.sh" "$SRC/scripts/healthcheck.sh" "$SRC/scripts/rollback.sh" "$SRC/scripts/collect-diagnostics.sh" "$BASE/scripts/"; cp -f "$SRC/systemd/ups-native-compat.service" "$BASE/templates/"; cp -f "$SRC/systemd/ups-usb.service.d/20-ups-native-compat.conf" "$BASE/templates/ups-usb-compat.conf"; cp -f "$SRC/rc.d/ups-native-compat.sh" "$BASE/templates/ups-native-compat-rc.sh"; cp -f "$SRC/patches/nut-2.8.5-tripplite-3028.patch" "$BASE/patches/"; chmod 0755 "$BASE/scripts/"*.sh
cat > "$BASE/bin/usbhid-ups" <<'WRAP'
#!/bin/sh
BASE=/volume1/ups-native/runtime/nut-2.8.5-3028
exec "$BASE/lib/ld-musl-x86_64.so.1" --library-path "$BASE/lib" "$BASE/bin/usbhid-ups" "$@"
WRAP
chmod 0755 "$BASE/bin/usbhid-ups"
. "$BASE/scripts/common.sh"; must_root; assert_known_layout; stock=$(sha "$STOCK_DRIVER"); [ "$stock" = "$EXPECTED_INITIAL_STOCK_SHA" ] || { echo "ERROR: unexpected stock driver hash: $stock" >&2; exit 1; }; usb_present || { echo "ERROR: USB device 09ae:3028 is not attached" >&2; exit 1; }
snapshot_if_needed; ensure_3028_usb_table; ensure_3028_scan_table; ensure_ups_conf "$DEFAULT_CONF"; ensure_ups_conf "$LIVE_CONF"; install_hooks_from_templates; "$BASE/scripts/compat.sh" --check
echo "Installation complete. Re-enable USB UPS support in DSM with UPS output shutdown disabled for the first test, then run: sudo $BASE/scripts/healthcheck.sh"
