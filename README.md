# Z6502 EMULATOR

Another 6502 CPU instruction set simulator, written in C++

## Build

1. Create a build directory:

   ```bash
   mkdir build && cd build
   ```

2. Run CMake to configure the project:

   ```bash
   cmake -S . -B ./build
   ```

3. Build the project:

   ```bash
   cmake --build ./build
   ```

## Usage

```bash
./z6502_emulator [-v] [-j] [-b] [-B] [-s] [-f frequency] ROM_file
```

* `-v` **Verbose:** Dump CPU status in the console
* `-j` **JSON:** Output CPU state in JSON format (only with -v)
* `-b` **Stop-on-brk:** Stop on BRK instruction (default)
* `-B` **No-stop-on-brk:** Continue execution on BRK instruction
* `-s` **Step:** Run CPU in step mode, waiting user input between each instruction. If ommited, clock mode is used
* `-f frequency` **Frequency:** Specify the speed of the CPU in clock mode (Hz). Default is 1 Hz. Set to 0 Hz for free running
* `ROM_File` **Program file** Path to the executable file (PseudoBin format)

### Example:

Example command in **Step Mode** and **Verbose**:

```bash
./build/src/z6502_emulator -v -s TEST/mem_test/mem.bin TEST/mem_test/data.bin
```

## Run tests

```bash
./test/test.sh
```

For more details, see [test instructions](./test/README.md)

## Instruction set

See [CPU datasheet](./doc/mos_6500_mpu_preliminary_may_1976.pdf)