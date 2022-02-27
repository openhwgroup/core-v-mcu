/*==========================================================
 * Copyright 2021 QuickLogic Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *==========================================================*/
#ifndef INC_GPIO_TESTS_H
#define INC_EFPGA_TESTS_H

#ifdef __cplusplus
extern "C" {
#endif


//#include "hal/include/hal_pinmux.h"
//#include "hal/include/hal_gpio.h"


#define GPIO_TEST 0

typedef enum {
	GPIO_SET = 0,
	GPIO_CLR = 1,
	GPIO_TOGGLE_H = 2,
	GPIO_TOGGLE_L = 3
}gpio_enum_test_typedef;

typedef enum {
	FALLING_EDGE = 0x1,
	RISING_EDGE = 0x2,
	ANY_EDGE = 0x3,
	ACTIVE_LOW = 0x5,
	ACTIVE_HIGH = 0x6

}gpio_enum_event_typedef;

typedef struct {
	uint32_t	io_num;
	uint32_t	mux_sel;
	uint32_t	number;
	uint32_t	int_type;
	uint8_t		in_val;
	uint8_t		out_val;
	uint8_t		mode;
	uint32_t	int_en;
	uint32_t	result;
	gpio_enum_test_typedef type;
	gpio_enum_event_typedef event;
} gpio_struct_typedef;

#ifdef __cplusplus
}
#endif
#endif /* INC_GPIO_TESTS_H */
