; @test{ "name": "Stack instruction test" }               
;   _____ ___ ___ ___ ___ 
;  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - Stack test
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

; Instruction tested: PHA, PLA, PHP, PLP, TXS, TSX

; COMPILER PARAMETERS *********************************** Built with ACME v0.91
; CPU target
!cpu 6502
; Set PC
*= 0x0000
; ********************************************************* COMPILER PARAMETERS

test:
    ; Test PHA and PLA
    LDA #$10 ;@expected{ "SP":"0xFF" }
    PHA      ;@expected{ "SP":"0xFE" }
    LDA #$20 ;@expected{ "A":"0x20" }
    PLA ;@expected{ "A":"0x10", "SP":"0xFF" }

    ; Test PHP and PLP
    SEC      ;@expected{ "NV-BDIZC":"0b00100001" }
    PHP      ;@expected{ "SP":"0xFE", "NV-BDIZC":"0b00100001" }
    CLC      ;@expected{ "NV-BDIZC":"0b00100000" }
    PLP      ;@expected{ "SP":"0xFF", "NV-BDIZC":"0b00100001" }

    ; Test TXS and TSX
    LDX #$80 ;@expected{ "X":"0x80" }
    TXS      ;@expected{ "SP":"0x80"}
    LDX #$00 ;@expected{ "X":"0x00" }
    TSX      ;@expected{ "SP":"0x80", "X":"0x80" }

    BRK      ;@halt
