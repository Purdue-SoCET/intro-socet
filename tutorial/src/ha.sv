// Half Adder
module ha (
    input logic a, b,
    output logic sum, cout
);
    assign sum  = a ^ b; 
    assign cout = a & b;

endmodule
