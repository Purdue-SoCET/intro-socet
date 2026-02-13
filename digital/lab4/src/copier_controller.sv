
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
        IDLE,
        READ,
        WRITE,
        FINISH
    } state_t;

    state_t state, next_state;

    logic [7:0] dr_byte;
    logic dr_wen;

    always_comb begin : input_logic
        next_state = state;
        casez(state)
            IDLE:    next_state = start ? READ : IDLE; // When in IDLE, wait for START signal
            READ:    next_state = mem_ready ? WRITE : READ; // If data is ready, go to write, else keep reading
            WRITE:   next_state = FINISH; // If done, finish, else read next block
            FINISH:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge CLK, negedge nRST) begin : state_register
        if (!nRST) begin
            state <= IDLE;    
        end else begin
            state <= next_state;
        end
    end

    always_comb begin : output_logic
        // Copier Signals
        dr_wen    = '0;
        finished  = '0;
        // Memory Facing Signals
        mem_ren   = '0;
        mem_wen   = '0;
        mem_addr  = '0;
        mem_wdata = 8'hFF;
        casez(state)
            READ: begin // When in READ, enable reading, set addr, and write data to DR for caching.
                mem_ren  = '1;
                mem_addr = src_addr; // No offset due to word_t structure
                dr_wen     = '1;
            end
            WRITE: begin // When in WRITE, enable write, set addr, and write data from DR.
                mem_wen    = 1;
                mem_addr   = dst_addr;
                mem_wdata  = dr_byte;
            end
            FINISH: 
                finished = 1;
            default: begin
                // Copier Signals
                dr_wen    = '0;
                finished  = '0;
                // Memory Facing Signals
                mem_ren   = '0;
                mem_wen   = '0;
                mem_addr  = '0;
                mem_wdata = 8'hFF;
            end
        endcase
    end

    // data buffer code -- your code below!
    data_register dr (.CLK(CLK), .nRST(nRST), .WEN(dr_wen), .wdata(mem_rdata), .data(dr_byte));
    
endmodule
