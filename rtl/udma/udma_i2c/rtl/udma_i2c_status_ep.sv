// Copyright 2026 Shivam Tiwari
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

// The I2C controller generates one-cycle BUSY-rise, arbitration-lost, and
// combined status-event pulses in the periph_clk_i domain. The register
// interface and err_o consume those pulses in the asynchronous sys_clk_i
// domain. This module uses acknowledged edge propagators so short source
// pulses are transferred safely without being missed. BUSY and AL remain
// separate for the STATUS fields, while event_i preserves the legacy
// combined-event behavior when both causes occur together.
module udma_i2c_status_ep (
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
