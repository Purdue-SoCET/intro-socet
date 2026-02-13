
module tb_copier_controller;

    // TB Signals (connect to DUT)
    logic CLK = 0, nRST;
    logic [7:0] src_addr, dst_addr, copy_size;
    logic start, finished;
    logic [7:0] mem_rdata, mem_addr, mem_wdata;
    logic mem_ready, mem_wen, mem_ren;

    logic [7:0] fake_byte, fake_src_addr, fake_dst_addr;
    // TODO: (optional) declare any other debugging-related
    // metadata signals you want here.
    // Adding things like a test number, or a string containing
    // the name of the test can be helpful for discerning when tests
    // start/stop when viewed in the waveforms.

    // Clock generation
    always #(10) CLK++;

    copier_controller DUT(
        .CLK(CLK),
        .nRST(nRST),
        .src_addr(src_addr),
        .dst_addr(dst_addr),
        .copy_size(copy_size),
        .start(start),
        .mem_ready(mem_ready),
        .mem_rdata(mem_rdata),
        .finished(finished),
        .mem_wen(mem_wen),
        .mem_ren(mem_ren),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata)
    );
    

    task reset();
    begin
        nRST = '0;
        repeat(2) @(posedge CLK);
        nRST = '1;
        @(posedge CLK);
        #(1);
    end
    endtask

    /*
    * reset_signals
    *
    * Set all signals to a "neutral" value. Can be helpful between tests.
    */
    task reset_signals();
    begin
        //target signals
        src_addr = 0;
        dst_addr = 0;
        copy_size = 0;
        start = 0;

        //fake memory signals
        mem_ready = 0;
        mem_rdata = '0;

    end
    endtask

    /*
    * fake_transaction
    *
    * TODO: Complete fake_transaction, a task that creates a transaction to step through memcpy controller.
    *       You should use the tasks created for you. Make sure to set the "fake memory" signals.
    */
    task fake_transaction ();
    begin
        
    // Your code here!

    end
    endtask

    task request_copy (
        input logic [7:0] rm_src_addr,
        input logic [7:0] wm_dst_addr
    );
    begin
        int rc_cycles = 0;
        src_addr = rm_src_addr;
        dst_addr = wm_dst_addr;

        while (!(finished == 1'b0 && mem_wen == 1'b0 && mem_ren == 1'b0 
            && mem_addr == 8'b0 && mem_wdata == 8'hFF)) begin
            if (rc_cycles >= 15) begin
                $error("Output signals not reset for new copy operation: finished: %b, mem_wen: %b, mem_ren: %b, mem_addr: %h, mem_wdata: %h",
                       finished, mem_wen, mem_ren, mem_addr, mem_wdata);
                return;
            end
            @(posedge CLK)
            rc_cycles++;
        end

        start = 1'b1;
        $display("Copying Started...");
        @(posedge CLK)
        @(posedge CLK)
        start = 1'b0;

    end
    endtask

    task read_mem(
        input logic [7:0] rm_src_addr
    );
    begin
        int rm_cycles = 0;

        copy_size = 8'b1; // hardcoded 1 byte r/w
        mem_rdata = 8'hA8; // hardcoded A8 read
        
        while (!(finished == 1'b0 && mem_wen == 1'b0 && mem_ren == 1'b1 
                && mem_addr == rm_src_addr && mem_wdata == 8'hFF)) begin
            if (rm_cycles >= 15) begin
                $error("Timeout: output signals not set properly for a read operation, exceeded 15 cycles");
                return;
            end
            @(posedge CLK)
            rm_cycles++;
        end

        @(posedge CLK)
        mem_ready = 1'b1;
        $display("Reading byte at %h on cycle %d", mem_addr, rm_cycles);
        @(posedge CLK)
        mem_ready = 1'b0;

    end
    endtask

    task write_mem(
        logic [7:0] wm_dst_addr,
    );
    begin
        int wm_cycles = 0;
        while (!(finished == 1'b0 && mem_wen == 1'b1 && mem_ren == 1'b0 
            && mem_addr == wm_dst_addr && mem_wdata == fake_byte)) begin
            if (wm_cycles >= 15) begin
                $error("Timeout: output signals not set properly for a read operation, exceeded 15 cycles");
                return;
            end
            @(posedge CLK)
            wm_cycles++;
        end
        
        $display("Wrote byte at %h on cycle %d", mem_addr, wm_cycles);

    end
    endtask

    task check_complete(
    );
    begin
        int cc_cycles = 0;
        while (!(finished == 1'b1 && mem_wen == 1'b0 && 
            mem_ren == 1'b0 && mem_wdata == 8'hFF)) begin
            if (cc_cycles >= 15) begin
                $error("Timeout: output signals not set properly once finished");
                return;
            end
            @(posedge CLK)
            cc_cycles++;
        end
        $display("Finished MEMCPY");
        $display("MEMCPY Transaction Successful!");
    end
    endtask

    initial begin
        
        $dumpfile("waveform.fst");
        $dumpvars(0, tb_copier_controller);

        nRST = 1'b1;

        $timeformat(-9, 2, " ns", 20); // Set formatting for printing time

        reset_signals();
        reset();

        // execute the testbench
        fake_transaction();

        $finish;
    end

endmodule
