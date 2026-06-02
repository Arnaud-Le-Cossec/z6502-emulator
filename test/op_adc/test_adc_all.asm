; filepath: test/op_adc/test_adc_all.asm
; Z6502 ADC Instruction Comprehensive Test Suite
; Tests all addressing modes, flag combinations, and decimal mode

; Test 1: ADC Immediate - Basic addition without carry
lda #$50        ; Load 0x50 into A
adc #$30        ; Add 0x30
;@expected {"A": 0x80, "NV-BDIZC": 0b10000000}

; Test 2: ADC Immediate - Addition with carry result
lda #$80
adc #$90        ; 0x80 + 0x90 = 0x110, should set carry
;@expected {"A": 0x10, "NV-BDIZC": 0b00000001}

; Test 3: ADC Immediate - Addition with existing carry flag
lda #$50
clc             ; Clear carry
adc #$30        ; 0x50 + 0x30 + 0 = 0x80
;@expected {"A": 0x80, "NV-BDIZC": 0b10000000}

; Test 4: ADC Immediate - Addition with carry flag set
lda #$50
sec             ; Set carry
adc #$30        ; 0x50 + 0x30 + 1 = 0x81
;@expected {"A": 0x81, "NV-BDIZC": 0b10000000}

; Test 5: ADC Immediate - Result zero
lda #$00
adc #$00        ; 0x00 + 0x00 = 0x00
;@expected {"A": 0x00, "NV-BDIZC": 0b00000010}

; Test 6: ADC Immediate - Overflow positive + positive = negative
lda #$50        ; +80
adc #$50        ; +80, result should be -96 with overflow
;@expected {"A": 0xA0, "NV-BDIZC": 0b11000000}

; Test 7: ADC Immediate - Overflow negative + negative = positive
lda #$80        ; -128
adc #$80        ; -128, result should be 0x00 with overflow and carry
;@expected {"A": 0x00, "NV-BDIZC": 0b01000011}

; Test 8: ADC Zero Page
lda #$20
sta $80         ; Store 0x20 at address 0x80
lda #$30
adc $80         ; Add value from zero page
;@expected {"A": 0x50, "NV-BDIZC": 0b00000000}

; Test 9: ADC Zero Page,X
lda #$10
sta $85         ; Store 0x10 at address 0x85
ldx #$05        ; Set X to 5
lda #$20
adc $80,x       ; Add value from zero page indexed by X
;@expected {"A": 0x30, "NV-BDIZC": 0b00000000}

; Test 10: ADC Absolute
lda #$25
sta $1000       ; Store 0x25 at address 0x1000
lda #$35
adc $1000       ; Add value from absolute address
;@expected {"A": 0x5A, "NV-BDIZC": 0b00000000}

; Test 11: ADC Absolute,X
lda #$40
sta $1005       ; Store 0x40 at address 0x1005
ldx #$05        ; Set X to 5
lda #$30
adc $1000,x     ; Add value from absolute address indexed by X
;@expected {"A": 0x70, "NV-BDIZC": 0b00000000}

; Test 12: ADC Absolute,Y
lda #$45
sta $1008       ; Store 0x45 at address 0x1008
ldy #$08        ; Set Y to 8
lda #$25
adc $1000,y     ; Add value from absolute address indexed by Y
;@expected {"A": 0x6A, "NV-BDIZC": 0b00000000}

; Test 13: ADC (Indirect,X)
lda #$50
sta $2000       ; Store 0x50 at address 0x2000
lda #$10        ; Store address low byte
sta $80
lda #$20        ; Store address high byte
sta $81
ldx #$00        ; Set X to 0
lda #$30
adc ($80,x)     ; Add from indirect X-indexed address
;@expected {"A": 0x80, "NV-BDIZC": 0b10000000}

; Test 14: ADC (Indirect),Y
lda #$60
sta $2005       ; Store 0x60 at address 0x2005
lda #$00        ; Store address low byte
sta $82
lda #$20        ; Store address high byte
sta $83
ldy #$05        ; Set Y to 5
lda #$40
adc ($82),y     ; Add from indirect Y-indexed address
;@expected {"A": 0xA0, "NV-BDIZC": 0b10000000}

; Test 15: ADC with all flags initially set
lda #$7F
sec
adc #$00        ; Add with carry set
;@expected {"A": 0x80, "NV-BDIZC": 0b10000000}

; Test 16: ADC Decimal Mode - Basic BCD addition
sed             ; Set decimal mode
lda #$09
adc #$01        ; 9 + 1 = 10 (0x10 in BCD)
;@expected {"A": 0x10, "NV-BDIZC": 0b00001000}

; Test 17: ADC Decimal Mode - BCD with carry
sed             ; Set decimal mode
lda #$50
adc #$60        ; 50 + 60 = 110 (0x10 with carry in BCD)
;@expected {"A": 0x10, "NV-BDIZC": 0b00001001}

; Test 18: ADC Decimal Mode - BCD addition with existing carry
sed             ; Set decimal mode
lda #$25
sec
adc #$15        ; 25 + 15 + 1 = 41 (0x41 in BCD)
;@expected {"A": 0x41, "NV-BDIZC": 0b00001000}

; Test 19: ADC Decimal Mode - BCD result zero
sed             ; Set decimal mode
lda #$00
adc #$00        ; 0 + 0 = 0
;@expected {"A": 0x00, "NV-BDIZC": 0b00001010}

; Test 20: ADC exit decimal mode
cld             ; Clear decimal mode
lda #$09
adc #$01        ; 9 + 1 = 10 (0x0A in binary, not BCD)
;@expected {"A": 0x0A, "NV-BDIZC": 0b00000000}

;@halt
