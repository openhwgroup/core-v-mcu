// PER_ID definitions
`define PER_ID_UART      0
`define PER_ID_I2CM      1
`define PER_ID_QSPIM     3
`define PER_ID_I2SS      4
`define PER_ID_CSI2      4
`define PER_ID_HYPER     4
`define PER_ID_CAM       4
`define PER_ID_JTAG      5
`define PER_ID_MRAM      5
`define PER_ID_FILTER    5
`define PER_ID_FPGA      6
`define PER_ID_EXT_PER   7

// UDMA TX channels
`define CH_ID_TX_UART    0
`define CH_ID_TX_UART0   0
`define CH_ID_TX_I2CM    1
`define CH_ID_TX_I2CM0   1
`define CH_ID_TX_I2CM1   2
`define CH_ID_TX_QSPIM   3
`define CH_ID_TX_QSPIM0  3
`define CH_ID_CMD_QSPIM  4
`define CH_ID_CMD_QSPIM0 4
`define CH_ID_TX_I2SS    5
`define CH_ID_TX_CSI2    5
`define CH_ID_TX_HYPER   5
`define CH_ID_TX_JTAG    5
`define CH_ID_TX_MRAM    5
`define CH_ID_TX_FILTER  5
`define CH_ID_TX_FILTER0 5
`define CH_ID_TX_FPGA    6
`define CH_ID_TX_FPGA0   6
`define CH_ID_TX_EXT_PER 7

// UDMA RX channels
`define CH_ID_RX_UART    0
`define CH_ID_RX_UART0   0
`define CH_ID_RX_I2CM    1
`define CH_ID_RX_I2CM0   1
`define CH_ID_RX_I2CM1   2
`define CH_ID_RX_QSPIM   3
`define CH_ID_RX_QSPIM0  3
`define CH_ID_RX_I2SS    4
`define CH_ID_RX_CSI2    4
`define CH_ID_RX_HYPER   4
`define CH_ID_CAM        4
`define CH_ID_CAM0       4
`define CH_ID_RX_JTAG    5
`define CH_ID_RX_MRAM    5
`define CH_ID_RX_FILTER  5
`define CH_ID_RX_FILTER0 5
`define CH_ID_RX_FPGA    6
`define CH_ID_RX_FPGA0   6
`define CH_ID_RX_EXT_PER 7

// Number of channels
`define N_TX_CHANNELS  6
`define N_RX_CHANNELS  6

// define index locations in perio bus
`define UART0_TX         0
`define UART0_RX         1
`define I2CM0_SCL        2
`define I2CM0_SDA        3
`define I2CM1_SCL        4
`define I2CM1_SDA        5
`define QSPIM0_CLK       6
`define QSPIM0_CSN0      7
`define QSPIM0_CSN1      8
`define QSPIM0_CSN2      9
`define QSPIM0_CSN3      10
`define QSPIM0_DATA0     11
`define QSPIM0_DATA1     12
`define QSPIM0_DATA2     13
`define QSPIM0_DATA3     14
`define CAM0_CLK         15
`define CAM0_VSYNC       16
`define CAM0_HSYNC       17
`define CAM0_DATA0       18
`define CAM0_DATA1       19
`define CAM0_DATA2       20
`define CAM0_DATA3       21
`define CAM0_DATA4       22
`define CAM0_DATA5       23
`define CAM0_DATA6       24
`define CAM0_DATA7       25
