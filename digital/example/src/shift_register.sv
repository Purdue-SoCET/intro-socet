
module shift_register #(
    parameter int NBITS = 8
)(
    input clk,
    input rst_n,
    input load,
    input shift,
    input serial_in,
    input [NBITS-1 : 0] parallel_in,
    output logic serial_out,
    output logic [NBITS-1 : 0] parallel_out
);

    logic [NBITS-1 : 0] sr, sr_next;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            sr <= '1; // reset high for UART
        end else begin
            sr <= sr_next;
        end
    end

    always_comb begin
        sr_next = sr;
        if(load) begin
            sr_next = parallel_in;
        end else if(shift) begin
            // concatenation operator; results in serial_in | sr[N-1] | sr[N-2] | ... | sr[1]
            // this is LSB-first shift
            sr_next = {serial_in, sr[NBITS-1 : 1]};
        end
    end

    assign parallel_out = sr;
    assign serial_out = sr[0];

endmodule