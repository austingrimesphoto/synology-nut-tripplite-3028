# Roadmap

## 0.1.x

- [ ] Independently validate a clean install from the public package on DS923+ / DSM 7.4.1-90080.
- [ ] Perform and document one full NAS reboot persistence test.
- [ ] Publish a signed/reproducible release artifact after CI output matches the validated runtime behavior.
- [ ] Submit the `0x3028 -> smart1500lcdt_scale` change upstream to NUT and link it to issue #2030.
- [ ] Investigate or document upstream automatic interface selection for `usb_hid_rep_index=1` / `usb_hid_ep_in=2`.

## Later

- [ ] Add additional DSM builds only after layout and power-loss validation.
- [ ] Add additional Synology models only after independent testing.
- [ ] Validate SMART1500PSGLCD or other `09ae:3028` units separately rather than assuming identical behavior.
- [ ] Retire local NUT patching when an upstream NUT release contains validated native `3028` scaling support.
