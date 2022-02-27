/*==========================================================
 * Copyright 2020 QuickLogic Corporation
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

#if !defined( _IN_CLI_H_ )
#error "Please include cli.h instead"
#endif


/**
* @brief Platform required function to get a key.
*
* @param nMSecs - how long to wait/delay sleep before returning.
*
* @returns EOF if no key ready, otherwise value 0x00 to 0xff
*/
int CLI_getkey_raw(int nMSecs);


/**
* @brief Platform required function, write byte to the serial port
*
* No newline or cr mapping.
*
* @param c - the byte to write.
*/
void CLI_putc_raw( int c );

/**
* @brief Platform function to current tick count in mSecs.
*/
uint32_t CLI_time_now(void);


/**
* @brief Platform function to sleep for nMsecs
*/
void CLI_sleep( int nMSecs );

/**
* @brief Platform function to sleep for micro-seconds
*/
void CLI_sleep_uSecs( int nUSecs );
