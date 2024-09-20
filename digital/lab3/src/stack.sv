module stack #(
    parameter int DATA_WIDTH = 8,
    parameter int NENTRIES   = 8
)(
    input clk,
    input rst_n,
    input push,
    input pop,
    input pop2,
    input clear,
    input [DATA_WIDTH-1 : 0] wdata,
    output logic full,
    output logic empty,
    output logic [$clog2(NENTRIES) : 0] count,
    output logic [DATA_WIDTH-1 : 0] top,
    output logic [DATA_WIDTH-1 : 0] next
);

    typedef logic [DATA_WIDTH-1 : 0] word_t;

    word_t [NENTRIES-1 : 0] array, array_next;
    logic [$clog2(NENTRIES) : 0] sp, sp_next;  // note: sp points to the next *empty* stack slot (e.g. next write is to array[sp])

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            array <= 0;
            sp    <= 0;
        end else begin
            array <= array_next;
            sp    <= sp_next;
        end
    end

    assign full  = (sp == NENTRIES);
    assign empty = (sp == 0);
    assign top   = array[sp - 1];
    assign next  = array[sp - 2];
    assign count = sp;

    // always pop before push. A pop2 overrides a pop1 (e.g. if pop2 is 1, ignore pop1)
    always_comb begin: STACK_POINTER
        casez ({clear, push, pop2, pop})
            4'b0000: sp_next = sp;
            4'b0001: sp_next = sp - 1;
            4'b001?: sp_next = sp - 2;
            4'b0100: sp_next = sp + 1;
            4'b0101: sp_next = sp;
            4'b011?: sp_next = sp - 1;
            4'b1???: sp_next = 0;
        endcase
    end

    always_comb begin : ARRAY_WRITE
        array_next = array;
        casez({push, pop2, pop})
            3'b0??: array_next = array;         // no updates 
            3'b100: array_next[sp] = wdata;     // push to top of stack
            3'b101: array_next[sp - 1] = wdata; // pop1, then push 1. SP location will not change, write will go below SP.
            3'b11?: array_next[sp - 2] = wdata; // pop2, then push 1. SP will decrease by 1, and write will go below SP.
        endcase
    end

endmodule