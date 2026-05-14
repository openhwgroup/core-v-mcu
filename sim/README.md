# Claude Generated Modifications

## Goal
Get the CORE-V MCU Verilator simulation compiling and running from the cloned `MikeCovrado/core-v-mcu` repository.

---

## Environment setup
- Cloned the repo via SSH to `/home/mike/Claude/core-v-mcu`
- Created a Python venv at `~/venv/core-v-mcu` and installed **FuseSoC 2.4.6** into it (the project's build orchestration tool)
- All RTL dependencies (`pulp-platform.org::axi`, `common_cells`, `riscv_dbg`, `cv32e40p`, `efpga`, etc.) were already present in the repo as local FuseSoC cores — no external fetching required

---

## Source fixes

Two bugs prevented compilation with Verilator 5.048 (the project was originally written against 4.100):

| File | Line | Problem | Fix |
|------|------|---------|-----|
| `rtl/simulation/PLL18_TOP.sv` | 50 | `CLKO = 0l\;` — malformed literal with a spurious `l\` suffix, illegal in Verilator 5.x | Changed to `CLKO = 0;` |
| `core-v-mcu.core` | model-lib verilator_options | Missing timing directive — Verilator 5.x requires `--timing` or `--no-timing` when the RTL contains `<= #1` intra-assignment delays (in `A2_fifo_ctl.sv`) | Added `--no-timing` (the delays are simulation glue, not functionally significant) |

---

## Build steps

From the repo root:

```bash
# Lint check (verify RTL parses cleanly)
~/venv/core-v-mcu/bin/fusesoc --cores-root . run --target=lint --setup --build \
    openhwgroup.org:systems:core-v-mcu

# Build Verilator C++ model library
~/venv/core-v-mcu/bin/fusesoc --cores-root . run --target=model-lib --setup --build \
    openhwgroup.org:systems:core-v-mcu
```

This produces `build/.../model-lib-verilator/obj_dir/Vcore_v_mcu__ALL.a` and `libverilated.a`.

The simulation harness is then built via the `sim/Makefile` `verilator` target, which also
populates `sim/mem_init/`:

```bash
cd sim
make verilator
```

---

## Files generated/added in `sim/`

| File/Dir | Origin | Description |
|----------|--------|-------------|
| `sim_main.cpp` | Created | C++ simulation harness. Instantiates `Vcore_v_mcu`, drives `ref_clk_i` at 100 MHz, holds `rstn_i` low for 20 cycles then deasserts. Accepts optional `[cycles]` and `[trace.vcd]` arguments on the command line. |
| `sim_core_v_mcu` | Compiled (not checked in) | Linked executable produced by `make verilator`. Listed in `.gitignore`. |
| `mem_init/` | Derived (not checked in) | Directory of memory initialisation files expected by the RTL `$readmem` calls. Populated by `make mem_init` (also a dependency of `make verilator`). Listed in `.gitignore`. |
| `mem_init/boot.mem` | Copied from `tb/mem_init_files/verilatorBoot.mem` | Boot ROM contents. Uses the Verilator-specific variant (distinct from the ModelSim one). |
| `mem_init/cli.txt` | Copied from `tb/mem_init_files/cli_sim.txt` | CLI simulation data used by the testbench environment. |
| `mem_init/TOP.core_v_mcu...CUTS[0-3].bank_i.u0.mem` | Copied from `tb/mem_init_files/col[0-3].mem` | L2 interleaved RAM bank initialisation. File names match the hierarchical paths used in the RTL `$readmem` calls. |
| `mem_init/TOP.core_v_mcu...bank_sram_pri[0-1]_i.u0.mem` | Copied from `tb/mem_init_files/privateBank[0-1].mem` | L2 private RAM bank initialisation. |
| `what_claude_did.md` | Created | This file. |

`trace.vcd` (produced by passing a `.vcd` filename to the simulator) is already covered by the
`*.vcd` entry in the repo's top-level `.gitignore`.

---

## .gitignore additions

Two entries were added to the repo's top-level `.gitignore`:

```
sim/mem_init/
sim/sim_core_v_mcu
```

The `mem_init/` files are copies of sources already tracked under `tb/mem_init_files/`; checking
them in would create duplication and risk the copies going stale. Both are derived artifacts that
`make verilator` recreates from scratch.

---

## Running the simulation

```bash
cd sim

./sim_core_v_mcu               # 2000 cycles (default)
./sim_core_v_mcu 1000          # 1000 cycles
./sim_core_v_mcu 500 trace.vcd # 500 cycles + VCD waveform
```
