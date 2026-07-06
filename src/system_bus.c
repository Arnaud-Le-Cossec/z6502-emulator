#include "system_bus.h"

void system_bus_init(system_bus_t* bus_s, uint8_t* memory_ptr, size_t memory_size, system_bus_memory_map_t memory_map){
    bus_s->memory_ptr = memory_ptr;
    bus_s->memory_size = memory_size;
    bus_s->memory_map = memory_map;
}

uint8_t system_bus_z6502_read_clbk(z6502_cpu_t* cpu_s, uint16_t offset){
    switch (bus_gs.memory_map)
    {
        case MEMORY_MAP_64KB_RAM:
            return bus_gs.memory_ptr[offset];
        
        case MEMORY_MAP_64KB_RAM_PLUS_ACIA:
            if(offset < 0x7F00 || offset >= 0x8000){
                /*CPU RAM*/
                return bus_gs.memory_ptr[offset];
            }
            else if(offset >= 0x7F00 && offset <= 0x7F03){
                /*6551 ACIA*/
                uint8_t val = z6551_read(&acia_gs, (z6551_register_select_t)(offset & 0b11));
                //printf("[DEBUG] ACIA read value 0x%02X from offset 0x%04X\n", val, offset);
                return val;
            }
            else{
                /*Floating bus*/
                return 0;
            }
            
        default:
            return 0;
    }

}

void system_bus_z6502_write_clbk(z6502_cpu_t* cpu_s, uint16_t offset, uint8_t value){
    switch (bus_gs.memory_map)
    {
        case MEMORY_MAP_64KB_RAM:
            bus_gs.memory_ptr[offset] = value;
            break;

        case MEMORY_MAP_64KB_RAM_PLUS_ACIA:
            if(offset < 0x7F00 || offset >= 0x8000){
                /*CPU RAM*/
                bus_gs.memory_ptr[offset] = value;
            }
            else if(offset >= 0x7F00 && offset <= 0x7F03){
                /*6551 ACIA*/
                //printf("[DEBUG] ACIA write 0x%02X at offset 0x%04X\n", value, offset);
                z6551_write(&acia_gs, (z6551_register_select_t)(offset & 0b11), value);
            }
            else{
                /*Floating bus*/
                return;
            }
        
        default:
            break;
    }

}