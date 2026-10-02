# Project status

## Original validated installation

- Synology DS923+ / DSM 7.4.1-90080 Update 0
- Tripp Lite BR1500LCDT / USB `09ae:3028`
- private NUT 2.8.5 patched `usbhid-ups` SHA-256: `01c7cce7ef49eb3f25319403b4a15b84b5a267df3e594bae131131fb35045ec6`
- stock DSM `/usr/bin/usbhid-ups` SHA-256: `c40952698fc8b333eba260169328c533f98c4a3dc58174774b0be87b549182c8`
- required selectors: `usb_hid_rep_index=1`, `usb_hid_ep_in=2`
- scaling patch: `0x3028 -> smart1500lcdt_scale()`
- physical test: `OL -> OB DISCHRG -> OL CHRG`
- DSM native on-battery and restored-power notifications confirmed

## Public package maturity

The repository package is an initial conservative release candidate. Its source/build inputs, safety boundaries, and rollback path are documented. Independent clean-install and full-reboot validation are tracked before broadening support.
