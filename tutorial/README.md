# Verilog Tutorial

## Before you start
This portion of the initial lab is mostly a "zoo" type lab. You won't have to run any code.

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

### Types of Verilog Modeling
There are three primary types of Verilog Modeling: Structural, Dataflow, and Behavioral. In `first_module.sv` you'll see all three modeling types for a device.

### Half Adder
A full adder is a circuit that adds 2 bits together, and procudes a sum and carry-out bit. The truth table of a full adder is as follows. A and B are the input bits, Cin is the carry-in value, S is the sum, and Cout is the carry-out value.

| **A** | **B** | **S** | **Cout** |
|:-----:|:-----:|:-:|:-----:|:--------:|
|   0   |   0   |   0   |     0    |
|   0   |   1   |   1   |     0    |
|   1   |   0   |   1   |     0    |
|   1   |   1   |   0   |     1    |


## Lab Tasks
### Schematic Half Adder
This is the only time where you'll need to draw gate-level schematics of anything.

**Task**: Using the website [logic.ly](https://logic.ly/demo/), create a Half Adder using gates. You should use the toggle switch (for inputs), and light bulbs (for the sum and final carry-out, indicating overflow), and whichever logic gates you wish to implement the half adder.

The rest of the lab is entirely described in the submission document.

## All done!
