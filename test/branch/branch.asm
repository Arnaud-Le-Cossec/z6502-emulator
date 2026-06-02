; @test{ "name": "branch instructions test" }               
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

; Instruction tested: BCC, BCS, BEQ, BNE, BPL, BMI, BVC, BVS

; COMPILER PARAMETERS *********************************** Built with ACME v0.91
; CPU target
!cpu 6502
; Set PC
*= 0x0000
; ********************************************************* COMPILER PARAMETERS

p0:
    NOP         ;@expected{ "PC":"0x0000", "NEXT":"0x0001", "A":"0x00", "X":"0x00", "SP":"0xFF", "NV-BDIZC":"0b00100000" }
    ; BCC condition true
    BCC p1      ;@expected{ "PC":"0x0001", "NEXT":"0x0010" }

*= 0x0010
p1:
    SEC         ;@expected{ "PC":"0x0010", "NV-BDIZC":"0b00100001" }
    ; BCC condition false
    BCC trap    ;@expected{ "NEXT":"0x0013" }
    ; BCS condition true
    BCS p2      ;@expected{ "NEXT":"0x0020" }

*= 0x0020
p2:
    CLC         ;@expected{ "PC":"0x0020", "NV-BDIZC":"0b00100000" }
    ; BCS condition false
    BCS trap    ;@expected{ "NEXT":"0x0023" }
    LDA #$0     ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010" }
    ; BEQ condition true
    BEQ p3      ;@expected{ "NEXT":"0x0030" }

*= 0x0030
p3:
    LDA #$1     ;@expected{ "A":"0x01", "NV-BDIZC":"0b00100000" }
    ; BEQ condition false
    BEQ trap    ;@expected{ "NEXT":"0x0034" }
    ; BNE condition true
    BNE p4      ;@expected{ "NEXT":"0x0040" }

*= 0x0040
p4:
    LDA #$0    ;@expected{ "A":"0x00", "NV-BDIZC":"0b00100010" }
    ; BNE condition false
    BNE trap   ;@expected{ "NEXT":"0x0044" }
    ; BPL condition true
    BPL p5     ;@expected{ "NEXT":"0x0050" }

*= 0x0050
p5:
    LDA #$80   ;@expected{ "A":"0x80", "NV-BDIZC":"0b10100000" }
    ; BPL condition false
    BPL trap   ;@expected{ "NEXT":"0x0054" }
    ; BMI condition true
    BMI p6     ;@expected{ "NEXT":"0x0060" }

*= 0x0060
p6:
    LDA #$7F   ;@expected{ "A":"0x7F", "NV-BDIZC":"0b00100000" }
    ; BMI condition false
    BMI trap   ;@expected{ "NEXT":"0x0064" }
    ; BVC condition true
    BVC p7     ;@expected{ "NEXT":"0x0070" }

*= 0x0070
p7:
    LDA #$FF   ;@expected{ "A":"0xFF", "NV-BDIZC":"0b10100000" }
    PHA        ;@expected{ "SP":"0xFE" }
    PLP        ;@expected{ "SP":"0xFF", "NV-BDIZC":"0b11101111" }
    ; BVC condition false
    BVC trap   ;@expected{ "NEXT":"0x0076" }
    ; BVS condition true
    BVS p8     ;@expected{ "NEXT":"0x0080" }

*= 0x0080
p8:
    CLV         ;@expected{ "PC":"0x0080", "NV-BDIZC":"0b10101111" }
    ; BVS condition false
    BVS trap    ;@expected{ "NEXT":"0x0083" }

; From now on, we go backward

    BCS p9      ;@expected{ "NEXT":"0x0078" }

*= 0x0078
p9:
    CLC         ;@expected{  "NV-BDIZC":"0b10101110" }
    BCC p10     ;@expected{ "NEXT":"0x0068" }


*= 0x0068
p10:
    BEQ p11     ;@expected{ "NEXT":"0x0058" }

*= 0x0058
p11:
    LDA #$1    ;@expected{ "A":"0x01", "NV-BDIZC":"0b00101100" }
    BNE p12     ;@expected{ "NEXT":"0x0048" }

*= 0x0048
p12:
    BPL p13     ;@expected{ "NEXT":"0x0038" }

*= 0x0038
p13:
    LDA #$80   ;@expected{ "A":"0x80", "NV-BDIZC":"0b10101100" }
    BMI p14     ;@expected{ "NEXT":"0x0028" }

*= 0x0028
p14:
    BVC p15     ;@expected{ "NEXT":"0x0018" }

*= 0x0018
p15:
    LDA #$FF   ;@expected{ "A":"0xFF", "NV-BDIZC":"0b10101100" }
    PHA        ;@expected{ "SP":"0xFE" }
    PLP        ;@expected{ "SP":"0xFF", "NV-BDIZC":"0b11101111" }
    BVS p16     ;@expected{ "NEXT":"0x0008" }

*= 0x0008
p16:
    BRK         ;@halt

trap:
    BRK         ;@throw{ "message": "Branch trap" }