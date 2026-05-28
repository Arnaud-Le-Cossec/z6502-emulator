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
#include <unistd.h>
#include "emulator_utility.h"
#include "z6502.h"

int main(int argc,char ** argv) {
    int opt;
    int verbose_flag = 0;
    int json_flag = 0;
    int step_mode = 0;
    int clock_frequency = 1; //Default 1Hz

    /*Parse command line options*/
    while ((opt = getopt(argc, argv, "vjsf:")) != -1) {
        switch (opt) {
            case 'v':
                verbose_flag = 1;
                break;
            case 'j':
                json_flag = 1;
                break;
            case 's':
                step_mode = 1;
                break;
            case 'f':
                clock_frequency = strtol(optarg, NULL, 10);
                if(clock_frequency < 0){
                    fprintf(stderr, "Invalid clock frequency\n");
                    exit(EXIT_FAILURE);
                }
                break;
            default:
                fprintf(stderr, "Usage: %s [-v] [-j] [-s] [-f frequency] ROM_file\n", argv[0]);
                exit(EXIT_FAILURE);
        }
    }
    
    if (optind >= argc) {
               fprintf(stderr, "Expected ROM file path after options\n");
               exit(EXIT_FAILURE);
    }
    
    printf("ROM file path argument = %s\n", argv[optind]);

    /*Allocate memory and io spaces*/
    uint8_t* memory_space = (uint8_t*)malloc(Z6502_MAX_MEMORY_SIZE_BYTES*sizeof(uint8_t));

    if(memory_space == NULL){
        fprintf(stderr, "[CRITICAL] Memory allocation error\n");
        exit(EXIT_FAILURE);
    }

    /*Load memory*/
    if(memory_load(argv[optind], 0x0000U, memory_space, (size_t)Z6502_MAX_MEMORY_SIZE_BYTES) == 0){
        fprintf(stderr, "[ ERROR  ] Could not load ROM file\n");
        free(memory_space);
        exit(EXIT_FAILURE);
    }

    /*Create components*/
    Z6502 cpu(memory_space);

    memory_dump(0x0000U, memory_space, 256);

    /*Reset CPU*/
    cpu.reset();

    //if(verbose_flag){
    //    cpu_state_dump(&cpu);
    // }



    /*Emulation loop*/
    while(1){

        cpu.step();
        

        if(verbose_flag){
            cpu_state_dump(&cpu, (uint8_t)json_flag);
        }

        if(step_mode){
            printf("Press ENTER to execute next instruction...\n");
            getchar();
        }
        else{
            if(clock_frequency > 0) usleep(1000000 / clock_frequency);
        }

    }

    free(memory_space);
    return 0;
}
