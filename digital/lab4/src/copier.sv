
module copier(
    input CLK, nRST,
    input logic [7:0] src_addr, dst_addr,
    input logic [7:0] copy_size,
    input logic start,
    output logic finished,
    memory_if.request memif
);

    // TODO: Use module instantiations + glue logic to implement
    // a module which copies 'copy_size' bytes of data from 'src_addr' 
    // to 'dst_addr' when 'start' goes high, and sets 'finished' when
    // the transfer is complete.
    // This behavior is similar to a simple DMA, or "Direct Memory Access"
    // unit, which is used to move data around memory without wasting processor
    // compute time.
    //
    // HINT: Draw out an RTL diagram of this module first using the submodules
    // "data_register" and "flex_counter"


    


endmodule
