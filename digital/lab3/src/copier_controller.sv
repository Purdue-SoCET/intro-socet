
module copier_controller(
    input CLK, nRST,
    input logic [7:0] src_addr, dst_addr,
    input logic [7:0] copy_size,
    input logic start,
    input logic mem_ready, 
    input logic [7:0] mem_rdata,
    output logic finished,
    output logic mem_wen, mem_ren,
    output logic [7:0] mem_addr, mem_wdata
);

    // TODO: Implement a controller device which directs copies of 'copy_size' bytes of data from 'src_addr' 
    // to 'dst_addr' when 'start' goes high, and sets 'finished' when
    // the transfer is complete.
    // This behavior is similar to a simple DMA, or "Direct Memory Access"
    // unit, which is used to move data around memory without wasting processor
    // compute time.

    // controller code
    typedef enum logic [2:0] {  
        //write your own states!

    } state_t;

    state_t state, next_state;


    always_comb begin : input_logic

    end

    always_ff @() begin : state_register

    end

    always_comb begin : output_logic

    end

    // data buffer code -- your code below!
    
    
endmodule
