VERILATE := verilator
VERILATE_FLAGS := -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --binary --trace-fst --trace-structs --trace-params --timescale 1ns/100ps --coverage --build-jobs 8

.PHONY: clean

mul: src/mul.sv tb/tb_mul.sv
	$(VERILATE) $(VERILATE_FLAGS) src/mul.sv tb/tb_mul.sv

div: src/div.sv tb/tb_div.sv
	$(VERILATE) $(VERILATE_FLAGS) src/div.sv tb/tb_div.sv

stack: src/stack.sv tb/tb_stack.sv
	$(VERILATE) $(VERILATE_FLAGS) src/stack.sv tb/tb_stack.sv

clean:
	rm -rf obj_dir
	rm -rf cov
	rm -f *.fst
	rm -f coverage.dat
	rm -f coverage.fst
	rm -rf html
