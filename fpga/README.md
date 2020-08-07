Instructions to build the core-v-mcu platform:

1. Install PULPissimo platform as detailed [here](https://github.com/hpollittsmith/core-v-mcu); assume $PULPISSIMO is the top-level of the project
2. Download the cv32e40p project from [here](https://github.com/openhwgroup/cv32e40p) and copy to $PULPISSIMO/ips/
3. Replace the "riscv" directory with the "cv32e40p":
      cd $PULPISSIMO/ips
      rm -Rf riscv
      cp ~/Downloads/cv32e40p riscv
4. Modify the $PULPISSIMO/ips/riscv/rtl/cv32e40p_sleep_unit.sv source file, line 155 to replace the clock gate module. Change
      cv32e40p_clock_gate core_clock_gate_i
      
      to
      
      tc_clk_gating (core_clock_gate_i) //this module is found in $PULPISSIMO/ips/tech_cells_generic/src/fpga/tc_clk_xilinx.sv
            
5. Download the modified pulp_soc ip from [here](https://github.com/hpollittsmith/pulp_soc)
6. Replace the "pulp_soc" directory in $PULPISSIMO/ips/ with the modified version from step 4
7. Replace the tcl files in $PULPISSIMO/tcl with the files [here](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga/tcl_files)
8. Follow the regular PULPissimo instructions to build the FPGA platform

Pre-built FPGA bitstreams for the Genesys2 and NexsyA7-100T boards are [here](https://github.com/hpollittsmith/core-v-mcu/tree/master/fpga/bitstreams)
