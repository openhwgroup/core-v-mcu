#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

char gFilePathBuf[256] = {0};
char gFileNameBuf[32] = {0};

uint8_t parseInputFileName(char *aInStr)
{
    int16_t i = 0;
    int16_t len = 0;
    uint8_t lSts = 0;
    char *ret = (char *)NULL;
    char *lEndPtr = (char *)NULL;
    char *lStartPtr = (char *)NULL;

    len = strlen(aInStr);
    ret = strstr(aInStr, ".bin");
    if( ret )
    {
        lEndPtr = ret;
        ret--;
        while( (*ret != '\\') && ( *ret != '/') && ( *ret != '.')  && ( i < (len - 4) ) )
        {
            ret--;
            i++;
        }
        lStartPtr = ret+1;

        i = 0;
        while( lStartPtr < lEndPtr )
        {
            gFileNameBuf[i] = *lStartPtr;
            i++;
            lStartPtr++;
        }
        sprintf(gFilePathBuf,"../../../memoryInitFiles/%s.txt",gFileNameBuf);
        lSts = 1;
    }
    else
    {
        lSts = 0;
    }
    return lSts;
}
int main(int argc, char *argv[])
{
    FILE *lBinFileReadPtr = (FILE *)NULL;
    FILE *lTxtFileWritePtr = (FILE *)NULL;
    long int lBinFileSize = 0;
    uint8_t lData = 0;

    if(argc < 1 )
    {
        printf("Usage: bin2txt <input.bin>\n");
    }
    else
    {
        lBinFileReadPtr = fopen(argv[1],"rb");  // r for read, b for binary
        if( lBinFileReadPtr )
        {

            parseInputFileName(argv[1]);
            printf("Converting %s to %s\n", argv[1], gFilePathBuf);
            lTxtFileWritePtr = fopen (gFilePathBuf,"w");

            if( lTxtFileWritePtr )
            {
                fseek(lBinFileReadPtr, 0, SEEK_END); // seek to end of file
                lBinFileSize = ftell(lBinFileReadPtr); // get current file pointer
                fseek(lBinFileReadPtr, 0, SEEK_SET); // seek back to beginning of file
                printf("File [%s] is of %ld bytes\n",argv[1], lBinFileSize);

                while( lBinFileSize )
                {
                    fread(&lData, sizeof(lData), 1, lBinFileReadPtr);
                    fprintf(lTxtFileWritePtr, "%02x \n",lData);
                    lBinFileSize--;
                }
                fclose(lBinFileReadPtr);
                fclose(lTxtFileWritePtr);

                printf("[DONE]\n");
            }
            else
            {
                printf("FILE access error 1\n");
            }
        }
        else
        {
            printf("FILE access error 0\n");
        }
    }

    return 0;
}
