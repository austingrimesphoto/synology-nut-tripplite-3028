# Synology NUT compatibility for Tripp Lite USB `09ae:3028`

A conservative compatibility layer for a specific Synology + Tripp Lite UPS combination that Synology DSM does not handle correctly out of the box.

## What this fixes

On the validated system, DSM 7.4.1 recognizes many Tripp Lite USB UPS product IDs but not `09ae:3028`. Forcing DSM's bundled `usbhid-ups` to claim the device is not enough: the stock driver reports a false on-battery state and unusable telemetry.

This project keeps Synology's native UPS orchestration and substitutes only a private, patched NUT `usbhid-ups` driver.

**Validated architecture**

```text
UPS USB
  -> private patched NUT 2.8.5 usbhid-ups
  -> DSM stock upsd
  -> DSM stock upsmon / upssched / synoups
  -> DSM notifications and safe-mode handling
```

No Raspberry Pi, VM, second UPS server, or Docker runtime is required. Docker is used only as an auditable containerized build environment when building the private driver.

## Validated hardware/software

| Component | Validated value |
|---|---|
| NAS | Synology DS923+ |
| DSM | 7.4.1-90080 Update 0 |
| UPS | Tripp Lite BR1500LCDT |
| USB VID:PID | `09ae:3028` |
| NUT base | 2.8.5, commit `0e051f9f6853e9ae0087b388b70840c9651a5eed` |
| Patch | add `0x3028` to `smart1500lcdt_scale()` device table |
| Required HID selection | `usb_hid_rep_index=1`, `usb_hid_ep_in=2` |

The same USB product ID has also been reported upstream on other Tripp Lite models, including SMART1500PSGLCD, but **this repository does not claim those models as validated** until they are tested independently.

## Validation results

The validated BR1500LCDT produced stable telemetry with the patched driver:

- `ups.status`: `OL`, and during a real outage test `OB DISCHRG`, then `OL CHRG`
- input voltage: about 118.3-118.9 V
- output voltage: about 118.9 V
- battery voltage: about 27.3 V
- input/output frequency: 60.0 Hz
- output current: about 0.9-1.0 A
- battery charge: 100% during initial validation
- estimated runtime: about 2,516 seconds at about 11-12% load

DSM produced its native on-battery and utility-restored notifications during the physical power-loss test.

## Why the patch works

NUT 2.8.5 already has a Tripp Lite handler called `smart1500lcdt_scale()` that corrects malformed scaling seen on related devices. NUT applies it to product IDs `0x3016` and `0x3024`, but not `0x3028`.

The tested `3028` device reported raw values consistent with that same correction. The project patch adds one device-table entry:

```c
{ USB_DEVICE(TRIPPLITE_VENDORID, 0x3028), smart1500lcdt_scale },
```

With the existing handler applied, previously broken values became plausible: input voltage changed from `0.0` to about `118.9 V`, frequency from `6000.0 Hz` to `60.0 Hz`, battery voltage from `0.0` to `27.3 V`, and output current from roughly `100-110 A` to about `0.9-1.0 A`.

## Safety model

This project is intentionally fail-closed.

The installer refuses to proceed unless the local system matches the tested DSM architecture and expected files. It backs up the original DSM files before modification, preserves Synology's stock `usbhid-ups`, and installs a rollback script. Runtime checks block the custom path if required files or assumptions are missing.

**Do not treat this as a generic Synology UPS installer.** Unknown DSM layouts and unvalidated NAS/UPS combinations should be treated as unsupported until tested.

## Install

### 1. Obtain the ready-to-install bundle

For a tagged release, download `synology-nut-tripplite-3028-vX.Y.Z.tar.gz` from GitHub Releases. It contains the installer, the private driver runtime, build provenance, hashes, and corresponding modified NUT source.

If you prefer to build it yourself on an x86-64 system with Docker:

```bash
./scripts/build-driver.sh
```

This creates `artifacts/nut-2.8.5-3028/`. The build is pinned to NUT 2.8.5 and applies only the included `3028` patch.

### 2. Copy the extracted project to the NAS

Copy the repository somewhere on the NAS, for example:

```text
/volume1/homes/<user>/synology-nut-tripplite-3028
```

### 3. Disable DSM UPS monitoring before installation

In DSM, disable UPS support temporarily. The installer expects `ups-usb.service` to be inactive and refuses to modify a live UPS stack.

### 4. Run the installer as root

```bash
sudo ./install.sh
```

The installer copies the private runtime into `/volume1/ups-native/`, creates per-build backups, installs the compatibility scripts and systemd integration, and patches only the required Synology recognition/configuration files.

### 5. Re-enable DSM UPS support

After installation, re-enable USB UPS support in DSM. Keep UPS output shutdown disabled during the first validation test.

Then run:

```bash
sudo /volume1/ups-native/scripts/healthcheck.sh
```

See [docs/VALIDATION.md](docs/VALIDATION.md) before performing a physical AC-loss test. Safe-mode timing remains a separate DSM policy; see [docs/SAFE-MODE-POLICY.md](docs/SAFE-MODE-POLICY.md).

## Rollback

```bash
sudo /volume1/ups-native/scripts/rollback.sh
```

Rollback restores only same-build originals captured by this installation, removes the compatibility hooks, reloads systemd, and leaves DSM UPS monitoring disabled.

See [docs/RECOVERY.md](docs/RECOVERY.md).

## DSM updates

The compatibility layer backs up each DSM build separately and re-applies only narrowly scoped changes when the expected DSM layout is still present. If the layout changes in an unexpected way, it fails closed rather than restoring files from an older DSM release.

See [docs/DSM-UPDATES.md](docs/DSM-UPDATES.md) and [docs/KNOWN-LIMITATIONS.md](docs/KNOWN-LIMITATIONS.md).

## Upstream status

[NUT issue #2030](https://github.com/networkupstools/nut/issues/2030) tracks support for Tripp Lite USB product ID `3028`. This repository includes the minimal NUT patch and an upstream-ready validation summary under [`upstream/`](upstream/).

## Liability / warranty

This is unofficial community software and is not affiliated with or endorsed by Synology, Eaton/Tripp Lite, or the Network UPS Tools project. UPS monitoring and shutdown software can affect availability and data integrity. Keep independent backups and validate the behavior on your own hardware.

The software is distributed under GPL-2.0-or-later and **without warranty**. See [DISCLAIMER.md](DISCLAIMER.md) and [LICENSE](LICENSE).

## License

GPL-2.0-or-later. The NUT-derived patch is based on GPL-2.0-or-later code from Network UPS Tools.

## Maintainer publishing

For the project maintainer, `scripts/publish-all.sh` performs the public publishing workflow with GitHub CLI: it creates/pushes the repository, labels and tracking issues, tags the version so GitHub Actions builds the ready-to-install release bundle, waits for the release workflow, forks NUT, and opens the scoped upstream scaling PR when still needed.
