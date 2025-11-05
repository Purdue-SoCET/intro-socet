# Systems Lab 2

## Before you start
### Definitions
- Driver: Piece of software responsible for interacting with a hardware device, and providing a higher-level API to programmers. Example: A UART driver with a "send" API that sends a whole string of characters.

### Review: MMIO
Memory-Mapped I/O (MMIO) is a paradigm for interacting with I/O devices where devices are assigned a range of addresses, and reads/writes to these addresses will be interpreted by the devices as various commands. This allows CPUs (and any other bus manager) to easily perform I/O operations via typical load/store instructions, rather than requiring special-purpose instructions. As an example, the next section will walk through a simple GPIO driver, exposing an API that lets users set certain pins to specific values.

### `volatile`
In C, the `volatile` keyword is a *type qualifier* that informs the compiler a specific value may change *outside of the control of the program*. This means that a compiler may not make certain assumptions about the data: for example, it cannot perform *register allocation*, where a frequently-accessed variable is kept in a register to reduce the amount of loads/stores, and instead must load and store data explicitly, every time. This keyword is intended to support MMIO, as I/O devices require load/store operations to work correctly, and the values read from the same location may change over time even without the program interfering (e.g. a timer counting up each cycle). 

Here's a short example of using a volatile variable:
```c
volatile uint32_t *my_accelerator_address = 0xCAFE0000;
uint32_t current_value = *my_accelerator_address; // Reads data from the device
*my_accelerator_address = 0xAABBCCDD;             // Writes data into the device
```
**Warning**: `volatile` has an *extremely* narrow use case! In particular, it should never be used for thread synchronization, *even for interrupt handlers on the same device* (you need atomics).

> Question 1: Assume a [FIFO](https://en.wikipedia.org/wiki/FIFO_(computing_and_electronics)) (first-in, first-out style queue) has separate read data, read enable, and write data registers in its address space. The read data register returns the head of the FIFO, the read enable register pops the head from the FIFO, and the write data register pushes a value into the tail of the FIFO. Is it sufficient to leave any of these registers without `volatile` qualifiers? Why/why not?

### A GPIO Driver
As an example, let's look through a simple GPIO driver for AFT-dev. First, here is the *memory map* for the GPIO. Note that the addresses are *offsets* from a base address, e.g. the `data` register is at address `BASE + 0x0`. For AFT-dev, `BASE` is `0x80000000`.

| Offset | Register | Description |
---------|----------|--------------
0x0      |  `data`  |  Current state of GPIO pins, 1 bit per pin
0x4      |  `ddr`   | Data Direction: `0` indicates input, `1` indicates output, 1 bit per pin
0x8      |  `ier`   | Interrupt Enable Register: Setting bit `n` to `1` enables interrupts on pin `n`. Must be used with corresponding `per`/`ner` bit to allow an interrupt!
0xC      |  `per`   | Positive Edge Register: Setting bit `n` to `1` enables a rising-edge interrupt for pin `n`
0x10     |  `ner`   | Negative Edge Register: Similar to `per`, but for falling-edge inputs
0x14     |  `icr`   | Interrupt Clear Register: Writing a `1` to bit `n` of this register clears the corresponding pending interrupt. Hardware will reset the value to 0 after clearing the pending interrupt.
0x18     |  `isr`   | Interrupt Status Register: A set bit `n` indicates that an interrupt is pending for pin `n`


There are many ways to write a driver, depending on the API you wish to present to the user. One goal (often) of a driver is to hide some implementation details and require users to go through your API (encapsulation), so for this design, we will use a C-struct + an *opaque pointer* to hide the definition of the struct from the users, indicating that they should not rely on the specific implementation, but rather make use of our API functions.

Let's define the basic interface we want our users to use:

```c
// gpio.h

// Opaque struct that does not provide it's definition in the header file, and
// hides its implementation from the user. This means that users must use
// pointers to interact with this object, and that we are free to change the
// memory map of the GPIO device transparently.
typedef struct GPIO GPIO;

// Returns a pointer to the GPIO peripheral
GPIO *getGpioHandle();

// Set the direction of a certain pin.
void gpioPinSetDir(GPIO *gpio, uint8_t pin, bool output);

// Set the output of a certain pin. Has no effect if the pin is not in output mode.
void gpioPinWrite(GPIO *gpio, uint8_t pin, bool val);

// Get the value on a certain pin.
bool gpioPinRead(GPIO *gpio, uint8_t pin);

...

```

Now, let's go ahead and provide the implementations of these functions

```c
// gpio.c

// We'll define the GPIO struct to match the memory map of the device. This
// allows us to treat the BASE pointer as a pointer to this struct.
struct GPIO {
    volatile uint32_t data;
    volatile uint32_t ddr;
    ...
};

GPIO *getGpioHandle() {
    // We can just cast the BASE address to GPIO * since we defined GPIO to
    // match the memory map of the peripheral.
    return (GPIO *)BASE;
}

void gpioPinSetDir(GPIO *gpio, uint8_t pin, bool output) {
    if (output) {
        gpio->ddr |= 1 << pin;
    } else {
        gpio->ddr &= ~(1 << pin);
    }
}

void gpioPinWrite(GPIO *gpio, uint8_t pin, bool val) {
    if (val) {
        gpio->data |= 1 << pin;
    } else {
        gpio->data &= ~(1 << pin);
    }
}

bool gpioPinRead(GPIO *gpio, uint8_t pin) {
    return (gpio->data >> pin) & 0x1;
}
```

####


## Designing, Implementing, and Testing a Peripheral for AFT-dev
Now that you've learned about MMIO and interacted with existing peripherals, you could create your own hardware peripheral to add into the chip. You should have already created an RTL diagram for your peripheral as part of Systems Lab 1.

### Step 1: Implement your accelerator
First, decide on the interface for your accelerator. How many control/status/data registers does it need, and what do they do? Common things to provide registers for would be: input data, output data, a "control" register that selects what operation (if multiple) and tells the computation to start, and a status register to show that the computation is done. You will also need to define the offsets. For simplicity, make all your register start at multiples of 4 bytes (this is the size of a word for 32-bit).

1. Navigate to `../AFT-dev/intro_systems_accelerator`. This is where you will implement your peripheral. If this folder does not exist, run `git pull --recurse-submodules` outside of the AFT-dev directory.
2. Implement your peripheral in `src/intro_systems_accelerator.sv`. You will use `bus_protocol_if.peripheral_vital` interface to interact with the system bus. You can see the definition of that interface in `AFT-dev/bus-components/generic/bus_protocol_if/bus_protocol_if.sv`. This is very similar to the `memory_if` you used earlier in Digital Lab 3. There are multiple TODO comments inside the interface file. **You can ignore them.**
3. Write a few test cases in `tb/tb_intro_systems_accelerator.sv` to test your design. You can build your design using the command `fusesoc --cores-root .. run --build --target sim socet:aft:intro_systems_accelerator`, and you can run it using `./build/socet_aft_intro_systems_accelerator_0.0.1/sim-verilator/Vtb_intro_systems_accelerator`.

### Step 2: Integrate into AFT-dev

1. All of the boilerplate to integrate your design has already been added into the AFT-dev submodule
2. Open `../AFT-dev/top_level/src/aftx07_mmap.vh`.

> Question 2: What is the `INTRO` module's AHB index? What is it's "BASE" address (hint: look at `AHB_MAP`)?

3. Build AFT-dev, now with your peripheral implemented, using `build.sh` in the top AFT-dev directory (`/AFT-dev/`).

### Step 3. Write a C driver for your accelerator

1. Fill out `src/accelerator.h` with some helper functions. For example, if you are doing the population count accelerator, you'll need to read and write to your peripheral to perform the population count. Make a wrapper function that takes in a 32 bit number, writes it to your accelerator, and then returns the value that it reads from the output register.
2. Fill out `src/accelerator.c` with all of the driver functions your defined earlier.

### Step 4. Benchmark your accelerator

**Instructions if you implemented the population count accelerator:**
1. Copy over your `popcnt.S` from the `lab1` folder to the `src` folder.
2. Fill in `popcnt_hw` in `src/main.c`. This function wraps your accelerator driver to match the interface of the `popcnt` function (`uint8_t popcnt(uint32_t a)`).
3. Create the build directory in your lab 2 directory using `mkdir build && cd build`, generate the build files using `cmake3 ..`, and build your files using `make`.
4. If you edited your .sv file at all, make sure to rebuild using build.sh in the top AFT-dev directory (/AFT-dev/).
5. Run AFT-dev and ensure that your accelerator properly works with `../../AFT-dev/aft_out/socet_aft_aftx07_2.0.0/sim-verilator/Vaftx07`.

**Instructions if you implemented a custom accelerator:**
1. Change the `POPCNT_ACCELERATOR` macro in `src/main.c` to be 0.
2. Write some C code that uses your accelerator. Write some software which is equivalent to your accelerator. Test it and determine what the speedup of your accelerator is.
3. Follow the steps 3 and 4 for the population count accelerator.

> Question 3: What is the variance of your population count accelerator?

> Question 4: What is the speedup of your accelerator vs your software implementations? (Hint: Speedup is t_old / t_new)

> Question 5: What are the benefits of a hardware accelerator? What are some drawbacks?
