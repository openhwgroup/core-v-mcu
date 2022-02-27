#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdint.h>

#define APBIO_STRING "apbio_"
#define FPGAIO_STRING "fpgaio_"

int8_t gLineBuf[128] = {0};
int8_t gStrTokBuf[128] = {0};
int16_t gsIONumBuf[50][4] = {0};
int16_t gLineCount = 0;

void processLine(int8_t *aBuf, int16_t aLen)
{
    int16_t lTokenIndex = 0;
    int16_t io_num = 0;
    int16_t fpgaio_num = 0;
    // Returns first token
    int8_t *token = (int8_t *)NULL;
    int8_t *string = gStrTokBuf;

    memcpy(gStrTokBuf, gLineBuf, aLen);
    //printf("[%s]\n", gStrTokBuf);

    while( (token = strsep(&string,",")) != NULL )
    {
        if( lTokenIndex >= 4 )
        {
            //printf("%d) %s\n", lTokenIndex, token);
            if( strncmp((const char *)token, (const char *)APBIO_STRING, strlen(APBIO_STRING) ) == 0 )
            {
                io_num = atoi( (const char *) (token + strlen(APBIO_STRING) ) );
                //printf("io_num = %d\n", io_num);
                gsIONumBuf[gLineCount - 2][lTokenIndex - 4] = io_num;

            }
            else if( strncmp( (const char *)token, (const char *)FPGAIO_STRING, strlen(FPGAIO_STRING)) == 0 )
            {
                fpgaio_num = atoi( (const char *)(token + strlen(FPGAIO_STRING)) );
                //printf("[%s] = 0x%x\n", (const char *)(token + strlen(FPGAIO_STRING)) ,fpgaio_num);
                gsIONumBuf[gLineCount - 2][lTokenIndex - 4] = (0x0100 + fpgaio_num);
            }
            else
            {
                gsIONumBuf[gLineCount - 2][lTokenIndex - 4] = -1;
            }
        }
        lTokenIndex++;
    }
    //printf("%d tokens found\n", lTokenIndex);
}

int main(int argc, char *argv[])
{
    FILE *lCSVFileReadPtr = (FILE *)NULL;
    FILE *lOutHeaderFileWritePtr = (FILE *)NULL;
    FILE *lOutFileWritePtr = (FILE *)NULL;

    char c = 0;
    int i = 0, j = 0;
    if(argc < 1 )
    {
        printf("Usage: csv2h <input.bin>\n");
    }
    else
    {
        printf("Converting %s\n", argv[1]);

        lCSVFileReadPtr = fopen(argv[1],"r");  // r for read, b for binary
        lOutHeaderFileWritePtr = fopen ("gpio_map.h","w");
        lOutFileWritePtr = fopen ("gpio_map.c","w");

        if(  ( lCSVFileReadPtr ) && ( lOutFileWritePtr ) )
        {

            c = fgetc(lCSVFileReadPtr);
            while (c != EOF)
            {
                if( c == '\n')
                {
                    gLineBuf[i++] = 0;

                    gLineCount++;
                    if( gLineCount > 1 )
                    //if( gLineCount == 27 )
                    //if( gLineCount == 31 )
                    {
                        //printf("[%s <%d>]\n",gLineBuf, i);
                        processLine(gLineBuf, i);
                    }
                    i = 0;
                }
                else
                {
                    gLineBuf[i++] = c;
                }

                c = fgetc(lCSVFileReadPtr);
            }


            printf("[DONE] %d\n", gLineCount-1); //Since first line was skipped

            fprintf(lOutHeaderFileWritePtr,"/*This is a generated file*/\n\n");
            fprintf(lOutHeaderFileWritePtr,"#ifndef __PINMAP_H__\n#define __PINMAP_H__\n\n\n");
            fprintf(lOutHeaderFileWritePtr,"typedef struct {\n\tshort pm[4];\n }gpio_struct_t;\n\n");
            fprintf(lOutHeaderFileWritePtr,"extern gpio_struct_t gpio_map[];\n");
            fprintf(lOutHeaderFileWritePtr,"#endif\n");

            fprintf(lOutFileWritePtr,"/*This is a generated file*/\n\n");
            fprintf(lOutFileWritePtr,"#include \"gpio_map.h\"\n");
            fprintf(lOutFileWritePtr,"gpio_struct_t gpio_map[48] = ");
            fprintf(lOutFileWritePtr,"{ ");
            for(i=0; i<gLineCount-1; i++ )
            {
                fprintf(lOutFileWritePtr,"{");
                for(j=0; j<4; j++ )
                {
                    if( gsIONumBuf[i][j] != (-1) )
                    {
                        fprintf(lOutFileWritePtr,"0x%x",gsIONumBuf[i][j]);
                    }
                    else
                    {
                        fprintf(lOutFileWritePtr,"%d",gsIONumBuf[i][j]);
                    }
                    if( j == 3 )
                    {
                        if( i == gLineCount-2 )
                            fprintf(lOutFileWritePtr,"}\n");
                        else
                            fprintf(lOutFileWritePtr,"},\n");
                    }
                    else
                        fprintf(lOutFileWritePtr,", ");
                    fflush(lOutFileWritePtr); // Prints to screen or whatever your standard out is
                }
            }
            fprintf(lOutFileWritePtr,"};\n");

            fclose(lCSVFileReadPtr);
            fclose(lOutFileWritePtr);
            fclose(lOutHeaderFileWritePtr);
        }
        else
        {
            printf("FILE access error\n");
        }
    }
}
