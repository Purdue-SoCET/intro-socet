
module uart_tx(
    input clk,
    input rst_n,
    input send_request,
    input [7:0] tx_byte,
    output logic tx_data
);

    // import from package
    import uart_pkg::*;

    // constants for counter overflow values
    // This assumes 10MHz clock and 9600 bits per second UART
    // This is rounded! We're OK because it's only 8 bits, but
    // this would skew over time!
    localparam logic [3:0] UART_MAX_BIT = 10;
    localparam logic [10:0] UART_CLOCKS_PER_BIT = 1042; // 10MHz / 9600 baud = 1041.66666...

    logic load_byte, count_reset, count_enable;
    logic bit_complete, send_complete;
    logic tx_bit_out;
    logic [3:0] current_bit;
    logic [9:0] data_packet;
    output_select_t output_select;

    assign data_packet = {1'b1, tx_byte, 1'b0};

    fsm_control CTRL(
        .clk,
        .rst_n,
        .send_request,
        .send_complete,
        .count_reset,
        .count_enable,
        .load_byte,
        .output_select
    );

    counter #(.NBITS(4)) BIT_COUNTER(
        .clk,
        .rst_n,
        .enable(bit_complete),
        .clear(count_reset),
        .overflow_value(UART_MAX_BIT),
        .overflow(send_complete),
        .count() // no connection, count not used in top-level
    );

    counter #(.NBITS(11)) BIT_TIMER(
        .clk,
        .rst_n,
        .enable(count_enable),
        .clear(count_reset),
        .overflow_value(UART_CLOCKS_PER_BIT),
        .overflow(bit_complete),
        .count() // no connection, count not used in top-level
    );

    shift_register #(.NBITS(10)) DATA_REGISTER(
        .clk,
        .rst_n,
        .load(load_byte),
        .shift(bit_complete),
        .serial_in(1'b1),
        .parallel_in(data_packet),
        .serial_out(tx_bit_out),
        .parallel_out() // no connection, parallel_out not used in top-level
    );

    // output mux
    assign tx_data = (output_select == DATA) ? tx_bit_out : 1'b1;

endmodule