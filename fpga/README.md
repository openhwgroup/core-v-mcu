## Instructions to build the core-v-mcu environment:

The following instructions start from a clean Ubuntu 18.04 installation.


1. Download and install the [Embecosm toolchain](https://buildbot.embecosm.com/job/corev-gcc-ubuntu1804/2/artifact/corev-openhw-gcc-ubuntu1804-20200705.tar.gz)
``` 
$ cp ~/Downloads/corev-openhw-gcc-ubuntu1804-20200705.tar.gz /opt/.
$ tar xvfz corev-openhw-gcc-ubuntu1804-20200705.tar.gz
$ export PULP_RISCV_GCC_TOOLCHAIN=/opt/corev-openhw-gcc-ubuntu1804-20200705
$ export PATH=$PULP_RISCV_GCC_TOOLCHAIN/bin:$PATH
```
2. Install the PULP SDK
```
Install the dependencies for Ubuntu 16.04:
  $ sudo apt install git python3-pip python-pip gawk texinfo libgmp-dev libmpfr-dev libmpc-dev swig3.0 libjpeg-dev lsb-core doxygen python-sphinx sox graphicsmagick-libmagick-dev-compat libsdl2-dev libswitch-perl libftdi1-dev cmake scons libsndfile1-dev
  $ sudo pip3 install artifactory twisted prettytable sqlalchemy pyelftools 'openpyxl==2.6.4' xlsxwriter pyyaml numpy configparser pyvcd
  $ sudo pip2 install configparser

$ git clone https://github.com/pulp-platform/pulp-sdk
$ cd pulp-sdk
$ source configs/pulpissimo.sh
$ source configs/platform_fpga.sh
$ make all
$ source sourceme.sh
```
3. Install patched version of OpenOCD:
```
$ source sourceme.sh && ./pulp-tools/bin/plpbuild checkout build -—p openocd -—stdout
```
4. Install the Core-v-mcu repo:
```
$ sudo apt install curl
$ git config --global user.email “your email address”
$ git config --global user.name “your name”
$ git clone https://github.com/openhwgroup/core-v-mcu.git
$ cd core-v-mcu
$ ./update-ips
```
5. Install Xilinx Vivado (currently we've been using 2018.2 to match original Pulpissimo build). To build for the Genesys2 board, you will need the full Vivado Design Suite and a license (Genesys2 board should include a voucher for a device-locked license). To build for the NexysA7-100T, the free Xilinx Vivado WebPack is sufficient. If you are only using Xilinx tools to download pre-generated bitstreams, you only need to install Vivado Lab Edition (this does not include any design tools). Install Vivado in the default location `/opt/Xilinx`.
6. Install the Digilent board files. Vivado does not install the board definition files for NexysA7. Board definition files are typically installed here:
```
/opt/Xilinx/Vivado/2018.2/data/boards/board_files
```
You can add these files to your installation by downloading the Digilent board files archive [here](https://github.com/Digilent/vivado-boards/archive/master.zip?_ga=2.131969359.177444068.1597675206-2125281860.1520869899) and then:
```
$ cd ~/Downloads
$ unzip vivado-boards-master.zip
$ cd vivado-boards-master/new/board_files
$ cp -Rf nexys-a7-100t /opt/Xilinx/Vivado/2019.2/data/boards/board_files/.
```

7. Install Xilinx cable drivers (make sure any download cables are not connected when you do this):
``` 
$ sudo /opt/Xilinx/Vivado/2018.2/data/xicom/cable_drivers/lin64/install_script/install_drivers
```
8. Setup the Vivado environment:
```
$ source /opt/Xilinx/Vivado/2018.2/settings64.sh
```
9. Install the PULP simple runtime:
```
$ git clone https://github.com/pulp-platform/pulp-runtime.git
$ cd pulp-runtime
$ source configs/pulpissimo.sh
$ source configs/fpgas/pulpissimo/genesys2.sh (or nexysA7.sh)
```
10. Download the pulp-runtime-examples:
```
$ git clone https://github.com/pulp-platform/pulp-runtime-examples.git
$ cd pulp-runtime-examples/hello
$ make clean all
```
## Instructions to download the pre-built bitstream
Pre-built FPGA bitstreams for Genesys2 and NexysA7-100T are available [here](https://github.com/openhwgroup/core-v-mcu/tree/master/fpga/bitstreams)

1. Start Vivado and program the FPGA
```
$ vivado  (note: if using Labtools Edition, use vivado_lab)
```
Open the Hardware Manager
Open Target
Program Device (use one of the pre-built bitstream files in the `$PULP/fpga/cv32e40p_bitstreams` directory)

Once the bitstream has been programmed, quit Vivado.

2. Connect to the serial/UART. In a terminal window:
```
$ sudo screen /dev/ttyUSB0 115200
```
(note, your USB port number may be different)

3. In another terminal window, start OpenOCD
```
$ cd $PULP/fpga/pulpissimo-genesys2
$ $OPENOCD/bin/openocd -f openocd-genesys2.cfg
```
4. In yet another terminal window start gdb
```
$ cd pulp-runtime-examples/hello
$ $PULP_RISCV_GCC_TOOLCHAIN/bin/riscv32-unknown-elf-gdb build/test/test
```
5. Connect and debug your program in gdb
```
target remote localhost:3333
load
continue
```
You should see the "Hello!" message in the serial terminal window.

## Instructions to modify Pulpissimo to instantiate CV32E40P and build the FPGA bitstream

The procedure above will install the Pulpissimo environment with the RI5CY core. To replace RI5CY with CV32E40P, the following modifications should be made (the $PULP variable refers to your location of the core-v-mcu source directory):

1. Download the cv32e40p source
``` 
$ git clone https://github.com/openhwgroup/cv32e40p
```

2. Replace the RI5CY source directory:
```
$ cp -Rf cv32e40p $PULP/ips/.
$ cd $PULP/ips
$ rm -Rf riscv
$ ln -s cv32e40p riscv
```

3. Modify the $PULP/ips/riscv/rtl/cv32e40p_sleep_unit.sv source file, line 155 to replace the clock gate module. Replace the text:
```
cv32e40p_clock_gate core_clock_gate_i
```
with
```
tc_clk_gating core_clock_gate_i //this module is found in $PULPISSIMO/ips/tech_cells_generic/src/fpga/tc_clk_xilinx.sv
```

4. Replace the source file that instantiates RISCY with a modified version that instantiates cv32e40p:
```
$ cp $PULP/fpga/cv32e40p_modified_files/fc_subsystem.sv $PULP/ips/pulp_soc/rtl/fc/fc_subsystem.sv
```

5. Replace the tcl files in $PULP/tcl with modified files:
```
$ cp $PULP/fpga/cv32e40p_modified_files/*.tcl $PULP/fpga/pulpissimo/tcl/.
```

6. Follow the regular PULPissimo instructions to build the FPGA platform, for example:
```
$ cd $PULP/fpga
$ make clean_genesys2. [or make clean_nexys rev=nexysA7-100T]
$ make genesys2 [or make nexys rev=nexysA7-100T]
```
7. Download

Pre-built FPGA bitstreams for the Genesys2 and NexsyA7-100T boards are [here](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga/bitstreams)
