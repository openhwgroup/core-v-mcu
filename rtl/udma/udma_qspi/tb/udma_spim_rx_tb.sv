// Copyright 2026 Nathan Chandrasekar
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

`timescale 1ns/1ps

module udma_spim_rx_tb;

    logic clk = 1'b0;
    logic rstn = 1'b0;
    logic cpol = 1'b0;
    logic cpha = 1'b0;
    logic start = 1'b0;
    logic qpi = 1'b0;
    logic lsb = 1'b0;
    logic [15:0] size;
    logic [4:0] bitsword;
    logic [1:0] wordtransf;
    logic [3:0] sdi = '0;
    logic spi_clk;
    logic [31:0] data_rx;
    logic valid;
    logic done;

    bit active = 1'b0;
    bit finished;
    int width;
    int packwords;
    int symbols;
    int received;
    int errors = 0;
    int cases = 0;

    always #5 clk = ~clk;

    udma_spim_txrx dut (
        .clk_i              (clk),
        .rstn_i             (rstn),
        .cfg_cpol_i         (cpol),
        .cfg_cpha_i         (cpha),
        .tx_start_i         (1'b0),
        .tx_size_i          (16'b0),
        .tx_qpi_i           (1'b0),
        .tx_bitsword_i      (5'b0),
        .tx_wordtransf_i    (2'b0),
        .tx_lsbfirst_i      (1'b0),
        .tx_done_o          (),
        .tx_data_i          (32'b0),
        .tx_data_valid_i    (1'b0),
        .tx_data_ready_o    (),
        .rx_start_i         (start),
        .rx_size_i          (size),
        .rx_qpi_i           (qpi),
        .rx_bitsword_i      (bitsword),
        .rx_wordtransf_i    (wordtransf),
        .rx_lsbfirst_i      (lsb),
        .rx_done_o          (done),
        .rx_data_o          (data_rx),
        .rx_data_valid_o    (valid),
        .rx_data_ready_i    (1'b1),
        .spi_clk_o          (spi_clk),
        .spi_oe0_o          (),
        .spi_oe1_o          (),
        .spi_oe2_o          (),
        .spi_oe3_o          (),
        .spi_sdo0_o         (),
        .spi_sdo1_o         (),
        .spi_sdo2_o         (),
        .spi_sdo3_o         (),
        .spi_sdi0_i         (sdi[0]),
        .spi_sdi1_i         (sdi[1]),
        .spi_sdi2_i         (sdi[2]),
        .spi_sdi3_i         (sdi[3])
    );

    function automatic logic [31:0] source_word(input int index);
        source_word = (32'he7c35a91 ^ (32'h01020408 * index)) & (32'hffffffff >> (32 - width));
    endfunction

    task automatic drive_symbol;
        int lanes;
        int shift;
        logic [31:0] value;
        lanes = qpi ? 4 : 1;
        value = source_word(symbols / (width / lanes));
        shift = lanes * (symbols % (width / lanes));
        if (!lsb)
            shift = width - lanes - shift;
        sdi = '0;
        if (qpi)
            sdi = 4'(value >> shift);
        else
            sdi[1] = value[shift];
    endtask

    // Change data on the SPI shift edge and count symbols on the sample edge.
    always @(spi_clk) begin
        if (active && rstn) begin
            if ((spi_clk ^ cpol) == cpha)
                drive_symbol();
            else
                symbols++;
        end
    end

    always @(posedge clk) begin
        if (active && rstn) begin
            if (valid) begin
                logic [31:0] expected;
                expected = '0;
                for (int j = 0; j < packwords; j++)
                    expected |= source_word(received * packwords + j) << ((32 / packwords) * j);
                if (data_rx !== expected) begin
                    $display("FAIL: mode=%0d qpi=%b lsb=%b bits=%0d pack=%0d word=%0d expected=%08x got=%08x",
                             {cpol, cpha}, qpi, lsb, width, packwords, received, expected, data_rx);
                    errors++;
                end
                received++;
            end
            if (done)
                finished = 1'b1;
        end
    end

    task automatic receive_words(input int mode, input bit quad, input bit lsbfirst,
                                 input int nbits, input int packing);
        active = 1'b0;
        rstn = 1'b0;
        start = 1'b0;
        cpol = 1'(mode >> 1);
        cpha = 1'(mode);
        qpi = quad;
        lsb = lsbfirst;
        width = nbits;
        packwords = packing;
        // Word size and count are encoded as N-1.
        bitsword = 5'(nbits - 1);
        size = 16'(2 * packing - 1);
        wordtransf = 2'(packing - 1);
        symbols = 0;
        received = 0;
        finished = 1'b0;
        repeat (4) @(negedge clk);
        rstn = 1'b1;
        repeat (2) @(negedge clk);
        drive_symbol();
        active = 1'b1;
        start = 1'b1;
        @(negedge clk);
        start = 1'b0;
        wait (finished);
        repeat (3) @(negedge clk);
        active = 1'b0;
        if (received != 2)
            $fatal(1, "expected two DMA transfers, got %0d", received);
        if (symbols != 2 * packing * nbits / (quad ? 4 : 1))
            $fatal(1, "unexpected SPI sample count: %0d", symbols);
        cases++;
    endtask

    initial begin
        for (int mode = 0; mode < 4; mode++)
            for (int quad = 0; quad < 2; quad++)
                for (int order = 0; order < 2; order++) begin
                    receive_words(mode, 1'(quad), 1'(order), 8, 1);
                    receive_words(mode, 1'(quad), 1'(order), 8, 2);
                    receive_words(mode, 1'(quad), 1'(order), 8, 4);
                    receive_words(mode, 1'(quad), 1'(order), 16, 1);
                    receive_words(mode, 1'(quad), 1'(order), 16, 2);
                    receive_words(mode, 1'(quad), 1'(order), 32, 1);
                end
        if (errors != 0)
            $fatal(1, "%0d receive mismatches in %0d cases", errors, cases);
        $display("TEST_PASS: uDMA QSPI receive (%0d cases)", cases);
        $finish;
    end

    initial begin
        #1000000;
        $fatal(1, "timeout");
    end

endmodule
