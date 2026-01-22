module first_module(
    input logic input_A,
    input logic input_B,
    output logic output_S, output_C
);
    
    // Structural Modeling:
    ha u1 (.a(input_A), .b(input_B), .sum(output_S), .cout(output_C));

    // Dataflow Modeling:
    assign output_Y = input_A ^ input_B;
    assign output_C = input_A & input_B;

    // Behavioral Modeling:
    always_comb begin
        {output_C, output_Y} = input_A + input_B;
    end

endmodule

