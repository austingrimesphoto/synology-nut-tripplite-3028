# Validation procedure

Run `sudo /volume1/ups-native/scripts/healthcheck.sh` with utility power connected. Confirm plausible voltage/frequency/battery/load values and `OL`. For a controlled outage test, keep UPS output shutdown disabled, disconnect only the UPS AC input briefly, verify `OB`/`DISCHRG` and DSM notification, restore AC, and verify `OL`/`CHRG`. Do not use writable UPS commands (`upscmd`, `upsrw`, `upsdrvctl shutdown`, `load.off`, self-tests, outlet controls) for validation.
