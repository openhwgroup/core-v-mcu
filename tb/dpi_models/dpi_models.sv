/* 
 * dev_dpi.sv
 * Germain Haugou <haugoug@iis.ee.ethz.ch>
 *
 * Copyright (C) 2013-2018 ETH Zurich, University of Bologna.
 *
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 */

interface QSPI_CS  ();

  logic csn;

endinterface



interface QSPI ();

  logic sck;
  logic data_0_in;
  logic data_0_out;
  logic data_1_in;
  logic data_1_out;
  logic data_2_in;
  logic data_2_out;
  logic data_3_in;
  logic data_3_out;

endinterface


interface GPIO ();

  logic data_in;
  logic data_out;

endinterface



interface JTAG ();

  logic tck;
  logic tdi;
  logic tdo;
  logic tms;
  logic trst;

endinterface


interface UART ();

  logic tx;
  logic rx;

endinterface


interface CPI ();

  logic pclk;
  logic href;
  logic vsync;
  logic data[7:0];

endinterface


interface I2S ();

  logic sck_in;
  logic sck_out;
  logic ws_in;
  logic ws_out;
  logic sdi;

endinterface



interface CTRL ();

  logic reset;
  logic configs[32:0];

endinterface



package dpi_models;
  `timescale 1ns / 1ps

  event task_event_wait;

  virtual JTAG    jtag_itf_array[];
  int             nb_jtag_itf = 0;

  virtual UART    uart_itf_array[];
  int             nb_uart_itf = 0;

  virtual CPI     cpi_itf_array[];
  int             nb_cpi_itf = 0;

  virtual I2S     i2s_itf_array[];
  int             nb_i2s_itf = 0;

  virtual CTRL    ctrl_itf_array[];
  int             nb_ctrl_itf = 0;

  virtual QSPI    qspim_itf_array[];
  int             nb_qspim_itf = 0;

  virtual GPIO    gpio_itf_array[];
  int             nb_gpio_itf = 0;


  import "DPI-C"   context function void dpi_uart_edge(chandle handle, longint timestamp, longint data);
  import "DPI-C"   context function void dpi_qspim_cs_edge(chandle handle, longint timestamp, input logic csn);
  import "DPI-C"   context function void dpi_qspim_sck_edge(chandle handle, longint timestamp, input logic sck, input logic data_0, input logic data_1, input logic data_2, input logic data_3, input int mask);
  import "DPI-C"   context function void dpi_i2s_edge(chandle handle, longint timestamp, input logic sck, input logic ws, input logic sdi);
  import "DPI-C"   context function void dpi_gpio_edge(chandle handle, longint timestamp, input logic data);
  import "DPI-C"   context function chandle dpi_qspim_bind(chandle dpi_model, string name, int handle);
  import "DPI-C"   context function chandle dpi_gpio_bind(chandle dpi_model, string name, int handle);
  import "DPI-C"   context function chandle dpi_jtag_bind(chandle dpi_model, string name, int handle);
  import "DPI-C"   context function chandle dpi_uart_bind(chandle dpi_model, string name, int handle);
  import "DPI-C"   context function chandle dpi_cpi_bind(chandle dpi_model, string name, int handle);
  import "DPI-C"   context function chandle dpi_i2s_bind(chandle dpi_model, string name, int handle);
  import "DPI-C"   context function chandle dpi_ctrl_bind(chandle dpi_model, string name, int handle);
  import "DPI-C"   context task dpi_start_task(int id);
  import "DPI-C"   context task dpi_exec_periodic_handler(int id);


  import "DPI-C"   context function chandle dpi_model_load(chandle comp_config, chandle handle);
  import "DPI-C"   context task dpi_model_start(chandle model);

  export "DPI-C"   task             dpi_create_task;
  export "DPI-C"   task             dpi_create_periodic_handler;
  export "DPI-C"   function         dpi_time;
  export "DPI-C"   function         dpi_print;
  export "DPI-C"   function         dpi_trace_new;
  export "DPI-C"   function         dpi_trace_msg;
  export "DPI-C"   function         dpi_fatal;
  export "DPI-C"   function         dpi_jtag_tck_edge;
  export "DPI-C"   function         dpi_uart_rx_edge;
  export "DPI-C"   function         dpi_qspim_edge;
  export "DPI-C"   function         dpi_cpi_edge;
  export "DPI-C"   function         dpi_ctrl_reset_edge;
  export "DPI-C"   function         dpi_ctrl_config_edge;
  export "DPI-C"   function         dpi_qspim_set_data;
  export "DPI-C"   function         dpi_gpio_set_data;
  export "DPI-C"   task             dpi_wait;
  export "DPI-C"   task             dpi_wait_ps;
  export "DPI-C"   task             dpi_wait_event;
  export "DPI-C"   task             dpi_raise_event;
  export "DPI-C"   task             dpi_wait_task_event;
  export "DPI-C"   task             dpi_wait_task_event_timeout;
  export "DPI-C"   function         dpi_raise_task_event;
  export "DPI-C"   function         dpi_i2s_rx_edge;

  function longint dpi_time(chandle handle);
    return $realtime * 1000;
  endfunction

  task dpi_wait(chandle handle, input longint t);
    #(t * 1ns);
  endtask

  task dpi_wait_ps(chandle handle, input longint t);
    #(t * 1ps);
  endtask

  task dpi_wait_event(chandle handle);
    #(50 * 1ns);
  endtask

  task dpi_raise_event(chandle handle);
    $display("[TB] %t - Raise event", $realtime);
  endtask

  task dpi_wait_task_event(chandle handle);
    @task_event_wait;
    //wait(task_event_wait.triggered);
  endtask

  task dpi_wait_task_event_timeout(chandle handle, longint timeout);
    fork : wait_or_timeout
      begin
        #(timeout * 1ps) ;
        disable wait_or_timeout;
      end
      begin
        @task_event_wait;
        disable wait_or_timeout;
      end
    join
  endtask

  function void dpi_raise_task_event(chandle handle);
    $display("[TB] %t - Raise event", $realtime);
    ->task_event_wait;
  endfunction

  function chandle dpi_trace_new(chandle handle, input string name);
    //$display("[TB] %t - %s", $realtime, msg);
    return null;
  endfunction : dpi_trace_new

  function void dpi_trace_msg(chandle handle, int level, input string msg);
    //$display("[TB] %t - %s", $realtime, msg);
  endfunction : dpi_trace_msg

  function void dpi_print(chandle handle, input string msg);
    //$display("[TB] %t - %s", $realtime, msg);
  endfunction : dpi_print

  function void dpi_fatal(chandle handle, input string msg);
    $fatal("[TB] %t - %s", $realtime, msg);
  endfunction : dpi_fatal


  function void dpi_jtag_tck_edge(int handle, int tck, int tdi, int tms, int trst, output int tdo);
    automatic virtual JTAG itf = jtag_itf_array[handle];
    itf.tck = tck;
    itf.tdi = tdi;
    itf.tms = tms;
    itf.trst = trst;
    tdo = itf.tdo;
  endfunction : dpi_jtag_tck_edge


  function void dpi_uart_rx_edge(int handle, int data);
    automatic virtual UART itf = uart_itf_array[handle];
    itf.tx = data;
  endfunction : dpi_uart_rx_edge


  function void dpi_i2s_rx_edge(int handle, int sck, int ws, int data);
    automatic virtual I2S itf = i2s_itf_array[handle];
    itf.sdi = data;
    itf.sck_in = sck;
    itf.ws_in = ws;
  endfunction : dpi_i2s_rx_edge


  function void dpi_qspim_edge(int handle, int data_0, int data_1, int data_2, int data_3, int mask);
    automatic virtual QSPI itf = qspim_itf_array[handle];
    itf.data_0 = data_0;
    itf.data_1 = data_1;
    itf.data_2 = data_2;
    itf.data_3 = data_3;
  endfunction : dpi_qspim_edge



  function void dpi_cpi_edge(int handle, int pclk, int href, int vsync, int data);
    automatic virtual CPI itf = cpi_itf_array[handle];
    itf.pclk = pclk;
    itf.href = href;
    itf.vsync = vsync;
    itf.data[0] = data[0];
    itf.data[1] = data[1];
    itf.data[2] = data[2];
    itf.data[3] = data[3];
    itf.data[4] = data[4];
    itf.data[5] = data[5];
    itf.data[6] = data[6];
    itf.data[7] = data[7];
  endfunction : dpi_cpi_edge






  function void dpi_ctrl_reset_edge(int handle, int reset);
    automatic virtual CTRL itf = ctrl_itf_array[handle];
    itf.reset = reset;
  endfunction : dpi_ctrl_reset_edge


  function void dpi_ctrl_config_edge(int handle, int value);
    automatic virtual CTRL itf = ctrl_itf_array[handle];
    itf.configs[0] = value;
  endfunction : dpi_ctrl_config_edge


  function void dpi_qspim_set_qpi_data(int handle, int data_0, int data_1, int data_2, int data_3);
    automatic virtual QSPI itf = qspim_itf_array[handle];
    itf.data_0_out = data_0;
    itf.data_1_out = data_1;
    itf.data_2_out = data_2;
    itf.data_3_out = data_3;
  endfunction : dpi_qspim_set_qpi_data

  function void dpi_qspim_set_data(int handle, int data);
    automatic virtual QSPI itf = qspim_itf_array[handle];
    itf.data_1_out = data;
  endfunction : dpi_qspim_set_data



  function void dpi_gpio_set_data(int handle, int data);
    automatic virtual GPIO itf = gpio_itf_array[handle];
    itf.data_out = data;
  endfunction : dpi_gpio_set_data


  task dpi_create_task(chandle handle, int id);
    $display("[TB] %t - Starting task id %d", $realtime, id);
    fork
      automatic int my_id = id;
      dpi_start_task(my_id);
    join_none
  endtask


  task dpi_create_periodic_handler(chandle handle, int id, longint period);
    $display("[TB] %t - Starting periodic handler %d", $realtime, id);
    fork
      automatic int my_id = id;
      do begin
        #(period * 1ps);
        dpi_exec_periodic_handler(my_id);
      end while(1);
    join_none
  endtask


  class periph_wrapper #(int NB_SPIS_CHANNELS = 0);

    virtual QSPI    qspi_itf;
    virtual QSPI_CS qspi_cs_itf;
    chandle dpi_model;

    function int load_model(chandle comp_config);
      dpi_model = dpi_model_load(comp_config, null);
      if (dpi_model == null) return -1;
      return 0;
    endfunction

    task start_model();
      dpi_model_start(dpi_model);
    endtask


    task jtag_bind(string name, virtual JTAG jtag_itf);
      chandle dpi_context;

      jtag_itf.tck = 'b1;
      jtag_itf.tdi = 'b1;
      jtag_itf.tms = 'b1;
      jtag_itf.trst = 'b1;

      nb_jtag_itf = nb_jtag_itf + 1;
      jtag_itf_array = new[nb_jtag_itf](jtag_itf_array);
      jtag_itf_array[nb_jtag_itf - 1] = jtag_itf;

      dpi_context = dpi_jtag_bind(dpi_model, name, nb_jtag_itf - 1);
    endtask

    task uart_bind(string name, virtual UART uart_itf);
      chandle dpi_handle;

      uart_itf.tx = 'b1;

      nb_uart_itf = nb_uart_itf + 1;
      uart_itf_array = new[nb_uart_itf](uart_itf_array);
      uart_itf_array[nb_uart_itf - 1] = uart_itf;

      dpi_handle = dpi_uart_bind(dpi_model, name, nb_uart_itf - 1);

      fork
      do begin
        @(negedge uart_itf.rx or posedge uart_itf.rx);
        dpi_uart_edge(dpi_handle, $realtime*1000, uart_itf.rx);
      end while(1);
      join_none
    endtask


    task cpi_bind(string name, virtual CPI cpi_itf);
      chandle dpi_handle;

      nb_cpi_itf = nb_cpi_itf + 1;
      cpi_itf_array = new[nb_cpi_itf](cpi_itf_array);
      cpi_itf_array[nb_cpi_itf - 1] = cpi_itf;

      dpi_handle = dpi_cpi_bind(dpi_model, name, nb_cpi_itf - 1);
    endtask



    task i2s_bind(string name, virtual I2S i2s_itf);
      chandle dpi_handle;

      nb_i2s_itf = nb_i2s_itf + 1;
      i2s_itf_array = new[nb_i2s_itf](i2s_itf_array);
      i2s_itf_array[nb_i2s_itf - 1] = i2s_itf;

      dpi_handle = dpi_i2s_bind(dpi_model, name, nb_i2s_itf - 1);

      i2s_itf.sck_out = 1'bZ;
      i2s_itf.ws_out = 1'bZ;
      i2s_itf.sdi = 1'b0;

      fork
      do begin
        @(posedge i2s_itf.sck_in or negedge i2s_itf.sck_in);
        dpi_i2s_edge(dpi_handle, $realtime*1000, i2s_itf.sck_in, i2s_itf.ws_in, 1'b0);
      end while(1);
      join_none
    endtask



    task ctrl_bind(string name, virtual CTRL ctrl_itf);
      chandle dpi_context;

      $display("[TB] %t - SETTING RESET TO 1", $realtime);
      ctrl_itf.reset = 'b1;
      ctrl_itf.configs[0] = 'b0;

      nb_ctrl_itf = nb_ctrl_itf + 1;
      ctrl_itf_array = new[nb_ctrl_itf](ctrl_itf_array);
      ctrl_itf_array[nb_ctrl_itf - 1] = ctrl_itf;

      dpi_context = dpi_ctrl_bind(dpi_model, name, nb_ctrl_itf - 1);
    endtask


    task qpim_bind(string name, virtual QSPI qspi_itf, virtual QSPI_CS qspi_cs_itf);

      chandle dpi_handle;

      nb_qspim_itf = nb_qspim_itf + 1;
      qspim_itf_array = new[nb_qspim_itf](qspim_itf_array);
      qspim_itf_array[nb_qspim_itf - 1] = qspi_itf;

      dpi_handle = dpi_qspim_bind(dpi_model, name, nb_qspim_itf - 1);

      this.qspi_itf = qspi_itf;
      this.qspi_cs_itf = qspi_cs_itf;
      fork
      do begin

        qspi_itf.data_0_out = 1'bZ;
        qspi_itf.data_1_out = 1'bZ;
        qspi_itf.data_2_out = 1'bZ;
        qspi_itf.data_3_out = 1'bZ;

        @(negedge qspi_cs_itf.csn);
        dpi_qspim_cs_edge(dpi_handle, $realtime*1000, qspi_cs_itf.csn);

        do begin
          @(posedge qspi_itf.sck or negedge qspi_itf.sck or posedge qspi_cs_itf.csn);

          if (qspi_cs_itf.csn == 1'b0) begin
            dpi_qspim_sck_edge(dpi_handle, $realtime*1000, qspi_itf.sck,
              qspi_itf.data_0_in, qspi_itf.data_1_in, qspi_itf.data_2_in,
              qspi_itf.data_3_in, 0
            );
          end

        end while (qspi_cs_itf.csn == 1'b0);

        dpi_qspim_cs_edge(dpi_handle, $realtime*1000, qspi_cs_itf.csn);

      end while(1);
      join_none
    endtask



    task gpio_bind(string name, virtual GPIO gpio_itf);

      chandle dpi_handle;

      nb_gpio_itf = nb_gpio_itf + 1;
      gpio_itf_array = new[nb_gpio_itf](gpio_itf_array);
      gpio_itf_array[nb_gpio_itf - 1] = gpio_itf;

      dpi_handle = dpi_gpio_bind(dpi_model, name, nb_gpio_itf - 1);

      gpio_itf.data_out = 1'bZ;
    endtask




    task toggle () ;
      do begin
      end while(1);
    endtask


  endclass

endpackage
