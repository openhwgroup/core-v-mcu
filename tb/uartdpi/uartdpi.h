// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef _UARTDPI_H_
#define _UARTDPI_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>

typedef struct {
  char ptyname[64];
  int master;
  int slave;
  char tmp_read;
} uartdpi_t;

void* uartdpi_create(const char *name);
int uartdpi_can_read(void* obj);
char uartdpi_read(void* obj);
void uartdpi_write(void* obj, char c);

#ifdef __cplusplus
}
#endif
#endif  // _UARTDPI_H_
