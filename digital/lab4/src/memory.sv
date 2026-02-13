
module memory(
    input CLK, nRST,
    memory_if.response memif,
    memory_if.response testif
);

    typedef logic [7:0] word_t;
    word_t [255:0] memory, memory_n;

    assign memif.rdata = (memif.ren) ? memory[memif.addr] : 8'hFF;
    assign memif.ready = '1; // No wait times!

    // Test interface
    assign testif.rdata = (testif.ren) ? memory[testif.addr] : 8'hFF;
    assign testif.ready = '1;

    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            memory <= '0;
        end else begin
            memory <= memory_n;
        end
    end

    always_comb begin
        memory_n = memory;
        if(memif.wen) begin
            memory_n[memif.addr] = memif.wdata;
        end else if(testif.wen) begin
            memory_n[testif.addr] = testif.wdata;
        end
    end

endmodule
