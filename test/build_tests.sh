#!/usr/bin/env bash
                  
#   _____ ___ ___ ___ ___ 
#  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - AUTOMATED TEST SCRIPT
#  |   __| . |_  | | |  _|     Copyright (C) 2026 - Arnaud LE COSSEC
#  |_____|___|___|___|___|     version 1.0.0
#                     
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the MIT License.
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  MIT License for more details.    


#acme --cpu 6502 -o op_adc/op_adc.bin op_adc/op_adc.asm &&\
acme --cpu 6502 -o misc/misc.bin misc/misc.asm &&\
acme --cpu 6502 -o flags/flags.bin flags/flags.asm &&\
acme --cpu 6502 -o stack/stack.bin stack/stack.asm &&\
acme --cpu 6502 -o jump/jump.bin jump/jump.asm &&\
acme --cpu 6502 -o branch/branch.bin branch/branch.asm &&\
acme --cpu 6502 -o compare/compare.bin compare/compare.asm &&\
acme --cpu 6502 -o bitwise/bitwise.bin bitwise/bitwise.asm &&\
acme --cpu 6502 -o shift/shift.bin shift/shift.asm &&\
acme --cpu 6502 -o access/access.bin access/access.asm &&\
acme --cpu 6502 -o transfer/transfer.bin transfer/transfer.asm &&\
acme --cpu 6502 -o arithmetic/arithmetic.bin arithmetic/arithmetic.asm &&\
acme --cpu 6502 -o arithmetic-decimal/arithmetic-decimal.bin arithmetic-decimal/arithmetic-decimal.asm