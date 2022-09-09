[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Documentation Status](https://readthedocs.org/projects/core-v-mcu/badge/?version=latest)](https://core-v-mcu.readthedocs.io/en/latest/?badge=latest)

# CORE-V MCU

> CORE-V MCU originated from PULPissimo \[[1](https://ieeexplore.ieee.org/abstract/document/8640145)\], \[[2](https://ieeexplore.ieee.org/document/9369856)\]. and is now a
> stand-alone project within OpenHW Group independent from PULPIssimo.
>
> In case you should be interested to join the project please feel free to open
> an issue, or involve yourself in any open issues/discussions.

## Quick Start Guide

The fastest way to get up and running with the CORE-V MCU is with pre-built bit streams for the Digilent Nexys A7 board. Check out the [Quick Start Guide](https://github.com/openhwgroup/core-v-mcu/tree/master/emulation/quickstart/README.md).

## Getting Started

Install the required Python tools:

```
pip3 install --user -r python-requirements.txt
```

Install fusesoc: https://fusesoc.readthedocs.io/en/stable/user/installation.html#ug-installation

Install Verilator v4.100: https://verilator.org/guide/latest/install.html

## Building

The build system uses make to capture the required steps.
make with no argments will print a list of the current targets:
```
$ make
all:            generate build scripts, custom build files, doc and sw header files
bitstream:      generate nexysA7-100T.bit file for emulation
model-lib:      build a Verilator model library
lint:           run Verilator lint check
docs:           generate documentation
sw:             generate C header files (in ./sw)
nexys-emul:     generate bitstream for Nexys-A7-100T emulation)
genesys2-emul:  generate bitstream for Genesys2 FPGA board
buildsim:       build for Questa sim
sim:            run Questa sim
downloadn:      Download bitstream to Nexys board
downloadg:      Download bitstream to Genesys2 board
```

## Building an FPGA Image

To target the Nexys-A7-100T board:
```
$ make nexys-emul
```

Make sure you have the latest Xilinx board-parts installed.
Current image is [core_v_nexys_200122.bit](http://core-v-mcu.s3-website-eu-west-1.amazonaws.com/core_v_mcu_nexys_200122.bit)


To target Genesys2 board:
```
$ make genesys2-emul
```
Extra note for building on ubuntu - Vivado tools from Xilinx may require a larger swap size that the system default.
The swap size can be increased by searching for "increase swapfile in ubuntu" and add your release.

## Building documentation

```
$ make docs
```
The resulting documents are accessed using file ./docs/\_build/html/index.html

### Documentation of the Debug Unit

At present the details of the debug unit are not incorporated in the main
documentation.  The top level interface is an IEEE 1149.1 compliant JTAG Test
Access port.  It implements the reference JTAG Debug Transport Module
documented in Section 6.1 of the [RISC-V Debug Interface, version
0.13.2](https://riscv.org/wp-content/uploads/2019/03/riscv-debug-release.pdf).

The RISC-V Debug Interface has many optional features.  Those enabled for the
CORE-V MCU are documented in the [PULP Platform Debug
Unit](https://github.com/pulp-platform/riscv-dbg).

## Building C header files

```
$ make sw
```
The resulting header files are located in ./sw

## Running Modelsim/Questasim

```
$ make buildsim sim
```
The 'make buildsim' creates a work library in build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim, and then 'make sim' runs the simulation.

The test bench used by the simulation is 'core_v_mcu_tb.sv'

The resulting header files are located in ./sw

## Experimental fuseSoC Support

Run Verilator lint target:

```
fusesoc --cores-root . run --target=lint --setup --build openhwgroup.org:systems:core-v-mcu
```

To build Verilator as a library which can be linked into other tools (such as
the debug server):

```
fusesoc --cores-root . run --target=model-lib --setup --build openhwgroup.org:systems:core-v-mcu
```

The library will be in the `obj_dir` subdirectory of the work root.

Once can sanity check the top-level using QuestaSim:

```
fusesoc --cores-root . run --target=sim --setup --build --run openhwgroup.org:systems:core-v-mcu
```

## Contributing: Pre-commit checks

If you are submitting a pull-request, it will be subject to pre-commit checks.  The two that most likely cause problems are the Verilator Lint check and the Verible format check.

### Verilator model library

The system will run
```
fusesoc --cores-root . run --target=model-lib --setup --build openhwgroup.org:systems:core-v-mcu
```
If your changes introduce any Verilator errors, you either need to fix these, or, if appropriate, add a rule to ignore them to `rtl/core-v-mcu/verilator.waiver`.

This will create the Verilator library `Vcore_v_mcu_wrapper__ALL.a` in `build/openhwgroup.org_systems_core-v-mcu_0/model-lib-verilator/obj_dir`.

Note that when you use this library to build an application you will need to
ensure that the directory `build/openhwgroup.org_systems_core-v-mcu_0/model-lib-verilator/mem_init` is either symbolically linked or copied to the directory where the application will run. The model will load ROM images from this directory.

### Verilator lint check

The system will run
```
fusesoc --cores-root . run --target=lint --setup --build openhwgroup.org:systems:core-v-mcu
```
If your changes introduce any more Verilator lint warnings, you either need to fix these, or, if appropriate, add a rule to ignore them to `rtl/core-v-mcu/verilator.waiver`.

### Verible format check

Standard formating is enforced by [Verible](https://github.com/google/verible).  The command used is
```
util/format-verible
```
at the top level of the repository, which will correct the format of any file. The check will fail if any file is changed.

Two important things to note.

1.  If you do not have Verible installed (which is likely), then `util/format-verible` will silently do nothing.

2.  You must install the correct version of Verible, currently v0.0-1051-gd4cd328.  GitHub has [prebuilt versions](https://github.com/google/verible/releases/tag/v0.0-1051-gd4cd328).  The version may change in the future.  In the event of the check failing, the details with the failure will tell you which version was used.

## References

1. [Schiavone, Pasquale Davide, et al. "Quentin: an ultra-low-power pulpissimo soc in 22nm fdx." 2018 IEEE SOI-3D-Subthreshold Microelectronics Technology Unified Conference (S3S). IEEE, 2018.](https://ieeexplore.ieee.org/abstract/document/8640145)

2. [Schiavone, Pasquale Davide, et al. "Arnold: An eFPGA-Augmented RISC-V SoC for Flexible and Low-Power IoT End Nodes." IEEE Transactions on Very Large Scale Integration (VLSI) Systems 29.4 (2021): 677-690.](https://ieeexplore.ieee.org/document/9369856)
