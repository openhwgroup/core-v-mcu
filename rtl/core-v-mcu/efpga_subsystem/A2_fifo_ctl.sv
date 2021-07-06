// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

`define CK2Q  1

module fifo_ctl # (
		   parameter FIFO_DEPTH  = 4,
		   parameter A_WIDTH = $clog2(FIFO_DEPTH))
   (
    output [A_WIDTH-1:0] raddr,
    output [A_WIDTH-1:0] waddr,
    output 		 empty, almost_empty,
    output 		 full, almost_full,
    output 		 ren_o,
    input 		 fflush,
    input 		 rclk,
    input 		 wclk,
    input 		 ren, // pop
    input 		 req  // push
    );

// Synchroniztion flops for crossing clock domains
reg  [A_WIDTH:0]   pushtopop1;
reg  [A_WIDTH:0]   pushtopop2;
reg  [A_WIDTH:0]   poptopush1;
reg  [A_WIDTH:0]   poptopush2;

wire [A_WIDTH:0]   pushtopop0;
wire [A_WIDTH:0]   poptopush0;


always@(posedge rclk or posedge fflush ) begin
  if (fflush) begin
    pushtopop1 <= #`CK2Q '0;
    pushtopop2 <= #`CK2Q '0;
  end else begin
   pushtopop1 <= #`CK2Q pushtopop0;
   pushtopop2 <= #`CK2Q pushtopop1;
  end
end // always@ (posedge rclk or posedge fflush )

always@(posedge wclk or posedge fflush ) begin
  if (fflush) begin
    poptopush1 <= #`CK2Q '0;
    poptopush2 <= #`CK2Q '0;
  end else begin
    poptopush1 <= #`CK2Q poptopush0;
    poptopush2 <= #`CK2Q poptopush1;
  end
end // always@ (posedge rclk or posedge fflush )

fifo_push # (.A_WIDTH(A_WIDTH))
u_fifo_push
   (
    .wclk(wclk),
    .wen(req),
    .fflush(fflush),
    .gcout(pushtopop0),
    .gcin(poptopush2),
    .ff_waddr(waddr),
    .full(full),
    .almost_full(almost_full)
);

fifo_pop   # (.A_WIDTH(A_WIDTH))
  u_fifo_pop (
    .rclk(rclk),
    .ren_in(ren),
    .fflush(fflush),
    .ren_o(ren_o),
    .gcout(poptopush0),
    .gcin(pushtopop2),
    .out_raddr(raddr),
    .empty(empty),
    .almost_empty(almost_empty)

    );

endmodule // fifo_ctl


module fifo_push # (
parameter A_WIDTH = 2 )
  (
  output logic 	       full,
  output logic 	       almost_full,
  output [A_WIDTH:0]   gcout,
  output [A_WIDTH-1:0] ff_waddr,
  input 	       wclk,
  input 	       wen,
  input 	       fflush,
  input [A_WIDTH:0]    gcin
   );

   reg 		       full_next;

   reg 		       paf_next;
   reg 		       paf;
   reg 		       fmo; // full minus one
   reg 		       fmo_next;
   reg 		       overflow;   // GAM overflow is no longer needed  detection is left to the user logic.
   reg 		       p1, p2, f1,f2, q1, q2;
   reg [A_WIDTH:0]     waddr;
   reg [A_WIDTH:0]     raddr;
   reg [A_WIDTH:0]     gcout_reg;
   reg [A_WIDTH:0]     gcout_next;
   reg [A_WIDTH:0]     raddr_next;
   reg [A_WIDTH:0]     paf_thresh;

   wire 	       overflow_next;  // GAM overflow is no longer needed  detection is left to the user logic.
   wire [A_WIDTH:0]    waddr_next;
   wire [A_WIDTH:0]    tmp;

   wire [A_WIDTH:0]    next_count, count;
   reg [A_WIDTH+1:0]   fbytes;
   genvar 	       i;

   // count is number of bytes free in the FIFO
   // next count is number that will free if the current clock is a pushflags
   // caclulation the size of the FIFO - (write pointer - read pointer)
   //assign next_count = fbytes - (waddr_next - raddr_next);
   //assign count      = fbytes - (waddr - raddr);
   assign next_count = fbytes - ((waddr_next >= raddr_next) ? (waddr_next - raddr_next) : (~raddr_next + waddr_next +1));
   assign count      = fbytes - ((waddr >= raddr) ? (waddr - raddr) : (~raddr + waddr + 1));

   always@(*) begin
      fbytes = {1'b1,{A_WIDTH{1'b0}}};
      paf_thresh = 2;
   end

   always@(*) begin
      full_next = wen ? f1 : f2;
      fmo_next  = wen ? p1 : p2;
      paf_next  = wen ? q1 : q2;
   end


   always@(*) begin : PUSH_FULL_FLAGS
      f1 = 1'b0;
      f2 = 1'b0;
      p1 = 1'b0;
      p2 = 1'b0;
      q1 = next_count < paf_thresh;
      q2 = count < paf_thresh;
      f1 = ({~waddr_next[A_WIDTH],waddr_next[A_WIDTH-1:0]} == raddr_next[A_WIDTH:0]);
      f2 = ({~waddr[A_WIDTH],waddr[A_WIDTH-1:0]} == raddr_next[A_WIDTH:0]);
      p1 = (((waddr_next[A_WIDTH-1:0]+1) & {A_WIDTH{1'b1}}) == raddr_next[A_WIDTH-1:0]);
      p2 = (((waddr[A_WIDTH-1:0]+1) & {A_WIDTH{1'b1}}) == raddr_next[A_WIDTH-1:0]);
   end // always@ begin full flags



   assign gcout_next  = ((waddr_next) >> 1) ^ (waddr_next);


   always@ (posedge wclk) begin
      paf  <= #`CK2Q paf_next;
   end


   always@ (posedge wclk or posedge fflush) begin
      if (fflush == 1) begin
	 full      <= #`CK2Q 1'b0;
	 almost_full      <= #`CK2Q 1'b0;
	 fmo  <= #`CK2Q 1'b0;
	 raddr     <= #`CK2Q '0;
      end else begin
	 full      <= #`CK2Q full_next;
	 fmo  <= #`CK2Q fmo_next;
	 raddr <= #`CK2Q raddr_next;
	 almost_full <= fmo_next;
      end
   end

   assign overflow_next = full & wen;  // GAM overflow is no longer needed  detection is left to the user logic.

   always@ (posedge wclk or posedge fflush) begin
      if (fflush) begin
	 overflow <= #`CK2Q 1'b0;
      end else if (wen == 1'b1) begin
	 overflow <= #`CK2Q overflow_next;  // set until fflush clears
      end
   end

   always@ (posedge wclk or posedge fflush) begin
      if (fflush) begin
	 waddr     <= #`CK2Q '0;

	 gcout_reg <= #`CK2Q '0;
      end else if (wen == 1'b1) begin
	 waddr     <= #`CK2Q waddr_next;
	 gcout_reg <= #`CK2Q gcout_next;
      end
   end

   assign gcout = gcout_reg;


   generate
      for (i = 0; i < A_WIDTH+1; i= i+1)
	assign tmp[i] = ^(gcin >> i);
   endgenerate

   always@(*) begin
      raddr_next = tmp;
   end

   assign ff_waddr   = waddr[A_WIDTH-1:0];
   assign waddr_next = waddr + 1;


endmodule

module fifo_pop # ( parameter A_WIDTH = 2)
   (
    output 		    ren_o,
    output logic 	    empty,
    output logic 	    almost_empty,
    output [A_WIDTH-1:0] out_raddr,
    output [A_WIDTH:0]   gcout,
    input 		    rclk,
    input 		    ren_in,
    input 		    fflush,
    input [A_WIDTH:0]    gcin
    );



reg         epo; //empty Plus one
reg         pae;
reg         underflow;  // GAM   underflow is longer needed as the user code will decode the conditionreg
reg         e1,e2,o1,o2,q1,q2;

reg  [A_WIDTH-1:0] ff_raddr;  // pre fetch address
reg  [A_WIDTH:0] waddr;
reg  [A_WIDTH:0] raddr;
reg  [A_WIDTH:0] gcout_reg;
reg  [A_WIDTH:0] gcout_next;
reg  [A_WIDTH:0] waddr_next;
reg  [A_WIDTH:0] pae_thresh;

wire        ren_out;
wire        empty_next;
wire        pae_next;
wire        epo_next;

wire [A_WIDTH:0] raddr_next;
wire [A_WIDTH-1:0] ff_raddr_next;
wire [A_WIDTH:0] tmp;
wire [A_WIDTH:0] next_count, count;
reg [A_WIDTH:0] fbytes;
genvar i;


//Count is number of bytes currenly in the FIFO
//next count is the number of bytes that will be in the FIFO if the current clock is a POP
// these equations need to be verified for adress wrap conditions.
   assign next_count = (waddr - raddr_next);
   assign count      = (waddr - raddr);


   always@(*) begin
      fbytes = 4;
   end
   always@(*) begin
      pae_thresh = 2;
   end

   //#2 ren_out = empty ? 1'b1 : ren_in;
   assign ren_out = empty ? 1'b1 : ren_in;


always@(*) begin // Empty Flags
  q1 = next_count < pae_thresh;
  q2 = count < pae_thresh;
   e1 = (raddr_next[A_WIDTH:0] ==  waddr_next[A_WIDTH:0]);
   e2 = (raddr[A_WIDTH:0] == waddr_next[A_WIDTH:0]);
   o1 = (((raddr_next[A_WIDTH:0] + 1) & {{1'b0},{A_WIDTH{1'b1}}}) ==  waddr_next[A_WIDTH:0]);
   o2 = (((raddr[A_WIDTH:0]+1) & {{1'b0},{A_WIDTH{1'b1}}}) == waddr_next[A_WIDTH:0]);
end // always@ begin

assign empty_next = (ren_in & !empty) ? e1 : e2;
assign epo_next = (ren_in & !empty) ? o1 : o2;
assign pae_next = (ren_in & !empty) ? q1 : q2;

always@ (posedge rclk or posedge fflush) begin
  if (fflush) begin
    empty     <= #`CK2Q 1'b1;
    pae  <= #`CK2Q 1'b1;
    epo <= #`CK2Q 1'b0;
     almost_empty <= 0;

  end else begin
    empty     <= #`CK2Q empty_next;
    pae  <= #`CK2Q pae_next;
    epo <= #`CK2Q epo_next;
         almost_empty <= #`CK2Q epo_next;
  end
end

assign gcout_next  = ((raddr_next) >> 1) ^ (raddr_next);

always@ (posedge rclk or posedge fflush) begin
  if (fflush) begin
    waddr     <= #`CK2Q '0;
  end else begin
    waddr     <= #`CK2Q waddr_next;
  end
end

always@ (posedge rclk or posedge fflush) begin
  if (fflush) begin
    underflow <= #`CK2Q 1'b0;
    gcout_reg <= #`CK2Q '0;
//greg@20191213  end else if (ren_in) begin
  end else if ((ren_in & !empty)) begin
    underflow <= #`CK2Q empty ;          // pop while empty
    gcout_reg <= #`CK2Q gcout_next;
  end
end


generate
   for (i = 0; i < A_WIDTH+1; i= i +1)
     assign tmp[i] = ^(gcin >> i);
endgenerate

always@(*) begin
   waddr_next = {tmp[A_WIDTH:0]     } ;

end

   assign ff_raddr_next = ff_raddr + 1;
   assign raddr_next    = raddr    + 1;


always@ (posedge rclk or posedge fflush) begin //? Vincent: Need to check this blcok funtion
  if (fflush)
    ff_raddr  <= #`CK2Q '0;
  else if (empty & ~empty_next)  // prefetch address increment when new data available
    ff_raddr  <= #`CK2Q raddr_next[A_WIDTH-1:0];
  else if ((ren_in & !empty) & ~empty_next)
    ff_raddr  <= #`CK2Q ff_raddr_next;
end

always@ (posedge rclk or posedge fflush) begin
  if (fflush)
    raddr <= #`CK2Q '0;
//greg@20191213  else if (ren_in)
  else if ((ren_in & !empty))
    raddr <= #`CK2Q raddr_next;
end

assign ren_o     = ren_out;
assign gcout     = gcout_reg;
   assign out_raddr = ff_raddr[A_WIDTH-1:0];
endmodule // fifo_pop
