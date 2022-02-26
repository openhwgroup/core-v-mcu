# CORE-V-MCU Quick Start Guide
Eventually, this will be a Quick Start Guide document to guide you through
running the CORE-V-MCU and 'real' test-programs on either a Verilator simulation
model or in emulation on either the Nexys A7 or Genesys2 evaluation boards.

The following assumes you are running on a Linux platform and has been tested under Ubuntu 20.04.

## Nexys A7

### Requirements:
Install the free-to-use WebTalk version of Vivado. Then:
```
$ apt install minicom
$ pip3 install pyserial
$ pip3 install pygame
```

### Install and setup MINICOM terminal emulator:
Note: you can use your favorite terminal emulator if you already have one.
Installation and setup instructions can be found [here](https://help.ubuntu.com/community/Minicom).
The remainder of this document assumes you have attached Minicom to /dev/ttyUSB1 on your machine.

### Files:
At ths time, Nexys A7 Quickstart comes with the following pre-compiled files which you will find in this directory:
- `core_v_mcu_nexys.bit`: Xilinx FPGA bitmap for XC7A100T on Nexys-A7 board
- `cli_test.srec`: "S-record" file of compiled "cli_test" program.

Also provide is `serialPort.py`, a Python script to push the bitmap to the Nexys-A7 over a serial port.

Future updates to this Quick Start will point you to the OpenHW Group
[downloads](http://downloads.openhwgroup.org/)
where you will be able to fetch the lastest pre-compiled FPGA bitmaps and test-programs.

### Push the BitMap to the Nexys A7:
```
$ make -C ../../  downloadn
```

### Download the compiled test-program "cli_test.srec"
```
$ python3 serialPort.py /dev/ttyUSB1 cli_test.srec
```
This stake a little while... Then:
```
$ minicom usb1
```

### Running "cli_test" on minicom terminal:
```
[0] help             # list of commands
[0] help misc        # list of agruments for misc command
[0] misc             # jump to misc command handler
[1] help             # list arguments for current command handler (misc in thhis case)
[1] exit             # exit current command handler (misc in this case)
[0] misc simul 1 0   # full misc command: runs the 'simul' test.
```

#### Understanding IO-muxing on CORE-V-MCU
| Nexys A7 Resource | XC7A100T IO | IONUM | MUX_SEL=0 | MUX_SEL=1 | MUX_SEL=2 | MUX_SEL=3 |
+-------------------+-------------+-------+-----------+-----------+-----------+-----------+
| LED[0]            | IO_11       | 11    | apbio_32  | apbio_47  | apbio_4   | fpgaio_4  |

#### Toggle LED[0] on the Nexys-A7 board:
```
[0] io setmux 11 2   # Set mux-select for IO 11 to 2 (apbio_4 now drives IO_11).
[0] gpio mode 4 1    # Set 'mode' of GPIO 4 to 1.
                     # Somehow, you are supposed to know that GPIO 4 is apbio_4.
                     # Not sure what mode 1 is.
[0] gpio toggle 4    # Toggle state of GPIO 4.
[0] gpio toggle 4    # Toggle state of GPIO 4.
```
