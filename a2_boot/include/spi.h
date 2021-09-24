/*
 * Copyright 2021 QuickLogic
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
 *
 * SPDX-License-Identifier: Apache-2.0
 */

uint16_t udma_qspim_open (uint8_t qspim_id, uint32_t clk_freq) ;
void udma_flash_readid(uint32_t l2addr) ;
uint32_t udma_flash_reset_enable(uint8_t qspim_id, uint8_t cs);
uint32_t udma_flash_reset_memory(uint8_t qspim_id, uint8_t cs);
void udma_flash_read(uint32_t flash_addr,uint32_t l2addr,uint16_t read_len );
void udma_flash_write(uint32_t flash_addr, uint32_t l2addr,uint16_t write_len );
void udma_qspim_write (uint8_t qspim_id, uint8_t cs, uint16_t write_len, uint8_t *write_data);


