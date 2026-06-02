#!/usr/bin/python3

#   _____ ___ ___ ___ ___ 
#  |__   |  _|  _|   |_  |     Z6502 CPU Emulator - INSTRUCTION TEST ENGINE
#  |   __| . |_  | | |  _|     Copyright (C) 2026 - Arnaud LE COSSEC
#  |_____|___|___|___|___|     version 1.0.0
#                     
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the MIT License.
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  MIT License for more details.  

# INCLUDES ********************************************************************
import sys
import subprocess
import re
import json
# ******************************************************************** INCLUDES

# CONSTANTS *******************************************************************
text_RED    = "\033[31m"
text_GREEN  = "\033[32m"
text_YELLOW = "\033[33m"
text_RESET  = "\033[0m"

testOpExpressions = [
    (r"@test\s*\{.*\}", "TEST_TAG"),
    (r"@expected\s*\{.*\}", "EXPECTED_TAG"),
    (r"@halt", "HALT_TAG"),
    (r"@\+\d*", "ADVANCE_TAG"),
    (r"@-\d*", "REWIND_TAG"),
    (r"@show", "SHOW_TAG"),
    (r"@throw\s*\{.*\}", "THROW_TAG")
]
# ******************************************************************* CONSTANTS

# LOCAL CLASSES ***************************************************************

class EmuState:
    def __init__(self, index=None, state=None):
        self.index = index
        self.state = state

class EmuStates:
    def __init__(self):
        self.states = []
        self.index = 0

    def parse(self, emulator_output):
        '''
        Main parser function:
        Creates an EmuState for every line of the input file
        The EmuState are composed of:
            - index (cpu cycle index)
            - state (the state of the emulated machine at that cpu cycle)
        SEE EmuState for more info
        '''
        for line in emulator_output.splitlines():
            # if line is not json formatted, discard it
            try:
                self.states.append(EmuState(index=self.index, state=json.loads(line)))
                self.index += 1
            except json.JSONDecodeError:
                pass

        return self.states

class TestOp:
    '''
    Our token definition:
    lexem (tag and value) + position in the program raw text
    Parameters
    ----------
    tag: string
        Name of the lexem's type, e.g. IDENTIFIER
    value: string
        Value of the lexem,       e.g. integer1
    position: integer tuple
        Tuple to point out the lexem in the input file (line number, position)
    '''
    def __init__(self, tag=None, value=None, position=None):
        self.tag      = tag
        self.value    = value
        self.position = position

    def __repr__(self):
        return self.tag

class TestOps:
    def __init__(self, test_op_list=None):
        self.test_op_list = test_op_list if test_op_list is not None else []
        self.test_op_idx = 0

    # Parser function

    def parse(self, inputText):
        '''
        Main parser function:
        Creates a TestOp for every detected regular expression
        The TestOp are composed of:
            - tag
            - values
            - position
        SEE TestOp for more info
        '''
        # Crawl through the input file
        for lineNumber, line in enumerate(inputText):
            lineNumber += 1
            position = 0
            # Crawl through the line
            while position < len(line):
                match = None
                for testOpRegex in testOpExpressions:
                    pattern, tag = testOpRegex
                    regex = re.compile(pattern)
                    match = regex.match(line, position)
                    if match:
                        data = match.group(0)
                        op = TestOp(tag, data, [lineNumber, position])
                        self.test_op_list.append(op)
                        # Renew the position
                        position = match.end(0)
                        break
                if not match:
                    position += 1

        return self.test_op_list

    # Execution functions for each type of test operation

    def _exec_test_op(self, test_op):
        '''
        Prints test metadata
        '''
        print(f"Starting test: {test_op.value.split('@test')[1].strip()}")

    def _exec_halt_op(self):
        '''
        End of the test
        '''
        print("End of test reached. Stopping.")

    def _exec_expected_op(self, test_op, emu_state):
        '''
        Compares the expected state to the actual state
        The expected state is extracted from the test_op value, and the actual state is given as a parameter (emu_state)
        '''
        print(f"\tCheckpoint at index {self.test_op_idx} ... ", end="")
        expected_str = test_op.value.split("@expected")[1].split("{")[1].split("}")[0].strip()
        expected_state = json.loads(f"{{{expected_str}}}")

        # Compare the expected state to the actual state
        for expectation_key, expectation_value in expected_state.items():
            if expectation_key not in emu_state.state:
                print(f"Test failed at CPU cycle {self.test_op_idx}:")
                print(f"  Expected key '{expectation_key}' not found in actual state.")
                print(f"  Expected: {expected_state}")
                print(f"  Actual:   {emu_state.state}")
                return 1
            elif emu_state.state[expectation_key] != expectation_value:
                print(f"Test failed at CPU cycle {self.test_op_idx}:")
                print(f"  Expected '{expectation_key}': {expectation_value}")
                print(f"  Actual '{expectation_key}':   {emu_state.state[expectation_key]}")
                print(f"  Expected: {expected_state}")
                print(f"  Actual:   {emu_state.state}")
                return 1

        return 0
    
    def _exec_advance_op(self, test_op):
        '''
        Advances the cpu cycle index by a given number of cycles (default is 1)
        '''
        try:
            inc = int(test_op.value.split("@+")[1].split()[0].strip())
            self.test_op_idx += inc - 1
        except:
            #self.test_op_idx += 1
            pass

    def _exec_rewind_op(self, test_op):
        '''
        Rewinds the cpu cycle index by a given number of cycles (default is 1)
        '''
        try:
            dec = int(test_op.value.split("@-")[1].split()[0].strip())
            self.test_op_idx -= dec + 1
        except:
            self.test_op_idx -= 2

    def _exec_show_op(self, emu_state):
        '''
        Shows the current state of the emulator
        '''
        print(f"\tCurrent state at index {self.test_op_idx}:")
        print(f"\t{emu_state.state}")

    def _exec_throw_op(self, test_op):
        '''
        Throws an error with a given message and fails the test
        '''
        message = test_op.value.split("@throw")[1].split("{")[1].split("}")[0].strip()
        print(f"{text_RED}Test failed at CPU cycle {self.test_op_idx}: {message}{text_RESET}")
        return 1

    # Main runner function

    def run(self, emu_states:EmuStates):
        '''
        Main runner function:
        Runs the test by comparing the expected state at each checkpoint to the actual state at the corresponding cpu cycle index
        SEE EmuState and EmuStates for more info
        '''
        self.test_op_idx = 0
        emu_state_idx = 0
        while self.test_op_idx < len(self.test_op_list):
            test_op = self.test_op_list[self.test_op_idx]
            print("\t\t",test_op, self.test_op_idx, emu_state_idx)

            if test_op.tag == "TEST_TAG":
                self._exec_test_op(test_op)

            elif test_op.tag == "HALT_TAG":
                self._exec_halt_op()
                break

            elif test_op.tag == "EXPECTED_TAG":
                if self._exec_expected_op(test_op, emu_states.states[emu_state_idx]) != 0:
                    return 1

                if self.test_op_list[self.test_op_idx+1].tag != "ADVANCE_TAG" and self.test_op_list[self.test_op_idx+1].tag != "REWIND_TAG":
                    emu_state_idx += 1

                print(f"{text_GREEN}passed{text_RESET}")

            elif test_op.tag == "ADVANCE_TAG":
                self._exec_advance_op(test_op)
                emu_state_idx += 1

            elif test_op.tag == "REWIND_TAG":
                self._exec_rewind_op(test_op)
                emu_state_idx += 1
            
            elif test_op.tag == "SHOW_TAG":
                self._exec_show_op(emu_states.states[emu_state_idx])

            elif test_op.tag == "THROW_TAG":
                self._exec_throw_op(test_op)
                return 1

            self.test_op_idx += 1

        return 0



# *************************************************************** LOCAL CLASSES

# MAIN ************************************************************************

if __name__ == "__main__":

    test_ops = TestOps()
    emu_states = EmuStates()

    # Check command line arguments
    if len(sys.argv) != 4:
        print("Usage: python3 unit_test.py <path_to_z6502_emulator> <path_to_test_binary> <path_to_debug_source_asm>")
        sys.exit(1)

    Z6502 = sys.argv[1]
    TEST_BINARY = sys.argv[2]
    DEBUG_SOURCE = sys.argv[3]

    # parse the debug source file
    with open(DEBUG_SOURCE, "r") as debug_file:
        test_op_list = test_ops.parse(debug_file)

    # run the emulator
    try:
        result = subprocess.run([Z6502, "-v", "-j", "-f 0", TEST_BINARY], capture_output=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running Z6502 emulator: {e}")
        print(f"Emulator output: \n{e.stdout.decode()}")
        print(f"Emulator error: {e.stderr.decode()}")
        sys.exit(1)

    # parse the emulator output
    emu_states.parse(result.stdout)

    #for state in emu_states.states:
    #    print(state.index, state.state)
    #
    #i = 0
    #for debug_op in debug_ops.debug_op_list:
    #    print(i, debug_op)
    #    i += 1

    # run the tests
    if test_ops.run(emu_states):
        print(f"{text_RED}Some tests failed.{text_RESET}")
        sys.exit(1)
    else:
        print(f"{text_GREEN}All tests passed.{text_RESET}")
        sys.exit(0)




# ************************************************************************ MAIN