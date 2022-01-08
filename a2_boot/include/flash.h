/*
 * Copyright (C) 2018 ETH Zurich and University of Bologna
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef __HAL_ROM_ROM_V2_H__
#define __HAL_ROM_ROM_V2_H__

#include <stdint.h>

#define BOOT_STACK_SIZE  1024
#define MAX_NB_AREA 16
#define FLASH_BLOCK_SIZE 4096



typedef struct {
	uint32_t start;
	uint32_t ptr;
	uint32_t size;
	uint32_t blocks;
} flash_v2_mem_area_t;

typedef struct {
	uint32_t nextDesc;
	uint32_t nbAreas;
	uint32_t entry;
	uint32_t bootaddr;
} flash_v2_header_t;

typedef struct {
	uint32_t chipID;
	uint32_t nbBinaries;
	uint32_t ptrBinaries[6];
} flash_v3_header_t;

typedef struct {
	uint32_t checksum;
	uint32_t nbAreas;
	uint32_t entry;
	uint32_t bootaddr;
	flash_v2_mem_area_t memArea[16];
} binary_v3_desc_t;

typedef struct {
	flash_v2_header_t header;
	flash_v2_mem_area_t area;
} flash_v2_header_single_t;


typedef struct {
	unsigned char flashBuffer[FLASH_BLOCK_SIZE];
	unsigned int udma_buffer[256];
	int spi_flash_id;
	int step;
	flash_v2_header_t header;
	flash_v2_mem_area_t memArea[MAX_NB_AREA];
	char udma_uart_tx_buffer[1];
	unsigned char stack[BOOT_STACK_SIZE];
	int hyperflash;
	int blockSize;
	int qpi;
} boot_code_t;



#define HYPER_FLASH_BLOCK_SIZE_LOG2 10
#define HYPER_FLASH_BLOCK_SIZE      (1<<HYPER_FLASH_BLOCK_SIZE_LOG2)

#endif
