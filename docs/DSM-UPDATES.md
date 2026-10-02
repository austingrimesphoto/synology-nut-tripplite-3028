# DSM updates

DSM can replace `/usr`, `/usr/lib/udev`, `/etc.defaults`, and regenerate `/etc/ups/ups.conf`. Persistence uses an `ups-usb.service` pre-start gate, an enabled one-shot compatibility service, and `/usr/local/etc/rc.d/ups-native-compat.sh`. A new DSM build gets a new backup/manifest before changes. Unexpected layouts fail closed. This release does not automatically retire the private driver merely because a future DSM table contains `09ae:3028`; native telemetry must be validated first.
