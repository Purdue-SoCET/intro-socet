
module tb_first_module;

    // A localparam is a constant value that exists only in this module
    localparam int DELAY = 10;

    // Declare signals to connect to the device-under-test (DUT)
    logic tb_a;
    logic tb_b;
    logic tb_s;
    logic tb_cout;

    // TB-only variables
    int test_number;
    int num_passed;


    // Instantiate DUT
    // .X(Y) means connect port X of the instance to signal Y
    // of the containing design.
    // This can get long-winded. SystemVerilog allows you to use ".*"
    // to connect all ports of the DUT to a signal of the same name.
    // For example, we could have done:
    // ```
    // logic a, b, cin, cout, s;
    // full_adder DUT(.*);
    // ```
    // instead of this. This is recommended when connections are obvious!
    first_module DUT(
        .input_A(tb_a),
        .input_B(tb_b),
        .output_S(tb_s),
        .output_C(tb_cout)
    );


    // Task that applies input and checks outputs.
    // Tasks are like functions in programming languages,
    // but they are allowed to *advance time* in simulation!
    // Tasks allow you to re-use code instead of copy-pasting!
    task apply_inputs(
        input a,
        input b,
        input expected_s,
        input expected_cout
    );
        test_number += 1;
        tb_a = a;
        tb_b = b;
        #(DELAY); // Pass time in simulation to allow propagation
        
        if({expected_cout, expected_s} != {tb_cout, tb_s}) begin
            $display("[Time %0t]: Expected %2b, got %2b\n", $time, {expected_cout, expected_s}, {tb_cout, tb_s});
        end else begin
            num_passed += 1;
        end
    endtask

    // initial block. This code will run procedurally until we hit a $finish task call.
    initial begin
        // set up waveform dump. This isn't necessary when working
        // with a simulator that does wave simulation by default,
        // but works with any simulator.
        $dumpfile("waveform.fst"); // output waves to 'waveform.vcd'
        $dumpvars;                 // dump all variables

        // initialize values (inputs & TB variables only)
        tb_a = 0;
        tb_b = 0;
        test_number = 0;
        num_passed = 0;

        // run tests. 4 possible cases for 2b input
        //
        //   a | b || s | cout
        // -------------------
        //   0 | 0 || 0 | 0
        //   0 | 1 || 1 | 0
        //   1 | 0 || 1 | 0
        //   1 | 1 || 0 | 1
        //
        apply_inputs(0, 0, 0, 0);
        apply_inputs(0, 1, 1, 0);
        apply_inputs(1, 0, 1, 0);
        apply_inputs(1, 1, 0, 1);

        $display("Passed %0d/%0d tests.", num_passed, test_number);

        // End simulation
        $finish();
    end

endmodule