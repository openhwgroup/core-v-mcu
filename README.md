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

Make sure the generated scripts are up-to-date:

```
./generate-scripts
```

Build the system using Modelsim:

```
make build
```

## Building an FPGA Image

```
$ cd fpga
$ make nexys rev=nexysA7-100T
```

Make sure you have the latest Xilinx board-parts installed.


Currently unsupported:
```
$ make genesys2
```

## Experimental fuseSoC Support

Once can sanity check the top-level using QuestaSim:

```
fusesoc --cores-root . run --target=sim --setup --build --run openhwgroup.org:systems:core-v-mcu
```
