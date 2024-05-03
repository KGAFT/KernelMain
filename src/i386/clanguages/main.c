#include "biosfunctions.h"
#include <stdlib.h>

void Main386() {
    uint32_t nextId = 0;
    E820MemoryBlock memBlock;
    do{
        x86_E820GetNextBlock(&memBlock, &nextId);
    }while(nextId!=0);
}
