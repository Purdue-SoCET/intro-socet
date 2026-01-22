# Digital Design Lab 1

## Before you start
This document is Markdown, and is best shown rendered! Viewing this on GitHub or with your choice of Markdown renderer offline is recommended.

### Important terminology
- HDL: Hardware Description Language, a language designed to describe and design circuits. This includes SystemVerilog, VHDL, and Verilog, as well as modern languages like Chisel and ClaSH.
- Testbench: HDL code that describes sequences of inputs, output checks, and other procedural code that will *not* be turned into a circuit. A testbench is used to test your design -- think plugging signal generators into your breadboard.
- Synthesis: Process of compiling HDL into a circuit netlist.

### Using Verilator
Verilator is an open-source (System)Verilog simulator. Verilator "synthesizes" your circuit and testbench into a C++ model, that is then compiled in to an executable binary. We have provided the commands to invoke Verilator for you, but you should inspect the provided Makefile and familiarize yourself with using Verilator.

When you build with verilator ("verilate"), it will create a directory called `obj_dir`, which contains the generated C++ code and a Makefile to build it (giving Verilator the --binary or --build flag will make it run 'make' for you). After building, you will get an executable in `obj_dir` named `V<top_module>`, where `<top_module>` is replaced with the name of the top-level module in your design.

Verilator also allows you to use C++ to write a testbench, which can be useful for easing test development and creating more complex testbenches, as you can use the full C++ language and libraries.

### Using GTKWave
GTKWave is a waveform viewer program. It is capable of displaying waveforms of many different formats, but the two relevant formats for our purposes are VCD (value-change dump) and FST (fast signal trace). FST is typically faster and contains more useful information, so using it is recommended. To read a waveform file, you can simply run `gtkwave <filename>` in your terminal.

### Makefile
Make is a program used to build software. A Makefile describes the build process, including lists of files and commands to run. While not critical to understand for this lab, you will be using the provided Makefile to build and run the simulations.

### Full adder
A full adder is a circuit that adds 2 bits and a carry-in value together, and procudes a sum and carry-out bit. The truth table of a full adder is as follows. A and B are the input bits, Cin is the carry-in value, S is the sum, and Cout is the carry-out value.

| **A** | **B** | **Cin** |   | **S** | **Cout** |
|:-----:|:-----:|:-------:|:-:|:-----:|:--------:|
|   0   |   0   |    0    |   |   0   |     0    |
|   0   |   0   |    1    |   |   1   |     0    |
|   0   |   1   |    0    |   |   1   |     0    |
|   0   |   1   |    1    |   |   0   |     1    |
|   1   |   0   |    0    |   |   1   |     0    |
|   1   |   0   |    1    |   |   0   |     1    |
|   1   |   1   |    0    |   |   0   |     1    |
|   1   |   1   |    1    |   |   1   |     1    |

Alternatively, as a set of Boolean equations:
```
t1   := a ^ b
t2   := a & b
t3   := t1 & Cin
s    := t1 ^ Cin
Cout := t2 | t3
```
>Note: Recall that the "^" symbol is XOR. The "tN" variables are internal signals, i.e. the result of individual gates.

Cascading full-adders together will allow you to add larger numbers (this formation is known as a Ripple-Carry Adder). Below is an example of a 4-bit ripple carry adder.

![4-bit Ripple-Carry](./doc/ripple_carry.png)

Of course, since we have a fixed-0 input for the Cin of the first full adder, this could be simplified to a "half adder": a circuit that *only* adds A + B and produces the sum and carry-out, but takes no carry-in.

>Note: Adding two binary numbers of bit widths $n$ and $m$ will produce a sum of width $max(n, m) + 1$. If you use fewer bits to represent the sum (e.g. excluding the final carry-out), the value will *overflow*, or wrap back around to the smallest value! For example, with a fixed width of 4 bits:
>```
>   1101 (= 13)
>+ 1000 (= 8)
>-------
>   0101 (= 5???)
>```
>13 + 8 wraps back around to 5! This is why in many old games, there are either limits of 255 (largest unsigned 8-bit value), or bugs occur when counters get past 255 and wrap back to 0.


## Lab Tasks
### 1. Schematic Ripple Carry Adder
This is the only time where you'll need to draw gate-level schematics of anything.

**Task**: Using the website [logic.ly](https://logic.ly/demo/), create a 4-bit ripple carry adder (RCA) using full adders. You should use the toggle switch (for inputs), the 4-bit digit (for output), a light bulb (for the final carry-out, indicating overflow), and whichever logic gates you wish to implement the full adder.

### 2. SystemVerilog Full Adder
Start by running the testbench for the full adder. This can be done by running:
```
make full_adder
```
This will invoke Verilator to build the simulator, and copy the resulting executable from the `obj_dir` folder to your current directory. To run it, you can simply type `./Vfull_adder` (the name of the executable). You should see some output on the screen, indicating that the full adder does not work.

Next, open the testbench (`tb/tb_full_adder.sv`). Read through the comments and code, and familiarize yourself with what the testbench is doing, and where the error messages originate from.

Now you can view the waveforms. In your terminal, run `gtkwave waveform.fst&` (note the & symbol: this will run the program in the background and allow you to continue using your terminal while GTKWave is open). Drag and drop the signal names from under "tb_full_adder" to the main display. Now you can inspect the values of variables during execution.

**Task**: Find the bug in the implementation of `full_adder`, fix it, and ensure the testbench passes all the tests.

**Question**: Looking at the code in the `initial` block of `tb_full_adder`, can you recommend a way to make it easier to read/write.


### 3. 8-bit Ripple Carry Adder
An important concept in SystemVerilog is hierarchical design: using (and re-using) smaller components to build up a larger system. For this part of the lab, you will construct an 8-bit adder by using the 1-bit adders you debugged in part 2. 

First, open the file `src/eight_bit_adder.sv` and fill in the logic for an 8-bit adder. You are welcome to code this however you like (as long as it is *hierarchical* using the full_adder module, not a 1-line assign statement), but following the link in the HINT comment and familiarizing yourself with `generate` blocks will cut down on coding effort substantially.

Next, open the file `tb/tb_eight_bit_adder.sv`. This TB is a little different than the last one, but follows the same basic format. This time, instead of testing all input combinations exhaustively (as there are 2^16 such inputs), we employ some random testing. Your job is to fill in the empty `apply_inputs` task to apply inputs, wait for the input to propagate, and check the outputs. Then, you should add at least 4 directed (e.g. chosen) test cases before the random tests. Try to check cases that you believe to be corner cases.

To run the simulator after building, execute `./Vtb_eight_bit_adder`.

**Task**: Implement the 8-bit ripple-carry adder from instances of `full_adder`, and fill in the tesbench to test the module.

> Note: Real-world circuits have a delay between presenting the inputs and seeing the change in output (*propagation delay*). The *critical path* of a circuit is simply the longest combinational logic path (from input to output, input to FF, FF to FF, or FF to output). This delay determines the fastest clock speed. The *critical path* of a full adder is the path from Cin -> Cout (assuming all gates have the same delay, which may not be true in a real process). Worse, for the ripple-carry adder, the next FA depends on Cout of the prior FA to compute its Cout. Hence the name ripple-carry: the carry signals "ripple" through the adder from least-significant bit to most-significant bit.

**Further Reading**: There are "fast adders" that reduce the delay of addition, such as Carry-Save, Carry-Select, and Carry-Lookahead. These all make different trade-offs in terms of propagation delay vs. power/area (i.e. use more gates but take less time). These optimizations can be important in wide adders like those doing integer arithmetic in 64-bit CPUs.

### 4. Binary Counter
This final lab task will introduce you to a basic sequential logic design in SystemVerilog. 

#### Circuit-level
First, we'll look at the circuit for a 2-bit binary counter in [logic.ly](https://logic.ly/demo). To start, place a hex display and 2 T-Flip-Flops (TFF). 

> Note: In the presentation, we only considered D-Flip-Flops, which simply save their current input (D) when a clock edge arrives. A T-Flip-Flop, on the other hand, has an input T. If T is low when a clock edge arrives, the saved value does not change. If T is high, it will toggle (e.g. 1 -> 0, 0 -> 1) its saved value.

Notice that the T flip-flops have 2 extra inputs, PRE' and CLR'. These are asynchronous signals (e.g. they take effect immediately, not when a clock edge arrives) that force the Flip-Flop's saved value to be 1 or 0, respectively. Finally, the apostrophe means they are "active-low": the PRE' and CLR' signals take effect when a "0" value is input, and do nothing when a "1" value is input.

Now, place a push-button and a NOT gate down. Connect the push-button to the input of the NOT gate, and the output of the NOT gate to the CLR' signal of each TFF. Place a Constant 1, and connect it to the PRE' signal of each TFF, and the T input of the first TFF. Connecting a constant 1 to the PRE' signal essentially disables the preset functionality. The push button is connected to the NOT gate to invert its output (as the button is normally low and goes high when pressed), and is connected to the CLR' input so that we can clear the flip-flops to 0 at any time by pressing it. 

Next, connect the Q output of the first TFF to the T input of the second TFF. Now connect the Q output of each TFF to an input of the hex digit (first TFF should be the top input, second should be the one below it). 

Finally, place a clock element, and connect it to the ">" input of the TFFs. Press the button to clear, and watch as the hex digit counts 0, 1, 2, 3, 0, 1, ...

The final circuit should look something like this:
![2b Counter](./doc/counter.png)

**Question**: How could this be extended to more bits? (Hint: Just adding more TFFs and connecting Q of the previous TFF to T of the next one will not work!)

#### SystemVerilog Counter
This final section of the lab will have you debug a simple counter, similar to the one you drew in logic.ly. The counter should be 3b, and count by 1 up to 7, rolling over back to 0 after that.

To start, run the counter's testbench by running `make counter` from your `lab1` directory. As before, this will use Verilator to build the simulator, and copy the binary to your current directory. You can run by executing `./Vcounter`. You will see that again, the TB does not pass as-is.

Open the file `./tb/tb_counter.sv`, and find out what the test case is. Make sure to read the comments in the TB, as they explain some of the concepts new to sequential logic.

Additionally, use gtkwave to open up the waveform file generated by running the simulation and check the counter behavior. Pay close attention to the initial value of the counter (after the reset), and the value by which it increments.

Now, open the file `./src/counter.sv`. Read the comments here to get a sense of what is going on, and try to find where the bugs occur. As a hint, there are 2 lines of code that need to be edited.

**Task**: Debug the counter module and ensure that the testbench passes all tests.

> Note: Notice that in our SystemVerilog model, we didn't specify *what* kind of flip-flops to use, only that our desired behavior was to have 3 bits that update on the rising edge of the clock or a reset, and each cycle adds a value to the old state. Decisions about *what* to make the circuit out of are the job of a synthesis tool, the HDL code specifies behavior. The synthesis tool could decide to implement the counter out of any flip-flop it has available (based on the *cell library*), and do the increment operation in many different ways based on which logic gates it has! Our use of TFFs in logic.ly was mostly to simplify the design, as DFFs would have required more external logic gates to do the increment.

**Question**: If we wanted to describe the TFF functionality in SystemVerilog, how could we implement this? See if you can fill in the following code:
```sv
module tff(
    input logic clk,
    input logic t,
    input logic pre_n,
    input logic clr_n,
    output logic q,
    output logic q_n
);

    always_ff @() begin
        // Your code here
    end
endmodule
```
> Hint: `A ^ 1 == !A and A ^ 0 == A`

## All done!
Make sure to put evidence of lab completion in your design logs! This includes screenshots of relevant portions (waveforms of working modules would be good) and answers to questions in this lab document.
