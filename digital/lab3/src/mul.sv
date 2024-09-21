module mul #(
    parameter int WIDTH = 16
)(
    input clk,
    input rst_n,
    input start,
    input [WIDTH-1 : 0] a,
    input [WIDTH-1 : 0] b,
    output logic [WIDTH-1 : 0] y,
    output logic ready
);

    logic [(WIDTH*2)-1 : 0] product, product_next;
    logic [$clog2(WIDTH) : 0] count, count_next;

    assign y = product[WIDTH-1 : 0];
    assign ready = (count >= WIDTH);

    // ASSUMPTION: a and b inputs are held steady
    // from when 'start' goes high until 'ready'
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            product <= '0;
            count <= '0;
        end else begin
            product <= product_next;
            count <= count_next;
        end
    end

    always_comb begin
        product_next = product;
        count_next = count;
        if(start) begin
            product_next[WIDTH-1 : 0] = b;
            product_next[(WIDTH*2)-1 : WIDTH] = 0;
            count_next = '0;
        end else if(count < WIDTH) begin
            if(product[0]) begin
                product_next[(WIDTH*2)-1 : WIDTH] = product[(WIDTH*2)-1 : WIDTH] + a;
            end
            product_next = product_next >> 1;
            count_next = count + 1;
        end
    end

endmodule