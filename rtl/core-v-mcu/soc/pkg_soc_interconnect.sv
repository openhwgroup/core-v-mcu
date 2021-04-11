package pkg_soc_interconnect;

  typedef struct packed {
    logic [31:0] idx;
    logic [31:0] start_addr;
    logic [31:0] end_addr;
  } addr_map_rule_t;

  //Warning, if you change the NR_SOC_TCDM_MASTER_PORTS parameter you must also change the identically named preprocessor
  //macro in soc_interconnect_wrap.sv. The macro is a workaround for a synopsys bug that prevent the usage of parameters
  //in index expression on the left-hand side of an assignment.
  localparam int unsigned NR_SOC_TCDM_MASTER_PORTS = 9; // FC instructions, FC data, uDMA RX, uDMA TX, debug access, 4xEFPGA
  localparam int unsigned NR_CLUSTER_2_SOC_TCDM_MASTER_PORTS = 4;  //  4 ports for 64-bit axi plug
  localparam int unsigned NR_TCDM_MASTER_PORTS = NR_SOC_TCDM_MASTER_PORTS + NR_CLUSTER_2_SOC_TCDM_MASTER_PORTS;
  localparam int unsigned AXI_ID_OUT_WIDTH = 1 + $clog2(NR_TCDM_MASTER_PORTS);

endpackage : pkg_soc_interconnect
