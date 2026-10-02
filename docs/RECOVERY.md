# Recovery and rollback

Run `sudo /volume1/ups-native/scripts/rollback.sh`. Rollback requires a same-build manifest, stops the UPS service, restores only same-build originals, removes persistence hooks, reloads systemd, and verifies hashes. Never restore an older DSM build's `/usr` or `/etc.defaults` files over a newer DSM release.
