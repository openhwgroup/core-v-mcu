#
# Copyright (C) 2016 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=riscv
IP_PATH=$(IPS_PATH)/riscv
LIB_NAME=$(IP)_lib

include vcompile/build.mk

.PHONY: vcompile-$(IP) vcompile-subip-riscv_regfile_rtl vcompile-subip-riscv vcompile-subip-riscv_vip_rtl vcompile-subip-tb_riscv 

vcompile-$(IP): $(LIB_PATH)/_vmake

$(LIB_PATH)/_vmake : $(LIB_PATH)/riscv_regfile_rtl.vmake $(LIB_PATH)/riscv.vmake 
	@touch $(LIB_PATH)/_vmake


# riscv_regfile_rtl component
INCDIR_RISCV_REGFILE_RTL=+incdir+$(IP_PATH)/./rtl/include
SRC_SVLOG_RISCV_REGFILE_RTL=\
	$(IP_PATH)/./rtl/cv32e40p_register_file_test_wrap.sv\
	$(IP_PATH)/./rtl/cv32e40p_register_file_ff.sv
SRC_VHDL_RISCV_REGFILE_RTL=

vcompile-subip-riscv_regfile_rtl: $(LIB_PATH)/riscv_regfile_rtl.vmake

$(LIB_PATH)/riscv_regfile_rtl.vmake: $(SRC_SVLOG_RISCV_REGFILE_RTL) $(SRC_VHDL_RISCV_REGFILE_RTL)
	$(call subip_echo,riscv_regfile_rtl)
	$(SVLOG_CC) -work $(LIB_PATH)   -suppress 2583 -suppress 13314 $(INCDIR_RISCV_REGFILE_RTL) $(SRC_SVLOG_RISCV_REGFILE_RTL)

	@touch $(LIB_PATH)/riscv_regfile_rtl.vmake

# riscv component
INCDIR_RISCV=+incdir+$(IP_PATH)/./rtl/include+$(IP_PATH)/../../rtl/includes
SRC_SVLOG_RISCV=\
	$(IP_PATH)/./rtl/include/cv32e40p_apu_core_pkg.sv\
	$(IP_PATH)/./rtl/include/cv32e40p_pkg.sv\
	$(IP_PATH)/./rtl/cv32e40p_alu.sv\
	$(IP_PATH)/./rtl/cv32e40p_alu_div.sv\
	$(IP_PATH)/./rtl/cv32e40p_compressed_decoder.sv\
	$(IP_PATH)/./rtl/cv32e40p_controller.sv\
	$(IP_PATH)/./rtl/cv32e40p_cs_registers.sv\
	$(IP_PATH)/./rtl/cv32e40p_decoder.sv\
	$(IP_PATH)/./rtl/cv32e40p_int_controller.sv\
	$(IP_PATH)/./rtl/cv32e40p_ex_stage.sv\
	$(IP_PATH)/./rtl/cv32e40p_hwloop_controller.sv\
	$(IP_PATH)/./rtl/cv32e40p_hwloop_regs.sv\
	$(IP_PATH)/./rtl/cv32e40p_id_stage.sv\
	$(IP_PATH)/./rtl/cv32e40p_if_stage.sv\
	$(IP_PATH)/./rtl/cv32e40p_load_store_unit.sv\
	$(IP_PATH)/./rtl/cv32e40p_mult.sv\
	$(IP_PATH)/./rtl/cv32e40p_prefetch_buffer.sv\
	$(IP_PATH)/./rtl/cv32e40p_prefetch_controller.sv\
	$(IP_PATH)/./rtl/cv32e40p_core.sv\
	$(IP_PATH)/./rtl/cv32e40p_apu_disp.sv\
	$(IP_PATH)/./rtl/cv32e40p_ff_one.sv\
	$(IP_PATH)/./rtl/cv32e40p_fetch_fifo.sv\
	$(IP_PATH)/./rtl/cv32e40p_pmp.sv\
	$(IP_PATH)/./rtl/cv32e40p_popcnt.sv\
	$(IP_PATH)/./rtl/cv32e40p_obi_interface.sv\
    	$(IP_PATH)/./rtl/cv32e40p_sleep_unit.sv
SRC_VHDL_RISCV=

vcompile-subip-riscv: $(LIB_PATH)/riscv.vmake

$(LIB_PATH)/riscv.vmake: $(SRC_SVLOG_RISCV) $(SRC_VHDL_RISCV)
	$(call subip_echo,riscv)
	$(SVLOG_CC) -work $(LIB_PATH)  -L fpnew_lib -suppress 2583 -suppress 13314 $(INCDIR_RISCV) $(SRC_SVLOG_RISCV)

	@touch $(LIB_PATH)/riscv.vmake

# riscv_vip_rtl component
#INCDIR_RISCV_VIP_RTL=+incdir+$(IP_PATH)/./rtl/include
#SRC_SVLOG_RISCV_VIP_RTL=\
#	$(IP_PATH)/./bhv/cv32e40p_tracer.sv
#SRC_VHDL_RISCV_VIP_RTL=

#vcompile-subip-riscv_vip_rtl: $(LIB_PATH)/riscv_vip_rtl.vmake

#$(LIB_PATH)/riscv_vip_rtl.vmake: $(SRC_SVLOG_RISCV_VIP_RTL) $(SRC_VHDL_RISCV_VIP_RTL)
#	$(call subip_echo,riscv_vip_rtl)
#	$(SVLOG_CC) -work $(LIB_PATH)   -suppress 2583 -suppress 13314 $(INCDIR_RISCV_VIP_RTL)$(SRC_SVLOG_RISCV_VIP_RTL)

#	@touch $(LIB_PATH)/riscv_vip_rtl.vmake



# tb_riscv component
#INCDIR_TB_RISCV=+incdir+$(IP_PATH)/tb/tb_riscv/include+$(IP_PATH)/rtl/include
#SRC_SVLOG_TB_RISCV=\
#	$(IP_PATH_OLD)/tb/tb_riscv/include/perturbation_defines.sv\
#	$(IP_PATH_OLD)/tb/tb_riscv/riscv_simchecker.sv\
#	$(IP_PATH_OLD)/tb/tb_riscv/tb_riscv_core.sv\
#	$(IP_PATH_OLD)/tb/tb_riscv/riscv_perturbation.sv\
#	$(IP_PATH_OLD)/tb/tb_riscv/riscv_random_interrupt_generator.sv\
#	$(IP_PATH_OLD)/tb/tb_riscv/riscv_random_stall.sv
#SRC_VHDL_TB_RISCV=

#vcompile-subip-tb_riscv: $(LIB_PATH)/tb_riscv.vmake

#$(LIB_PATH)/tb_riscv.vmake: $(SRC_SVLOG_TB_RISCV) $(SRC_VHDL_TB_RISCV)
#	$(call subip_echo,tb_riscv)
#	$(SVLOG_CC) -work $(LIB_PATH)   -suppress 2583 -suppress 13314 $(INCDIR_TB_RISCV) $(SRC_SVLOG_TB_RISCV)

#	@touch $(LIB_PATH)/tb_riscv.vmake

