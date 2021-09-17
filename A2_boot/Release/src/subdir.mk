################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/I2CProtocol.c \
../src/crc.c \
../src/dbg.c \
../src/hal_apb_i2cs.c \
../src/main.c \
../src/spi.c \
../src/uart.c 

OBJS += \
./src/I2CProtocol.o \
./src/crc.o \
./src/dbg.o \
./src/hal_apb_i2cs.o \
./src/main.o \
./src/spi.o \
./src/uart.o 

C_DEPS += \
./src/I2CProtocol.d \
./src/crc.d \
./src/dbg.d \
./src/hal_apb_i2cs.d \
./src/main.d \
./src/spi.d \
./src/uart.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv32-corev-elf-gcc -msmall-data-limit=8 -mno-save-restore -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g -I../target/core-v-mcu/include -I../include/ -I../../sw/inc -std=gnu11 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


