#!/bin/sh
# GPL-2.0-or-later
set -eu
BASE=${UPS_NATIVE_BASE:-/volume1/ups-native}; . "$BASE/scripts/common.sh"; must_root; mode=${1:---check}
assert_known_layout || { log "Compatibility gate blocked: unknown DSM layout"; exit 20; }
[ "$(uname -m)" = "x86_64" ] || { log "Compatibility gate blocked: unsupported architecture"; exit 21; }
[ -x "$PRIVATE_DRIVER_LINK" ] || { log "Compatibility gate blocked: private driver wrapper missing"; exit 22; }; verify_private_runtime || { log "Compatibility gate blocked: private runtime hash verification failed"; exit 28; }
snapshot_if_needed || exit 23; ensure_3028_usb_table || exit 24; ensure_3028_scan_table || exit 25; ensure_ups_conf "$DEFAULT_CONF" || exit 26; ensure_ups_conf "$LIVE_CONF" || exit 27
case "$mode" in --boot|--repair) install_hooks_from_templates;; --prestart|--check) :;; *) echo "Usage: $0 [--check|--prestart|--boot|--repair]" >&2; exit 2;; esac
log "Compatibility gate OK for $(build_label), mode=$mode"
