# CORE_V_MCU

## Feature Specification
The core-v-mcu showcases the [CV32E40P](https://cv32e40p.readthedocs.io/en/latest/intro), a fully verified open-source RISC-V core supported by the Open Hardware Group in aa SoC design.
In addition to the CV32E40P core the SoC provides 512 KBytes of SRAM, a set of standard Peripherals and an embedded FPGA.
Three independent PLLs provide flexible clocking for the CPU, the peripherals and the eFPGA.
An internal bootrom allows for booting from a SPI flash or under host control via an I2C slave interface along with a JTAG interface for debugging.

The following peripherals are equipped:

* 2 UART
* QSPI master
* 2 I2C master
* 1 Parallel CAMERA
* 1 SDIO
* 1 I2C slave
* 32 GPIO
* 4 advanced timer blocks with PWM
* 1 eFPGA with 4 math units
* Event Generator for Interrupt processing
* Fast Interrupt capability


![Block Diagram](../images/core-v-mcu-block-diagram.png)

### UART
The uart equipped on the SoC are udma peripherals that allow efficient transfer of data.

### QSPI master
The QSPI master utilized the udma supsystem to efficiently transfer datato/from memory. It can operate in x1, x2 or x4 mode and can be used by the bootrom to load memory and transfer control. When booting from SPI the interface runs in x1 mode.

### I2C master
Two I2C master interfaces are provided.  They utilize the udma subsystem for transfer to and from memory.

### Parallel Camera
An 11-bit camera interface with 3 control inputs (CLK, HSYNC, VSYNC) and 8 data inputs is provided with a udma interface to transfer frames to memory.
The interface is compatible with the HiMax HM01B0 low power image sensor.

### SDIO
SDIO interface may be included -- TBD

### I2C Slave
An I2C slave interface is provided for host communication to the SoC. It is directly controlled as an APB peripheral with 2 256-Byte Fifos for reciept and transmission of data.

### GPIO
The Soc provides 32 GPIO pins that can multiplexed  from the internal gpio registers to the IO of the device.
Each GPIO is independent and supports Open collector output, loopback from the PAD, programmable pullup/pulldown and several drive strengths. Additionally, interrupts via the event generator can be enabled for level or edge sensitive triggers.

### Advanced Timer
An advanced timer block with four independent timers each with 4 output channels can be programmebe to generate PWM outputs.

### EFPGA
A Quicklogic ArcticPro 2 eFPGA with four math Blocks is equipped. The EFPGA contains approximately 1000 SLC each with 4 lut/ff elements. 2 Math units are provided, each math unit contains 3 4kx32 bit Dual port RAMs and 2 Multiplier units.
the RAMS cna be configures to be 8/16/or 32 bit width independently on the read and write ports.  The mulitpliers can be configured to be a 32x32, 2 -16x16, 4 8x8, or 8 4x4 multipliers.
The EFPGA has a primary APB sytle interface to the SoC and can be addressed as a stadard peripheral.  In addition the CPU controlled APB interface the EFPGA has access to 4 TCDM (Tightly Coupled Distributed Memory) interfaces that allow the EFPGA to independently read and write the System Memory.
The EFPGA had 16 dedicated interrupt output signals to the SoC Event Generator along with 40 FPGAIO that can send and recieve data from the device PADs.

### EVENT Generator
The event Generator collects events (interrupts) from all the udma peripherals (each udma channel has 4 interrupts allocated), the GPIO and the EFPGA for presentation to the CPU via set of FIFOs which presnt the interrupts in a round robin fashion

### Fast Interrupts
The CV32E40P core provides for Fast interrupts that allow quick response. The interrupts are directly vectored from the MTVEC.
