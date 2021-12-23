/*
 * This is a generated file
 *
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
#ifndef HAL_INCLUDE_PERCEPTIA_PLL_REG_DEFS_H_
#define HAL_INCLUDE_PERCEPTIA_PLL_REG_DEFS_H_

//---------------------------------//
//
// Module: PerceptiaPLLConfigUnit_t
//
//---------------------------------//

#ifndef __IO
#define __IO volatile
#endif

#ifndef __I
#define __I volatile
#endif

#ifndef __O
#define __O volatile
#endif

#include "stdint.h"

typedef struct {

  // Offset = 0x0000
  union {
    __IO uint32_t pll_config0_register;
    struct {
      __IO uint32_t  s_PS0_L1 :  2;
      __IO uint32_t  PS0_RSTN :1;
      __IO uint32_t  reserved0 :1;
      __IO uint32_t  s_PS0_L2 :  8;
      __IO uint32_t  s_PS0_L2_FRAC :  6;
      __IO uint32_t  reserved1  : 14;
    } pll_config0_register_b;
  };

  // Offset = 0x0004
  union {
    __IO uint32_t pll_config1_register;
    struct {
      __IO uint32_t  s_PS0_EN :  1;
      __IO uint32_t  reserved2  :  1;
      __IO uint32_t  s_PS0_BYPASS :  1;
      __IO uint32_t  reserved3  :  1;
      __IO uint32_t  s_MUL_INT :  11;
      __IO uint32_t  s_MUL_FRAC  : 12;
      __IO uint32_t  s_INTEGER_MODE : 1;
      __IO uint32_t  s_PRESCALE  :  4;
    } pll_config1_register_b;
  };

  // Offset = 0x0008
  union {
    __IO uint32_t pll_config2_register;
    struct {
      __IO uint32_t  s_LDET_CONFIG : 9;
      __IO uint32_t  s_SSC_EN : 1;
      __IO uint32_t  s_SSC_STEP : 8;
	  __IO uint32_t  s_SSC_PERIOD : 11;
	  __IO uint32_t  Wr_s_LF_CONFIG_33_Rd  :  1;
	  __IO uint32_t  Wr_s_LF_CONFIG_34_Rd_32  :  1;
	  __IO uint32_t  Wr_s_LF_CONFIG_35_Rd_LOCK  :  1;
    } pll_config2_register_b;
  };

  // Offset = 0x000c
  union {
    __IO uint32_t pll_config3_register;
    struct {
      __IO uint32_t  s_LF_CONFIG : 32;
    } pll_config3_register_b;
  };
} PerceptiaPLLConfigUnit_t;

#endif /* HAL_INCLUDE_PERCEPTIA_PLL_REG_DEFS_H_ */
