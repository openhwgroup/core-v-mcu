// Copyright 2026 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

`timescale 1ns/1ps

module udma_i2c_control_status_tb;

    localparam int BUSY_COUNTER  = 0;
    localparam int AL_COUNTER    = 1;
    localparam int EVENT_COUNTER = 2;

    logic clk;
    logic rstn;

    logic [7:0] data_tx;
    logic       data_tx_valid;
    logic       data_tx_ready;
    logic       data_rx_valid;

    logic busy_event;
    logic al_event;
    logic status_event;

    logic scl_oe;
    logic sda_oe;
    logic ext_scl_low;
    logic ext_sda_low;
    logic scl_i;
    logic sda_i;

    int busy_event_count;
    int al_event_count;
    int status_event_count;

    assign scl_i = ~(scl_oe | ext_scl_low);
    assign sda_i = ~(sda_oe | ext_sda_low);

    always #5 clk = ~clk;

    udma_i2c_control i_control (
        .clk_i           (clk),
        .rstn_i          (rstn),
        .ext_events_i    (4'b0),
        .data_tx_i       (data_tx),
        .data_tx_valid_i (data_tx_valid),
        .data_tx_ready_o (data_tx_ready),
        .data_rx_o       (),
        .data_rx_valid_o (data_rx_valid),
        .data_rx_ready_i (1'b1),
        .sw_rst_i        (1'b0),
        .busy_o          (busy_event),
        .al_o            (al_event),
        .err_o           (status_event),
        .scl_i           (scl_i),
        .scl_o           (),
        .scl_oe          (scl_oe),
        .sda_i           (sda_i),
        .sda_o           (),
        .sda_oe          (sda_oe)
    );

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            busy_event_count   <= 0;
            al_event_count     <= 0;
            status_event_count <= 0;
        end else begin
            if (busy_event)
                busy_event_count <= busy_event_count + 1;
            if (al_event)
                al_event_count <= al_event_count + 1;
            if (status_event)
                status_event_count <= status_event_count + 1;

            if (status_event !== (busy_event | al_event))
                $fatal(1, "err_o must remain busy_rise | arbitration_lost_rise");
        end
    end

    task automatic wait_for_count(input int kind, input int expected);
        int timeout;
        begin
            timeout = 0;
            while ((timeout < 80) &&
                   (((kind == BUSY_COUNTER) && (busy_event_count < expected)) ||
                    ((kind == AL_COUNTER) && (al_event_count < expected)) ||
                    ((kind == EVENT_COUNTER) && (status_event_count < expected)))) begin
                @(posedge clk);
                #1;
                timeout++;
            end

            if (((kind == BUSY_COUNTER) && (busy_event_count != expected)) ||
                ((kind == AL_COUNTER) && (al_event_count != expected)) ||
                ((kind == EVENT_COUNTER) && (status_event_count != expected)))
                $fatal(1, "event counter %0d did not reach %0d", kind, expected);
        end
    endtask

    task automatic send_byte(input logic [7:0] value);
        int timeout;
        begin
            @(negedge clk);
            data_tx       = value;
            data_tx_valid = 1'b1;
            timeout       = 0;
            while (!data_tx_ready && (timeout < 20)) begin
                @(negedge clk);
                timeout++;
            end
            if (!data_tx_ready)
                $fatal(1, "controller did not accept command byte %02h", value);
            @(posedge clk);
            @(negedge clk);
            data_tx_valid = 1'b0;
            data_tx       = '0;
        end
    endtask

    task automatic external_start;
        begin
            if (!scl_i || !sda_i)
                $fatal(1, "bus must be idle before external START");
            @(negedge clk);
            ext_sda_low = 1'b1;
        end
    endtask

    task automatic external_stop;
        begin
            if (!scl_i || sda_i)
                $fatal(1, "SCL must be high and SDA low before external STOP");
            @(negedge clk);
            ext_sda_low = 1'b0;
        end
    endtask

    task automatic unexpected_stop;
        begin
            // Move SDA low while SCL is low so this setup is not interpreted
            // as another START, then release SDA after SCL returns high.
            @(negedge clk);
            ext_scl_low = 1'b1;
            repeat (6) @(posedge clk);
            ext_sda_low = 1'b1;
            repeat (6) @(posedge clk);
            ext_scl_low = 1'b0;
            repeat (6) @(posedge clk);
            if (!scl_i || sda_i)
                $fatal(1, "unexpected STOP setup did not reach SCL=1, SDA=0");
            ext_sda_low = 1'b0;
        end
    endtask

    initial begin
        clk           = 1'b0;
        rstn          = 1'b0;
        data_tx       = '0;
        data_tx_valid = 1'b0;
        ext_scl_low   = 1'b0;
        ext_sda_low   = 1'b0;

        repeat (4) @(posedge clk);
        rstn = 1'b1;
        repeat (4) @(posedge clk);

        external_start();
        wait_for_count(BUSY_COUNTER, 1);
        wait_for_count(EVENT_COUNTER, 1);
        external_stop();
        repeat (12) @(posedge clk);
        if (busy_event_count != 1 || al_event_count != 0 || status_event_count != 1)
            $fatal(1, "normal STOP must not generate a status event");

        // A long WAIT command keeps the bus controller out of IDLE. An
        // externally generated STOP in that state is arbitration loss.
        send_byte(8'hE0);
        send_byte(8'h00);
        send_byte(8'h20);
        send_byte(8'hA0);
        send_byte(8'hFF);
        repeat (4) @(posedge clk);
        unexpected_stop();
        wait_for_count(AL_COUNTER, 1);
        wait_for_count(EVENT_COUNTER, 2);

        if (data_rx_valid)
            $fatal(1, "status testing must not create RX data");

        $display("PASS: uDMA I2C BUSY/arbitration-lost status sources");
        $finish;
    end

endmodule
