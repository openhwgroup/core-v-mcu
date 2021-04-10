# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Removed
### Fixed

## [2.0.1] - 2021-01-11
### Added
### Changed
- Changed address aliasing rules to be identical to the behavior of the legacy
  interconnect.
### Removed
### Fixed
- Fix wrong address part select in SRAM wrappers that caused part of the
  memories to be inaccessible and alias into lower address ranges.


## [2.0.0] - 2020-12-11
### Added
- Completely replaced `soc_interconnect` with a new parametric version
- Added AXI Crossbar to `soc_interconnect` to attach custom IPs
- Added new `pulp_soc` parameter to isolate the axi plug CDC fifo in case it is not needed
- Add `register_interface` as dependency to simplify integration of custom ip using reggen
- Properly assert `r_opc` signal in new interconnect to indicate bus errors
- Add error checking for illegal access on HWPE ports which only have access to L2 interleaved memory
### Changed
- AXI ID width of cluster plugs are now set to actually required width instead of a hardcoded one
- TCDM protocol to SRAM specific protocol is moved from interconnect to memory bank module
### Removed
- obsolete `axi_node` dependency
- obsolete header files

## [1.4.2] - 2020-11-04
### Fixed
- Propagate `ZFINX` parameter

## [1.4.1] - 2020-10-28
### Changed
- Bump `fpnew` to `v0.6.4`

### Fixed
- Fix bad dependency of fpnew

## [1.4.0] - 2020-10-02
### Changed
- Bump `fpnew` to `v0.6.3`

### Fixed
- Fix drive input address in bootrom

## [1.3.0] - 2020-07-30
### Changed
- Bump `udma_i2s` to `v1.1.0`

### Removed
- `axi_slice_dc_master_wrap` and `axi_slice_dc_slave_wrap`. These are already
  provided by the `axi_slice_dc` ip.

## [1.2.0] - 2020-05-18
### Added
- Make number of I2C and SPI parametrizable
- Allow external fc_fetch signal to control booting

### Changed
- Prefer for loop over for gen for hartinfo

### Removed
- Quentin specific SCM code

### Fixed
- Elaboration issue when using constant function before declaration
- Style issue
- Missing signals for jtag
- Parameter propagation of `NBIT_CFG`, `NPAD` and `NUM_GPIO`
- Name generate statements

## [1.1.1] - 2020-01-24
### Fixed
- Fix wrong ID WIDTH in soc/cluster AXI bus

## [1.1.0] - 2020-01-20

### Changed
- Propagate cluster debug signals
- Make selectable harts/hartinfo/cluster debug signals parametrizable according
  to NB_CORES
- Rewrite generate blocks to for-genvar loops
- Annotate ips in `ips_list.yml` with usage domain

### Removed
- `axi_mem_if`

## [1.0.1] - 2019-11-21

### Changed
- Bump `axi` to `v0.7.1`
- Bump `axi_node` to `v1.1.4`

### Fixed
- Remove `axi_test.sv` from synthesized files

## [1.0.0] - 2019-11-18

### Added
- ibex support
- FPGA support (`PULP_FPGA_EMUL`) macros
- CHANGELOD.md
- `axi` with version `v0.7.0`

### Changed
- Bump `tech_cells_generic` to `v0.1.6`
- Bump `riscv` (RI5CY) to `pulpissimo-3.4.0`
- Keep `udma_i2c` on `vega_v1.0.0`
- Bump `udma*` to `v1.0.0` (except `udma_i2c`)
- Bump `apb_gpio` to `v0.2.0`
- Bump `jtag_pulp` to `v0.1`
- Bump `hwpe` to `v1.2`
- Bump `axi_node` to `v1.1.3`
- Bump `axi_slice` to `v1.1.4`
- Bump `axi_slice_dc` to `v1.1.3`
- Bump `common_cells` to `v1.13.1`
- Bump `fpnew` to `v0.6.1`
- Bump `riscv-dbg` to `v0.2`
- Bump `apb_interrupt_cntrl` to `v0.0.1`
- Bump `apb_node` to `v0.1.1`
- Bump `apb_adv_timer` to `v1.0.2`
- Bump `apb2per` to `v0.0.1`
- Bump `adv_dbg_if` to `v0.0.1`
- Bump `timer_unit` to `v1.0.2`
- Tag `generic_FLL` with `v0.1`
- Tag `axi_mem_if` with `v0.2.0`

### Fixed
- udma connection issues
- various synthesis issues
- Remove parasitic latches in TCDM bus
- bad signal names
- typo in cluster reset signal

### Removed
- zero-riscy support

## [0.0.1] - 2018-02-08

### Added
- Initial release
