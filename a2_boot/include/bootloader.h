/*
 * bootloader.h
 *
 *  Created on: 21-Jan-2022
 *      Author: somesh
 */

#ifndef __BOOT_LOADER_H__
#define __BOOT_LOADER_H__

typedef union {
	uint32_t w;
	uint8_t b[4];
} split_4Byte_t ;

typedef union {
	uint16_t hw;
	uint8_t b[2];
} split_2Byte_t ;

static inline void __attribute__((noreturn)) jump_to_address(unsigned int address) {
  void (*entry)() = (void (*)())((long)address);
  entry();
  while(1);
}

#endif /* __BOOT_LOADER_H__ */
