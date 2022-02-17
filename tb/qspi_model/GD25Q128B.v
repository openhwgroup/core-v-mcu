//////////////////////////////////////////////////////////////////////////////
//  File name : GD25Q128B.v
//////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------
// GD25Q128B Verilog model
//
// These Verilog HDL models are provided "as is" without warranty
// of any kind, included but not limited to, implied warranty
// of merchantability and fitness for a particular purpose.
//
// Copyright (C) GigaDevice Semiconductor Inc. http://www.gigadevice.com
//-----------------------------------------------------------------------------
//  MODIFICATION HISTORY:
//
//  version: |    author:      |  mod date: | changes made:
//  V0.1          Ziheng Xue      11 Aug 08   Preliminary version
//  V1.0          Tao Sun         11 Aug 30   LB fixed:custom can set LB=1,but can't clear LB now.
//                                            WRSR 8bit:clear high SR 8 bit(except LB) when WRSR 8 bit
//                                            Read manufacture_ID(94h) fixed for different send mode:
//                                              94h+addr+ax; 94h+addr+!(ax); con_read+addr+ax; con_read+addr+!(ax)
//                                            Release deep power down(abh) fixed so that read and release are ok
//                                            Sus signature fixed so that custom can read it whichever kind suspend.
//                                            Suspend and resume fixed.so that.     
//                                            Only read data(03h) instruction works with 80MHz,others with 120MHz.
//  V1.1          Tao Sun         11 Nov 14   modify "90h+addr+7bit" can read ID. 
//                                            modify pgm/ers cycle time will not be effected by suspend
//  V1.2          Tao Sun         12 Aug 23   Modify to initialize the memory content with external file
//
//////////////////////////////////////////////////////////////////////////////
//  PART DESCRIPTION:
//
//  Library:     FLASH
//  Technology:  FLASH MEMORY
//  Part:        GD25Q128B 
//
//  Description: 128 Mbit 3.3V Uniform Sector Dual and Quad SPI Flash
//
//////////////////////////////////////////////////////////////////////////////
//  Comments :
//
//
//////////////////////////////////////////////////////////////////////////////
//  Known Bugs:
//
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// PARAMETER DECLARATION                                                    //
//////////////////////////////////////////////////////////////////////////////



`timescale 1ns/10ps

`define INITIAL_DATA	   //if define INITIAL_DATA,load memory content with external file; else initial memory all '1'

`define SIZE               134217728      // 128Mbit 1048576*128
`define PLENGTH            256           // page length 256 bytes
`define OTP_SIZE           1024         // otp array size 1024 bytes,4 pages
`define BSIZE_64           524288      // Block size 512 kbits(64k size blk)
`define BSIZE_32           262144     // Block size 256 kbits(32k size blk)

`define SSIZE              32768           // Sector size 32 kbits
`define SIGNATURE          8'h17          // electronic signature 17h   CMD=AB ID7-ID0
`define manufacturerID     8'hc8         // Manufacturer ID
`define memtype            8'h40        // memorytype   ID15-ID8
`define density            8'h18       // memory density 128Mbits  ID7-ID0
`define custid             16'hc800   // custom ID 8Mbits ID15-ID0
`define BIT_TO_CODE_MEM    24         // number of bit to code a 128Mbits memory
`define LSB_TO_CODE_PAGE   8         // number of bit to code a PLENGTH page

`define NB_BIT_ADD_MEM              24
`define NB_BIT_ADD                  8
`define NB_BIT_DATA                 8
`define TOP_MEM                     (`SIZE/`NB_BIT_DATA)-1

`define MASK_BLK64          24'hFF0000     // anded with address to find first block adress to erase
`define MASK_BLK32          24'hFF8000    // anded with address to find first 32 block adress to erase
`define MASK_SECTOR         24'hFFF000   // anded with address to find first sector adress to erase

`define   TRUE    1'b1
`define   FALSE   1'b0


`define TC     9.6             // Minimum Clock period
`define TR     12.5           // Minimum Clock period for read instruction
`define TSLCH  5             // notS active setup time (relative to C)
`define TCHSL  5            // notS not active hold time
`define TCH    4.5         // Clock high time
`define TCL    4.5        // Clock low time
`define TDVCH  2          // Data in Setup Time
`define TCHDX  2          // Data in Hold Time
`define TCHSH  5          // notS active hold time (relative to C)
`define TSHCH  5          // notS not active setup  time (relative to C)
`define TSHSL  20         // S deselect time
`define TSHQZ  6          // Output disable Time			
`define TCLQV  7          // clock low to output valid
`define THLCH  5          // NotHold active setup time
`define TCHHH  5          // NotHold not active hold time
`define THHCH  5          // NotHold not active setup time
`define TCHHL  5          // NotHold active hold time
`define THHQX  6          // NotHold high to Output Low-Z
`define THLQZ  6          // NotHold low to Output High-Z
`define TWHSL  20         // Write protect setup time (SRWD=1)
`define TSHWL  100        // Write protect hold time (SRWD=1)
`define TSUS   2000       // notS high to next instruction after suspend (2us)
`define TDP    100        // notS high to deep power down mode(0.1us)
`define TRES1  5000       // notS high to Stand-By power mode w-o ID Read(0.1us)
`define TRES2  5000       // notS high to Stand-By power mode with ID Read(0.1us)

`define TW     2000000    // write status register cycle time (2ms)
`define TPP    700000     // page program cycle time (0.7ms)
`define TSE    100        // sector erase cycle time (100ms)
`define TBE1   200        // 32k block erase cycle time (0.2s)
`define TBE2   400        // 64k block erase cycle time (0.4s)
`define TCE    60000      // chip erase cycle time (60s)


`define Tbase  1000000    // time base for chip and Block Sector ERASE, delay function limited to signed 32bits values (1ms)

module GD25Q128B(sclk,si,cs,wp,hold,so);
   input sclk;
   inout si;  
   input cs;
   inout wp;       
   inout hold;    
   
   inout so;   

   wire [(`NB_BIT_ADD_MEM-1):0] address; 
   wire [(`BIT_TO_CODE_MEM-1):0] suspend_add; 
   wire [(`NB_BIT_DATA-1):0] data_to_read; 
   wire [(`NB_BIT_DATA-1):0] data_to_write; 
   wire [(`LSB_TO_CODE_PAGE-1):0] page_index;
   
   wire wr_op; 
   wire rd_op; 
   wire c_en;
   wire ser_enable; 
   wire ber32_enable; 
   wire ber64_enable; 

   wire add_pp_en; 
   wire pp_en; 
   wire read_enable; 
   wire read_enable_2; 
   wire read_enable_4; 
   wire rd_req;
   wire wd_req; 
   wire clck;
   wire suspend_en;
   wire resume_en;
   wire suspend_pp;
   wire suspend_ber32;
   wire suspend_ber64;

   wire suspend_ser;
  
   wire quadpgm_enable;  
   wire otpers_enable;
   wire otppgm_enable;
   wire otppgm;
   wire otpers;
   wire suspend_quadpgm;
   wire suspend_otppgm;
   wire suspend_otpers;
   
 assign clck = sclk ; 

   	parameter initfile = "initGD25Q128B.txt"; 

memory_access  #(.initfile(initfile) ) mem_access(address, suspend_add, suspend_en,     suspend_pp, suspend_ber32, suspend_ber64, suspend_ser, resume_en,     c_en,       ber32_enable, ber64_enable, ser_enable, add_pp_en,     pp_en,    wd_req,             read_enable,read_enable_2,read_enable_4, rd_req,            data_to_write, page_index,     data_to_read, 
                               quadpgm_enable,otppgm_enable, otpers_enable, suspend_quadpgm, suspend_otppgm, suspend_otpers, otppgm, otprd, otpers); 


`ifdef SPEEDSIM

task InitMemory_fom_file;
    begin 
      	    $readmemh(initfile, mem_access.content); 
      	    $display("%t : NOTE : InitMemory_fom_file Load End",$realtime); 
    end
endtask 
`endif
 
acdc_check  acdc_watch(sclk, si, cs, hold, wr_op, rd_op,rd_op_80,oen, thold_readquad,QE,flag_80M,flag_120M);

internal_logic  spi_decoder(sclk, si, wp, cs, hold, data_to_read, so, data_to_write, page_index,     address, suspend_add, suspend_en,     suspend_pp, suspend_ber32,  suspend_ber64,  suspend_ser, resume_en,     wr_op,    rd_op,  rd_op_80, c_en,       ber32_enable, ber64_enable, ser_enable, add_pp_en,     pp_en,    wd_req,             read_enable,read_enable_2,read_enable_4, rd_req ,           oen, thold_readquad,  
                                 quadpgm_enable,   otpers_enable, otppgm_enable,   suspend_quadpgm,   suspend_otppgm,  suspend_otpers, otppgm, otprd, otpers,QE,flag_80M,flag_120M);		
 
   
endmodule
module memory_access (    add_mem, suspend_add, suspend_enable, suspend_pp, suspend_ber32, suspend_ber64, suspend_ser, resume_enable, cer_enable, ber32_enable, ber64_enable, ser_enable, add_pp_enable, pp_enable,write_data_request, read_enable,read_enable_2,read_enable_4, read_data_request, data_to_write, page_add_index, data_to_read,
                          quadpgm_enable, otppgm_enable, otpers_enable, suspend_quadpgm, suspend_otppgm, suspend_otpers, otppgm, otprd,otpers);

   input[(`NB_BIT_ADD_MEM - 1):0] add_mem; 
   input[(`BIT_TO_CODE_MEM-1):0] suspend_add; 
   input cer_enable; 
   input ber32_enable;
   input ber64_enable;
   input ser_enable; 
   input add_pp_enable; 
   input pp_enable; 
   input quadpgm_enable;   
   input otppgm_enable; 
   input otpers_enable; 
   input otppgm;    
   input otprd; 
   input otpers;   
   input read_enable; 
   input read_enable_2; 
   input read_enable_4; 
   input read_data_request; 
   input write_data_request; 
   input suspend_enable;
   input resume_enable;
   input suspend_pp;
   input suspend_quadpgm;  
   input suspend_otppgm;
   input suspend_otpers;
   input suspend_ber32;
   input suspend_ber64;
   input suspend_ser;
   input[(`NB_BIT_DATA - 1):0] data_to_write; 
   input[(`LSB_TO_CODE_PAGE-1):0] page_add_index;

   output[(`NB_BIT_DATA - 1):0] data_to_read; 
   reg[(`NB_BIT_DATA - 1):0] data_to_read;

   reg[(`NB_BIT_DATA - 1):0] p_prog[0:(`PLENGTH-1)];
   reg[(`NB_BIT_DATA - 1):0] content[0:`TOP_MEM];
   reg[(`NB_BIT_DATA - 1):0] otp_content[0:`OTP_SIZE-1];
   reg[`BIT_TO_CODE_MEM - 1:0] cut_add; 

   integer i; 
   integer deb_zone; 
   integer int_add; 
   integer int_add_mem;

   `ifdef INITIAL_DATA
   	parameter initfile = "initGD25Q128B.txt"; 
   `endif

   initial
   begin
      cut_add = 0;
      deb_zone = 0;
      int_add = 0;
      int_add_mem = `BIT_TO_CODE_MEM ;
      
      
      //-------------------------------
      // initialisation of memory array
      //-------------------------------
      
      for(i = 0; i <= (`PLENGTH-1); i = i + 1) 
      begin
         p_prog[i] = 8'b11111111 ; 
      end
      
      for(i = 0; i <= (`TOP_MEM); i = i + 1)  
      begin
         content[i] = 8'b11111111 ; 
      end

      `ifdef INITIAL_DATA
      	    $display("%t : NOTE : Load memory with Initial content",$realtime); 
      	    $readmemh(initfile, content); 
      	    $display("%t : NOTE : Initial Load End",$realtime); 
      `endif
        
      for(i = 0; i <= (`OTP_SIZE-1); i = i + 1)  
      begin
         otp_content[i] = 8'b11111111 ; 
      end
  end 

   //--------------------------------------------------
   //                PROCESS MEMORY
   //--------------------------------------------------

   always @(negedge pp_enable or negedge quadpgm_enable or negedge otppgm_enable)
    begin
      if (!suspend_enable)
      begin
         for(i = 0; i <= (`PLENGTH-1); i = i + 1)
         begin
            p_prog[i] = 8'b11111111 ; 
         end
      end
   end
   
wire #1 delayed_write_data_request = write_data_request;

   always
   begin
      @(posedge delayed_write_data_request)
      if ($time != 0)
      begin
         if (page_add_index !== 8'bxxxxxxxx)
         begin
          if (add_pp_enable == 1'b1 && (pp_enable == 1'b0 || quadpgm_enable || otppgm_enable)  )
            begin
            	p_prog[page_add_index] <= data_to_write ;
            end
         end
      end
   end
   
 
wire otpcmd = otpers | otppgm | otprd;  
   always 
      @(posedge ser_enable  or posedge otpers_enable or posedge read_enable or add_pp_enable or posedge ber32_enable or posedge ber64_enable)  
      if ($time != 0)
      begin
        if(!otpcmd) 
         begin
         for(i = 0; i <= `BIT_TO_CODE_MEM - 1; i = i + 1)
           begin
            cut_add[i] = add_mem[i]; 
           end
         end 
         
       else if(otpcmd) 
         begin
         for(i = 0; i <=9; i = i + 1)  
               begin                   
                  cut_add[i] = add_mem[i]; 
               end
               cut_add[`BIT_TO_CODE_MEM -1:10] = 12'h000;                      
         end  
         
      end
      
   wire #1 delayed_read_data_request = read_data_request;
   always 
      @(posedge delayed_read_data_request)
      if ($time != 0)
      begin
         if (read_enable)
         begin
            int_add = cut_add; 
            //---------------------------------------------------------
            // Read instruction
            //---------------------------------------------------------
            if(!otprd)
              begin 
              if (int_add > `TOP_MEM)
              begin
                 for(i = 0; i <= `BIT_TO_CODE_MEM - 1; i = i + 1)
                 begin
                    cut_add[i] = 1'b0; 
                 end
                 int_add = 0;
              end 
              data_to_read <= content[int_add] ; 
              end 
             
             else if(otprd)
              begin 
              if (int_add > `OTP_SIZE-1)
              begin
                 for(i = 0; i <= `BIT_TO_CODE_MEM - 1; i = i + 1) 
                 begin
                    cut_add[i] = 1'b0; 
                 end
                 int_add = 0; 
              end 
              data_to_read <= otp_content[int_add] ; 
              end  
              
         end
      end   
            
  always    
      @(negedge read_data_request)
       if ($time != 0)
           begin
           cut_add <= cut_add+1;
           end
            
            
   always 
      @(negedge read_enable)
      if ($time != 0)
      begin
         for(i = 0; i <= `NB_BIT_DATA - 1; i = i + 1)
         begin
            data_to_read[i] <= 1'b0 ; 
         end
      end

   //--------------------------------------------------------
   // Page program instruction
   // To find the first adress of the memory to be programmed
   //--------------------------------------------------------
wire #1 delayed_add_pp_enable = add_pp_enable;  
   always 
      @(delayed_add_pp_enable)
       begin
         if (delayed_add_pp_enable == 1'b1)
           if(!otppgm)
             begin
                int_add_mem = cut_add; 
                int_add = `TOP_MEM + 1; 
                while (int_add > int_add_mem)
                begin
                   int_add = int_add - `PLENGTH ; 
                end
             end
           else if(otppgm)
             begin
                int_add_mem = {12'h 000, cut_add[9:0]}; 
                int_add = `OTP_SIZE; 
                while (int_add > int_add_mem)
                begin
                   int_add = int_add - `PLENGTH ;   
                end
             end 
       end      
             
             

 always                             
      @(posedge resume_enable)
      if ($time != 0)
      begin
      	if (suspend_pp || suspend_quadpgm)
      		int_add = {suspend_add[`BIT_TO_CODE_MEM -1 : 8],8'h00}; 
      	if (suspend_otppgm)
      		int_add = {12'h000,suspend_add[9:8],8'h00}; 	
      	if (suspend_otpers)
      		int_add = 22'h000000; 		
      	if (suspend_ber32)
      		int_add = suspend_add & `MASK_BLK32 ;
      	if (suspend_ber64)
      		int_add = suspend_add & `MASK_BLK64 ;
      	if (suspend_ser)
      		int_add = suspend_add & `MASK_SECTOR ;
      end

      //----------------------------------------------------
      // Sector erase instruction
      // To find the first adress of the sector to be erased
      //----------------------------------------------------
wire #1 delayed_ser_enable = ser_enable;
   always 
      @(posedge delayed_ser_enable)
      
         begin
            int_add = cut_add & `MASK_SECTOR ;
         end
         
         
wire #1 delayed_otpers_enable = otpers_enable;  
   always 
      @(posedge delayed_otpers_enable)
      
         begin
            int_add = 22'h000000 ;
         end         
         
         
      //----------------------------------------------------
      // Block erase instruction
      // To find the first adress of the block to be erased
      //----------------------------------------------------
wire #1 delayed_ber32_enable = ber32_enable;

 always 
      @(posedge delayed_ber32_enable)
         begin
         	int_add = cut_add & `MASK_BLK32 ;
         end
         
wire #1 delayed_ber64_enable = ber64_enable;
   always 
      @(posedge delayed_ber64_enable)
         begin
            int_add = cut_add & `MASK_BLK64 ;
         end
         
                  
        
   //----------------------------------------------------
   // Write or erase cycle execution
   //----------------------------------------------------
     
   always 
      @(posedge pp_enable or posedge quadpgm_enable)
      if ($time != 0)           
       begin
         for(i = 0; i <= (`PLENGTH - 1); i = i + 1)
         begin
            content[int_add + i] = p_prog[i] & content[int_add + i];
         end
      end
      
 always 
      @(posedge otppgm_enable)
      if ($time != 0)           
      begin
         for(i = 0; i <= (`PLENGTH - 1); i = i + 1)
         begin
            otp_content[int_add + i] = p_prog[i] & otp_content[int_add + i];
         end
      end      


   always 
      @(negedge cer_enable)
      if ($time != 0)           
      begin
         for(i = 0; i <= `TOP_MEM; i = i + 1)
         begin
            content[i] = 8'b11111111; 
         end
      end

   always 
      @(negedge ser_enable)
     
      if ($time != 0)           
      begin
         for(i = int_add; i <= (int_add + (`SSIZE / `NB_BIT_DATA) - 1); i = i + 1)
         begin
            content[i] = 8'b11111111; 
         end
      end
   
 always 
      @(negedge otpers_enable)
     
      if ($time != 0)          
      begin
         for(i = int_add; i <= (int_add + `OTP_SIZE - 1); i = i + 1)
         begin
            otp_content[i] = 8'b11111111; 
         end
      end


      
  always 
      @(negedge ber32_enable)
     
      if ($time != 0)         
      begin
         for(i = int_add; i <= (int_add + (`BSIZE_32 / `NB_BIT_DATA) - 1); i = i + 1)
         begin
            content[i] = 8'b11111111; 
         end
      end

      
always 
      @(negedge ber64_enable)
      
      if ($time != 0)        
      begin
         for(i = int_add; i <= (int_add + (`BSIZE_64 / `NB_BIT_DATA) - 1); i = i + 1)
         begin
            content[i] = 8'b11111111; 
         end
      end
         

endmodule


module acdc_check (c, d, s, hold, write_op, read_op,read_op_80,oen,thold_readquad,QE,flag_80M,flag_120M);	

   input c; 
   input d; 
   input s; 
   input hold; 
   input write_op; 
   input read_op; 
   input read_op_80;
   input oen;
   input thold_readquad;
   input QE;

   output flag_80M;
   reg    flag_80M;

   output flag_120M;
   reg    flag_120M;

   ////////////////
   // TIMING VALUES
   ////////////////
   realtime t_C_rise;
   realtime t_C_fall;
   realtime t_H_rise;
   realtime t_H_fall;
   realtime t_S_rise;
   realtime t_S_fall;
   realtime t_D_change;
   realtime high_time;
   realtime low_time;
  

   
   reg toggle;
   
   initial
   begin
      high_time = 100000;
      low_time = 100000;
      toggle = 1'b0;
      flag_80M  = 1'b0;
      flag_120M = 1'b0;
   end

   //--------------------------------------------
   // This process checks pulses length on pin /S
   //--------------------------------------------
   always 
   begin : shsl_watch
      @(posedge s); 
      begin
         if ($time != 0) 
         begin
            t_S_rise = $realtime; 
            @(negedge s); 
            t_S_fall = $realtime; 
            if ((t_S_fall - t_S_rise) < `TSHSL)
            begin
               $display("%t : ERROR : tSHSL condition violated",$realtime); 
            end 
         end
      end 
   end 

   //----------------------------------------------------
   // This process checks select setup and hold timings 
   //----------------------------------------------------
   always 
   begin : s_watch1  
      @(s); 
      if ((s == 1'b0) && (hold != 1'b0))
      begin
      if(!oen)
      begin
         if ($time != 0) 
         begin
            t_S_fall = $realtime;
            if ( ($realtime - t_C_rise) < `TCHSL)
                begin
                $display("%t : ERROR :tCHSL condition violated",$realtime); 
            if (c ==1'b1)
                begin
                @(c);
                @(c);
                if (($realtime - t_S_fall) < `TSLCH)
                      begin 
                      $display("%t : ERROR :tSLCH condition violated",$realtime);  
                      end
                end 
                end
            else if (c == 1'b0)
                begin
                @(c);
                if (($realtime - t_S_fall) < `TSLCH)
                    begin 
                    $display("%t : ERROR :tSLCH condition violated",$realtime);  
                    end
                end 
                end
      end 
      end
   end
   
   //----------------------------------------------------
   // This process checks deselect setup and hold timings 
   //----------------------------------------------------
   always
   begin : s_watch2 
   @(s);
      if ((s == 1'b1) && (hold != 1'b0))
      begin
      if(!oen)
      begin
         if ($time != 0) 
         begin
            t_S_rise = $realtime;
            if ( ($realtime - t_C_rise) < `TCHSH)
                begin
                $display("%t : ERROR :tCHSH condition violated",$realtime); 
                end 
            if (c == 1'b1)
                begin
                @(c);
                @(c);
                if ( ($realtime - t_S_rise) < `TSHCH )
                    begin
                    $display("%t : ERROR :tSHCH condition violated",$realtime);
                    end
                end
            else if (c == 1'b0)
                begin
                @(c);
                if ( ($realtime - t_S_rise) < `TSHCH )
                    begin
                    $display("%t : ERROR :tSHCH condition violated",$realtime);
                    end
                end 
          end
          end
      end 
   end

   //---------------------------------
   // This process checks hold timings
   //---------------------------------
   always 
   begin : hold_watch
      @(hold); 
      if ((hold == 1'b0) && (s == 1'b0) && !QE)	
      begin
      if((!oen) & (!thold_readquad))
      begin
         if ($time != 0) 
         begin
            t_H_fall = $realtime ;
            if (( (t_H_fall - t_C_rise) < `TCHHL) && !QE)
            begin
               $display("%t : ERROR : tCHHL condition violated",$realtime); 
            end 
         
            @(posedge c);
            if (( ($realtime - t_H_fall) < `THLCH) && !QE)
            begin
               $display("%t : ERROR : tHLCH condition violated",$realtime);
            end
         end
         end
      end 


      if ((hold == 1'b1) && (s == 1'b0))    
      begin
       if((!oen) & (!thold_readquad))
       begin
         if ($time != 0) 
         begin
            t_H_rise = $realtime ;
            if (( (t_H_rise - t_C_rise) < `TCHHH) && !QE)
            begin
               $display("%t : ERROR : tCHHH condition violated",$realtime); 
            end 
            @(posedge c);
            if (( ($realtime - t_H_rise) < `THHCH) && !QE)
            begin
               $display("%t : ERROR : tHHCH condition violated",$realtime);
            end
         end
         end
      end 
   end 

   //--------------------------------------------------
   // This process checks data hold and setup timings
   //--------------------------------------------------
   always 
   begin : d_watch
      @(d);
      if(!oen)
      begin
      if ((s ==1'b0)  && (hold == 1'b1))  
      begin
      if ($time != 0) 
      begin
         t_D_change = $realtime;
         if (c == 1'b1)
         begin
            if ( ($realtime - t_C_rise) < `TCHDX)
            begin
               $display("%t : ERROR : tCHDX condition violated",$realtime); 
            end 
         end
         else if (c == 1'b0)
         begin
            @(c);
            if ( ($realtime - t_D_change) < `TDVCH) 
            begin
               $display("%t : ERROR : tDVCH condition violated",$realtime);
            end
         end 
      end
      end
      end
   end 

   //-------------------------------------
   // This process checks clock high time
   //-------------------------------------
   always 
   begin : c_high_watch
      @(c); 
      if ($time != 0) 
         begin
         if (c == 1'b1)
            begin
            if (s==1'b1)
                begin
                t_C_rise = $realtime; 
                high_time=100; 
                end
            if (s==1'b0)  
                begin 
                t_C_rise = $realtime; 
                @(negedge c); 
                t_C_fall = $realtime; 
                high_time = t_C_fall - t_C_rise;
                toggle = ~toggle;
                if ((t_C_fall - t_C_rise) < `TCH)
                    begin
                    if ((s == 1'b0) && (hold == 1'b1)) 
                         begin
                         if ($time != 0) $display("%t : ERROR : tCH condition violated",$realtime); 
                         end 
                    end 
                 end
      end
   end 
 end
   //-------------------------------------
   // This process checks clock low time
   //-------------------------------------
   always 
   begin : c_low_watch
      @(c); 
      if ($time != 0)
          begin
          if (s==1'b1) low_time=100;  
          if (s==1'b0)  
              begin  
              if (c == 1'b0)
                  begin
                  t_C_fall = $realtime; 
                  @(posedge c); 
                  t_C_rise = $realtime; 
                  low_time = t_C_rise - t_C_fall;
                  toggle = ~toggle;
                  if ((t_C_rise - t_C_fall) < `TCL)
                     begin
                     if ((s == 1'b0) && (hold == 1'b1)) 
                         begin
                         if ($time != 0) $display("%t : ERROR : tCL condition violated",$realtime); 
                        end 
                     end 
                  end
              end
        end 
   end
  

   //-----------------------------------------------
   // This process checks clock frequency
   //-----------------------------------------------
   always @(toggle or read_op or read_op_80 or write_op)
   begin : freq_watch
      if ($time != 0) 
      begin
         if ((s == 1'b0) && (hold == 1'b1)) 
         begin
            if (read_op_80)
            begin
               if ((high_time + low_time) < `TR)
               begin
                  if ($time !=0) $display("%t : ERROR : Clock frequency condition violated for READ instruction: fR>80MHz",$realtime); 
                  flag_80M <=1'b1;
               end 
               else
               begin
                  flag_80M <=1'b0;
               end
            end

            if (write_op || read_op)
            begin
               if ((high_time + low_time) < `TC)
               begin
                  if ($time !=0) $display("%t : ERROR : Clock frequency condition violated: fC>120MHz",$realtime);                   
                  flag_120M <=1'b1;
               end 
               else
               begin
                  flag_120M <=1'b0;
               end
               if ((high_time + low_time) < `TR)
               begin
                  flag_80M <=1'b1;
               end 
               else
               begin
                  flag_80M <=1'b0;
               end
            end 
         end
      end
   end 
   
 
endmodule



module internal_logic ( c, d,      w, s, hold, data_to_read, q,        data_to_write, page_add_index, add_mem, suspend_add, suspend_enable, suspend_pp, suspend_ber32 , suspend_ber64 , suspend_ser, resume_enable, write_op, read_op,read_op_80, cer_enable, ber32_enable, ber64_enable, ser_enable, add_pp_enable, pp_enable,write_data_request, read_enable,read_enable_2,read_enable_4, read_data_request, oen, thold_readquad,  
                              quadpgm_enable,   otpers_enable, otppgm_enable,   suspend_quadpgm,   suspend_otppgm,  suspend_otpers, otppgm, otprd, otpers,QE,flag_80M,flag_120M);	
   ////////////////////////////////
   // declaration of the parameters
   ////////////////////////////////
    
   input c; 
   inout d;   
   inout w;   
   input s;
   inout hold; 
   input[(`NB_BIT_DATA - 1):0] data_to_read; 
   
   inout q;  

   input flag_80M;
   input flag_120M;

   wire d,q,w,hold;
 
   output thold_readquad;

   output[(`NB_BIT_DATA - 1):0] data_to_write;
   reg[(`NB_BIT_DATA - 1):0] data_to_write;
   
   output[(`LSB_TO_CODE_PAGE - 1):0] page_add_index; 
   reg[(`LSB_TO_CODE_PAGE - 1):0] page_add_index;

   output[(`NB_BIT_ADD_MEM - 1):0] add_mem; 
   reg[(`NB_BIT_ADD_MEM - 1):0] add_mem;
   
   output [(`BIT_TO_CODE_MEM-1):0]   suspend_add; 
   reg [(`BIT_TO_CODE_MEM-1):0]      suspend_add; 
 
   output write_op; 
   reg write_op;

   output read_op; 
   output read_op_80; 
   reg read_op;
   reg read_op_80;

   output cer_enable; 
   reg cer_enable;

   output ber32_enable; 
   reg ber32_enable;
   
   output ber64_enable; 
   reg ber64_enable;
   
   output ser_enable; 
   reg ser_enable;
   
   output otpers_enable; 
   reg otpers_enable;
   
   
   output add_pp_enable; 
   reg add_pp_enable;
   
   output pp_enable; 
   reg pp_enable;
   
   output quadpgm_enable; 
   reg quadpgm_enable;
   
   output otppgm_enable; 
   reg otppgm_enable;
   
   output read_enable; 
   reg read_enable;

   output read_enable_2; 
   reg read_enable_2;
 
   output read_enable_4; 
   reg read_enable_4;

   output read_data_request; 
   reg read_data_request;
   
   output write_data_request; 
   reg write_data_request;
   
   output resume_enable;
   reg resume_enable;
   
   output suspend_enable;
   reg suspend_enable;
   
   output suspend_pp;
   reg suspend_pp;
   
   output suspend_quadpgm;
   reg suspend_quadpgm;
   
   output suspend_otppgm; 
   reg suspend_otppgm;
   
   output suspend_otpers; 
   reg suspend_otpers;
         
   output suspend_ser;
   reg suspend_ser;
   
   output suspend_ber32;
   reg suspend_ber32;
   
   output suspend_ber64;
   reg suspend_ber64;
   
   output oen;
   reg oen;
    
   output otppgm;  
   reg    otppgm;
    
   output otprd;
   reg    otprd; 
   
   output otpers;
   reg    otpers;
  
   output QE; 
   reg    QE; 

   ///////////////////////////////////////////////
   // declaration of internal variables
   ///////////////////////////////////////////////
   reg only_rdsr;
   reg only_suspend;
   reg select_ok;
   reg raz;
   reg byte_ok;
   reg byte_ok_crmr;
   reg wren;
   reg wrdi; 
   reg rdsr_l;      
   reg rdsr_h;      
   reg read_data;  
   reg fast_read;  
   
   reg dofr;    
   reg diofr;  
   reg qofr;   
   reg qiofr;   
   reg qiowfr;  
   reg manu_device_id_dual;  
   reg manu_device_id_quad;  
    
   reg crmr;
   reg reset_crmr;
   reg crmr_flag;
   reg diofr_crm_read;
   reg qiofr_crm_read;
   reg qiowfr_crm_read;
   reg manu_device_id_dual_crm_read;
   reg manu_device_id_quad_crm_read;
   
   reg diofr_crm_flag ; 
   reg qiofr_crm_flag ; 
   reg qiowfr_crm_flag ; 
   reg manu_device_id_dual_crm_flag ; 
   reg manu_device_id_quad_crm_flag ; 
   reg manu_device_id_quad_crm_flag1;
   reg manu_device_id_quad_crm_flag2;

   reg suspend_flag;


   reg wrsr;    
   reg wrsr_enable;    
   
   reg  dpd;
   reg  rfdp;
   reg  rfdpid;
   reg  dpd_enable;
   reg  bpbit_reg;
  
   reg pp;
   reg quadpgm; 
   reg ser;
   reg ber32;
   reg ber64;   
   
   reg cer;
   reg dp;
   reg rdid;
   reg q_bis;
   reg d_bis;
   reg wp_bis;
   reg hold_bis;
   
  wire tmp_do;  
  wire tmp_di;
  wire tmp_wp;
  wire tmp_hold;
  wire bpbit;

   reg temp_di;	
   reg temp_di_1;
   reg temp_di_2;
   reg temp_di_3;
   reg temp_di_4;
   reg temp_di_5;
   reg dq_do;
   reg dq_di;
   reg dq_wp;
   reg dq_hold;
   
   reg hold_cond;
   reg inhib_wren;
   reg inhib_wrdi;
   reg inhib_rdsr;
   reg inhib_read;
   reg inhib_crmr;
   reg inhib_manu_device_id_dual; 
   reg inhib_manu_device_id_quad; 
   reg inhib_pp;
   reg inhib_quadpgm; 
   reg inhib_otppgm;   
   reg inhib_otpers;
   reg inhib_ser;
   reg inhib_ber32;
   reg inhib_ber64;   
 
   reg inhib_wrsr;  

   reg inhib_cer;
   reg inhib_rdid;
   reg inhib_mid;  
   reg inhib_cpid;  
   reg inhib_rfdpid;  
   reg inhib_suspend;
   reg inhib_resume;

  
   reg inhib_rfdp;  
   reg inhib_dpd;  

   reg ser_enable_ctl; 
   reg otpers_enable_ctl;
   reg ber32_enable_ctl;
   reg ber64_enable_ctl;
       
   reg suspend;
   reg resume;
   
   reg reset_wel;
   reg wel;
   reg wip;
   reg c_int;
   
   reg rdsr_enable;
   reg rdid_enable;

   reg[4:0] bit_id;
   reg [23:0]  id;  
   reg [15:0] did0;  
   reg [15:0] cp_id;  
   reg [15:0] did1;  
   reg [7:0] resdid; 
   
   reg [7:0] crm_bit;
   reg LB;
   reg CMP;       
   reg mid;      
   reg cpid;      

   reg [2:0]   cpt; 
   reg [2:0]   cpt_crmr; 
   reg [2:0]   bit_index;      
   reg [2:0]   bit_res;       
   reg [2:0]   bit_register; 
   reg [2:0]   k;    

   reg [7:0]   data; 
   reg [7:0]   data_crmr;    
   reg [7:0]   adress_1; 
   reg [7:0]   adress_2; 
   reg [7:0]   adress_3; 
   reg [7:0]   manufacturerID;
   reg [7:0]   memtype;
   reg [7:0]   density; 
   reg [7:0]   electronic_signature;  
   reg [4:0]   bp; 
   reg [1:0]   srp;
   reg [15:0]  custid;
   reg wrsr_protect;
 
   reg [(`NB_BIT_DATA-1):0]   page_ini; 
   reg [(`NB_BIT_DATA-1):0]   data_latch;
   reg [(`NB_BIT_DATA-1):0]   data_crmr_latch; 
   reg [(`NB_BIT_DATA*2-1):0]   register_bis;   
   reg [(`NB_BIT_DATA*2-1):0]   status_register;   
   
   reg [(`NB_BIT_ADD_MEM-1):0]      adress; 
   reg [(`BIT_TO_CODE_MEM-1):0]     cut_add; 
   reg [(`LSB_TO_CODE_PAGE -1) :0]  lsb_adress; 

   integer     byte_cpt;
   integer     byte_cpt_crmr;
   integer     int_add; 
   integer     i,j;
   integer     count_enable; 


   realtime	pps_time;
   realtime	otppgms_time; 
   realtime	otperss_time;
   realtime	quadpgms_time;         
   realtime	ser_time;
   realtime	ber32_time;
   realtime	ber64_time;
   
   realtime	ppi_time;
   realtime	quadpgmi_time;
   realtime	otppgmi_time;
   realtime	otpersi_time;  
   realtime	seri_time;
   realtime	beri32_time;
   realtime	beri64_time;

   realtime	pps_time_add;	
   realtime	otppgms_time_add;   
   realtime	otperss_time_add;
   realtime	quadpgms_time_add;         
   realtime	ser_time_add;
   realtime	ber32_time_add;
   realtime	ber64_time_add;

   assign  tmp_do = q;    
   assign  tmp_di = d;
   assign  tmp_wp = w;
   assign  tmp_hold = hold;
  
  
   assign d = (read_enable_2) ? dq_di: 1'bz;
   assign q = (oen) ? dq_do : 1'bz;
   assign w = (read_enable_4) ? dq_wp : 1'bz;
   assign hold = (read_enable_4) ? dq_hold : 1'bz; 
   
   assign thold_readquad = qiofr || qiowfr;  

   initial
   begin
      ////////////////////////////////////////////
      // Initialization of the internal variables
      ////////////////////////////////////////////
      only_rdsr      = `FALSE;
      only_suspend   = `FALSE;
      select_ok      = `FALSE;
      raz            = `FALSE;
      byte_ok        = `FALSE;
      byte_ok_crmr   = `FALSE;
      
      cpt         = 0;
      byte_cpt    = 0;
      cpt_crmr         = 0;
      byte_cpt_crmr    = 0;
      data_to_write  = 8'bxxxxxxxx;
      data_latch     = 8'bxxxxxxxx;
      read_data_request <= `FALSE;
      write_data_request <= `FALSE;
      
      wren          = `FALSE;
      wrdi          = `FALSE;
      rdsr_l        = `FALSE;  
      rdsr_h        = `FALSE;  
      
      read_data   = `FALSE;
      fast_read   = `FALSE;
      
      dofr        = `FALSE;   
      diofr       = `FALSE;
      qofr        = `FALSE;
      qiofr       = `FALSE;
      qiowfr      = `FALSE;
      otprd       = `FALSE;  
      
      diofr_crm_read  = `FALSE;
      qiofr_crm_read  = `FALSE;
      qiowfr_crm_read = `FALSE;
      
      diofr_crm_flag  = `FALSE;
      qiofr_crm_flag  = `FALSE;
     
      manu_device_id_dual_crm_flag  = `FALSE;
      manu_device_id_quad_crm_flag  = `FALSE;
      manu_device_id_quad_crm_flag1  = `FALSE;
      manu_device_id_quad_crm_flag2  = `FALSE;
      manu_device_id_dual_crm_read  = `FALSE;
      manu_device_id_quad_crm_read  = `FALSE;
      
      
      qiowfr_crm_flag = `FALSE;
      crmr        = `FALSE;
      crmr_flag   = `FALSE;
     
      pp              = `FALSE;
      quadpgm         = `FALSE; 
      otppgm          = `FALSE;
      otpers          = `FALSE;      
      ser            = `FALSE;
      ber32         = `FALSE;
      ber64         = `FALSE;
        
      cer	  = `FALSE;
      suspend_pp  = `FALSE;
      suspend_quadpgm  = `FALSE;  
      suspend_otppgm  = `FALSE;      
      suspend_otpers  = `FALSE;      
            
      suspend_ser = `FALSE;
      suspend_ber32 = `FALSE;
      suspend_ber64 = `FALSE;

      rdid        = `FALSE;
      mid         = `FALSE;       
      cpid        = `FALSE;       
      suspend     = `FALSE;
      resume      = `FALSE;
      rfdp        = `FALSE;   
      rfdpid      = `FALSE;  
      dpd         = `FALSE;  
      dpd_enable  = `FALSE;  

      q_bis          = 1'bz;
      d_bis          = 1'bz;
      wp_bis         = 1'bz;
      hold_bis       = 1'bz;

      register_bis     = 16'h0000; 
      status_register  = 16'h0000; 

      hold_cond   = `FALSE;
      write_op    = `FALSE;
      read_op     = `FALSE;
      read_op_80  = `FALSE;

      inhib_wren  = `FALSE;
      inhib_wrdi  = `FALSE;
      inhib_rdsr  = `FALSE;
 
      inhib_read  = `FALSE;
      
      inhib_crmr  = `FALSE;
      
      inhib_pp    = `FALSE;
      inhib_ber32    = `FALSE;
      inhib_ber64    = `FALSE;

      inhib_cer    = `FALSE;
      manu_device_id_dual       = `FALSE;   
      manu_device_id_quad       = `FALSE;   
      
      inhib_quadpgm   = `FALSE;        
      inhib_otppgm    = `FALSE;      
      inhib_otpers    = `FALSE;      
      inhib_ser     = `FALSE;
      inhib_wrsr    = `FALSE;   
      QE            = `FALSE;	  
      LB            = `FALSE;   
      CMP           = `FALSE;

      inhib_rdid  = `FALSE;
      inhib_mid   = `FALSE;    
      inhib_cpid   = `FALSE;    
      inhib_rfdpid  = `FALSE;
  
      inhib_dpd   = `FALSE;    
      inhib_rfdp  = `FALSE;  
      
      inhib_suspend  = `FALSE;
      inhib_resume   = `FALSE;

      add_pp_enable  = `FALSE;
      read_enable    = `FALSE;
      read_enable_2    = `FALSE;
      read_enable_4    = `FALSE;
      pp_enable      = `FALSE;
      quadpgm_enable     = `FALSE; 
      otppgm_enable      = `FALSE;      
      
      cer_enable         = `FALSE;
      ber32_enable       = `FALSE;
      ber32_enable_ctl   = `FALSE;
      ber64_enable       = `FALSE;
      ber64_enable_ctl   = `FALSE;

      
      ser_enable      = `FALSE;
      ser_enable_ctl  = `FALSE;
      otpers_enable   = `FALSE;     
      otpers_enable_ctl = `FALSE;  
      suspend_enable  = `FALSE;
      suspend_flag    = `FALSE;	   
      resume_enable   = `FALSE;
      rdsr_enable     = `FALSE;
      wrsr            = `FALSE;
      wrsr_enable     = `FALSE;
      rdid_enable     = `FALSE;
      oen             = `FALSE; 
      bpbit_reg       = `FALSE; 
      wrsr_protect    = `FALSE;

      count_enable   = `FALSE;
      data           = 8'b00000000;

      bit_index      = 8'b00000000;
      bit_res        = 8'b00000000;
      bit_register   = 8'b00000000;
      k   = 8'b00000000;

      int_add     = 0;
      page_ini    = 8'b11111111;
      
      reset_crmr  = 1'b0;
      reset_wel   = 1'b0;
      wel         = 1'b0;
      wip         = 1'b0;
      
      temp_di =1'bz;
      temp_di_1 =1'bz;
      temp_di_2 =1'bz;
      temp_di_3 =1'bz;
      temp_di_4 =1'bz;
      temp_di_5 =1'bz;
      dq_di = 1'bz ;
      dq_do = 1'bz ;
      dq_wp = 1'bz ;
      dq_hold = 1'bz ;
      manufacturerID = `manufacturerID;
      memtype = `memtype;
      density = `density;
      custid  = `custid;
      electronic_signature = `SIGNATURE; 
      
      /////////////////////////////////////////////////////////
      id = {manufacturerID,memtype,density};
      did0 = { manufacturerID, electronic_signature };
      did1 = { electronic_signature, manufacturerID };
      resdid = electronic_signature;
      bit_id = 5'b00000;
      cp_id = custid;
      //////////////////////////////////////////////////////////


   pps_time_add		=0;	
   otppgms_time_add	=0;   
   otperss_time_add	=0;
   quadpgms_time_add	=0;         
   ser_time_add		=0;
   ber32_time_add	=0;
   ber64_time_add	=0;


   end
  
    always @(negedge wrsr_enable)	 
    begin
	if(!LB || (LB && register_bis[10]))	
	status_register[(`NB_BIT_DATA*2-1):0] = { 1'b0,register_bis[14], 3'b000, register_bis[10:0]};
	else
	begin
	status_register[(`NB_BIT_DATA*2-1):0] = { 1'b0,register_bis[14], 3'b000, LB,register_bis[9:0]};
	end
     end 


   always 
   begin : hold_com
      @(hold or s); 
      begin
      if ((hold == 1'b0) && (s == 1'b0 ) &&   (!QE)  )
      begin
         if (c == 1'b0)
         begin
            hold_cond <= `TRUE;
            if ($time != 0) $display("%t:  NOTE: COMMUNICATION PAUSED",$realtime); 
         end
         else
         begin
            @(c or hold); 
            if (c == 1'b0)
            begin
               hold_cond <= `TRUE;
               if ($time != 0) $display("%t:  NOTE: COMMUNICATION PAUSED",$realtime); 
            end 
         end 
      end
      else if (hold == 1'b1 &&  (!QE) && hold_cond)
      begin
         if (c == 1'b0)
         begin
            hold_cond <= `FALSE;
            if ($time != 0) $display("%t:  NOTE: COMMUNICATION (RE)STARTED",$realtime); 
         end
         else
         begin
            @(c or hold); 
            if (c == 1'b0)
            begin
               hold_cond <= `FALSE;
               if ($time != 0) $display("%t:  NOTE: COMMUNICATION (RE)STARTED",$realtime); 
            end 
         end 
      end
      end
   end 

   always 
   begin : horloge
      @(c); 
      begin
      if (!hold_cond)
      begin
         c_int <= c ; 
      end
      else
      begin
         c_int <= 1'b0 ; 
      end 
      end
   end 

   always @(posedge hold_cond ) dq_do <= #`THLQZ 1'bz ;
   
   always @(negedge hold_cond) dq_do <= #`THHQX q_bis ; 
   
   always @ (q_bis or s)
      if (!hold_cond)
      begin
         dq_do <= q_bis ; 
      end

  always @ (d_bis or s)    
      if (!hold_cond)
      begin
         dq_di <= d_bis ; 
      end
        
 always @ (wp_bis or s)
      if (!hold_cond)
      begin
         dq_wp <= wp_bis ; 
      end
      
always @ (hold_bis or s)
      if (!hold_cond)
      begin
         dq_hold <= hold_bis ; 
      end
      
 
   always 
   begin : count_bit_raz
         @(raz); 
         begin
            if (raz || !select_ok)
            begin
               cpt <= 0 ; 
               byte_cpt <= 0 ; 
               count_enable <= `FALSE; 
               cpt_crmr <= 0 ; 
               byte_cpt_crmr <= 0 ;
            end
         end
   end 

   always 
   begin : count_bit_enable
      @(posedge c_int or negedge raz);
      begin
            if (!raz && select_ok)
            begin
               count_enable = `TRUE; 
            end
      end
   end
   

   always 
   begin : count_bit
      @(negedge c_int);
      begin
         if (!raz && select_ok)
         begin
            if (count_enable) 
            begin
               if(~(( (dofr && read_enable) || diofr || manu_device_id_dual) && (cpt ==3)  ||  ( (qofr && read_enable) || qiofr || qiowfr || manu_device_id_quad) && (cpt ==1)  || (quadpgm  && (byte_cpt > 3) && (cpt ==1)) ))
               cpt <= cpt + 1 ;
               cpt_crmr <= cpt_crmr + 1 ; 
            end 
         end
         if (crmr_flag && (cpt_crmr == 7))
               cpt_crmr <= 0;
          
      end
   end 

   always @(negedge c_int)
   begin
      if (byte_ok) 
         byte_cpt <= (byte_cpt + 1) ; 
      if (byte_ok_crmr && crmr_flag)    
         byte_cpt_crmr <= (byte_cpt_crmr + 1) ; 
   end 

  always @(posedge c_int)
  begin
  	if ((cpt_crmr == 7) && crmr_flag)
  		byte_ok_crmr <= `TRUE;
  	if ((cpt_crmr == 0) && crmr_flag)
  		byte_ok_crmr <= `FALSE;
  end	

   always 
   begin : data_in_reset

      @(select_ok); 
      begin
         if (!select_ok)
         begin
            raz <= `TRUE ; 
            byte_ok <=  `FALSE ; 
            data_latch <= 8'b00000000 ; 
            data = 8'b00000000;
            byte_ok_crmr <= `FALSE ; 
            data_crmr_latch <= 8'b00000000 ; 
            data_crmr = 8'b00000000;
         end
      end
   end
   
   always 
   begin : data_in     

      @(posedge c_int); 
      begin
      if (select_ok)
      begin
         
         if((byte_cpt==0) && (crm_bit[7:4] !== 4'ha))  
         begin
           raz <= `FALSE ;
         if (cpt == 0)
            begin
            data_latch <= 8'b00000000 ; 
            byte_ok <= `FALSE ; 
            end 
         data[7 - cpt] = tmp_di; 
          if (cpt == 7)
            begin
            byte_ok <= `TRUE ; 
            data_latch <= data ; 
            end 
         else data_latch <= 8'bxxxxxxxx;
         end 
       
         else
         if ((byte_cpt==0) && (crm_bit[7:4] == 4'ha) && (diofr || manu_device_id_dual)) 
         begin
         	raz <= `FALSE ;
         	if (cpt == 0)
           	 begin
            	data_latch <= 8'b00000000 ; 
            	byte_ok <= `FALSE ; 
            	end 
        	data[7 - cpt * 2] = tmp_do; 
         	data[6 - cpt * 2] = tmp_di; 
         	
         
          	if (cpt == 3)
           	begin
           	byte_ok <= `TRUE ; 
            	data_latch <= data ; 
             	end 
             	
          	else data_latch <= 8'bxxxxxxxx;
         end 
         else
         if ((byte_cpt==0) && (crm_bit[7:4] == 4'ha) && (qiofr || qiowfr ||manu_device_id_quad))
         begin
         	raz <= `FALSE ;
         	if (cpt == 0)
            	begin
            	data_latch <= 8'b00000000 ; 
            	byte_ok <= `FALSE ; 
            	end 
         	data[7 - cpt * 4 ] = tmp_hold; 
         	data[6 - cpt * 4 ] = tmp_wp; 
         	data[5 - cpt * 4 ] = tmp_do; 
         	data[4 - cpt * 4 ] = tmp_di; 
         	
         	
           	if (cpt == 1)
            	begin
           	 byte_ok <= `TRUE ; 
            	data_latch <= data ; 
            	end 
            	
            	else data_latch <= 8'bxxxxxxxx;
            	
         end
       
       else if (byte_cpt>0)   
       begin
           raz <= `FALSE ;
           
    	if(read_data || fast_read ||dofr ||qofr ||otprd) 
                 
         begin
         if (cpt == 0)
            begin
            data_latch <= 8'b00000000 ; 
            byte_ok <= `FALSE ; 
            end 
         data[7 - cpt] = tmp_di; 
           if (cpt == 7)
            begin
            byte_ok <= `TRUE ; 
            data_latch <= data ; 
            end 
          else data_latch <= 8'bxxxxxxxx;
         end 
         
        
                  
         else if (diofr || manu_device_id_dual)
         begin
         if (cpt == 0)
            begin
            data_latch <= 8'b00000000 ; 
            byte_ok <= `FALSE ; 
            end 
         data[7 - cpt * 2] = tmp_do; 
         data[6 - cpt * 2] = tmp_di; 
         
          if (cpt == 3)
            begin
            byte_ok <= `TRUE ; 
            data_latch <= data ; 
             end                       
          else data_latch <= 8'bxxxxxxxx;
         end 
        
         else if (qiofr || qiowfr || manu_device_id_quad)
         begin
         if (cpt == 0)
            begin
            data_latch <= 8'b00000000 ; 
            byte_ok <= `FALSE ; 
            end 
         data[7 - cpt * 4 ] = tmp_hold; 
         data[6 - cpt * 4 ] = tmp_wp; 
         data[5 - cpt * 4 ] = tmp_do; 
         data[4 - cpt * 4 ] = tmp_di; 
         
           if (cpt == 1)
            begin
            byte_ok <= `TRUE ; 
            data_latch <= data ; 
            end 
        end 
        
         else if (quadpgm)
           begin  
            if(byte_cpt >=1 && byte_cpt <=3)
            begin
            if (cpt == 0)
            begin
            data_latch <= 8'b00000000 ; 
            byte_ok <= `FALSE ; 
            end 
            data[7 - cpt] = tmp_di; 
           if (cpt == 7)
            begin
            byte_ok <= `TRUE ; 
            data_latch <= data ; 
            end 
           else data_latch <= 8'bxxxxxxxx;
          end
           
            else if(byte_cpt > 3)
            begin
                if (cpt == 0)
                   begin
                   data_latch <= 8'bxxxxxxxx;
                   byte_ok <= `FALSE ; 
                   end 
                data[7 - cpt * 4 ] = tmp_hold; 
                data[6 - cpt * 4 ] = tmp_wp; 
                data[5 - cpt * 4 ] = tmp_do; 
                data[4 - cpt * 4 ] = tmp_di; 
                
                  if (cpt == 1)
                   begin
                   byte_ok <= `TRUE ; 
                   data_latch <= data ; 
                   end 
            end        
        end 
  
               
        else
         begin
         raz <= `FALSE ;
         if (cpt == 0)
            begin
            data_latch <= 8'b00000000 ; 
            byte_ok <= `FALSE ; 
            end 
         data[7 - cpt] = tmp_di; 
          if (cpt == 7)
            begin
            byte_ok <= `TRUE ; 
            data_latch <= data ; 
            end 
         else data_latch <= 8'bxxxxxxxx;
         end 
      end 
      if ((byte_cpt_crmr==0) && (crm_bit[7:4] == 4'ha) && (diofr || manu_device_id_dual || qiofr || manu_device_id_quad || qiowfr))
      begin
                raz <= `FALSE ;
         	if (cpt_crmr == 0)
            	begin
            	data_crmr_latch <= 8'b00000000 ; 
            	byte_ok_crmr <= `FALSE ;
            	end
            	
            	data_crmr[7 - cpt_crmr] = tmp_di;
            	
            	if (cpt_crmr == 7)
            	begin
            	data_crmr_latch <= data_crmr;
            	end
            
                else data_crmr_latch <= 8'bxxxxxxxx; 
      end
                else data_crmr_latch <= 8'bxxxxxxxx; 
   end 
   end
   end 
   
 always @(negedge c_int) 
    begin
      if (select_ok && (diofr || manu_device_id_dual))
      begin
      if(cpt ==3)
      cpt<=0;
      end
      
      else if (select_ok && ( qiofr || manu_device_id_quad || qiowfr ) )
      begin
      if(cpt ==1)
      cpt<=0;     
      end 
      
      else if (select_ok && quadpgm )
      begin
        if(byte_cpt > 3)
         begin
        if(cpt ==1)
        cpt<=0;     
         end 
      end 
    end
       




   //-------------------------------------------------------------
   //--------------- ASYNCHRONOUS DECODE PROCESS -----------------
   //-------------------------------------------------------------
always 
   begin : decode_crmr
     
      @(byte_ok_crmr); 
      if (byte_ok_crmr == 1'b1)
      begin         
         //-----------------------------------------------------------
         //-- op_code decode
         //-----------------------------------------------------------
         if (byte_cpt_crmr == 0)
         begin
	if (data_crmr_latch == 8'b11111111) 
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr && (~suspend_enable))
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
                begin
                  crmr <= `TRUE ;
                  write_op <= `TRUE ; 
                  
               end 
            end
	end
     end
end



   always 
   begin : decode
      @(byte_ok); 
 	if (byte_ok == 1'b1 )	

      
      begin         
         //-----------------------------------------------------------
         //-- op_code decode
         //-----------------------------------------------------------
         
         if ((byte_cpt == 0) && (!crmr_flag))
         begin
          if (data_latch == 8'b00000110)
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle",$realtime); 
               end
               else
               begin
                  wren <= `TRUE ; 
               end 
            end
            
             else if (data_latch == 8'b00000100 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle",$realtime); 
               end
               else
               begin
                  wrdi <= `TRUE ; 
               end 
            end
            
            else if (data_latch == 8'b00000101 && (!crmr_flag))  
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else
               begin
                  rdsr_l <= `TRUE ; 
                  read_op <= `TRUE ;  
               end
            end
           
            else if (data_latch == 8'b00110101 && (!crmr_flag))  
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else
               begin
                  rdsr_h <= `TRUE ; 
                  read_op <= `TRUE ;  
               end
            end
           
           
            else if (data_latch == 8'b00000011 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr && (~suspend_enable))
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
               begin
                  read_data <= `TRUE ; 
                  read_op_80 <= `TRUE ; 
               end 
            end
            
            else if (data_latch == 8'b00001011 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr && (~suspend_enable))
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else               
               begin
                  fast_read <= `TRUE ; 
                  write_op <= `TRUE ;  
               end 
            end
            
            else if (data_latch == 8'b01001000 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr && (~suspend_enable))
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
               begin
                  otprd <= `TRUE ; 
                  write_op <= `TRUE ;   
               end 
            end
            
            
            else if (data_latch == 8'b00111011 && (!crmr_flag)) 
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr && (~suspend_enable))
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
                begin
                  dofr <= `TRUE ; 
                  write_op <= `TRUE ; 
               end 
            end
            
            else if (data_latch == 8'b10111011 && (!crmr_flag)) 
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr && (~suspend_enable))
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else 
               begin
                  diofr <= `TRUE ; 
                  read_op <= `TRUE ; 
               end 
            end

             else if (data_latch == 8'b10010010 && (!crmr_flag)) 
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr && (~suspend_enable))
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else 
               begin
                  manu_device_id_dual <= `TRUE ; 
                  read_op <= `TRUE ;
               end 
            end
            else if (data_latch == 8'b01101011 && (!crmr_flag))  
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr && (~suspend_enable))
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else if (QE)
               begin
                  qofr <= `TRUE ; 
                  write_op <= `TRUE ; 
               end 
               else 
                begin
                  qofr <= `FALSE ; 
                  write_op <= `FALSE ; 
                 
               end 
            end
            
            else if (data_latch == 8'b11101011 && (!crmr_flag)) 
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr && (~suspend_enable))
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
                else if (QE)
               begin
                  qiofr <= `TRUE ;
                  read_op <= `TRUE ; 
               end 
               else
                begin
                  qiofr <= `FALSE ;
                  read_op <= `FALSE ; 
               end 
            end
            
             else if ((data_latch == 8'b10010100) && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr && (~suspend_enable))
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
                else if (QE)
               begin
                  manu_device_id_quad <= `TRUE ;
	          read_op <= `TRUE;
               end 
               else
                begin
                  manu_device_id_quad <= `FALSE ;
                  read_op <= `FALSE ; 
               end 
            end
            
            
            else if (data_latch == 8'b11100111 && (!crmr_flag)) 
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr && (~suspend_enable))
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
                else if  (QE)
               begin
                  qiowfr <= `TRUE ; 
                  read_op <= `TRUE ; 
               end 
               else 
                begin
                  qiowfr <= `FALSE ;
                  read_op <= `FALSE ;
               end 
            end
            
           else if (data_latch == 8'b00000001 && (!crmr_flag))   
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr || suspend_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
               begin
                  wrsr <= `TRUE ; 
                  write_op <= `TRUE ; 
               end 
            end
            
            
            
            else if (data_latch == 8'b00000010 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr || suspend_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
               begin
                  pp <= `TRUE ; 
                  write_op <= `TRUE ; 
               end 
            end
            
             else if (data_latch == 8'b00110010 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr || suspend_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else if (QE)
               begin
                  quadpgm <= `TRUE ;
                  write_op <= `TRUE ; 
               end 
               else
                begin
                  quadpgm <= `FALSE ;
                  write_op <= `FALSE ; 
                  if ($time != 0) $display("%t:  ERROR : This Opcode need to set QE first. Cycle",$realtime); 
               end 
            end
             
             else if (data_latch == 8'b01000010 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr || suspend_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
               begin
                  otppgm <= `TRUE ; 
                  write_op <= `TRUE ; 
               end 
            end 
                               
            
            else if (data_latch == 8'b00100000 && (!crmr_flag)) 
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr || suspend_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
               begin
                  ser <= `TRUE ; 
                  write_op <= `TRUE ; 
               end 
            end
            
             else if (data_latch == 8'b01000100 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr || suspend_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
               begin
                  otpers <= `TRUE ; 
                  write_op <= `TRUE ; 
               end 
            end
            
            
            else if ( data_latch == 8'b01010010 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr || suspend_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
               begin
                  ber32 <= `TRUE ; 
                  write_op <= `TRUE ; 
               end 
            end

             else if ( data_latch == 8'b11011000 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr || suspend_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
               begin
                  ber64 <= `TRUE ; 
                  write_op <= `TRUE ; 
               end 
            end
           
            else if (((data_latch == 8'b11000111) || (data_latch == 8'b01100000)) && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr || suspend_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime); 
               end
               else
               begin
                  cer <= `TRUE ; 
                  write_op <= `TRUE ; 
               end 
            end

            else if (data_latch == 8'b10011111 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime);
               end
               else
               begin
                  rdid <= `TRUE ;
                  read_op <= `TRUE ;
               end
            end
            
            else if (data_latch == 8'b10010000 && (!crmr_flag))  
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime);
               end
               else
               begin
                  mid <= `TRUE ;
                  read_op <= `TRUE ;
               end
            end

            else if (data_latch == 8'b01001011 && (!crmr_flag))  
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime);
               end
               else
               begin
                  cpid <= `TRUE ;
                  read_op <= `TRUE ;
               end
            end
            
           else if (data_latch == 8'b10101011 && (!crmr_flag)) 
            begin
               if (only_rdsr)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime);
               end
		else
               begin   
                  rfdp <= `TRUE ;
                  read_op <= `TRUE ;
               end
            end

             else if (data_latch == 8'b10111001 && (!crmr_flag))  
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (only_rdsr)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime);
               end
               else 
               begin
                  dpd <= `TRUE ;
                  read_op <= `TRUE ;
               end
            end
            
            else if (data_latch == 8'b01110101 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (cer || wrsr || (!only_rdsr))  
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime);
               end
              else
              begin
                  suspend <= `TRUE ;
                  if(pp)
                  begin
                  	suspend_pp <= `TRUE;
                  end                  
                  if(quadpgm)
                  begin
                  	suspend_quadpgm <= `TRUE;
                  end                  
                  if(otppgm)
                  begin
                  	suspend_otppgm <= `TRUE;
                  end
                  if(otpers)
                  begin
                  	suspend_otpers <= `TRUE;
                  end                                                      
                 if(ser)
                  begin
                  	suspend_ser <= `TRUE;
                  end
                 if(ber32)
                  begin
                  	suspend_ber32 <= `TRUE;
                  end
                 if(ber64)
                  begin
                  	suspend_ber64 <= `TRUE;
                  end 
                  
              end
            end
            else if (data_latch == 8'b01111010 && (!crmr_flag))
            begin
               if ( dpd_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during deep power down cycle. Cycle",$realtime); 
               end
               else if (~suspend_enable)
               begin
                  if ($time != 0) $display("%t:  ERROR : This Opcode is not decoded during a Prog. Cycle ",$realtime);
               end
               else
               begin
               	resume <= `TRUE;
              	resume_enable <=`TRUE ; 
              
        		if(suspend_pp)
     			begin
     				pp <= `TRUE;
     			end
     			if(suspend_quadpgm)
     			begin
     				quadpgm <= `TRUE;
     			end
     			if(suspend_otppgm)
     			begin
     				otppgm <= `TRUE;
     			end
     			if(suspend_otpers)
     			begin
     				otpers <= `TRUE;
     			end     			     			
     			if(suspend_ser)
     			begin
     				ser <= `TRUE;
     			end
     			if(suspend_ber32)
     			begin
     				ber32 <= `TRUE;
     			end
     			if(suspend_ber64)
     			begin
     				ber64 <= `TRUE;
     			end
     	     end
            end   
            else
            begin
               if ($time != 0) $display("%t:  ERROR : False instruction (%x), please retry ",$realtime,data_latch); 
            end 
         end 
         //---------------------------------------------------------------------
         // addresses and data reception and treatment
         //---------------------------------------------------------------------
         if ( (byte_cpt == 1) && (!only_rdsr) && (crm_bit[7:4] !==4'ha))
         begin
            if (( (otppgm) || (quadpgm) || (otpers) || (otprd)  || (read_data) || (fast_read) ||(mid) || (dofr) || (diofr) || (manu_device_id_dual) || (qofr) || (qiofr) || (manu_device_id_quad) || (qiowfr)  || (ser) || (ber32)|| (ber64) || (pp))  )
            begin
               adress_1[7:0] = data_latch[7:0];  
            end
         end 
         
         if ( (byte_cpt == 0) && (!only_rdsr) && (crm_bit[7:4] == 4'ha))
         begin
            if ((diofr) || (manu_device_id_dual) || (qiofr) ||(manu_device_id_quad)|| (qiowfr))
            begin
               adress_1[7:0] = data_latch[7:0];  
            end
         end 
         if ((byte_cpt == 2) && (!only_rdsr) && (crm_bit[7:4] !==4'ha))
         begin
            if (( (otppgm) || (quadpgm) || (otpers) || (otprd)  ||(read_data) || (fast_read) ||(mid) || (dofr) || (diofr) || (manu_device_id_dual) || (qofr) || (qiofr) || (manu_device_id_quad)|| (qiowfr) || (ser) || (ber32)|| (ber64) || (pp)) )  
            begin
               adress_2 = data_latch; 
            end 
         end 
         
         if ((byte_cpt == 1) && (!only_rdsr) && (crm_bit[7:4] == 4'ha))
         begin
            if ((diofr) || (qiofr) || (manu_device_id_dual) ||(manu_device_id_quad)|| (qiowfr))  
            begin
               adress_2 = data_latch; 
            end 
         end 
         
         if ((byte_cpt == 3) && (!only_rdsr) && (crm_bit[7:4] !==4'ha))
         begin
            if ((  (otppgm) || (quadpgm) || (otpers) || (otprd)  || (read_data) || (fast_read) || (mid)  || (dofr) || (diofr) || (manu_device_id_dual) || (qofr) || (qiofr) || (manu_device_id_quad) || (ser) || (ber32)|| (ber64) || (pp)) )  
            begin
               adress_3 = data_latch;
               for(i = 0; i <= (`NB_BIT_ADD - 1); i = i + 1)
               begin
                  adress[i] = adress_3[i]; 
                  adress[i + `NB_BIT_ADD] = adress_2[i]; 
                  adress[i + 2 * `NB_BIT_ADD] = adress_1[i]; 
                  add_mem <= adress ; 
               end
               for(i = (`LSB_TO_CODE_PAGE - 1); i >= 0; i = i - 1)
               begin
                  lsb_adress[i] = adress[i]; 
               end
            end 
            
            if (qiowfr)
            begin
              if(!data_latch[0])
               adress_3 = data_latch;
              else
               adress_3 = {data_latch[7:1],1'b0}; 
               for(i = 0; i <= (`NB_BIT_ADD - 1); i = i + 1)
               begin
                  adress[i] = adress_3[i]; 
                  adress[i + `NB_BIT_ADD] = adress_2[i]; 
                  adress[i + 2 * `NB_BIT_ADD] = adress_1[i]; 
                  add_mem <= adress ; 
               end
               
               for(i = (`LSB_TO_CODE_PAGE - 1); i >= 0; i = i - 1)
               begin
                  lsb_adress[i] = adress[i]; 
               end
            end 
          
           if ( ser || ber32 || ber64 || pp || otppgm || quadpgm || otpers )  
            begin
               //-----------------------------------------
               // To ignore don't care MSB of the adress
               //----------------------------------------- 
               for(i = 0; i <= `BIT_TO_CODE_MEM -1; i = i + 1)
               begin
                  cut_add[i] = adress[i]; 
               end
               int_add = cut_add; 
            end 
         end 
       
          if ((byte_cpt == 2) && (!only_rdsr) && (crm_bit[7:4] == 4'ha))
         begin
            if (diofr || manu_device_id_dual || qiofr || manu_device_id_quad )  
            begin
               adress_3 = data_latch;
               for(i = 0; i <= (`NB_BIT_ADD - 1); i = i + 1)
               begin
                  adress[i] = adress_3[i]; 
                  adress[i + `NB_BIT_ADD] = adress_2[i]; 
                  adress[i + 2 * `NB_BIT_ADD] = adress_1[i]; 
                  add_mem <= adress ; 
               end
               for(i = (`LSB_TO_CODE_PAGE - 1); i >= 0; i = i - 1)
               begin
                  lsb_adress[i] = adress[i]; 
               end
            end 
            
            if (qiowfr)
            begin
              if(!data_latch[0])
               adress_3 = data_latch;
              else
               adress_3 = {data_latch[7:1],1'b0}; 
               for(i = 0; i <= (`NB_BIT_ADD - 1); i = i + 1)
               begin
                  adress[i] = adress_3[i]; 
                  adress[i + `NB_BIT_ADD] = adress_2[i]; 
                  adress[i + 2 * `NB_BIT_ADD] = adress_1[i]; 
                  add_mem <= adress ; 
               end
               
               for(i = (`LSB_TO_CODE_PAGE - 1); i >= 0; i = i - 1)
               begin
                  lsb_adress[i] = adress[i]; 
               end
            end 
       end
         
       if ((byte_cpt == 4) && (!only_rdsr) && (crm_bit[7:4] !==4'ha) && (!diofr_crm_flag) && (!manu_device_id_dual_crm_flag) && (!qiofr_crm_flag) && (!manu_device_id_quad_crm_flag) && (!qiowfr_crm_flag))
       begin
       	   
       	   if (diofr || manu_device_id_dual || qiofr || qiowfr || manu_device_id_quad)
       	   begin
       	   	crm_bit = data_latch;
       	   	
       	   end
       end 
       
       if ((byte_cpt == 3) && (!only_rdsr) && (crm_bit[7:4] ==4'ha))
       begin
       	   
       	   if (diofr || manu_device_id_dual || qiofr || manu_device_id_quad || qiowfr)
       	   begin
       	   	crm_bit = data_latch;
       	   end
       end 
       	     
         
         //-----------------------------------------------------------------------------
         // PAGE PROGRAM
         // The adress's LSBs necessary to code a whole page are converted to a natural
         // and used to fullfill the page buffer p_prog the same way as the memory page
         // will be fullfilled.
         //-----------------------------------------------------------------------------
         if ( (byte_cpt >= 4) && (pp || quadpgm  ||otppgm ) && (!only_rdsr) && (status_register[1]==1'b1) )  
         begin
            data_to_write = data_latch ; 
            page_add_index = (byte_cpt - 1 - (`NB_BIT_ADD_MEM / `NB_BIT_ADD) + lsb_adress); 
         end 
         else
         begin
            data_to_write  = 8'bxxxxxxxx; 
            page_add_index = 8'bxxxxxxxx; 
         end


          if ( ( read_data && (byte_cpt == 3)) || ((fast_read || otprd) && (byte_cpt == 4)) || (dofr && (byte_cpt == 4)) || ((diofr || manu_device_id_dual)&& (((byte_cpt == 4) && (!crmr_flag)) || ((byte_cpt == 3) && (crmr_flag)))) 
         ||(qofr && (byte_cpt == 4)) || ((qiofr || manu_device_id_quad) && (((byte_cpt == 6) && (!crmr_flag)) || ((byte_cpt == 5) && (crmr_flag)))) ||(qiowfr && (((byte_cpt == 5) && (!crmr_flag)) || ((byte_cpt == 4) && (crmr_flag)))))
         begin
            read_enable <=  `TRUE ; 
         end 

          if ( (dofr && (byte_cpt == 4)) || ((diofr || manu_device_id_dual)&& (((byte_cpt == 4) && (!crmr_flag)) || ((byte_cpt == 3) && (crmr_flag)))) 
         ||(qofr && (byte_cpt == 4)) || ((qiofr || manu_device_id_quad) && (((byte_cpt == 6) && (!crmr_flag)) || ((byte_cpt == 5) && (crmr_flag)))) ||(qiowfr && (((byte_cpt == 5) && (!crmr_flag)) || ((byte_cpt == 4) && (crmr_flag)))))
         begin
            read_enable_2 <=  `TRUE ; 
         end
	
          if ( (qofr && (byte_cpt == 4)) || ((qiofr || manu_device_id_quad) && (((byte_cpt == 6) && (!crmr_flag)) || ((byte_cpt == 5) && (crmr_flag)))) ||(qiowfr && (((byte_cpt == 5) && (!crmr_flag)) || ((byte_cpt == 4) && (crmr_flag)))))
         begin
            read_enable_4 <=  `TRUE ; 
         end
        
         if (( read_data && (byte_cpt >= 3)) || ( (fast_read || otprd) && (byte_cpt >= 4))|| (dofr && (byte_cpt >= 4)) || ((diofr || manu_device_id_dual )&& (((byte_cpt >= 4) && (!crmr_flag)) || ((byte_cpt >= 3) && (crmr_flag)))) 
         ||(qofr && (byte_cpt >= 4)) || ((qiofr || manu_device_id_quad)&& (((byte_cpt >= 6) && (!crmr_flag)) || ((byte_cpt >= 5) && (crmr_flag)))) ||(qiowfr && (((byte_cpt >= 5) && (!crmr_flag)) || ((byte_cpt >= 4) && (crmr_flag)))))
         begin
            read_data_request <= `TRUE ; 
         end 
         if ( ( pp || quadpgm  || otppgm ) && (byte_cpt > 3))
         begin
            write_data_request <= `TRUE ; 
         end 
         
         //--------------------------------------------------------------------------
         // WRSR data treatment
         // write statue register 
         //--------------------------------------------------------------------------
      
        if ( (byte_cpt == 1) && (wrsr) && (!only_rdsr) ) 
         begin
            register_bis[`NB_BIT_DATA-1:0] = data_latch ;
            register_bis[`NB_BIT_DATA*2-1:8] = {5'b00000,LB,2'b00} ;			
         end 
         else if ( (byte_cpt == 2) && (wrsr) && (!only_rdsr) )  
         begin
             register_bis[`NB_BIT_DATA-1:0] = register_bis[`NB_BIT_DATA-1:0] ;
             register_bis[`NB_BIT_DATA*2-1:8] = data_latch ; 	
         end
      end
   end
   
   //-----------------------------------------
   // adresses initialization and reset
   //-----------------------------------------

always @(posedge select_ok) 	
   begin
      for(i = 0; i <= (`NB_BIT_ADD - 1); i = i + 1)
      begin
         adress_1[i] = 1'b0; 
         adress_2[i] = 1'b0; 
         adress_3[i] = 1'b0; 
      end
      for(i = 0; i <= (`NB_BIT_ADD_MEM - 1); i = i + 1)
      begin
         adress[i] = 1'b0; 
      end
      add_mem <= adress ; 
     
      if (crm_bit[7:4] !== 4'ha)
      begin
      	 diofr_crm_flag <= `FALSE;
      	 qiofr_crm_flag <= `FALSE;
      	 qiowfr_crm_flag <= `FALSE;
      	 crmr_flag <= `FALSE;
         manu_device_id_dual_crm_flag <= `FALSE;
      	 manu_device_id_quad_crm_flag <= `FALSE;
      	 manu_device_id_quad_crm_flag1 <= `FALSE;
      	 manu_device_id_quad_crm_flag2 <= `FALSE;
      end
      if (diofr || qiofr || qiowfr || manu_device_id_dual || manu_device_id_quad)
      	crmr_flag <= `TRUE;
      
      	reset_crmr <= 1'b0;
   end

	        
   always @(negedge select_ok) 
   begin
   	if (crm_bit[7:4] !== 4'ha)
      	begin
      	 diofr <= `FALSE ; 
         qiofr <= `FALSE ; 
         qiowfr <= `FALSE ; 
         read_enable <= `FALSE;
         read_enable_2 <= `FALSE;
         read_enable_4 <= `FALSE;
         read_data_request <= `FALSE ; 
         manu_device_id_dual <= `FALSE;	
         manu_device_id_quad <= `FALSE;	
        end
   end	
   	
   always @(negedge byte_ok)
   begin
      if ((read_data && (byte_cpt > 3) ) || ((fast_read || otprd) && (byte_cpt > 4) )   || (dofr && (byte_cpt > 4))  || ((diofr ||manu_device_id_dual) && (((byte_cpt > 4) && (!diofr_crm_flag)) || ((byte_cpt > 3) && (diofr_crm_flag))))  
      || (manu_device_id_dual && (((byte_cpt > 4) && (!manu_device_id_dual_crm_flag)) || ((byte_cpt > 3) && (manu_device_id_dual_crm_flag))))
      || (qofr && (byte_cpt > 4)) || (qiofr && (((byte_cpt > 6) && (!qiofr_crm_flag)) || ((byte_cpt > 5) && (qiofr_crm_flag)))) ||(qiowfr && (((byte_cpt > 5) && (!qiowfr_crm_flag)) || ((byte_cpt > 4) && (qiowfr_crm_flag))))
      || (manu_device_id_quad && (((byte_cpt > 6) && (!manu_device_id_quad_crm_flag)) || ((byte_cpt > 5) && (manu_device_id_quad_crm_flag))) ))
      begin
         read_data_request <= `FALSE ; 

      end 
      if ( (pp || quadpgm  || otppgm) && (byte_cpt > 3)) 
      begin
      	 write_data_request <= `FALSE ;
      end
   end
      
   always @(posedge inhib_read)
   begin
         read_op <= `FALSE ; 
         read_op_80 <= `FALSE ; 
         read_data <= `FALSE ; 
         fast_read <= `FALSE ; 
         otprd  <= `FALSE ;  
         read_enable <=  `FALSE ; 
         read_enable_2 <=  `FALSE ; 
         read_enable_4 <=  `FALSE ; 
         read_data_request <= `FALSE ; 
         dofr <= `FALSE ;    
         qofr <= `FALSE ; 
         if (!manu_device_id_dual_crm_flag) manu_device_id_dual <= `FALSE;
         if (!manu_device_id_quad_crm_flag) manu_device_id_quad <= `FALSE;
         if (!diofr_crm_flag) diofr <= `FALSE ; 
         if (!qiofr_crm_flag) qiofr <= `FALSE ; 
         if (!qiowfr_crm_flag) qiowfr <= `FALSE ;
   end

always @(posedge c_int)
   begin
   	if (crm_bit[7:4] == 4'ha)
   	
   	 begin
      	 	if (diofr)
      	 	diofr_crm_flag <= `TRUE;
      	 	if (qiofr) 
      	 	qiofr_crm_flag <= `TRUE;
      	 	if (qiowfr)
      	 	qiowfr_crm_flag <= `TRUE;
      	 	if (manu_device_id_dual)
      	 	manu_device_id_dual_crm_flag <= `TRUE;
	        if (manu_device_id_quad)
      	 	manu_device_id_quad_crm_flag1 <= `TRUE;		
      	 	
      	 end
  end    	
   
always @(posedge c_int)
    begin
	manu_device_id_quad_crm_flag2 <= manu_device_id_quad_crm_flag1;
	manu_device_id_quad_crm_flag <= manu_device_id_quad_crm_flag2;	
    end

   //------------------------------------------------------
   // STATUS REGISTER INSTRUCTIONS
   //------------------------------------------------------
   // WREN instructions
   //-----------------------      

   always @(posedge inhib_wren) 
   begin
      wren <= `FALSE ; 
   end 
   
    always @(posedge inhib_wrdi) 
   begin
      wrdi <= `FALSE ; 
   end 
   

   //----------------------
   // RESET WEL instruction
   //----------------------
     
   always @(posedge reset_wel)
   begin
      wel <= 1'b0 ; 
   end 
 
   //-----------------------------
   // CONTINUOUS READ MODE RESET
   //-----------------------------
 
  always @(posedge inhib_crmr) 
   begin
      crmr <= `FALSE ; 
      crmr_flag <= `FALSE ; 
   end 
   
  always @(posedge reset_crmr)
  begin
  	diofr_crm_flag <= `FALSE ; 
      	qiofr_crm_flag <= `FALSE ; 
      	qiowfr_crm_flag <= `FALSE ;
      	manu_device_id_dual_crm_flag <= `FALSE ; 
  	manu_device_id_quad_crm_flag <= `FALSE ;  
  	manu_device_id_quad_crm_flag1 <= `FALSE ;  
  	manu_device_id_quad_crm_flag2 <= `FALSE ;  
  end   
 
   //------
   // PROG
   //------
   
   always @(wip or wel)
   begin
      case ( { wel,wip} )        
       2'b00 :   status_register[1:0] = 2'b00 ; 
       2'b01 :   status_register[1:0] = 2'b01 ;
       2'b10 :   status_register[1:0] = 2'b10 ;
       2'b11 :   status_register[1:0] = 2'b11 ;
       default:  status_register[1:0] = 2'b00 ;
      endcase 
   end 

  wire sus = suspend_ber32 | suspend_ber64 | suspend_otpers | suspend_otppgm | suspend_pp | suspend_ser | suspend_quadpgm;
  
  always @ (sus or resume)
  begin
  status_register[15] = sus & ~resume ;
  end
   //**************end for read SUSPEND flag*********** 
   //------------------
   // rdsr instruction
   //------------------
   always @(posedge inhib_rdsr) 
   begin
   	rdsr_l <= `FALSE ;   
   	rdsr_h <= `FALSE ;   
   	read_op <= `FALSE ;
   	read_op_80 <= `FALSE ;
   	rdsr_enable <= `FALSE ;  
   end
   //----------------------------------------------------------
   // CHIP/BLOCK/SECTOR ERASE INSTRUCTIONS
   //----------------------------------------------------------
   always @(posedge inhib_cer)
   begin
      cer <= `FALSE ; 
   end 
     
   always @(posedge inhib_ber32)
   begin
      ber32 <= `FALSE ; 
      ber32_enable <= `FALSE; 
      ber32_time_add <=0;
   end 
   
   always @(posedge inhib_ber64)
   begin
      ber64 <= `FALSE ; 
      ber64_enable <= `FALSE;
      ber64_time_add <=0;
   end 
 
   always @(posedge inhib_ser)
   begin
      ser <= `FALSE ;
      ser_enable <= `FALSE;
      ser_time_add <=0;
   end 
   
   always @(posedge inhib_otpers)
   begin
      otpers <= `FALSE ;
      otpers_enable <= `FALSE;
      otperss_time_add <=0;
   end 
   
   
   
   //----------------------------------------------------------
   //WRSR INSTRUCTIONS
   //---------------------------------------------------------
  
   always @(posedge inhib_wrsr)
   begin
      wrsr <= `FALSE ;
      wel  <= `FALSE ;
   end 
   
   
   //----------------------------------------------------------
   //PAGE PROGRAM INSTRUCTIONS
   //---------------------------------------------------------
   
   always @(posedge inhib_pp)
   begin
      pp <= `FALSE ;
      write_data_request <= `FALSE ;
      pps_time_add <=0;
   end 

 always @(posedge inhib_quadpgm)
   begin
      quadpgm <= `FALSE ;
      write_data_request <= `FALSE ;
      quadpgms_time_add	<=0;
   end 



   always @(posedge inhib_otppgm)
   begin
      otppgm <= `FALSE ;
      write_data_request <= `FALSE ;
      otppgms_time_add	<=0;
   end 



   //--------------------------------------
   // READ JEDEC ID
   //--------------------------------------
   always @(posedge inhib_rdid) 
   begin
   	rdid <= `FALSE;
   	read_op <= `FALSE;
   	read_op_80 <= `FALSE;
   	rdid_enable  <= `FALSE;
   end
   
    always @(posedge inhib_mid) 
   begin
   	mid <= `FALSE;
   	read_op <= `FALSE;
   	read_op_80 <= `FALSE;
   	rdid_enable  <= `FALSE;
   end

   always @(posedge inhib_cpid) 
   begin
   	cpid <= `FALSE;
   	read_op <= `FALSE;
   	read_op_80 <= `FALSE;
   	rdid_enable  <= `FALSE;
   end

   
    always @(posedge inhib_rfdpid) 
   begin
   	rfdpid <= `FALSE;
   	rfdp <= `FALSE;
   	read_op <= `FALSE;
   	read_op_80 <= `FALSE;
   	rdid_enable  <= `FALSE;
   	dpd_enable <= `FALSE;
   end
   
    
   //--------------------------------------
   // DEEP POWER DOWN
   //--------------------------------------
   always @(posedge inhib_dpd) 
   begin
   	dpd <= `FALSE;
   	read_op <= `FALSE;
   	read_op_80 <= `FALSE;
   end
   
   
   //--------------------------------------
   // RELEASE FORM DEEP POWER DOWN
   //--------------------------------------
   always @(posedge inhib_rfdp) 
   begin
   	rfdp <= `FALSE;
   	read_op <= `FALSE;
   	read_op_80 <= `FALSE;
   	dpd_enable <= `FALSE;
   	rfdpid <= `FALSE;
   	rdid_enable  <= `FALSE;
   end 
   
   
   //----------------------------------------------------------
   //  ERASE/PROGRAM SUSPEND INSTRUCTIONS
   //----------------------------------------------------------
   always @(posedge inhib_suspend)
   begin
      suspend <= `FALSE ;
   end 

   always @(negedge select_ok)	
   begin
     if(suspend && ((byte_cpt==0 && cpt==7) || (byte_cpt==1 && cpt==0)) && byte_ok )
     begin
      pp <= `FALSE;
      quadpgm <= `FALSE; 
      otppgm <= `FALSE;
      otpers <= `FALSE;
      ser <= `FALSE;
      ber32 <= `FALSE;
      ber64 <= `FALSE;
      
      suspend_add <= cut_add;
      if(suspend_pp)	        
	begin
	ppi_time = $realtime;
	pps_time_add <= pps_time_add+(ppi_time - pps_time);
	end
      if(suspend_quadpgm)	
	begin
	quadpgmi_time = $realtime; 	
	quadpgms_time_add <= quadpgms_time_add+(quadpgmi_time - quadpgms_time);
	end
      if(suspend_otppgm)
	begin
	otppgmi_time = $realtime;
	otppgms_time_add <= otppgms_time_add+(otppgmi_time - otppgms_time);
	end
      if(suspend_otpers)	
	begin
	otpersi_time = $realtime;
	otperss_time_add <= otperss_time_add+(otpersi_time - otperss_time);
	end
      if(suspend_ser)	       
	begin
	seri_time = $realtime;
	ser_time_add <= ser_time_add+(seri_time - ser_time);
	end
      if(suspend_ber32)	        
	begin
	beri32_time = $realtime;
	ber32_time_add <= ber32_time_add+(beri32_time - ber32_time);
	end
      if(suspend_ber64)  	
	begin
	beri64_time = $realtime;
	ber64_time_add <= ber64_time_add+(beri64_time - ber64_time);
	end 
     end
   end
  
    always @(posedge suspend_enable)
    begin
    	pp_enable <= `FALSE;
    	quadpgm_enable <= `FALSE;  
        otppgm_enable <= `FALSE;
        otpers_enable_ctl <= `FALSE;
    	ser_enable_ctl <= `FALSE;
    	ber32_enable_ctl <= `FALSE;
    	ber64_enable_ctl <= `FALSE;
	disable ers_pgm_resume_process;	
    end
   //----------------------------------------------------------
   //  ERASE/PROGRAM RESUME INSTRUCTIONS
   //----------------------------------------------------------
always @(posedge inhib_resume)
   begin
      resume <= `FALSE ; 
      if(resume_enable)
        begin
      	suspend_pp <= `FALSE;
      	suspend_quadpgm <= `FALSE;  
        suspend_otppgm <= `FALSE;
        suspend_otpers <= `FALSE;      	    	
      	suspend_ser <= `FALSE;
      	suspend_ber32 <= `FALSE;
      	suspend_ber64 <= `FALSE; 
        end
      resume_enable <= `FALSE ;	
end

 
   //--------------------------------------------------------
   //--------------- SYNCHRONOUS PROCESS  ----------------
   //--------------------------------------------------------
      //-------------------------------------------
      // READ_data
      //-------------------------------------------
 
   always 
      @(select_ok)
      begin
         if ((!read_data) && (!fast_read) && (!otprd)  && (!dofr)  && (!diofr)  &&(!manu_device_id_dual)&& (!qofr) && (!qiofr) && (!manu_device_id_quad) && (!qiowfr)  )
         begin
            inhib_read <= `FALSE ; 
         end 
         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || ((byte_cpt == 3) && (cpt != 7))) && read_data && (!select_ok))
         begin
            inhib_read <= `TRUE ; 
            bit_index <= 8'b00000000; 
         end 
         if (read_data && (((byte_cpt == 3) && (cpt == 7)) || (byte_cpt >= 4)))
         begin
            if (!select_ok)
            begin
               inhib_read <= `TRUE ; 
               bit_index <= 8'b00000000; 
               q_bis <= #`TSHQZ 1'bz ; 
            end
         end
     end
  
   always 
   @(negedge c_int)
   begin
      if (read_data && (((byte_cpt == 3) && (cpt == 7)) || (byte_cpt >= 4)) && (!suspend_enable))
      begin
         if (select_ok)
         begin
            d_bis <= #`TSHQZ 1'bz ;
            if(flag_80M)
	    begin
            	q_bis <= #`TCLQV 1'bx ; 
	    end
	    else
            begin
                q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
            end
            wp_bis <= #`TSHQZ 1'bz ;
            hold_bis <= #`TSHQZ 1'bz ;
            bit_index <= bit_index + 1; 
         end 
      end
      else if (read_data && (((byte_cpt == 3) && (cpt == 7)) || (byte_cpt >= 4)) && (suspend_enable) && (select_ok))
      begin
      	 
         if ((suspend_pp || suspend_quadpgm ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:8] == adress_2))
         begin
            d_bis <= #`TSHQZ 1'bx ;
            bit_index <= 8'b00000000; 
            q_bis <=  #`TSHQZ 1'bx; 
            wp_bis <= #`TSHQZ 1'bx ;
            hold_bis <= #`TSHQZ 1'bx ;
            if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
         end
         else if ((suspend_pp || suspend_quadpgm  ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:8] !== adress_2)))
         begin
            d_bis <= #`TSHQZ 1'bz ;
            if(flag_80M)
	    begin
            	q_bis <= #`TCLQV 1'bx ; 
	    end
	    else
            begin
                q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
            end
            wp_bis <= #`TSHQZ 1'bz ;
            hold_bis <= #`TSHQZ 1'bz ;
            bit_index <= bit_index + 1; 
         end 
          
         if ((suspend_ser ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:12] == adress_2[7:4]))
         begin
            bit_index <= 8'b00000000; 
            d_bis <= #`TSHQZ 1'bx ;
            q_bis <=  #`TSHQZ 1'bx;
            wp_bis <= #`TSHQZ 1'bx ;
            hold_bis <= #`TSHQZ 1'bx ;
            if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
         end
         else if ((suspend_ser ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:12] !== adress_2[7:4])))
         begin
            d_bis <= #`TSHQZ 1'bz ;
            if(flag_80M)
	    begin
            	q_bis <= #`TCLQV 1'bx ; 
	    end
	    else
            begin
                q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
            end
            wp_bis <= #`TSHQZ 1'bz ;
            hold_bis <= #`TSHQZ 1'bz ;
            bit_index <= bit_index + 1; 
         end 
        
         if (suspend_ber32 && (suspend_add[23:15] == {adress_1[7:0],adress_2[7]}) )
         begin
            bit_index <= 8'b00000000; 
            d_bis <= #`TSHQZ 1'bx ;
            q_bis <=  #`TSHQZ 1'bx;
            wp_bis <= #`TSHQZ 1'bx ;
            hold_bis <= #`TSHQZ 1'bx ; 
            if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
         end
         else  if (suspend_ber32 && (suspend_add[23:15] !== {adress_1[7:0],adress_2[7]}) )
         begin
            d_bis <= #`TSHQZ 1'bz ;
            if(flag_80M)
	    begin
            	q_bis <= #`TCLQV 1'bx ; 
	    end
	    else
            begin
                q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
            end
            wp_bis <= #`TSHQZ 1'bz ;
            hold_bis <= #`TSHQZ 1'bz ;
            bit_index <= bit_index + 1; 
         end         
        
         if (suspend_ber64 && (suspend_add[23:16] == adress_1[7:0]))
         begin
            bit_index <= 8'b00000000; 
            d_bis <= #`TSHQZ 1'bx ;
            q_bis <=  #`TSHQZ 1'bx;
            wp_bis <= #`TSHQZ 1'bx ;
            hold_bis <= #`TSHQZ 1'bx ; 
            if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
         end
         else  if (suspend_ber64 && (suspend_add[23:16] !== adress_1[7:0]))
         begin
            d_bis <= #`TSHQZ 1'bz ;
            if(flag_80M)
	    begin
            	q_bis <= #`TCLQV 1'bx ; 
	    end
	    else
            begin
                q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
            end
            wp_bis <= #`TSHQZ 1'bz ;
            hold_bis <= #`TSHQZ 1'bz ; 
            bit_index <= bit_index + 1; 
         end 
         
         if (suspend_otpers || suspend_otppgm )
         begin
            d_bis <= #`TSHQZ 1'bz ;
            if(flag_80M)
	    begin
            	q_bis <= #`TCLQV 1'bx ; 
	    end
	    else
            begin
                q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
            end
            wp_bis <= #`TSHQZ 1'bz ;
            hold_bis <= #`TSHQZ 1'bz ; 
            bit_index <= bit_index + 1; 
         end  
         
                       
      end
   end

      //------------------------------------------------------------------
      // Fast_Read
      //------------------------------------------------------------------
   always 
      @(select_ok)
      begin
         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || ((byte_cpt == 4) && (cpt != 7))) && fast_read && (!select_ok))
         begin
            inhib_read <= `TRUE ; 
            bit_index <= 8'b00000000; 
         end 
         if (fast_read && (((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5)))
         begin
            if (!select_ok)
            begin
               inhib_read <= `TRUE ; 
               bit_index <= 8'b00000000; 
               q_bis <= #`TSHQZ 1'bz ; 
               
            end
         end
      end
  
   always 
      @(negedge c_int)
      begin
         if (fast_read && (((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5)) && (!suspend_enable))
         begin
            if (select_ok)
            begin
               d_bis <= #`TSHQZ 1'bz ;
               if(flag_120M)
	       begin
            	   q_bis <= #`TCLQV 1'bx ; 
	       end
	       else
               begin
                   q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
               end
               wp_bis <= #`TSHQZ 1'bz ;
               hold_bis <= #`TSHQZ 1'bz ;
               bit_index <= bit_index + 1 ;
            end 
         end
         else if (fast_read && (((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5)) && (suspend_enable) && (select_ok))
         begin
      	   
            if ((suspend_pp || suspend_quadpgm ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:8] == adress_2))
            begin
            	bit_index <= 8'b00000000; 
            	d_bis <= #`TSHQZ 1'bx ;
                q_bis <=  #`TSHQZ 1'bx;
                wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ;  
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_pp || suspend_quadpgm ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:8] !== adress_2)))
            begin
            	d_bis <= #`TSHQZ 1'bz ;
                if(flag_120M)
	        begin
                    q_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
            	bit_index <= bit_index + 1; 
            end 
            
            if ((suspend_ser ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:12] == adress_2[7:4]))
            begin
            	
            	bit_index <= 8'b00000000; 
            	d_bis <= #`TSHQZ 1'bx ;
                q_bis <=  #`TSHQZ 1'bx;
                wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ;   
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_ser ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:12] !== adress_2[7:4])))
            begin
            	d_bis <= #`TSHQZ 1'bz ;
            	if(flag_120M)
	        begin
                    q_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
                end
            	wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
            	bit_index <= bit_index + 1; 
            end 
           
             if (suspend_ber32 && (suspend_add[23:15] == {adress_1[7:0],adress_2[7]}) )
            begin
            
                bit_index <= 8'b00000000; 
                d_bis <= #`TSHQZ 1'bx ;
                q_bis <=  #`TSHQZ 1'bx;
                wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ; 
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else  if (suspend_ber32 && (suspend_add[23:15] !== {adress_1[7:0],adress_2[7]}) )
            begin
                d_bis <= #`TSHQZ 1'bz ;
                if(flag_120M)
	        begin
                    q_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <= bit_index + 1; 
            end         
        
         if (suspend_ber64 && (suspend_add[23:16] == adress_1[7:0]))
         begin
                bit_index <= 8'b00000000; 
                d_bis <= #`TSHQZ 1'bx ;
                q_bis <=  #`TSHQZ 1'bx;
                wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ; 
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
         end
         else  if (suspend_ber64 && (suspend_add[23:16] !== adress_1[7:0]))
         begin
                d_bis <= #`TSHQZ 1'bz ;
                if(flag_120M)
	        begin
                    q_bis <= #`TCLQV 1'bx ; 
	        end
                else
                begin
                    q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <= bit_index + 1; 
         end 
         
         if (suspend_otpers || suspend_otppgm )
         begin
                d_bis <= #`TSHQZ 1'bz ;
                if(flag_120M)
	        begin
                    q_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ; 
                bit_index <= bit_index + 1; 
         end  
                 
         end
     end
        
 
      //------------------------------------------------------------------
      // OTP_Read
      //------------------------------------------------------------------
   always 
      @(select_ok)
      begin
         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || ((byte_cpt == 4) && (cpt != 7))) && otprd && (!select_ok))
         begin
            inhib_read <= `TRUE ; 
            bit_index <= 8'b00000000; 
         end 
         if (otprd && (((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5)))
         begin
            if (!select_ok)
            begin
               inhib_read <= `TRUE ; 
               bit_index <= 8'b00000000; 
               q_bis <= #`TSHQZ 1'bz ; 
               
            end
         end
      end
  
   always 
      @(negedge c_int)
      begin
         if (otprd && (((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5)) && (!suspend_enable))
         begin
            if (select_ok)
            begin
               d_bis <= #`TSHQZ 1'bz ;
               if(flag_120M)
	        begin
                    q_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
                end
               wp_bis <= #`TSHQZ 1'bz ;
               hold_bis <= #`TSHQZ 1'bz ;
               bit_index <= bit_index + 1 ;
            end 
         end
         else if (otprd && (((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5)) && (suspend_enable) && (select_ok))
         begin
      	   
               
             if (suspend_otppgm) 
              begin 
                if (suspend_add[9:8] == adress_2[1:0])                       
                   begin
                   bit_index <= 8'b00000000; 
                   d_bis <= #`TSHQZ 1'bx ;
                   q_bis <=  #`TSHQZ 1'bx;
                   wp_bis <= #`TSHQZ 1'bx ;
                   hold_bis <= #`TSHQZ 1'bx ;  
                   if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
                   end
            
                else if (suspend_add[9:8] !== adress_2[1:0])
                   begin
                   d_bis <= #`TSHQZ 1'bz ;
                   if(flag_120M)
	           begin
                       q_bis <= #`TCLQV 1'bx ; 
	           end
	           else
                   begin
                       q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
                   end
                   wp_bis <= #`TSHQZ 1'bz ;
                   hold_bis <= #`TSHQZ 1'bz ;
                   bit_index <= bit_index + 1; 
                   end  
                end                      
             else if (suspend_otpers) 
               begin               	
                   bit_index <= 8'b00000000; 
               	   d_bis <= #`TSHQZ 1'bx ;
                   q_bis <=  #`TSHQZ 1'bx;
                   wp_bis <= #`TSHQZ 1'bx ;
                   hold_bis <= #`TSHQZ 1'bx ;   
                   if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
               end
            else 
              begin
                   d_bis <= #`TSHQZ 1'bz ;
                   if(flag_120M)
	           begin
                       q_bis <= #`TCLQV 1'bx ; 
	           end
	           else
                   begin
                       q_bis <= #`TCLQV data_to_read[7 - bit_index] ; 
                   end
                   wp_bis <= #`TSHQZ 1'bz ;
                   hold_bis <= #`TSHQZ 1'bz ;
                   bit_index <= bit_index + 1 ;
              end        
                 
         end
     end
         
 
     
      //------------------------------------------------------------------
      // DOFR
      //------------------------------------------------------------------
   always 
      @(select_ok)
      begin
         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || ((byte_cpt == 4) && (cpt != 7))) && dofr && (!select_ok))
         begin
            inhib_read <= `TRUE ; 
            bit_index <= 8'b00000000; 
         end 
         if (dofr && (((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5)))
         begin
            if (!select_ok)
            begin
               inhib_read <= `TRUE ; 
               bit_index <= 8'b00000000; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
               wp_bis <= #`TSHQZ 1'bz ;
               hold_bis <= #`TSHQZ 1'bz ;
            end
         end
      end

 
   always 
      @(negedge c_int)
      begin
         if (dofr && read_enable && ( ((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5) ) && (!suspend_enable))
         begin
            if (select_ok)
            begin
               if(flag_120M)
	       begin
                   q_bis <= #`TCLQV 1'bx ; 
                   d_bis <= #`TCLQV 1'bx ; 
	       end
	       else
               begin
                   q_bis <= #`TCLQV data_to_read[7 - bit_index *2 ] ; 
                   d_bis <= #`TCLQV data_to_read[6 - bit_index *2 ] ;
               end
               wp_bis <= #`TSHQZ 1'bz ;
               hold_bis <= #`TSHQZ 1'bz ;
               bit_index <=  bit_index + 1 ;
               if (bit_index == 3)
               begin
               bit_index <=  0 ;
               end 
              
              end
             
         end
         else if (dofr && (((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5)) && (suspend_enable) && (select_ok))
         begin
      	   
            if ((suspend_pp || suspend_quadpgm  ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:8] == adress_2))
            begin
            	bit_index <= 8'b00000000; 
            	d_bis <= #`TSHQZ 1'bx ;
                q_bis <=  #`TSHQZ 1'bx;
                wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_pp || suspend_quadpgm  ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:8] !== adress_2)))	
            begin
                if(flag_120M)
	        begin
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[7 - bit_index *2 ] ; 
                    d_bis <= #`TCLQV data_to_read[6 - bit_index *2 ] ;
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <=  bit_index + 1 ;
                if (bit_index == 3)
                begin
                bit_index <=  0;
                end
            end 
            
            if ((suspend_ser ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:12] == adress_2[7:4]))
            begin
            	bit_index <= 8'b00000000; 
            	d_bis <= #`TSHQZ 1'bx ;
                q_bis <=  #`TSHQZ 1'bx;
                wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_ser ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:12] !== adress_2[7:4])))
            begin
                if(flag_120M)
	        begin
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[7 - bit_index *2 ] ; 
                    d_bis <= #`TCLQV data_to_read[6 - bit_index *2 ] ;
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <=  bit_index + 1 ;
                if (bit_index == 3)
                begin
                bit_index <=   0;
                end 
            end 
           
             if (suspend_ber32 && (suspend_add[23:15] == ({adress_1[7:0],adress_2[7]}) ))
            begin
            	bit_index <= 8'b00000000; 
            	d_bis <= #`TSHQZ 1'bx ;
                q_bis <=  #`TSHQZ 1'bx;
                wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else  if (suspend_ber32 && (suspend_add[23:15] !== ({adress_1[7:0],adress_2[7]}) ) )
            begin
                if(flag_120M)
	        begin
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[7 - bit_index *2 ] ; 
                    d_bis <= #`TCLQV data_to_read[6 - bit_index *2 ] ;
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <=  bit_index + 1 ;
                if (bit_index == 3)
                begin
                bit_index <=  0;
                end  
            end 
            
           if (suspend_ber64 && (suspend_add[23:16] == adress_1[7:0]) )
           begin 
                bit_index <= 8'b00000000; 
                d_bis <= #`TSHQZ 1'bx ;
                q_bis <=  #`TSHQZ 1'bx;
                wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ; 
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
           end
         else  if (suspend_ber64 && (suspend_add[23:16] !== adress_1[7:0]))
         begin
                if(flag_120M)
	        begin
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[7 - bit_index *2 ] ; 
                    d_bis <= #`TCLQV data_to_read[6 - bit_index *2 ] ;
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <= bit_index + 1; 
                if (bit_index == 3)
                begin
                bit_index <=  0;
                end  
         end 
         
         if (suspend_otpers  || suspend_otppgm)
         begin
                if(flag_120M)
	        begin
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[7 - bit_index *2 ] ; 
                    d_bis <= #`TCLQV data_to_read[6 - bit_index *2 ] ;
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <= bit_index + 1; 
                if (bit_index == 3)
                begin
                bit_index <=  0;
                end  
         end                   
   end  
   
  end
     
     always 
      @(negedge c_int)
      begin
         if (dofr && read_enable)
         begin
            if (cpt==3)
            begin
              cpt<= 0 ;
             end
           end
       end
     
      always 
      @(posedge c_int)
      begin
         if (dofr && read_enable)
         begin
            if (cpt==3)
            begin
              byte_ok <= `TRUE ;
             end
           end
       end
     
      //------------------------------------------------------------------
      // QOFR
      //------------------------------------------------------------------

   always 
      @(select_ok)
      begin
         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || ((byte_cpt == 4) && (cpt != 7))) && qofr && (!select_ok))
         begin
            inhib_read <= `TRUE ; 
            bit_index <= 8'b00000000; 
         end 
         if (qofr && (((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5)))
         begin
            if (!select_ok)
            begin
               inhib_read <= `TRUE ; 
               bit_index <= 8'b00000000; 
               hold_bis<= #`TSHQZ 1'bz ; 
               wp_bis<= #`TSHQZ 1'bz ; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
                
            end
         end
      end
         
   always 
      @(negedge c_int)
      begin
         if (qofr &&  (((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5)) && (!suspend_enable))
         begin
            if (select_ok)
            begin
                if(flag_120M)
	        begin
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
               bit_index <=  bit_index + 1 ;
               if (bit_index ==1)
               begin
               bit_index <=  0;
               end

            end 
         end
         else if (qofr && (((byte_cpt == 4) && (cpt == 7)) || (byte_cpt >= 5)) && (suspend_enable) && (select_ok))
         begin
      	   
            if ((suspend_pp || suspend_quadpgm  ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:8] == adress_2))
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_pp || suspend_quadpgm  ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:8] !== adress_2)))
            begin
               if(flag_120M)
	        begin
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
               bit_index <=  bit_index + 1 ;
               if (bit_index == 1)
               begin
               bit_index <=  0;
               end
            end 
            
            if ((suspend_ser ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:12] == adress_2[7:4]))
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_ser ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:12] !== adress_2[7:4])))
            begin
                if(flag_120M)
	        begin
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <=  bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <= 0;
                end
            end 
           
             if (suspend_ber32 && (suspend_add[23:15] == ( {adress_1[7:0],adress_2[7]} )) )
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else  if (suspend_ber32 && (suspend_add[23:15] !== {adress_1[7:0],adress_2[7]}) )
            begin
                if(flag_120M)
	        begin
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <=   bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <=   0;
                end
            end 
            if (suspend_ber64 && (suspend_add[23:16] == adress_1[7:0]))
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else  if (suspend_ber64 && (suspend_add[23:16] !== adress_1[7:0]))
            begin
                if(flag_120M)
	        begin
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <=   bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <=   0;
                end
            end 
            
           if (suspend_otpers  || suspend_otppgm)
            begin
                if(flag_120M)
	        begin
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
               bit_index <=   bit_index + 1 ;
               if (bit_index == 1)
               begin
               bit_index <=   0;
               end
            end  
         end
     end
         
      always 
      @(negedge c_int)
      begin
         if (qofr && (read_enable))
         begin
            if (cpt==1)
            begin
             cpt<= 0 ;
             end
           end
       end
       
        always 
      @(posedge c_int)
      begin
         if (qofr && (read_enable))
         begin
            if (cpt==1)
            begin
             byte_ok <= `TRUE ;
             end
           end
       end
    
      //------------------------------------------------------------------
      // DIOFR
      //------------------------------------------------------------------
   always 
      @(select_ok)
      begin
      	 
         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || ((byte_cpt == 4) && (cpt != 3))) && (diofr || manu_device_id_dual) && (!select_ok) && (!crmr))
         begin
            inhib_read <= `TRUE ; 
            bit_index <= 8'b00000000; 
         end 
        if ((diofr || manu_device_id_dual) && (((byte_cpt == 4) && (cpt == 3)) || (byte_cpt >= 5)))
         begin
            if ((!select_ok) && (!diofr_crm_flag))
            begin
               inhib_read <= `TRUE ; 
               bit_index <= 8'b00000000; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
               wp_bis <= #`TSHQZ 1'bz ;
               hold_bis <= #`TSHQZ 1'bz ;
	       diofr_crm_read <=`FALSE;	
            end
            if ((!select_ok) && (diofr_crm_flag))
            begin
               read_enable <= `FALSE;
               read_enable_2 <= `FALSE;
               read_enable_4 <= `FALSE;
               bit_index <= 8'b00000000; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
               wp_bis <= #`TSHQZ 1'bz ;
               hold_bis <= #`TSHQZ 1'bz ;
	       diofr_crm_read <=`FALSE;	
            end             
         end
        if (diofr && ((byte_cpt == 4) && (cpt == 3)) && (!select_ok))
         begin
               crm_bit[7:0] <= 8'h00;
         end
      end
  
   always 
      @(negedge c_int)
      begin
      	 
         if (diofr_crm_read && (!suspend_enable))
         begin
            if (select_ok)
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[ 7 - bit_index * 2 ] ; 
                    d_bis <= #`TCLQV data_to_read[ 6 - bit_index * 2 ] ;
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <= bit_index + 1 ;
                if (bit_index == 3)
                begin
                bit_index <= 0;
                end
            end 
         end
         
         else if (diofr_crm_read && (suspend_enable) && (select_ok))
         begin
      	   
            if ((suspend_pp || suspend_quadpgm  ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:8] == adress_2))
            begin
            	bit_index <= 8'b00000000; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
            	wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_pp || suspend_quadpgm ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:8] !== adress_2)))
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[ 7 - bit_index * 2 ] ; 
                    d_bis <= #`TCLQV data_to_read[ 6 - bit_index * 2 ] ;
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <= bit_index + 1 ;
                if (bit_index == 3)
                begin
                bit_index <= 0;
                end
            end 
            
            if ((suspend_ser ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:12] == adress_2[7:4]))
            begin
            	
            	bit_index <= 8'b00000000; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
            	wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_ser) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:12] !== adress_2[7:4])))
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[ 7 - bit_index * 2 ] ; 
                    d_bis <= #`TCLQV data_to_read[ 6 - bit_index * 2 ] ;
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <= bit_index + 1 ;
                if (bit_index == 3)
                begin
                bit_index <= 0;
                end 
            end 
           
             if (suspend_ber32 && (suspend_add[23:15] == ( {adress_1[7:0],adress_2[7]} )) )
            begin
            	bit_index <= 8'b00000000; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
            	wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else  if (suspend_ber32 && (suspend_add[23:15] !== {adress_1[7:0],adress_2[7]}) )
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[ 7 - bit_index * 2 ] ; 
                    d_bis <= #`TCLQV data_to_read[ 6 - bit_index * 2 ] ;
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <= bit_index + 1 ;
                if (bit_index == 3)
                begin
                bit_index <= 0;
                end  
            end 
            
              if (suspend_ber64 && (suspend_add[23:16] == adress_1[7:0]))
            begin
            	bit_index <= 8'b00000000; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
            	wp_bis <= #`TSHQZ 1'bx ;
                hold_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else  if (suspend_ber64 && (suspend_add[23:16] !== adress_1[7:0]))
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[ 7 - bit_index * 2 ] ; 
                    d_bis <= #`TCLQV data_to_read[ 6 - bit_index * 2 ] ;
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <= bit_index + 1 ;
                if (bit_index == 3)
                begin
                bit_index <= 0;
                end  
            end 
            
            if (suspend_otpers  || suspend_otppgm)
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    q_bis <= #`TCLQV data_to_read[ 7 - bit_index * 2 ] ; 
                    d_bis <= #`TCLQV data_to_read[ 6 - bit_index * 2 ] ;
                end
                wp_bis <= #`TSHQZ 1'bz ;
                hold_bis <= #`TSHQZ 1'bz ;
                bit_index <= bit_index + 1 ;
                if (bit_index == 3)
                begin
                bit_index <= 0;
                end  
            end 
            
         end
     end
     
     always 
      @(negedge c_int)
      begin
         if (diofr  && read_enable)
         begin
            if (cpt==3)
            begin
              cpt<= 0 ;
             end
           end
       end
     
      always 
      @(posedge c_int)
      begin
         if (diofr && read_enable)
         begin
            if (cpt==3)
            begin
              byte_ok <= `TRUE  ;
             end
         end
         
         if (diofr && (((byte_cpt == 4) && (cpt == 3)) || (byte_cpt >= 5)) && (!diofr_crm_flag))
         	diofr_crm_read <= `TRUE;
         else
         if (diofr && (((byte_cpt == 3) && (cpt == 3)) || (byte_cpt >= 4)) && (diofr_crm_flag))
         	diofr_crm_read <= `TRUE;
         else
         	diofr_crm_read <= `FALSE;
       end
    
      //------------------------------------------------------------------
      // Manufacturer/Device ID by Dual I/O
      //------------------------------------------------------------------
   always 
      @(select_ok)
      begin
	if (!manu_device_id_dual )
         begin
            inhib_manu_device_id_dual <= `FALSE;
            bit_index <= 8'b00000000; 
         end   
      	 
         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || ((byte_cpt == 4) && (cpt != 3))) && manu_device_id_dual && (!select_ok) && (!crmr))
         begin
            inhib_read <= `TRUE ; 
            bit_index <= 8'b00000000; 
         end 
        if (manu_device_id_dual && (((byte_cpt == 4) && (cpt == 3)) || (byte_cpt >= 5)))
         begin
            if ((!select_ok) && (!manu_device_id_dual_crm_flag))
            begin
               inhib_read <= `TRUE ; 
               bit_index <= 8'b00000000; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
               wp_bis <= #`TSHQZ 1'bz ;
               hold_bis <= #`TSHQZ 1'bz ;
               manu_device_id_dual_crm_read <= `FALSE;
            end
            if ((!select_ok) && (manu_device_id_dual_crm_flag))
            begin
               read_enable <= `FALSE;
               read_enable_2 <= `FALSE;
               read_enable_4 <= `FALSE;
               bit_index <= 8'b00000000; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
               wp_bis <= #`TSHQZ 1'bz ;
               hold_bis <= #`TSHQZ 1'bz ;
               manu_device_id_dual_crm_read <= `FALSE;
            end
         end
        if (manu_device_id_dual && ((byte_cpt == 4) && (cpt == 3)) && (!select_ok))
         begin
               crm_bit[7:0] <= 8'h00;
         end
      end
 
   always 
      @(negedge c_int)
      begin
         if (manu_device_id_dual_crm_read)
         begin
            if (select_ok)
            begin
		if(adress_3[0] == 1'b0)
		begin
                    if(flag_120M)
                    begin
               	        q_bis <= #`TCLQV 1'bx; 
               	        d_bis <= #`TCLQV 1'bx;
                    end
                    else
                    begin
               	        q_bis <= #`TCLQV did0[ 15 - bit_index * 2 ] ; 
               	        d_bis <= #`TCLQV did0[ 14 - bit_index * 2 ] ;
                    end
                    wp_bis <= #`TSHQZ 1'bz ;
                    hold_bis <= #`TSHQZ 1'bz ;
		end
             	else if (adress_3[0] == 1'b1)
		begin
                    if(flag_120M)
                    begin
               	        q_bis <= #`TCLQV 1'bx; 
               	        d_bis <= #`TCLQV 1'bx;
                    end
                    else
                    begin
               	        q_bis <= #`TCLQV did1[ 15 - bit_index * 2 ] ; 
               	        d_bis <= #`TCLQV did1[ 14 - bit_index * 2 ] ;
                    end
               	    wp_bis <= #`TSHQZ 1'bz ;
               	    hold_bis <= #`TSHQZ 1'bz ;
		end
             	else
             	begin
             	    d_bis <= #`TSHQZ 1'bz;
             	    q_bis <= #`TSHQZ 1'bz;
              	    wp_bis <= #`TSHQZ 1'bz ;
               	    hold_bis <= #`TSHQZ 1'bz ;
             	end 

                bit_index <= bit_index + 1 ;
                if (bit_index == 7)
                begin
                    bit_index <= 0;
                end
            end 
         end
     end
     
     always 
      @(negedge c_int)
      begin
         if (manu_device_id_dual && read_enable)
         begin
            if (cpt==3)
            begin
              cpt<= 0 ;
             end
           end
       end
     
      always 
      @(posedge c_int)
      begin
         if (manu_device_id_dual && read_enable)
         begin
            if (cpt==3)
            begin
              byte_ok <= `TRUE  ;
             end
         end
         
         if (manu_device_id_dual && (((byte_cpt == 4) && (cpt == 3)) || (byte_cpt >= 5)) && (!manu_device_id_dual_crm_flag))
         	manu_device_id_dual_crm_read <= `TRUE;
         else
         if (manu_device_id_dual && (((byte_cpt == 3) && (cpt == 3)) || (byte_cpt >= 4)) && (manu_device_id_dual_crm_flag))
         	manu_device_id_dual_crm_read <= `TRUE;
         else
         	manu_device_id_dual_crm_read <= `FALSE;
         
       end
    
    
   always @(posedge inhib_manu_device_id_dual) 
   begin
   	manu_device_id_dual <= `FALSE;
   	read_op <= `FALSE;
   	read_op_80 <= `FALSE;
   	rdid_enable  <= `FALSE;
   end

  always @(posedge inhib_manu_device_id_quad) 
   begin
   	manu_device_id_quad <= `FALSE;
   	read_op <= `FALSE;
   	read_op_80 <= `FALSE;
   	rdid_enable  <= `FALSE;
   end
    
      //------------------------------------------------------------------
      // Manufacturer/Device ID by Quad I/O
      //------------------------------------------------------------------
   always 
      @(select_ok)
      begin
	 if (!manu_device_id_quad )
         begin
            inhib_manu_device_id_quad <= `FALSE;
            bit_index <= 1'b0;
         end  

         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || (byte_cpt == 4) || (byte_cpt == 5)|| ((byte_cpt == 6)&& (cpt != 1))) && manu_device_id_quad && (!select_ok) &&(!crmr))
         begin
            inhib_read <= `TRUE ; 
            bit_index <= 8'b00000000; 
         end 

         if (((byte_cpt == 3) || (byte_cpt == 4) || (byte_cpt == 5)|| ((byte_cpt == 6)&& (cpt != 1))) && manu_device_id_quad && (!select_ok) &&(!crmr))
         begin
            crm_bit[7:0] <= 8'h00;
         end 

         if (manu_device_id_quad && (((byte_cpt == 6) && (cpt == 1)) || (byte_cpt >= 7)))
         begin
            if ((!select_ok) && (!manu_device_id_quad_crm_flag))
            begin
               inhib_read <= `TRUE ; 
               bit_index <= 8'b00000000; 
               hold_bis<= #`TSHQZ 1'bz ; 
               wp_bis<= #`TSHQZ 1'bz ; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
               manu_device_id_quad_crm_read <= `FALSE;
               
            end
            if ((!select_ok) && (manu_device_id_quad_crm_flag))
            begin
               read_enable <= `FALSE;
               read_enable_2 <= `FALSE;
               read_enable_4 <= `FALSE;
               bit_index <= 8'b00000000; 
               hold_bis<= #`TSHQZ 1'bz ; 
               wp_bis<= #`TSHQZ 1'bz ; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
               manu_device_id_quad_crm_read <= `FALSE;
               
            end
         end
      end
 
   always 
      @(negedge c_int)
      begin
         
         if (manu_device_id_quad_crm_read)
         begin
            if (select_ok)
            begin
            	if(adress_3[0] == 1'b0)
		begin
                    if(flag_120M)
                    begin
            	        hold_bis <= #`TCLQV 1'bx;
            	        wp_bis <= #`TCLQV 1'bx;
            	        q_bis <= #`TCLQV 1'bx;
            	        d_bis <= #`TCLQV 1'bx;
                    end
                    else
                    begin
                        hold_bis <= #`TCLQV did0[15 - bit_index*4] ;
            	        wp_bis <= #`TCLQV did0[14 - bit_index*4] ;
            	        q_bis <= #`TCLQV did0[13 - bit_index*4] ; 
            	        d_bis <= #`TCLQV did0[12 - bit_index*4] ;
                    end
		end
             	else if (adress_3[0] == 1'b1)
		begin
               	    if(flag_120M)
                    begin
            	        hold_bis <= #`TCLQV 1'bx;
            	        wp_bis <= #`TCLQV 1'bx;
            	        q_bis <= #`TCLQV 1'bx;
            	        d_bis <= #`TCLQV 1'bx;
                    end
                    else
                    begin
                        hold_bis <= #`TCLQV did1[15 - bit_index*4] ;
            	        wp_bis <= #`TCLQV did1[14 - bit_index*4] ;
            	        q_bis <= #`TCLQV did1[13 - bit_index*4] ; 
            	        d_bis <= #`TCLQV did1[12 - bit_index*4] ;
                    end
		end
             	else
             	begin
             	    d_bis <= #`TSHQZ 1'bz;
             	    q_bis <= #`TSHQZ 1'bz;
              	    wp_bis <= #`TSHQZ 1'bz;
               	    hold_bis <= #`TSHQZ 1'bz;
             	end 

                bit_index <= bit_index + 1 ;
                if (bit_index == 3)
                begin
                    bit_index <= 0;
                end
            end 
         end
     end

     
 always 
      @(negedge c_int)
      begin
         if (manu_device_id_quad && (read_enable))
         begin
            if (cpt==1)
            begin
             cpt<= 0 ;
             end
           end
       end
       
 always 
      @(posedge c_int)
      begin
         if (manu_device_id_quad && (read_enable))
         begin
            if (cpt==1)
            begin
             byte_ok <= `TRUE  ;
             end
         end
         
         if (manu_device_id_quad && (((byte_cpt == 6) && (cpt == 1)) || (byte_cpt >= 7)) && (!manu_device_id_quad_crm_flag) )
         	manu_device_id_quad_crm_read <= `TRUE;

         else if (manu_device_id_quad && (((byte_cpt == 5) && (cpt == 1)) || (byte_cpt >= 6)) && (manu_device_id_quad_crm_flag))
	       	manu_device_id_quad_crm_read <= `TRUE;      
         else						       
         	manu_device_id_quad_crm_read <= `FALSE;
       end

    
      //------------------------------------------------------------------
      // QIOFR
      //------------------------------------------------------------------
   always 
      @(select_ok)
      begin
         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || (byte_cpt == 4) || (byte_cpt == 5)|| ((byte_cpt == 6)&& (cpt != 1))) && qiofr && (!select_ok) && (!crmr))
         begin
            inhib_read <= `TRUE ; 
            bit_index <= 8'b00000000; 
         end 

         if (((byte_cpt == 3) || (byte_cpt == 4) || (byte_cpt == 5)|| ((byte_cpt == 6)&& (cpt != 1))) && qiofr && (!select_ok) && (!crmr))
         begin
            crm_bit[7:0] <= 8'h00;
         end 

         if (qiofr && (((byte_cpt == 6) && (cpt == 1)) || (byte_cpt >= 7)))
         begin
            if ((!select_ok) && (!qiofr_crm_flag))
            begin
               inhib_read <= `TRUE ; 
               bit_index <= 8'b00000000; 
               hold_bis<= #`TSHQZ 1'bz ; 
               wp_bis<= #`TSHQZ 1'bz ; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
               qiofr_crm_read <=`FALSE;
            end
            if ((!select_ok) && (qiofr_crm_flag))
            begin
               read_enable <= `FALSE;
               read_enable_2 <= `FALSE;
               read_enable_4 <= `FALSE;
               bit_index <= 8'b00000000; 
               hold_bis<= #`TSHQZ 1'bz ; 
               wp_bis<= #`TSHQZ 1'bz ; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
	       qiofr_crm_read <=`FALSE;
            end
         end
      end
 
   always 
      @(negedge c_int)
      begin
         
         if (qiofr_crm_read && (!suspend_enable))
         begin
            if (select_ok)
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <= bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <= 0;
                end
            end 
         end
         else if (qiofr_crm_read && (suspend_enable) && (select_ok))
         begin
      	   
            if ((suspend_pp || suspend_quadpgm  ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:8] == adress_2))
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_pp || suspend_quadpgm  ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:8] !== adress_2)))
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <= bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <= 0;
                end
            end 
            
            if ((suspend_ser) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:12] == adress_2[7:4]))
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_ser ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:12] !== adress_2[7:4])))
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
               bit_index <= bit_index + 1 ;
               if (bit_index == 1)
               begin
               bit_index <= 0;
               end
            end 
           
            if (suspend_ber32 && (suspend_add[23:15] == ( {adress_1[7:0],adress_2[7]} )) )
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else  if (suspend_ber32 && (suspend_add[23:15] !== {adress_1[7:0],adress_2[7]}) )
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <= bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <= 0;
                end
            end 
             if (suspend_ber64 && (suspend_add[23:16] == adress_1[7:0]))
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else  if (suspend_ber64 && (suspend_add[23:16] !== adress_1[7:0]))
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <= bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <= 0;
                end
            end 
            
            if (suspend_otpers  || suspend_otppgm)
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <= bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <= 0;
                end
            end 
           
         end
     end

     
 always 
      @(negedge c_int)
      begin
         if (qiofr && (read_enable))
         begin
            if (cpt==1)
            begin
             cpt<= 0 ;
             end
           end
       end
       
 always 
      @(posedge c_int)
      begin
         if (qiofr && (read_enable))
         begin
            if (cpt==1)
            begin
             byte_ok <= `TRUE  ;
             end
         end
         
         if (qiofr && (((byte_cpt == 6) && (cpt == 1)) || (byte_cpt >= 7)) && (!qiofr_crm_flag))
	    begin							
         	qiofr_crm_read <= `TRUE;
	    end
         else
         if (qiofr && (((byte_cpt == 5) && (cpt == 1)) || (byte_cpt >= 6)) && (qiofr_crm_flag))
	    begin
         	qiofr_crm_read <= `TRUE;
	    end
         else
         	qiofr_crm_read <= `FALSE;
       end
     
     
      //------------------------------------------------------------------
      // QIOWFR
      //------------------------------------------------------------------
   always 
      @(select_ok)
      begin
         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || (byte_cpt == 4) ||  ((byte_cpt == 5)&& (cpt != 1))) && qiowfr && (!select_ok) && (!crmr))
         begin
            inhib_read <= `TRUE ; 
            bit_index <= 8'b00000000; 
         end 

         if (((byte_cpt == 3) || (byte_cpt == 4) ||  ((byte_cpt == 5)&& (cpt != 1))) && qiowfr && (!select_ok) && (!crmr))
         begin
            crm_bit[7:0] <= 8'h00;
         end 

         if (qiowfr && (((byte_cpt == 5) && (cpt == 1)) || (byte_cpt >= 6)))
         begin
            if ((!select_ok) && (!qiowfr_crm_flag))
            begin
               inhib_read <= `TRUE ; 
               bit_index <= 8'b00000000; 
               hold_bis<= #`TSHQZ 1'bz ; 
               wp_bis<= #`TSHQZ 1'bz ; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
	       qiowfr_crm_read <=`FALSE;
            end
            if ((!select_ok) && (qiowfr_crm_flag))
            begin
               read_enable <= `FALSE;
               read_enable_2 <= `FALSE;
               read_enable_4 <= `FALSE;
               bit_index <= 8'b00000000; 
               hold_bis<= #`TSHQZ 1'bz ; 
               wp_bis<= #`TSHQZ 1'bz ; 
               q_bis <= #`TSHQZ 1'bz ; 
               d_bis <= #`TSHQZ 1'bz ;
	       qiowfr_crm_read <=`FALSE;
            end
         end
      end
   
   always 
      @(negedge c_int)
      begin
         if (qiowfr_crm_read && (!suspend_enable))
         begin
            if (select_ok)
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
               bit_index <= bit_index + 1 ;
               if (bit_index == 1)
               begin
               bit_index <= 0;
               end
            end 
         end
         else if (qiowfr_crm_read && (suspend_enable) && (select_ok))
         begin
      	   
            if ((suspend_pp || suspend_quadpgm  ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:8] == adress_2))
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_pp || suspend_quadpgm ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:8] !== adress_2)))
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <= bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <= 0;
                end
            end 
            
            if ((suspend_ser ) && (suspend_add[23:16] == adress_1[7:0]) && (suspend_add[15:12] == adress_2[7:4]))
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
            else if ((suspend_ser ) && ((suspend_add[23:16] !== adress_1[7:0]) || (suspend_add[15:12] !== adress_2[7:4])))
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <= bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <= 0;
                end
            end 
           
           if (suspend_ber32 && (suspend_add[23:15] == ( {adress_1[7:0],adress_2[7]} )) )
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
           else  if (suspend_ber32 && (suspend_add[23:15] !== {adress_1[7:0],adress_2[7]}) )
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <= bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <= 0;
                end
            end 
            
             if (suspend_ber64 && (suspend_add[23:16] == adress_1[7:0]))
            begin
            	bit_index <= 8'b00000000; 
            	hold_bis <=  #`TSHQZ 1'bx; 
            	wp_bis <=  #`TSHQZ 1'bx; 
            	q_bis <=  #`TSHQZ 1'bx; 
            	d_bis <= #`TSHQZ 1'bx ;
                if ($time != 0) $display("%t:  WARNING : Read error because data is operated(program/erase) now!",$realtime); 
            end
           else  if (suspend_ber64 && (suspend_add[23:16] !== adress_1[7:0]))
            begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <= bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <= 0;
                end
            end 
            
            if (suspend_otpers  || suspend_otppgm)
             begin
                if(flag_120M)
	        begin
                    $display("%t Warning: This read command at High frequence! \n",$realtime);
                    hold_bis <= #`TCLQV 1'bx ; 
                    wp_bis <= #`TCLQV 1'bx ; 
                    q_bis <= #`TCLQV 1'bx ; 
                    d_bis <= #`TCLQV 1'bx ; 
	        end
	        else
                begin
                    hold_bis <= #`TCLQV data_to_read[7 - bit_index*4] ;
                    wp_bis <= #`TCLQV data_to_read[6 - bit_index*4] ;
                    q_bis <= #`TCLQV data_to_read[5 - bit_index*4] ; 
                    d_bis <= #`TCLQV data_to_read[4 - bit_index*4] ;
                end
                bit_index <= bit_index + 1 ;
                if (bit_index == 1)
                begin
                bit_index <= 0;
                end
            end 
            
         end
     end
        
     
 always 
      @(negedge c_int)
      begin
         if ( qiowfr && (read_enable))
         begin
            if (cpt==1)
            begin
             cpt<= 0 ;
             end
           end
       end
       
 always 
      @(posedge c_int)
      begin
         if ( qiowfr && (read_enable))
         begin
            if (cpt==1)
            begin
             byte_ok <= `TRUE  ;
             end
           end
         if (qiowfr && (((byte_cpt == 5) && (cpt == 1)) || (byte_cpt >= 6)) && (!qiowfr_crm_flag))
	    begin					
         	qiowfr_crm_read <= `TRUE;
	    end
         else if (qiowfr && (((byte_cpt == 4) && (cpt == 1)) || (byte_cpt >= 5)) && (qiowfr_crm_flag))
	    begin							
         	qiowfr_crm_read <= `TRUE;
	    end
         else
         	qiowfr_crm_read <= `FALSE;
       end
     
      //-----------------------------------------
      // CONTINUOUS READ MODE RESET
      //-----------------------------------------
   always 
      @(select_ok)
      begin
         if (!crmr)
         begin
            inhib_crmr <= `FALSE ; 
         end
         if (crmr && (!only_rdsr))
         begin
            if (
		(!select_ok) && 
	            ( 
	 	     (((byte_cpt==1 && cpt==3)||(byte_cpt==2 && cpt==0)) && byte_ok && (diofr || manu_device_id_dual))
	 	     || (((byte_cpt==3 && cpt==1)||(byte_cpt==4 && cpt==0)) && byte_ok && (qiofr||qiowfr))
	 	     || (((byte_cpt==3 && cpt==1)||(byte_cpt==4 && cpt==0)) && byte_ok && manu_device_id_quad) 
	            )
	       )
            begin
                if ($time != 0) $display("%t: NOTE : Continue Read Mode Reset.",$realtime);
		crm_bit = 8'h00;
                reset_crmr <= 1'b1;
               	inhib_crmr <= `TRUE ; 
            end
         end
      end

   always 
      @(posedge c_int)
      begin
         if (crmr && (!only_rdsr) && select_ok)
         begin
	    crmr <= `FALSE;
         end
      end 

      //-----------------------------------------
      // Write_enable 
      //-----------------------------------------
   always 
      @(select_ok)
      begin
         if (!wren)
         begin
            inhib_wren <= `FALSE ; 
         end
         if (wren && (!only_rdsr))
         begin
            if (!select_ok)
            begin
               wel <= 1'b1 ; 
               inhib_wren <= `TRUE; 
            end
         end
      end

   always 
      @(posedge c_int)
      begin
         if (wren && (!only_rdsr) && select_ok)
         begin
            inhib_wren <= `TRUE ; 
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
         end
      end
      
      //-----------------------------------------
      // Write_disable 
      //-----------------------------------------
   always 
      @(select_ok)
      begin
         if (!wrdi)
         begin
            inhib_wrdi <= `FALSE ; 
         end
         if (wrdi && (!only_rdsr))
         begin
            if (!select_ok)
            begin
               wel <= 1'b0 ; 
               inhib_wrdi <= `TRUE ; 
            end
         end
      end

   always 
      @(posedge c_int)
      begin
         if (wrdi && (!only_rdsr) && select_ok)
         begin
            inhib_wrdi <= `TRUE ; 
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
         end
      end
  
      //-------------------------------------------
      // WRSR PROCESS
      //-------------------------------------------

always @(select_ok)
   begin
      if (!wrsr)
      begin
         inhib_wrsr <= `FALSE ; 
      end 
     if (( (byte_cpt == 0) || (((byte_cpt == 1) || (byte_cpt==2)) && (!byte_ok)) ) && wrsr && (!only_rdsr))
      begin
         if (!select_ok) 
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            wrsr <= `FALSE;
         end 
      end 
      if ((  ((byte_cpt == 1) && (cpt == 7)) || ((byte_cpt == 2) && (cpt == 0)) || ((byte_cpt == 2)&& (cpt == 7)) || ((byte_cpt == 3) && (cpt == 0))  ) && byte_ok && wrsr && (!only_rdsr))   
           begin
         if (!select_ok) 
         begin
            if ((status_register[1]) == 1'b0)
            begin
               if ($time != 0) $display("%t:  WARNING : Instruction canceled because WEL is low",$realtime); 
               wrsr_enable <= `FALSE ; 
               inhib_wrsr <= `TRUE ; 
            end
             else 
            begin
             if(!wrsr_protect)
              begin
               if ($time != 0) $display("%t:  NOTE : wrsr cycle has begun",$realtime); 
               wrsr_enable <= `TRUE ; 
               reset_wel <= 1'b0 ;
               wip <= 1'b1 ;
               #`TW ;
               if ($time != 0) $display("%t:  NOTE : wrsr cycle is finished",$realtime); 
               wrsr_enable <= `FALSE ; 
               inhib_wrsr <= `TRUE ; 
               wip <= 1'b0 ; 
               reset_wel <= 1'b1 ; 
              end
             else
               begin
               if ($time != 0) $display("%t:  NOTE : this wrsr op protected,wrsr operation is inhibted",$realtime);
               wrsr <= `FALSE;
               end
            end
         end 
      end
   end
   
  
always @(posedge c_int)
   begin
      if ( ((byte_cpt == 3) || ((byte_cpt == 2) && (cpt == 7) && byte_ok)) && wrsr && (!only_rdsr))
      begin
         if (byte_cpt == 3 && select_ok)
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            wrsr <=`FALSE;
         end
      end
   end   

  
      //-------------------------------------------
      // CHIP_erase
      //-------------------------------------------

   always @(select_ok)
   begin
      if (!cer)
      begin
         inhib_cer <= `FALSE ; 
      end 
      if (cer && (!only_rdsr))
      begin
         if ((!select_ok) && (!resume_enable) )
         begin
            if ((status_register[1]) == 1'b0)
            begin
               if ($time != 0) $display("%t:  WARNING : Instruction canceled because WEL is low",$realtime); 
               cer_enable <= `FALSE ; 
               inhib_cer <= `TRUE ; 
            end
            else
        begin
              #2;
              if(!bpbit)
              begin
               if ($time != 0) $display("%t:  NOTE : Chip erase cycle has begun",$realtime); 
               cer_enable <= `TRUE ; 
               reset_wel <= 1'b0 ;
               wip <= 1'b1 ;
               for(j = 1; j <= `TCE; j = j + 1) 
                  begin
                   #`Tbase ;
                  end
               if ((!suspend_enable) && (!resume_enable))
               begin
               if ($time != 0) $display("%t:  NOTE : Chip erase cycle is finished",$realtime); 
               cer_enable <= `FALSE ;
               inhib_cer <= `TRUE ;  
               wip <= 1'b0 ; 
               reset_wel <= 1'b1 ; 
               end
            end
            else
            begin 
            if ($time != 0) $display("%t:  NOTE : Chip is protected,no erase occur",$realtime); 
            inhib_cer <= `TRUE ;  
            end
         end  
       end
     end
   end

   always @(posedge c_int)
   begin
      if (cer && (!only_rdsr) && select_ok)
      begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
         inhib_cer <= `TRUE ; 
      end
   end

      //-------------------------------------------
      // BLOCK_erase(32k)
      //-------------------------------------------
   always @(select_ok)
   begin
      if (!ber32)
      begin
         inhib_ber32 <= `FALSE ; 
      end 
      if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || ((byte_cpt == 3) && ((cpt != 7) || !byte_ok))) && ber32 && (!only_rdsr))
      begin
         if ((!select_ok) && (!resume_enable) && (!suspend_enable))
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            inhib_ber32 <= `TRUE ; 
             
         end 
      end 
      if ( ((byte_cpt == 4) || ((byte_cpt == 3) && (cpt == 7) && byte_ok)) && ber32 && (!only_rdsr))
      begin
         if ((!select_ok) && (!resume_enable))
         begin
            if ((status_register[1]) == 1'b0)
            begin
               if ($time != 0) $display("%t:  WARNING : Instruction canceled because WEL is low",$realtime); 
               ber32_enable_ctl <= `FALSE ; 
               inhib_ber32 <= `TRUE ; 
               
            end
             else 
            begin
             #2;
              if(!bpbit)
              begin
               ber32_time <= $realtime;
               if ($time != 0) $display("%t:  NOTE : Block erase cycle has begun",$realtime); 
               ber32_enable <= `TRUE ; 
               reset_wel <= 1'b0 ;
               wip <= 1'b1 ;
               for(j = 1; j <= `TBE1; j = j + 1) 
                  begin
                   #`Tbase ;
                  end
               if ((!suspend_enable) && (!resume_enable) && (!suspend_flag))
               begin
               if ($time != 0) $display("%t:  NOTE : Block erase cycle is finished",$realtime); 	
               ber32_enable_ctl <= `FALSE ; 
               inhib_ber32 <= `TRUE ; 
               
               wip <= 1'b0 ; 
               reset_wel <= 1'b1 ; 
               end
              end
             else
               begin
              if ($time != 0) $display("%t:  NOTE : this block protected,ber32 operation is inhibted",$realtime);
               inhib_ber32 <= `TRUE ;
               end
            end
         end 
      end
   end
   
   always @(posedge c_int)
   begin
      if ( ((byte_cpt == 4) || ((byte_cpt == 3) && (cpt == 7) && byte_ok)) && ber32 && (!only_rdsr))
      begin
         if (byte_cpt == 4 && select_ok)
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            inhib_ber32 <= `TRUE ;
            
         end
      end
   end

      //-------------------------------------------
      // BLOCK_erase(64k)
      //-------------------------------------------
   always @(select_ok)
   begin
      if (!ber64)
      begin
         inhib_ber64 <= `FALSE ; 
      end 
      if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || ((byte_cpt == 3) && ((cpt != 7) || !byte_ok))) && ber64 && (!only_rdsr))
      begin
         if ((!select_ok) && (!resume_enable) && (!suspend_enable))
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            inhib_ber64 <= `TRUE ; 
             
         end 
      end 
      if ( ((byte_cpt == 4) || ((byte_cpt == 3) && (cpt == 7) && byte_ok)) && ber64 && (!only_rdsr))
      begin
         if ((!select_ok) && (!resume_enable))
         begin
            if ((status_register[1]) == 1'b0)
            begin
               if ($time != 0) $display("%t:  WARNING : Instruction canceled because WEL is low",$realtime); 
               ber64_enable_ctl <= `FALSE ; 
               inhib_ber64 <= `TRUE ; 
               
            end
            else 
            begin
             #2;
              if(!bpbit)
              begin
               ber64_time <= $realtime;
               if ($time != 0) $display("%t:  NOTE : Block erase cycle has begun",$realtime); 
               ber64_enable <= `TRUE ; 
               reset_wel <= 1'b0 ;
               wip <= 1'b1 ;
               for(j = 1; j <= `TBE2; j = j + 1) 
                  begin
                    #`Tbase ;
                  end
         	if ((!suspend_enable) && (!resume_enable) && (!suspend_flag))
               begin
               if ($time != 0) $display("%t:  NOTE : Block erase cycle is finished",$realtime); 	
               ber64_enable_ctl <= `FALSE ; 
               inhib_ber64 <= `TRUE ; 
               
               wip <= 1'b0 ; 
               reset_wel <= 1'b1 ; 
               end
              end
             else
             begin
                if ($time != 0) $display("%t:  NOTE : this block is protected, ber64 operation is inhibted",$realtime); 
                inhib_ber64 <= `TRUE ; 
             end

            end 
         end 
      end
   end
   
   always @(posedge c_int)
   begin
      if ( ((byte_cpt == 4) || ((byte_cpt == 3) && (cpt == 7) && byte_ok)) && ber64 && (!only_rdsr))
      begin
         if (byte_cpt == 4 && select_ok)
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            inhib_ber64 <= `TRUE ;
            
         end
      end
   end
  
   
 
      //-------------------------------------------
      // SECTOR_erase
      //-------------------------------------------
   always @(select_ok)
   begin
      if (!ser)
      begin
         inhib_ser <= `FALSE ; 
      end 
      if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || ((byte_cpt == 3) && ((cpt != 7) || !byte_ok))) && ser && (!only_rdsr))
      begin
         if ((!select_ok) && (!resume_enable) && (!suspend_enable))
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            inhib_ser <= `TRUE ; 
         end 
      end 
      if ( ((byte_cpt == 4) || ((byte_cpt == 3) && (cpt == 7) && byte_ok)) && ser && (!only_rdsr))
      begin
         if ((!select_ok) && (!resume_enable))
         begin
            if ((status_register[1]) == 1'b0)
            begin
               if ($time != 0) $display("%t:  WARNING : Instruction canceled because WEL is low",$realtime); 
               ser_enable_ctl <= `FALSE ; 
               inhib_ser <= `TRUE ; 
            end
            else 
             begin
              #2;
              if(!bpbit)
               begin
               ser_time <= $realtime;
               if ($time != 0) $display("%t:  NOTE : Sector erase cycle has begun",$realtime); 
               ser_enable <= `TRUE ; 
               reset_wel <= 1'b0 ;
               wip <= 1'b1 ; 
               for(j = 1; j <= `TSE; j = j + 1) 
                  begin
                    #`Tbase ; 
                  end
               if ((!suspend_enable) && (!resume_enable) && (!suspend_flag))
               begin
               if ($time != 0) $display("%t:  NOTE : Sector erase cycle is finished",$realtime);
               ser_enable_ctl <= `FALSE ; 
               inhib_ser <= `TRUE ; 
               wip <= 1'b0 ; 
               reset_wel <= 1'b1 ; 
               end
               end
             else
               begin
               if ($time != 0) $display("%t:  NOTE : this sectore is protected, sector erase is inhibted",$realtime); 
               inhib_ser <= `TRUE ; 
               end
            end 
         end 
      end
   end
   
   always @(posedge c_int)
   begin
      if ( ((byte_cpt == 4) || ((byte_cpt == 3) && (cpt == 7) && byte_ok)) && ser && (!only_rdsr))
      begin
         if (byte_cpt == 4 && select_ok)
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            inhib_ser <= `TRUE ; 
         end
      end
   end
    

      //-------------------------------------------
      // OTP_erase
      //-------------------------------------------
   always @(select_ok)
   begin
      if (!otpers)
      begin
         inhib_otpers <= `FALSE ; 
      end 
      if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || ((byte_cpt == 3) && ((cpt != 7) || !byte_ok))) && otpers && (!only_rdsr))
      begin
         if ((!select_ok) && (!resume_enable) && (!suspend_enable))
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            inhib_otpers <= `TRUE ; 
         end 
      end 
      if ( ((byte_cpt == 4) || ((byte_cpt == 3) && (cpt == 7) && byte_ok)) && otpers && (!only_rdsr))
      begin
         if ((!select_ok) && (!resume_enable))
         begin
            if ((status_register[1]) == 1'b0)
            begin
               if ($time != 0) $display("%t:  WARNING : Instruction canceled because WEL is low",$realtime); 
               otpers_enable_ctl <= `FALSE ; 
               inhib_otpers <= `TRUE ; 
            end
            else 
             begin
              #2;
              if(!bpbit)
               begin
               otperss_time <= $realtime;
               if ($time != 0) $display("%t:  NOTE : OTP Sector erase cycle has begun",$realtime); 
               otpers_enable <= `TRUE ; 
               reset_wel <= 1'b0 ;
               wip <= 1'b1 ; 
               for(j = 1; j <= `TSE; j = j + 1) 
                  begin
                    #`Tbase ; 
                  end
               if ((!suspend_enable) && (!resume_enable) && (!suspend_flag))
               begin
               if ($time != 0) $display("%t:  NOTE : Otp Sector erase cycle is finished",$realtime); 
               otpers_enable_ctl <= `FALSE ; 
               inhib_otpers <= `TRUE ; 
               wip <= 1'b0 ; 
               reset_wel <= 1'b1 ; 
               end
               end
             else
               begin
               if ($time != 0) $display("%t:  NOTE : this otp sectore is protected, sector erase is inhibted",$realtime); 
               inhib_otpers <= `TRUE ; 
               end
            end 
         end 
      end
   end
   
   always @(posedge c_int)
   begin
      if ( ((byte_cpt == 4) || ((byte_cpt == 3) && (cpt == 7) && byte_ok)) && otpers && (!only_rdsr))
      begin
         if (byte_cpt == 4 && select_ok)
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            inhib_otpers <= `TRUE ; 
         end
      end
   end    
    
      //-------------------------------------------
      // Page_Program
      //-------------------------------------------
   always @(c_int or select_ok)
   begin
      if (((byte_cpt == 5) || ((byte_cpt == 4) && (cpt == 7))) && pp && (!only_rdsr))
      begin
         add_pp_enable <= `TRUE ; 
         if ((status_register[1]) == 1'b0)
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because WEL is low",$realtime); 
            pp_enable <= `FALSE ; 
            inhib_pp <= `TRUE ; 
         end
      end 
   end
   always @(select_ok)
   begin
      if (!pp)
      begin
         inhib_pp <= `FALSE ;
         add_pp_enable <= `FALSE ;  
         pp_enable <= `FALSE ; 
      end 
   end
    
   always @(negedge select_ok)
   begin
      if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || ((byte_cpt == 4) && ((cpt != 7) || !byte_ok))) && pp && (!only_rdsr) && (!select_ok))
         begin
            if ((!resume_enable) && (!suspend_enable))
            begin
                if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            	inhib_pp <= `TRUE ; 
            end
         end 
      if (((byte_cpt == 5) || ((byte_cpt == 4) && (cpt == 7))) && pp && (!only_rdsr) && byte_ok)
      begin
         if (!resume_enable)
         begin
               #2;
            if(!bpbit)
             begin
                add_pp_enable <= `TRUE ; 
           	if ((pp) && (!resume_enable))
        	begin
            	pps_time = $realtime;
            	if ($time != 0) $display("%t:  NOTE : Page program cycle is started",$realtime);
            	reset_wel <= 1'b0 ;
            	wip <= 1'b1 ; 
           	 #`TPP; 
           	if ((!suspend_enable) && (!resume_enable) && (!suspend_flag))
           	  begin
            	  if ($time != 0) $display("%t:  NOTE : Page program cycle is finished",$realtime);
            	  pp_enable <= `TRUE ; 
            	  inhib_pp <= `TRUE ; 
            	  wip <= 1'b0 ; 
            	  reset_wel <= 1'b1 ; 
         	  end 
         	end
            end
           else
           begin
            if ($time != 0) $display("%t:  NOTE : this page is protected, no pgm occur",$realtime); 
            inhib_pp <= `TRUE ;
            end
         end
      end 
      if ((byte_cpt > 5) && pp && (!only_rdsr) && byte_ok && (!resume_enable))
      begin
        #2;
        if(!bpbit)
        begin
         if ($time != 0) $display("%t:  NOTE : Page program cycle is started",$realtime); 
         pps_time = $realtime;
         reset_wel <= 1'b0 ;
         wip <= 1'b1 ;
         #`TPP; 
           if ((!suspend_enable) && (!resume_enable) && (!suspend_flag))
           begin
           if ($time != 0) $display("%t:  NOTE : Page program cycle is finished",$realtime);
           pp_enable <= `TRUE ; 
           wip <= 1'b0 ; 
           inhib_pp <= `TRUE ; 
           reset_wel <= 1'b1 ;
           end 
        end
        else
          begin
          if ($time != 0) $display("%t:  NOTE : this page is protected, no pgm occur",$realtime); 
          inhib_pp <= `TRUE ;
          end
     end 
     if ((byte_cpt > 5) && pp && (!only_rdsr) && (!byte_ok) && (!resume_enable) && (!suspend_enable))
     begin
         if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
         inhib_pp <= `TRUE ; 
         pp_enable <= `FALSE ; 
      end           
   end


      //-------------------------------------------
      //Quad Page_Program
      //-------------------------------------------
   always @(c_int or select_ok)
   begin
      if (((byte_cpt == 5) || ((byte_cpt == 4) && (cpt == 1))) && quadpgm && (!only_rdsr))
      begin
         add_pp_enable <= `TRUE ; 
         if ((status_register[1]) == 1'b0)
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because WEL is low",$realtime); 
            quadpgm_enable <= `FALSE ; 
            inhib_quadpgm <= `TRUE ; 
         end
      end 
   end
   always @(select_ok)
   begin
      if (!quadpgm)
      begin
         inhib_quadpgm <= `FALSE ;
         add_pp_enable <= `FALSE ;  
         quadpgm_enable <= `FALSE ; 
      end 
   end
    
   always @(negedge select_ok)
   begin
      if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || ((byte_cpt == 4) && ((cpt != 1) || !byte_ok))) && quadpgm && (!only_rdsr) && (!select_ok))
         begin
            if ((!resume_enable) && (!suspend_enable))
            begin
                if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            	inhib_quadpgm <= `TRUE ; 
            end
         end 
      if (((byte_cpt == 5) || ((byte_cpt == 4) && (cpt == 1))) && quadpgm && (!only_rdsr) && byte_ok)
      begin
         if (!resume_enable)
         begin
               #2;
              if(!bpbit)
                begin
                add_pp_enable <= `TRUE ; 
           	if ((quadpgm) && (!resume_enable))
        	begin
            	quadpgms_time = $realtime;
            	if ($time != 0) $display("%t:  NOTE : quad Page program cycle is started",$realtime); 
            	reset_wel <= 1'b0 ;
            	wip <= 1'b1 ; 
           	 #`TPP; 
           	if ((!suspend_enable) && (!resume_enable) && (!suspend_flag))
           	begin
            	if ($time != 0) $display("%t:  NOTE : quad Page program cycle is finished",$realtime); 
            	quadpgm_enable <= `TRUE ; 
            	inhib_quadpgm <= `TRUE ; 
            	wip <= 1'b0 ; 
            	reset_wel <= 1'b1 ; 
         	end 
         	end
           end
        else
           begin
            if ($time != 0) $display("%t:  NOTE : this page is protected, no quad pgm occur",$realtime); 
            inhib_quadpgm <= `TRUE ;
            end
         end
      end 
      if ((byte_cpt > 5) && quadpgm && (!only_rdsr) && byte_ok && (!resume_enable))
      begin
        #2;
              if(!bpbit)
         begin
         if ($time != 0) $display("%t:  NOTE : quad Page program cycle is started",$realtime); 
         quadpgms_time = $realtime;
         reset_wel <= 1'b0 ;
         wip <= 1'b1 ;
         #`TPP; 
         if ((!suspend_enable) && (!resume_enable) && (!suspend_flag))
         begin
         if ($time != 0) $display("%t:  NOTE : quad Page program cycle is finished",$realtime); 
         quadpgm_enable <= `TRUE ; 
         wip <= 1'b0 ; 
         inhib_quadpgm <= `TRUE ; 
         reset_wel <= 1'b1 ;
         end 
        end
       else
           begin
            if ($time != 0) $display("%t:  NOTE : this quad page is protected, no pgm occur",$realtime); 
            inhib_quadpgm <= `TRUE ;
            end
      end 
      if ((byte_cpt > 5) && quadpgm && (!only_rdsr) && (!byte_ok) && (!resume_enable) && (!suspend_enable))
      begin
         if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
         inhib_quadpgm <= `TRUE ; 
         quadpgm_enable <= `FALSE ; 
      end           
   end
   
      //-------------------------------------------
      //OTP Page_Program
      //-------------------------------------------
   always @(c_int or select_ok)
   begin
      if (((byte_cpt == 5) || ((byte_cpt == 4) && (cpt == 7))) && otppgm && (!only_rdsr))
      begin
         add_pp_enable <= `TRUE ; 
         if ((status_register[1]) == 1'b0)
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because WEL is low",$realtime); 
            otppgm_enable <= `FALSE ; 
            inhib_otppgm <= `TRUE ; 
         end
      end 
   end
   always @(select_ok)
   begin
      if (!otppgm)
      begin
         inhib_otppgm <= `FALSE ;
         add_pp_enable <= `FALSE ;  
         otppgm_enable <= `FALSE ; 
      end 
   end
    
   always @(negedge select_ok)
   begin
      if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || (byte_cpt == 3) || ((byte_cpt == 4) && ((cpt != 7) || !byte_ok))) && otppgm && (!only_rdsr) && (!select_ok))
         begin
            if ((!resume_enable) && (!suspend_enable))
            begin
            	if ($time != 0) $display("%t:  WARNING : Instruction canceled because the chip is deselected",$realtime); 
            	inhib_otppgm <= `TRUE ; 
            end
         end 
      if (((byte_cpt == 5) || ((byte_cpt == 4) && (cpt == 7))) && otppgm && (!only_rdsr) && byte_ok)
      begin
         if (!resume_enable)
         begin
               #2;
              if(!bpbit)
                begin
                add_pp_enable <= `TRUE ; 
           	if ((otppgm) && (!resume_enable))
        	begin
            	otppgms_time = $realtime;
            	if ($time != 0) $display("%t:  NOTE : Otp Page program cycle is started",$realtime); 
            	reset_wel <= 1'b0 ;
            	wip <= 1'b1 ; 
           	 #`TPP; 
           	if ((!suspend_enable) && (!resume_enable) && (!suspend_flag))
           	begin
            	if ($time != 0) $display("%t:  NOTE : Otp Page program cycle is finished",$realtime); 
            	otppgm_enable <= `TRUE ; 
            	inhib_otppgm <= `TRUE ; 
            	wip <= 1'b0 ; 
            	reset_wel <= 1'b1 ; 
         	end 
         	end
           end
        else
           begin
            if ($time != 0) $display("%t:  NOTE : this otp page is protected, no pgm occur",$realtime); 
            inhib_otppgm <= `TRUE ;
            end
         end
      end 
      if ((byte_cpt > 5) && otppgm && (!only_rdsr) && byte_ok && (!resume_enable))
      begin
        #2;
              if(!bpbit)
         begin
         if ($time != 0) $display("%t:  NOTE : Otp Page program cycle is started",$realtime); 
         otppgms_time = $realtime;
         reset_wel <= 1'b0 ;
         wip <= 1'b1 ;
         #`TPP; 
         if ((!suspend_enable) && (!resume_enable) && (!suspend_flag))	
         begin
         if ($time != 0) $display("%t:  NOTE : Otp Page program cycle is finished",$realtime); 
         otppgm_enable <= `TRUE ; 
         wip <= 1'b0 ; 
         inhib_otppgm <= `TRUE ; 
         reset_wel <= 1'b1 ;
         end 
        end
       else
           begin
            if ($time != 0) $display("%t:  NOTE : this otp page is protected, no pgm occur",$realtime); 
            inhib_otppgm <= `TRUE ;
            end
      end 
      if ((byte_cpt > 5) && otppgm && (!only_rdsr) && (!byte_ok) && (!resume_enable) && (!suspend_enable))
      begin
         if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
         inhib_otppgm <= `TRUE ; 
         otppgm_enable <= `FALSE ; 
      end           
   end   
      //-------------------------------------------
      //Erase/Program suspend
      //-------------------------------------------
   always @(select_ok)
   begin
      if (!suspend)
      begin
         inhib_suspend <= `FALSE ; 
      end 
      if (suspend && (only_suspend))
      begin
         if (!select_ok)
         begin
            if ((status_register[0]) == 1'b0)
            begin
               if ($time != 0) $display("%t:  WARNING : Instruction canceled because State is Idle",$realtime); 
               suspend_enable <= `FALSE ; 
               inhib_suspend <= `TRUE ; 
            end
            else
            begin
               if ($time != 0) 
		begin
		$display("%t:  NOTE : Erase/Program suspend cycle has begun",$realtime); 
		end
               wip <= #`TSUS 1'b0 ;
               suspend_enable <= #`TSUS `TRUE ; 
	       suspend_flag <= #`TSUS `TRUE ;
               inhib_suspend <= `TRUE ;
            end
         end
      end
          
   end

   always @(posedge c_int)
   begin
      if (suspend && (only_suspend) && select_ok)
      begin
         if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
         inhib_suspend <= `TRUE ; 
         suspend_enable <= `FALSE ; 
         suspend_pp <= `FALSE;
         suspend_quadpgm <= `FALSE;  
         suspend_otppgm <= `FALSE;
         suspend_otpers <= `FALSE;
         suspend_ser <= `FALSE;
         suspend_ber32 <= `FALSE;
         suspend_ber64 <= `FALSE;
     
      end
   end
      
      //-------------------------------------------
      //Erase/Program resume
      //-------------------------------------------
   always @(select_ok)
   begin
      if (!resume_enable)
      begin
         inhib_resume <= `FALSE ;
      end 
     if (resume && (!only_suspend))
      begin
         if (!select_ok)
         begin
               begin
                wip <=  1'b1 ;
                suspend_enable <=`FALSE;
		inhib_resume <= `TRUE ;	
               end
         end
      end 
   end
        
   always @(posedge c_int)
   begin
      if (resume && (!only_suspend) && select_ok)
      begin
         if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
         inhib_resume <= `TRUE ; 
         resume_enable <= `FALSE;
         ser <= `FALSE;
         ber32 <= `FALSE;
         ber64 <= `FALSE;       
         pp <= `FALSE;
         quadpgm <= `FALSE;  
         otppgm <= `FALSE;
         otpers <= `FALSE;        
      end
   end   

event ers_pgm_resume_event;
always @(ers_pgm_resume_event)
  begin:ers_pgm_resume_process
      if (pp)
     	begin
       	 	if ($time != 0) $display("%t:  NOTE : Page program cycle is resumed!",$realtime); 
        	reset_wel <= 1'b0 ;
        	wip <= 1'b1 ; 
		pps_time=$realtime;
      		#(`TPP-pps_time_add); 
        	if ($time != 0) $display("%t:  NOTE : after resumed Page program cycle is finished",$realtime); 
        	pp_enable <= `TRUE ; 
        	wip <= 1'b0 ; 
        	inhib_pp <= `TRUE ; 
        	reset_wel <= 1'b1 ; 
		suspend_flag <= `FALSE;	
     	end
     if (quadpgm)
     	begin
        	
       	 	if ($time != 0) $display("%t:  NOTE : quad Page program cycle is resumed",$realtime); 
        	reset_wel <= 1'b0 ;
        	wip <= 1'b1 ; 
		quadpgms_time = $realtime; 
        	#(`TPP-quadpgms_time_add); 
        	if ($time != 0) $display("%t:  NOTE : after resumed quad page program cycle is finished",$realtime); 
        	quadpgm_enable <= `TRUE ; 
        	wip <= 1'b0 ; 
        	inhib_quadpgm <= `TRUE ; 
        	reset_wel <= 1'b1 ;
		suspend_flag <= `FALSE;	
     	end
     
     
     if (otppgm)
     	begin
        	
       	 	if ($time != 0) $display("%t:  NOTE : Otp Page program cycle is resumed",$realtime); 
        	reset_wel <= 1'b0 ;
        	wip <= 1'b1 ; 
		otppgms_time = $realtime; 
        	#(`TPP-otppgms_time_add); 
        	if ($time != 0) $display("%t:  NOTE : after resumed otp page program cycle is finished",$realtime); 
        	otppgm_enable <= `TRUE ; 
        	wip <= 1'b0 ; 
        	inhib_otppgm <= `TRUE ; 
        	reset_wel <= 1'b1 ; 
		suspend_flag <= `FALSE;	
     	end
     
     if (otpers)
     	begin
        	
        	if ($time != 0) $display("%t:  NOTE : Otp Sector erase cycle has resumed",$realtime); 
        	otpers_enable <= `TRUE ;
        	reset_wel <= 1'b0 ;
        	wip <= 1'b1 ; 
		otperss_time = $realtime; 
        	#(`TSE*`Tbase-otperss_time_add) 
        	if ($time != 0) $display("%t:  NOTE : after resumed otp Sector erase cycle is finished",$realtime); 
        	otpers_enable_ctl <= `FALSE ;        	 
        	inhib_otpers <= `TRUE ;
        	
        	wip <= 1'b0 ; 
        	reset_wel <= 1'b1 ; 
		suspend_flag <= `FALSE;
    	end
     
     
     	if (ser)
     	begin
        	if ($time != 0) $display("%t:  NOTE : Sector erase cycle has resumed",$realtime); 
        	ser_enable <= `TRUE ;
        	reset_wel <= 1'b0 ;
        	wip <= 1'b1 ; 
		ser_time = $realtime;
        	#(`TSE*`Tbase-ser_time_add) 
        	if ($time != 0) $display("%t:  NOTE : after resumed Sector erase cycle is finished",$realtime);
        	ser_enable_ctl <= `FALSE ;        	 
        	inhib_ser <= `TRUE ;
        	
        	wip <= 1'b0 ; 
        	reset_wel <= 1'b1 ; 
		suspend_flag <= `FALSE;	
    	end
    	if (ber32)
    	begin
       	 	
        	if ($time != 0) $display("%t:  NOTE : Block erase cycle has resumed",$realtime); 
        	ber32_enable <= `TRUE ; 
        	reset_wel <= 1'b0 ;
        	wip <= 1'b1 ; 
		ber32_time = $realtime;
        	#(`TBE1*`Tbase-ber32_time_add)
        	if ($time != 0) $display("%t:  NOTE : after resumed Block erase cycle is finished_32k",$realtime); 	
        	ber32_enable_ctl <= `FALSE ; 
        	inhib_ber32 <= `TRUE ; 
        	
        	wip <= 1'b0 ; 
        	reset_wel <= 1'b1 ; 
		suspend_flag <= `FALSE;	
    	end
    	
    	if (ber64)
    	begin
       	 	
        	if ($time != 0) $display("%t:  NOTE : Block erase cycle has resumed",$realtime); 
        	ber64_enable <= `TRUE ; 
        	reset_wel <= 1'b0 ;
        	wip <= 1'b1 ; 
		ber64_time = $realtime;
        	#(`TBE2*`Tbase-ber64_time_add)
        	if ($time != 0) $display("%t:  NOTE : after resumed Block erase cycle is finished_64k",$realtime); 	
        	ber64_enable_ctl <= `FALSE ; 
        	inhib_ber64 <= `TRUE ; 
        	
        	wip <= 1'b0 ; 
        	reset_wel <= 1'b1 ; 
		suspend_flag <= `FALSE;	
    	end
  end       
 



 always @(negedge select_ok)
   begin 
      if(resume_enable)
      begin
  	->ers_pgm_resume_event;
      end
   end

  
    //-------------------------------------------------------
    //deep power down and release form deep power down
    //-------------------------------------------------------
 always  @(select_ok)
    begin
      if (!dpd) 
      begin
      inhib_dpd <= `FALSE ;
      end
      if ( dpd && (select_ok) )	
      begin
      inhib_dpd <=  `TRUE ;
      dpd <= `FALSE;
      end
      if (dpd && (!select_ok) && (!only_suspend) && ((byte_cpt==0 && cpt==7) || (byte_cpt==1 && cpt==0)) && byte_ok)
      begin
	  dpd_enable <= `TRUE ;
	  if ($time != 0) $display("%t:  NOTE: DEEP POWER DOWN START:COMMUNICATION PAUSED",$realtime); 
      end
      if (rfdp && (!select_ok) && (!only_suspend)  )
      begin
            inhib_rfdp <= `TRUE ;
      end
   end


 always @(select_ok or c_int)
 begin
   if (rfdp && (!only_rdsr) &&  (!select_ok) && ((byte_cpt ==0 && byte_ok) || byte_cpt==1 || byte_cpt==2 || byte_cpt==3 || (byte_cpt==4 && ((cpt<7) || (!byte_ok)) )))
      begin
      if (dpd_enable)
         begin
         if ($time != 0) $display("%t:  NOTE : The chip is releasing from DEEP POWER DOWN",$realtime); 
         inhib_rfdp <= `FALSE; 
         inhib_dpd <= `FALSE; 
         #`TRES1;
	 inhib_rfdp <=`TRUE; 
	 inhib_dpd <= `TRUE; 
         end
         inhib_rfdp <= `TRUE ; 
	 inhib_dpd <=  `TRUE;
         q_bis <= 1'bz ; 
       end 
 else 
      begin
      inhib_rfdp <= `FALSE; 
      inhib_dpd <= `FALSE; 
      end
     

 if ((((byte_cpt == 1) && (cpt > 0)) || (byte_cpt == 2) || (byte_cpt == 3) || ((byte_cpt == 4) && ((cpt < 7) || (!byte_ok)))) && rfdp && (!only_rdsr) && (!select_ok))
      begin
         if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
      end

      else if ((((byte_cpt == 4) && (cpt == 7) && byte_ok) || (byte_cpt > 4)) && rfdp && (!only_rdsr) && (!select_ok))
           begin
                 if (dpd_enable)
                     begin
                     if ($time != 0) $display("%t:  NOTE : The Chip is releasing from DEEP POWER DOWN",$realtime); 
                     inhib_rfdpid <= `FALSE ; 
                     inhib_dpd <=  `FALSE ;
                     #`TRES2;
		     inhib_rfdpid <= `TRUE ; 
		     inhib_dpd <=  `TRUE;
                     end
		else 
                  begin
		  inhib_rfdpid <= `TRUE; 
		  inhib_dpd <=  `TRUE;
                  q_bis <= 1'bz ; 
                  end
           end
end 

   //-------------------------------------------------------  
   /////////////////////////////////////////////////////// //
   // This process shifts out identification on data output
   always  @(select_ok )         
      begin
         if (!rdid )
         begin
            inhib_rdid <= `FALSE;
         end
         if(rdid && (!select_ok))
         begin
            bit_id <= 1'b0;
            d_bis <= #`TSHQZ 1'bz;
            q_bis <= #`TSHQZ 1'bz;
            inhib_rdid <= `TRUE;
         end         
      end
      
      
    always
        @(negedge c_int)
        begin
            if(rdid && (select_ok))
            begin
              rdid_enable <= `TRUE;
              d_bis <= #`TSHQZ 1'bz;
              if(flag_120M)
              begin
                  q_bis <= #`TCLQV 1'bx;
              end
              else
              begin
                  q_bis <= #`TCLQV id[23 - bit_id];
              end
              bit_id = bit_id + 1;
              if(bit_id > 23)   bit_id = 0;
            end
        end

   /////////////////////////////////////////////////////// //
   // This process shifts out manufactureid did on data output
   always
      @(select_ok )         
      begin
         if (!mid )
         begin
            inhib_mid <= `FALSE;
            bit_id <= 1'b0;
         end   
         
         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || ((byte_cpt == 3) && (cpt != 7))) && mid && (!select_ok))
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            inhib_mid <= `TRUE ; 
            bit_id <= 1'b0; 
         end 
         
         
         if ( mid && (((byte_cpt == 3) && (cpt == 7)) || (byte_cpt >= 4)))
         begin  
         if (!select_ok)
            begin
            bit_id <= 1'b0;
            d_bis <= #`TSHQZ 1'bz;
            q_bis <= #`TSHQZ 1'bz;
            inhib_mid <= `TRUE;  
            end
         end 
      end
      

    always
        @(negedge c_int)
        begin
            if(mid && (select_ok) && (((byte_cpt == 3) && (cpt == 7)) || (byte_cpt >= 4)) )
            begin
              if (adress_3[0] == 1'h0)
              begin
              rdid_enable <= `TRUE;
              d_bis <= #`TSHQZ 1'bz;
              if(flag_120M)
              begin
                  q_bis <= #`TCLQV 1'bx;
              end
              else
              begin
                  q_bis <= #`TCLQV did0 [15 - bit_id];
              end
              bit_id = bit_id + 1;		
	      if(bit_id > 15)   bit_id = 0;	
              end
              
              else if (adress_3[0] == 1'h1)
              begin
              rdid_enable <= `TRUE;
              d_bis <= #`TSHQZ 1'bz;
              if(flag_120M)
              begin
                  q_bis <= #`TCLQV 1'bx;
              end
              else
              begin
                  q_bis <= #`TCLQV did1 [15 - bit_id];
              end
              bit_id = bit_id + 1;		
	      if(bit_id > 15)   bit_id = 0;	
              end
              
              else
              begin
              d_bis <= #`TSHQZ 1'bz;
              q_bis <= #`TSHQZ 1'bx;              
              end 
            end
        end


   ///////////////// 4bh ////////////////////////////////////////
   // This process shifts out manufactureid did on data output
   always
      @(select_ok )         
      begin
         if (!cpid )
         begin
            inhib_cpid <= `FALSE;
            bit_id <= 1'b0;
         end   
         
         if (((byte_cpt == 0) && (cpt != 7)) && cpid && (!select_ok))
         begin
            if ($time != 0) $display("%t:  WARNING : Instruction canceled because False Instruction.",$realtime); 
            inhib_cpid <= `TRUE ; 
            bit_id <= 1'b0; 
         end 
         
         
         if ( cpid && (((byte_cpt == 0) && (cpt == 7)) || (byte_cpt >= 1)))
         begin  
         if (!select_ok)
            begin
            bit_id <= 1'b0;
            d_bis <= #`TSHQZ 1'bz;
            q_bis <= #`TSHQZ 1'bz;
            inhib_cpid <= `TRUE;  
            end
         end 
      end
      

    always
        @(negedge c_int)
        begin
            if(cpid && (select_ok) && (((byte_cpt == 0) && (cpt == 7)) || (byte_cpt >= 1)) )
            begin
                rdid_enable <= `TRUE;
                d_bis <= #`TSHQZ 1'bz;
                if(flag_120M)
                begin
                    q_bis <= #`TCLQV 1'bx;
                end
                else
                begin
                    q_bis <= #`TCLQV cp_id [15 - bit_id];
                end
                bit_id = bit_id + 1;		
	        if(bit_id > 15)   bit_id = 0;	
            end
        end



    /////////////////////////////////////////////////////// //
   // This process shifts out device id on data output


   always
      @(select_ok )         
      begin
         if (!rfdpid )
         begin
            inhib_rfdpid <= `FALSE;
         end   
         
         if (((byte_cpt == 0) || (byte_cpt == 1) || (byte_cpt == 2) || ((byte_cpt == 3) && (cpt != 7))) && rfdpid && (!select_ok))
         begin
            
            inhib_rfdpid <= `TRUE ; 
            bit_id <= 1'b0; 
         end 
         
          if ( rfdpid && (((byte_cpt == 3) && (cpt == 7)) || (byte_cpt >= 4)))
         begin  
         if (!select_ok)
             begin
            bit_id <= 1'b0;
            d_bis <= #`TSHQZ 1'bz;
            q_bis <= #`TSHQZ 1'bz;
            inhib_rfdpid <= `TRUE; 
            end
         end 
      end

    always
        @(negedge c_int)
        begin
         if(rfdp  && (((byte_cpt == 3) && (cpt == 7)) || (byte_cpt >= 4)) )
         begin
           if(! dpd)
              begin               
              if(select_ok)  
                begin
                  rdid_enable <= `TRUE;
                  d_bis <= #`TSHQZ 1'bz;
                  if(flag_120M)
                  begin
                      q_bis <= #`TCLQV 1'bx;
                  end
                  else
                  begin
                      q_bis <= #`TCLQV resdid [7 - bit_id];
                  end
                  bit_id = bit_id + 1;
                  if(bit_id > 7)   bit_id = 0;
                end
              end
          else 
             begin
              if(select_ok)    
                begin
                  rdid_enable <= `TRUE;
                  d_bis <= #`TSHQZ 1'bz;
                  if(flag_120M)
                  begin
                      q_bis <= #`TCLQV 1'bx;
                  end
                  else
                  begin
                      q_bis <= #`TCLQV resdid [7 - bit_id];
                  end
                  bit_id = bit_id + 1;
                  if(bit_id > 7)   bit_id = 0;
                end
              end
          end
        end
        
   /////////////////////////////////////////////////////// //
   // block protected bits set
   /////////////////////////////////////////////////////// //
   always @(status_register)
     begin
       bp[4:0] = status_register[6:2];
       srp[1:0] = status_register[8:7];
       QE = status_register[9];
       CMP = status_register[14];
      end 

   always @(status_register or tmp_wp)
     begin
       wrsr_protect = (srp[0] & (!tmp_wp)&(!QE))|srp[1] ;
     end
       
     always @(status_register)
     begin  
        if( status_register[10] == 1'b1)
        begin
        LB = 1'b1;
        end 
        else LB = LB;      
     end

always @( cut_add or select_ok or bp)
     begin
     
      casez ( bp )
        5'b00001 : 
        begin
           
           if( (cut_add >= 24'hfc0000) && (cut_add <= 24'hffffff) )
            begin
            
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end
        
        5'b00010 : 
        begin
           if( (cut_add >= 24'hf80000) && (cut_add <= 24'hffffff) )
            begin
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end   
        
        5'b00011 : 
        begin
           if( (cut_add >= 24'hf00000) && (cut_add <= 24'hffffff) )
            begin
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end   
        
        5'b00100 : 
        begin
           if( (cut_add >= 24'he00000) && (cut_add <= 24'hffffff) )
            begin
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end   
        
       5'b00101 : 
        begin
           if( (cut_add >= 24'hc00000) && (cut_add <= 24'hffffff) )
            begin
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end    
     
      5'b00110 : 
        begin
           if( (cut_add >= 24'h800000) && (cut_add <= 24'hffffff) )
            begin
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end     
                             
              
        5'b01001 : 
        begin
           if( (cut_add >= 24'h000000) && (cut_add <= 24'h03ffff) )
            begin
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end  
        
         5'b01010 : 
        begin
           if( (cut_add >= 24'h000000) && (cut_add <= 24'h07ffff) )
            begin
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end  
        
        
           5'b01011 : 
        begin
           if( (cut_add >= 24'h000000) && (cut_add <= 24'h0fffff) )
            begin
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end  
        
           5'b01100 : 
        begin
           if( (cut_add >= 24'h000000) && (cut_add <= 24'h1fffff) )
            begin
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end  
        
          5'b01101 : 
        begin
           if( (cut_add >= 24'h000000) && (cut_add <= 24'h3fffff) )
            begin
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end   
        
          5'b01110 : 
        begin
           if( (cut_add >= 24'h000000) && (cut_add <= 24'h7fffff) )
            begin
               bpbit_reg<= `TRUE;
             end
             
            else  bpbit_reg<= `FALSE;
        end  
        
         
         5'b10001 : 
        begin
             if( pp || quadpgm || ser)
              begin         
                 if( (cut_add >= 24'hfff000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber32)
              begin         
                 if( (cut_add >= 24'hff8000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber64)
              begin         
                 if( (cut_add >= 24'hff0000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end 
              end
             else  bpbit_reg<= `FALSE;
        end
        
         
         5'b10010 : 
        begin
             if( pp || quadpgm || ser)
              begin         
                 if( (cut_add >= 24'hffe000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end 
             else if( ber32)
              begin         
                 if( (cut_add >= 24'hff8000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber64)
              begin         
                 if( (cut_add >= 24'hff0000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end 
               end
             else  bpbit_reg<= `FALSE;
        end
        
         
         5'b10011 : 
        begin
             if( pp || quadpgm || ser)
              begin         
                 if( (cut_add >= 24'hffc000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
              end
             else if( ber32)
              begin         
                 if( (cut_add >= 24'hff8000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber64)
              begin         
                 if( (cut_add >= 24'hff0000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end 
               end
             else  bpbit_reg<= `FALSE;
        end
         
          
         5'b1010?, 5'b10110 : 
        begin
             if( pp || quadpgm || ser)
              begin         
                 if( (cut_add >= 24'hff8000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber32)
              begin         
                 if( (cut_add >= 24'hff8000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber64)
              begin         
                 if( (cut_add >= 24'hff0000) && (cut_add <= 24'hffffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end 
               end
             else  bpbit_reg<= `FALSE;
        end
        
         
         5'b11001 : 
        begin
             if( pp || quadpgm || ser)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h000fff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber32)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h007fff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber64)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h00ffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end 
             else  bpbit_reg<= `FALSE;
        end
        
          
         5'b11010 : 
        begin
             if( pp || quadpgm || ser)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h001fff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber32)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h007fff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber64)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h00ffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end 
               end
             else  bpbit_reg<= `FALSE;
        end
          
         5'b11011 : 
        begin
             if( pp || quadpgm || ser)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h003fff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber32)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h007fff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber64)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h00ffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end 
               end
             else  bpbit_reg<= `FALSE;
        end
          
         5'b1110?, 5'b11110 : 
        begin
             if( pp || quadpgm || ser)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h007fff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber32)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h007fff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end
               end
             else if( ber64)
              begin         
                 if( (cut_add >= 24'h000000) && (cut_add <= 24'h00ffff) )
                      begin           
                       bpbit_reg<= `TRUE;
                      end 
               end
             else  bpbit_reg<= `FALSE;
        end         
     
        5'b??111 : 
        begin
           if( (cut_add >= 24'h000000) && (cut_add <= 24'hffffff) )
              begin
               bpbit_reg<= `TRUE;
             end             
            else  bpbit_reg<= `FALSE;
        end   
               
       default:  bpbit_reg<= `FALSE;
            
       endcase
     end
     
     
wire bpbit_otp = (otppgm | otpers) & LB;
wire bpbit_all = (CMP & bp[4]) & ( ~(&bp[2:0]) & ber64 | ~bp[2] & ber32 );
wire bpbit_spi = ~CMP & bpbit_reg | CMP & ~bpbit_reg | bpbit_all;
wire bp_none =  ~CMP & ~(|bp[2:0]) | CMP & (&bp[2:0]);
assign  bpbit = ( pp | quadpgm | ser | ber32 | ber64) & bpbit_spi | bpbit_otp | cer & ~bp_none;


   
   /////////////////////////////////////////////////////// //
   // status register protected bits set
   /////////////////////////////////////////////////////// //   
     always  @(posedge wrsr) 
       begin
       if(QE==1'b0)
         begin
         case ( { srp, tmp_wp } )
           3'b010  : 
               begin	
               wrsr <= `FALSE;
               if ($time != 0) $display("%t:  NOTE : this wrsr op protected,wrsr operation is inhibted",$realtime);
               end
           3'b011  : inhib_wrsr <= `FALSE;     
           default : inhib_wrsr <= `FALSE; 
         endcase
         end
       else
          inhib_wrsr <= `FALSE;  
       end


       
   //-------------------------------------------------------
   //-------------------------------------------------------
   // This process shifts out status register on data output
   always  @(select_ok )
      begin
         if ((!rdsr_l) || (!rdsr_h) )             
         begin
            inhib_rdsr <= `FALSE ; 
         end 
         if ( (rdsr_l || rdsr_h) && (!select_ok))  
         begin
            bit_register <= 0; 
            q_bis <= #`TSHQZ 1'bz ; 
            inhib_rdsr <= `TRUE ; 
             
         end
      end

   always 
      @(negedge c_int)
      begin
         if (rdsr_l && (select_ok))
         begin
            rdsr_enable <= `TRUE ;
            d_bis <= #`TSHQZ 1'bz ;
            if(flag_120M)
            begin
                q_bis <= #`TCLQV 1'bx; 
            end
            else
            begin
                q_bis <= #`TCLQV status_register[7 - bit_register] ; 
            end
            bit_register = bit_register + 1; 
         end
         
          if (rdsr_h && (select_ok))    
         begin	    
            rdsr_enable <= `TRUE ;
            d_bis <= #`TSHQZ 1'bz ;
            if(flag_120M)
            begin
                q_bis <= #`TCLQV 1'bx; 
            end
            else
            begin
            q_bis <= #`TCLQV status_register[15 - bit_register] ; 
            end
            bit_register = bit_register + 1; 
         end
         
         
      end
      
 //-------------------------------------------------------
 //---------------output enable-------------------------------
    always @( read_enable or rdsr_enable or rdid_enable)
    begin
       if (read_enable || rdsr_enable ||rdid_enable)
       begin
       oen <= `TRUE ;
       end
       else
       begin
       oen <= `FALSE ; 
       end
    end 
     

   always 
   begin : pin_s
      @(s); 
      begin
      if (s == 1'b0)
      begin
         select_ok <= `TRUE ; 
      end 
      else
      begin
         select_ok <= `FALSE ; 
      end 
      end
   end 

   always 
   begin : signal_wip
      @(wip); 
      begin
      if (wip == 1'b1)
      begin
         if (pp || quadpgm || otppgm || otpers  || cer || ber32 || ber64 || ser || wrsr)
         begin
            if ($time != 0) $display("%t:  NOTE : Read Status Register instruction will be valid",$realtime); 
            only_rdsr <= `TRUE ; 
         end
         if ((pp || quadpgm || otppgm || otpers  || ber32 || ber64 || ser))
         begin
            if ($time != 0) $display("%t:  NOTE : Erase/Program suspend instruction will be valid",$realtime); 
            only_suspend <= `TRUE ;         
         end 
      end 
      else
      begin
         only_rdsr <= `FALSE ; 
         write_op  <= `FALSE ;
         only_suspend <= `FALSE ;
      end 
      end
   end 
endmodule


