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

/* 
 * Lightweight timer, and timeout functions usable in commands.
 */

/**
* @brief Start a lightweight polled timer, return a token.
*
*/
intptr_t CLI_timeout_start( void );

/**
* @brief Determine if a light weigth timeout timer has expired.
*
* @param token - from CLI_timeout_start()
* @param n     - how many msecs the timeout is for, negative is "never"
*
* @returns non zero if true.
*/
int CLI_timeout_expired( intptr_t cookie, int n );

/**
* @brief Return number of mSecs that remain within this timeout period.
*
* @param token - from CLI_timeout_start()
*/
int CLI_timeout_remain( intptr_t token );
