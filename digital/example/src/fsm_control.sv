
module fsm_control(
    input clk,
    input rst_n,
    input send_request,
    input send_complete,
    output logic count_reset,
    output logic count_enable,
    output logic load_byte,
    output uart_pkg::output_select_t output_select
);
    // import all definitions from UART package
    // this provides definition for state_t and output_select_t
    import uart_pkg::*;

    typedef enum logic [1:0] {
        IDLE,
        LOAD_DATA,
        SEND_DATA
    } state_t;

    state_t state, state_next;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= state_next;
        end
    end

    // FSM Controllers often use case statements instead of "if..else if...else if..." chains
    always_comb begin : NEXT_STATE_LOGIC
        state_next = state;
        casez (state)
            IDLE: begin
                if(send_request) begin
                    state_next = LOAD_DATA;
                end
            end

            LOAD_DATA: state_next = SEND_DATA;

            SEND_DATA: begin
                if(send_complete) begin
                    state_next = IDLE;
                end
            end
            default: state_next = IDLE;
        endcase
    end

    always_comb begin : OUTPUT_LOGIC
        count_reset = 0;
        count_enable = 0;
        output_select = ONE;
        load_byte = 0;

        casez(state)
            IDLE: output_select = ONE;
            LOAD_DATA: begin
                output_select = ONE;
                load_byte = 1;
                count_reset = 1;
            end
            SEND_DATA: begin
                output_select = DATA;
                count_enable = 1;
            end
            default: output_select = ONE;
        endcase
    end

endmodule