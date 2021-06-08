[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Documentation Status](https://readthedocs.org/projects/core-v-mcu/badge/?version=latest)](https://core-v-mcu.readthedocs.io/en/latest/?badge=latest)

# CORE-V MCU

> CORE-V MCU originated from PULPissimo and is currently in change to become a
> stand-alone project within OpenHW Group independent from PULPIssimo.
>
> In case you should be interested to join the project please feel free to open
> an issue, or involve yourself in any open issues/discussions.

## Getting Started

Install the required Python tools:

```
pip3 install --user -r python-requirements.txt
```

Install fusesoc: https://fusesoc.readthedocs.io/en/stable/user/installation.html#ug-installation

## Building

The build system uses make to capture the required steps.
make with no argments will print a list of the current targets:
```
$ make
all:            generate build scripts, custom build files, doc and sw header files
bitstream:      generate nexysA7-100T.bit file for emulation
lint:           run Verilator lint check
doc:            generate documentation
sw:             generate C header files (in ./sw)
nexys-emul:     generate bitstream for Nexys-A7-100T emulation)
buildsim:       build for Questa sim
sim:            run Questa sim
```

## Building an FPGA Image

To target the Nexys-A7-100T board:
```
$ make nexys-emul
```

Make sure you have the latest Xilinx board-parts installed.


Currently unsupported:
```
$ make genesys2
```

## Building documentation
```
$ make docs
```
The resulting documents are accessed using file ./docs/_build/html/index.html

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
