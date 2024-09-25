
module counter #(
    parameter int NBITS = 8
)(
    input clk,
    input rst_n,
    input enable,
    input clear,
    input [NBITS-1 : 0] overflow_value,
    output logic overflow,
    output logic [NBITS-1 : 0] count
);
    logic [NBITS-1 : 0] count_next;
    logic overflow_next;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            count <= '0;
            overflow <= '0;
        end else begin
            count <= count_next;
            overflow <= overflow_next;
        end
    end

    always_comb begin
        count_next = count;
        overflow_next = overflow;
        if(clear) begin
            count_next = 0;
            overflow_next = 0;
        end else if(enable) begin
            if(overflow) begin
                count_next = 0;
            end else begin
                count_next = count + 1;
            end
            if(count_next == overflow_value) begin
                overflow_next = 1;
            end else begin
                overflow_next = 0;
            end
        end
    end

endmodule