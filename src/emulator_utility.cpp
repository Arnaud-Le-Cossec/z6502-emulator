
#include "emulator_utility.h"

size_t memory_load(char* filename, uint16_t start_address, uint8_t* memory_ptr, size_t memory_size){
    size_t count;
    /*Open file*/
    FILE *file = fopen(filename, "rb");
    if(file == NULL){
        printf("Could not open file %s\n", filename);
        fclose(file);
        return 0;
    }

    /*Read file*/
    count = fread(memory_ptr, sizeof(uint8_t), memory_size, file);

    if(ferror(file) != 0){
        printf("Error reading file %s\n", filename);
        fclose(file);
        return 0;
    }
    printf("Loaded %zu bytes from file %s\n", count, filename);
    fclose(file);
    return count;
}

void memory_dump(uint16_t start_address, uint8_t* memory_ptr, uint16_t length){
    for(uint16_t i = 0; i < length; i++){
        if(i % 16 == 0){
            printf("\n%04X: ", start_address + i);
        }
        printf("%02X ", memory_ptr[start_address + i]);
    }
    printf("\n");
}

void cpu_state_dump(Z6502* cpu, uint8_t json_flag){
    register_set_t* reg = cpu->dump_register();
    const char std_format_str[] = "PC:%04X NEXT:%04X A:%02X X:%02X Y:%02X SP:%02X NV-BDIZC:%d%d%d%d%d%d%d%d opcode:%02X (%s %s)\n";
    const char json_format_str[] = "{ \"PC\": \"0x%04X\", \"NEXT\": \"0x%04X\", \"A\": \"0x%02X\", \"X\": \"0x%02X\", \"Y\": \"0x%02X\", \"SP\": \"0x%02X\", \"NV-BDIZC\": \"0b%d%d%d%d%d%d%d%d\", \"opcode\": \"0x%02X\", \"mnemonic\": \"%s\", \"addressing_mode\": \"%s\" }\n";

    printf(json_flag?json_format_str:std_format_str,
           cpu->get_instruction_address(),
           reg->program_counter,
           reg->accumulator,
           reg->x,
           reg->y,
           reg->stack_pointer,
           reg->processor_status.negative,
           reg->processor_status.overflow,
           1,
           reg->processor_status.break_flg,
           reg->processor_status.decimal_mode,
           reg->processor_status.irq_disable,
           reg->processor_status.zero,
           reg->processor_status.carry,
           cpu->get_instruction_opcode(),
           cpu->get_instruction_mnemonic(),
           cpu->get_addressing_mode_str()
           );
}