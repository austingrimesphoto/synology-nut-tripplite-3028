# DSM safe-mode policy

This project fixes UPS communication; it does not choose your shutdown policy.

With DSM configured to wait for a low-battery condition rather than a fixed timer, the trigger is the NUT `LB` (low battery) state while the UPS is on battery. The UPS/driver determines when that state is asserted. Depending on hardware, variables such as `battery.charge.low` or `battery.runtime.low` may expose the threshold.

Inspect the live battery variables with:

```bash
upsc ups@localhost | grep '^battery\.'
```

For a NAS, choose a policy that leaves enough reserve for battery aging, load changes, and a clean safe-mode transition. The compatibility installer deliberately does not change DSM's safe-mode timing or enable UPS output shutdown.
