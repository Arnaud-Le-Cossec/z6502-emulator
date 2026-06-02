; @test{ "name": "Compare instruction test" }               
;   _____ ___ ___ ___ ___ 
;  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - Compare test
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

; Instruction tested: CMP, CPX, CPY

; COMPILER PARAMETERS *********************************** Built with ACME v0.91
; CPU target
!cpu 6502
; ********************************************************* COMPILER PARAMETERS

*= 0x0000
test:
    NOP                         ;@expected{ "PC":"0x0000", "NEXT":"0x0001", "A":"0x00", "X":"0x00", "SP":"0xFF", "NV-BDIZC":"0b00100000" }
    jmp cmp_test                ;@expected{ "PC":"0x0001", "NEXT":"0x0100" }

; Note : we will use the actual address instead of the label 
; to force the compiler to use the correct addressing mode 
; for each instruction.
*= 0x0080
zeropage_data:
    !byte 0x00, 0x10, 0x20

*= 0x00F0
indexed_table:
    !word zeropage_data, zeropage_data+1, zeropage_data+2

*= 0x0100
cmp_test:
    ; immediate mode
    LDA #$10                    ;@expected{ "A":"0x10" }
    CMP #$00                    ;@expected{ "NV-BDIZC":"0b00100001" }
    CMP #$10                    ;@expected{ "NV-BDIZC":"0b00100011" }
    CMP #$20                    ;@expected{ "NV-BDIZC":"0b10100000" }

    ; zero page mode
    CMP $80                     ;@expected{ "NV-BDIZC":"0b00100001", "addressing_mode":"ZP"}
    CMP $80+1                   ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZP" }
    CMP $80+2                   ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }

    ; zero page,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    CMP $80,X                   ;@expected{ "NV-BDIZC":"0b00100001", "addressing_mode":"ZPX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    CMP $80,X                   ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZPX" }
    LDX #$02                    ;@expected{ "X":"0x02" }
    CMP $80,X                   ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }

    ; absolute mode
    CMP $0080                   ;@expected{ "NV-BDIZC":"0b00100001", "addressing_mode":"ABS" }
    CMP $0080+1                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABS" }
    CMP $0080+2                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }

    ; absolute,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    CMP $0080,X                 ;@expected{ "NV-BDIZC":"0b00100001", "addressing_mode":"ABX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    CMP $0080,X                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABX" }
    LDX #$02                    ;@expected{ "X":"0x02" }
    CMP $0080,X                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }

    ; absolute,Y mode
    LDY #$00                    ;@expected{ "Y":"0x00" }
    CMP $0080,Y                 ;@expected{ "NV-BDIZC":"0b00100001", "addressing_mode":"ABY" }
    LDY #$01                    ;@expected{ "Y":"0x01" }
    CMP $0080,Y                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABY" }
    LDY #$02                    ;@expected{ "Y":"0x02" }
    CMP $0080,Y                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABY" }

    ; indirect,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    CMP ($F0,X)                 ;@expected{ "NV-BDIZC":"0b00100001", "addressing_mode":"INX" }
    LDX #$02                    ;@expected{ "X":"0x02" }
    CMP ($F0,X)                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"INX" }
    LDX #$04                    ;@expected{ "X":"0x04" }
    CMP ($F0,X)                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"INX" }

    ; indirect,Y mode
    LDY #$00                    ;@expected{ "Y":"0x00" }
    CMP ($F0),Y                 ;@expected{ "NV-BDIZC":"0b00100001", "addressing_mode":"INY" }
    LDY #$01                    ;@expected{ "Y":"0x01" }
    CMP ($F0),Y                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"INY" }
    LDY #$02                    ;@expected{ "Y":"0x02" }
    CMP ($F0),Y                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"INY" }

cpx_test:
    ; immediate mode
    LDX #$10                    ;@expected{ "X":"0x10" }
    CPX #$00                    ;@expected{ "NV-BDIZC":"0b00100001" }
    CPX #$10                    ;@expected{ "NV-BDIZC":"0b00100011" }
    CPX #$20                    ;@expected{ "NV-BDIZC":"0b10100000" }

    ; zero page mode
    CPX $80                     ;@expected{ "NV-BDIZC":"0b00100001", "addressing_mode":"ZP" }
    CPX $80+1                   ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZP" }
    CPX $80+2                   ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }

    ; absolute mode
    CPX $0080                   ;@expected{ "NV-BDIZC":"0b00100001", "addressing_mode":"ABS" }
    CPX $0080+1                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABS" }
    CPX $0080+2                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }

cpy_test:
    ; immediate mode
    LDY #$10                    ;@expected{ "Y":"0x10" }
    CPY #$00                    ;@expected{ "NV-BDIZC":"0b00100001" }
    CPY #$10                    ;@expected{ "NV-BDIZC":"0b00100011" }
    CPY #$20                    ;@expected{ "NV-BDIZC":"0b10100000" }

    ; zero page mode
    CPY $80                     ;@expected{ "NV-BDIZC":"0b00100001", "addressing_mode":"ZP" }
    CPY $80+1                   ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZP" }
    CPY $80+2                   ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }

    ; absolute mode
    CPY $0080                   ;@expected{ "NV-BDIZC":"0b00100001", "addressing_mode":"ABS" }
    CPY $0080+1                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABS" }
    CPY $0080+2                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }

    BRK                         ;@halt