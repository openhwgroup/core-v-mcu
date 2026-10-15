# uDMA camera VSYNC test

Run the focused regression from the repository root with Icarus Verilog:

```sh
fusesoc --cores-root . run --target=vsync-test openhwgroup.org:ip:udma_camera
```

Use `--tool=verilator` to run the same test with Verilator. The test checks
that capture waits for the next VSYNC assertion with the default active-low
polarity and with active-high polarity, then receives exactly the new-frame
pixel through the clock-domain crossing FIFO.
