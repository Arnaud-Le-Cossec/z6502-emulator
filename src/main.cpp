/**
 *   ____         _            
 *  |_  /___ _ __| |_ _  _ _ _ 
 *   / // -_) '_ \ ' \ || | '_|
 *  /___\___| .__/_||_\_, |_|  
 *          |_|       |__/ Project 
 * 
 * [Zephyr DX82x Series Emulator]
 * (c)2025 - Written by Arnaud LE COSSEC
 * MIT Licence - see licence file
 */

#include <stdlib.h>
#include <stdio.h>
#include "emulator_utility.h"
#include "z6502.h"

int main(int argc,char ** argv) {
    //std::cout << "zephyr_dx82_emulator started." << std::endl;

    // le programme prend 3 arguments: le nom du fichier pour cr�er la cl�, le nombre de s�maphore ainsi que la valeur initiale
	if (argc!=2) { fprintf(stderr,"Usage: %s ROM_file\n",argv[0]);
					return 1;
	}

    /*Allocate memory and io spaces*/
    uint8_t* memory_space = (uint8_t*)malloc(Z6502_MAX_MEMORY_SIZE_BYTES*sizeof(uint8_t));

    if(memory_space == NULL){
        fprintf(stderr, "[CRITICAL] Memory allocation error\n");
        return -1;
    }

    /*Load memory*/
    if(memory_load(argv[1], 0x0000U, memory_space, Z6502_MAX_MEMORY_SIZE_BYTES) < 0){
        fprintf(stderr, "[ ERROR  ] Could not load ROM file");
        return -1;
    }

    /*Create components*/
    Z6502 cpu(memory_space);

    free(memory_space);
    return 0;
}
