#include <stdio.h>
#include "emulator_utility.h"

int memory_load(char* filename, uint16_t start_address, uint8_t* memory_ptr, uint16_t memory_size){
    int result;
    /*Open file*/
    FILE *file = fopen(filename, "r");
    if(file == NULL){
        fclose(file);
        return -1;
    }
    /*Read file*/
    result = fread(memory_ptr, sizeof(uint8_t), memory_size, file);
    if(ferror != 0){
        fclose(file);
        return -1;
    }
    fclose(file);
    return result;
}