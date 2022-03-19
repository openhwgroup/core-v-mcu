/**
 * SPDX-License-Identifier: Apache-2.0
 *
 * Copyright 2016 by the authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module uartdpi
  #(parameter BAUD = 'x,
    parameter FREQ = 'x,
    parameter string NAME = "uart0",
    parameter USEPTY = 1)
   (
    input      clk,
    input      rst,

    output reg tx,
    input      rx
    );

   localparam CYCLES_PER_SYMBOL = FREQ/BAUD;
   initial begin
     $display("%m @ %0t: %s Baud = %d freq = %d ccps = %d",
              $time, NAME, BAUD, FREQ, CYCLES_PER_SYMBOL);
     $display("%m @ %0t: Pseudo UART is %s", $time, USEPTY ? "enabled" : "disabled");
   end
   
   import "DPI-C" function
     chandle uartdpi_create(input string name);

   import "DPI-C" function
     byte uartdpi_read(input chandle obj);

   import "DPI-C" function
     int uartdpi_can_read(input chandle obj);

   import "DPI-C" function
     void uartdpi_write(input chandle obj, int data);

   chandle obj;
   
   initial begin
      obj = uartdpi_create(NAME);
   end

   // TX
   reg txactive;
   int  txcount;
   int  txcyccount;
   reg [9:0] txsymbol;
   
   always_ff @(negedge clk) begin
      tx <= 1;
      if (rst) begin
         txactive <= 0;
	 txcount <= 0;
	 txcyccount <= 0;
	 txsymbol <= 0;
      end else begin
         if (!txactive) begin
            if (uartdpi_can_read(obj)) begin
               automatic int c = uartdpi_read(obj);
               txsymbol <= {1'b1, c[7:0], 1'b0};
               txactive <= 1;
               txcount <= 0;
               txcyccount <= 0;
            end
         end else begin
            txcyccount <= txcyccount + 1;
            tx <= txsymbol[txcount];
            if (txcyccount == CYCLES_PER_SYMBOL) begin
               txcyccount <= 0;
               if (txcount == 9)
                 txactive <= 0;
               else
                 txcount <= txcount + 1;
            end
         end
      end
   end

   // RX
   reg rxactive;
   int rxcount;
   int rxcyccount;
   reg [7:0] rxsymbol;
   
   always_ff @(negedge clk) begin
      rxcyccount = rxcyccount + 1;
      
      if (rst) begin
	 rxsymbol <= 0;
         rxactive <= 0;
	 rxcount <= 0;
	 rxcyccount <=0;
      end else begin
         if (!rxactive) begin
            if (!rx) begin
               rxactive <= 1;
               rxcount <= 0;
               rxcyccount <= 0;
            end
         end else begin
            if (rxcount == 0) begin
               if (rxcyccount == CYCLES_PER_SYMBOL/2) begin
                  if (rx) begin
                     rxactive <= 0;
                  end else begin
                     rxcount <= rxcount + 1;
                     rxcyccount <= 0;
                  end
               end
            end else if (rxcount <= 8) begin
               if (rxcyccount == CYCLES_PER_SYMBOL) begin
                  rxsymbol[rxcount-1] <= rx;
                  rxcount <= rxcount + 1;
                  rxcyccount <= 0;
               end
            end else begin
               if (rxcyccount == CYCLES_PER_SYMBOL) begin
                  rxactive = 0;
                  if (rx) begin
                     if (USEPTY) begin
                        uartdpi_write(obj, rxsymbol);
                     end
                     else begin
                        $write("%c", rxsymbol);
                     end
                  end
               end
            end
            $fflush;
         end
      end // else: !if(rst)
   end
   
endmodule
   
