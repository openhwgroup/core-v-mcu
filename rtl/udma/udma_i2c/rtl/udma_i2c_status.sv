// Copyright 2026 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module udma_i2c_status (
    input  logic periph_clk_i,
    input  logic sys_clk_i,
    input  logic rstn_i,

    input  logic busy_i,
    input  logic al_i,
    input  logic event_i,

    output logic busy_o,
    output logic al_o,
    output logic event_o
);

    // The source pulses can be shorter than a sys_clk_i period. The
    // acknowledged edge propagators hold each pulse until it is observed in
    // the system-clock domain.
    edge_propagator i_busy_sync (
        .clk_tx_i  (periph_clk_i),
        .rstn_tx_i (rstn_i),
        .edge_i    (busy_i),
        .clk_rx_i  (sys_clk_i),
        .rstn_rx_i (rstn_i),
        .edge_o    (busy_o)
    );

    edge_propagator i_al_sync (
        .clk_tx_i  (periph_clk_i),
        .rstn_tx_i (rstn_i),
        .edge_i    (al_i),
        .clk_rx_i  (sys_clk_i),
        .rstn_rx_i (rstn_i),
        .edge_o    (al_o)
    );

    edge_propagator i_event_sync (
        .clk_tx_i  (periph_clk_i),
        .rstn_tx_i (rstn_i),
        .edge_i    (event_i),
        .clk_rx_i  (sys_clk_i),
        .rstn_rx_i (rstn_i),
        .edge_o    (event_o)
    );

endmodule
