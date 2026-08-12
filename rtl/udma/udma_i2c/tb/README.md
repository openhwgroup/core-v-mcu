# uDMA I2C status tests

The focused tests for the uDMA I2C status path use Icarus Verilog through
FuseSoC. From the repository root, register this checkout once and run both
targets:

```sh
fusesoc library add core-v-mcu .
fusesoc run --target=control-status-test openhwgroup.org:ip:udma_i2c
fusesoc run --target=status-test openhwgroup.org:ip:udma_i2c
```

`control-status-test` generates I2C START and STOP conditions on a resolved
open-drain bus. It checks the BUSY rising-edge event, verifies that a normal
STOP produces no event, and creates an unexpected STOP during an active command
to check the arbitration-lost event.

`status-test` uses asynchronous system and peripheral clocks. It checks pulse
transfer, the composite event, sticky BUSY and arbitration-lost STATUS bits,
clear-on-read behavior, and set priority when a condition and STATUS read occur
in the same cycle.
