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

#ifndef Z6502_CORE_H_INCLUDED
#define Z6502_CORE_H_INCLUDED

#include <cstdint>
#include <cstddef>

#define Z6502_MAX_MEMORY_SIZE_BYTES 65536U

#define FALSE 0U
#define TRUE 1U

/*Status indicator flags structure*/
typedef struct
{
    uint8_t carry;
    uint8_t zero;
    uint8_t irq_disable;
    uint8_t decimal_mode;
    uint8_t break_cmd;
    uint8_t overflow;
    uint8_t negative;
} flag_t;

/*Register set structure*/
typedef struct
{
    uint16_t program_counter;
    uint16_t stack_pointer;
    uint8_t accumulator;
    uint8_t x;
    uint8_t y;
    flag_t processor_status;
} register_set_t;

/*Instruction set opcodes*/


/*Addressing modes*/
enum addressing_mode_t
{
    ___, /* Undefined*/
    IMP, /* Implied */
    ACC, /* Accumulator */
    IMM, /* Immediate */
    ZP,  /* Zero Page */
    ZPX, /* Zero Page,X */
    ZPY, /* Zero Page,Y */
    REL, /* Relative */
    ABS, /* Absolute */
    ABX, /* Absolute,X */
    ABY, /* Absolute,Y */
    IND, /* Indirect */
    INX, /* X-indexed, indirect - aka (Indirect,X) */
    INY, /* Indirect, Y-indexed	- aka (Indirect),Y */
};

/*Instruction function prototypes*/
void _op_ADC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_AND(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_ASL(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_BCC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_BCS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_BEQ(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_BIT(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_BMI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_BNE(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_BPL(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_BRK(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_BVC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_BVS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_CLC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_CLD(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_CLI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_CLV(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_CMP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_CPX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_CPY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_DEC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_DEX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_DEY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_EOR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_INC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_INX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_INY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_JMP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_JSR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_LDA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_LDX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_LDY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_LSR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_NOP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_ORA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_PHA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_PHP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_PLA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_PLP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_ROL(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_ROR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_RTI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_RTS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_SBC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_SEC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_SED(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_SEI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_STA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_STX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_STY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_TAX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_TAY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_TSX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_TXA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_TXS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);
void _op_TYA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);


typedef void (*instruction_t)(uint8_t* mem, register_set_t* reg, addressing_mode_t mode);

static const instruction_t instruction_set[256] = {
    /* 0x00 - 0x0F */
    &_op_BRK,   &_op_ORA,   NULL,       NULL,       NULL,       &_op_ORA,   &_op_ASL,   NULL,   &_op_PHP,   &_op_ORA,   &_op_ASL,   NULL,   NULL,       &_op_ORA,   &_op_ASL,   NULL,
    /* 0x10 - 0x1F */
    &_op_BPL,   &_op_ORA,   NULL,       NULL,       NULL,       &_op_ORA,   &_op_ASL,   NULL,   &_op_CLC,   &_op_ORA,   NULL,       NULL,   NULL,       &_op_ORA,   &_op_ASL,   NULL,
    /* 0x20 - 0x2F */
    &_op_JSR,   &_op_AND,   NULL,       NULL,       &_op_BIT,   &_op_AND,   &_op_ROL,   NULL,   &_op_PLP,   &_op_AND,   &_op_ROL,   NULL,   &_op_BIT,   &_op_AND,   &_op_ROL,   NULL,
    /* 0x30 - 0x3F */
    &_op_BMI,   &_op_AND,   NULL,       NULL,       NULL,       &_op_AND,   &_op_ROL,   NULL,   &_op_SEC,   &_op_AND,   NULL,       NULL,   NULL,       &_op_AND,   &_op_ROL,   NULL,
    /* 0x40 - 0x4F */
    &_op_RTI,   &_op_EOR,   NULL,	    NULL,       NULL,       &_op_EOR,   &_op_LSR,   NULL,   &_op_PHA,   &_op_EOR,   &_op_LSR,   NULL,	&_op_JMP,   &_op_EOR,   &_op_LSR,   NULL,
    /* 0x50 - 0x5F */
    &_op_BVC,	&_op_EOR,   NULL,	    NULL,	    NULL,       &_op_EOR,   &_op_LSR,   NULL,   &_op_CLI,	&_op_EOR,   NULL,	    NULL,	NULL,	    &_op_EOR,   &_op_LSR,   NULL,
    /* 0x60 - 0x6F */
    &_op_RTS,	&_op_ADC,   NULL,	    NULL,	    NULL,	    &_op_ADC,   &_op_ROR,   NULL,   &_op_PLA,	&_op_ADC,   &_op_ROR,   NULL,	&_op_JMP,   &_op_ADC,   &_op_ROR,   NULL,
    /* 0x70 - 0x7F */
    &_op_BVC,   &_op_ADC,   NULL,	    NULL,	    NULL,	    &_op_ADC,   &_op_ROR,   NULL,   &_op_SEI,	&_op_ADC,   NULL,	    NULL,   NULL,	    &_op_ADC,   &_op_ROR,   NULL,
    /* 0x80 - 0x8F */
    NULL,       &_op_STA,   NULL,	    NULL,	    &_op_STY,   &_op_STA,   &_op_STX,   NULL,   &_op_DEY,	NULL,	    &_op_TXA,   NULL,	&_op_STY,   &_op_STA,   &_op_STX,   NULL,
    /* 0x90 - 0x9F */
    &_op_BCC,	&_op_STA,   NULL,	    NULL,	    &_op_STY,   &_op_STA,   &_op_STX,   NULL,   &_op_TYA,	&_op_STA,   &_op_TXS,   NULL,	NULL,	    &_op_STA,   NULL,       NULL,
    /* 0xA0 - 0xAF */
    &_op_LDY,   &_op_LDA,   &_op_LDX,   NULL,	    &_op_LDY,   &_op_LDA,   &_op_LDX,   NULL,   &_op_TAY,	&_op_LDA,   &_op_TAX,   NULL,	&_op_LDY,   &_op_LDA,   &_op_LDX,   NULL,
    /* 0xB0 - 0xBF */
    &_op_BCS,   &_op_LDA,   NULL,	    NULL,	    &_op_LDY,   &_op_LDA,   &_op_LDX,   NULL,   &_op_CLV,	&_op_LDA,   &_op_TSX,   NULL,	&_op_LDY,   &_op_LDA,   &_op_LDX,   NULL,
    /* 0xC0 - 0xCF */
    &_op_CPY,   &_op_CMP,   NULL,	    NULL,	    &_op_CPY,   &_op_CMP,   &_op_DEC,   NULL,   &_op_INY,	&_op_CMP,   &_op_DEX,   NULL,	&_op_CPY,   &_op_CMP,   &_op_DEC,   NULL,
    /* 0xD0 - 0xDF */
    &_op_BNE,	&_op_CMP,   NULL,	    NULL,	    NULL,	    &_op_CMP,   &_op_DEC,   NULL,   &_op_CLD,	&_op_CMP,   NULL,	    NULL,	NULL,	    &_op_CMP,   &_op_DEC,   NULL,
    /* 0xE0 - 0xEF */
    &_op_CPX,   &_op_SBC,   NULL,	    NULL,	    &_op_CPX,   &_op_SBC,   &_op_INC,   NULL,   &_op_INX,	&_op_SBC,   &_op_NOP,   NULL,	&_op_CPX,   &_op_SBC,   &_op_INC,   NULL,
    /* 0xF0 - 0xFF */
    &_op_BEQ,	&_op_SBC,   NULL,	    NULL,	    NULL,	    &_op_SBC,   &_op_INC,   NULL,   &_op_SED,	&_op_SBC,   NULL,	    NULL,	NULL,	    &_op_SBC,   &_op_INC,   NULL,
};

static const int instruction_cycles[256] = {
    /* 0x00 - 0x0F */
    7, 6, 0, 0, 0, 3, 5, 0, 3, 2, 2, 0, 0, 4, 6, 0,
    /* 0x10 - 0x1F */
    2, 5, 0, 0, 0, 4, 6, 0, 2, 4, 0, 0, 0, 4, 7, 0,
    /* 0x20 - 0x2F */
    6, 6, 0, 0, 3, 3, 5, 0, 4, 2, 2, 0, 4, 4, 6, 0,
    /* 0x30 - 0x3F */
    2, 5, 0, 0, 0, 4, 6, 0, 2, 4, 0, 0, 0, 4, 7, 0,
    /* 0x40 - 0x4F */
    6, 6, 0, 0, 0, 3, 5, 0, 3, 2, 2, 0, 3, 4, 6, 0,
    /* 0x50 - 0x5F */
    2, 5, 0, 0, 0, 4, 6, 0, 2, 4, 0, 0, 0, 4, 7, 0,
    /* 0x60 - 0x6F */
    6, 6, 0, 0, 0, 3, 5, 0, 4, 2, 2, 0, 5, 4, 6, 0,
    /* 0x70 - 0x7F */
    2, 5, 0, 0, 0, 4, 6, 0, 2, 4, 0, 0, 0, 4, 7, 0,
    /* 0x80 - 0x8F */
    0, 6, 0, 0, 3, 3, 3, 0, 2, 0, 2, 0, 4, 4, 4, 0,
    /* 0x90 - 0x9F */
    2, 6, 0, 0, 4, 4, 4, 0, 2, 5, 2, 0, 0, 5, 0, 0,
    /* 0xA0 - 0xAF */
    2, 6, 2, 0, 3, 3, 3, 0, 2, 2, 2, 0, 4, 4, 4, 0,
    /* 0xB0 - 0xBF */
    2, 5, 0, 0, 4, 4, 4, 0, 2, 4, 2, 0, 4, 4, 4, 0,
    /* 0xC0 - 0xCF */
    2, 6, 0, 0, 3, 3, 5, 0, 2, 2, 2, 0, 4, 4, 6, 0,
    /* 0xD0 - 0xDF */
    2, 5, 0, 0, 0, 4, 6, 0, 2, 4, 0, 0, 0, 4, 7, 0,
    /* 0xE0 - 0xEF */
    2, 6, 0, 0, 3, 3, 5, 0, 2, 2, 2, 2, 4, 4, 6, 0,
    /* 0xF0 - 0xFF */
    2, 5, 0, 0, 0, 4, 6, 0, 2, 4, 0, 0, 0, 4, 7, 0,
};

static const addressing_mode_t instruction_mode[256] = {
    /* 0x00 - 0x0F */
    IMP, INX, ___, ___, ___, ZP,  ZP,  ___, IMP, IMM, ACC, ___, ___, ABS, ABS, ___,
    /* 0x10 - 0x1F */
    REL, INY, ___, ___, ___, ZPX, ZPX, ___, IMP, ABY, ___, ___, ___, ABX, ABX, ___,
    /* 0x20 - 0x2F */
    ABS, INX, ___, ___, ZP,  ZP,  ZP,  ___, IMP, IMM, ACC, ___, ABS, ABS, ABS, ___,
    /* 0x30 - 0x3F */
    REL, INY, ___, ___, ___, ZPX, ZPX, ___, IMP, ABY, ___, ___, ___, ABX, ABX, ___,
    /* 0x40 - 0x4F */
    IMP, INX, ___, ___, ___, ZP,  ZP,  ___, IMP, IMM, ACC, ___, ABS, ABS, ABS, ___,
    /* 0x50 - 0x5F */
    REL, INY, ___, ___, ___, ZPX, ZPX, ___, IMP, ABY, ___, ___, ___, ABX, ABX, ___,
    /* 0x60 - 0x6F */
    IMP, INX, ___, ___, ___, ZP,  ZP,  ___, IMP, IMM, ACC, ___, IND, ABS, ABS, ___,
    /* 0x70 - 0x7F */
    REL, INY, ___, ___, ___, ZPX, ZPX, ___, IMP, ABY, ___, ___, ___, ABX, ABX, ___,
    /* 0x80 - 0x8F */
    ___, INX, ___, ___, ZP,  ZP,  ZP,  ___, IMP, ___, IMP, ___, ABS, ABS, ABS, ___,
    /* 0x90 - 0x9F */
    REL, INY, ___, ___, ZPX, ZPX, ZPY, ___, IMP, ABY, IMP, ___, ___, ABX, ___, ___,
    /* 0xA0 - 0xAF */
    IMM, INX, IMM, ___, ZP,  ZP,  ZP,  ___, IMP, IMM, IMP, ___, ABS, ABS, ABS, ___,
    /* 0xB0 - 0xBF */
    REL, INY, ___, ___, ZPX, ZPX, ZPY, ___, IMP, ABY, IMP, ___, ABX, ABX, ABY, ___,
    /* 0xC0 - 0xCF */
    IMM, INX, ___, ___, ZP,  ZP,  ZP,  ___, IMP, IMM, IMP, ___, ABS, ABS, ABS, ___,
    /* 0xD0 - 0xDF */
    REL, INY, ___, ___, ___, ZPX, ZPX, ___, IMP, ABY, ___, ___, ___, ABX, ABX, ___,
    /* 0xE0 - 0xEF */
    IMM, INX, ___, ___, ZP,  ZP,  ZP,  ___, IMM, IMM, IMP, ___, ABS, ABS, ABS, ___,
    /* 0xF0 - 0xFF */
    REL, INY, ___, ___, ___, ZPX, ZPX, ___, IMP, ABY, ___, ___, ___, ABX, ABX, ___,
};

class Z6502
{
private:
    /*Registers*/
    register_set_t _reg;
    
    /*Memory*/
    uint8_t* _memory_space;
public:
    /**
     * @brief Create Z6502 CPU
     * @param memory_space pointer to memory space
     * @param io_space pointer to io space
     */
    Z6502(uint8_t* memory_space);

    /**
     * @brief Reset CPU register
     */
    void reset(void);

    /**
     * @brief execute one instruction from memory at program counter
     * @returns number of clock cycles spent
     */
    int step(void);

    /**
     * @brief 
     */
    register_set_t* dump_register(register_set_t* register_set){
        return &_reg;
    }

    /**
     * @brief Z6502 destructor
     */
    ~Z6502();
};

#endif // Z6502_CORE_H_INCLUDED