
module tb_uart_tx;

    logic clk, rst_n;
    logic tx_data, send_request;
    logic [7:0] tx_byte;
    logic tb_sample;

    // Assume 1ns timescale
    localparam CLOCK_PERIOD = 100;
    localparam UART_BIT_CYCLES = 1024;

    // clock generation
    always begin
        clk = 0;
        #(CLOCK_PERIOD / 2);
        clk = 1;
        #(CLOCK_PERIOD / 2);
    end

    // instantiate DUT, auto-connect TB signals
    uart_tx DUT(.*);

    task reset();
        rst_n = 1'b0;
        repeat(2) @(negedge clk);
        #(1);
        rst_n = 1'b1;
    endtask

    task expect_bit(logic data);
        if(data != tx_data) begin
            $display("Expected %b, got %b\n", data, tx_data);
        end
    endtask

    task send_data(logic [7:0] data);
        $display("Sending byte %02x", data);
        tx_byte = data;
        send_request = 1'b1;
        @(posedge clk);
        #(1);
        // should be in LOAD state
        send_request = 0;
        @(posedge clk);
        #(1);
        // now in send state, check that tx_data goes low for start bit
        expect_bit(1'b0);
        // Wait for next bit
        repeat(UART_BIT_CYCLES) @(posedge clk);
        // get to center of the next bit to sample
        repeat(UART_BIT_CYCLES/2) @(posedge clk);
        for(int i = 0; i < 8; i++) begin
            // sample bit
            tb_sample = 1'b1;
            expect_bit(data[i]);
            @(posedge clk);
            tb_sample = 1'b0;
            repeat(UART_BIT_CYCLES) @(posedge clk);
        end
        // check stop bit
        expect_bit(1'b1);
        // get to end of stop bit
        repeat(UART_BIT_CYCLES / 2) @(posedge clk);
    endtask

    initial begin
        $dumpfile("trace.fst");
        $dumpvars(0, tb_uart);


        rst_n = 1'b1;
        send_request = 1'b0;
        tx_byte = '0;
        tb_sample = 1'b0;

        repeat(5) @(posedge clk); // get away from time 0


        reset();

        for(int i = 0; i < 10; i++) begin
            // Give 1000 cycles of idle time
            repeat(1000) @(posedge clk);

            // disable width check in verilator
            // $random returns 32 bits but the task expects 8.
            // This causes the linter in verilator to complain
            // that the value is truncated.
            
            /* verilator lint_off WIDTHTRUNC */
            send_data($random);
            /* verilator lint_on WIDTHTRUNC */
        end

        $finish();
    end

endmodule