################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include target/subdir.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
SECONDARY_FLASH += \
A2_boot.srec \


# All Target
all: A2_boot.elf secondary-outputs

# Tool invocations
A2_boot.elf: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GNU RISC-V Cross C Linker'
	riscv32-corev-elf-gcc -msmall-data-limit=8 -mno-save-restore -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g -T ../target/core-v-mcu/core-v-mcu2-rom.ld -nostartfiles -nodefaultlibs -nostdlib -Xlinker --gc-sections -Wl,-Map,"A2_boot.map" --specs=nosys.specs -o "A2_boot.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '
	$(MAKE) --no-print-directory post-build

A2_boot.srec: A2_boot.elf
	@echo 'Invoking: GNU RISC-V Cross Create Flash Image'
	-O srec "A2_boot.elf"  "A2_boot.srec"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(SECONDARY_FLASH)$(ASM_DEPS)$(S_UPPER_DEPS)$(C_DEPS) A2_boot.elf
	-@echo ' '

post-build:
	-riscv32-corev-elf-objcopy -O srec -j .text -j .data "A2_boot.elf"  "A2_boot.srec";python3 ../srec2verilog.py -i ./A2_boot.srec -o ./a2_bootrom.sv -m ./boot.mem
	-@echo ' '

secondary-outputs: $(SECONDARY_FLASH)

.PHONY: all clean dependents post-build

-include ../makefile.targets
