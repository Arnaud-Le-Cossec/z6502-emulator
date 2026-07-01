#ifndef SYSTEM_BUS_H_INCLUDED
#define SYSTEM_BUS_H_INCLUDED

#include <stdint.h>
#include <stddef.h>
#include "z6502.h"
#include "z6551.h"

//#define SYSTEM_BUS_READ(addr) system_bus_read(&bus_s, addr)
//#define SYSTEM_BUS_WRITE(addr, val) system_bus_write(&bus_s, addr, val);

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

extern system_bus_t bus_gs;
extern z6502_cpu_t cpu_gs;
extern z6551_acia_t acia_gs;

//*****************************************************************************
// Prototypes
//*****************************************************************************

void system_bus_init(system_bus_t* bus_s, uint8_t* memory_ptr, size_t memory_size);

uint8_t system_bus_z6502_read_clbk(z6502_cpu_t* cpu_s, uint16_t addr);
void system_bus_z6502_write_clbk(z6502_cpu_t* cpu_s, uint16_t addr, uint8_t val);

#endif // SYSTEM_BUS_H_INCLUDED