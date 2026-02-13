module flex_counter #(
    parameter NUM_CNT_BITS = 4
)( 
    input logic clk,
    input logic n_rst,
    input logic clear,
    input logic count_enable,
    input logic [NUM_CNT_BITS - 1 : 0] rollover_val,
    output logic [NUM_CNT_BITS - 1 :0] count_out,
    output logic rollover_flag
);

    logic [NUM_CNT_BITS - 1 : 0] temp_counter;
    logic [NUM_CNT_BITS - 1 :0] next_state;
    logic rollover_flag_c;

    //state_logicister
    always_ff @(posedge clk, negedge n_rst)
    begin
        if (!n_rst)
        begin
            temp_counter <= 0;
            rollover_flag <= 0;
        end
        else
        begin
            temp_counter <= next_state;
            rollover_flag <= rollover_flag_c ;
        end
    end

    //next _state logic
    always_comb
    begin
        next_state = (clear) ? ('0) : (!count_enable) ? temp_counter :(temp_counter == rollover_val) ? 1: temp_counter + 1;
        
        if (next_state == rollover_val)  
        begin
            rollover_flag_c = 1;
        end
        else
        begin
            rollover_flag_c = 0;
        end
    end

    //output logic
    assign count_out = temp_counter;

endmodule











