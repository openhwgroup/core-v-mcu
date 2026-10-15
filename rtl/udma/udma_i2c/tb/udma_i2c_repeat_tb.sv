// Copyright 2026 Donmakino LLC
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

`timescale 1ns/1ps

module udma_i2c_repeat_tb;

    logic clk = 1'b0;
    logic rstn = 1'b0;
    logic [7:0] data_tx = '0;
    logic data_tx_valid = 1'b0;
    logic data_tx_ready;
    logic [7:0] data_rx;
    logic data_rx_valid;
    logic scl_o, scl_oe, sda_o, sda_oe;
    logic slave_low = 1'b0;
    logic active = 1'b0;
    wire scl = scl_oe ? scl_o : 1'b1;
    wire sda = (sda_oe ? sda_o : 1'b1) & ~slave_low;
    int wire_clocks = 0;
    int received = 0;
    int stops = 0;

    // 25 MHz peripheral clock, divider 16 for a Fast-mode bus rate.
    always #20 clk = ~clk;

    udma_i2c_control i_control (
        .clk_i           (clk),
        .rstn_i          (rstn),
        .ext_events_i    (4'b0),
        .data_tx_i       (data_tx),
        .data_tx_valid_i (data_tx_valid),
        .data_tx_ready_o (data_tx_ready),
        .data_rx_o       (data_rx),
        .data_rx_valid_o (data_rx_valid),
        .data_rx_ready_i (1'b1),
        .sw_rst_i        (1'b0),
        .busy_o          (),
        .al_o            (),
        .err_o           (),
        .scl_i           (scl),
        .scl_o           (scl_o),
        .scl_oe          (scl_oe),
        .sda_i           (sda),
        .sda_o           (sda_o),
        .sda_oe          (sda_oe)
    );

    // Read-only slave: acknowledge the address, then send 0xff bytes.
    always @(negedge sda) begin
        if (rstn && scl) begin
            active = 1'b1;
            wire_clocks = 0;
        end
    end

    always @(posedge sda) begin
        if (rstn && scl && active) begin
            active = 1'b0;
            stops++;
        end
    end

    always @(posedge scl) begin
        if (active)
            wire_clocks++;
    end

    always @(negedge scl) begin
        slave_low = active && (wire_clocks == 8);
    end

    always @(posedge clk) begin
        if (rstn && data_rx_valid) begin
            if (data_rx !== 8'hff)
                $fatal(1, "unexpected slave data %02h", data_rx);
            received++;
        end
    end

    task automatic send_byte(input logic [7:0] value);
        @(negedge clk);
        data_tx = value;
        data_tx_valid = 1'b1;
        do @(posedge clk); while (!data_tx_ready);
    endtask

    task automatic read_bytes(input int count);
        int previous_stops;
        previous_stops = stops;
        received = 0;
        send_byte(8'h00);             // START
        send_byte(8'h80);             // WR
        send_byte(8'ha1);             // address 0x50, read
        send_byte(8'hc0);             // RPT
        send_byte(8'(count - 1));     // ACKed read count
        send_byte(8'h40);             // RD_ACK
        send_byte(8'h60);             // final byte, RD_NACK
        send_byte(8'h20);             // STOP
        @(negedge clk);
        data_tx_valid = 1'b0;
        wait (stops == previous_stops + 1);
        repeat (100) @(posedge clk);
        $display("READ_SIZE=%0d received=%0d wire_clocks=%0d",
                 count, received, wire_clocks);
        if (received != count)
            $fatal(1, "expected %0d bytes, got %0d", count, received);
        // Nine clocks per address/data byte, plus the STOP clock.
        if (wire_clocks != 9 * (count + 1) + 1)
            $fatal(1, "unexpected number of I2C clocks");
    endtask

    initial begin
        repeat (4) @(negedge clk);
        rstn = 1'b1;
        repeat (100) @(posedge clk);
        send_byte(8'he0);             // CFG, divider 16
        send_byte(8'h00);
        send_byte(8'h10);

        // Repeat counts 0, 1, 127, 128, 129, 254 and 255.
        read_bytes(1);
        read_bytes(2);
        read_bytes(128);
        read_bytes(129);
        read_bytes(130);
        read_bytes(255);
        read_bytes(256);
        $display("PASS: uDMA I2C repeat counts");
        $finish;
    end

    initial begin
        #100000000;
        $fatal(1, "timeout waiting for I2C transaction");
    end

endmodule
