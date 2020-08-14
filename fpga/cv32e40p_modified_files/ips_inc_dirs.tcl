if ![info exists INCLUDE_DIRS] {
	set INCLUDE_DIRS ""
}

eval "set INCLUDE_DIRS {
    /home/vhugh/mydata/PULP/core-v-mcu/rtl/includes \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/adv_dbg_if/rtl \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/apb/apb_adv_timer/./rtl \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/axi/axi_node/./src/ \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/timer_unit/rtl \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/fpnew/../common_cells/include \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/jtag_pulp/../../rtl/includes \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/riscv/./rtl/include \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/riscv/../../rtl/includes \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/riscv/./rtl/include \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/ibex/rtl \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/udma/udma_core/./rtl \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/udma/udma_qspi/rtl \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/hwpe-ctrl/rtl \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/hwpe-stream/rtl \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/hwpe-mac-engine/rtl \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/pulp_soc/../../rtl/includes \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/pulp_soc/../../rtl/includes \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/pulp_soc/. \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/pulp_soc/../../rtl/includes \
    /home/vhugh/mydata/PULP/core-v-mcu/ips/pulp_soc/. \
    /home/vhugh/mydata/PULP/core-v-mcu/mydata/pulpissimo/ips/pulp_soc/../../rtl/includes \
	${INCLUDE_DIRS} \
}"
