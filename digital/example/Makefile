VERILATE := verilator
VERILATE_FLAGS := --binary --trace-fst --trace-structs --trace-params --timescale 1ns/100ps --coverage --build-jobs 8

.PHONY: clean

uart: src/uart_pkg.sv src/counter.sv src/fsm_control.sv src/shift_register.sv  src/uart_tx.sv tb/tb_uart_tx.sv 
	$(VERILATE) $(VERILATE_FLAGS) $^

clean:
	rm -rf obj_dir
	rm -f trace.fst