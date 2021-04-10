// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

task FILL_LINEAR;
input  logic [31:0]  address_base;
input  logic [31:0]  fill_pattern;
input  logic [15:0]  transfer_count;
input  string        transfer_type;
begin

  int unsigned count_local_AW;
  int unsigned count_local_W;
  logic   [7:0][31:0]           local_wdata;

  case(transfer_type)

  "4_BYTE" :
  begin

        fork
              for ( count_local_AW = 0; count_local_AW < transfer_count; count_local_AW++)
              begin
                  ST4_AW ( .id(count_local_AW[3:0]),               .address( (address_base + count_local_AW*4) & 32'hFFFF_FFFC ),  .user(SRC_ID) );
              end

              for ( count_local_W = 0; count_local_W < transfer_count; count_local_W++)
              begin
                  local_wdata[0] = fill_pattern + count_local_W*4;
                  case (((32'h0000_0004) & (address_base + count_local_W*4)) >> 2)
                  0: ST4_DW ( .wdata({32'h0000_0000, local_wdata[0]}),   .be(8'h0F),                              .user(SRC_ID) );
                  1: ST4_DW ( .wdata({local_wdata[0], 32'h0000_0000}),   .be(8'hF0),                              .user(SRC_ID) );
                  endcase
              end
        join
  end


  "8_BYTE" :
  begin

        fork
              for ( count_local_AW = 0; count_local_AW < transfer_count; count_local_AW++)
              begin
                  ST8_AW ( .id(count_local_AW[3:0]),  .address(address_base + count_local_AW*8 ),  .user(SRC_ID) );
              end

              for ( count_local_W = 0; count_local_W < transfer_count; count_local_W++)
              begin
                  local_wdata[0] = fill_pattern + count_local_W*8 + 0 ;
                  local_wdata[1] = fill_pattern + count_local_W*8 + 4 ;
                  ST8_DW ( .wdata(local_wdata[1:0]),   .be('1),  .user(SRC_ID) );
              end
        join
  end


  "16_BYTE" :
  begin

        fork
              for ( count_local_AW = 0; count_local_AW < transfer_count; count_local_AW++)
              begin
                  ST16_AW ( .id(count_local_AW[3:0]),  .address(address_base + count_local_AW*16 ),  .user(SRC_ID) );
              end

              for ( count_local_W = 0; count_local_W < transfer_count; count_local_W++)
              begin
                  local_wdata[0] = fill_pattern + count_local_W*16 + 0 ;
                  local_wdata[1] = fill_pattern + count_local_W*16 + 4 ;
                  local_wdata[2] = fill_pattern + count_local_W*16 + 8 ;
                  local_wdata[3] = fill_pattern + count_local_W*16 + 12 ;
                  ST16_DW ( .wdata(local_wdata[3:0]),   .be('1),  .user(SRC_ID) );
              end
        join
  end

  "32_BYTE" :
  begin

        fork
              for ( count_local_AW = 0; count_local_AW < transfer_count; count_local_AW++)
              begin
                  ST32_AW ( .id(count_local_AW[3:0]),  .address(address_base + count_local_AW*32 ),  .user(SRC_ID) );
              end

              for ( count_local_W = 0; count_local_W < transfer_count; count_local_W++)
              begin
                  local_wdata[0] = fill_pattern + count_local_W*32 + 0 ;
                  local_wdata[1] = fill_pattern + count_local_W*32 + 4 ;
                  local_wdata[2] = fill_pattern + count_local_W*32 + 8 ;
                  local_wdata[3] = fill_pattern + count_local_W*32 + 12 ;
                  local_wdata[4] = fill_pattern + count_local_W*32 + 16 ;
                  local_wdata[5] = fill_pattern + count_local_W*32 + 20 ;
                  local_wdata[6] = fill_pattern + count_local_W*32 + 24 ;
                  local_wdata[7] = fill_pattern + count_local_W*32 + 28 ;
                  ST32_DW ( .wdata(local_wdata[7:0]),   .be('1),  .user(SRC_ID) );
              end
        join
  end

  default:
  begin
        fork
              for ( count_local_AW = 0; count_local_AW < transfer_count; count_local_AW++)
              begin
                  ST4_AW ( .id(count_local_AW[3:0]),               .address(address_base + count_local_AW*4  ),  .user(SRC_ID) );
              end

              for ( count_local_W = 0; count_local_W < transfer_count; count_local_W++)
              begin
                  local_wdata[0] = fill_pattern + count_local_W*4;
                  ST4_DW ( .wdata(local_wdata[0]),   .be('1),                              .user(SRC_ID) );
              end
        join
  end
  endcase

end
endtask







task READ_LINEAR;
input  logic [31:0]  address_base;
input  logic [15:0]  transfer_count;
input  string        transfer_type;
begin

  integer count_local_AR;
  logic   [7:0][31:0]           local_wdata;

  case(transfer_type)

      "4_BYTE" :
      begin
          for ( count_local_AR = 0; count_local_AR < transfer_count; count_local_AR++)
          begin
                    LD4 ( .id(count_local_AR[3:0]),               .address(BASE_ADDRESS + count_local_AR*4 ),  .user(SRC_ID) );
          end
      end

      "8_BYTE" :
      begin
          for ( count_local_AR = 0; count_local_AR < transfer_count; count_local_AR++)
          begin
                    LD8 ( .id(count_local_AR[3:0]),               .address(BASE_ADDRESS + count_local_AR*8 ),  .user(SRC_ID) );
          end
      end

      "16_BYTE" :
      begin
          for ( count_local_AR = 0; count_local_AR < transfer_count; count_local_AR++)
          begin
                    LD16 ( .id(count_local_AR[3:0]),               .address(BASE_ADDRESS + count_local_AR*16 ),  .user(SRC_ID) );
          end
      end

      "32_BYTE" :
      begin
          for ( count_local_AR = 0; count_local_AR < transfer_count; count_local_AR++)
          begin
                    LD32 ( .id(count_local_AR[3:0]),               .address(BASE_ADDRESS + count_local_AR*32 ),  .user(SRC_ID) );
          end
      end



      default:
      begin
          for ( count_local_AR = 0; count_local_AR < transfer_count; count_local_AR++)
          begin
                    LD4 ( .id(count_local_AR[3:0]),               .address(BASE_ADDRESS + count_local_AR*4 ),  .user(SRC_ID) );
          end
      end

  endcase


end
endtask




task CHECK_LINEAR;
input  logic [31:0]  address_base;
input  logic [15:0]  transfer_count;
input  string        transfer_type;
input  logic [31:0]  check_pattern;

begin

  integer count_local_AR;
  logic   [7:0][31:0]           local_wdata;

  automatic int unsigned local_PASS = 0;
  automatic int unsigned local_FAIL = 0;

  case(transfer_type)

      "4_BYTE" :
      begin
          for ( count_local_AR = 0; count_local_AR < transfer_count; count_local_AR++)
          begin
                    LD4 ( .id(count_local_AR[3:0]),               .address(address_base + count_local_AR*4 ),  .user(SRC_ID) );
                    @(IncomingRead);
                    if(RDATA != check_pattern + count_local_AR*4 )
                    begin
                      $error("RDATA ERROR: got %x != %x [expected]", RDATA , check_pattern+count_local_AR*4);
                      local_FAIL++;
                    end
                    else
                    begin
                      local_PASS++;
                    end
          end
      end

      "8_BYTE" :
      begin
          for ( count_local_AR = 0; count_local_AR < transfer_count; count_local_AR++)
          begin
                    LD8 ( .id(count_local_AR[3:0]),               .address(address_base + count_local_AR*8 ),  .user(SRC_ID) );
                    @(IncomingRead);
                    if(RDATA != check_pattern + count_local_AR*8 )
                    begin
                      $error("RDATA ERROR: got %x != %x [expected]", RDATA , check_pattern+count_local_AR*8);
                      local_FAIL++;
                    end
                    else
                    begin
                      local_PASS++;
                    end
          end
      end

      "16_BYTE" :
      begin
          for ( count_local_AR = 0; count_local_AR < transfer_count; count_local_AR++)
          begin
                    LD16 ( .id(count_local_AR[3:0]),               .address(address_base + count_local_AR*16 ),  .user(SRC_ID) );
                    @(IncomingRead);;
                    if(RDATA != check_pattern + count_local_AR*16)
                    begin
                      $error("RDATA ERROR: got %x != %x [expected]", RDATA , check_pattern+count_local_AR*16);
                      local_FAIL++;
                    end
                    else
                    begin
                      local_PASS++;
                    end
          end
      end

      "32_BYTE" :
      begin
          for ( count_local_AR = 0; count_local_AR < transfer_count; count_local_AR++)
          begin
                    LD32 ( .id(count_local_AR[3:0]),               .address(address_base + count_local_AR*32 ),  .user(SRC_ID) );
                    @(IncomingRead);;
                    if(RDATA != check_pattern + count_local_AR*32)
                    begin
                      $error("RDATA ERROR: got %x != %x [expected]", RDATA , check_pattern+count_local_AR*32);
                      local_FAIL++;
                    end
                    else
                    begin
                      local_PASS++;
                    end
          end
      end



      default:
      begin
          for ( count_local_AR = 0; count_local_AR < transfer_count; count_local_AR++)
          begin
                    LD4 ( .id(count_local_AR[3:0]),               .address(address_base + count_local_AR*4 ),  .user(SRC_ID) );
                    @(IncomingRead);;
                    if(RDATA != check_pattern + count_local_AR*4 )
                    begin
                      $error("RDATA ERROR: got %x != %x [expected]", RDATA , check_pattern+count_local_AR*4);
                      local_FAIL++;
                    end
                    else
                    begin
                      local_PASS++;
                    end
          end
      end

  endcase

  PASS = PASS + local_PASS;
  FAIL = FAIL + local_FAIL;
end
endtask







task FILL_RANDOM;
input  logic [31:0]  address_base;
input  logic [31:0]  fill_pattern;
input  logic [15:0]  transfer_count;
input  string        transfer_type;
parameter RANDOM_ADDR_BITS = 6;
begin

  integer count_local_AW;
  integer count_local_W;
  logic   [7:0][31:0]           local_wdata;
  logic   [31:0]                local_addr;

  case(transfer_type)

  "4_BYTE" :
  begin

        fork
              for ( count_local_AW = 0; count_local_AW < transfer_count; count_local_AW++)
              begin
                  local_addr = '0;
                  local_addr[2+RANDOM_ADDR_BITS-1:2] = $random();
                  local_addr = address_base + local_addr;
                  ST4_AW ( .id(count_local_AW[3:0]),               .address(local_addr),  .user(SRC_ID) );
              end

              for ( count_local_W = 0; count_local_W < transfer_count; count_local_W++)
              begin
                  local_wdata[0] = $random;
                  ST4_DW ( .wdata(local_wdata[0]),   .be('1),                              .user(SRC_ID) );
              end
        join
  end


  "8_BYTE" :
  begin

        fork
              for ( count_local_AW = 0; count_local_AW < transfer_count; count_local_AW++)
              begin
                  local_addr = '0;
                  local_addr[3+RANDOM_ADDR_BITS-1:3] = $random();
                  local_addr = address_base + local_addr;
                  ST8_AW ( .id(count_local_AW[3:0]),               .address(local_addr  ),  .user(SRC_ID) );
              end

              for ( count_local_W = 0; count_local_W < transfer_count; count_local_W++)
              begin
                  local_wdata[0] = $random;
                  local_wdata[1] = $random;
                  ST8_DW ( .wdata(local_wdata[1:0]),   .be('1),                              .user(SRC_ID) );
              end
        join
  end


  "16_BYTE" :
  begin

        fork
              for ( count_local_AW = 0; count_local_AW < transfer_count; count_local_AW++)
              begin
                  local_addr = '0;
                  local_addr[4+RANDOM_ADDR_BITS-1:4] = $random();
                  local_addr = address_base + local_addr;
                  ST16_AW ( .id(count_local_AW[3:0]),  .address(local_addr ),  .user(SRC_ID) );
              end

              for ( count_local_W = 0; count_local_W < transfer_count; count_local_W++)
              begin
                  local_wdata[0] = fill_pattern + count_local_W*16 + 0 ;
                  local_wdata[1] = fill_pattern + count_local_W*16 + 4 ;
                  local_wdata[2] = fill_pattern + count_local_W*16 + 8 ;
                  local_wdata[3] = fill_pattern + count_local_W*16 + 12 ;
                  ST16_DW ( .wdata(local_wdata[3:0]),   .be('1),  .user(SRC_ID) );
              end
        join
  end

  "32_BYTE" :
  begin

        fork
              for ( count_local_AW = 0; count_local_AW < transfer_count; count_local_AW++)
              begin
                  local_addr = '0;
                  local_addr[5+RANDOM_ADDR_BITS-1:5] = $random();
                  local_addr = address_base + local_addr;
                  ST4_AW ( .id(count_local_AW[3:0]),  .address(local_addr ),  .user(SRC_ID) );
              end

              for ( count_local_W = 0; count_local_W < transfer_count; count_local_W++)
              begin
                  local_wdata[0] = $random ;
                  local_wdata[1] = $random ;
                  local_wdata[2] = $random ;
                  local_wdata[3] = $random ;
                  local_wdata[4] = $random ;
                  local_wdata[5] = $random ;
                  local_wdata[6] = $random ;
                  local_wdata[7] = $random ;
                  ST4_DW ( .wdata(local_wdata[7:0]),   .be('1),  .user(SRC_ID) );
              end
        join
  end

  default:
  begin
        fork
              for ( count_local_AW = 0; count_local_AW < transfer_count; count_local_AW++)
              begin
                  ST4_AW ( .id(count_local_AW[3:0]),               .address(address_base + count_local_AW*4  ),  .user(SRC_ID) );
              end

              for ( count_local_W = 0; count_local_W < transfer_count; count_local_W++)
              begin
                  local_wdata[0] = fill_pattern + count_local_W*4;
                  ST4_DW ( .wdata(local_wdata[0]),   .be('1),                              .user(SRC_ID) );
              end
        join
  end
  endcase

end
endtask
