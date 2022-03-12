/*
* Copyright 2020 ETH Zurich
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

MEMORY
{
  ROM         : ORIGIN = 0x1A000000, LENGTH = 0x2000
  L2          : ORIGIN = 0x1C07c000, LENGTH = 0x4000
}

SECTIONS
{
    .text : {
	. = ALIGN(4);
	KEEP(*(.vectors))
	_stext = .;
	*(.text*)
	_etext  =  .;
	*(.rodata*)
	*(.data*)
	_endtext = .;
    }  > ROM

     .ram :
     {
	. = ALIGN(4);
	_bss_start = .;
	*(.ram*)
	*(.bss*)
	*(.sbss*)
	. = ALIGN(4);
	_bss_end = .;
     } > L2

     .stack :
     {
	. = ALIGN(4);
       stack = . + 1024;
     } > L2
}
