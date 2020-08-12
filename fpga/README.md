##Instructions to build the core-v-mcu platform:

The following instructions start from a clean Ubuntu 18.04 installation.


- Download and install the [Embecosm toolchain](https://buildbot.embecosm.com/job/corev-gcc-ubuntu1804/2/artifact/corev-openhw-gcc-ubuntu1804-20200705.tar.gz)
            - cp corev-openhw-gcc-ubuntu1804-20200705.tar.gz /opt/.
            - tar xvfz corev-openhw-gcc-ubuntu1804-20200705.tar.gz
            - export PULP_RISCV_GCC_TOOLCHAIN=/opt/corev-openhw-gcc-ubuntu1804-20200705
            - export PATH=$PULP_RISCV_GCC_TOOLCHAIN/bin:$PATH
- Install the PULP SDK as detailed [here](https://github.com/pulp-platform/pulp-sdk)
            - Install the dependencies for Ubuntu 16.04
            - git clone https://github.com/pulp-platform/pulp-sdk
            - cd pulp-sdk
            - source configs/pulpissimo.sh
            - source configs/platform_fpga.sh
            - make all
            - source sourceme.sh
- Install patched version of OpenOCD:
            - source sourceme.sh && ./pulp-tools/bin/plpbuild checkout build -—p openocd -—stdout
- Go to: [https://github.com/openhwgroup/core-v-mcu](https://github.com/openhwgroup/core-v-mcu)
            - sudo apt install curl
            - git config --global user.email “your email address”
            - git config --global user.name “your name”
            - git clone https://github.com/openhwgroup/core-v-mcu.git
            - cd core-v-mcu
            - ./update-ips
- Install Xilinx Vivado 2018.2 (note for NexysA7 board, the free Xilinx WebPack is sufficient; for Genesys2, a full version is required; if you are only using Xilinx to download pre-generated bitstreams, you only need to install Vivado Lab Edition, which does not include the design tools)
- Install Xilinx cable drivers: 
            - sudo /opt/Xilinx/Vivado/2018.2/data/xicom/cable_drivers/lin64/install_script/install_drivers


Once you have the default Pulpissimo environment (which instantiates the RI5CY core), you will need to make the following modifications to instantiate CV32E40P:

1. Download the cv32e40p project from [here](https://github.com/openhwgroup/cv32e40p) and copy to $PULPISSIMO/ips/
2. Replace the "riscv" directory with the "cv32e40p" directory:
            
            cd $PULPISSIMO/ips
            rm -Rf riscv
            cp ~/Downloads/cv32e40p riscv
3. Modify the $PULPISSIMO/ips/riscv/rtl/cv32e40p_sleep_unit.sv source file, line 155 to replace the clock gate module. Change

            cv32e40p_clock_gate core_clock_gate_i
      
            to
      
            tc_clk_gating (core_clock_gate_i) //this module is found in $PULPISSIMO/ips/tech_cells_generic/src/fpga/tc_clk_xilinx.sv
            
4. Download the modified pulp_soc ip from [here](https://github.com/hpollittsmith/pulp_soc)
5. Replace the "pulp_soc" directory in $PULPISSIMO/ips/ with the modified version from step 4
6. Replace the tcl files in $PULPISSIMO/tcl with the files [here](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga/tcl_files)
7. Follow the regular PULPissimo instructions to build the FPGA platform

Pre-built FPGA bitstreams for the Genesys2 and NexsyA7-100T boards are [here](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga/bitstreams)
