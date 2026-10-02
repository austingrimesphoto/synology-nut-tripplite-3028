## Summary

Add Tripp Lite USB product ID `09ae:3028` to the existing `smart1500lcdt_scale()` table. Validated on a physical BR1500LCDT using NUT 2.8.5.

## Hardware validation

With `usb_hid_rep_index=1` and `usb_hid_ep_in=2`, unpatched telemetry had `0.0 V`, `6000.0 Hz`, and roughly `100-110 A`; applying the existing handler produced 118.3-118.9 V input, 118.9 V output, 27.3 V battery, 60.0 Hz, and 0.9-1.0 A while preserving OL, 100% charge, ~2516 s runtime and 11-12% load. Thirteen samples over 60 seconds were DATAOK. A later physical integration test completed `OL -> OB DISCHRG -> OL CHRG`. Related: #2030.


## Scope note

This change addresses the `3028` scaling-table omission only. On the tested BR1500LCDT, reliable telemetry also requires `usb_hid_rep_index=1` and `usb_hid_ep_in=2`; this PR does not change NUT's automatic USB interface selection. I am reporting that separately rather than claiming this one-line change makes `3028` fully plug-and-play on every host.
