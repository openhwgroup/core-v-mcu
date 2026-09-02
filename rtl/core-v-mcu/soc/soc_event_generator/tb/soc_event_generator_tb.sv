// Copyright (c) 2026 Shivam Tiwari
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

`timescale 1ns/1ps

// Self-checking regression for the APB event controller FC FIFO path.
// Events 7 and 8 also drive the unused direct output; verify that their
// software-visible delivery remains through IRQ 11 and the event ID FIFO.
module soc_event_generator_tb;

  localparam int APB_ADDR_WIDTH = 12;
  localparam int PER_EVNT_NUM   = 160;
  localparam int APB_EVNT_NUM   = 8;
  localparam int EVNT_WIDTH     = 8;
  localparam int FC_EVENT_POS   = 7;

  localparam logic [APB_ADDR_WIDTH-1:0] REG_FC_MASK_0_ADDR = 12'h004;
  localparam logic [APB_ADDR_WIDTH-1:0] REG_FIFO_ADDR     = 12'h090;
  localparam logic [EVNT_WIDTH-1:0] UART1_ERR_EVENT_ID    = 8'd7;
  localparam logic [EVNT_WIDTH-1:0] QSPI0_RX_EVENT_ID     = 8'd8;
  localparam logic [4:0] SOC_EVENT_IRQ_ID                 = 5'd11;
  localparam logic [4:0] EFPGA_EVENT_5_IRQ_ID             = 5'd30;
  localparam logic [4:0] EVENT_QUEUE_ERROR_IRQ_ID         = 5'd31;
  localparam logic [31:0] FC_MASK_UART1_ERR_ONLY          = 32'hFFFF_FF7F;
  localparam logic [31:0] FC_MASK_QSPI0_RX_ONLY           = 32'hFFFF_FEFF;
  localparam logic [31:0] FC_MASK_TARGET_EVENTS           = 32'hFFFF_FE7F;

  logic                      HCLK;
  logic                      HRESETn;
  logic [APB_ADDR_WIDTH-1:0] PADDR;
  logic [31:0]               PWDATA;
  logic                      PWRITE;
  logic                      PSEL;
  logic                      PENABLE;
  logic [31:0]               PRDATA;
  logic                      PREADY;
  logic                      PSLVERR;
  logic                      low_speed_clk_i;
  logic [PER_EVNT_NUM-1:0]   per_events_i;
  logic [1:0]                fc_events_o;
  logic [4:0]                core_irq_ack_id_i;
  logic                      core_irq_ack_i;
  logic                      event_fifo_valid_o;
  logic                      err_event_o;
  logic                      timer_event_lo_o;
  logic                      timer_event_hi_o;
  logic                      cl_event_valid_o;
  logic [EVNT_WIDTH-1:0]     cl_event_data_o;
  logic                      cl_event_ready_i;
  logic                      pr_event_valid_o;
  logic [EVNT_WIDTH-1:0]     pr_event_data_o;
  logic                      pr_event_ready_i;

  integer failures;

  soc_event_generator #(
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
      .PER_EVNT_NUM  (PER_EVNT_NUM),
      .APB_EVNT_NUM  (APB_EVNT_NUM),
      .EVNT_WIDTH    (EVNT_WIDTH),
      .FC_EVENT_POS  (FC_EVENT_POS)
  ) dut (
      .HCLK,
      .HRESETn,
      .PADDR,
      .PWDATA,
      .PWRITE,
      .PSEL,
      .PENABLE,
      .PRDATA,
      .PREADY,
      .PSLVERR,
      .low_speed_clk_i,
      .per_events_i,
      .fc_events_o,
      .core_irq_ack_id_i,
      .core_irq_ack_i,
      .event_fifo_valid_o,
      .err_event_o,
      .timer_event_lo_o,
      .timer_event_hi_o,
      .cl_event_valid_o,
      .cl_event_data_o,
      .cl_event_ready_i,
      .pr_event_valid_o,
      .pr_event_data_o,
      .pr_event_ready_i
  );

  always #5 HCLK = ~HCLK;

  task automatic check(input logic condition, input string message);
    begin
      if (condition !== 1'b1) begin
        failures = failures + 1;
        $error("CHECK FAILED: %s", message);
      end
    end
  endtask

  task automatic apb_write(
      input logic [APB_ADDR_WIDTH-1:0] address,
      input logic [31:0]               data
  );
    begin
      @(negedge HCLK);
      PADDR   = address;
      PWDATA  = data;
      PWRITE  = 1'b1;
      PSEL    = 1'b1;
      PENABLE = 1'b0;

      @(negedge HCLK);
      PENABLE = 1'b1;

      @(posedge HCLK);
      #1;
      check(PREADY === 1'b1, "APB write must complete with PREADY high");
      check(PSLVERR === 1'b0, "APB write must not assert PSLVERR");

      @(negedge HCLK);
      PADDR   = '0;
      PWDATA  = '0;
      PWRITE  = 1'b0;
      PSEL    = 1'b0;
      PENABLE = 1'b0;
    end
  endtask

  task automatic apb_read(
      input  logic [APB_ADDR_WIDTH-1:0] address,
      output logic [31:0]               data
  );
    begin
      @(negedge HCLK);
      PADDR   = address;
      PWDATA  = '0;
      PWRITE  = 1'b0;
      PSEL    = 1'b1;
      PENABLE = 1'b0;

      @(negedge HCLK);
      PENABLE = 1'b1;

      @(posedge HCLK);
      #1;
      data = PRDATA;
      check(PREADY === 1'b1, "APB read must complete with PREADY high");
      check(PSLVERR === 1'b0, "APB read must not assert PSLVERR");

      @(negedge HCLK);
      PADDR   = '0;
      PSEL    = 1'b0;
      PENABLE = 1'b0;
    end
  endtask

  task automatic pulse_event(input integer event_id);
    logic [1:0] expected_direct_event;
    begin
      expected_direct_event = 2'b01 << (event_id - FC_EVENT_POS);

      @(negedge HCLK);
      per_events_i[event_id] = 1'b1;
      #1;
      check(fc_events_o === expected_direct_event,
            "Direct high-priority output must mirror peripheral event 7 or 8");

      @(negedge HCLK);
      per_events_i[event_id] = 1'b0;
      #1;
      check(fc_events_o === 2'b00,
            "Direct high-priority output must deassert with the peripheral event");
    end
  endtask

  task automatic pulse_events_7_and_8;
    begin
      @(negedge HCLK);
      per_events_i[UART1_ERR_EVENT_ID] = 1'b1;
      per_events_i[QSPI0_RX_EVENT_ID]  = 1'b1;
      #1;
      check(fc_events_o === 2'b11,
            "Both direct high-priority outputs must mirror simultaneous events");

      @(negedge HCLK);
      per_events_i[UART1_ERR_EVENT_ID] = 1'b0;
      per_events_i[QSPI0_RX_EVENT_ID]  = 1'b0;
      #1;
      check(fc_events_o === 2'b00,
            "Both direct high-priority outputs must deassert after the event pulse");
    end
  endtask

  task automatic wait_for_fifo_valid(input integer maximum_cycles);
    integer elapsed_cycles;
    begin
      elapsed_cycles = 0;
      while ((event_fifo_valid_o !== 1'b1) && (elapsed_cycles < maximum_cycles)) begin
        @(posedge HCLK);
        #1;
        elapsed_cycles = elapsed_cycles + 1;
      end
      check(event_fifo_valid_o === 1'b1,
            "IRQ 11 source event_fifo_valid_o must assert before timeout");
    end
  endtask

  task automatic acknowledge_irq(input logic [4:0] irq_id);
    begin
      @(negedge HCLK);
      core_irq_ack_id_i = irq_id;
      core_irq_ack_i    = 1'b1;

      @(posedge HCLK);
      #1;

      @(negedge HCLK);
      core_irq_ack_i    = 1'b0;
      core_irq_ack_id_i = '0;
    end
  endtask

  initial begin : test_sequence
    logic [31:0] read_data;
    logic [7:0]  first_event_id;
    logic [7:0]  second_event_id;

    HCLK                = 1'b0;
    HRESETn             = 1'b0;
    PADDR               = '0;
    PWDATA              = '0;
    PWRITE              = 1'b0;
    PSEL                = 1'b0;
    PENABLE             = 1'b0;
    low_speed_clk_i     = 1'b0;
    per_events_i        = '0;
    core_irq_ack_id_i   = '0;
    core_irq_ack_i      = 1'b0;
    cl_event_ready_i    = 1'b1;
    pr_event_ready_i    = 1'b1;
    failures            = 0;

    if ($test$plusargs("DUMP")) begin
      $dumpfile("soc_event_generator_tb.vcd");
      $dumpvars(0, soc_event_generator_tb);
    end

    repeat (4) @(posedge HCLK);
    @(negedge HCLK);
    HRESETn = 1'b1;
    repeat (2) @(posedge HCLK);
    #1;

    check(event_fifo_valid_o === 1'b0, "IRQ 11 source must be low after reset");
    check(err_event_o === 1'b0, "Queue overflow interrupt must be low after reset");
    check(fc_events_o === 2'b00, "Direct event output must be low after reset");
    check(cl_event_valid_o === 1'b0, "Cluster event channel must remain masked");
    check(pr_event_valid_o === 1'b0, "Peripheral event channel must remain masked");

    apb_read(REG_FC_MASK_0_ADDR, read_data);
    check(read_data === 32'hFFFF_FFFF, "All FC events must be masked after reset");

    // A masked event must be consumed without entering the FC FIFO.
    pulse_event(UART1_ERR_EVENT_ID);
    repeat (6) @(posedge HCLK);
    #1;
    check(event_fifo_valid_o === 1'b0, "Masked event 7 must not assert IRQ 11");
    check(err_event_o === 1'b0, "A single masked event must not overflow its queue");

    pulse_event(QSPI0_RX_EVENT_ID);
    repeat (6) @(posedge HCLK);
    #1;
    check(event_fifo_valid_o === 1'b0, "Masked event 8 must not assert IRQ 11");
    check(err_event_o === 1'b0, "A second masked event must not overflow its queue");

    // Unmask only event 7 and verify the complete IRQ 11/FIFO transaction.
    apb_write(REG_FC_MASK_0_ADDR, FC_MASK_UART1_ERR_ONLY);
    apb_read(REG_FC_MASK_0_ADDR, read_data);
    check(read_data === FC_MASK_UART1_ERR_ONLY, "FC mask must unmask only event 7");

    pulse_event(UART1_ERR_EVENT_ID);
    wait_for_fifo_valid(12);
    check(err_event_o === 1'b0, "Event 7 must not overflow its source queue");

    apb_read(REG_FIFO_ADDR, read_data);
    check(read_data[7:0] === 8'd0,
          "FIFO CSR must retain its reset value until IRQ 11 is acknowledged");

    acknowledge_irq(EFPGA_EVENT_5_IRQ_ID);
    check(event_fifo_valid_o === 1'b1, "IRQ 30 acknowledgment must not pop the FC FIFO");
    acknowledge_irq(EVENT_QUEUE_ERROR_IRQ_ID);
    check(event_fifo_valid_o === 1'b1, "IRQ 31 acknowledgment must not pop the FC FIFO");

    acknowledge_irq(SOC_EVENT_IRQ_ID);
    check(event_fifo_valid_o === 1'b0, "IRQ 11 must clear after the only FIFO entry is popped");
    apb_read(REG_FIFO_ADDR, read_data);
    check(read_data[7:0] === UART1_ERR_EVENT_ID,
          "FIFO CSR must report event ID 7 after acknowledgment");

    // Unmask only event 8 and repeat the transaction.
    apb_write(REG_FC_MASK_0_ADDR, FC_MASK_QSPI0_RX_ONLY);
    apb_read(REG_FC_MASK_0_ADDR, read_data);
    check(read_data === FC_MASK_QSPI0_RX_ONLY, "FC mask must unmask only event 8");

    pulse_event(QSPI0_RX_EVENT_ID);
    wait_for_fifo_valid(12);
    apb_read(REG_FIFO_ADDR, read_data);
    check(read_data[7:0] === UART1_ERR_EVENT_ID,
          "FIFO CSR must keep the previous ID until the next IRQ 11 acknowledgment");

    acknowledge_irq(SOC_EVENT_IRQ_ID);
    check(event_fifo_valid_o === 1'b0, "IRQ 11 must clear after event 8 is popped");
    apb_read(REG_FIFO_ADDR, read_data);
    check(read_data[7:0] === QSPI0_RX_EVENT_ID,
          "FIFO CSR must report event ID 8 after acknowledgment");
    check(err_event_o === 1'b0, "Event 8 must not overflow its source queue");

    // Verify that both events can coexist in the four-entry FC FIFO.
    apb_write(REG_FC_MASK_0_ADDR, FC_MASK_TARGET_EVENTS);
    pulse_events_7_and_8();
    wait_for_fifo_valid(12);
    repeat (4) @(posedge HCLK);
    #1;

    acknowledge_irq(SOC_EVENT_IRQ_ID);
    check(event_fifo_valid_o === 1'b1,
          "IRQ 11 must remain asserted while a second FIFO entry is pending");
    apb_read(REG_FIFO_ADDR, read_data);
    first_event_id = read_data[7:0];

    acknowledge_irq(SOC_EVENT_IRQ_ID);
    check(event_fifo_valid_o === 1'b0, "IRQ 11 must clear after both entries are popped");
    apb_read(REG_FIFO_ADDR, read_data);
    second_event_id = read_data[7:0];

    check(((first_event_id == UART1_ERR_EVENT_ID) &&
           (second_event_id == QSPI0_RX_EVENT_ID)) ||
          ((first_event_id == QSPI0_RX_EVENT_ID) &&
           (second_event_id == UART1_ERR_EVENT_ID)),
          "Simultaneous events must produce exactly one FIFO entry for IDs 7 and 8");
    check(err_event_o === 1'b0, "Normal event 7/8 traffic must not assert queue overflow");
    check(cl_event_valid_o === 1'b0, "Cluster output must remain masked throughout the test");
    check(pr_event_valid_o === 1'b0, "Peripheral output must remain masked throughout the test");

    if (failures == 0) begin
      $display("TEST_PASS: soc_event_generator IRQ 11/FIFO regression completed successfully");
      $finish;
    end else begin
      $fatal(1, "TEST_FAIL: soc_event_generator regression found %0d failure(s)", failures);
    end
  end

  initial begin : watchdog
    #10000;
    $fatal(1, "TEST_TIMEOUT: soc_event_generator regression did not complete");
  end

endmodule  // soc_event_generator_tb
