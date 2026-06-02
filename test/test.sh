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

# find the z6502_emulator executable
if [ -f "../build/src/z6502_emulator" ]; then
    Z6502="../build/src/z6502_emulator"
else
    echo "Error: z6502_emulator executable not found. Please build the project first."
    exit 1
fi

# run the tests
TESTS=(
    "misc"
    "flags"
    "stack"
    "jump"
    "branch"
)

for TEST in "${TESTS[@]}"; do
    echo "Running $TEST..."
    python3 test_engine.py "$Z6502" "$TEST/$TEST.bin" "$TEST/$TEST.asm"
    if [ $? -ne 0 ]; then
        echo "Test $TEST failed."
        exit 1
    else
        echo "Test $TEST passed."
    fi
done
