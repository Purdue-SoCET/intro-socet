VERILATE := verilator
VERILATE_FLAGS := -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --binary --trace-fst --trace-structs --trace-params --timescale 1ns/100ps --coverage --build-jobs 8

.PHONY: clean

stack: src/stack.sv tb/tb_stack.sv
	$(VERILATE) $(VERILATE_FLAGS) src/stack.sv tb/tb_stack.sv

clean:
	rm -rf obj_dir
	rm -rf cov
	rm -f *.fst
	rm -f coverage.dat
	rm -f coverage.fst
