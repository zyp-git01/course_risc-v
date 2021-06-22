#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include <string.h>
#include "encoding.h"
#include <unistd.h>
#include "stdatomic.h"


#define DMA_REG_SOURCE_ADDR 0x04
#define DMA_REG_PURPOSE_ADDR 0x08
#define DMA_REG_BURST_ADDR 0x12
#define DMA_REG_STATE 0x16
void handle_m_ext_interrupt(){
    printf("irq_handle");
}

void dma_init(uint32_t *regDat)
{

    
    DMA_REG(DMA_REG_SOURCE_ADDR) = regDat[0];
    while (DMA_REG(DMA_REG_STATE) != 0x06){}
    printf("done");
    
    DMA_REG(DMA_REG_PURPOSE_ADDR) = regDat[1];
    while (DMA_REG(DMA_REG_STATE) != 0x04){}
    printf("done");

    DMA_REG(DMA_REG_BURST_ADDR) = regDat[2];

    while (DMA_REG(DMA_REG_STATE) != 0x00){}
    printf("done");
    if (DMA_REG(DMA_REG_STATE) == 0x00)
    {
        printf("done");
    }

}

int main(int argc,char **argv)
{
    set_csr(mie,MIP_MEIP);
	set_csr(mstatus,MSTATUS_MIE);
    uint32_t data_list[3] = {0x20000000,0x30000000,0x00000271};
    dma_init(data_list);
    for (int j = 0;j < 3;j++)
    {
        if (j == 2)
            j - 1;
        else 
            j + 1;
    }
}













