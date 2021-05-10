set ipName xilinx_private_ram

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -module_name $ipName

set_property -dict [eval list CONFIG.Use_Byte_Write_Enable {true} \
    CONFIG.Byte_Size {8} \
    CONFIG.Write_Width_A {32} \
    CONFIG.Write_Depth_A $::env(PRIVATE_BANK_SIZE) \
    CONFIG.Read_Width_A {32} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    ] [get_ips $ipName]

