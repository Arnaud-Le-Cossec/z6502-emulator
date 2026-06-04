; @test{ "name": "Bitwise instruction test" }               
;   _____ ___ ___ ___ ___ 
;  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - Bitwise test
;  |   __| . |_  | | |  _|     Copyright (C) 2026 - Arnaud LE COSSEC
;  |_____|___|___|___|___|     version 1.0.0
;                     
;  This program is free software; you can redistribute it and/or modify
;  it under the terms of the MIT License.
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  MIT License for more details.    
;

; Instruction tested: AND, ORA, EOR, BIT

; COMPILER PARAMETERS *********************************** Built with ACME v0.91
; CPU target
!cpu 6502
; ********************************************************* COMPILER PARAMETERS

*= 0x0000
test:
    NOP                         ;@expected{ "PC":"0x0000", "NEXT":"0x0001", "A":"0x00", "X":"0x00", "SP":"0xFF", "NV-BDIZC":"0b00100000" }
    jmp and_test                ;@expected{ "PC":"0x0001", "NEXT":"0x0100" }

; Note : we will use the actual address instead of the label 
; to force the compiler to use the correct addressing mode 
; for each instruction.
*= 0x0080
zeropage_data:
    !byte 0x55, 0xCC, 0x00

*= 0x00F0
indexed_table:
    !word zeropage_data, zeropage_data+1, zeropage_data+2

*= 0x0100
and_test:
    ; immediate mode
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND #%01010101              ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMM" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND #%11001100              ;@expected{ "A":"0x88", "NV-BDIZC":"0b10100000", "addressing_mode":"IMM" }

    ; zero page mode
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND $80                     ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZP" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND $80+1                   ;@expected{ "A":"0x88", "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }

    ; zero page,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND $80,X                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZPX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND $80,X                   ;@expected{ "A":"0x88", "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }

    ; absolute mode
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND $0080                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABS" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND $0080+1                 ;@expected{ "A":"0x88", "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }

    ; absolute,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND $0080,X                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND $0080,X                 ;@expected{ "A":"0x88", "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }

    ; absolute,Y mode
    LDY #$00                    ;@expected{ "Y":"0x00" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND $0080,Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABY" }
    LDY #$01                    ;@expected{ "Y":"0x01" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND $0080,Y                 ;@expected{ "A":"0x88", "NV-BDIZC":"0b10100000", "addressing_mode":"ABY" }

    ; indirect,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND ($F0,X)                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"INX" }
    LDX #$02                    ;@expected{ "X":"0x02" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND ($F0,X)                 ;@expected{ "A":"0x88", "NV-BDIZC":"0b10100000", "addressing_mode":"INX" }

    ; indirect,Y mode
    LDY #$00                    ;@expected{ "Y":"0x00" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND ($F0),Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"INY" }
    LDY #$01                    ;@expected{ "Y":"0x01" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    AND ($F0),Y                 ;@expected{ "A":"0x88", "NV-BDIZC":"0b10100000", "addressing_mode":"INY" }

or_test:
    ; immediate mode
    LDA #$00                    ;@expected{ "A":"0x00" }
    ORA #$00                    ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMM" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    ORA #%11001100              ;@expected{ "A":"0xEE", "NV-BDIZC":"0b10100000", "addressing_mode":"IMM" }

    ; zero page mode
    LDA #$00                    ;@expected{ "A":"0x00" }
    ORA $80+2                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZP" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    ORA $80+1                   ;@expected{ "A":"0xEE", "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }

    ; zero page,X mode
    LDX #$02                    ;@expected{ "X":"0x02" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    ORA $80,X                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZPX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    ORA $80,X                   ;@expected{ "A":"0xEE", "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }

    ; absolute mode
    LDA #$00                    ;@expected{ "A":"0x00" }
    ORA $0080+2                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABS" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    ORA $0080+1                 ;@expected{ "A":"0xEE", "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }

    ; absolute,X mode
    LDX #$02                    ;@expected{ "X":"0x02" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    ORA $0080,X                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    ORA $0080,X                 ;@expected{ "A":"0xEE", "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }

    ; absolute,Y mode
    LDY #$02                    ;@expected{ "Y":"0x02" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    ORA $0080,Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABY" }
    LDY #$01                    ;@expected{ "Y":"0x01" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    ORA $0080,Y                 ;@expected{ "A":"0xEE", "NV-BDIZC":"0b10100000", "addressing_mode":"ABY" }

    ; indirect,X mode
    LDX #$04                    ;@expected{ "X":"0x04" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    ORA ($F0,X)                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"INX" }
    LDX #$02                    ;@expected{ "X":"0x02" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    ORA ($F0,X)                 ;@expected{ "A":"0xEE", "NV-BDIZC":"0b10100000", "addressing_mode":"INX" }

    ; indirect,Y mode
    LDY #$02                    ;@expected{ "Y":"0x02" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    ORA ($F0),Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"INY" }
    LDY #$01                    ;@expected{ "Y":"0x01" }
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    ORA ($F0),Y                 ;@expected{ "A":"0xEE", "NV-BDIZC":"0b10100000", "addressing_mode":"INY" }

eor_test:
    ; immediate mode
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR #%01010101              ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMM" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR #%11001100              ;@expected{ "A":"0x99", "NV-BDIZC":"0b10100000", "addressing_mode":"IMM" }

    ; zero page mode
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR $80                     ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZP" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR $80+1                   ;@expected{ "A":"0x99", "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }

    ; zero page,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR $80,X                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZPX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR $80,X                   ;@expected{ "A":"0x99", "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }

    ; absolute mode
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR $0080                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABS" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR $0080+1                 ;@expected{ "A":"0x99", "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }

    ; absolute,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR $0080,X                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR $0080,X                 ;@expected{ "A":"0x99", "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }

    ; absolute,Y mode
    LDY #$00                    ;@expected{ "Y":"0x00" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR $0080,Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABY" }
    LDY #$01                    ;@expected{ "Y":"0x01"  }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR $0080,Y                 ;@expected{ "A":"0x99", "NV-BDIZC":"0b10100000", "addressing_mode":"ABY" }

    ; indirect,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR ($F0,X)                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"INX" }
    LDX #$02                    ;@expected{ "X":"0x02" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR ($F0,X)                 ;@expected{ "A":"0x99", "NV-BDIZC":"0b10100000", "addressing_mode":"INX" }

    ; indirect,Y mode
    LDY #$00                    ;@expected{ "Y":"0x00" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR ($F0),Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"INY" }
    LDY #$01                    ;@expected{ "Y":"0x01" }
    LDA #%01010101              ;@expected{ "A":"0x55" }
    EOR ($F0),Y                 ;@expected{ "A":"0x99", "NV-BDIZC":"0b10100000", "addressing_mode":"INY" }

bit_test:
    ; zero page mode
    LDA #%10101010              ;@expected{ "A":"0xAA" }
    BIT $80                     ;@expected{ "A":"0xAA", "NV-BDIZC":"0b01100010", "addressing_mode":"ZP" }
    BIT $80+1                   ;@expected{ "A":"0xAA", "NV-BDIZC":"0b11100000", "addressing_mode":"ZP" }

    ; absolute mode
    BIT $0080                   ;@expected{ "A":"0xAA", "NV-BDIZC":"0b01100010", "addressing_mode":"ABS" }
    BIT $0080+1                 ;@expected{ "A":"0xAA", "NV-BDIZC":"0b11100000", "addressing_mode":"ABS" }

    BRK                         ;@halt