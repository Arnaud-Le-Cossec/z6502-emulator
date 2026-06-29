#ifndef SYSTEM_BUS_H_INCLUDED
#define SYSTEM_BUS_H_INCLUDED

#include <stdint.h>
#include <stddef.h>
#include "z6502.h"

#define SYSTEM_BUS_READ(addr) system_bus_read(&bus_s, addr)
#define SYSTEM_BUS_WRITE(addr, val) system_bus_write(&bus_s, addr, val);

//*****************************************************************************
// Prototypes
//*****************************************************************************

/*System bus structure*/
typedef struct
{   
    /*Memory*/
    uint8_t* memory_ptr;
    size_t memory_size;

} system_bus_t;

//*****************************************************************************
// Global components declaration
//*****************************************************************************

extern system_bus_t bus_s;
//extern z6502_cpu_t cpu_s;

//*****************************************************************************
// Prototypes
//*****************************************************************************

void system_bus_init(system_bus_t* bus_s, uint8_t* memory_ptr, size_t memory_size);

uint8_t system_bus_read(system_bus_t* bus_s, uint16_t offset);
void system_bus_write(system_bus_t* bus_s, uint16_t offset, uint8_t value);

#endif // SYSTEM_BUS_H_INCLUDED