; @test{ "name": "ADC instruction test" }               
;   _____ ___ ___ ___ ___ 
;  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - ADC test
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


; COMPILER PARAMETERS *********************************** Built with ACME v0.91
; CPU target
!cpu 6502
; Set PC
*= 0x0000
; ********************************************************* COMPILER PARAMETERS

test:
; Tests all addressing modes, flag combinations, and decimal mod
    clc ;@+
    lda #$90 ;@+
    adc #$90 ;@expected{ "A":"0x20", "NV-BDIZC":"0b01100001" }


    ; Test 1: ADC Immediate - Basic addition without carry
    LDA #$50        ; Load 0x50 into accumulator @+
    ADC #$30        ; Add 0x30 
    ;@expected {"accumulator": 0x80, "zero": 0, "negative": 1, "carry": 0, "overflow": 0}

    ; Test 2: ADC Immediate - Addition with carry result
    @+
    LDA #$80
    ADC #$90        ; 0x80 + 0x90 = 0x110, should set carry
    ;@expected {"accumulator": 0x10, "carry": 1, "zero": 0, "negative": 0, "overflow": 0}

    ; Test 3: ADC Immediate - Addition with existing carry flag
    @+
    LDA #$50
    CLC             ; Clear carry
    ADC #$30        ; 0x50 + 0x30 + 0 = 0x80
    @expected {"accumulator": 0x80, "carry": 0, "zero": 0, "negative": 1, "overflow": 0}

    ; Test 4: ADC Immediate - Addition with carry flag set
    @+
    LDA #$50
    SEC             ; Set carry
    ADC #$30        ; 0x50 + 0x30 + 1 = 0x81
    ;@expected {"accumulator": 0x81, "carry": 0, "zero": 0, "negative": 1, "overflow": 0}

    ; Test 5: ADC Immediate - Result zero
    @+
    LDA #$00
    ADC #$00        ; 0x00 + 0x00 = 0x00
    ;@expected {"accumulator": 0x00, "zero": 1, "negative": 0, "carry": 0, "overflow": 0}

    ; Test 6: ADC Immediate - Overflow positive + positive = negative
    @+
    LDA #$50        ; +80
    ADC #$50        ; +80, result should be -96 with overflow
    ;@expected {"accumulator": 0xA0, "overflow": 1, "negative": 1, "carry": 0, "zero": 0}

    ; Test 7: ADC Immediate - Overflow negative + negative = positive
    @+
    LDA #$80        ; -128
    ADC #$80        ; -128, result should be 0x00 with overflow and carry
    ;@expected {"accumulator": 0x00, "overflow": 1, "carry": 1, "zero": 1, "negative": 0}

    ; Test 8: ADC Zero Page
    @+
    LDA #$20
    STA $80         ; Store 0x20 at address 0x80
    LDA #$30
    ADC $80         ; Add value from zero page
    ;@expected {"accumulator": 0x50, "carry": 0, "zero": 0, "negative": 0, "overflow": 0}

    ; Test 9: ADC Zero Page,X
    @+
    LDA #$10
    STA $85         ; Store 0x10 at address 0x85
    LDX #$05        ; Set X to 5
    LDA #$20
    ADC $80,X       ; Add value from zero page indexed by X
    ;@expected {"accumulator": 0x30, "carry": 0, "zero": 0, "negative": 0, "overflow": 0}

    ; Test 10: ADC Absolute
    @+
    LDA #$25
    STA $1000       ; Store 0x25 at address 0x1000
    LDA #$35
    ADC $1000       ; Add value from absolute address
    ;@expected {"accumulator": 0x5A, "carry": 0, "zero": 0, "negative": 0, "overflow": 0}

    ; Test 11: ADC Absolute,X
    @+
    LDA #$40
    STA $1005       ; Store 0x40 at address 0x1005
    LDX #$05        ; Set X to 5
    LDA #$30
    ADC $1000,X     ; Add value from absolute address indexed by X
    ;@expected {"accumulator": 0x70, "carry": 0, "zero": 0, "negative": 0, "overflow": 0}

    ; Test 12: ADC Absolute,Y
    @+
    LDA #$45
    STA $1008       ; Store 0x45 at address 0x1008
    LDY #$08        ; Set Y to 8
    LDA #$25
    ADC $1000,Y     ; Add value from absolute address indexed by Y
    ;@expected {"accumulator": 0x6A, "carry": 0, "zero": 0, "negative": 0, "overflow": 0}

    ; Test 13: ADC (Indirect,X)
    @+
    LDA #$50
    STA $2000       ; Store 0x50 at address 0x2000
    LDA #$10        ; Store address low byte
    STA $80
    LDA #$20        ; Store address high byte
    STA $81
    LDX #$00        ; Set X to 0
    LDA #$30
    ADC ($80,X)     ; Add from indirect X-indexed address
    ;@expected {"accumulator": 0x80, "carry": 0, "zero": 0, "negative": 1, "overflow": 0}

    ; Test 14: ADC (Indirect),Y
    @+
    LDA #$60
    STA $2005       ; Store 0x60 at address 0x2005
    LDA #$00        ; Store address low byte
    STA $82
    LDA #$20        ; Store address high byte
    STA $83
    LDY #$05        ; Set Y to 5
    LDA #$40
    ADC ($82),Y     ; Add from indirect Y-indexed address
    ;@expected {"accumulator": 0xA0, "carry": 0, "zero": 0, "negative": 1, "overflow": 0}

    ; Test 15: ADC with all flags initially set
    @+
    LDA #$7F
    SEC
    ADC #$00        ; Add with carry set
    ;@expected {"accumulator": 0x80, "carry": 0, "negative": 1, "zero": 0, "overflow": 0}

    ; Test 16: ADC Decimal Mode - Basic BCD addition
    @+
    SED             ; Set decimal mode
    LDA #$09
    ADC #$01        ; 9 + 1 = 10 (0x10 in BCD)
    ;@expected {"accumulator": 0x10, "decimal_mode": 1, "carry": 0, "zero": 0, "negative": 0}

    ; Test 17: ADC Decimal Mode - BCD with carry
    @+
    SED             ; Set decimal mode
    LDA #$50
    ADC #$60        ; 50 + 60 = 110 (0x10 with carry in BCD)
    ;@expected {"accumulator": 0x10, "decimal_mode": 1, "carry": 1, "zero": 0, "negative": 0}

    ; Test 18: ADC Decimal Mode - BCD addition with existing carry
    @+
    SED             ; Set decimal mode
    LDA #$25
    SEC
    ADC #$15        ; 25 + 15 + 1 = 41 (0x41 in BCD)
    ;@expected {"accumulator": 0x41, "decimal_mode": 1, "carry": 0, "zero": 0, "negative": 0}

    ; Test 19: ADC Decimal Mode - BCD result zero
    @+
    SED             ; Set decimal mode
    LDA #$00
    ADC #$00        ; 0 + 0 = 0
    ;@expected {"accumulator": 0x00, "decimal_mode": 1, "zero": 1, "carry": 0, "negative": 0}

    ; Test 20: ADC exit decimal mode
    @+
    CLD             ; Clear decimal mode
    LDA #$09
    ADC #$01        ; 9 + 1 = 10 (0x0A in binary, not BCD)
    ;@expected {"accumulator": 0x0A, "decimal_mode": 0, "carry": 0, "zero": 0, "negative": 0}

    
    brk ; @halt

