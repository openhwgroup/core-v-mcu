# Copyright 2020 ETH Zurich
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# Author: Robert Balas (balasr@iis.ee.ethz.ch)

CC      = riscv32-corev-elf-gcc
OBJCOPY = riscv32-corev-elf-objcopy

CFLAGS   = -Os -g -msmall-data-limit=8 \
           -mno-save-restore -fmessage-length=0 \
           -march=rv32imc \
           -fsigned-char -ffunction-sections -fdata-sections
CPPFLAGS = -I$(CURDIR)/../sw/inc -Iinclude
ASFLAGS  = $(CFLAGS) -DLANGUAGE_ASSEMBLY
LDFLAGS  = -msmall-data-limit=8 -mno-save-restore -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g -T core-v-mcu2-rom.ld -nostartfiles -nodefaultlibs -nostdlib -Xlinker --gc-sections -Wl,-Map,"A2_boot.map" --specs=nosys.specs -o "A2_boot.elf"


BOOTCODE = boot.mem

all: $(BOOTCODE)

$(BOOTCODE): A2_Boot.srec
	python3 srec2verilog.py -i ./A2_Boot.srec -o ./a2_bootrom.sv -m ../tb/mem_init_files/boot.mem

A2_Boot.srec: A2_boot.elf
	$(OBJCOPY) -O srec -j .text -j .data A2_boot.elf A2_Boot.srec


A2_boot.elf: main.o crc.o dbg.o uart.o spi.o I2CProtocol.o uartProtocol.o hal_apb_i2cs.o crt0.o
	$(CC) $(LDFLAGS) crt0.o I2CProtocol.o uartProtocol.o crc.o dbg.o hal_apb_i2cs.o main.o spi.o uart.o  -lc -lm -lgcc


.PHONY: clean
clean:
	$(RM) *.o
