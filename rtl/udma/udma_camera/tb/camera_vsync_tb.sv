// Copyright 2026 Nathan Chandrasekar
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

`timescale 1ns/1ps

module camera_vsync_tb;

    logic clk = 1'b0;
    logic cam_clk = 1'b0;
    logic rstn = 1'b0;

    logic [31:0] cfg_data = '0;
    logic [4:0] cfg_addr = '0;
    logic cfg_valid = 1'b0;
    logic vsync = 1'b1;
    logic hsync = 1'b0;
    logic [7:0] pixel_byte = '0;
    logic [15:0] rx_data;
    logic rx_valid;
    logic [15:0] last_pixel;
    int received;
    int failures = 0;

    always #5 clk = ~clk;
    always #20 cam_clk = ~cam_clk;

    camera_if #(
        .DATA_WIDTH (8)
    ) i_camera (
        .clk_i               (clk),
        .rstn_i              (rstn),
        .dft_test_mode_i     (1'b0),
        .dft_cg_enable_i     (1'b0),
        .cfg_data_i          (cfg_data),
        .cfg_addr_i          (cfg_addr),
        .cfg_valid_i         (cfg_valid),
        .cfg_rwn_i           (1'b0),
        .cfg_data_o          (),
        .cfg_ready_o         (),
        .cfg_rx_startaddr_o  (),
        .cfg_rx_size_o       (),
        .cfg_rx_continuous_o (),
        .cfg_rx_en_o         (),
        .cfg_rx_clr_o        (),
        .cfg_rx_en_i         (1'b1),
        .cfg_rx_pending_i    (1'b0),
        .cfg_rx_curr_addr_i  (12'b0),
        .cfg_rx_bytes_left_i (16'b0),
        .data_rx_datasize_o  (),
        .data_rx_data_o      (rx_data),
        .data_rx_valid_o     (rx_valid),
        .data_rx_ready_i     (1'b1),
        .cam_clk_i           (cam_clk),
        .cam_data_i          (pixel_byte),
        .cam_hsync_i         (hsync),
        .cam_vsync_i         (vsync)
    );

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            received   <= 0;
            last_pixel <= '0;
        end else if (rx_valid) begin
            received   <= received + 1;
            last_pixel <= rx_data;
            $display("PIXEL[%0d]=%04x", received, rx_data);
        end
    end

    task automatic write_csr(input logic [4:0] addr, input logic [31:0] value);
        @(negedge clk);
        cfg_addr  = addr;
        cfg_data  = value;
        cfg_valid = 1'b1;
        @(negedge clk);
        cfg_valid = 1'b0;
    endtask

    task automatic send_pixel(input logic [15:0] value);
        @(negedge cam_clk);
        hsync      = 1'b1;
        pixel_byte = value[15:8];
        @(negedge cam_clk);
        pixel_byte = value[7:0];
        @(negedge cam_clk);
        hsync = 1'b0;
        // Allow the pixel pipeline and clock-domain crossing FIFO to drain.
        repeat (10) @(negedge cam_clk);
    endtask

    task automatic check_polarity(input logic polarity);
        @(negedge cam_clk);
        rstn  = 1'b0;
        vsync = ~polarity;
        repeat (4) @(negedge cam_clk);
        rstn = 1'b1;

        write_csr(5'h02, 32'h12);       // RX: halfword
        // Exercise the reset default for active low and program active high.
        if (polarity)
            write_csr(5'h0d, 32'h1);
        write_csr(5'h08, 32'h80000400); // Enable, BYPASS_LITEND
        repeat (20) @(negedge cam_clk);

        // Enabling with VSYNC inactive must wait for the next frame.
        send_pixel(16'habcd);
        if (received != 0) begin
            $display("FAIL: polarity=%0b captured %0d pixel(s) before VSYNC", polarity, received);
            failures++;
        end

        vsync = polarity;
        repeat (5) @(negedge cam_clk);
        vsync = ~polarity;
        repeat (5) @(negedge cam_clk);
        send_pixel(16'h1234);
        if (received != 1 || last_pixel !== 16'h1234) begin
            $display("FAIL: polarity=%0b expected only 1234, received=%0d last=%04x",
                     polarity, received, last_pixel);
            failures++;
        end
        $display("VSYNC_POLARITY=%0b received_pixels=%0d", polarity, received);
    endtask

    initial begin
        check_polarity(1'b0);
        check_polarity(1'b1);
        if (failures != 0)
            $fatal(1, "camera VSYNC polarity regression: %0d failure(s)", failures);
        $display("PASS: camera capture waits for active-low and active-high VSYNC");
        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "camera VSYNC polarity regression timed out");
    end

endmodule
