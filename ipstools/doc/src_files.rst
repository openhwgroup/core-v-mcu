.. ipstools documentation for src_files.yml files

IP Source file descriptor (`src_files.yml`)
===========================================

A simple IP Source file descriptor should be included within all IPs managed with the `ipstools`.
The descriptor is a simple human-readable file called `src_files.yml` located in the root of the IP repository.
It uses the Yaml syntax to describe:

1. the HDL source files composing the IP (in Verilog, SystemVerilog or VHDL)
2. include files (for Verilog/SystemVerilog)
3. technology targets
4. other auxiliary information for the generation of simulation and synthesis scripts

The IP can be divided in several "IP blocks" of files sharing options and targets::

    block0:
      files: [
        rtl/file0.sv,
        rtl/file1.vhd
      ]
      targets: [
        'gf22'
      ]

    block1:
      files: [
        rtl/file2.sv
      ]
      targets: [
        'umc65'
      ]

At least a single IP block must be present in each `src_files.yml` file.
Each block is organized as a dictionary supporting a fixed set of keys.
A list of values is assigned to every key.

The following is the list of allowed keys:

- `files`: this is the only mandatory list in any IP block. It contains the list of all HDL sources that share the properties defined within the block.
- `incdirs`: the directories where Verilog or SystemVerilog include files  are located.
- `targets`: the list of allowed technology targets. Currently the following targets are supported:
    * `all`       : all targets.
    * `verilator` : Verilator HDL compiler/simulator.
    * `xilinx`    : Xilinx Series 7 FPGAs.
    * `st28fdsoi` : STMicroelectronics 28nm FD-SOI
    * `umc65`     : UMC 65nm
    * `tsmc55`    : TSMC 55nm
    * `tsmc40`    : TSMC 40nm
    * `gf28`      : GlobalFoundries 28nm
    * `gf22`      : GlobalFoundries 22nm
    * `smic130`   : SMIC 130nm

- `flags`: a list of auxiliary flags to direct script generation; currently sthe following flags are supported:
    * `skip_simulation` : generate only synthesis scripts, but no simulation ones.
    * `skip_synthesis`  : generate only simulation scripts, but no synthesis ones.
    * `skip_tcsh`       : skip the generation of TCSH scripts (for legacy IPs).
    * `only_local`      : use these files only if the simulation is tagged as "local" (e.g. an IP-specific testbench).

- `defines`: a list of defines to be used to direct simulation / synthesis (in the `DEFINE_NAME` or `DEFINE_NAME=DEFINE_VALUE` format).
- `vlog_opts` and `vcom_opts` : list of ModelSim/QuestaSim specific flags.

