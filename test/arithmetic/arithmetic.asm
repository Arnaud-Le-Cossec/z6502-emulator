; @test{ "name": "Arithmetic instruction test" }               
;   _____ ___ ___ ___ ___ 
;  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - Arithmetic test
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

; Instruction tested: ADC, SBC, INC, DEC, INX, DEX, INY, DEY 	

; COMPILER PARAMETERS *********************************** Built with ACME v0.91
; CPU target
!cpu 6502
; ********************************************************* COMPILER PARAMETERS

*= 0x0000
test:
    NOP                         ;@expected{ "PC":"0x0000", "NEXT":"0x0001", "A":"0x00", "X":"0x00", "SP":"0xFF", "NV-BDIZC":"0b00100000" }
    JMP inc_test                ;@expected{ "PC":"0x0001", "NEXT":"0x0100" }

; Note : we will use the actual address instead of the label 
; to force the compiler to use the correct addressing mode 
; for each instruction.
*= 0x0040
zeropage_data:
    !byte 0xFE, 0xFE, 0xFE, 0xFE

*= 0x0050
zeropage_adc_data
    !byte 0xEE, 0x81, 0x80

*= 0x0060
zeropage_sbc_data
    !byte 0x11, 0x7F, 0x7E

*= 0x0080
indexed_adc_table:
    !word zeropage_adc_data, zeropage_adc_data+1, zeropage_adc_data+2

*= 0x0090
indexed_sbc_table:
    !word zeropage_sbc_data, zeropage_sbc_data+1, zeropage_sbc_data+2


*= 0x0100
inc_test:
    ; zero page mode
    INC $40                     ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }
    LDA $40                     ;@expected{ "A":"0xFF" }
    INC $40                     ;@expected{ "NV-BDIZC":"0b00100010", "addressing_mode":"ZP" }
    LDA $40                     ;@expected{ "A":"0x00" }

    ; zero page,X mode
    LDX #$01                    ;@expected{ "X":"0x01" }
    INC $40,X                   ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }
    LDA $40+1                   ;@expected{ "A":"0xFF" }
    INC $40,X                   ;@expected{ "NV-BDIZC":"0b00100010", "addressing_mode":"ZPX" }
    LDA $40+1                   ;@expected{ "A":"0x00" }

    ; absolute mode
    INC $0040+2                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }
    LDA $0040+2                 ;@expected{ "A":"0xFF" }
    INC $0040+2                 ;@expected{ "NV-BDIZC":"0b00100010", "addressing_mode":"ABS" }
    LDA $0040+2                 ;@expected{ "A":"0x00" }

    ; absolute,X mode
    LDX #$03                    ;@expected{ "X":"0x03" }
    INC $0040,X                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }
    LDA $0040,X                 ;@expected{ "A":"0xFF" }
    INC $0040,X                 ;@expected{ "NV-BDIZC":"0b00100010", "addressing_mode":"ABX" }
    LDA $0040,X                 ;@expected{ "A":"0x00" }

    ; reset data for next test
    LDA #$01                    ;@expected{ "A":"0x01", "NV-BDIZC":"0b00100000" }
    STA $40                     ;@expected{ }
    STA $40+1                   ;@expected{ }
    STA $40+2                   ;@expected{ }
    STA $40+3                   ;@expected{ }


dec_test:
    ; zero page mode
    DEC $40                     ;@expected{ "NV-BDIZC":"0b00100010", "addressing_mode":"ZP" }
    LDA $40                     ;@expected{ "A":"0x00" }
    DEC $40                     ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }
    LDA $40                     ;@expected{ "A":"0xFF" }

    ; zero page,X mode
    LDX #$01                    ;@expected{ "X":"0x01" }
    DEC $40,X                   ;@expected{ "NV-BDIZC":"0b00100010", "addressing_mode":"ZPX" }
    LDA $40+1                   ;@expected{ "A":"0x00" }
    DEC $40,X                   ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }
    LDA $40+1                   ;@expected{ "A":"0xFF" }

    ; absolute mode
    DEC $0040+2                 ;@expected{ "NV-BDIZC":"0b00100010", "addressing_mode":"ABS" }
    LDA $0040+2                 ;@expected{ "A":"0x00" }
    DEC $0040+2                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }
    LDA $0040+2                 ;@expected{ "A":"0xFF" }

    ; absolute,X mode
    LDX #$03                    ;@expected{ "X":"0x03" }
    DEC $0040,X                 ;@expected{ "NV-BDIZC":"0b00100010", "addressing_mode":"ABX" }
    LDA $0040,X                 ;@expected{ "A":"0x00" }
    DEC $0040,X                 ;@expected{ "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }
    LDA $0040,X                 ;@expected{ "A":"0xFF" }

inx_test:
    ; Implied mode
    LDX #$FE                    ;@expected{ "X":"0xFE" }
    LDA #$01                    ;@expected{ "NV-BDIZC":"0b00100000" }
    INX                         ;@expected{ "X":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"IMP"}
    INX                         ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMP"}

dex_test:
    ; Implied mode
    LDX #$01                    ;@expected{ "X":"0x01" }
    DEX                         ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMP"}
    DEX                         ;@expected{ "X":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"IMP"}

iny_test:
    ; Implied mode
    LDY #$FE                    ;@expected{ "Y":"0xFE" }
    LDA #$01                    ;@expected{ "NV-BDIZC":"0b00100000" }
    INY                         ;@expected{ "Y":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"IMP"}
    INY                         ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMP"}

dey_test:
    ; Implied mode
    LDY #$01                    ;@expected{ "Y":"0x01" }
    DEY                         ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMP"}
    DEY                         ;@expected{ "Y":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"IMP"}

adc_binary_test:
    ; immediate mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    SEC                         ;@expected{ "NV-BDIZC":"0b00100001" }
    ADC #$EE                    ;@expected{ "A":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"IMM" }
    ADC #$81                    ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100001", "addressing_mode":"IMM" }
    CLC                         ;@expected{ "NV-BDIZC":"0b10100000" }
    ADC #$80                    ;@expected{ "A":"0x00", "NV-BDIZC":"0b01100011", "addressing_mode":"IMM"}

    CLV                         ;@expected{ "NV-BDIZC":"0b00100011" }
    CLC                         ;@expected{ "NV-BDIZC":"0b00100010" }

    ; zero page mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    SEC                         ;@expected{ "NV-BDIZC":"0b00100001" }
    ADC $50                     ;@expected{ "A":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"ZP" }
    ADC $50+1                   ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100001", "addressing_mode":"ZP" }
    CLC                         ;@expected{ "NV-BDIZC":"0b10100000" }
    ADC $50+2                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b01100011", "addressing_mode":"ZP"}

    CLV                         ;@expected{ "NV-BDIZC":"0b00100011" }
    CLC                         ;@expected{ "NV-BDIZC":"0b00100010" }

    ; zero page,X mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    SEC                         ;@expected{ "NV-BDIZC":"0b00100001" }
    LDX #$00                    ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100011" }
    ADC $50,X                   ;@expected{ "A":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"ZPX" }
    LDX #$01                    ;@expected{ "X":"0x01", "NV-BDIZC":"0b00100000" }
    ADC $50,X                   ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100001", "addressing_mode":"ZPX" }
    CLC                         ;@expected{ "NV-BDIZC":"0b10100000" }
    LDX #$02                    ;@expected{ "X":"0x02", "NV-BDIZC":"0b00100000" }
    ADC $50,X                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b01100011", "addressing_mode":"ZPX"}

    CLV                         ;@expected{ "NV-BDIZC":"0b00100011" }
    CLC                         ;@expected{ "NV-BDIZC":"0b00100010" }

    ; absolute mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    SEC                         ;@expected{ "NV-BDIZC":"0b00100001" }
    ADC $0050                   ;@expected{ "A":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"ABS" }
    ADC $0050+1                 ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100001", "addressing_mode":"ABS" }
    CLC                         ;@expected{ "NV-BDIZC":"0b10100000" }
    ADC $0050+2                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b01100011", "addressing_mode":"ABS"}

    CLV                         ;@expected{ "NV-BDIZC":"0b00100011" }
    CLC                         ;@expected{ "NV-BDIZC":"0b00100010" }

    ; absolute,X mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    SEC                         ;@expected{ "NV-BDIZC":"0b00100001" }
    LDX #$00                    ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100011" }
    ADC $0050,X                 ;@expected{ "A":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"ABX" }
    LDX #$01                    ;@expected{ "X":"0x01", "NV-BDIZC":"0b00100000" }
    ADC $0050,X                 ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100001", "addressing_mode":"ABX" }
    CLC                         ;@expected{ "NV-BDIZC":"0b10100000" }
    LDX #$02                    ;@expected{ "X":"0x02", "NV-BDIZC":"0b00100000" }
    ADC $0050,X                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b01100011", "addressing_mode":"ABX"}

    CLV                         ;@expected{ "NV-BDIZC":"0b00100011" }
    CLC                         ;@expected{ "NV-BDIZC":"0b00100010" }

    ; absolute,Y mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    SEC                         ;@expected{ "NV-BDIZC":"0b00100001" }
    LDY #$00                    ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100011" }
    ADC $0050,Y                 ;@expected{ "A":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"ABY" }
    LDY #$01                    ;@expected{ "Y":"0x01", "NV-BDIZC":"0b00100000" }
    ADC $0050,Y                 ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100001", "addressing_mode":"ABY" }
    CLC                         ;@expected{ "NV-BDIZC":"0b10100000" }
    LDY #$02                    ;@expected{ "Y":"0x02", "NV-BDIZC":"0b00100000" }
    ADC $0050,Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b01100011", "addressing_mode":"ABY"}

    CLV                         ;@expected{ "NV-BDIZC":"0b00100011" }
    CLC                         ;@expected{ "NV-BDIZC":"0b00100010" }

    ; indirect,X mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    SEC                         ;@expected{ "NV-BDIZC":"0b00100001" }
    LDX #$00                    ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100011" }
    ADC ($80,X)                 ;@expected{ "A":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"INX" }
    LDX #$02                    ;@expected{ "X":"0x02", "NV-BDIZC":"0b00100000" }
    ADC ($80,X)                 ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100001", "addressing_mode":"INX" }
    CLC                         ;@expected{ "NV-BDIZC":"0b10100000" }
    LDX #$04                    ;@expected{ "X":"0x04", "NV-BDIZC":"0b00100000" }
    ADC ($80,X)                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b01100011", "addressing_mode":"INX"}

    CLV                         ;@expected{ "NV-BDIZC":"0b00100011" }
    CLC                         ;@expected{ "NV-BDIZC":"0b00100010" }

    ; indirect,Y mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    SEC                         ;@expected{ "NV-BDIZC":"0b00100001" }
    LDY #$00                    ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100011" }
    ADC ($80),Y                 ;@expected{ "A":"0xFF", "NV-BDIZC":"0b10100000", "addressing_mode":"INY" }
    LDY #$01                    ;@expected{ "Y":"0x01", "NV-BDIZC":"0b00100000" }
    ADC ($80),Y                 ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100001", "addressing_mode":"INY" }
    CLC                         ;@expected{ "NV-BDIZC":"0b10100000" }
    LDY #$02                    ;@expected{ "Y":"0x02", "NV-BDIZC":"0b00100000" }
    ADC ($80),Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b01100011", "addressing_mode":"INY"}

    CLV                         ;@expected{ "NV-BDIZC":"0b00100011" }
    CLC                         ;@expected{ "NV-BDIZC":"0b00100010" }

sbc_binary_test:
    ; immediate mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    SBC #$11                    ;@expected{ "A":"0xFE", "NV-BDIZC":"0b10100001", "addressing_mode":"IMM" }
    SBC #$7F                    ;@expected{ "A":"0x7F", "NV-BDIZC":"0b01100000", "addressing_mode":"IMM" }
    SBC #$7E                    ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"IMM"}

    ; zero page mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    SBC $60+0                   ;@expected{ "A":"0xFE", "NV-BDIZC":"0b10100001", "addressing_mode":"ZP" }
    SBC $60+1                   ;@expected{ "A":"0x7F", "NV-BDIZC":"0b01100000", "addressing_mode":"ZP" }
    SBC $60+2                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZP"}

    ; zero page,X mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    LDX #$00                    ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010" }
    SBC $60,X                   ;@expected{ "A":"0xFE", "NV-BDIZC":"0b10100001", "addressing_mode":"ZPX" }
    LDX #$01                    ;@expected{ "X":"0x01", "NV-BDIZC":"0b00100001" }
    SBC $60,X                   ;@expected{ "A":"0x7F", "NV-BDIZC":"0b01100000", "addressing_mode":"ZPX" }
    LDX #$02                    ;@expected{ "X":"0x02", "NV-BDIZC":"0b01100000" }
    SBC $60,X                   ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ZPX"}

    ; absolute mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    SBC $0060+0                 ;@expected{ "A":"0xFE", "NV-BDIZC":"0b10100001", "addressing_mode":"ABS" }
    SBC $0060+1                 ;@expected{ "A":"0x7F", "NV-BDIZC":"0b01100000", "addressing_mode":"ABS" }
    SBC $0060+2                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABS"}

    ; absolute,X mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    LDX #$00                    ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010" }
    SBC $0060,X                 ;@expected{ "A":"0xFE", "NV-BDIZC":"0b10100001", "addressing_mode":"ABX" }
    LDX #$01                    ;@expected{ "X":"0x01", "NV-BDIZC":"0b00100001" }
    SBC $0060,X                 ;@expected{ "A":"0x7F", "NV-BDIZC":"0b01100000", "addressing_mode":"ABX" }
    LDX #$02                    ;@expected{ "X":"0x02", "NV-BDIZC":"0b01100000" }
    SBC $0060,X                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABX"}

    ; absolute,Y mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    LDY #$00                    ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100010" }
    SBC $0060,Y                 ;@expected{ "A":"0xFE", "NV-BDIZC":"0b10100001", "addressing_mode":"ABY" }
    LDY #$01                    ;@expected{ "Y":"0x01", "NV-BDIZC":"0b00100001" }
    SBC $0060,Y                 ;@expected{ "A":"0x7F", "NV-BDIZC":"0b01100000", "addressing_mode":"ABY" }
    LDY #$02                    ;@expected{ "Y":"0x02", "NV-BDIZC":"0b01100000" }
    SBC $0060,Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"ABY"}

    ; indirect,X mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    LDX #$00                    ;@expected{ "X":"0x00", "NV-BDIZC":"0b00100010" }
    SBC ($90,X)                 ;@expected{ "A":"0xFE", "NV-BDIZC":"0b10100001", "addressing_mode":"INX" }
    LDX #$02                    ;@expected{ "X":"0x02", "NV-BDIZC":"0b00100001" }
    SBC ($90,X)                 ;@expected{ "A":"0x7F", "NV-BDIZC":"0b01100000", "addressing_mode":"INX" }
    LDX #$04                    ;@expected{ "X":"0x04", "NV-BDIZC":"0b01100000" }
    SBC ($90,X)                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"INX"}

    ; indirect,X mode
    LDA #$10                    ;@expected{ "A":"0x10", "NV-BDIZC":"0b00100000" }
    LDY #$00                    ;@expected{ "Y":"0x00", "NV-BDIZC":"0b00100010" }
    SBC ($90),Y                 ;@expected{ "A":"0xFE", "NV-BDIZC":"0b10100001", "addressing_mode":"INY" }
    LDY #$01                    ;@expected{ "Y":"0x01", "NV-BDIZC":"0b00100001" }
    SBC ($90),Y                 ;@expected{ "A":"0x7F", "NV-BDIZC":"0b01100000", "addressing_mode":"INY" }
    LDY #$02                    ;@expected{ "Y":"0x02", "NV-BDIZC":"0b01100000" }
    SBC ($90),Y                 ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010", "addressing_mode":"INY"}

adc_decimal_test:

; TODO

sbc_decimal_test:

; TODO

    BRK                         ;@halt



