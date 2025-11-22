/*                       
     _____ ___ ___ ___ ___ 
    |__   |  _|  _|   |_  |     Z6502 CPU Emulator
    |   __| . |_  | | |  _|     Copyright (C) 2025 - Arnaud LE COSSEC
    |_____|___|___|___|___|     version 1.0.0
                       
    This program is free software; you can redistribute it and/or modify
    it under the terms of the MIT License.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    MIT License for more details.    
*/

#include "z6502.h"


void _op_ADC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    switch (mode)
    {
    case IMM:
        reg->accumulator += mem[reg->program_counter];
        reg->program_counter++;
        break;
    case ZP:
        {
            uint8_t addr = mem[reg->program_counter];
            reg->accumulator += mem[addr];
            reg->program_counter++;
        }
        break;
    case ZPX:
        {
            uint8_t addr = (mem[reg->program_counter] + reg->x) % 256;
            reg->accumulator += mem[addr];
            reg->program_counter++;
        }
        break;
    case ABS:
        {
            uint16_t lo = mem[reg->program_counter];
            uint16_t hi = mem[reg->program_counter + 1];
            uint16_t addr = (hi << 8) | lo;
            reg->accumulator += mem[addr];
            reg->program_counter += 2;
        }
        break;
    case ABX:
        {
            uint16_t lo = mem[reg->program_counter];
            uint16_t hi = mem[reg->program_counter + 1];
            uint16_t addr = ((hi << 8) | lo) + reg->x;
            reg->accumulator += mem[addr];
            reg->program_counter += 2;
        }
        break;
    case ABY:
        {
            uint16_t lo = mem[reg->program_counter];
            uint16_t hi = mem[reg->program_counter + 1];
            uint16_t addr = ((hi << 8) | lo) + reg->y;
            reg->accumulator += mem[addr];
            reg->program_counter += 2;
        }
        break;
    case INX:
        {
            uint8_t zp_addr = (mem[reg->program_counter] + reg->x) % 256;
            uint16_t lo = mem[zp_addr];
            uint16_t hi = mem[(zp_addr + 1) % 256];
            uint16_t addr = (hi << 8) | lo;
            reg->accumulator += mem[addr];
            reg->program_counter++;
        }
        break;
    case INY:
        {
            uint8_t zp_addr = mem[reg->program_counter];
            uint16_t lo = mem[zp_addr];
            uint16_t hi = mem[(zp_addr + 1) % 256];
            uint16_t addr = ((hi << 8) | lo) + reg->y;
            reg->accumulator += mem[addr];
            reg->program_counter++;
        }
        break;
    default:
        break;
    }
}
void _op_AND(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_ASL(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_BCC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_BCS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_BEQ(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_BIT(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_BMI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_BNE(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_BPL(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_BRK(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_BVC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_BVS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_CLC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_CLD(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_CLI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_CLV(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_CMP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_CPX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_CPY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_DEC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_DEX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_DEY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_EOR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_INC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_INX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_INY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_JMP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_JSR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_LDA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_LDX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_LDY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_LSR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_NOP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_ORA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_PHA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_PHP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_PLA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_PLP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_ROL(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_ROR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_RTI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_RTS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_SBC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_SEC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_SED(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_SEI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_STA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_STX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_STY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_TAX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_TAY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_TSX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_TXA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_TXS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}
void _op_TYA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){}


Z6502::Z6502(uint8_t* memory_space)
{
    _memory_space = memory_space;
}

void Z6502::reset(void) {
    /*Init special purpose registers*/
    _reg.program_counter = 0U;
    _reg.stack_pointer = 0U;
    _reg.accumulator = 0U;
    _reg.x = 0U;
    _reg.y = 0U;

    _reg.processor_status.carry = 0U;
    _reg.processor_status.zero = 0U;
    _reg.processor_status.irq_disable = 0U;
    _reg.processor_status.decimal_mode = 0U;
    _reg.processor_status.break_cmd = 0U;
    _reg.processor_status.overflow = 0U;
    _reg.processor_status.negative = 0U;
}

int Z6502::step(void) {
    /*Read instruction*/
    uint8_t opcode = _memory_space[_reg.program_counter];
    _reg.program_counter++;

    /*Execute instruction*/
    if(instruction_set[opcode] != NULL){
        instruction_set[opcode](_memory_space, &_reg, instruction_mode[opcode]);
    }
    else{
        //Unhandled opcode
    }

    return 0;
}

Z6502::~Z6502()
{
}

void func1(){}
void func2(){}
void func3(){}