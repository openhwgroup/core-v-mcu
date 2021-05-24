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
lint:           run Verilator lint check
docs:           generate documentation (./docs/_build/html/index.html)
sw:             generate C header files (in ./sw)
nexys-emul:     generate bitstream for Nexys-A7-100T (./emulation/core-v-mcu-nexys-a7-100t.bit)
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

## Building documenation
```
$ make docs
```
The resulting documents are accessed using file ./docs/_build/html/index.html

## Building C header files
```
$ make docs
```
The resulting header files are located in ./sw