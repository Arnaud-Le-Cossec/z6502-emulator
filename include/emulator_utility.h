#include <cstdint>
#include <stdio.h>
#include "z6502.h"

/**
 * @brief Load memory from dumpfile
 * @param filename Dumpfile file name
 * @param address Memory start address
 * @param memory_ptr Load target
 * @param memory_size Max memory size
 * @returns Number of bytes loaded. 0 if error
 */
size_t memory_load(char* filename, uint16_t start_address, uint8_t* memory_ptr, size_t memory_size);


/**
 * @brief Dump memory to console
 * @param start_address Memory start address
 * @param memory_ptr Memory pointer
 * @param length Number of bytes to dump
 */
void memory_dump(uint16_t start_address, uint8_t* memory_ptr, uint16_t length);

/**
 * @brief Dump CPU state to console
 * @param cpu Pointer to Z6502 CPU instance
 */
void cpu_state_dump(Z6502* cpu);
