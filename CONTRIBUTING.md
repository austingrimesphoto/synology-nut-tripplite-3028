# Contributing

Contributions are welcome, especially independent hardware validation.

Do not report a model as working based only on the same USB VID:PID. Include exact UPS/NAS/DSM versions, USB VID:PID, driver version, HID selector settings, stable online telemetry, and whether a controlled `OL -> OB -> OL` test and DSM notifications were verified.

Never post UPS serial numbers unless you intend to make them public.

Keep code changes narrow and fail-closed. Avoid wildcard matching, replacing Synology system binaries, restoring files across DSM builds, or adding output-power commands to validation scripts.

For upstream NUT patches, use DCO sign-off (`git commit -s`) and follow NUT's contribution guidance.
