Instructions to build the core-v-mcu platform:

1. Install PULPissimo platform as detailed [here](https://github.com/hpollittsmith/core-v-mcu); assume $PULPISSIMO is the top-level of the project
2. Download the cv32e40p project from [here](https://github.com/openhwgroup/cv32e40p) and copy to $PULPISSIMO/ips/
3. Replace the "riscv" directory with the "cv32e40p":
      cd $PULPISSIMO/ips
      rm -Rf riscv
      cp ~/Downloads/cv32e40p riscv
4. Modify the cv32e40p_sleep_unit.sv source file
4. Download the modified pulp_soc ip from [here](https://github.com/hpollittsmith/pulp_soc)
5. Replace the "pulp_soc" directory in $PULPISSIMO/ips/ with the modified version from step 4
6. Replace the tcl files in $PULPISSIMO/tcl with the files [here](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga/tcl_files)
7. Follow the regular PULPissimo instructions to build the FPGA platform

Pre-built FPGA bitstreams for the Genesys2 and NexsyA7-100T boards are [here](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga/bitstreams)
