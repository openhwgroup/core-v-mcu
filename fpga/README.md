# Setup and build instructions for the FPGA Platform

The instructions below describe how to install and use the core-v-mcu FPGA environment:

[Instructions to install the core-v-mcu environment](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga#instructions-to-install-the-core-v-mcu-environment)

[Instructions to modify Pulpissimo to instantiate CV32E40P and build the FPGA bitstream](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga#instructions-to-modify-pulpissimo-to-instantiate-cv32e40p-and-build-the-fpga-bitstream)

[Instructions to download a pre-built FPGA bitstream](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga#instructions-to-download-the-pre-built-bitstream)

[Instructions to build and run an application](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga#instructions-to-build-and-run-an-application)

[Instructions to run Questasim simulation of the platform](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga#instructions-to-simulate-pulpissimo-with-cv32e40p-using-mentor-graphics-questasimmodelsim)


## Instructions to install the core-v-mcu environment:

The following instructions start from a clean Ubuntu 18.04 installation. Note
that to build the PULP environment, we use the old PULP GNU tool chain. The
new CORE-V GNU tool chain can be downloaded later.

1. Download and install the [pre-built PULP GCC toolchain from Embecosm](https://www.embecosm.com/resources/tool-chain-downloads/#pulp). In this case select the `tar.gz` file for Ubuntu 18.04. We shall assume the tool chain is to be installed in `/opt`, but it can be any writable directory on your machine, including in your home directory. Just replace `/opt` by the directory you have chosen in the following instructions. The actual name of the downloaded file will vary, and you should adjust the following commands accordingly. In this case, we are using `pulp-gcc-ubuntu1804-20200913.tar.gz` and assume you have downloaded it into your `Downloads` directory.
```
$ tar xf ~/Downloads/pulp-gcc-ubuntu1804-20200913.tar.gz
$ export PULP_RISCV_GCC_TOOLCHAIN=/opt/pulp-gcc-ubuntu1804-20200913
$ export PATH=$PULP_RISCV_GCC_TOOLCHAIN/bin:$PATH
```
2. Install the PULP SDK

Install the Linux dependencies:
```
  $ sudo apt install git python3-pip python-pip gawk texinfo libgmp-dev libmpfr-dev libmpc-dev swig3.0 libjpeg-dev lsb-core doxygen python-sphinx sox graphicsmagick-libmagick-dev-compat libsdl2-dev libswitch-perl libftdi1-dev cmake scons libsndfile1-dev
  $ sudo pip3 install artifactory twisted prettytable sqlalchemy pyelftools 'openpyxl==2.6.4' xlsxwriter pyyaml numpy configparser pyvcd
  $ sudo pip2 install configparser
```
Install the PULP SDK:
```
$ git clone https://github.com/pulp-platform/pulp-sdk
$ cd pulp-sdk
$ source configs/pulpissimo.sh
$ source configs/platform-fpga.sh
$ make all
$ source sourceme.sh
```
3. Install patched version of OpenOCD:

If you have not previously configured git, then you need to configure your
name and email address:
```
$ git config --global user.email “your email address”
$ git config --global user.name “your name”
```

Then install the patched version of OpenOCD:

```
$ source sourceme.sh && ./pulp-tools/bin/plpbuild checkout build --p openocd --stdout
$ cd ..
```

If you have a slightly newer version of the compiler, the build may fail (one of the newer checkers identifies a potential issue). To resolve this you need to edit the file `./pulp-sdk/scripts/build-openocd`. Change it from
```bash
#!/bin/bash -ex

./bootstrap
./configure --prefix=$OPENOCD_INSTALL_DIR
make install
```
to
```bash
#!/bin/bash -ex

./bootstrap
./configure --disable-werror --prefix=$OPENOCD_INSTALL_DIR
make install
```

4. Install the core-v-mcu repo (this should be done in a directory in which you have write permssions, such as in your home directory):
```
$ sudo apt install curl
$ git clone https://github.com/openhwgroup/core-v-mcu.git
$ cd core-v-mcu
$ export COREVMCU=$(pwd)
$ ./update-ips
```
5. Download and install Xilinx Vivado (currently procedure has been tested using 2019.2). You will need to register for a Xilinx account to download the [installer](https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2019.2_1106_2127_Lin64.bin). To build for the Genesys2 board, you will need the full Vivado Design Suite and a license (Genesys2 board should include a voucher for a device-locked license). To build for the NexysA7-100T, the free Xilinx Vivado WebPack is sufficient (this can be selected during the installation). If you are only using Xilinx tools to download pre-generated bitstreams, you only need to install Vivado Lab Edition (this does not include any design tools). Install Vivado in the default location `/opt/Xilinx`.

More detail on installing Vivado can be found [here](https://reference.digilentinc.com/vivado/installing-vivado/start ).

6. Install the Digilent board files. Vivado does not install the board definition files for Genesys 2 or NexysA7. Board definition files are typically installed here:
```
/opt/Xilinx/Vivado/2019.2/data/boards/board_files
```
You can add these files to your installation by downloading the Digilent board files archive [here](https://github.com/Digilent/vivado-boards/archive/master.zip?_ga=2.131969359.177444068.1597675206-2125281860.1520869899) and then:
```
$ cd ~/Downloads
$ unzip vivado-boards-master.zip
$ cd vivado-boards-master/new/board_files
$ sudo cp -Rf nexys-a7-100t /opt/Xilinx/Vivado/2019.2/data/boards/board_files/.
$ sudo cp -Rf genesys2 /opt/Xilinx/Vivado/2019.2/data/boards/board_files/.
```

7. Install Xilinx cable drivers (make sure any download cables are not connected when you do this):
``` 
$ cd /opt/Xilinx/Vivado/2019.2/data/xicom/cable_drivers/lin64/install_script/install_drivers
$ sudo ./install_drivers
```
8. Setup the Vivado user environment:
```
$ source /opt/Xilinx/Vivado/2019.2/settings64.sh
```
9. Install the PULP simple runtime:
```
$ git clone https://github.com/pulp-platform/pulp-runtime.git
$ cd pulp-runtime
$ source configs/pulpissimo.sh
$ source configs/fpgas/pulpissimo/nexys_video.sh (or genesys2.sh)
```
10. Download the pulp-runtime-examples (this should be done in a directory for which you have write permission such as your home directory):
```
$ git clone https://github.com/pulp-platform/pulp-runtime-examples.git
$ cd pulp-runtime-examples/hello
$ make clean all
```


## Instructions to modify Pulpissimo to instantiate CV32E40P and build the FPGA bitstream

The procedure above will install the Pulpissimo environment with the RI5CY core. To replace RI5CY with CV32E40P, the following modifications should be made (the $COREVMCU variable refers to your location of the core-v-mcu source directory):

1. Download the cv32e40p source (note: due to changes in cv32e40p source files, we will temporarily use an older version of the core so we don't break the FPGA scripts):
```
$ git clone https://github.com/openhwgroup/cv32e40p
$ cd cv32e40p
$ git checkout 916d92a
$ cd ..
```

2. Replace the RI5CY source directory:
```
$ cp -Rf cv32e40p $COREVMCU/ips/.
$ cd $COREVMCU/ips
$ rm -Rf riscv
$ ln -s cv32e40p riscv
```

3. Modify the $COREVMCU/ips/riscv/rtl/cv32e40p_sleep_unit.sv source file; starting at line 155 replace the clock gate module `cv32e40p_clock_gate` with
```
tc_clk_gating core_clock_gate_i
//this module is found in $COREVMCU/ips/tech_cells_generic/src/fpga/tc_clk_xilinx.sv
(
   .clk_i     ( clk_i       ),
   .en_i      ( clock_en    ),
   .test_en_i ( scan_cg_en  ),
   .clk_o     ( clk_o       )

);
```

4. Replace the source file that instantiates RISCY with a modified version that instantiates cv32e40p:
```
$ cp $COREVMCU/fpga/cv32e40p_modified_files/fc_subsystem.sv $COREVMCU/ips/pulp_soc/rtl/fc/fc_subsystem.sv
```

5. Replace the tcl files in $COREVMCU/tcl with modified files:
```
$ cp $COREVMCU/fpga/cv32e40p_modified_files/*.tcl $COREVMCU/fpga/pulpissimo/tcl/.
```
6. Follow the regular PULPissimo instructions to build the FPGA platform, for example:
```
$ cd $COREVMCU/fpga
$ make clean_genesys2 [or make clean_nexys rev=nexysA7-100T]
$ make genesys2 [or make nexys rev=nexysA7-100T]
```
A bitstream file will be created, for example, `pulpissimo_nexys.bit`.



## Instructions to download the pre-built bitstream

Pre-built FPGA bitstreams for Genesys2 and NexysA7-100T are available [here](https://github.com/openhwgroup/core-v-mcu/tree/master/fpga/cv32e40p_bitstreams)

Note: if you are using a VirtualBox VM, you may need to enable the 2 USB ports from the USB Settings icon at the bottom of your VM's window. You should see 2 Digilent USB Devices ([0900] and [0700]). Ensure there are check marks beside both.

### If you are using the Digilent NexysA7-100T board
1. Connect microUSB cable to PROG/UART (J12) port on NexysA7

2. Connect Digilent JTAG-HS2 cable to Pmod JA port (top row); ensure GND and VDD ports on JTAG-HS2 cable align with GND and VDD pins on Pmod JA

3. To program through USB cable, ensure jumper on MODE pins JP1 is across pins 2-3 (JTAG)

4. Power on the board (note that power is from the microUSB cable connected to J12)

Your board setup should look similar to the image below:
![alt text](https://github.com/hpollittsmith/core-v-mcu/blob/master/fpga/images/NexysA7.png "NexysA7-100T setup")

5. Start Xilinx Vivado
```
$ vivado  (note: if using Labtools Edition, use vivado_lab)
```
6. In the Vivado window, click `Open Hardware Manager >`

7. In the Hardware Manager window, click `Open Target` and select `Auto Connect`. If successful, you should see a xc7z100t_0 target in the Hardware pane. 

The connection to the target may fail with `ERROR: [Labtools 27-2269]`. If so, you should see two hardware targets in the Hardware pan in Hardware Manager--one marked `Open` and one marked `Closed`. Right-click on the Open target and select `Close Target`. Right-click on the second Closed target and select `Open Target`. Under the second target, you should now see the `xc7a100t_0` FPGA.

Once you have opened the xc7a100t_0 target. Click `Program device`. In the Program Device window, select the bitstream file you wish to use and click `Program`. When programmed, the DONE LED should be green. Exit Vivado. The FPGA is now programmed with the CV32E40P based Pulpissimo platform.


## Instructions to build and run an application

1. Download and extract the sort application [here](https://github.com/openhwgroup/core-v-mcu/blob/master/fpga/cv32e40p_modified_files/cv32e40p_sort.tar.gz)
```
tar xvfz cv32e40p_sort.tar.gz
```
2. Compile the application using PULP simple runtime. In a terminal window:
```
$ cd sort
$ make clean all
```
3. In the same terminal, start gdb
```
$ $PULP_RISCV_GCC_TOOLCHAIN/bin/riscv32-unknown-elf-gdb build/bubble/bubble
```
4. In another terminal window, start OpenOCD
```
$ cd $COREVMCU/fpga/pulpissimo-nexys
$ $OPENOCD/bin/openocd -f openocd-nexys-hs2.cfg
```
5. Connect to the serial/UART. In another terminal window:
```
$ sudo screen /dev/ttyUSB0 115200
```
(note, your USB port number may be different)

6. In your gdb session terminal, connect and load your program
```
(gdb) target remote localhost:3333
(gdb) load
```
7. Debug your program in gdb. For example:
```
(gdb) monitor reg		(list all registers)
(gdb) monitor reg mhartid	(print a specfic register's value)
(gdb) list			(list program code and line numbers)
(gdb) b 39			(set breakpoint at line #)
(gdb) b 42
(gdb) continue			(resume execution)
(gdb) disas			(disassemble current function)
(gdb) info locals		(print local variables)
(gdb) continue
```
You should see the unsorted and sorted lists printed in the serial terminal window.


## Instructions to simulate Pulpissimo with CV32E40P using Mentor Graphics Questasim/Modelsim
1. Install Questasim (current procedure has been tested with 10.7g) and Questasim license.

2. Replace the RI5CY simulation file with CV32E40P:
```
$ cp $COREVMCU/fpga/cv32e40p_modified_files/riscv.mk $COREVMCU/sim/vcompile/ips/.
```
3. Ensure you have TCL installed on your system:
```
$ sudo apt-get install -y tcl-dev
```
4. Build the simulation libaries:
```
$ cd $COREVMCU
$ source setup/vsim.sh
$ make build
```
5. Build an example application:
```
$ cd location_of_pulp-runtime
$ source configs/pulpissimo.sh
$ source configs/rtl.sh
$ cd location_of_pulp-runtime-examples/hello
$ make clean all run
```
Output will be in the terminal window. To launch the VSIM GUI to view signals, use:
```
$ make run gui=1
```

