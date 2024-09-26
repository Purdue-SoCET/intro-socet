
module stack_calculator(
    input clk,
    input rst_n,
    input start,
    input [16:0] instruction,
    output logic result,
    output logic ready
);


    typedef enum logic [2:0] { 
        ADD,
        SUB,
        MUL,
        DIV
    } op_t;

    // Instruction signals
    logic is_value;
    logic [15:0] data;
    op_t operation;

    // Stack control signals
    logic push, pop, pop2, clear;
    logic full, empty;

    // 
    

    assign is_value = instruction[16];
    assign data = instruction[15:0];
    assign operation = op_t'(instruction[2:0]);





endmodule
