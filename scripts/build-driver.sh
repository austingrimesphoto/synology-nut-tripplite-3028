#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/artifacts/nut-2.8.5-3028"
IMAGE="synology-nut-tripplite-3028-builder:2.8.5"
DOCKER="${DOCKER:-docker}"
if ! command -v "$DOCKER" >/dev/null 2>&1; then if [[ -x /usr/local/bin/docker ]]; then DOCKER=/usr/local/bin/docker; else echo "ERROR: Docker is required for the auditable containerized build." >&2; exit 1; fi; fi
rm -rf "$OUT"; mkdir -p "$OUT"
"$DOCKER" build --pull=false --no-cache -f "$ROOT/build/Dockerfile" -t "$IMAGE" "$ROOT"
cid="$($DOCKER create "$IMAGE")"
trap '"$DOCKER" rm -f "$cid" >/dev/null 2>&1 || true' EXIT
"$DOCKER" cp "$cid:/bin" "$OUT/bin"
"$DOCKER" cp "$cid:/lib" "$OUT/lib"
"$DOCKER" cp "$cid:/build" "$OUT/build"
"$DOCKER" cp "$cid:/SHA256SUMS" "$OUT/SHA256SUMS"
cat > "$OUT/BUILD-INFO" <<EOF
NUT=2.8.5
NUT_COMMIT=0e051f9f6853e9ae0087b388b70840c9651a5eed
PATCH=patches/nut-2.8.5-tripplite-3028.patch
TARGET=x86_64-linux-musl private runtime
EOF
printf 'Built artifact: %s\n' "$OUT"
sha256sum "$OUT/bin/usbhid-ups"
