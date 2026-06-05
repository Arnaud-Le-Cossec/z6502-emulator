; @test{ "name": "Transfer instruction test" }               
;   _____ ___ ___ ___ ___ 
;  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - Transfer test
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

; Instruction tested: TAX, TXA, TAY, TYA 	

; COMPILER PARAMETERS *********************************** Built with ACME v0.91
; CPU target
!cpu 6502
; ********************************************************* COMPILER PARAMETERS

*= 0x0000
test:
    NOP                         ;@expected{ "PC":"0x0000", "NEXT":"0x0001", "A":"0x00", "X":"0x00", "SP":"0xFF", "NV-BDIZC":"0b00100000" }

tax_test:
    ; implied mode
    LDA #$AA                    ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000"}
    LDX #$55                    ;@expected{ "X":"0x55", "NV-BDIZC":"0b00100000"}
    TAX                         ;@expected{ "X":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"IMP"}

    LDA #$00                    ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010"}
    LDX #$AA                    ;@expected{ "X":"0xAA", "NV-BDIZC":"0b10100000"}
    TAX                         ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMP"}

txa_test:
    ; implied mode
    LDX #$AA                    ;@expected{ "X":"0xAA", "NV-BDIZC":"0b10100000"}
    LDA #$55                    ;@expected{ "A":"0x55", "NV-BDIZC":"0b00100000"}
    TXA                         ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"IMP"}

    LDX #$00                    ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010"}
    LDA #$AA                    ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000"}
    TXA                         ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMP"}

tay_test:
    ; implied mode
    LDA #$AA                    ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000"}
    LDY #$55                    ;@expected{ "Y":"0x55", "NV-BDIZC":"0b00100000"}
    TAY                         ;@expected{ "Y":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"IMP"}

    LDA #$00                    ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010"}
    LDY #$AA                    ;@expected{ "Y":"0xAA", "NV-BDIZC":"0b10100000"}
    TAY                         ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMP"}

tya_test:
    ; implied mode
    LDY #$AA                    ;@expected{ "Y":"0xAA", "NV-BDIZC":"0b10100000"}
    LDA #$55                    ;@expected{ "A":"0x55", "NV-BDIZC":"0b00100000"}
    TYA                         ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000", "addressing_mode":"IMP"}

    LDY #$00                    ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100010"}
    LDA #$AA                    ;@expected{ "A":"0xAA", "NV-BDIZC":"0b10100000"}
    TYA                         ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMP"}

    BRK                         ;@halt



