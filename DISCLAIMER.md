# Disclaimer

This project is unofficial community software. It is not affiliated with, sponsored by, or endorsed by Synology Inc., Eaton, Tripp Lite, or the Network UPS Tools project.

The project modifies UPS integration behavior on supported Synology systems. Incorrect UPS detection, telemetry, safe-mode behavior, shutdown behavior, or update handling can cause service interruption, an unclean shutdown, data loss, or other damage.

The software is provided **as is**, without warranty of any kind, to the extent permitted by applicable law. The GPL-2.0-or-later license included with this repository contains the controlling warranty and liability terms for the software distributed under that license.

Compatibility statements in this repository are factual descriptions of configurations actually tested by contributors. They are not guarantees that another NAS, DSM release, UPS revision, battery condition, USB implementation, or workload will behave identically.

Users are responsible for maintaining independent backups, verifying exact compatibility, performing a controlled on-battery test, reviewing behavior after DSM updates, and choosing their own safe-mode and UPS output-shutdown policies.

The installer is designed to fail closed on unrecognized layouts rather than make speculative changes. That design reduces risk but does not eliminate it.
