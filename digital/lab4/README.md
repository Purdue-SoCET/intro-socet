# Digital Design Lab 4

## Contents
1. [Before you start](#before-you-start)
2. [Memory Copier](#memory-copier)

## Before you start

### SystemVerilog Interfaces
Interfaces in SystemVerilog are used to create logical "bundles" of signals, and specify their input/output relationship with respect to what devices are being connected. Interfaces have 2 major parts: signal declarations, and *modports*. The modports decide the orientation of the wires for each module that connects to the interface. You can read more about them at [ASIC World](http://www.asic-world.com/systemverilog/interface.html). Here are a few reasons interfaces can be useful:
1. Code reuse: many modules use similar or even standardize interfaces (e.g. AHB/APB components)
2. Simplicity and brevity in code: instead of passing in many signals manually when connecting modules, you can pass in just the single interface.
3. UVM testing uses "virtual interfaces" to access signals rather than loose signals.

As a simple example, consider the `memory_if` interface that will be used in the second part of the lab:
```sv
interface memory_if();
    logic wen, ren;
    logic ready;
    logic [7:0] addr, rdata, wdata;

    modport request(
        input ready, rdata,
        output wen, ren, addr, wdata
    );

    modport response(
        input wen, ren, addr, wdata,
        output ready, rdata
    );
endinterface
```

This interface defines communication between a requester (e.g. a CPU) and a responder (e.g. memory). The two modports match these roles, a requester would have the `request` modport, and the responder would have the `response` modport. The signals can be accessed using `.` syntax like a struct.

## Memory Copier
This lab will have you practice hierarchical design by integrating together a few submodules to create a larger module.

### Memory Copier Specification
The "Memory Copier"'s job is to read consecutive data from one location in a memory, and write it consecutively to another location. This is also known as Direct Memory Access (DMA), which is a critical piece of hardware in many computer systems that is responsible for performing certain bulk copy operations so that the CPU can spend its cycles performing useful work. The Memory Copier is not a full DMA implementation (hence the name not being DMA controller), but works in much the same way.

The port list is as follows:
- `memif` - a `memory_if` instance connecting the copier to the memory
- `src_addr` - the address to *read* data from
- `dst_addr` - the address to *write* data to
- `copy_size` - how many bytes to copy
- `start` - asserted when the copier should start copying
- `finished` - asserted **by** the copier when copying is complete

You may assume that:
- Once `start` has been asserted, the other input signals will not change until you assert `finished`
- You copy addresses in order: src, src + 1, src + 2, ... src + copy_size
- You do not need to check for any errors. For example, if the `src_addr` and `dst_addr` overlap or are the same, or if the copy_size would cause a rollover, you may ignore these conditions and just perform the copy.
- There is at least one cycle after asserting `finished` where `start` will not be asserted

### Provided Submodules
#### memory_if
This module has 2 modports: `request` and `response`. The `request` modport will be used by the Memory Copier and TB to send requests (read or write) to the memory. The `response` modport is used by the memory in responding to requests. The signals are as follows:
- `wen` - write enable. Current request is a write.
- `ren` - read enable. Current request is a read.
- `addr` - the address of the request
- `rdata` - the value read from the memory
- `wdata` - the value to write into the memory (from the copier or TB)
- `ready` - indicates that the data is valid and the operation is complete. If `ready` isn't high, the requester should not assume that `rdata` is correct or that the memory has actually performed a write.

#### memory
This is a simple dual-ported memory. One port will be used for the Memory Copier to access, the other will be for the TB to access to perform checks. This is not a component of Memory Copier, it is testing IP, so you should not instantiate this module in your Memory Copier.

#### data_register
This is a simple 8-bit register that serves as temporary storage. If the `WEN` signal is asserted at the rising edge of a clock, the `wdata` value will be stored in the register. The output `data` is the data currently stored in the register. Resets to 0.

#### flex_counter
This is a parameterizable counter module. The parameter `NUM_CNT_BITS` can be selected to create an N-bit counter. The `clear` signal is a *synchronous* reset, that is, asserting `clear` will cause the counter value to reset to 0 at the rising edge of the clock. `rollover_value` sets the maximum counter value: when this value is reached, the counter will automatically roll over to 0, and the `rollover_flag` will be set to 1 for a single cycle. `count_enable` is used to control when the counter will actually increment: holding `count_enable` at 0 will make the counter stop, setting it to 1 will allow it to count. Finally, `count` is the current value of the counter.

### Getting Started
Since this is a larger module, here are some design hints:
1. Use an FSM to control the system. You might have states like IDLE, READ, WRITE, and FINISH. Draw an FSM diagram to help your design, listing which signals should be asserted to what values.
2. Consider how the pieces provided fit into the design. Where would you use a counter, or a data register? Draw an RTL diagram.
3. Fill in the TB BEFORE writing the code for the copier. This should help with incremental testing, and help you understand the design requirements.

The TB for this assignment consists of 3 parts: the TB driver code, the DUT, and the memory module. You can think of them being connected like this:

![TB Setup](./doc/copier_tb.png)

**Task**: Implement the Memory Copier by:
1. Draw an RTL diagram showing the blocks and connections
2. (optional, but helpful): Draw a waveform diagram (using [Wavedrom](https://wavedrom.com/)) to show a transaction
3. Fill in the TB test cases
4. Write the code for the module
