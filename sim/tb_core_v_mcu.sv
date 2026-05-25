// SystemVerilog testbench for core_v_mcu (Verilator --binary --timing)
//
// Usage:  ./sim_core_v_mcu +cycles=N [+trace=out.vcd]
//   +cycles=N   run for N clock cycles (default 2000)
//   +trace=FILE write VCD to FILE
//
// UART0 TX (io_out_o[8]) output is decoded and printed to stdout.
// UART0 RX (io_in_i[7]) is held high (idle).

`timescale 1ns/1ps

module tb_core_v_mcu;

    // ── Clock & reset ───────────────────────────────────────────────────────────
    logic ref_clk = 0;
    logic rstn    = 0;

    // ── JTAG (tied off) ─────────────────────────────────────────────────────────
    logic jtag_tck  = 0;
    logic jtag_tdi  = 0;
    logic jtag_tdo;
    logic jtag_tms  = 1;   // TMS=1 keeps JTAG TAP in Test-Logic-Reset
    logic jtag_trst = 0;

    // ── Pad IO ──────────────────────────────────────────────────────────────────
    logic [47:0]      io_in  = '1;    // all inputs idle; UART RX = 1
    logic [47:0]      io_out;
    logic [47:0][5:0] pad_cfg;
    logic [47:0]      io_oe;

    // ── DUT ─────────────────────────────────────────────────────────────────────
    core_v_mcu dut (
        .jtag_tck_i  (jtag_tck),
        .jtag_tdi_i  (jtag_tdi),
        .jtag_tdo_o  (jtag_tdo),
        .jtag_tms_i  (jtag_tms),
        .jtag_trst_i (jtag_trst),
        .ref_clk_i   (ref_clk),
        .rstn_i      (rstn),
        .bootsel_i   (1'b0),
        .stm_i       (1'b0),
        .io_in_i     (io_in),
        .io_out_o    (io_out),
        .pad_cfg_o   (pad_cfg),
        .io_oe_o     (io_oe)
    );

    // ── Clock: 100 MHz (5 ns half-period) ───────────────────────────────────────
    always #5 ref_clk = ~ref_clk;

    // ── Reset: deassert after 20 cycles ─────────────────────────────────────────
    initial begin
        repeat (20) @(posedge ref_clk);
        rstn = 1;
        $display("[%0t] Reset deasserted", $time);
    end

    // ── Optional VCD trace via +trace=filename ───────────────────────────────────
    initial begin
        string trace_file;
        if ($value$plusargs("trace=%s", trace_file)) begin
            $dumpfile(trace_file);
            $dumpvars(0, tb_core_v_mcu);
            $display("[%0t] Writing VCD trace to %s", $time, trace_file);
        end
    end

    // ── Make the %t format spec look pretty ─────────────────────────
    initial $timeformat(-9, 1, "ns", 10);

    // ── Run-length control via +cycles=N (default 2000) ─────────────────────────
    longint unsigned max_cycles  = 2000;
    longint unsigned cycle_count = 0;

    initial void'($value$plusargs("cycles=%d", max_cycles));

    always @(posedge ref_clk) begin
        cycle_count++;
        if (cycle_count >= max_cycles) begin
            @(negedge ref_clk);
            $display("[%0t] Simulation done after %0d cycles", $time, max_cycles);
            $finish;
        end
    end

    // ── UART0 TX monitor ────────────────────────────────────────────────────────
    // UART0 TX = io_out_o[8]
    // UART1 TX = io_out_o[9]
    // Both run at periph_clk/div = 100MHz/43 ≈ 44 cycles/bit in simulation
    // (firmware hardcodes div=5000000/115200=43; periph_clk=100MHz in bypass mode)
    localparam int UART_BIT_CYCLES  = 44;
    localparam int UART_HALF_CYCLES = UART_BIT_CYCLES / 2;

    initial begin : uart0_monitor
        logic [7:0] rx_byte;
        int         bit_idx;

        @(posedge rstn);    // wait until out of reset

        forever begin
            @(negedge io_out[8]);                           // start-bit falling edge
            repeat (UART_HALF_CYCLES) @(posedge ref_clk);  // advance to mid-start-bit
            if (io_out[8] === 1'b0) begin                  // confirmed start bit
                for (bit_idx = 0; bit_idx < 8; bit_idx++) begin
                    repeat (UART_BIT_CYCLES) @(posedge ref_clk);
                    rx_byte[bit_idx] = io_out[8];           // LSB-first
                end
                if (rx_byte >= 8'h20 && rx_byte <= 8'h7e)
                    $write("%c", rx_byte);
                else if (rx_byte == 8'h0a || rx_byte == 8'h0d)
                    $write("\n");
                else
                    $write("[%02h]", rx_byte);
                $fflush();
            end
            // else: glitch — loop back and wait for next negedge
        end
    end

    // ── UART1 TX monitor (same timing as UART0) ─────────────────────────────────
    // Buffers a full line and prints it as "[U1] <line>" to avoid char-by-char
    // interleaving with UART0 output.
    initial begin : uart1_monitor
        logic [7:0] rx_byte;
        int         bit_idx;
        string      line_buf;

        @(posedge rstn);
        line_buf = "";

        forever begin
            @(negedge io_out[9]);
            repeat (UART_HALF_CYCLES) @(posedge ref_clk);
            if (io_out[9] === 1'b0) begin
                for (bit_idx = 0; bit_idx < 8; bit_idx++) begin
                    repeat (UART_BIT_CYCLES) @(posedge ref_clk);
                    rx_byte[bit_idx] = io_out[9];
                end
                if (rx_byte == 8'h0a || rx_byte == 8'h0d) begin
                    $display("[U1] %s", line_buf);
                    line_buf = "";
                end else if (rx_byte >= 8'h20 && rx_byte <= 8'h7e)
                    line_buf = {line_buf, string'(rx_byte)};
                else
                    line_buf = {line_buf, $sformatf("[%02h]", rx_byte)};
            end
        end
    end

endmodule
