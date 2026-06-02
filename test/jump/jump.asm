; @test{ "name": "jump instruction test" }               
;   _____ ___ ___ ___ ___ 
;  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - Jump test
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

; Instruction tested: JMP, JSR, RTS, RTI

; COMPILER PARAMETERS *********************************** Built with ACME v0.91
; CPU target
!cpu 6502
; Set PC
*= 0x0000
; ********************************************************* COMPILER PARAMETERS

jmp_implied:
    NOP                 ;@expected{ "PC":"0x0000", "NEXT":"0x0001", "A":"0x00", "X":"0x00", "SP":"0xFF", "NV-BDIZC":"0b00100000" }
    JMP jmp_indirect    ;@expected{ "PC":"0x0001", "NEXT":"0x0100" }

*= 0x0100
jmp_indirect:
    JMP (d0)            ;@expected{ "PC":"0x0100", "NEXT":"0x0200" }

*= 0x0200
jsr_absolute:
    JSR jsr_absolute_sub ;@expected{ "PC":"0x0200", "NEXT":"0x0300", "SP":"0xFD" } @+8
    ; We fool the cpu and to create a false interrupt return data in the stack
    LDA #$04            ;@+
    PHA                 ;@+
    LDA #$00            ;@+
    PHA                 ;@+
    PHP                 ;@+
    RTI                 ;@expected{ "NEXT":"0x0400", "SP":"0xFF" } @+3

*= 0x0300
jsr_absolute_sub:
    RTS                 ;@expected{ "PC":"0x0300", "NEXT":"0x0203", "SP":"0xFF" } @-8

*= 0x0400
rti_return:
    NOP                 ;@expected{"PC":"0x0400"}
    BRK                 ;@halt

*= 0x8000
d0:
    !word jsr_absolute