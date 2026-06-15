# Test

## Foreword

## Usage

To run the tests, execute the following script

```bash
./test.sh
```

## Compile tests

The tests here have been compiled with [ACME v0.91](https://web.archive.org/web/20150520143433/https://www.esw-heim.tu-clausthal.de/~marco/smorbrod/acme/). See also the [SourceForge page](https://sourceforge.net/projects/acme-crossass/).

If you have ACME installed, you can re-compile every test with the following script:

```bash
./build_tests.sh
```

## Test operators

In the `.asm` source files*, test operators can be placed to instruct the test engine what to do and what to expect from the emulator.

> **Notes**
> - Comments `;` do not interfere with the test operators
> - Test operators can be placed in any text files, but it is easier to have them next to the assembly instructions

Below are the possible test operators:

- `@test{JSON*}`: provide metadata to the test engine<br>
    JSON keys: 
    -  `name`: name of the test
- `@halt` : end the test
- `@throw{message}` : throw message and end the test. the test is marked as failed
- `@+` / `@+<integer>`: advance next / advance *`<integer>`* steps
- `@-` / `@-<integer>`: go back / go back *`<integer>`* steps
- `@show`: Show the emulator state. useful when debugging
- `@expected{JSON*}` : provide expected cpu state<br>
    JSON keys:
    - `PC`: program counter
    - `NEXT`: next program counter address
    - `A`: accumulator register value
    - `X`: X register value
    - `Y`: Y register value
    - `SP`: stack pointer register value
    - `NV-BDIZC`: status register value (byte representation): `N`=negative flag, `V`=overflow flag, `-`=not used (always 1), `B`=break flag, `D`=decimal mode, `I`=irq flag, `Z`=zero flag, `C`=carry flag
    - `opcode`: current instuction opcode
    - `mnemonic`: mnemonic of current instuction (string)
    - `addressing_mode`: addressing mode of current instuction (sting): `IMP`=Implied, `ACC`=Accumulator, `IMM`=Immediate, `ZP`=Zero Page, `ZPX`=Zero Page,X, `ZPY`=Zero Page,Y, `REL`=Relative, `ABS`=Absolute, `ABX`=Absolute,X, `ABY`=Absolute,Y, `IND`=Indirect, `INX`=X-indexed, indirect - aka (Indirect,X), `INY`=Indirect, Y-indexed - aka (Indirect),Y,
    - `cycles` : number of clock cycles spent on insctruction

Example:

```asm
; @test{ "name": "JSR instruction test" } 
jsr_absolute:
    JSR jsr_absolute_sub ;@expected{ "PC":"0x0200", "NEXT":"0x0300", "SP":"0xFD" } @+8
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

```

