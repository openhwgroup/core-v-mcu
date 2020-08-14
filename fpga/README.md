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
6. Install Xilinx cable drivers (make sure any download cables are not connected when you do this):
``` 
$ sudo /opt/Xilinx/Vivado/2018.2/data/xicom/cable_drivers/lin64/install_script/install_drivers
```
7. Setup the Vivado environment:
```
$ source /opt/Xilinx/Vivado/2018.2/settings64.sh
```
8. Install the simple Pulp runtime:
```
$ cd pulp-runtime
$ source configs/pulpissimo.sh
$ source configs/fpgas/pulpissimo/nexysA7.sh
```
9. Download the pulp-runtime-examples:
```
$ git clone https://pulp-platform/pulp-runtime-examples.git
$ cd pulp-runtime-examples/hello
$ make clean all
```
## Instructions to download the pre-built bitstream
```

```

## Modifications to Pulpissimo to instantiate CV32E40P

The procedure above will install the Pulpissimo environment with the RI5CY core. To replace RI5CY with CV32E40P, the following modifications should be made (the $PULP variable refers to your location of the core-v-mcu source directory):

1. Download the cv32e40p source: project from [here](https://github.com/openhwgroup/cv32e40p) and copy to $PULPISSIMO/ips/
``` 
$ git clone https://github.com/openhwgroup/cv32e40p
```

2. Replace the RI5CY source directory:
```
$ cp -Rf cv32e40p $PULP/ips/.
$ cd $PULP/ips
$ rm -Rf riscv
$ mv cv32e40p riscv
```

3. Modify the $PULP/ips/riscv/rtl/cv32e40p_sleep_unit.sv source file, line 155 to replace the clock gate module. Replace the text:
```
cv32e40p_clock_gate core_clock_gate_i
```
with
```
tc_clk_gating (core_clock_gate_i) //this module is found in $PULPISSIMO/ips/tech_cells_generic/src/fpga/tc_clk_xilinx.sv
```            
4. Replace the pulp_soc module with a modified version that instantiates cv32e40p:
```
$ cd $PULP/ips
$ rm -Rf $PULP/ips/pulp_soc
$ git clone https://github.com/hpollittsmith/pulp_soc
```

5. Replace the tcl files in $PULP/tcl with modified files:
```
$ cp $PULP/fpga/tcl_files/*.tcl $PULP/tcl/.
```
7. Follow the regular PULPissimo instructions to build the FPGA platform, for example:
```
$ cd $PULP/fpga
$ make clean_genesys2
$ make genesys2
```
8. Download

Pre-built FPGA bitstreams for the Genesys2 and NexsyA7-100T boards are [here](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga/bitstreams)
