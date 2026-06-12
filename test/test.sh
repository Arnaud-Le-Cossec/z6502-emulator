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

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# find the emulator executable
# use path from argument if provided, otherwise use default
if [ -n "$1" ]; then
    Z6502="$1"
else
    Z6502="$SCRIPT_DIR/../build/src/z6502_emulator"
fi

if [ -n "$2" ]; then
    TEST_ENGINE="$2"
else
    TEST_ENGINE="$SCRIPT_DIR/test_engine.py"
fi

# verify the file exists
if [ ! -f "$Z6502" ]; then
    echo "Error: emulator executable not found at '$Z6502'. Please build the project or provide the correct path."
    exit 1
fi

# run the tests
TESTS=(
    "misc"
    "flags"
    "access"
    "stack"
    "jump"
    "branch"
    "compare"
    "bitwise"
    "shift"
    "transfer"
    "arithmetic"
    "arithmetic-decimal"
)

for TEST in "${TESTS[@]}"; do
    echo "Running $TEST..."
    python3 $TEST_ENGINE "$Z6502" "$SCRIPT_DIR/$TEST/$TEST.bin" "$SCRIPT_DIR/$TEST/$TEST.asm"
    if [ $? -ne 0 ]; then
        echo "Test $TEST failed."
        exit 1
    else
        echo "Test $TEST passed."
    fi
done
