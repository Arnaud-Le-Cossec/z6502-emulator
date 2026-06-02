; @test{ "name": "Flags instruction test" }               
;   _____ ___ ___ ___ ___ 
;  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - flags test
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

; Instruction tested: CLC, SEC, CLI, SEI, CLD, SED, CLV

; COMPILER PARAMETERS *********************************** Built with ACME v0.91
; CPU target
!cpu 6502
; Set PC
*= 0x0000
; ********************************************************* COMPILER PARAMETERS

test:
    NOP     ;@expected{ "NV-BDIZC":"0b00100000" }
    SEC     ;@expected{ "NV-BDIZC":"0b00100001" }
    CLC     ;@expected{ "NV-BDIZC":"0b00100000" }
    SEI     ;@expected{ "NV-BDIZC":"0b00100100" }
    CLI     ;@expected{ "NV-BDIZC":"0b00100000" }
    SED     ;@expected{ "NV-BDIZC":"0b00101000" }
    CLD     ;@expected{ "NV-BDIZC":"0b00100000" }
    CLV     ;@expected{ "NV-BDIZC":"0b00100000" }
    BRK     ;@halt
