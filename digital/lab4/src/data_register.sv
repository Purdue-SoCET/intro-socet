
/*  
*   Simple data register to hold a single 8-bit word.
*   WEN - Write Enable. Value on 'wdata' line will be
*         written in to the register if WEN is high.
*   wdata - data to be written in to the register.
*   register - current register contents to be read.
*/
module data_register(
    input CLK, nRST,
    input logic WEN,
    input logic [7:0] wdata,
    output logic [7:0] data
);

    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            data <= '0;
        end else begin
            data <= (WEN) ? wdata : data;
        end
    end

endmodule
