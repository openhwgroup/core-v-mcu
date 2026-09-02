# SoC event generator testbench

The self-checking `soc_event_generator_tb` regression verifies the FC mask,
FIFO event ID, CPU interrupt 11 acknowledgment, and simultaneous-event behavior
for events 7 and 8.

Run the default Verilator test from the repository root with:

```sh
fusesoc --cores-root . run --target=event-generator-test --setup --build --run openhwgroup.org:ip:soc_event_generator
```

Run the same test with Icarus through the module-local Makefile:

```sh
make -C rtl/core-v-mcu/soc/soc_event_generator/tb
```

The simulation prints `TEST_PASS` and exits successfully when all checks pass.
