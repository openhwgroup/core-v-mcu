# uDMA QSPI receive test

Run the self-checking Icarus Verilog regression from the repository root:

```sh
make -C rtl/udma/udma_qspi/tb
```

The test drives the SPI input pins of `udma_spim_txrx` and checks received data
with RX always ready. It covers standard and quad SPI, both bit orders, all
four CPOL/CPHA modes, 8-, 16- and 32-bit words, and one, two and four words per
DMA transfer where they fit. Each case receives two DMA transfers to exercise
packing and word boundaries. The simulation prints `TEST_PASS` on success.
