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
* @file cli_args.h
* 
* @brief This file defines parameter or argument parsing functions, or related functions.
*
* Error Handling
*
* Error Handling is automatic, via setjump/longjump.  At the top of
* the command and parameter parsing a call to setjump() is made, and
* in the CLI_error() function after printing the error message, a
* call to longjmp() is made.
*
* Required, and Optional Parameters
*
* The _required() suffix, Example: CLI_string_buf_lc_required()
* indicates that a parameter is required, if it is missing then an
* error message is printed.
*
* The _getshow() suffix, Example:  CLI_string_buf_lc_getshow()
* indicates the parameter is optional.
*
* The purpose of the "getshow()" is to allow the human (or test script)
* to question, or query the current value of the parameter.
*
* For example:
*
*    > sometopcommand  subcommand parametername 
*
* Would would print the current value of the parameter.
*
*    > sometopcommand  subcommand parametername SOMEVALUE
*
* A wide varirety of parameter types are supported.
*
*/

/**
* @brief expect no more parameters on cmdline, otherwise raise error
*/
void CLI_no_more_args( void );

/**
* @brief Return nonzero if there are more parameters.
*/
int CLI_is_more_args( void );

/* expect N more parameters */
void CLI_n_more_args( const char *name, int n );

/* Peek next arg, return NULL if there are no more */
const char *CLI_peek_next_arg(void);

/**
* @defgroup String type parameter functions.
* 
* Note: The term: _lc_ verses (blank) in the name means the input
* string is forced to lower case before returning. Without _lc_, the
* string is left "as is"
*
* The term: _ptr_ verses _buf_, means the value is either a pointer
* or a string, in the buf case, if the input value is too long an
* error message is printed.
*
* @{
*/

/* get/show a string in a ptr, lowercase or not is controled by is_lc */
int CLI_string_ptr_xx_getshow(const char *name, char **puthere, int is_lc );
void CLI_string_ptr_xx_required( const char *name, char **puthere, int is_lc );

/* get/show a string that is forced to lower case */
int CLI_string_ptr_lc_getshow(const char *name, char **puthere);
void CLI_string_ptr_lc_required( const char *name, char **puthere);

/* get/show a string that case remains untouched */
int CLI_string_ptr_getshow(const char *name, char **puthere);
void CLI_string_ptr_required( const char *name, char **puthere);

/* get/show a string in a buffer, lowercase or not is controled by is_lc */
int CLI_string_buf_xx_getshow(const char *name, char *puthere, size_t buflen, int is_lc );
void CLI_string_buf_xx_required( const char *name, char *puthere, size_t buflen, int is_lc );

/* get/dhow a string in a buffer, case is forced to lower */
int CLI_string_buf_lc_getshow(const char *name, char *puthere, size_t buflen);
void CLI_string_buf_lc_required( const char *name, char *puthere, size_t buflen);

/* get/dhow a string in a buffer, case is left as is */
int CLI_string_buf_getshow(const char *name, char *puthere, size_t buflen);
void CLI_string_buf_required( const char *name, char *puthere, size_t buflen);

/*
* @}
*/

/**
* @brief Fetch the next string which is required and is a subcommand.
*/
void CLI_string_ptr_get_subcmd( char **puthere );

/**
* @brief core workhorse for all non-float parameters
* 
* @param name - name of paraemeter
* @param puthere - where to put/get value
* @param width bit width of the value
* @param flags - required & show flags
*
* Flags values are OR'ed, see:
*   CLI_NUMX_GETSHOW_FLAG_xxx below.
*   
* Note: For width, it is one of 8, 16, 32, 64, or 'I' (0x49)
* If the width is negative, the value is signed
* If the width is positive, the value is unsigned.
*/
#define CLI_NUMX_GETSHOW_FLAG_none     0
#define CLI_NUMX_GETSHOW_FLAG_hex      1
#define CLI_NUMX_GETSHOW_FLAG_required 2

int CLI_numX_getshow_X( const char *name, void *puthere, int width, int flags );

/**
* @brief Get/Show a boolean type parameter.
*
* @param name - the name of the parameter
* @param puthere - where to put the parameter.
*
* Note: For boolean, a wide varity of "truth" and "false" is
* supported for input.  examples include: t, true, 1, y, yes.  For
* output, only the text "true" and "false" is provided.
*/
int CLI_bool_getshow(const char *name, int *puthere);
int CLI_bool_required(const char *name, int *puthere);

/**
* @defgroup Get/Show a integer type parameter.
*
* @param name - the name of the parameter
* @param puthere - where to put the parameter.
*
* If the value was not present, the value EOF is returned.
* Your code should test for EOF, example:
* 
*  if( EOF == CLI_intgetshow( "foo", &foo" ) ){
*      printf("value was not present\n");
*  } else {
*      printf("A value was present\n");
*  }
*
* Numbers may be in any C format.  If the value is too large, it is
* ignored.  Example: Setting a uint8 to 0x1234 is too large.
*
* @{
*/
int CLI_int_getshow( const char *name, int *puthere );
int CLI_unsigned_getshow( const char *name, unsigned *puthere );
int CLI_int8_getshow( const char *name, int8_t *puthere );
int CLI_int16_getshow( const char *name, int16_t *puthere );
int CLI_int32_getshow( const char *name, int32_t *puthere );
int CLI_int64_getshow( const char *name, int64_t *puthere );
int CLI_uint8_getshow( const char *name, uint8_t *puthere );
int CLI_uint16_getshow( const char *name, uint16_t *puthere );
int CLI_uint32_getshow( const char *name, uint32_t *puthere );
int CLI_uint64_getshow( const char *name, uint64_t *puthere );

void CLI_int_required( const char *name, int *puthere );
void CLI_unsigned_required( const char *name, unsigned *puthere );
void CLI_int8_required( const char *name, int8_t *puthere );
void CLI_int16_required( const char *name, int16_t *puthere );
void CLI_int32_required( const char *name, int32_t *puthere );
void CLI_int64_required( const char *name, int64_t *puthere );
void CLI_uint8_required( const char *name, uint8_t *puthere );
void CLI_uint16_required( const char *name, uint16_t *puthere );
void CLI_uint32_required( const char *name, uint32_t *puthere );
void CLI_uint64_required( const char *name, uint64_t *puthere );

/*
* @}
*/

/**
* @brief Get/Show a floating point type variable.
*
* @param name - name of the parameter
* @param puthere - where the parameter gets put.
*/
int CLI_float_getshow( const char *name, float *puthere );
int CLI_float_required( const char *name, float *puthere );


