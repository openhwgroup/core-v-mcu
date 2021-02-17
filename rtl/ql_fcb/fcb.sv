
//--------------------------------------------------------------------------------//
//--										--//
//-- QuickLogic confidential 2016     					--// 
//--										--//
//-- File name 		: fcb.sv					--//	
//-- Create time 	: Mon Sep 26 18:37:17 2016				--// 
//-- Owner		: jcheng 					--//
//-- 										--//
//-- Function Description :							--//
//--										--//
//--										--//
//-- Modification 	 							--//
//-- 1. 									--//
//-- Date 		:							--//
//-- Owner 		:							--//
//-- Change(s) 		:							--//
//--										--//
//--										--//
//--										--//
//--------------------------------------------------------------------------------//

module fcb 
#(
parameter        PAR_QLFCB_FB_TAMAR_CFG		= 8'b0 ,	// 
parameter        PAR_QLFCB_DEFAULT_ON		= 1'b1 ,	// 
parameter [ 7:0] PAR_QLFCB_DEVICE_ID		= 8'h21 ,	// 
parameter [10:0] PAR_QLFCB_11BIT_100NS          = 11'h00A ,     // 1: Default ON, 0: Default Off
parameter [10:0] PAR_QLFCB_11BIT_200NS          = 11'h014 ,    	// Default Assume 100MHz
parameter [10:0] PAR_QLFCB_11BIT_1US            = 11'h064 ,    	// Default Assume 100MHz
parameter [10:0] PAR_QLFCB_11BIT_10US           = 11'h3E8 ,    	// Default Assume 100MHz
parameter [ 5:0] PAR_QLFCB_6BIT_125NS           = 6'h0d ,    	// Default Assume 100MHz
parameter [ 5:0] PAR_QLFCB_6BIT_250NS           = 6'h19 ,      	// Default Assume 100MHz
parameter [15:0] PAR_RAMFIFO_CFG  		= 16'b0000_0000_0000_0000     //Define the RAMFIFO which Read back data
)
(
        //------------------------------------------------------------------------//
        //-- INPUT PORT                                                         --//
        //------------------------------------------------------------------------//
input logic                     fcb_sys_clk ,   	//Main Clock for FCB except SPI Slave Int
input logic                     fcb_sys_rst_n , 	//Main Reset for FCB except SPI Slave int
input logic                     fcb_spis_clk ,  	//Clock for SPIS Slave Interface
input logic                     fcb_spis_rst_n ,        //Reset for SPIS slave Interface, it is a
input logic                     fcb_sys_stm ,   	//1'b1 : Put the module into Test Mode
input logic                     fcb_spim_miso , 	//SPI Master MISO
input logic                     fcb_spim_ckout_in ,     //SPI Master Loop Back Clock
input logic                     fcb_spis_mosi , 	//SPI Slave MOSI
input logic                     fcb_spis_cs_n , 	//SPI Slave Chip Select
input logic                     fcb_pif_vldi ,  	//PIF Input Data Valid
input logic [3:0]               fcb_pif_di_l ,  	//PIF Input Data, Lower 4 Bits
input logic [3:0]               fcb_pif_di_h ,  	//PIF Input Data, Higher 4 Bits
//input logic [7:0]             fcb_device_id_bo ,      //Device ID for Register 0x3
//input logic                   fcb_vlp,      		//1'b1 Put the FB Macro into VLP Mode. 1'
input logic                     fcb_spi_mode_en_bo ,    //1'b1 : SPI Master/Slave is Enable. 1'b0
input logic                     fcb_pif_en ,    	//1'b1 : Enable the PIF mode. Note this b
input logic                     fcb_pif_8b_mode_bo ,    //1'b1 : PIF DI/DO are 8 bits and in Simp
input logic [19:0]              fcb_apbs_paddr , 	//APB Address in byte Resolution. Up to 1
input logic [2:0]               fcb_apbs_pprot , 	//ABP PPROT, If FCB_APB_PROT_EN is 1, the
input logic                     fcb_apbs_psel , 	//APB Slave select signal
input logic                     fcb_apbs_penable ,      //APB Enable signal for data transfer
input logic                     fcb_apbs_pwrite ,       //APB write Enable Signal
input logic [31:0]              fcb_apbs_pwdata ,       //APB Write Data
input logic [3:0]               fcb_apbs_pstrb ,        //APB Byte Enable.
input logic [31:0]              fcb_bl_dout ,   	//Fabric BL Read Data
input logic [17:0]              fcb_apbm_prdata_0 ,     //APB Read Data, the RAMFIFO will impleme
input logic [17:0]              fcb_apbm_prdata_1 ,     //APB Read Data, the RAMFIFO will impleme
input logic                     fcb_spi_master_en ,     //FCB Master Enable form Boot Strap Pin.
//input logic			fcb_fb_default_on_bo,	//eFPGA Macro Default Power State
//input logic			fcb_clp_mode_en_bo, 	//1'b1 : Chip Level, 1'b0 Quardant
        //------------------------------------------------------------------------//
        //-- OUTPUT PORT                                                        --//
        //------------------------------------------------------------------------//
output logic                    fcb_cfg_done ,  	//Cfg Done
output logic                    fcb_cfg_done_en ,       //Cfg Done Output Enable
//output logic [3:0]            fcb_io_sv_180 , 	//Select the IO Supply Voltage, 0x0 : 3.3
output logic                    fcb_spim_mosi , 	//SPI Master MOSI
output logic                    fcb_spim_mosi_en ,      //SPI Master MOSI output enable
output logic                    fcb_spim_cs_n , 	//SPI Master Chip Select
output logic                    fcb_spim_cs_n_en ,      //SPI Master Chip Select enable
output logic                    fcb_spim_ckout ,        //SPI Master Clock Output
output logic                    fcb_spim_ckout_en ,   	//SPI Master Clock Output Enable
output logic                    fcb_spis_miso , 	//SPI Slave MISO
output logic                    fcb_spis_miso_en ,      //SPI Slave MISO output enable
output logic                    fcb_pif_vldo ,  	//PIF Output Data Valid
output logic                    fcb_pif_vldo_en ,       //PIF Output Data Valid Output Enable
output logic [3:0]              fcb_pif_do_l ,  	//PIF Output Data, Lower 4 Bits
output logic                    fcb_pif_do_l_en ,       //PIF Output Data Output Enable for Lower
output logic [3:0]              fcb_pif_do_h ,  	//PIF Output Data, Higher 4 Bits
output logic                    fcb_pif_do_h_en ,       //PIF Output Data Output Enable for Highe
output logic                    fcb_apbs_pready ,       //APB Slave Ready Signal
output logic [31:0]             fcb_apbs_prdata ,       //APB READ Data
output logic                    fcb_apbs_pslverr ,      //ABP Error Response
output logic                    fcb_blclk ,     	//Fabric Bit Line Clock, Does not need to
output logic                    fcb_re ,        	//Fabric Read Enable
output logic                    fcb_we ,        	//Fabric Write Enable
output logic                    fcb_we_int ,    	//Fabric Write Enable Left/write Interfac
output logic                    fcb_pchg_b ,    	//Fabric Pre-Charge, Low active
output logic [31:0]             fcb_bl_din ,    	//Fabric BL Write Data
output logic                    fcb_cload_din_sel ,     //Fabric Column Load Data in Select
output logic                    fcb_din_slc_tb_int ,    //Fabric Bit Line Shift Register Data In	//JC
output logic                    fcb_din_int_l_only ,    //Fabric Bit line shift register Data in
output logic                    fcb_din_int_r_only ,    //Fabric Bit Line Shift Register Data in
output logic [15:0]             fcb_bl_pwrgate ,        //Fabric Bit Line Cfg Shift Register Powe
output logic                    fcb_wlclk ,     	//Fabric Word Line Clock, Does not need t
output logic                    fcb_wl_resetb , 	//Fabric Word Line Shift Register Bank Re
output logic                    fcb_wl_en ,     	//Fabric Word Line enable
output logic [15:0]             fcb_wl_sel ,    	//Fabric Word Line Select
output logic [2:0]              fcb_wl_cload_sel ,      //Fabric Word Line Column Load Select
output logic [7:0]              fcb_wl_pwrgate ,        //Fabric Word Line Power Gate Control. 1'
output logic [5:0]              fcb_wl_din ,    	//Fabric Word Line Shfit Register Data In
output logic                    fcb_wl_int_din_sel ,    //Fabric Word Line interface Data in Sele
output logic [15:0]             fcb_prog ,      	//Fabric Configuration Enable for Quads,
output logic                    fcb_prog_ifx ,  	//Fabric Configuration Enable for IFX, Hi
output logic                    fcb_wl_sel_tb_int ,     //Disable the TB Configuration during Qua
output logic [15:0]             fcb_iso_en ,    	//Fabric ISO Enable, 0x1->Isolation Enabl
output logic [15:0]             fcb_pi_pwr ,    	//Fabric Power Down Enable, 0x1->Power Do
output logic [15:0]             fcb_vlp_clkdis ,        //Fabric Clock Function Disable Signal fo
output logic                    fcb_vlp_clkdis_ifx ,    //Fabric Clock Function Disable signal fo
output logic [15:0]             fcb_vlp_srdis , 	//Fabric Set/Reset Function Disable Signa
output logic                    fcb_vlp_srdis_ifx ,     //Fabric Set/Reset Function Disable signa
output logic [15:0]             fcb_vlp_pwrdis ,        //Fabric VLP Power Down signals for Quads
output logic                    fcb_vlp_pwrdis_ifx ,    //Fabric VLP Power Down signals for Inter
output logic [11:0]             fcb_apbm_paddr ,        //APB Address in byte Resolution, Bit 11
output logic [7:0]              fcb_apbm_psel , 	//APB Slave Select Signals. Bit 0 is used
output logic                    fcb_apbm_penable ,      //APB Enable signal for data transfer
output logic                    fcb_apbm_pwrite ,       //APB write Enable Signal
output logic [17:0]             fcb_apbm_pwdata ,       //APB Write Data
output logic                    fcb_apbm_ramfifo_sel ,  //1'b1 : RAMFIFO APB Interface Enable.
output logic                    fcb_apbm_mclk ,  	//APB Master Clock
output logic			fcb_rst	,		// Now this is for Tamar Only
//output logic [15:0]           fcb_rst ,       	//Fabric Reset
//output logic                  fcb_tb_rst ,    	//TB Reset
//output logic                  fcb_lr_rst ,    	//LR Reset
//output logic                  fcb_iso_rst ,   	//Isolation Reset
output logic                    fcb_sysclk_en , 	//1'b1 : Turn on the RC/SYS clock. Note:
output logic                    fcb_fb_cfg_done, 	//Indicate the Fabric Configuration is do
//output logic                  fcb_clp_cfg_done ,	//New Added
output logic                    fcb_clp_cfg_done_n ,	//New Added
output logic                    fcb_clp_cfg_enb ,	//New Added
output logic                    fcb_clp_lth_enb ,	//New Added
output logic                    fcb_clp_pwr_gate ,	//New Added
output logic                    fcb_clp_vlp,  		//New Added
output logic                    fcb_fb_iso_enb,         //JC
output logic                    fcb_pwr_gate,           //JC            
output logic                    fcb_set_por ,           //JC this signal need to be handle outside by customer's logic
output logic			fcb_clp_set_por ,       //POR Signal JC
output logic                    fcb_spi_master_status  	//New Added
);

endmodule


