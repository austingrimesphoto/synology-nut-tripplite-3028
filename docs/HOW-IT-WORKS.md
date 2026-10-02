# How it works

DSM already contains the server/monitor side of NUT. This layer admits `09ae:3028`, forces the tested HID report/endpoint, points `driverpath` at a private NUT 2.8.5 `usbhid-ups`, and leaves DSM `upsd`, `upsmon`, `upssched`, `synoups`, notifications, and safe-mode logic stock. The stock `/usr/bin/usbhid-ups` is never overwritten.
