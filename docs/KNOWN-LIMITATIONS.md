# Known limitations

- Public installation support is intentionally limited to Synology DS923+ running DSM 7.4.1-90080.
- The physically validated UPS is Tripp Lite BR1500LCDT with USB VID:PID `09ae:3028`. Other models sharing the ID are not automatically supported.
- The validated installed binary had SHA-256 `01c7cce7ef49eb3f25319403b4a15b84b5a267df3e594bae131131fb35045ec6`. A fresh containerized rebuild can have a different byte hash if Alpine package revisions change; provenance and the local `SHA256SUMS` manifest are therefore checked instead of requiring that historical byte hash.
- Service restart/update-recovery behavior was validated on the original system, but a full NAS reboot persistence test is still tracked as a project task.
- The public installer itself should receive an independent clean-install/rollback validation before the support matrix is broadened.
- No automatic UPS output-power shutdown is enabled by this project. That remains a DSM/user policy decision.
