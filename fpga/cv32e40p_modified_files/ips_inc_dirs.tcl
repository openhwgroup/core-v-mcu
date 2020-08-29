if ![info exists INCLUDE_DIRS] {
	set INCLUDE_DIRS ""
}

if ![info exists PULP_FPGA_SIM] {
    set RTL $::env(COREVMCU)/rtl
    set IPS $::env(COREVMCU)/ips
    set FPGA_IPS ../ips
    set FPGA_RTL ../rtl
}

eval "set INCLUDE_DIRS {
    $RTL/includes \
    $IPS/adv_dbg_if/rtl \
    $IPS/apb/apb_adv_timer/./rtl \
    $IPS/axi/axi_node/./src/ \
    $IPS/timer_unit/rtl \
    $IPS/fpnew/../common_cells/include \
    $IPS/jtag_pulp/../../rtl/includes \
    $IPS/riscv/./rtl/include \
    $IPS/riscv/../../rtl/includes \
    $IPS/riscv/./rtl/include \
    $IPS/ibex/rtl \
    $IPS/udma/udma_core/./rtl \
    $IPS/udma/udma_qspi/rtl \
    $IPS/hwpe-ctrl/rtl \
    $IPS/hwpe-stream/rtl \
    $IPS/hwpe-mac-engine/rtl \
    $IPS/pulp_soc/../../rtl/includes \
    $IPS/pulp_soc/../../rtl/includes \
    $IPS/pulp_soc/. \
    $IPS/pulp_soc/../../rtl/includes \
    $IPS/pulp_soc/. \
    $IPS/pulp_soc/../../rtl/includes \
        ${INCLUDE_DIRS} \
}"

