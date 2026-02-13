# Digital Design Lab 4

## Memory Copier
This lab will have you practice designing your own sequential machine, specifically a finite state machine (FSM), that controls the flow of data in a memory system. **You will reuse this code in lab 4**, where you will integrate your controller into a complete system using verilog interfaces.

### Enumerated Types
When you are creating a custom FSM, you may find it helpful to label states with more descriptive names instead of "state 1, 2, 3, etc." You can find an example in Lab 2 precoded, or below:

```sv
typedef enum logic [2:0] {
    S0,
    S1,
    S2,
    S3,
    S4
} state_t;

state_t state, next_state;
```

In this example, S0, S1, etc. are values of type "logic" where S0 = 000, S1 = 001, S2 = 010, and so on. Since state_t is also of [2:0] size, this enum can hold a maximum of 8 names.

You could compare this in a case statement either with the enumerated label, or the actual data value, for example, these two case checks would be equal evaluations (this isn't functionally correct and should only be used as an example).

```sv
case (state)
    S0: <stuff>;
    000: <stuff>;
endcase
```

### Memory Copier Specification
The "Memory Copier"'s job is to read consecutive data from one location in a memory, and write it consecutively to another location. This is also known as Direct Memory Access (DMA), which is a critical piece of hardware in many computer systems that is responsible for performing certain bulk copy operations so that the CPU can spend its cycles performing useful work. The Memory Copier is not a full DMA implementation (hence the name not being DMA controller), but works in much the same way. You are responsible for creating the controller (i.e. the brain) of the system. This controller manages communication between external devices.

This and the following lab both use *byte-level addressing*. This is where each address has a whole byte (8-bits) of data. We also have a bus that can only process one byte of data at a time. Transfers of more than one byte must take place sequentially.

Below is a visual explaination of the memory copy process. Note: each step of this process is done in a *sequential* manner (hint: sequential machines!).

![MCPY_Dataflow](./doc/Intro_DL3.png)

The port list for your controller is as follows:

Inputs:
- `start` - asserted when the copier should start copying
- `src_addr` - an address to *read* data from given to your controller externally
- `dst_addr` - the address to *write* data to given to your controller externally
- `copy_size` - how many bytes to copy
- `mem_ready` - a signal from the memory that the data is ready to be read
- `mem_rdata` - the data readable from memory
  
Outputs:
- `mem_wen` - the signal asserted to tell the memory to enable writing
- `mem_ren` - signal to enable reading from memory
- `mem_addr` - the signal asserted to tell the memory to read/write from/to a specific address
- `mem_wdata` - the data to be written to memory
- `finished` - asserted **by** the copier when copying is complete

You may assume that:
- Once `start` has been asserted, the other input signals will not change until you assert `finished`
- You copy addresses in order: src, src + 1, src + 2, ... src + copy_size
- You do not need to check for any errors. For example, if the `src_addr` and `dst_addr` overlap or are the same, or if the copy_size would cause a rollover, you may ignore these conditions and just perform the copy.
- The **Data Buffer** is an internal device and does not need to be *externally* seen. You will need to implement a simple storage system in your code to do this. A simple data register `data_register.sv` is provided for you to use.
- `copy_size` **will always be equal to 1. You do not need to implement a counting system, but compatability with copy_size >1 will be helpful for Lab 4.**
- There is at least one cycle after asserting `finished` where `start` will not be asserted
- The default output of your system's write bus should be `8'hFF`

### Getting Started
Since this is part of a larger module, here are some design hints:
1. Use an FSM to control the system. You might have states like IDLE, READ, WRITE, and FINISH. Draw an FSM diagram to help your design, listing which signals should be asserted to what values.

**Task**: Implement the memcpy controller by:
1. Draw a RTL diagram with it's coresponding FSM (Moore Machine) diagram showing your states and state transitions.
2. Figure out what states use which I/O.
3. Write the code for the module.
4. Complete the TB to verify correct copy behavior. (Hint: there might be clues to the function in there!)
