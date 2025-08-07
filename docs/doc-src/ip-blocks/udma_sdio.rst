..
   Copyright (c) 2023 OpenHW Group
   Copyright (c) 2024 CircuitSutra

   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

.. Level 1
   =======

   Level 2
   -------

   Level 3
   ~~~~~~~

   Level 4
   ^^^^^^^
.. _udma_sd_card_interface:

UDMA SD CARD INTERFACE
======================

The SDIO (Secure digital I/O) card provides high speed data I/O with low
power consumption for mobile electronic devices. Host devices supporting
SDIO can connect the SD slot with I/O devices like Bluetooth, wireless,
LAN, GPS Receiver, Digit Camera etc.

SDIO INTERFACE BUS:
-------------------

.. udma_sdio_image:: udma_sdio_image8.png
   :width: 4.17708in
   :height: 2.51042in

FEATURES:
---------

-  It has a clock, command and 4-bit data bus.

-  Supports quad mode.

-  Five types of response supported:

   -  No response

   -  48 bits with CRC

   -  48 bits with NO CRC.

   -  136 bits with BUSY check.

-  Error output pin.

-  End of transfer output pin.

-  Four error status for command transfer supported:

   -  No error

   -  Response timeout

   -  Response wrong direction

   -  Response busy timeout

THEORY OF OPERATION:
^^^^^^^^^^^^^^^^^^^^

Communication over the SD bus is based on command and data bit streams
that are initiated by a start and terminated by a stop bit.

-  Command: Operation is started by generating a command. A host can
      send a command to either a single card or to all the connected
      cards. A command is transferred serially on the CMD line. MSB is
      transmitted first and LSB is transmitted last. Transmission bit is
      1 as command is transmitted from host to device.

   -  Command token format\ |Command token|

+------------+------+--------------+-----------+---------+----+-------+
| Bit        | 47   | 46           | [45:40]   | [39:8]  | [  | 0     |
| position   |      |              |           |         | 7: |       |
|            |      |              |           |         | 1] |       |
+============+======+==============+===========+=========+====+=======+
| Width      | 1    | 1            | 6         | 32      | 7  | 1     |
+------------+------+--------------+-----------+---------+----+-------+
| Value      | 0    | 1            | x         | x       | x  | 1     |
+------------+------+--------------+-----------+---------+----+-------+
| D          | S    | Transmission | cmd       | Cmd arg | c  | End   |
| escription | tart | bit          | opcode    |         | rc | bit   |
|            | bit  |              |           |         |    |       |
+------------+------+--------------+-----------+---------+----+-------+

-  Response: A response is sent from an addressed card to the host as an
      answer to a previously received command. A response is transferred
      serially on the CMD line. Transmission bit is 0 as response is
      transmitted from device to host.

   -  Response token format:

..

   .. udma_sdio_image:: udma_sdio_image2.png
      :width: 3.95833in
      :height: 0.96875in

+------------+------+-------------+-----------+---------+----+-------+
| Bit        | 47   | 46          | [45:40]   | [39:8]  | [  | 0     |
| position   |      |             |           |         | 7: |       |
|            |      |             |           |         | 1] |       |
+============+======+=============+===========+=========+====+=======+
| Width      | 1    | 1           | 6         | 32      | 7  | 1     |
+------------+------+-------------+-----------+---------+----+-------+
| Value      | 0    | 0           | x         | x       | x  | 1     |
+------------+------+-------------+-----------+---------+----+-------+
| D          | S    | T           | Command   | Card    | c  | End   |
| escription | tart | ransmission | index     | status  | rc | bit   |
|            | bit  | bit         |           |         |    |       |
+------------+------+-------------+-----------+---------+----+-------+

+------------+------+-------------+-----------+----------------+-----+
| Bit        | 135  | 134         | [133:128] | [127:1]        | 0   |
| position   |      |             |           |                |     |
+============+======+=============+===========+================+=====+
| Width      | 1    | 1           | 6         | 127            | 1   |
+------------+------+-------------+-----------+----------------+-----+
| Value      | 0    | 0           | 111111    | x              | 1   |
+------------+------+-------------+-----------+----------------+-----+
| D          | S    | T           | Reserved  | Response       | End |
| escription | tart | ransmission |           | content        | bit |
|            | bit  | bit         |           | including CRC  |     |
+------------+------+-------------+-----------+----------------+-----+

-  Data: Data can be transferred from the card to the host or vice
      versa. It is transferred via the data lines.

Data transfer to/from the SD memory card is done in blocks. Data blocks
are succeeded by CRC bits.

BLOCK DIAGRAM:
^^^^^^^^^^^^^^
.. udma_sdio_image:: udma_sdio_image6.png
   :width: 4.72292in
   :height: 5.44022in

.. udma_sdio_image:: udma_sdio_image3.png
   :width: 6.5in
   :height: 2.47222in

It contains a reg interface for writing and reading from the register
and a SDIO TX/RX module which instantiates command and data modules.
Command module handles command interface and data module handles data
transfer.

SDIO TX/RX:
^^^^^^^^^^^

This module is responsible for sending and receiving command and data
between host and device. It instantiates command and data modules.

.. udma_sdio_image:: udma_sdio_image5.png
   :width: 3.20625in
   :height: 3.66721in

-  It uses the clock generated by udma_clockgen as input clock.

-  Synchronous start generated by the edge propagator is used to get the
      command start bit. This command start bit is sent to the command
      module which marks the start of the command.

-  This module works in three states:

   -  CMD_ONLY: This is the default state.

      -  State is set to WAIT_EOT if there is no block to be transmitted
            else state is set to WAIT_LAST.

   -  WAIT_LAST: Wait for the last piece of data to be transferred.

      -  After transferring the last piece of data we go to state
            WAIT_EOT.

      -  Data module sends a high signal which indicates transfer of
            last data.

   -  WAIT_EOT: Wait for the end of transaction.

      -  If command eot and data eot sent by command and data module
            respectively are high then go to state CMD_ONLY and reset
            command eot and data eot.

-  Status : 16 bit status output is transmitted through this block. This
      status can be read through SDIO_REG_STATUS. Non-negative status
      would generate and error.

+-------------+-------------+-------------+-------------+-------------+
| Bit         | [15:14]     | [13:8]      | [7:6]       | [5:0]       |
| position    |             |             |             |             |
+=============+=============+=============+=============+=============+
| value       | 00          | x           | 00          | x           |
+-------------+-------------+-------------+-------------+-------------+
| Description | reserved    | Data status | reserved    | Command     |
|             |             |             |             | status      |
+-------------+-------------+-------------+-------------+-------------+

It instantiates two sub blocks: command and data.

.. udma_sdio_image:: udma_sdio_image1.png
   :width: 5.89792in
   :height: 3.05234in

-  Command block: This module handles the command interface.

   -  It supports three types of response status:

      -  Response timeout

      -  Response wrong direction

      -  Response busy timeout

   -  It supports five types of responses: Response type is written to
         register

..

   SDIO_REG_CMD_OP.

-  Null response: No response.

-  48 bits with CRC.

   -  Supports CRC.

   -  Response length is 38 bits.

-  48 bits with NO CRC

   -  Supports CRC.

   -  Response length is 38 bits.

-  136 bits

   -  Supports CRC.

   -  Response length is 133 bits.

-  48 bits with a busy check.

   -  Supports CRC.

   -  Response length is 38 bits.

   -  Supports busy signal.

-  Command output enable signal: sdcmd_oen_o is an active low signal. It
      is enabled during transfer of command and is disabled during
      reception of response.

-  It goes through twelve states:

   -  ST_IDLE: Default state when the system is IDLE.

      -  Clock is disabled initially.

      -  If the command start bit is high then state is set to
            ST_TX_START and clock is enabled.

   -  ST_TX_START: Send the start bit to start the transaction.

      -  Start bit is sent through sdcmd_o.

      -  State is set to ST_TX_DIR.

   -  ST_TX_DIR: Set the transmission bit of the command.

      -  Transmission bit is sent through sdcmd_o.

      -  CRC is enabled.

      -  State is set to ST_TX_SHIFT and 38 bit command data is
            transmitted.

   -  ST_TX_SHIFT:

      -  MSB of the command is sent as output through sdcmd_o.

      -  CRC is enabled.

      -  Command data is shifted to the left by 1 bit.

      -  If the 38 bit command data is transmitted go to state ST_TX_CRC
            and start counting the CRC bits. There are 7 CRC bits.

   -  ST_TX_CRC: Send CRC output and shifts CRC.

      -  CRC output is sent as output through sdcmd_o.

      -  CRC is enabled.

      -  State is set to ST_TX_STOP after successfully transmitting the
            CRC bits.

   -  ST_TX_STOP: Transmit the stop bit of the command.

      -  Stop bit is sent through sdcmd_o.

      -  Start read is enabled which indicate we can read from data
            block.

      -  If the response is enabled, set the state to ST_RX_START.

      -  If the response is disabled, go to state ST_WAIT.

   -  ST_RX_START: Initiates the reception of response.

      -  Response is received via sdcmd_i

      -  State is set to ST_RX_DIR if the start bit is received.

      -  If the start bit is not received till 38 clock cycle then
            response status is set to response timeout.

   -  ST_RX_DIR: Check if the received command indicates the correct
         direction.

      -  Direction bit is received and state is set ST_RX_SHIFT.

      -  Response data is received.

      -  Receiving an incorrect bit would set the response status to
            response wrong direction and the state is set to ST_IDLE.

   -  ST_RX_SHIFT: Shift in response data.

      -  CRC is calculated.

      -  If the response data is received and response crc is enabled
            then state is set to ST_TX_CRC.

      -  If response data is received and response crc is disabled and
            response busy is enabled then go to state ST_WAIT_BUSY.

      -  If response count is completed but response crc and response
            busy are not enabled then go to ST_WAIT.

   -  ST_RX_CRC:

      -  If CRC is received then go to ST_WAIT..

   -  ST_WAIT_BUSY:

      -  If a low busy signal is received from the data block then we go
            to ST_WAIT.

      -  If the busy signal is high till 256 clock cycle status is set
            to response busy timeout.

   -  ST_WAIT:

      -  After waiting for 8 clock cycles, high output is asserted
            through command eot output and high start write output is
            sent which indicates successful write command.

      -  Set the state to ST_IDLE.

-  Single bit is transferred at every posedge of the clock. Transmitting
      a 38 bit command data would take 38 clock cycles and a 7 bit crc
      would take 7 clock cycles. Similarly receiving a response would
      take response length clock cycle.

-  Response content is received through sdcmd_i and is sent as output
      through rsp_data_o.

-  Data block: This module is responsible for handling data transfer.

   -  Support response status timeout.

   -  Supports five types of responses:

      -  Null response: No response.

      -  48 bits with CRC.

         -  Supports CRC.

         -  Response length is 38 bits.

      -  48 bits with NO CRC

         -  Supports CRC.

         -  Response length is 38 bits.

      -  136 bits

         -  Supports CRC.

         -  Response length is 133 bits.

      -  48 bits with a busy check.

         -  Supports CRC.

         -  Response length is 38 bits.

         -  Supports busy signal.

   -  Supports 16 bit CRC.

   -  Data output enable signal: sddata_oen_o is an active low signal.
         It is enabled during transfer of data and is disabled during
         reception of data.

   -  Data can be transmitted in 2 modes:

      -  Single count mode: Data is transferred only on DATA[0] pin. LSB
            is transmitted first and MSB is transmitted last.

..

   .. udma_sdio_image:: udma_sdio_image9.png
      :width: 5.63542in
      :height: 1.07292in

-  Quad mode: Data is transferred on all the four data pins.

..

   .. udma_sdio_image:: udma_sdio_image10.jpg
      :width: 5.28762in
      :height: 2.70313in

-  States:

   -  ST_IDLE:

      -  For read operation go to state ST_RX_START.

      -  For write operation go to ST_TX_START.

      -  Read and write operation is decided by data_rwn_i.

   -  ST_TX_START:

      -  Send the start bit through sddata_o to start the transaction.

      -  Go to state ST_TX_SHIFT.

      -  one block is transmitted.

   -  ST_TX_SHIFT:

      -  Data output is enabled.

      -  CRC is calculated.

      -  Direction bit is sent.

      -  If the whole block is transmitted go to state ST_TX_CRC.

   -  ST_TX_CRC:

      -  Output crc through sddata_o.

      -  state is set to ST_TX_END.

   -  ST_TX_END

      -  Send ‘F’ through sddata_o.

      -  Go to state ST_TX_CRCSTAT.

   -  ST_TX_CRCSTAT

      -  Wait for 8 clock cycles and go to state ST_TX_BUSY

   -  ST_TX_BUSY

      -  After waiting for 512 cycles go to timeout phase:

         -  Sdio timeout counter is increased till it reaches 1023.

         -  State is set to ST_IDLE and high output is driven through
               eot output.

      -  If 512 cycles is not reached and high bit is received in LSB of
            incoming data:

         -  If all the blocks are transmitted then the state is set to
               ST_IDLE and eot is asserted.

         -  If the whole block is not transmitted then go to ST_TX_START
               and transmit the next block.

   -  ST_RX_START:

      -  Data is received through sddata_i.

      -  Go to state ST_RX_SHIFT if the start bit is received.

      -  If the start bit is not received, set the status to response
            timeout and go to ST_IDLE.

   -  ST_RX_SHIFT:

      -  CRC is calculated.

      -  After receiving the block state is set to ST_RX_CRC.

   -  ST_RX_CRC:

      -  CRC is calculated.

      -  After receiving the 16 bit CRC, if the all the blocks are
            received assert eot else go to ST_RX_START and receive
            another block.

   -  ST_WAIT

      -  After waiting for 8 clock cycle assert eot and go to state
            ST_IDLE.

-  This block contains a data input, data output, ready output and valid
      output.

   -  Data input: Receive the data from tx fifo and transfer it to
         device.

   -  Data output: Transmits the data received from device to rx fifo.

   -  Ready output: Indicate if block is ready to write data to tx fifo.

   -  Valid output: Indicate if there is valid data to be written to rx
         fifo.

.. udma_sdio_image:: udma_sdio_image4.png
   :width: 6.5in
   :height: 3.41667in

**(u_clockgen) udma_clkgen:-**

**Ports:-**

input logic clk_i,

input logic rstn_i,

input logic dft_test_mode_i,

input logic dft_cg_enable_i,

input logic clock_enable_i,

input logic [7:0] clk_div_data_i,

input logic clk_div_valid_i,

output logic clk_div_ack_o,

output logic clk_o

**Theory of operation :-**

-  This is a Integer clock divider with async configuration interface.

-  The module will be in four modes namely IDLE, STOP, WAIT, RELEASE.

-  The clock_enable_i should be high and the **module should enable the clock** for the output to be visible.

-  When the module is in reset mode by making rstn_i low,then the mode
      is set to IDLE.The multiplexer will select the input clock to be
      the output clock of the module.The clock divider is
      enabled.\ **The clock is enabled by the module**.

-  The signal clk_div_valid_i is sent to a pulp_sync_wedge module as
      serial_i and output of the module is clk_div_valid_sync which
      represents the r_edge_o of the pulp_sync_edge.

-  Now at every positive edge of the clk_i,If clk_div_valid_sync is
      high,then the clk_div_data_i is read and the clock divider value
      is updated.Also ,the next state of the module is change to STOP
      state, so that in next clock cycle as state is in STOP mode, the
      multiplexer sets the output to the clock divider output and
      schedules the update of **clock divider config** to next clock
      cycle by changing the next state to WAIT.The clock is disabled in
      this state to make the config changes.

-  At the next clock edge as it is in WAIT state,here the **clock divider config** is updated ,which means the counter value is set
      to default 0 and output clock is made low.The next state is
      RELEASE state.

-  In the next clock edge where the state is RELEASE,from this moment
      the clock divider starts working with a new clock divider value
      from the start(as counter i made 0).The next state is again back
      to IDLE state.

-  In the next clock edge(IDLE state),\ **The clock is enabled** so that
      we can see the output in the output pin.The module will remain in
      this state and clock divider will be toggle the output clock
      signal after the counter reaches a value equal to **(clock divisor
      value -1)** and at this moment the counter also becomes 0 so that
      it can be incremented by one unit again at every clock edge.This
      will continue until again clk_div_valid_sync become high again
      then The clock divider value is updated and the state goes to STOP
      mode for next clock cycle to reset the clock divisor and counter
      to 0.

-  The clk_o is nothing but the output signal of the clock divider.

**Pulp_sync_wedge:-**

**Ports:-**

input logic clk_i,

input logic rstn_i,

input logic en_i,

input logic serial_i,

output logic r_edge_o,

output logic f_edge_o,

output logic serial_o

The module takes an input(serial_i) and a clock signal.There is a
submodule which contains a 2 bit shift register which will be storing
the signal value at every clock edge by shifting to right and storing
new signal value in MSB.The output of the shift register is the LSB
which is connected in cascaded fashion to a module which writes the
output serial_o .At every clock positive edge , the serial_o is updated
with the current LSB of the shift register and LSB is updated by shift
register with new value ,both happening in a parallel non blocking
fashion.Whenever the LSB of the shift register changes to high and
serial_o was low,then r_edge_o is made high ,but at next clock cycle as
serial_o is updated to LSB of shift register ,r_edge_o goes low (So
r_edge_o stays high for only one clock cycle).

**Edge Propagator:-**

**Ports:-**

input logic clk_tx_i,

input logic rstn_tx_i,

input logic edge_i,

input logic clk_rx_i,

input logic rstn_rx_i,

output logic edge_o

**Theory of operation:-**

-  The main purpose of the module is to propagate the input value in
      edge_i for a period of time.

-  So,when rstn_tx_i is low, then the output is low.

-  In active mode ,Whenever the edge_i is high it is stored in a
      register and reflected in a signal in the next positive edge of
      clk_tx_i.The signal which is sensitive to edge_i at every positive
      edge of clk_tx_i is sent to pulp_sync_wedge.This signal will
      remain high until we get an output from pulp_sync_wedge(serial_o)(
      clock clk_rx_i ) for the signal sensitive to edge_i.Then after
      three clock cycles after we get a output from pulp_sync_wedge we
      will make the signal low .After this the signal is again set
      sensitive to edge_i .So everything repeats after the edge_i is
      triggered again.Now the output of the edge propagator (edge_o) is
      nothing but the rising edge pulp_sync_wedge based
      signal,i.e.,r_edge_o, which asserts one clock cycle after the
      signal sensitive to edge_i is made high.

**udma_dc_fifo:**

**Ports:-**

input logic src_clk_i,

input logic src_rstn_i,

input logic [DATA_WIDTH-1:0] src_data_i,

input logic src_valid_i,

output logic src_ready_o,

input logic dst_clk_i,

input logic dst_rstn_i,

output logic [DATA_WIDTH-1:0] dst_data_o,

output logic dst_valid_o,

input logic dst_ready_i

**Theory of operation:-**

-  The module contains two sub modules ,one connected to the source to
      receive the data and enter the data into FIFO and another module
      connected to the destination and works on sending the FIFO data to
      destination.

-  din:

   -  This is connected to the source.

      -  input clk;

      -  input rstn;

      -  input [DATA_WIDTH - 1 : 0] data;

      -  input valid;

      -  output ready;

      -  output [BUFFER_DEPTH - 1 : 0] write_token;

      -  input [BUFFER_DEPTH - 1 : 0] read_pointer;

      -  output [DATA_WIDTH - 1 : 0] data_async;

   -  The din contains the dc_buffer module which contains the actual
         FIFO , dc_token_ring module which contains the logic to compute
         the write pointers and finally the dc_full_detector module
         which contains the logic to deduce whether FIFO is full or not.

-  dout:

   -  input [DATA_WIDTH - 1 : 0] data_async;

   -  input clk;

   -  input rstn;

   -  output [DATA_WIDTH - 1 : 0] data;

   -  output valid;

   -  input ready;

   -  input [BUFFER_DEPTH - 1 : 0] write_token;

   -  output [BUFFER_DEPTH - 1 : 0] read_pointer;

   -  dout contains the dc_token_ring module which contains the logic to
         compute the read_pointer to read data from when FIFO is not
         empty .

   -  It will also be taking write_token from the din module and perform
         the logic of dc_synchronizer on it to get the synchronized
         version of write_token.This synchronized write_token along with
         read_pointer is used to deduce whether the FIFO is empty or not
         ,using bit manipulation.

   -  The dc_synchronizer synchronizes the write_token with respect to
         clk ,which means at every clock edge the value of the
         write_token is stored but it is reflected in the output in the
         next clock edge.

   -  If the FIFO is empty then we cannot read from the FIFO.

**io_tx_fifo:-**

-  This is a TX FIFO with outstanding request support.

-  Ports:-

   -  input logic clk_i,

   -  input logic rstn_i,

   -  

   -  input logic clr_i,

   -  

   -  output logic req_o,

   -  input logic gnt_i,

   -  

   -  output logic [DATA_WIDTH-1 : 0] data_o,

   -  output logic valid_o,

   -  input logic ready_i,

   -  

   -  input logic valid_i,

   -  input logic [DATA_WIDTH-1 : 0] data_i,

   -  output logic ready_o

-  Theory of operation:-

   -  The module contains a FIFO module which is a synchronous FIFO with
         configurable width and depth and logic to keep record of any
         outstanding requests and if requests are solved and accordingly
         update the record.

   -  The FIFO module does three things which are updating the buffer ,
         keeping record of the number of elements in the buffer and
         updating the write and read pointers in the buffer.

   -  If the signal valid_i is high and the buffer is not full then at
         the current position at the write pointer of the buffer array
         the data from data_i is stored and the write pointer is
         incremented.

   -  If the signal ready_i is high and the buffer is not empty then the
         read pointer is incremented.

   -  The current read pointer position in the buffer array is read into
         data_o always.The read pointer is updated at every clock
         positive edge as mentioned in above bullet point.

   -  While above functions are happening at every clock positive edge
         the number of elements in the buffer is also updated and
         recorded after the operation.

   -  Coming to the logic for the outstanding requests,We calculate the
         number of free spaces left in the buffer and if it is equal to
         the number of the outstanding requests then we signal to stop
         further requests.If there is no signal to stop the requests and
         the buffer is ready to accept requests (which means it is not
         full) then we can accept the requests.

   -  So at every clock positive edge if the module and accept requests
         based on above conditions and the request is granted by making
         gnt_i signal high then if valid_i is low(meaning the request is
         not valid) or The buffer is not ready (meaning the buffer is
         full) then the number of outstanding requests will be
         incremented.If valid_i is high and the buffer is ready then the
         number of outstanding requests will be decremented.

**Whole operation:-**

.. udma_sdio_image:: udma_sdio_image4.png
   :width: 7.14063in
   :height: 3.75in

-  As we can see in the above block diagram,some of the input signals go
      into the register interface and few signals are generated by the
      register interface which are used for various operations in SDIO.

-  We have a module called u_clockgen which takes in a few parameters
      from the register and generates a sdio clock from the peripheral
      clock (u_clockgen is a Integer clock divider with async
      configuration interface).

-  The SDIO clock generated will be used in the SDIO module.There is a
      edge propagator module which takes in s_start from register which
      is in sync with system clock sys_clk_i and sdio clock as input
      ,finally generates the resign edge of the s_start in sync with the
      sdio clock ,So this module generates resign edge of s_start in
      sync with the sdio clock instead of sys_clk_i.

-  The s_start_sync ,sdio clock and signals from registers go to
      sdio_tx_rx where actual logic for transmission and receiving is
      executed.sdio_tx_rx runs in sync with sdio clock.

-  The signal s_err from the module sdio_tx_rx is synchronized to
      sys_clk_i using the module pulp_sync_wedge and set to register to
      be stored.

-  The s_eot signal from sdio_tx__rx is in sync with sdio clock ,there
      is edge propagator with name i_eot_sync which generates the rising
      edge of the signal s_eot in sync with sys_clk_i and the
      synchronized signal is sent to register to be stored.

-  For communication between( SDIO and uDMA )and (SDIO and I/O) we use
      FIFOs.

-  FIFOs for SDIO and uDMA:-

   -  There are three FIFOs in total , i_dc_fifo_tx , u_dc_fifo_rx and
         io_tx_fifo.

   -  **u_dc_fifo_rx** is a **udma_dc_fifo** which is used to transfer
         the data from the clock domain of sdio clock domain(source) and
         sys_clk_i (system clock)(destination).So the data from
         peripheral I/O gets into sdio_tx_rx module, to communicate this
         received data from the sdio_tx_rx to uDMA we use this FIFO
         **u_dc_fifo_rx.**

   -  **i_dc_fifo_tx** is different clock FIFO between sys_ck_i(source)
         and sdio clock(destination) .So basically The data which comes
         as input to the top module from uDMA is sent first to
         **io_tx_fifo** which is a TX FIFO with outstanding request
         support.The data in this FIFO goes to **i_dc_fifo_tx** which is
         FIFO between sys_clk_i as source and sdio clock as destination
         ,So through this FIFO named **i_dc_fifo_tx** ,the data can be
         sent to the **sdio_tx_rx** module in SDIO.So the data from the
         uDMA first gets into the FIFO named **io_tx_fifo** and then
         from there into a FIFO named **i_dc_fifo_tx** and finally to
         **sdio_tx_rx**.

.. |Command token| udma_sdio_image:: udma_sdio_image7.png
   :width: 3.95833in
   :height: 0.96875in

Interrupt
^^^^^^^^^

uDMA SDIO generates the following interrupts:

- Error interrupt: 
- End of transfer interrupt:
- Rx channel interrupt: Raised by uDMA core's Rx channel after pushing the last byte of RX_SIZE bytes into core RX FIFO.
- Tx channel interrupt: Raised by uDMA core's Tx channel after pushing the last byte of TX_SIZE bytes into core TX FIFO.

The RX and TX channel interrupts are cleared by the uDMA core if any of the following conditions occur:

- If a clear request for the RX or TX uDMA core channel is triggered via the CLR bitfield in the respective RX or TX CFG CSR of the uDMA SDIO.
- If either the RX or TX uDMA channel is disabled via the CFG CSR of the uDMA SDIO, or if access is not granted by the uDMA core's arbiter.
- If continuous mode is enabled for the RX or TX uDMA channel through the CFG CSR of the SDIO uDMA.

RX and TX channel interrupts are transparent to users.

The event bridge forwards interrupts over dedicated lines to the APB event controller for processing. Each interrupt has its own dedicated line.
Users can mask these interrupts through the APB event controller's control and status registers (CSRs).

System Architecture
-------------------

The figure below shows how the uDMA SDIO interfaces with the rest of the CORE-V-MCU components and the external SDIO device:-

.. figure:: uDMA-SDIO-CORE-V-MCU-Connection-Diagram.png
   :name: uDMA-SDIO-CORE-V-MCU-Connection-Diagram
   :align: center
   :alt:

   uDMA SDIO CORE-V-MCU connection diagram

Programming Model
------------------
As with most peripherals in the uDMA subsystem, software configuration can be conceptualized into three functions:

- Configure the I/O parameters of the peripheral (e.g. baud rate).
- Configure the uDMA data control parameters.
- Manage the data transfer/reception operation.

uDMA SDIO Data Control
^^^^^^^^^^^^^^^^^^^^^^
Refer to the Firmware Guidelines section in the current chapter.

Data Transfer Operation
^^^^^^^^^^^^^^^^^^^^^^^
Refer to the Firmware Guidelines section in the current chapter.

uDMA SDIO CSRs
--------------
Refer to `Memory Map <https://github.com/openhwgroup/core-v-mcu/blob/master/docs/doc-src/mmap.rst>`_ for peripheral domain address of the uDMA SDIO.

**NOTE:** Several of the uDMA SDIO CSRs are volatile, meaning that their read value may be changed by the hardware.
For example, writing the *RX_SADDR* CSR will set the address of the receive buffer pointer.
As data is received, the hardware will update the value of the pointer to indicate the current address.
As the name suggests, the value of non-volatile CSRs is not changed by the hardware.
These CSRs retain the last value written by software.

A CSR's volatility is indicated by its "type".

Details of CSR access type are explained `here <https://docs.openhwgroup.org/projects/core-v-mcu/doc-src/mmap.html#csr-access-types>`_.

The CSRs RX_SADDR and RX_SIZE specify the configuration for the transaction on the RX channel. The CSRs TX_SADDR and TX_SIZE specify the configuration for the transaction on the TX channel. The uDMA Core creates a local copy of this information at its end and uses it for current ongoing transactions.

RX_SADDR
^^^^^^^^
- Offset: 0x0
- Type:   volatile

+--------+------+--------+------------+-----------------------------------------------------------------------------------------------------------+
| Field  | Bits | Access | Default    | Description                                                                                               |
+========+======+========+============+===========================================================================================================+
| SADDR  | 18:0 | RW     |    0x0     | Address of the Rx buffer. This is location in the L2 memory where SDIO will write the received data.      |
|        |      |        |            | Read & write to this CSR access different information.                                                    |
|        |      |        |            |                                                                                                           |
|        |      |        |            | **On Write**: Address of Rx buffer for next transaction. It does not impact current ongoing transactions. |
|        |      |        |            |                                                                                                           |
|        |      |        |            | **On Read**: Address of read buffer for the current ongoing transaction. This is the local copy of        |
|        |      |        |            | information maintained inside the uDMA core.                                                              |
+--------+------+--------+------------+-----------------------------------------------------------------------------------------------------------+

RX_SIZE
^^^^^^^
- Offset: 0x04
- Type:   volatile

+-------+-------+--------+------------+--------------------------------------------------------------------------------------------+
| Field |  Bits | Access | Default    | Description                                                                                |
+=======+=======+========+============+============================================================================================+
| SIZE  |  19:0 |   RW   |    0x0     | Size of Rx buffer (amount of data to be transferred by SDIO to L2 memory). Read & write    |
|       |       |        |            | to this CSR access different information.                                                  |
|       |       |        |            |                                                                                            |
|       |       |        |            | **On Write**: Size of Rx buffer for next transaction. It does not impact current ongoing   |
|       |       |        |            | transaction.                                                                               |
|       |       |        |            |                                                                                            |
|       |       |        |            | **On Read**: Bytes left for current ongoing transaction. This is the local copy of         |
|       |       |        |            | information maintained inside the uDMA core.                                               |
+-------+-------+--------+------------+--------------------------------------------------------------------------------------------+

RX_CFG
^^^^^^
- Offset: 0x08
- Type:   volatile

+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| Field      |  Bits | Access | Default    | Description                                                                        |
+============+=======+========+============+====================================================================================+
| CLR        |   6:6 |   WO   |    0x0     | Clear the local copy of Rx channel configuration CSRs inside uDMA core             |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| PENDING    |   5:5 |   RO   |    0x0     | - 0x1: The uDMA core Rx channel is enabled and either transmitting data,           |
|            |       |        |            |   waiting for access from the uDMA core arbiter, or stalled due to a full Rx FIFO  |
|            |       |        |            |   of uDMA Core                                                                     |
|            |       |        |            | - 0x0 : Rx channel of the uDMA core does not have data to transmit to L2 memory.   |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| EN         |   4:4 |   RW   |    0x0     | Enable the Rx channel of the uDMA core to perform Rx operation                     |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| CONTINUOUS |   0:0 |   RW   |    0x0     | - 0x0: stop after last transfer for channel                                        |
|            |       |        |            | - 0x1: after last transfer for channel, reload buffer size                         |
|            |       |        |            |   and start address and restart channel                                            |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+

TX_SADDR
^^^^^^^^
- Offset: 0x10
- Type:   volatile

+-------+-------+--------+------------+--------------------------------------------------------------------------------------------------------------+
| Field |  Bits | Access | Default    | Description                                                                                                  |
+=======+=======+========+============+==============================================================================================================+
| SADDR |  18:0 |   RW   |    0x0     | Address of the Tx buffer. This is location in the L2 memory from where SDIO will read the data to transmit.  |
|       |       |        |            | Read & write to this CSR access different information.                                                       |
|       |       |        |            |                                                                                                              |
|       |       |        |            | **On Write**: Address of Tx buffer for next transaction. It does not impact current ongoing transactions.    |
|       |       |        |            |                                                                                                              |
|       |       |        |            | **On Read**: Address of Tx buffer for the current ongoing transaction. This is the local copy of information.|
|       |       |        |            | maintained inside the uDMA core.                                                                             |
+-------+-------+--------+------------+--------------------------------------------------------------------------------------------------------------+

TX_SIZE
^^^^^^^
- Offset: 0x14
- Type:   volatile

+-------+-------+--------+------------+--------------------------------------------------------------------------------------------------------+
| Field |  Bits | Access | Default    | Description                                                                                            |
+=======+=======+========+============+========================================================================================================+
| SIZE  |  19:0 |   RW   |    0x0     | Size of Tx buffer (amount of data to be read by SDIO from L2 memory for Tx operation). Read & write    |
|       |       |        |            | to this CSR access different information.                                                              |
|       |       |        |            |                                                                                                        |
|       |       |        |            | **On Write**: Size of Tx buffer for next transaction. It does not impact current ongoing transactions. |
|       |       |        |            |                                                                                                        |
|       |       |        |            | **On Read**: Bytes left for current ongoing transaction, i.e., bytes left to read from L2 memory. This |
|       |       |        |            | is the local copy of information maintained inside the uDMA core.                                      |
+-------+-------+--------+------------+--------------------------------------------------------------------------------------------------------+

TX_CFG
^^^^^^
- Offset: 0x18
- Type:   volatile

+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| Field      |  Bits | Access | Default    | Description                                                                        |
+============+=======+========+============+====================================================================================+
| CLR        |   6:6 |   WO   |    0x0     | Clear the local copy of Tx channel configuration CSRs inside uDMA core             |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| PENDING    |   5:5 |   RO   |    0x0     | - 0x1: The uDMA core Tx channel is enabled and is either receiving data,           |
|            |       |        |            |   waiting for access from the uDMA core arbiter, or stalled due to a full Tx FIFO  |
|            |       |        |            | - 0x0 : Tx channel of the uDMA core does not have data to read from L2 memory      |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| EN         |   4:4 |   RW   |    0x0     | Enable the transmit channel of uDMA core to perform Tx operation                   |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| CONTINUOUS |   0:0 |   RW   |            | - 0x0: stop after last transfer for channel                                        |
|            |       |        |    0x0     | - 0x1: after last transfer for channel, reload buffer size                         |
|            |       |        |            |   and start address and restart channel                                            |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+


CMD_OP
^^^^^^
- Offset: 0x20
- Type:   non-volatile

+-----------+--------+--------+------------+---------------------------------------------------------------------+
| Field     | Bits   | Access | Default    | Description                                                         |
+===========+========+========+============+=====================================================================+
| OP        | 13:8   | W      | 0x00       | Operation code specifying the command or function to be performed.  |
|           |        |        |            | This 6-bit field selects the type of operation initiated by the     |
|           |        |        |            | controller or processor.                                            |
+-----------+--------+--------+------------+---------------------------------------------------------------------+
| RSP_TYPE  | 2:0    | W      | 0x0        | Response type expected for the issued operation. This 3-bit field   |
|           |        |        |            | defines the format or presence of the response data.                |
+-----------+--------+--------+------------+---------------------------------------------------------------------+

CMD_ARG
^^^^^^^
- Offset: 0x24
- Type:   non-volatile

+--------+--------+--------+------------+---------------------------------------------------------------------+
| Field  | Bits   | Access | Default    | Description                                                         |
+========+========+========+============+=====================================================================+
| ARG    | 31:0   | W      | 0x00000000 | Argument value associated with the operation. This 32-bit field     |
|        |        |        |            | provides optional or required data used by the command specified    |
|        |        |        |            | in the `OP` field. The meaning of this field depends on the         |
|        |        |        |            | command type and context.                                           |
+--------+--------+--------+------------+---------------------------------------------------------------------+

DATA_SETUP
^^^^^^^^^^
- Offset: 0x28
- Type:   non-volatile

+-------------+--------+--------+------------+---------------------------------------------------------------------+
| Field       | Bits   | Access | Default    | Description                                                         |
+=============+========+========+============+=====================================================================+
| BLOCK_SIZE  | 25:16  | W      | 0x000      | Specifies the size of each data block to be transferred, in bytes.  |
|             |        |        |            | Typically used to define the transfer chunk size for multi-block    |
|             |        |        |            | operations.                                                         |
+-------------+--------+--------+------------+---------------------------------------------------------------------+
| BLOCK_NUM   | 15:8   | W      | 0x00       | Number of blocks to be transferred. This value works together       |
|             |        |        |            | with `BLOCK_SIZE` to determine total transfer size.                 |
+-------------+--------+--------+------------+---------------------------------------------------------------------+
| QUAD        | 2:2    | W      | 0x0        | Enables Quad SPI mode when set to `1`. In this mode, 4 data lines   |
|             |        |        |            | are used for faster data transfer. Set to `0` for standard mode.    |
+-------------+--------+--------+------------+---------------------------------------------------------------------+
| RWN         | 1:1    | W      | 0x0        | Read/Write control: `0` indicates a write operation, `1` indicates  |
|             |        |        |            | a read operation.                                                   |
+-------------+--------+--------+------------+---------------------------------------------------------------------+
| EN          | 0:0    | W      | 0x0        | Enable bit. When set to `1`, triggers the start of the configured   |
|             |        |        |            | transfer. Must be cleared and reset for each new command.           |
+-------------+--------+--------+------------+---------------------------------------------------------------------+

REG_START
^^^^^^^^^
- Offset: 0x2C
- Type:   non-volatile

+--------+--------+--------+------------+---------------------------------------------------------------------+
| Field  | Bits   | Access | Default    | Description                                                         |
+========+========+========+============+=====================================================================+
| START  | 0:0    | W      | 0x0        | Start bit. Writing `1` to this bit initiates the operation          |
|        |        |        |            | configured by the preceding control fields. This bit is typically   |
|        |        |        |            | self-cleared by hardware once the operation begins.                 |
+--------+--------+--------+------------+---------------------------------------------------------------------+

REG_RSP0
^^^^^^^^
- Offset: 0x30
- Type:   volatile

+---------+-------+--------+------------+--------------------------------------------------------------------+
| Field   |  Bits | Access | Default    | Description                                                        |  
+=========+=======+========+============+====================================================================+
|   DATA  |  31:0 |   R    |     0x0    |  Represents the 31:0 bits of RSP data                              |
+---------+-------+--------+------------+--------------------------------------------------------------------+


REG_RSP1
^^^^^^^^
- Offset: 0x34
- Type:   volatile

+---------+-------+--------+------------+--------------------------------------------------------------------+
| Field   |  Bits | Access | Default    | Description                                                        |  
+=========+=======+========+============+====================================================================+
|   DATA  |  31:0 |   R    |     0x0    |  Represents the 63:32 bits of RSP data                             |
+---------+-------+--------+------------+--------------------------------------------------------------------+

REG_RSP2
^^^^^^^^
- Offset: 0x38
- Type:   volatile

+---------+-------+--------+------------+--------------------------------------------------------------------+
| Field   |  Bits | Access | Default    | Description                                                        |  
+=========+=======+========+============+====================================================================+
|   DATA  |  31:0 |   R    |     0x0    |  Represents the 95:64 bits of RSP data                             |
+---------+-------+--------+------------+--------------------------------------------------------------------+

REG_RSP3
^^^^^^^^
- Offset: 0x3C
- Type:   volatile

+---------+-------+--------+------------+--------------------------------------------------------------------+
| Field   |  Bits | Access | Default    | Description                                                        |  
+=========+=======+========+============+====================================================================+
|   DATA  |  31:0 |   R    |     0x0    |  Represents the 127:96 bits of RSP data                            |
+---------+-------+--------+------------+--------------------------------------------------------------------+

CLK_DIV
^^^^^^^^
- Offset: 0x40
- Type:   non-volatile

+-----------+-------+--------+------------+--------------------------------------------------------------------+
| Field     | Bits  | Access | Default    | Description                                                        |
+===========+=======+========+============+====================================================================+
| DIV_VALID | 8:8   | RW     | 0x0        | Indicates whether the value in `DIV_DATA` is valid. When set to    |
|           |       |        |            | `1`, the divider logic uses the value in `DIV_DATA`. When `0`,     |
|           |       |        |            | the divider is considered inactive or disabled.                    |
+-----------+-------+--------+------------+--------------------------------------------------------------------+
| DIV_DATA  | 7:0   | RW     | 0x0        | 8-bit divider value to be used when `DIV_VALID` is set. This       |
|           |       |        |            | value typically controls the clock division ratio or timing        |
|           |       |        |            | behavior of a functional block.                                    |
+-----------+-------+--------+------------+--------------------------------------------------------------------+


STATUS
^^^^^^
- Offset: 0x44
- Type:   volatile

+---------+-------+--------+------------+-----------------------------------------------------------------------------+
| Field   |  Bits | Access | Default    | Description                                                                 |  
+=========+=======+========+============+=============================================================================+
|  STATUS | 31:16 |  RW    |   0x0      | - Bits [21:16] represent the Command Status, a 6-bit field indicating       |
|         |       |        |            |      the state or result of the most recent command execution.              |
|         |       |        |            | - Bits [29:24] represent the TXRX Status, a 6-bit field indicating          |
|         |       |        |            |      the transmit/receive state of the interface.                           |
|         |       |        |            | - Bits [23:22] and [31:30] are reserved and should be ignored by software.  |
|         |       |        |            |      They hold no functional meaning and may be read as zero or undefined.  |
+---------+-------+--------+------------+-----------------------------------------------------------------------------+
|  ERR    | 1:1   |  RWC   |   0x0      |  Writing any value other than 0x0 clears the bit.                           |
+---------+-------+--------+------------+-----------------------------------------------------------------------------+
|  EOT    | 0:0   |  RWC   |   0x0      |  Writing any value other than 0x0 clears the bit.                           |
+---------+-------+--------+------------+-----------------------------------------------------------------------------+


Firmware Guidelines
-------------------

Clock Enable, Reset & Configure uDMA SDIO
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Configure uDMA Core's PERIPH_CLK_ENABLE to enable uDMA SDIO's peripheral clock. A peripheral clock is used to calculate the baud rate in uDMA SDIO.
- Configure uDMA Core's PERIPH_RESET CSR to issue a reset signal to uDMA SDIO. It acts as a soft reset for uDMA SDIO.

Tx Operation
^^^^^^^^^^^^
- Configure the TX channel using the TX_CFG CSR. Refer to the CSR details for detailed information.
- For each transaction:
   - Update uDMA SDIO's TX_SADDR CSR with an interleaved (L2) memory address. SDIO will read the data from this memory address for transmission.
   - Configure the uDMA SDIO's TX_SIZE CSR with the size of data that the SDIO needs to transmit. uDMA SDIO will copy the transmit TX_SIZE bytes of data from the TX_SADDR location of interleaved memory.
- While Tx operation is ongoing, the TX_BUSY bit of the STATUS CSR will be set.

Rx Operation
^^^^^^^^^^^^
- Configure the RX channel using the RX_CFG CSR. Refer to the CSR details for detailed information.
- For each transaction:
   - Update uDMA SDIO's RX_SADDR CSR with an interleaved (L2) memory address. SDIO will write the data to this memory address for transmission.
   - Configure uDMA SDIO's RX_SIZE CSR with the size of data that SDIO needs to transmit. uDMA SDIO will copy the transmit RX_SIZE bytes of data to the RX_SADDR location of interleaved memory.
- While Rx operation is ongoing, the RX_BUSY bit of the STATUS CSR will be set.
- Upon receiving the data from the external device, uDMA SDIO will set the RX_DATA_VALID bit to high.
- Received data can also be read using the REG_RSPx{x = 0 to 3} CSR. When there is no valid data, the RX_DATA_VALID bit will be cleared.

End of transfer Interrupt
^^^^^^^^^^^^^^^^^^^^^^^^^

Error interrupt
^^^^^^^^^^^^^^^

Receive interrupt
^^^^^^^^^^^^^^^^^

Pin Diagram
-----------
The Figure below is a high-level block diagram of the uDMA: -

.. figure:: uDMA_SDIO_Pin_Diagram.png
   :name: uDMA_SDIO_Pin_Diagram
   :align: center
   :alt:

   uDMA SDIO Pin Diagram

Below is a categorization of these pins:

Tx channel interface
^^^^^^^^^^^^^^^^^^^^
The following pins constitute the Tx channel interface of uDMA SDIO. uDMA SDIO uses these pins to read data from interleaved (L2) memory:

- data_tx_req_o
- data_tx_gnt_i
- data_tx_datasize_o
- data_tx_i
- data_tx_valid_i
- data_tx_ready_o

Data_tx_datasize_o  pin is hardcoded to value 0x0. These pins reflect the configuration values for the next transaction.

Rx channel interface
^^^^^^^^^^^^^^^^^^^^
The following pins constitute the Rx channel interface of uDMA SDIO. uDMA SDIO uses these pins to write data to interleaved (L2) memory:

- data_rx_datasize_o
- data_rx_o
- data_rx_valid_o
- data_rx_ready_i

 data_rx_datasize_o pin is hardcoded to value 0x0. These pins reflect the configuration values for the next transaction.

Clock interface
^^^^^^^^^^^^^^^
- sys_clk_i
- periph_clk_i

uDMA CORE derives these clock pins. periph_clk_i is used to calculate baud rate. sys_clk_i is used to synchronize SDIO with uDAM Core.

Reset interface
^^^^^^^^^^^^^^^
- rstn_i

uDMA core issues reset signal to SDIO using reset pin.

uDMA SDIO interface to get/send data from/to external device
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- SDIO_rx_i
- SDIO_tx_o

uDMA SDIO receives data from an external SDIO device on SDIO_rx_i and transmits via SDIO_tx_o.

uDMA SDIO interface to generate interrupt
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- rx_char_event_o
- err_event_o

Overflow and parity errors are generated over the err_event_o interface. The receive data event will be generated over the rx_char_event_o interface.

uDMA SDIO interface to read-write CSRs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The following interfaces are used to read and write to SDIO CSRs. These interfaces are managed by uDMA Core:

- cfg_data_i
- cfg_addr_i
- cfg_valid_i
- cfg_rwn_i
- cfg_ready_o
- cfg_data_o

uDMA SDIO Rx channel configuration interface
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- uDMA SDIO uses the following pins to share the value of config CSRs, i.e., RX_SADDR, RX_SIZE, and RX_CFG, with the uDMA core: -

   - cfg_rx_startaddr_o
   - cfg_rx_size_o
   - cfg_rx_datasize_o
   - cfg_rx_continuous_o
   - cfg_rx_en_o
   - cfg_rx_clr_o

   The cfg_rx_datasize_o pin is stubbed.

- SDIO shares the values present over the below pins as read values of the config CSRs, i.e. RX_SADDR, RX_SIZE, and RX_CFG:

   - cfg_rx_en_i
   - cfg_rx_pending_i
   - cfg_rx_curr_addr_i
   - cfg_rx_bytes_left_i

   These values are updated by the uDMA core and reflect the configuration values for the current ongoing transactions.

uDMA SDIO Tx channel configuration interface
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- uDMA SDIO uses the following pins to share the value of config CSRs, i.e., TX_SADDR, TX_SIZE, and TX_CFG, with the uDMA core: -

   - cfg_tx_startaddr_o
   - cfg_tx_size_o
   - cfg_tx_datasize_o
   - cfg_tx_continuous_o
   - cfg_tx_en_o
   - cfg_tx_clr_o

  The cfg_tx_datasize_o pin is stubbed.

- SDIO shares the values present over the below pins as read values of the config CSRs, i.e., TX_SADDR, TX_SIZE, and TX_CFG:

   - cfg_tx_en_i
   - cfg_tx_pending_i
   - cfg_tx_curr_addr_i
   - cfg_tx_bytes_left_i

   These values are updated by the uDMA core and reflect the configuration values for the current ongoing transactions.