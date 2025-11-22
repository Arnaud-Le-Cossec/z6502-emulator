#include <cstdint>

/**
 * @brief Load memory from dumpfile
 * @param filename Dumpfile file name
 * @param address Memory start address
 * @param memory_ptr Load target
 * @param memory_size Max memory size
 * @returns Number of bytes loaded. -1 if error
 */
int memory_load(char* filename, uint16_t start_address, uint8_t* memory_ptr, uint16_t memory_size);