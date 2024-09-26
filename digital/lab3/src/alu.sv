
module alu(
    input clk,
    input rst_n,
    input start,
    input [15:0] a,
    input [15:0] b,
    input [1:0] op,
    output logic ready,
    output logic [15:0] y
);

    typedef enum logic [2:0] { 
        ALU_ADD,
        ALU_SUB,
        ALU_MUL,
        ALU_DIV,
    } aluop_t;


    logic [15:0] y, y_next;
    logic ready_next;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            y     <= '0;
            ready <= '0;
        end else begin
            y     <= y_next;
            ready <= ready_next;
        end
    end

    always_comb begin
        ready_next = ready;
        if(start) begin
            ready_next = 0;
        end

        ready_next = 1;
    end


    always_comb begin
        casez(op)
            ALU_ADD: y_next = a + b;
            ALU_SUB: y_next = a - b;
            ALU_MUL: y_next = a * b;
            ALU_DIV: y_next = a / b;
            default: y_next = 0;
        endcase
    end

endmodule