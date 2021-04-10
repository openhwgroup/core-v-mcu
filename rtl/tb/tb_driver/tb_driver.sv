/* 
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

package tb_driver;

  import "DPI-C"   function chandle dpi_config_get_from_file(string path);
  import "DPI-C"   function chandle dpi_config_get_config(chandle config_handle, string path);
  import "DPI-C"   function int dpi_config_get_int(chandle config_handle);
  import "DPI-C"   function string dpi_config_get_str(chandle config_handle);

  import "DPI-C"   function chandle dpi_driver_set_config(chandle config_handle);
  import "DPI-C"   function int dpi_driver_get_nb_comp(chandle driver_handle);
  import "DPI-C"   function string dpi_driver_get_comp_name(chandle driver_handle, int index);
  import "DPI-C"   function chandle dpi_driver_get_comp_config(chandle driver_handle, int index);
  import "DPI-C"   function int dpi_driver_get_comp_nb_itf(chandle comp_handle, int index);
  import "DPI-C"   function void dpi_driver_get_comp_itf_info(chandle comp_handle, int index, int itf_index, output string itf_name, output string itf_type, output int itf_id, output int itf_sub_id);

  typedef struct { 
    virtual QSPI itf;
    virtual QSPI_CS cs[];
  } qspi_info_t;

  typedef struct { 
    virtual JTAG itf;
  } jtag_info_t;

  typedef struct { 
    virtual UART itf;
  } uart_info_t;

  typedef struct { 
    virtual CPI itf;
  } cpi_info_t;

  typedef struct { 
    virtual I2S itf;
  } i2s_info_t;

  typedef struct { 
    virtual CTRL itf;
  } ctrl_info_t;

  typedef struct { 
    virtual GPIO itf;
  } gpio_info_t;

  class tb_driver;

    chandle config_handle;

    qspi_info_t qspi_infos[];
    jtag_info_t jtag_infos[];
    uart_info_t uart_infos[];
    cpi_info_t cpi_infos[];
    i2s_info_t i2s_infos[];
    ctrl_info_t ctrl_infos[];
    gpio_info_t gpio_infos[];

    function void register_qspim_itf(int itf_id, virtual QSPI itf, virtual QSPI_CS cs[]);
      qspi_infos = new[itf_id+1] (qspi_infos);
      qspi_infos[itf_id].itf = itf;
      qspi_infos[itf_id].cs = cs;
      //qspi_infos[itf_id].cs = new[cs.size] (cs);
    endfunction

    function void register_gpio_itf(int itf_id, virtual GPIO itf);
      gpio_infos = new[itf_id+1] (gpio_infos);
      gpio_infos[itf_id].itf = itf;
    endfunction

    function void register_jtag_itf(int itf_id, virtual JTAG itf);
      jtag_infos = new[itf_id+1] (jtag_infos);
      jtag_infos[itf_id].itf = itf;
    endfunction

    function void register_uart_itf(int itf_id, virtual UART itf);
      uart_infos = new[itf_id+1] (uart_infos);
      uart_infos[itf_id].itf = itf;
    endfunction

    function void register_cpi_itf(int itf_id, virtual CPI itf);
      cpi_infos = new[itf_id+1] (cpi_infos);
      cpi_infos[itf_id].itf = itf;
    endfunction

    function void register_i2s_itf(int itf_id, virtual I2S itf);
      i2s_infos = new[itf_id+1] (i2s_infos);
      i2s_infos[itf_id].itf = itf;
    endfunction

    function void register_ctrl_itf(int itf_id, virtual CTRL itf);
      ctrl_infos = new[itf_id+1] (ctrl_infos);
      ctrl_infos[itf_id].itf = itf;
    endfunction

    task build_from_json(string path);

      int nb_comp;
      chandle driver_handle;

      config_handle = dpi_config_get_from_file(path);

      driver_handle = dpi_driver_set_config(config_handle);
      nb_comp = dpi_driver_get_nb_comp(driver_handle);

      for(int i = 0; i < nb_comp; i++) begin
        string comp_name = dpi_driver_get_comp_name(driver_handle, i);
        chandle comp_config = dpi_driver_get_comp_config(driver_handle, i);
        string comp_type = dpi_config_get_str(dpi_config_get_config(comp_config, "type"));
        int nb_itf = dpi_driver_get_comp_nb_itf(comp_config, i);

        $display("[TB] %t - Found TB driver component (index: %d, name: %s, type: %s)", $realtime, i, comp_name, comp_type);

        if (comp_type == "dpi") begin
          dpi_models::periph_wrapper i_comp = new();
          int err;

          $display("[TB] %t - Instantiating DPI component", $realtime);

          err = i_comp.load_model(comp_config);
          if (err != 0) $fatal(1, "[TB] %t - Failed to instantiate periph model", $realtime);


          i_comp.start_model();

          for(int j = 0; j < nb_itf; j++) begin
            string itf_type;
            string itf_name;
            int itf_id;
            int itf_sub_id;
            dpi_driver_get_comp_itf_info(comp_config, i, j, itf_name, itf_type, itf_id, itf_sub_id);
            $display("[TB] %t - Got interface information (index: %d, name: %s, type: %s, id: %d, sub_id: %d)", $realtime, i, itf_name, itf_type, itf_id, itf_sub_id);

            if (itf_type == "QSPIM") begin
                i_comp.qpim_bind(itf_name, qspi_infos[itf_id].itf, qspi_infos[itf_id].cs[itf_sub_id]);

            end else if (itf_type == "JTAG") begin
                i_comp.jtag_bind(itf_name, jtag_infos[itf_id].itf);

            end else if (itf_type == "UART") begin
                i_comp.uart_bind(itf_name, uart_infos[itf_id].itf);

            end else if (itf_type == "CPI") begin
                i_comp.cpi_bind(itf_name, cpi_infos[itf_id].itf);

            end else if (itf_type == "I2S") begin
                i_comp.i2s_bind(itf_name, i2s_infos[itf_id].itf);

            end else if (itf_type == "CTRL") begin
                i_comp.ctrl_bind(itf_name, ctrl_infos[itf_id].itf);

            end else if (itf_type == "GPIO") begin
                i_comp.gpio_bind(itf_name, gpio_infos[itf_id].itf);

            end

          end

        end

      end


    endtask

  endclass

endpackage
