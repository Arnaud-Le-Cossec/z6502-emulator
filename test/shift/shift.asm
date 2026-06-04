; @test{ "name": "Shift instruction test" }               
;   _____ ___ ___ ___ ___ 
;  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - Shift test
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

; Instruction tested: ASL, LSR, ROL, ROR

; COMPILER PARAMETERS *********************************** Built with ACME v0.91
; CPU target
!cpu 6502
; ********************************************************* COMPILER PARAMETERS

*= 0x0000
test:
    NOP                         ;@expected{ "PC":"0x0000", "NEXT":"0x0001", "A":"0x00", "X":"0x00", "SP":"0xFF", "NV-BDIZC":"0b00100000" }
    jmp asl_test                ;@expected{ "PC":"0x0001", "NEXT":"0x0100" }

; Note : we will use the actual address instead of the label 
; to force the compiler to use the correct addressing mode 
; for each instruction.
*= 0x0080
asl_data:
    !byte 0x40, 0x40, 0x40, 0x40

lsr_data:
    !byte 0x02, 0x02, 0x02, 0x02

rol_data:
    !byte 0x40, 0x40, 0x40, 0x40

ror_data:
    !byte 0x02, 0x02, 0x02, 0x02

*= 0x0100
asl_test:
    ; accumulator mode
    LDA #$40                    ;@expected{ "A":"0x40", "NV-BDIZC":"0b00100000" }
    ASL                         ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100000", "addressing_mode":"ACC" }
    ASL                         ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100011", "addressing_mode":"ACC" }

    ; zero page mode
    ASL $80                     ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }
    ASL $80                     ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZP" }

    ; zero page,X mode
    LDX #$01                    ;@expected{ "X":"0x01" }
    ASL $80,X                   ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }
    ASL $80,X                   ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZPX" }
    LDA $80                     ;@expected{ "A":"0x00" }

    ; absolute mode
    ASL $0080+2                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }
    ASL $0080+2                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABS" }
    LDA $80+2                   ;@expected{ "A":"0x00" }

    ; absolute,X mode
    LDX #$03                    ;@expected{ "X":"0x03" }
    ASL $0080,X                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }
    ASL $0080,X                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABX" }
    LDA $80+3                   ;@expected{ "A":"0x00" }

    CLC                         ;@expected{ "NV-BDIZC":"0b00100010" }
lsr_test:
    ; accumulator mode
    LDA #$02                    ;@expected{ "A":"0x02", "NV-BDIZC":"0b00100000" }
    LSR                         ;@expected{ "A":"0x01", "NV-BDIZC":"0b00100000", "addressing_mode":"ACC" }
    LSR                         ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100011", "addressing_mode":"ACC" }

    ; zero page mode
    LSR $84                     ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ZP" }
    LSR $84                     ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZP" }
    LDA $84                     ;@expected{ "A":"0x00" }

    ; zero page,X mode
    LDX #$01                    ;@expected{ "X":"0x01" }
    LSR $84,X                   ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ZPX" }
    LSR $84,X                   ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZPX" }
    LDA $84+1                   ;@expected{ "A":"0x00" }

    ; absolute mode
    LSR $0084+2                 ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ABS" }
    LSR $0084+2                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABS" }
    LDA $84+2                   ;@expected{ "A":"0x00" }

    ; absolute,X mode
    LDX #$03                    ;@expected{ "X":"0x03" }
    LSR $0084,X                 ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ABX" }
    LSR $0084,X                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABX" }
    LDA $84+3                   ;@expected{ "A":"0x00" }

    CLC                         ;@expected{ "NV-BDIZC":"0b00100010" }

rol_test:
    ; accumulator mode
    LDA #$40                    ;@expected{ "A":"0x40", "NV-BDIZC":"0b00100000" }
    ROL                         ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100000", "addressing_mode":"ACC" }
    ROL                         ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100011", "addressing_mode":"ACC" }
    ROL                         ;@expected{ "A":"0x01", "NV-BDIZC":"0b00100000", "addressing_mode":"ACC" }

    ; zero page mode
    ROL $88                     ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }
    ROL $88                     ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZP" }
    ROL $88                     ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ZP" }
    LDA $88                     ;@expected{ "A":"0x01" }

    ; zero page,X mode
    LDX #$01                    ;@expected{ "X":"0x01" }
    ROL $88,X                   ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }
    ROL $88,X                   ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZPX" }
    ROL $88,X                   ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ZPX" }
    LDA $88+1                   ;@expected{ "A":"0x01" }

    ; absolute mode
    ROL $0088+2                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }
    ROL $0088+2                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABS" }
    ROL $0088+2                 ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ABS" }
    LDA $88+2                   ;@expected{ "A":"0x01" }

    ; absolute,X mode
    LDX #$03                    ;@expected{ "X":"0x03" }
    ROL $0088,X                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }
    ROL $0088,X                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABX" }
    ROL $0088,X                 ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ABX" }
    LDA $88+3                   ;@expected{ "A":"0x01" }

ror_test:
    ; accumulator mode
    LDA #$02                    ;@expected{ "A":"0x02", "NV-BDIZC":"0b00100000" }
    ROR                         ;@expected{ "A":"0x01", "NV-BDIZC":"0b00100000", "addressing_mode":"ACC" }
    ROR                         ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100011", "addressing_mode":"ACC" }
    ROR                         ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100000", "addressing_mode":"ACC" }

    ; zero page mode
    ROR $8C                     ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ZP" }
    ROR $8C                     ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZP" }
    ROR $8C                     ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }
    LDA $8C                     ;@expected{ "A":"0x80" }

    ; zero page,X mode
    LDX #$01                    ;@expected{ "X":"0x01" }
    ROR $8C,X                   ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ZPX" }
    ROR $8C,X                   ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ZPX" }
    ROR $8C,X                   ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }
    LDA $8C+1                   ;@expected{ "A":"0x80" }

    ; absolute mode
    ROR $008C+2                 ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ABS" }
    ROR $008C+2                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABS" }
    ROR $008C+2                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }
    LDA $8C+2                   ;@expected{ "A":"0x80" }

    ; absolute,X mode
    LDX #$03                    ;@expected{ "X":"0x03" }
    ROR $008C,X                 ;@expected{ "NV-BDIZC":"0b00100000", "addressing_mode":"ABX" }
    ROR $008C,X                 ;@expected{ "NV-BDIZC":"0b00100011", "addressing_mode":"ABX" }
    ROR $008C,X                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }
    LDA $8C+3                   ;@expected{ "A":"0x80" }

    BRK                         ;@halt