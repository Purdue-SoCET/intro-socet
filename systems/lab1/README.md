# Systems Lab 1
## Before Starting
This lab is primarily a *software* lab, specifically about writing C and RISC-V assembly code. This document assumes some familiarity with C, but none with RISC-V. In this first section, we will introduce many of the instructions that you will use. However, the definitive instruction listing can be found at the [RISC-V Website](https://riscv.org/technical/specifications/).

Before continuing, make sure that you are on version 2.3 of fusesoc. You can do so by typing "fusesoc --version". If it's below 2.3, make sure you're not in a virtual environment by typing "deactivate" and type in "pip3 install --user fusesoc".

### Basics of RISC-V
RISC-V is an open standard for an instruction set architecture (ISA). RISC-V has 32 general-purpose registers, and register 0 (x0, zero) is hard-wired to 0. The registers can be referred to as xN, for the Nth register, or by their [ABI Names](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf). For these examples, we will use the ABI names, since they are more descriptive and easier to read.

> Note: An Application Binary Interface (ABI) describes a protocol, or contract, for how code should inter-operate. Things like the calling convention (where data is located when you call a function, where return values should live, whose responsibility it is to save register values), sizes of different types (how many bits is an `int`? Depends on which computer you're using!), alignment requirements (e.g. an alignment of 4 means that the address is a multiple of 4), and more. You don't need to be familiar with any particular ABI details for this lab, but the word will come up when doing this kind of programming!

**Definitions**:
1. Caller: The piece of code that calls a function
2. Callee: The function that was called
3. Caller-saved: Registers whose values are not guaranteed to be preserved across function calls. That is, if you call a function, caller-saved registers may be modified by the callee. If the caller requires those values to be saved, it must store them into memory somewhere (typically on the stack) before calling the function, and load them back into the registers after the function returns.
4. Callee-saved: Registers whose values *must* be preserved accross function calls. This means that if the callee wants to make use of these registers, they must save their value (typically on the stack) before using them, and restore their value before returning.

A quick summary of ABI register names:
- zero (x0): hard-wired zero
- ra (x1): return address (e.g. for function calls)
- sp (x2): stack pointer (callstack)
- gp (x3): global pointer, used for accessing global variables in compiled code from higher-level languages
- tp (x4): thread pointer, pointer to thread-local data
- t0-t6 (x5-x7, x28-x31): temporary registers, caller-saved
- s0-s11 (x8-x9, x18-x27): saved registers, callee-saved. x8 is also the (optional) frame pointer.
- a0-a7: argument registers. Hold arguments for function calls. a0 and a1 also serve to hold return values from a function.

For the full details, see the [RISC-V UABI Documents](https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-abi.adoc), specifically the "calling convention" document.


### Interrupts and Exceptions
An interrupt is a hardware-initiated transfer of control that is usually *asychronous*; that is, it can happen at any time, and the currently-executing application has no knowledge of when an interrupt will occur. When an interrupt occurs, the CPU will jump to a pre-defined address (an *interrupt vector*), save the PC of the location where it was when the interrupt happened (i.e. where to return to after the interrupt handler is done) based on the condition that caused it, and begin executing code here (the *interrupt handler*). 

Interrupts can be caused by various hardware peripherals, and in some architectures (RISC-V included) by a CPU directly. For example, things like:
- A hardware timer running out
- A CPU core interrupting another CPU core
- An external peripheral (e.g. USB) completing an action

In RISC-V, interrupt handling is split between the CPU and the *interrupt controller*, a dedicated piece of hardware that manages interrupts and notifies the CPU of interrupt conditions.

> Note: An *exception* is similar to an interrupt, only it is *synchronous* with the executing application. An exception is typically due to an error condition with the running program, such as a program attempting to access a bad memory location (segfault), executing an illegal instruction, a page fault, or even a *syscall*. Exceptions are handled in the same way as interrupts in RISC-V and many other ISAs.

On the CPU side, there are a number of *Control & Status Registers* (CSRs) that govern interrupt handling. Here is a subset of these registers:
- `mtvec`: Holds the base address of the interrupt *vector table*
- `mstatus.mie`: Holds control bits for many CPU functions. The `mie` bit determines whether interrupts are enabled/disabled globally.
- `mie`: Has a bit per interrupt source, that determines whether the specific interrupt is enabled or not. This is useful for filtering out sources of interrupts that you are not interested in. 
- `mip`: A bit per interrupt source, indicates that an interrupt is *pending*, e.g. the condition has occurred but has not been acknowledged
- `mepc`: The address you were executing at before the interrupt happened. This is where the CPU will return to when you exit the interrupt handler
- `mcause`: A unique value that tells you what caused the interrupt

To set up interrupts on a RISC-V CPU, you must set up `mtvec`, `mie`, and `mstatus.mie`. We won't go over the exact process in detail, but if you're interested, take a look at the code in `sw-tests/support`, which sets up interrupts.
> Note: Exceptions are always active (they do not require an enable bit). This is because most exceptions indicate an error condition that must be dealt with, such as an attempt to access a protected memory range, or executing an illegal instruction.

### RISC-V privilege basics 

The '`m`' prefix on these registers indicates the *privilege level* of the CPU. Machine ("M")-mode is the highest privilege, where firmware like a BIOS would run, and gives full access to the hardware. RISC-V also supports 2 more basic modes: Supervisor ("S") mode has less privilege than M-Mode, and is typically where a desktop OS kernel would run. S-mode comes with its own set of CSRs, most notably CSRs that control *virtual memory*. User "U"-mode is where applications can run and has the least privilege.

The privilege mode controls what instructions can be run by the executing code, which CSRs can be accessed, and even which memory regions can be accessed. For example, an application running in U-mode cannot alter the `mtvec` register to redirect interrupts to a new location: only M-mode software can do this, providing a level of security from malicious (or poorly-written) applications.

The privilege mode can be escalated using the `ecall` instruction, which causes a *synchronous* exception that goes to the next-highest mode. Symmetrically, each privilege mode (besides "U") has a special instruction `xret`, where `x` is the current mode (e.g. `mret` for M-mode) that lowers the privilege back to what it was before the last interrupt/exception and resumes the application at the address in the corresponding `xepc` register.
> It might seem strange that an instruction can escalate privilege mode; after all, if you can just upgrade your privilege, what is being protected?
>
> However, because `ecall` causes an *exception*, program control is transferred to an exception handler owned by software running in the next-higher privilege mode (e.g. OS, hypervisor, firmware); that is, the attacker can escalate the privilege mdoe, but cannot choose which code runs, and therefore cannot access any protected resource without permission from the OS.

For example, consider an application running in U-mode, and an OS running in S-mode. If the application requires access to a particular resource (e.g. more memory), it must use a *syscall*, which would be implemented by loading some arguments into the registers, then using `ecall` to enter the OS in S-mode. After doing the requested work, the OS will use the `sret` instruction to resume the application in U-mode.

## Writing code for AFT-dev
For this lab, you will write code that runs on AFT-dev (the latest SoCET chip). The chip will be simulated using Verilator.

### Step 1: Set up AFT-dev
To get started, clone the AFT-dev repository and follow its build instructions. If your account is set up properly, this should be as simple as:

1. Run `git submodule update --init` to pull in the `AFT-dev` (the chip) and `aft-femtokernel` (a small runtime kernel) submodules
2. Change directory into the AFT-dev folder by running `cd ../AFT-dev`
2. Run `setup.sh` to download the needed libraries and submodules
3. Run `build.sh` to build the Verilator simulation
4. Run `./aft_out/socet_aft_aftx07_2.0.0/sim-verilator/Vaftx07` to run the simulation. Note that the simulation needs a file named `meminit.bin` in the current directory. If you don't provide that, it will just run forever doing nothing, since the RAM is full of 0s.

There are many software tests you can run by navigating to the `sw-tests`
directory, building them with CMake, and copying the resulting `.bin` files
to the proper location. The steps to build something with CMake are shown below:

1. Run `cd sw-tests` to navigate to the directory with the CMakeLists.txt file (this is the build script for CMake projects)
2. Create and enter a build directory: `mkdir build && cd build`
3. Run CMake to generate the build files: `cmake3 ..`
4. Run the generated Makefile to build the project: `make`
5. Copy a ".bin" file to "meminit.bin": for example, `cp print_test.bin meminit.bin`
6. Run the simulator by running `../aft_out/socet_aft_aftx07_2.0.0/sim-verilator/Vaftx07`

### Step 2: Setup CMake

Next, we'll need to set up the build system for the code you'll be writing in this lab (make sure you're in the `systems/lab1` folder):

1. Create and enter a build directory: `mkdir build && cd build`
2. Run CMake to generate the build files: `cmake3 ..`
3. Run the generated Makefile to build the project: `make`

### Step 3: Simple Assembly
The file "src/asmHello.S" contains the code listed below. Open it up and fill in the "TODO" part with whatever message you want to write.

```asm
.extern print # declare external symbol to be resolved at link time

.global asmHello
asmHello:
    addi sp, sp, -16
    sw ra, 0(sp)
    la a0, message
    la a1, name
    call print
    lw ra, 0(sp)
    li a0, 0
    addi sp, sp, 16
    ret

.data
message:
.string "Hello, world! My name is: %s\n"
name:
.string "" # TODO: Your name here
```

Now, navigate to the build directory you created earlier and run `make` to build the code. It will produce an executable (ELF) file named `main.elf`.

You might see a lot of text fly by. This is invoking the compiler `gcc` to build the supporting library code, and your assembly code.
> Note: The GNU assembler is called `as`. However, `gcc` is smart enough to invoke `as` automatically for assembly files, so you can just compile everything with `gcc` and let it figure out what to do.

> All of the gcc/binutils programs for our RISC-V toolchain (programs that let you compile and inspect binaries) are prefixed by `riscv64-unknown-elf-`, e.g. `riscv64-unknown-elf-gcc`. This prefix indicates the *cross compiler toolchain* being used; that is, we're compiling code not for our native machine, but for a RISC-V machine. You can read more about these "target triples" on the [OSDev website](https://wiki.osdev.org/Target_Triplet).

After the `make` command completes, you should see a number of build artifacts. The `.elf` files are the binaries in ELF format, which is the default output of the compiler. This is the executable format for Linux machines (similar to EXE files on Windows and Mach-O for macOS). The `.bin` files also are program binaries, but they contain *only* the program data as raw binary (ELF files contain other metadata about your program). We have AFT-dev set up to use raw binaries right now, which is why this is needed. Make sure that you can see the files `main.elf`, `main.bin`, and `meminit.bin` in this directory.

Run the simulation with: `../../AFT-dev/aft_out/socet_aft_aftx07_2.0.0/sim-verilator/Vaftx07`. You should see your message printed to the screen!

> Note: You'll see some other prints. There is a small "kernel" that runs before your `main` code runs, which will set up some basic things on the system, and also provides the `print` function you used.

Let's look at what this did step-by-step.

Line 1: `.extern print` declares an external symbol named "print". This is just like the C statement `extern void print(const char *, ...)`, only in ASM, we don't have that type information. This line declares a symbol named `print` which is external to this file, so the linker knows to go look for this symbol elsewhere.

Line 2-3: `.global asmHello` indicates that the symbol `asmHello` should be made globally available; that is, if another piece of code wants to reference `asmHello`, the linker will use this symbol. If you don't mark something as `.global`, other files cannot see that symbol. This is like if assembly labels were `static` variables/functions in C. 

Line 4-5: This part uses `addi sp, sp, -16` to allocate space on the stack (by moving the stack pointer), then saves the value of `ra` (the return address) onto the stack using `sw ra, 0(sp)`. We plan on modifying `ra` later (thus losing our return address), so we need to save it now.

Line 6-7: The `la xN, symbol` instruction loads the address of a symbol into a register. These lines set `a0` and `a1` to the addresses of our message and name strings, respectively. (To be clear: `a0` and `a1` hold *pointers*, e.g. `char *` in C).
> Note: `la` is a so-called "pseudo-instruction", that was added to make programmer's lives easier. `la xN, symbol` loads the effective address of a given symbol into the register `xN`. Some architectures have the ability to load full-sized constants into registers (e.g. x86-64), but on RISC-V, this often must be done with a multi-instruction sequence. For example, to load the constant `0x80000001` into a register in RISC-V, you might do:
> ```
> lui x1, 0x80000 # "load-upper-immediate", set upper 20b of x1 to 0x80000, lower 12 to 0
> addi x1, x1, 1  # "add immediate", add "1" to the contents of x1
> ```
> However, if we only wanted to load `0x80000000`, it could be done with a single `lui`. RISC-V assembly has a pseudo-instruction `li` (load immediate), that the assembler will expand to the shortest possible sequence of instructions to build the immediate value. However, for symbols, we don't know their value until link time, so we cannot use `li`. The `la` instruction, on the other hand, defers the instruction selection for building this constant to link-time. Based on where the address is located in memory, the linker can choose whether it needs 2 instructions, or only a single instruction to build the desired constant value. The linker can also shuffle things around to optimize this process by locating things such that they can be reached with a single instruction from where they are used. This process is called *linker relaxation*. If you are interested, there's a [great blog post](https://www.sifive.com/blog/all-aboard-part-3-linker-relaxation-in-riscv-toolchain) from SiFive talking about this process.

Line 8: `call print` will call the print function that we declared `.extern`
> Note: `call` is a pseudo-instruction that expands to `jal ra, print`. `jal` is "jump-and-link", which makes the CPU jump to a specified address (`print`'s address), and save PC + 4 into the target register. In this case, the target register is `ra`, the ABI return address register. Saving PC + 4 allows us to resume from the instruction after the function call when we eventually return.

Line 9: `li a0, 0` loads 0 into the a0 register. This is setting up the return value of 0 for returning from `main`. If we don't do this, the calling code will think there is a problem (like in C, returning a non-zero code indicates an error occurred), and print a message like `Test Failed`.

Line 10-11: This section restores our old value of `ra`, in preparation to return from `main`. First, we reload `ra` with `lw ra, 0(sp)`. Then, we de-allocate our stack space by bumping the stack pointer back up, using `addi sp, sp, 16`.

Line 12: `ret`, the `return` instruction. This will return from our `asmHello` function. Note that this is where execution resumes after the `print` function call returns.
> Note: `ret` is another pseudo-instruction, that expands to `jr ra`. `jr` (Jump-Register) sets the program counter to the contents of the specified register. Here it uses `ra`, the ABI return address register.

Before continuing, let's inspect the output of the compiler. To do this, run the following command to disassemble the code:
```
riscv64-unknown-elf-objdump -d main.elf | less
```
You will see a lot of output and can scroll up and down using "f" and "b" respectively. You can also use the arrow keys. This is a *disassembly*, or human-readable printing of the machine code generated after compiling/assembling the input files. One thing of note here is that addresses are also assigned for all the code and data: this was done during the *linking* step. Try to find the code you wrote, which should be under the label `asmHello`. You should be able to see what the linker replaced your `la` instructions with!

> Question 1: Find our code in the output under the `asmHello` label. What did the `la` instructions become after compiling? Look in the disassembly.

### Step 4: More advanced assembly

Next we'll write some more advanced assembly to calculate the "population count" (or the number of bits set) in a 32 bit integer. An intuitive implementation of this algorithm is to loop through each bit of the integer and increment an accumulator if the bit is equal to 1.

Looping in assembly can be slightly unintuitive so let's take a look at an example where we add up all the elements of an `int` array. In C, this is pretty simple:

```c
uint8_t array[SIZE] = { ... };
...
uint32_t sum = 0;
for (int i = 0; i < SIZE; i++) {
    sum += array[i];
}
```

There are 4 parts to the loop here: the initializer (`int i = 0`), the condition (`i < SIZE`), the update (`i++`), and the body of the loop (`sum += arr[i];`). In asssembly, we can make the same loop by just translating the initializer, update, and body to assembly, and then branching on the inverted condition.

```asm
array:                  // Array definition
    ...

...

    la t0, array        // Load address of array into t0
    li t1, SIZE         // Load SIZE into t1
    li a0, 0            // Initialize a0 with the initial value of `sum` (this is not the initialization of `i`)
    li t2, 0            // Initialize t2 with our loop counter (`int i = 0`)
loop:
    bge t2, t1, done    // Condition to break out of the loop (`!(i < SIZE)`)
    add t3, t0, t2      // Index into array using t2
    lb t4, 0(t3)        // Read the value at array[i]
    add a0, a0, t4      // Add the value from array[i] to our accumulator
    addi t2, t2, 1      // Increment our loop counter (`i++`)
    j loop              // Unconditionally restart the loop
done:
    ...
```

> Question 2: Why do we need to invert the conditional in assembly?

> Question 3: Where are each of the 4 parts of the loop (in the C version) found in the assembly version (e.g. before loop, at the start of loop, in the middle of loop, at the end of loop)? Convince yourself why this makes sense.

#### Step 4a: Early exit population count

Fill out the `popcnt` assembly routine in the `src/popcnt.S` and try to exit early if there are no more ones in the input. Remember, the input `a` will be in the `a0` register, and you'll need to return your result in `a0` so the C code can properly use it. Go into the C file (`src/main.c`) and change the macro `STEP2` to equal 1. Recompile the binary (change directory to `build/` and run `make`) and run the simulator to test your `popcnt` funtion with some given inputs and expected outputs. When your function works correctly, it will print out the run time (in cycles) of each test case.

> Question 4: What is the instruction run time for the input 0x00000000 (the first input)? What about for 0xFFFFFFFF (the second input)? What is the calculated runtime variance of your function?

> Question 5: Look at line 33-35. What do these lines do? Why are they needed?

#### Step 4b: Timing-safe population count

If you properly implemented the previous function, you should see that the runtime variance is very high. This is due to the fact that we exit early if we detect there are no more 1s to count which improves our performance for a certain class of inputs. However, this performant implementation can leak some information to possible attackers because it's runtime is dependant on a certain characteristic of the input. If the attacker can measure how long the function takes for certain inputs, then they can extract information if the function is called with some protected data. Imagine if a step in processing of a password is to calculate the number of bits set in each letter, the attacker could figure out how many bits of a certain character in a password are set if they know for example, the runtime of an input with 3 bits set. This is called [timing side-channel attack](https://en.wikipedia.org/wiki/Timing_attack) because the timing of a function becomes a side-channel (unintended method of collecting information) which can be used as an attack vector in e.g. hacking. Let's implement a timing-safe version of the same function.

> Question 6: What class of inputs does the regular `popcnt` outperform `popcnt_secure`

> Question 7: What is the invariant you can exploit in `popcnt_secure`? (hint: what is a constant every time you call the function)

Implement the function `popcnt_secure` routine in `src/popcnt.S`. It has the same function signature as the previous routine. Change the `STEP3` macro in the C file to equal 1 and recompile the binary. Rerun the simulation. If the variance of your routine is over 50 cycles, analayze your implementation and improve it so that it is below 50.

> Question 8: What is the instruction run time for the input 0x00000000 (the first input)? What about for 0xFFFFFFFF (the second input)? What is the calculated runtime variance of your function?

> The TA answer using a loop takes around 271 cycles to execute with a variance of 18 cycles. Can you do better?

### Step 5: RTL Diagram
For the next lab, you will be designing a small hardware accelerator which will do the population count operation in hardware. For this lab's last task, draw the RTL diagram of this peripheral, and how you plan on making it accessible to the core. (Hint: use a bus-based MMIO interface, what registers will you need to make available to the bus)

If you would like to go above and beyond the given task, propose your own peripheral/accelerator to your TAs in office hours (or if you cannot make ANY office hours, then a group Teams message would be acceptable as well) and get approval before creating the RTL diagrams. If the project is deemed sufficiently advanced by your TAs, you may work with other students in your group. Some example ideas are given below:

#### Divisible-by-5 checker
Re-use the code from lab 2's FSM to perform divisibility checks on a 32b integer. This will require the following registers to be added:

- A data register (for 32b input)
- Result register (1/0 for divisible-by-5)
- Control register (writing a 1 starts the operation)
- Status register (0 for busy, 1 for done)

The usage would look like this:

1. Write a 32b value into the data register
2. Write a '1' into the control register to start
3. Wait for the status register to become '1'
4. Read the result register to see the output

This will require some extra hardware in addition to your FSM to create the registers, count how many bits have been shifted in, and actually perform the shifting.

#### Bit-manipulation
Implement a hardware accelerator for complex bit manipulation operations. You will need the following registers:

1. Data register (for 32b input)
2. Result register (32b output)
3. Operation register (for selecting an operation)
4. Status register (0/1 for busy/complete). Depending on your implementation, this may always be a 1 (e.g. if the computation is combinational logic).

You should support at least the following operations:

1. Count-leading-zeros: starting with the MSB, count the number of '0' bits until the first '1'. The result will be in the range 0-32.
2. Count-trailing-zeros: starting with the LSB, count the number of '0' bits until the first '1'. The result will be in the range 0-32.
3. Population count: count the number of '1' bits in the input. The result will be in the range 0-32
4. Parity check: count the number of '1' bits in the input. If this count is even, output a '1', otherwise output a '0'. The result will be either 0 or 1.

For the operation register, you will need to assign values to the different operations, e.g. 0 = CLZ, 1 = CTZ, etc. For values that fall outside the legal range, you can return '0'.

#### Other ideas
- Hardware Multiply-And-Accumulate (MAC): Computes a = a + (b x c). Have a "reset" that sets a = 0, then perform MAC operations on 2 input data values and accumulate in the "a" register. Make sure to have a reasonable multiplier design! (*not* purely combinational)
- Morse code generator: Create a bit string of 0s and 1s depending on the series of `char`s that are written to a certain address. You can assume only valid lowercase ASCII characters will be written. A 0 should represent a dot, and a 1 should represent a dash. You should support up to 32 dots or dashes. If you cannot insert a certain letter into your bitstring, the error signal of the bus should go high.

#### Your idea
If you have an idea you want to try, please talk to your TAs! You can do things like create devices with custom interrupts, have I/O pins on the chip, or even create a design that acts as a bus manager!
