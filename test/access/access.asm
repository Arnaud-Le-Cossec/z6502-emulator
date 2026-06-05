; @test{ "name": "Access instruction test" }               
;   _____ ___ ___ ___ ___ 
;  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - Access test
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

; Instruction tested: LDA, STA, LDX, STX, LDY, STY 	

; COMPILER PARAMETERS *********************************** Built with ACME v0.91
; CPU target
!cpu 6502
; ********************************************************* COMPILER PARAMETERS

*= 0x0000
test:
    NOP                         ;@expected{ "PC":"0x0000", "NEXT":"0x0001", "A":"0x00", "X":"0x00", "SP":"0xFF", "NV-BDIZC":"0b00100000" }
    jmp lda_test                ;@expected{ "PC":"0x0001", "NEXT":"0x0100" }

; Note : we will use the actual address instead of the label 
; to force the compiler to use the correct addressing mode 
; for each instruction.
*= 0x0080
zeropage_read_data:
    !byte 0xAA, 0x00

*= 0x00E0
indexed_read_table:
    !word zeropage_read_data, zeropage_read_data+1

*= 0x00F0
indexed_write_table:
    !word 0x9000, 0x9010

*= 0x0100
lda_test:
    ; immediate mode
    LDA #$AA                    ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"IMM" }
    LDA #$00                    ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMM" }

    ; zero page mode
    LDA $80                     ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }
    LDA $80+1                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZP" }

    ; zero page,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDA $80,X                   ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDA $80,X                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZPX" }

    ; absolute mode
    LDA $0080                   ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }
    LDA $0080+1                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABS" }

    ; absolute,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDA $0080,X                 ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDA $0080,X                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABX" }

    ; absolute,Y mode
    LDY #$00                    ;@expected{ "Y":"0x00" }
    LDA $0080,Y                 ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ABY" }
    LDY #$01                    ;@expected{ "Y":"0x01" }
    LDA $0080,Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABY" }

    ; indirect,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDA ($E0,X)                 ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"INX" }
    LDX #$02                    ;@expected{ "X":"0x02" }
    LDA ($E0,X)                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"INX" }

    ; indirect,Y mode
    LDY #$00                    ;@expected{ "Y":"0x00" }
    LDA ($E0),Y                 ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"INY" }
    LDY #$01                    ;@expected{ "Y":"0x01" }
    LDA ($E0),Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"INY" }

sta_test:
    ; zero page mode
    LDA #$F0                    ;@expected{ "A":"0xF0" }
    STA $90                     ;@expected{ "addressing_mode":"ZP" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    LDA $90                     ;@expected{ "A":"0xF0" }

    ; zero page,X mode
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDA #$F1                    ;@expected{ "A":"0xF1" }
    STA $90,X                   ;@expected{ "addressing_mode":"ZPX" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    LDA $0091                   ;@expected{ "A":"0xF1" }

    ; absolute mode
    LDA #$F2                    ;@expected{ "A":"0xF2" }
    STA $8090                   ;@expected{ "addressing_mode":"ABS" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    LDA $8090                   ;@expected{ "A":"0xF2" }

    ; absolute,X mode
    LDX #$03                    ;@expected{ "X":"0x03" }
    LDA #$F3                    ;@expected{ "A":"0xF3" }
    STA $8090,X                 ;@expected{ "addressing_mode":"ABX" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    LDA $8090+3                 ;@expected{ "A":"0xF3" }

    ; absolute,Y mode
    LDY #$04                    ;@expected{ "Y":"0x04" }
    LDA #$F4                    ;@expected{ "A":"0xF4" }
    STA $8090,Y                 ;@expected{ "addressing_mode":"ABY" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    LDA $8090+4                 ;@expected{ "A":"0xF4" }

    ; indirect,X mode
    LDX #$02                    ;@expected{ "X":"0x02" }
    LDA #$F5                    ;@expected{ "A":"0xF5" }
    STA ($F0,X)                 ;@expected{ "addressing_mode":"INX" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    LDA $9010                   ;@expected{ "A":"0xF5" }

    ; indirect,Y mode
    LDY #$20                    ;@expected{ "Y":"0x20" }
    LDA #$F6                    ;@expected{ "A":"0xF6" }
    STA ($F0),Y                 ;@expected{ "addressing_mode":"INY" }
    LDA #$00                    ;@expected{ "A":"0x00" }
    LDA $9020                   ;@expected{ "A":"0xF6" }

ldx_test:
    ; immediate mode
    LDX #$AA                    ;@expected{ "X":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"IMM" }
    LDX #$00                    ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMM" }

    ; zero page mode
    LDX $80                     ;@expected{ "X":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }
    LDX $80+1                   ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZP" }

    ; zero page,Y mode
    LDY #$00                    ;@expected{ "Y":"0x00" }
    LDX $80,Y                   ;@expected{ "X":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ZPY" }
    LDY #$01                    ;@expected{ "Y":"0x01" }
    LDX $80,Y                   ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZPY" }

    ; absolute mode
    LDX $0080                   ;@expected{ "X":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }
    LDX $0080+1                 ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABS" }

    ; absolute,Y mode
    LDY #$00                    ;@expected{ "Y":"0x00" }
    LDX $0080,Y                 ;@expected{ "X":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ABY" }
    LDY #$01                    ;@expected{ "Y":"0x01" }
    LDX $0080,Y                 ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABY" }

stx_test:
    ; zero page mode
    LDX #$F0                    ;@expected{ "X":"0xF0" }
    STX $A0                     ;@expected{ "addressing_mode":"ZP" }
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDX $A0                     ;@expected{ "X":"0xF0" }

    ; zero page,Y mode
    LDY #$01                    ;@expected{ "Y":"0x01" }
    LDX #$F1                    ;@expected{ "X":"0xF1" }
    STX $A0,Y                   ;@expected{ "addressing_mode":"ZPY" }
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDX $00A1                   ;@expected{ "X":"0xF1" }

    ; absolute mode
    LDX #$F2                    ;@expected{ "X":"0xF2" }
    STX $9090                   ;@expected{ "addressing_mode":"ABS" }
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDX $9090                   ;@expected{ "X":"0xF2" }

ldy_test:
    ; immediate mode
    LDY #$AA                    ;@expected{ "Y":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"IMM" }
    LDY #$00                    ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMM" }

    ; zero page mode
    LDY $80                     ;@expected{ "Y":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }
    LDY $80+1                   ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZP" }

    ; zero page,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDY $80,X                   ;@expected{ "Y":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDY $80,X                   ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZPX" }

    ; absolute mode
    LDY $0080                   ;@expected{ "Y":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }
    LDY $0080+1                 ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABS" }

    ; absolute,X mode
    LDX #$00                    ;@expected{ "X":"0x00" }
    LDY $0080,X                 ;@expected{ "Y":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDY $0080,X                 ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABX" }

sty_test:
    ; zero page mode
    LDY #$F0                    ;@expected{ "Y":"0xF0" }
    STY $B0                     ;@expected{ "addressing_mode":"ZP" }
    LDY #$00                    ;@expected{ "Y":"0x00" }
    LDY $B0                     ;@expected{ "Y":"0xF0" }

    ; zero page,X mode
    LDX #$01                    ;@expected{ "X":"0x01" }
    LDY #$F1                    ;@expected{ "Y":"0xF1" }
    STY $B0,X                   ;@expected{ "addressing_mode":"ZPX" }
    LDY #$00                    ;@expected{ "Y":"0x00" }
    LDY $00B1                   ;@expected{ "Y":"0xF1" }

    ; absolute mode
    LDY #$F2                    ;@expected{ "Y":"0xF2" }
    STY $A090                   ;@expected{ "addressing_mode":"ABS" }
    LDY #$00                    ;@expected{ "Y":"0x00" }
    LDY $A090                   ;@expected{ "Y":"0xF2" }

    BRK                         ;@halt



