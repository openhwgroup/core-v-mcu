// Copyright 2026 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

`timescale 1ns/1ps

module udma_i2c_status_tb;

    localparam logic [4:0] I2C_STATUS_ADDR = 5'b01000;

    logic sys_clk;
    logic periph_clk;
    logic rstn;

    logic busy_periph;
    logic al_periph;
    logic event_periph;
    logic busy_sys;
    logic al_sys;
    logic status_event;

    logic [31:0] cfg_data_i;
    logic [4:0]  cfg_addr_i;
    logic        cfg_valid_i;
    logic        cfg_rwn_i;
    logic [31:0] cfg_data_o;
    logic        cfg_ready_o;

    int event_count;
    logic status_event_q;

    always #5 sys_clk = ~sys_clk;
    always #7 periph_clk = ~periph_clk;

    udma_i2c_status i_status (
        .periph_clk_i (periph_clk),
        .sys_clk_i    (sys_clk),
        .rstn_i       (rstn),
        .busy_i       (busy_periph),
        .al_i         (al_periph),
        .event_i      (event_periph),
        .busy_o       (busy_sys),
        .al_o         (al_sys),
        .event_o      (status_event)
    );

    udma_i2c_reg_if #(
        .L2_AWIDTH_NOAL (12),
        .TRANS_SIZE     (16)
    ) i_reg_if (
        .clk_i               (sys_clk),
        .rstn_i              (rstn),
        .cfg_data_i          (cfg_data_i),
        .cfg_addr_i          (cfg_addr_i),
        .cfg_valid_i         (cfg_valid_i),
        .cfg_rwn_i           (cfg_rwn_i),
        .cfg_data_o          (cfg_data_o),
        .cfg_ready_o         (cfg_ready_o),
        .cfg_rx_startaddr_o  (),
        .cfg_rx_size_o       (),
        .cfg_rx_continuous_o (),
        .cfg_rx_en_o         (),
        .cfg_rx_clr_o        (),
        .cfg_rx_en_i         (1'b0),
        .cfg_rx_pending_i    (1'b0),
        .cfg_rx_curr_addr_i  (12'b0),
        .cfg_rx_bytes_left_i (16'b0),
        .cfg_tx_startaddr_o  (),
        .cfg_tx_size_o       (),
        .cfg_tx_continuous_o (),
        .cfg_tx_en_o         (),
        .cfg_tx_clr_o        (),
        .cfg_tx_en_i         (1'b0),
        .cfg_tx_pending_i    (1'b0),
        .cfg_tx_curr_addr_i  (12'b0),
        .cfg_tx_bytes_left_i (16'b0),
        .cfg_do_rst_o        (),
        .status_busy_i       (busy_sys),
        .status_al_i         (al_sys)
    );

    always @(posedge sys_clk or negedge rstn) begin
        if (!rstn) begin
            event_count    <= 0;
            status_event_q <= 1'b0;
        end else begin
            if (status_event)
                event_count <= event_count + 1;

            if (status_event && status_event_q)
                $fatal(1, "status_event must be one sys_clk cycle wide");

            status_event_q <= status_event;
        end
    end

    task automatic pulse_status(input logic busy, input logic al);
        begin
            @(negedge periph_clk);
            busy_periph  = busy;
            al_periph    = al;
            event_periph = busy | al;
            @(negedge periph_clk);
            busy_periph  = 1'b0;
            al_periph    = 1'b0;
            event_periph = 1'b0;
        end
    endtask

    task automatic wait_for_event(input int previous_count);
        int timeout;
        begin
            timeout = 0;
            while ((event_count == previous_count) && (timeout < 40)) begin
                @(posedge sys_clk);
                #1;
                timeout++;
            end

            if (event_count != previous_count + 1)
                $fatal(1, "expected one status event, count changed from %0d to %0d",
                       previous_count, event_count);
        end
    endtask

    task automatic read_status(output logic [1:0] value);
        begin
            @(negedge sys_clk);
            cfg_addr_i  = I2C_STATUS_ADDR;
            cfg_valid_i = 1'b1;
            cfg_rwn_i   = 1'b1;
            #1;
            value = cfg_data_o[1:0];
            @(posedge sys_clk);
            @(negedge sys_clk);
            cfg_valid_i = 1'b0;
            cfg_rwn_i   = 1'b0;
            cfg_addr_i  = '0;
        end
    endtask

    task automatic expect_status(input logic [1:0] expected);
        logic [1:0] actual;
        begin
            read_status(actual);
            if (actual !== expected)
                $fatal(1, "STATUS expected %02b, got %02b", expected, actual);
        end
    endtask

    task automatic wait_for_busy_pulse;
        int timeout;
        begin
            timeout = 0;
            while (!busy_sys && (timeout < 40)) begin
                @(posedge sys_clk);
                #1;
                timeout++;
            end
            if (!busy_sys)
                $fatal(1, "BUSY pulse did not reach the system-clock domain");
        end
    endtask

    initial begin
        int previous_count;

        sys_clk       = 1'b0;
        periph_clk    = 1'b0;
        rstn          = 1'b0;
        busy_periph   = 1'b0;
        al_periph     = 1'b0;
        event_periph  = 1'b0;
        cfg_data_i    = '0;
        cfg_addr_i    = '0;
        cfg_valid_i   = 1'b0;
        cfg_rwn_i     = 1'b0;

        repeat (3) @(posedge sys_clk);
        rstn = 1'b1;
        repeat (2) @(posedge sys_clk);

        if (!cfg_ready_o)
            $fatal(1, "configuration interface must remain ready");
        if (status_event || busy_sys || al_sys)
            $fatal(1, "status outputs must be low after reset");
        expect_status(2'b00);

        previous_count = event_count;
        pulse_status(1'b1, 1'b0);
        wait_for_event(previous_count);
        repeat (2) @(posedge sys_clk);
        expect_status(2'b01);
        expect_status(2'b00);

        previous_count = event_count;
        pulse_status(1'b0, 1'b1);
        wait_for_event(previous_count);
        repeat (2) @(posedge sys_clk);
        expect_status(2'b10);
        expect_status(2'b00);

        previous_count = event_count;
        pulse_status(1'b1, 1'b1);
        wait_for_event(previous_count);
        repeat (2) @(posedge sys_clk);
        expect_status(2'b11);
        expect_status(2'b00);

        // Keep a STATUS read active until BUSY reaches the register interface.
        // The new set must win over the simultaneous clear-on-read operation.
        @(negedge sys_clk);
        cfg_addr_i  = I2C_STATUS_ADDR;
        cfg_valid_i = 1'b1;
        cfg_rwn_i   = 1'b1;
        previous_count = event_count;
        pulse_status(1'b1, 1'b0);
        wait_for_busy_pulse();
        @(posedge sys_clk);
        #1;
        @(negedge sys_clk);
        cfg_valid_i = 1'b0;
        cfg_rwn_i   = 1'b0;
        cfg_addr_i  = '0;
        wait_for_event(previous_count);
        expect_status(2'b01);
        expect_status(2'b00);

        $display("PASS: uDMA I2C status CDC and sticky STATUS behavior");
        $finish;
    end

endmodule
