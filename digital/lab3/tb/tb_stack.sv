
`define CHECK(signal, value) \
    check(signal, value, `"signal`", `__LINE__)

module tb_stack;

    localparam int CLOCK_PERIOD = 10;
    localparam int INTERTEST_TIME = 5;

    int test_case = -1;
    int passed = 0;
    int nblocks = 0;
    int passed_blocks = 0;
    string test_block = "Initialization";
    logic clk = 0, rst_n;
    logic [7:0] top, next, wdata;
    logic push, pop, pop2, clear;
    logic full, empty;
    logic [4:0] count;

    // Clock generation
    always #(CLOCK_PERIOD / 2) clk++;

    // DUT instantiation.
    stack #(.DATA_WIDTH(8), .NENTRIES(16)) DUT(.*);

    // Reset DUT using aynschronous reset
    // Advances clock by 2 cycles.
    task reset();
        rst_n = 1'b0;
        repeat(2) @(negedge clk);
        #(1);
        rst_n = 1'b1;
    endtask

    // Sets all signals to their default values
    // To be used at beginning of testbench, or
    // when a test needs to reset inputs to a 'neutral' state.
    task clear_signals();
        rst_n = 1;
        push = 0;
        pop = 0;
        pop2 = 0;
        clear = 0;
        wdata = 0;
    endtask

    task tb_start();
        clear_signals();
    endtask

    task test_block_start(string name);
        clear_signals();
        repeat(INTERTEST_TIME) @(posedge clk);
        #(1);
        test_block = name;
        test_case = 0;
        passed = 0;
        nblocks += 1;
    endtask

    task check(logic [7:0] actual, logic [7:0] expected, string signal_name, int line_number);
        if(expected != actual) begin
            $display("[Time %0t Block \"%s\" Case %03d]: On line %0d: signal \"%s\" expected %x, received %x\n", $time, test_block, test_case, line_number, signal_name, expected, actual);
        end else begin
            passed += 1;
        end
        test_case += 1;
    endtask

    task test_block_end();
        $display("BLOCK %s: Passed %0d / %0d\n", test_block, passed, test_case);
        if(passed == test_case) begin
            passed_blocks += 1;
        end
    endtask

    task tb_end();
        $display("%0d / %0d Blocks fully passed.", passed_blocks, nblocks);
        $finish;
    endtask

    // Uses the synchronous clear signal to empty
    // the stack.
    task clear_stack();
        clear = 1;
        @(posedge clk);
        #(1);
        clear = 0;
    endtask

    // Push `value` to the stack
    task push_stack(logic [7:0] value);
        push = 1;
        wdata = value;
        @(posedge clk);
        #(1);
        push = 0;
    endtask


    initial begin
        // Setup trace dump
        $dumpfile("stack.fst");
        $dumpvars(0, tb_stack);

        // Initialize input signals
        tb_start();

        // reset DUT
        test_block_start("Power-on Reset");
        reset();
        `CHECK(count, 0);
        `CHECK(top, 0);
        `CHECK(next, 0);
        `CHECK(empty, 1);
        `CHECK(full, 0);
        test_block_end();

        // test push
        test_block_start("Push");
        begin
            logic [7:0] last = 0;
            
            push_stack(10);
            `CHECK(top, 10);
            `CHECK(count, 1);
            `CHECK(empty, 0);
            last = 10;

            for(int i = 0; i < 15; i++) begin
                push_stack(i + 11);
                `CHECK(top, i + 11);
                `CHECK(next, last);
                `CHECK(count, i + 2);
                `CHECK(empty, 0);
                last = i + 11;
            end
            `CHECK(full, 1);
            clear_signals();

            clear_stack();
            `CHECK(count, 0);
            `CHECK(full, 0);
            `CHECK(empty, 1);
        end
        test_block_end();

        test_block_start("Pop1");
        begin
            // Fill the stack with values
            for(int i = 0; i < 16; i++) begin
                push_stack(i*3 + 1);
            end
            #(1);
            `CHECK(full, 1);
            `CHECK(empty, 0);
            `CHECK(count, 16);
            `CHECK(top, 15*3 + 1);
            `CHECK(next, 14*3 + 1);

            clear_signals();
            // Now pop the data values, ensuring the new top/next is correct each time
            for(int i = 15; i >= 2; i--) begin
                pop = 1;
                @(posedge clk);
                #(1);
                `CHECK(full, 0);
                `CHECK(empty, 0);
                `CHECK(count, i);
                `CHECK(top, (i-1)*3 + 1);
                `CHECK(next, (i-2)*3 + 1);
            end

            // Last element handled separately
            pop = 1;
            @(posedge clk);
            #(1);
            `CHECK(full, 0);
            `CHECK(empty, 0);
            `CHECK(top, 1);
            `CHECK(count, 1);

            pop = 1;
            @(posedge clk);
            #(1);
            `CHECK(full, 0);
            `CHECK(empty, 1);
            `CHECK(count, 0);
        end
        test_block_end();

        test_block_start("Pop2");
        begin
            // Fill the stack with values
            for(int i = 0; i < 16; i++) begin
                push_stack(i*3 + 1);
            end
            #(1);
            `CHECK(full, 1);
            `CHECK(empty, 0);
            `CHECK(count, 16);
            `CHECK(top, 15*3 + 1);
            `CHECK(next, 14*3 + 1);

            clear_signals();
            // Now pop the data values, ensuring the new top/next is correct each time
            for(int i = 7; i >= 1; i--) begin
                pop2 = 1;
                @(posedge clk);
                #(1);
                `CHECK(full, 0);
                `CHECK(empty, 0);
                `CHECK(count, i*2);
                `CHECK(top, (i*2-1)*3 + 1);
                `CHECK(next, (i*2-2)*3 + 1);
            end

            // Last elements handled separately
            pop2 = 1;
            @(posedge clk);
            #(1);
            `CHECK(full, 0);
            `CHECK(empty, 1);
            `CHECK(count, 0);
        end
        test_block_end();

        test_block_start("Mixed push/pop");
        begin
            // Test if pop2 overrides pop1
            clear_stack();
            push_stack(8'hFF);
            push_stack(8'hF);
            push_stack(8'hF0);

            pop = 1;
            pop2 = 1;
            @(posedge clk);
            #(1);
            `CHECK(count, 1);
            `CHECK(top, 8'hFF);
            `CHECK(full, 0);
            `CHECK(empty, 0);
            clear_signals();

            // Test if we can push/pop at the same time, swapping out the top value
            clear_stack();
            push_stack(8'hFF);
            push_stack(8'hAA);
            pop = 1;
            push = 1;
            wdata = 8'hBB;
            @(posedge clk);
            #(1);
            `CHECK(count, 2);
            `CHECK(top, 8'hBB);
            `CHECK(next, 8'hFF);
            `CHECK(full, 0);
            `CHECK(empty, 0);
            clear_signals();

            // Test if we can push/pop2 at the same time.
            clear_stack();
            push_stack(8'hFF);
            push_stack(8'hEE);
            push_stack(8'hAA);
            pop2 = 1;
            push = 1;
            wdata = 8'hCC;
            @(posedge clk);
            #(1);
            `CHECK(count, 2);
            `CHECK(top, 8'hCC);
            `CHECK(next, 8'hFF);
            `CHECK(full, 0);
            `CHECK(empty, 0);
            clear_signals();

            // Same test, but also assert pop and show that it's overridden
            clear_stack();
            push_stack(8'hFF);
            push_stack(8'hEE);
            push_stack(8'hAA);            
            pop  = 1;
            pop2 = 1;
            push = 1;
            wdata = 8'hCC;
            @(posedge clk);
            #(1);
            `CHECK(count, 2);
            `CHECK(top, 8'hCC);
            `CHECK(next, 8'hFF);
            `CHECK(full, 0);
            `CHECK(empty, 0);
            clear_signals();
        end
        test_block_end();
        
        tb_end();
    end


endmodule