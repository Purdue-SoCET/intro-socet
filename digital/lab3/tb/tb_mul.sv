module tb_mul;

    localparam int CLOCK_PERIOD = 10;

    logic clk = 0, rst_n;
    logic [15:0] a, b, y, expected;
    logic start, ready;
    int test_num = 0;
    int pass_count = 0;

    always #(CLOCK_PERIOD/2) clk++;

    mul DUT(.*);

    task reset();
        rst_n = 1'b0;
        repeat(2) @(negedge clk);
        #(1);
        rst_n = 1'b1;
    endtask
    
    task check(logic [15:0] lhs, logic [15:0] rhs, logic [15:0] expected, logic [15:0] actual);
        if(expected != actual) begin
            $display("[Time %0t Test %03d]: %d x %d; Expected %d, received %d\n", $time, test_num, lhs, rhs, expected, actual);
        end else begin
            pass_count += 1;
        end
    endtask

    task multiply(logic [15:0] lhs, logic [15:0] rhs);
        test_num += 1;
        a = lhs;
        b = rhs;
        expected = lhs * rhs;
        start = 1;
        @(posedge clk); #(1);
        start = 0;
        repeat(31) @(posedge clk);
        #(1);
        if(!ready) begin
            $display("Multiplier was not ready when expected!\n");
        end
        check(lhs, rhs, expected, y);
    endtask

    initial begin
        $dumpfile("mul.fst");
        $dumpvars(0, mul);
        start = 0;
        a = 0;
        b = 0;
        
        reset();

        for(int i = 0; i < 1000000; i++) begin
            multiply($random, $random);
        end

        $display("Passed %0d / %0d tests.", pass_count, test_num);
        $finish;
    end

endmodule