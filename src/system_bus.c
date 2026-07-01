#include "system_bus.h"

void system_bus_init(system_bus_t* bus_s, uint8_t* memory_ptr, size_t memory_size){
    bus_s->memory_ptr = memory_ptr;
    bus_s->memory_size = memory_size;
}

uint8_t system_bus_z6502_read_clbk(z6502_cpu_t* cpu_s, uint16_t offset){
    if(offset <= 0x7F00 || offset >= 0x8000){
        /*CPU RAM*/
        return bus_gs.memory_ptr[offset];
    }
    else if(offset >= 0x7F00 && offset <= 0x7F03){
        /*6551 ACIA*/
        return z6551_read(&acia_gs, (z6551_register_select_t)(offset & 0b11));
    }
    else{
        /*Floating bus*/
        return 0;
    }
}

void system_bus_z6502_write_clbk(z6502_cpu_t* cpu_s, uint16_t offset, uint8_t value){
    if(offset <= 0x7F00 || offset >= 0x8000){
        /*CPU RAM*/
        bus_gs.memory_ptr[offset] = value;
    }
    else if(offset >= 0x7F00 && offset <= 0x7F03){
        /*6551 ACIA*/
        return z6551_write(&acia_gs, (z6551_register_select_t)(offset & 0b11), value);
    }
    else{
        /*Floating bus*/
        return;
    }
}