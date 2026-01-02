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

//*****************************************************************************
// Private functions
//*****************************************************************************

/**
 * @brief Get operand based on addressing mode
 * @param mem Pointer to memory space
 * @param reg Pointer to register set
 * @param mode Addressing mode
 * @return Operand address or value
 */
uint16_t _get_operand(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint16_t lo = 0U;
    uint16_t hi = 0U;
    uint16_t operand = 0U;
    switch (mode)
    {
        case IMP:
            /*No operand*/
            return 0;
        case ACC:
            /*No operand*/
            return 0;
        case IMM:
            /*Return 8 bit value*/
            operand = mem[reg->program_counter];
            reg->program_counter++;
            return operand;
        case ZP:
            /*Return address in zero page (0x0000-0x00FF)*/
            operand = mem[reg->program_counter];
            reg->program_counter++;
            return operand;
        case ZPX:
            /*Return address in zero page (0x0000-0x00FF), indexed by X*/
            operand = (mem[reg->program_counter] + reg->x) % 256;
            reg->program_counter++;
            return operand;
        case ZPY:
            /*Return address in zero page (0x0000-0x00FF), indexed by Y*/
            operand = (mem[reg->program_counter] + reg->y) % 256;
            reg->program_counter++;
            return operand;
        case REL:
            /*Return branch offset value*/
            operand = mem[reg->program_counter];
            reg->program_counter++;
            return operand;
        case ABS:
            /*Return absolute address*/
            lo = mem[reg->program_counter];
            hi = mem[reg->program_counter + 1];
            operand = (hi << 8) | lo;
            reg->program_counter += 2;
            return operand;
        case ABX:
            /*Return absolute address, indexed by X*/
            lo = mem[reg->program_counter];
            hi = mem[reg->program_counter + 1];
            operand = (((hi << 8) | lo) + reg->x) % 65536;
            reg->program_counter += 2;
            return operand;
        case ABY:
            /*Return absolute address, indexed by Y*/
            lo = mem[reg->program_counter];
            hi = mem[reg->program_counter + 1];
            operand = (((hi << 8) | lo) + reg->y) % 65536;
            reg->program_counter += 2;
            return operand;
        case IND:
            /*Return indirect address*/
            lo = mem[reg->program_counter];
            hi = mem[reg->program_counter + 1];
            operand = (hi << 8) | lo;
            reg->program_counter += 2;
            return mem[operand] | (mem[(operand + 1) % 65536] << 8);
        case INX:
            /*Return X-indexed indirect address*/
            operand = (mem[reg->program_counter] + reg->x) % 256;
            lo = mem[operand];
            hi = mem[(operand + 1) % 256];
            operand = (hi << 8) | lo;
            reg->program_counter++;
            return operand;
        case INY:
            /*Return Indirect Y-indexed address*/
            operand = mem[reg->program_counter];
            lo = mem[operand];
            hi = mem[(operand + 1) % 256];
            operand = ((hi << 8) | lo) + reg->y;
            reg->program_counter++;
            return operand;
        default:
            return 0;
    }
}

/**
 * @brief Update zero flag
 * @param reg Pointer to register set
 * @param value Value to check
 */
void _update_zero_flag(register_set_t* reg, uint8_t value){
    if(value == 0U){
        reg->processor_status.zero = 1U;
    }
    else{
        reg->processor_status.zero = 0U;
    }
}

/**
 * @brief Update negative flag
 * @param reg Pointer to register set
 * @param value Value to check
 */
void _update_negative_flag(register_set_t* reg, uint8_t value){
    reg->processor_status.negative = (value >> 7) & 0x01;
}

/**
 * @brief Update carry flag
 * @param reg Pointer to register set
 * @param value Value to check (uint16_t)
 */
void _update_carry_flag(register_set_t* reg, uint16_t value){
    if(value > 0xFF){
        reg->processor_status.carry = 1U;
    }
    else{
        reg->processor_status.carry = 0U;
    }
}

/**
 * @brief Update overflow flag
 * @param reg Pointer to register set
 * @param a First operand
 * @param b Second operand
 * @param result Result of the operation
 */
void _update_overflow_flag(register_set_t* reg, uint8_t a, uint8_t b, uint8_t result){
    if(((a ^ result) & (b ^ result) & 0x80) != 0U){
        reg->processor_status.overflow = 1U;
    }
    else{
        reg->processor_status.overflow = 0U;
    }
}

/**
 * @brief Pull a byte from the stack
 * @param mem Pointer to memory space
 * @param reg Pointer to register set
 * @param value Pointer to store the pulled value
 */
void _pull_stack(uint8_t* mem, register_set_t* reg, uint8_t* value){
    reg->stack_pointer = (reg->stack_pointer + 1U) % 256;
    *value = mem[0x0100 + reg->stack_pointer];
}

/**
 * @brief Push a byte onto the stack
 * @param mem Pointer to memory space
 * @param reg Pointer to register set
 * @param value Value to push onto the stack
 */
void _push_stack(uint8_t* mem, register_set_t* reg, uint8_t value){
    mem[0x0100 + reg->stack_pointer] = value;
    reg->stack_pointer = (reg->stack_pointer - 1U) % 256;
}

/**
 * @brief Pull processor status from the stack
 * @param mem Pointer to memory space
 * @param reg Pointer to register set
 */
void _pull_register_stack(uint8_t* mem, register_set_t* reg){
    uint8_t tmp;
    reg->stack_pointer = (reg->stack_pointer + 1U) % 256;
    tmp = mem[0x0100 + reg->stack_pointer];
    reg->processor_status.negative = (tmp >> 7) & 0x01;
    reg->processor_status.overflow = (tmp >> 6) & 0x01;
    reg->processor_status.decimal_mode = (tmp >> 3) & 0x01;
    reg->processor_status.irq_disable = (tmp >> 2) & 0x01;
    reg->processor_status.zero = (tmp >> 1) & 0x01;
    reg->processor_status.carry = tmp & 0x01;
}

/**
 * @brief Push processor status onto the stack
 * @param mem Pointer to memory space
 * @param reg Pointer to register set
 */
void _push_register_stack(uint8_t* mem, register_set_t* reg){
    mem[0x0100 + reg->stack_pointer] = (uint8_t)(reg->processor_status.negative << 7 |
                                                 reg->processor_status.overflow << 6 |
                                                 1 << 5 |
                                                 1 << 4 |
                                                 reg->processor_status.decimal_mode << 3 |
                                                 reg->processor_status.irq_disable << 2 |
                                                 reg->processor_status.zero << 1 |
                                                 reg->processor_status.carry);
    reg->stack_pointer = (reg->stack_pointer - 1U) % 256;
}

//*****************************************************************************
// Instruction implementations
//*****************************************************************************

void _op_ADC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint8_t tmp;
    uint16_t res;
    if(mode == IMM){
        tmp = _get_operand(mem, reg, mode);
    }
    else{
        tmp = mem[_get_operand(mem, reg, mode)];
    }
    res += tmp + reg->processor_status.carry;
    _update_overflow_flag(reg, reg->accumulator, tmp, res);
    _update_carry_flag(reg, res);
    reg->accumulator = (uint8_t)(res % 256);
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void _op_AND(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    if (mode == IMM) {
        reg->accumulator &= (uint8_t)_get_operand(mem, reg, mode);
    }
    else{
        reg->accumulator &= mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void _op_ASL(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint16_t addr;
    if (mode == ACC) {
        reg->processor_status.carry = (reg->accumulator >> 7) & 0x01;
        reg->accumulator = (reg->accumulator << 1);
        _update_zero_flag(reg, reg->accumulator);
        _update_negative_flag(reg, reg->accumulator);
    }
    else{
        addr = _get_operand(mem, reg, mode);
        reg->processor_status.carry = (mem[addr] >> 7) & 0x01;
        mem[addr] = (mem[addr] << 1);
        _update_zero_flag(reg, mem[addr]);
        _update_negative_flag(reg, mem[addr]);
    }
}
void _op_BCC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.carry == 0U){
        reg->program_counter = (reg->program_counter + 2 + addr) % 65536;
    }
}
void _op_BCS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.carry == 1U){
        reg->program_counter = (reg->program_counter + 2 + addr) % 65536;
    }
}
void _op_BEQ(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.zero == 1U){
        reg->program_counter = (reg->program_counter + 2 + addr) % 65536;
    }
}
void _op_BIT(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint8_t tmp = mem[_get_operand(mem, reg, mode)];
    _update_zero_flag(reg, reg->accumulator & tmp);
    _update_negative_flag(reg, tmp);
    reg->processor_status.overflow = (tmp >> 6) & 0x01;
}
void _op_BMI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.negative == 1U){
        reg->program_counter = (reg->program_counter + 2 + addr) % 65536;
    }
}
void _op_BNE(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.zero == 0U){
        reg->program_counter = (reg->program_counter + 2 + addr) % 65536;
    }
}
void _op_BPL(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.negative == 0U){
        reg->program_counter = (reg->program_counter + 2 + addr) % 65536;
    }
}
void _op_BRK(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint16_t addr = (reg->program_counter + 2U) % 65536;
    _push_stack(mem, reg, (uint8_t)((addr >> 8) & 0x00FF));
    _push_stack(mem, reg, (uint8_t)(addr & 0x00FF));
    _push_register_stack(mem, reg);
    reg->program_counter = Z6502_IRQ_VECTOR_ADDRESS;
    reg->processor_status.irq_disable = 1U;
}
void _op_BVC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.overflow == 0U){
        reg->program_counter = (reg->program_counter + 2 + addr) % 65536;
    }
}
void _op_BVS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.overflow == 1U){
        reg->program_counter = (reg->program_counter + 2 + addr) % 65536;
    }
}
void _op_CLC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->processor_status.carry = 0U;
}
void _op_CLD(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->processor_status.decimal_mode = 0U;
}
void _op_CLI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->processor_status.irq_disable = 0U;
}
void _op_CLV(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->processor_status.overflow = 0U;
}
void _op_CMP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    int8_t tmp;
    if (mode == IMM){
        tmp = _get_operand(mem, reg, mode);
    }
    else{
        tmp = mem[_get_operand(mem, reg, mode)];
    }
    tmp = reg->accumulator - tmp;
    reg->processor_status.carry = (tmp >= 0)?1U:0U;
    reg->processor_status.zero = (tmp == 0)?1U:0U;
    reg->processor_status.negative = (tmp >> 7) & 0x01;
}
void _op_CPX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    int8_t tmp;
    if (mode == IMM){
        tmp = _get_operand(mem, reg, mode);
    }
    else{
        tmp = mem[_get_operand(mem, reg, mode)];
    }
    tmp = reg->x - tmp;
    reg->processor_status.carry = (tmp >= 0)?1U:0U;
    reg->processor_status.zero = (tmp == 0)?1U:0U;
    reg->processor_status.negative = (tmp >> 7) & 0x01;
}
void _op_CPY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    int8_t tmp;
    if (mode == IMM){
        tmp = _get_operand(mem, reg, mode);
    }
    else{
        tmp = mem[_get_operand(mem, reg, mode)];
    }
    tmp = reg->y - tmp;
    reg->processor_status.carry = (tmp >= 0)?1U:0U;
    reg->processor_status.zero = (tmp == 0)?1U:0U;
    reg->processor_status.negative = (tmp >> 7) & 0x01;
}
void _op_DEC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint16_t addr = _get_operand(mem, reg, mode);
    mem[addr] = (mem[addr] - 1U) % 256;
    _update_zero_flag(reg, mem[addr]);
    _update_negative_flag(reg, mem[addr]);
}
void _op_DEX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->x = (reg->x - 1U) % 256;
    _update_zero_flag(reg, reg->x);
    _update_negative_flag(reg, reg->x);
}
void _op_DEY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->y = (reg->y - 1U) % 256;
    _update_zero_flag(reg, reg->y);
    _update_negative_flag(reg, reg->y);
}
void _op_EOR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    if (mode == IMM) {
        reg->accumulator ^= (uint8_t)_get_operand(mem, reg, mode);
    }
    else{
        reg->accumulator ^= mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void _op_INC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint16_t addr = _get_operand(mem, reg, mode);
    mem[addr] = (mem[addr] + 1U) % 256;
    _update_zero_flag(reg, mem[addr]);
    _update_negative_flag(reg, mem[addr]);
}
void _op_INX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->x = (reg->x + 1U) % 256;
    _update_zero_flag(reg, reg->x);
    _update_negative_flag(reg, reg->x);
}
void _op_INY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->y = (reg->y + 1U) % 256;
    _update_zero_flag(reg, reg->y);
    _update_negative_flag(reg, reg->y);
}
void _op_JMP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->program_counter = _get_operand(mem, reg, mode);
}
void _op_JSR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint16_t tmp = (reg->program_counter + 2U) % 65536;
    _push_stack(mem, reg, (uint8_t)((tmp >> 8) & 0x00FF));
    _push_stack(mem, reg, (uint8_t)(tmp & 0x00FF));
    reg->program_counter = _get_operand(mem, reg, mode);
}
void _op_LDA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    if (mode == IMM) {
        reg->accumulator = _get_operand(mem, reg, mode);
    }
    else{
        reg->accumulator = mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void _op_LDX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    if (mode == IMM) {
        reg->x = _get_operand(mem, reg, mode);
    }
    else{
        reg->x = mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->x);
    _update_negative_flag(reg, reg->x);
}
void _op_LDY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    if (mode == IMM) {
        reg->y = _get_operand(mem, reg, mode);
    }
    else{
        reg->y = mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->y);
    _update_negative_flag(reg, reg->y);
}
void _op_LSR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint16_t addr;
    if (mode == ACC) {
        reg->processor_status.carry = reg->accumulator & 0x01;
        reg->accumulator = (reg->accumulator >> 1);
        _update_zero_flag(reg, reg->accumulator);
        _update_negative_flag(reg, reg->accumulator);
    }
    else{
        addr = _get_operand(mem, reg, mode);
        reg->processor_status.carry = mem[addr] & 0x01;
        mem[addr] = (mem[addr] >> 1);
        _update_zero_flag(reg, mem[addr]);
        _update_negative_flag(reg, mem[addr]);
    }
}
void _op_NOP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    return;
}
void _op_ORA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    if (mode == IMM) {
        reg->accumulator |= (uint8_t)_get_operand(mem, reg, mode);
    }
    else{
        reg->accumulator |= mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void _op_PHA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    _push_stack(mem, reg, reg->accumulator);
}
void _op_PHP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    _push_register_stack(mem, reg);
}
void _op_PLA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    _pull_stack(mem,reg, &reg->accumulator);
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void _op_PLP(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    _pull_register_stack(mem, reg);
}
void _op_ROL(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint8_t c;
    uint16_t addr;
    if (mode == ACC) {
        c = (reg->accumulator >> 7) & 0x01;
        reg->accumulator = (reg->accumulator << 1) | (reg->processor_status.carry);
        reg->processor_status.carry = c;
        _update_zero_flag(reg, reg->accumulator);
        _update_negative_flag(reg, reg->accumulator);
    }
    else{
        addr = _get_operand(mem, reg, mode);
        c = (mem[addr] >> 7) & 0x01;
        mem[addr] = (mem[addr] << 1) | (reg->processor_status.carry);
        reg->processor_status.carry = c;
        _update_zero_flag(reg, mem[addr]);
        _update_negative_flag(reg, mem[addr]);
    }
}
void _op_ROR(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint8_t c;
    uint16_t addr;
    if (mode == ACC) {
        c = reg->accumulator & 0x01;
        reg->accumulator = (reg->accumulator >> 1) | (reg->processor_status.carry << 7);
        reg->processor_status.carry = c;
        _update_zero_flag(reg, reg->accumulator);
        _update_negative_flag(reg, reg->accumulator);
    }
    else{
        addr = _get_operand(mem, reg, mode);
        c = mem[addr] & 0x01;
        mem[addr] = (mem[addr] >> 1) | (reg->processor_status.carry << 7);
        reg->processor_status.carry = c;
        _update_zero_flag(reg, mem[addr]);
        _update_negative_flag(reg, mem[addr]);
    }
    
}
void _op_RTI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    _pull_register_stack(mem, reg);
    _pull_stack(mem, reg, (uint8_t*)&reg->program_counter);
    _pull_stack(mem, reg, (uint8_t*)&reg->program_counter + 1);
}
void _op_RTS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    _pull_stack(mem, reg, (uint8_t*)&reg->program_counter);
    _pull_stack(mem, reg, (uint8_t*)&reg->program_counter + 1);
    reg->program_counter++;
}
void _op_SBC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    uint8_t tmp;
    uint16_t res;
    if(mode == IMM){
        tmp = _get_operand(mem, reg, mode);
    }
    else{
        tmp = mem[_get_operand(mem, reg, mode)];
    }
    res = reg->accumulator - tmp - (1U - reg->processor_status.carry);
    _update_overflow_flag(reg, reg->accumulator, ~tmp, res);
    _update_carry_flag(reg, res);
    reg->accumulator = (uint8_t)(res % 256);
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void _op_SEC(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->processor_status.carry = 1U;
}
void _op_SED(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->processor_status.decimal_mode = 1U;
}
void _op_SEI(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->processor_status.irq_disable = 1U;
}
void _op_STA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    mem[_get_operand(mem, reg, mode)] = reg->accumulator;
}
void _op_STX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    mem[_get_operand(mem, reg, mode)] = reg->x;
}
void _op_STY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    mem[_get_operand(mem, reg, mode)] = reg->y;
}
void _op_TAX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->x = reg->accumulator;
    _update_zero_flag(reg, reg->x);
    _update_negative_flag(reg, reg->x);
}
void _op_TAY(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->y = reg->accumulator;
    _update_zero_flag(reg, reg->y);
    _update_negative_flag(reg, reg->y);
}
void _op_TSX(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->x = reg->stack_pointer;
    _update_zero_flag(reg, reg->x);
    _update_negative_flag(reg, reg->x);
}
void _op_TXA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->accumulator = reg->x;
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void _op_TXS(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->stack_pointer = reg->x;
}
void _op_TYA(uint8_t* mem, register_set_t* reg, addressing_mode_t mode){
    reg->accumulator = reg->y;
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}


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