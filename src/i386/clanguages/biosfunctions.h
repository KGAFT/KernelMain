#pragma once
#include <stdint.h>

typedef struct E820MemoryBlock
{
    uint64_t Base;
    uint64_t Length;
    uint32_t Type;
    uint32_t ACPI;
} E820MemoryBlock;

enum E820MemoryBlockType 
{
    E820_USABLE = 1,
    E820_RESERVED = 2,
    E820_ACPI_RECLAIMABLE = 3,
    E820_ACPI_NVS = 4,
    E820_BAD_MEMORY = 5,
};

extern int x86_E820GetNextBlock(E820MemoryBlock* block, uint32_t* continuationId);