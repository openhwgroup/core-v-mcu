module fpga_bootrom
 #(
 parameter ADDR_WIDTH=32,
 parameter DATA_WIDTH=32
 )
 (
 input logic 		  CLK,
 input logic 		  CEN,
 input logic [ADDR_WIDTH-1:0]  A,
 output logic [DATA_WIDTH-1:0] Q
 );
 logic [31:0] 		  value;
 assign Q = value;
 always @(posedge CLK) begin
  case (A)
  0: value <= 32'h09C0006F;
  1: value <= 32'h0980006F;
  2: value <= 32'h0940006F;
  3: value <= 32'h0900006F;
  4: value <= 32'h08C0006F;
  5: value <= 32'h0880006F;
  6: value <= 32'h0840006F;
  7: value <= 32'h0800006F;
  8: value <= 32'h07C0006F;
  9: value <= 32'h0780006F;
  10: value <= 32'h0740006F;
  11: value <= 32'h0700006F;
  12: value <= 32'h06C0006F;
  13: value <= 32'h0680006F;
  14: value <= 32'h0640006F;
  15: value <= 32'h0600006F;
  16: value <= 32'h05C0006F;
  17: value <= 32'h0580006F;
  18: value <= 32'h0540006F;
  19: value <= 32'h0500006F;
  20: value <= 32'h04C0006F;
  21: value <= 32'h0480006F;
  22: value <= 32'h0440006F;
  23: value <= 32'h0400006F;
  24: value <= 32'h03C0006F;
  25: value <= 32'h0380006F;
  26: value <= 32'h0340006F;
  27: value <= 32'h0300006F;
  28: value <= 32'h02C0006F;
  29: value <= 32'h0280006F;
  30: value <= 32'h0240006F;
  31: value <= 32'h0200006F;
  32: value <= 32'h0080006F;
  33: value <= 32'h0000006F;
  34: value <= 32'h02000117;
  35: value <= 32'h37810113;
  36: value <= 32'h0260006F;
  37: value <= 32'h00060113;
  38: value <= 32'h00058067;
  39: value <= 32'h30200073;
  40: value <= 32'hCA09832A;
  41: value <= 32'h00058383;
  42: value <= 32'h00730023;
  43: value <= 32'h0305167D;
  44: value <= 32'hFA6D0585;
  45: value <= 32'h11018082;
  46: value <= 32'h1A0005B7;
  47: value <= 32'h85934641;
  48: value <= 32'h850A1B45;
  49: value <= 32'hCC22CE06;
  50: value <= 32'h65F13FE1;
  51: value <= 32'h20058593;
  52: value <= 32'h28894505;
  53: value <= 32'h45C1860A;
  54: value <= 32'h20554505;
  55: value <= 32'h1A0005B7;
  56: value <= 32'h85934635;
  57: value <= 32'h850A1C85;
  58: value <= 32'h47B73F65;
  59: value <= 32'hA7831A10;
  60: value <= 32'hC7890C47;
  61: value <= 32'h03100793;
  62: value <= 32'h00F10523;
  63: value <= 32'h45B5860A;
  64: value <= 32'h28B54505;
  65: value <= 32'h02E00793;
  66: value <= 32'h00F10723;
  67: value <= 32'h000F4437;
  68: value <= 32'h24040793;
  69: value <= 32'hFFFD17FD;
  70: value <= 32'h00E10613;
  71: value <= 32'h45054585;
  72: value <= 32'hB7FD28B9;
  73: value <= 32'h1A102737;
  74: value <= 32'h47854714;
  75: value <= 32'h00A797B3;
  76: value <= 32'hC7148EDD;
  77: value <= 32'h8FD54314;
  78: value <= 32'h27B7C31C;
  79: value <= 32'h87930034;
  80: value <= 32'h953E0417;
  81: value <= 32'h004C57B7;
  82: value <= 32'hB4078793;
  83: value <= 32'h02B7D7B3;
  84: value <= 32'h07C2051E;
  85: value <= 32'h132383C1;
  86: value <= 32'h515C02F5;
  87: value <= 32'h0067E793;
  88: value <= 32'h515CD15C;
  89: value <= 32'h0107E793;
  90: value <= 32'h515CD15C;
  91: value <= 32'h1007E793;
  92: value <= 32'h515CD15C;
  93: value <= 32'h2007E793;
  94: value <= 32'h4501D15C;
  95: value <= 32'h27B78082;
  96: value <= 32'h87930034;
  97: value <= 32'h953E0417;
  98: value <= 32'h00751793;
  99: value <= 32'h4BD84501;
  100: value <= 32'hCB90EF11;
  101: value <= 32'hC703CBCC;
  102: value <= 32'h67130187;
  103: value <= 32'h8C230107;
  104: value <= 32'h4BD800E7;
  105: value <= 32'h0542E711;
  106: value <= 32'h80828141;
  107: value <= 32'hB7C50505;
  108: value <= 32'hBFC50505;
  109: value <= 32'h42203241;
  110: value <= 32'h6C746F6F;
  111: value <= 32'h6564616F;
  112: value <= 32'h0A0D2072;
  113: value <= 32'h00000000;
  114: value <= 32'h746F6F42;
  115: value <= 32'h206C6573;
  116: value <= 32'h0D30203D;
  117: value <= 32'h0000000A;
  default: value <= 0;
   endcase
  end
endmodule    
