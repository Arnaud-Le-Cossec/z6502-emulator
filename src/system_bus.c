#include "system_bus.h"

void system_bus_init(system_bus_t* bus_s, uint8_t* memory_ptr, size_t memory_size){
    bus_s->memory_ptr = memory_ptr;
    bus_s->memory_size = memory_size;
}

uint8_t system_bus_read(system_bus_t* bus_s, uint16_t offset){
    if(offset <= 0x7F00 || offset >= 0x8000){
        /*CPU RAM*/
        return bus_s->memory_ptr[offset];
    }
    else if(offset >= 0x7F00 && offset <= 0x7F03){
        /*6551 ACIA*/
        return 1;
    }
    else{
        /*Floating bus*/
        return 0;
    }
}

void system_bus_write(system_bus_t* bus_s, uint16_t offset, uint8_t value){
    if(offset <= 0x7F00 || offset >= 0x8000){
        /*CPU RAM*/
        bus_s->memory_ptr[offset] = value;
    }
    else if(offset >= 0x7F00 && offset <= 0x7F03){
        /*6551 ACIA*/
        return;
    }
    else{
        /*Floating bus*/
        return;
    }
}