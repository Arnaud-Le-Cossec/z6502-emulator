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
uint16_t _get_operand(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
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
void _update_zero_flag(z6502_register_set_t* reg, uint8_t value){
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
void _update_negative_flag(z6502_register_set_t* reg, uint8_t value){
    reg->processor_status.negative = (value >> 7) & 0x01;
}

/**
 * @brief Update carry flag
 * @param reg Pointer to register set
 * @param value Value to check (uint16_t)
 */
void _update_carry_flag(z6502_register_set_t* reg, uint16_t value){
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
void _update_overflow_flag(z6502_register_set_t* reg, uint8_t a, uint8_t b, uint8_t result){
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
void _pull_stack(uint8_t* mem, z6502_register_set_t* reg, uint8_t* value){
    reg->stack_pointer = (reg->stack_pointer + 1U) % 256;
    *value = mem[0x0100 + reg->stack_pointer];
}

/**
 * @brief Push a byte onto the stack
 * @param mem Pointer to memory space
 * @param reg Pointer to register set
 * @param value Value to push onto the stack
 */
void _push_stack(uint8_t* mem, z6502_register_set_t* reg, uint8_t value){
    mem[0x0100 + reg->stack_pointer] = value;
    reg->stack_pointer = (reg->stack_pointer - 1U) % 256;
}

/**
 * @brief Pull processor status from the stack
 * @param mem Pointer to memory space
 * @param reg Pointer to register set
 */
void _pull_register_stack(uint8_t* mem, z6502_register_set_t* reg){
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
void _push_register_stack(uint8_t* mem, z6502_register_set_t* reg){
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

void z6502_op_ADC(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    uint8_t tmp;
    uint16_t res;
    uint8_t local_carry;
    if(mode == IMM){
        tmp = _get_operand(mem, reg, mode);
    }
    else{
        tmp = mem[_get_operand(mem, reg, mode)];
    }

    if(reg->processor_status.decimal_mode){
        /*Decimal mode*/
        res = (reg->accumulator & 0x0F) + (tmp & 0x0F) + reg->processor_status.carry;
        if (res>= 0x0A) res = ((res+0x06) & 0x0F) + 0x10;
        res = (reg->accumulator & 0xF0) + (tmp & 0xF0) + res;
        if (res >= 0xA0) res = res + 0x60;
    }
    else{
        /*Binary mode*/
        res = reg->accumulator + tmp + reg->processor_status.carry;
    }

    _update_overflow_flag(reg, reg->accumulator, tmp, res);
    _update_carry_flag(reg, res);
    reg->accumulator = (uint8_t)(res % 256);
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void z6502_op_AND(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    if (mode == IMM) {
        reg->accumulator &= (uint8_t)_get_operand(mem, reg, mode);
    }
    else{
        reg->accumulator &= mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void z6502_op_ASL(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
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
void z6502_op_BCC(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.carry == 0U){
        reg->program_counter = (reg->program_counter + addr) % 65536;
    }
}
void z6502_op_BCS(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.carry == 1U){
        reg->program_counter = (reg->program_counter + addr) % 65536;
    }
}
void z6502_op_BEQ(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.zero == 1U){
        reg->program_counter = (reg->program_counter + addr) % 65536;
    }
}
void z6502_op_BIT(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    uint8_t tmp = mem[_get_operand(mem, reg, mode)];
    _update_zero_flag(reg, reg->accumulator & tmp);
    _update_negative_flag(reg, tmp);
    reg->processor_status.overflow = (tmp >> 6) & 0x01;
}
void z6502_op_BMI(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.negative == 1U){
        reg->program_counter = (reg->program_counter + addr) % 65536;
    }
}
void z6502_op_BNE(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.zero == 0U){
        reg->program_counter = (reg->program_counter + addr) % 65536;
    }
}
void z6502_op_BPL(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.negative == 0U){
        reg->program_counter = (reg->program_counter + addr) % 65536;
    }
}
void z6502_op_BRK(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    uint16_t addr = (reg->program_counter + 2U) % 65536;
    _push_stack(mem, reg, (uint8_t)((addr >> 8) & 0x00FF));
    _push_stack(mem, reg, (uint8_t)(addr & 0x00FF));
    _push_register_stack(mem, reg);
    reg->program_counter = Z6502_IRQ_VECTOR_ADDRESS;
    reg->processor_status.irq_disable = 1U;
    reg->processor_status.break_flg = 1U;
}
void z6502_op_BVC(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.overflow == 0U){
        reg->program_counter = (reg->program_counter + addr) % 65536;
    }
}
void z6502_op_BVS(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    int8_t addr = _get_operand(mem, reg, mode);
    if (reg->processor_status.overflow == 1U){
        reg->program_counter = (reg->program_counter + addr) % 65536;
    }
}
void z6502_op_CLC(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->processor_status.carry = 0U;
}
void z6502_op_CLD(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->processor_status.decimal_mode = 0U;
}
void z6502_op_CLI(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->processor_status.irq_disable = 0U;
}
void z6502_op_CLV(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->processor_status.overflow = 0U;
}
void z6502_op_CMP(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
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
void z6502_op_CPX(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
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
void z6502_op_CPY(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
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
void z6502_op_DEC(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    uint16_t addr = _get_operand(mem, reg, mode);
    mem[addr] = (mem[addr] - 1U) % 256;
    _update_zero_flag(reg, mem[addr]);
    _update_negative_flag(reg, mem[addr]);
}
void z6502_op_DEX(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->x = (reg->x - 1U) % 256;
    _update_zero_flag(reg, reg->x);
    _update_negative_flag(reg, reg->x);
}
void z6502_op_DEY(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->y = (reg->y - 1U) % 256;
    _update_zero_flag(reg, reg->y);
    _update_negative_flag(reg, reg->y);
}
void z6502_op_EOR(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    if (mode == IMM) {
        reg->accumulator ^= (uint8_t)_get_operand(mem, reg, mode);
    }
    else{
        reg->accumulator ^= mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void z6502_op_INC(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    uint16_t addr = _get_operand(mem, reg, mode);
    mem[addr] = (mem[addr] + 1U) % 256;
    _update_zero_flag(reg, mem[addr]);
    _update_negative_flag(reg, mem[addr]);
}
void z6502_op_INX(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->x = (reg->x + 1U) % 256;
    _update_zero_flag(reg, reg->x);
    _update_negative_flag(reg, reg->x);
}
void z6502_op_INY(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->y = (reg->y + 1U) % 256;
    _update_zero_flag(reg, reg->y);
    _update_negative_flag(reg, reg->y);
}
void z6502_op_JMP(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->program_counter = _get_operand(mem, reg, mode);
}
void z6502_op_JSR(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    uint16_t tmp = (reg->program_counter + 1U) % 65536;
    _push_stack(mem, reg, (uint8_t)((tmp >> 8) & 0x00FF));
    _push_stack(mem, reg, (uint8_t)(tmp & 0x00FF));
    reg->program_counter = _get_operand(mem, reg, mode);
}
void z6502_op_LDA(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    if (mode == IMM) {
        reg->accumulator = _get_operand(mem, reg, mode);
    }
    else{
        reg->accumulator = mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void z6502_op_LDX(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    if (mode == IMM) {
        reg->x = _get_operand(mem, reg, mode);
    }
    else{
        reg->x = mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->x);
    _update_negative_flag(reg, reg->x);
}
void z6502_op_LDY(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    if (mode == IMM) {
        reg->y = _get_operand(mem, reg, mode);
    }
    else{
        reg->y = mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->y);
    _update_negative_flag(reg, reg->y);
}
void z6502_op_LSR(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
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
void z6502_op_NOP(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    return;
}
void z6502_op_ORA(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    if (mode == IMM) {
        reg->accumulator |= (uint8_t)_get_operand(mem, reg, mode);
    }
    else{
        reg->accumulator |= mem[_get_operand(mem, reg, mode)];
    }
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void z6502_op_PHA(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    _push_stack(mem, reg, reg->accumulator);
}
void z6502_op_PHP(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    _push_register_stack(mem, reg);
}
void z6502_op_PLA(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    _pull_stack(mem,reg, &reg->accumulator);
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void z6502_op_PLP(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    _pull_register_stack(mem, reg);
}
void z6502_op_ROL(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
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
void z6502_op_ROR(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
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
void z6502_op_RTI(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    _pull_register_stack(mem, reg);
    _pull_stack(mem, reg, (uint8_t*)&reg->program_counter);
    _pull_stack(mem, reg, (uint8_t*)&reg->program_counter + 1);
}
void z6502_op_RTS(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    _pull_stack(mem, reg, (uint8_t*)&reg->program_counter);
    _pull_stack(mem, reg, (uint8_t*)&reg->program_counter + 1);
    reg->program_counter++;
}
void z6502_op_SBC(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    uint8_t tmp;
    int16_t res;
    if(mode == IMM){
        tmp = _get_operand(mem, reg, mode);
    }
    else{
        tmp = mem[_get_operand(mem, reg, mode)];
    }

    if(reg->processor_status.decimal_mode){
        /*Decimal mode*/
        res = (reg->accumulator & 0x0F) - (tmp & 0x0F) - (1U - reg->processor_status.carry);
        if (res < 0x0) res = ((res-0x06) & 0x0F) - 0x10;
        res = (reg->accumulator & 0xF0) - (tmp & 0xF0) + res;
        if (res < 0x0) res = res - 0x60;
    }
    else{
        /*Binary mode*/
        res = reg->accumulator - tmp - (1U - reg->processor_status.carry);
    }

    _update_overflow_flag(reg, reg->accumulator, ~tmp, res);
    _update_carry_flag(reg, res);
    reg->accumulator = (uint8_t)(res % 256);
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void z6502_op_SEC(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->processor_status.carry = 1U;
}
void z6502_op_SED(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->processor_status.decimal_mode = 1U;
}
void z6502_op_SEI(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->processor_status.irq_disable = 1U;
}
void z6502_op_STA(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    mem[_get_operand(mem, reg, mode)] = reg->accumulator;
}
void z6502_op_STX(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    mem[_get_operand(mem, reg, mode)] = reg->x;
}
void z6502_op_STY(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    mem[_get_operand(mem, reg, mode)] = reg->y;
}
void z6502_op_TAX(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->x = reg->accumulator;
    _update_zero_flag(reg, reg->x);
    _update_negative_flag(reg, reg->x);
}
void z6502_op_TAY(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->y = reg->accumulator;
    _update_zero_flag(reg, reg->y);
    _update_negative_flag(reg, reg->y);
}
void z6502_op_TSX(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->x = reg->stack_pointer;
    _update_zero_flag(reg, reg->x);
    _update_negative_flag(reg, reg->x);
}
void z6502_op_TXA(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->accumulator = reg->x;
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}
void z6502_op_TXS(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->stack_pointer = reg->x;
}
void z6502_op_TYA(uint8_t* mem, z6502_register_set_t* reg, z6502_addressing_mode_t mode){
    reg->accumulator = reg->y;
    _update_zero_flag(reg, reg->accumulator);
    _update_negative_flag(reg, reg->accumulator);
}


void z6502_init(z6502_cpu_t* cpu_s, uint8_t* memory_ptr){
    cpu_s->memory_ptr = memory_ptr;
}

void z6502_reset(z6502_cpu_t* cpu_s) {
    /*Init special purpose registers*/
    cpu_s->reg.program_counter = (uint16_t)(cpu_s->memory_ptr[Z6502_RESET_VECTOR_ADDRESS+1U]<<8) | (uint16_t)(cpu_s->memory_ptr[Z6502_RESET_VECTOR_ADDRESS]);
    cpu_s->reg.stack_pointer = 0xFFU;
    cpu_s->reg.accumulator = 0U;
    cpu_s->reg.x = 0U;
    cpu_s->reg.y = 0U;

    cpu_s->reg.processor_status.carry = 0U;
    cpu_s->reg.processor_status.zero = 0U;
    cpu_s->reg.processor_status.irq_disable = 0U;
    cpu_s->reg.processor_status.decimal_mode = 0U;
    cpu_s->reg.processor_status.break_flg = 0U;
    cpu_s->reg.processor_status.overflow = 0U;
    cpu_s->reg.processor_status.negative = 0U;

    cpu_s->current_opcode = 0U;
}

int z6502_step(z6502_cpu_t* cpu_s) {
    /*Read instruction*/
    cpu_s->current_instr_addr = cpu_s->reg.program_counter;
    cpu_s->current_opcode = cpu_s->memory_ptr[cpu_s->reg.program_counter];
    cpu_s->reg.program_counter++;

    /*Execute instruction*/
    if(z6502_instruction_set[cpu_s->current_opcode] != NULL){
        z6502_instruction_set[cpu_s->current_opcode](cpu_s->memory_ptr, &cpu_s->reg, z6502_instruction_mode[cpu_s->current_opcode]);
    }
    else{
        //Unhandled opcode
        return 1;
    }

    return 0;
}

//z6502_register_set_t* Z6502::dump_register(void){
//    return &_reg;
//}
//
const char* z6502_get_instruction_mnemonic(z6502_cpu_t* cpu_s) {
    return z6502_instruction_mnemonic[cpu_s->current_opcode];
}

const char* z6502_get_addressing_mode_str(z6502_cpu_t* cpu_s) {
    return z6502_addressing_mode_str[z6502_instruction_mode[cpu_s->current_opcode]];
}
//
//uint8_t Z6502::get_instruction_opcode(void) {
//    return _opcode;
//}
//
//uint16_t Z6502::get_instruction_address(void) {
//    return _instr_addr;
//}
//
//Z6502::~Z6502()
//{
//}