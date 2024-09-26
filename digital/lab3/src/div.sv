module div#(
    parameter int WIDTH = 16
)(
    input clk,
    input rst_n,
    input start,
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output logic ready,
    output logic [WIDTH-1:0] q,
    output logic [WIDTH-1:0] r
);

    logic [WIDTH*2 : 0] rq; // debug signal
    logic [WIDTH:0] rem, r_next;
    logic [WIDTH-1 : 0] q_next;
    logic [$clog2(WIDTH) : 0] count, count_next;
    logic ready_next;
    logic is_div_by_zero;
    logic sign_a, sign_b, sign_q;

    assign rq = {rem, q};
    assign r = rem[WIDTH-1 : 0];
    assign is_div_by_zero = (b == 0);

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            rem <= '0;
            q <= '0;
            count <= '0;
            ready <= '0;
        end else begin
            rem     <= r_next;
            q     <= q_next;
            count <= count_next;
            ready <= ready_next;
        end
    end

    // Main division algorithm
    always_comb begin
        ready_next = ready;
        count_next = count;
        r_next = rem;
        q_next = q;

        if(start && !is_div_by_zero) begin
            ready_next = 0;
            count_next = 0;
            r_next = 0;
            q_next = a;
        end else if(start && is_div_by_zero) begin 
            ready_next = 1;
            count_next = count;
            r_next = 16'hFFFF;
            q_next = 16'hFFFF;
        end else if(count < WIDTH) begin
            count_next = count + 1;
            {r_next, q_next} = {r, q} << 1;
            if($signed(r_next - b) >= 0) begin
                r_next = r_next - b;
                q_next |= 'b1;
            end
        end else if(count >= WIDTH) begin
            ready_next = 1;
        end
    end


endmodule