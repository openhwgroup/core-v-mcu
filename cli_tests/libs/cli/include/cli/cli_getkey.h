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
* @brief Peek keyboard, if present return key otherwise EOF with timeout.
*
* @param nMsec_delay - how long in mSecs before giving up, 0 means none,-1 forever
*/
int CLI_getkey_peek( int delay );


/**
* @brief Unget the key
*
* @param keyvalue - value to unget
*
* Note: Negative numbers are *NOT* allowed
*/
void CLI_ungetkey(int value);



/**
* @brief get a key from the keyboard.
*
* @param delay - nMsecs to wait for a key, -1 is for ever.
*
* returns EOF on timeout, or the key pressed.
*/

int CLI_getkey( int delay );


/* these keycodes come from TERATERM in VT100 mode
 *
 * There is no magic to the number choices, I just choose
 * to use the actual byte values sent when you press keys.
 *
 * For example...
 * When you press a key like RIGHT ARROW tera term sends ESC[D
 * Hence the key code is 0x5b, and 'A' 
 * The same schema is used for other keys
 */

#define _KEYCODE32( A,B, C, D )  ( ((A) << 24) | ((B) << 16 ) | ((C) << 8) | ((D) << 0) )
#define _KEYCODE2( A, B )         _KEYCODE32( 0, 0x5b, (A), (B))
#define _KEYCODE1( A )            _KEYCODE32( 0, 0, 0x5b, (A))



#define KEY_UARROW      _KEYCODE1( 'A' )
#define KEY_DARROW      _KEYCODE1( 'B' )
#define KEY_RARROW      _KEYCODE1( 'C' )
#define KEY_LARROW      _KEYCODE1( 'D' )
/* set teraterm to VT100 mode.*/
#define KEY_F1			_KEYCODE2(11,0x7e)
#define KEY_F2			_KEYCODE2(12,0x7e)
#define KEY_F3			_KEYCODE2(13,0x7e)
#define KEY_F4			_KEYCODE2(14,0x7e)
#define KEY_F5			_KEYCODE2(15,0x7e)
/* yes, 16 is skipped */
#define KEY_F6			_KEYCODE2(17,0x7e)
#define KEY_F7			_KEYCODE2(18,0x7e)
#define KEY_F8			_KEYCODE2(19,0x7e)
#define KEY_F9			_KEYCODE2(20,0x7e)
#define KEY_F10			_KEYCODE2(21,0x7e)
#define KEY_F11			_KEYCODE2(23,0x7e)
#define KEY_F12			_KEYCODE2(24,0x7e)

#define KEY_HOME        _KEYCODE2(1,0x7e)
#define KEY_INSERT      _KEYCODE2(2,0x7e)
#define KEY_END         _KEYCODE2(4,0x7e)
#define KEY_PAGE_UP     _KEYCODE2(5,0x7e)
#define KEY_PAGE_DN     _KEYCODE2(6,0x7e)

/* vt100 keypad */
#define KEY_PF1         _KEYCODE32( 'P', 'F', 'O','P' )
#define KEY_PF2         _KEYCODE32( 'P', 'F', 'O','Q' )
#define KEY_PF3         _KEYCODE32( 'P', 'F', 'O','R' )
#define KEY_PF4         _KEYCODE32( 'P', 'F', 'O','S' )

#define KEY_BACKSPACE           8
#define KEY_DELETE              0x7f

#define KEY_ENTER               0x0d
#define KEY_LINEFEED            0x0a

#define KEY_TAB                 9

