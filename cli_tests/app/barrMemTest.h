#ifndef __BARR_MEM_TEST_H__
#define __BARR_MEM_TEST_H__

typedef unsigned char datum;     /* Set the data bus width to 8 bits. */

#define BASE_ADDRESS  (volatile datum *) (&__l2_shared_end)//(volatile datum *) 0x00000000
#define NUM_BYTES     32 * 1024//64 * 1024

datum memTestDataBus(volatile datum * address);
datum memTestDataBusNBytes(volatile datum * baseAddress, unsigned long nBytes);
datum *memTestAddressBus(volatile datum * baseAddress, unsigned long nBytes);
datum *memTestDevice(volatile datum * baseAddress, unsigned long nBytes);
int memTest(uint32_t aNumOfKBs);
#endif

