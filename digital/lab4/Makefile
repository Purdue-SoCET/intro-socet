VERILATE := verilator
VERILATE_FLAGS := --binary --trace-fst

COPIER_SRC := src/memory_if.sv src/memory.sv src/flex_counter.sv src/data_register.sv src/copier.sv

copier: $(COPIER_SRC) tb/tb_copier.sv
	$(VERILATE) $(VERILATE_FLAGS) --top-module tb_copier $^
	cp obj_dir/Vtb_copier .

clean:
	rm -rf obj_dir
	rm -f Vtb_copier
	rm -f waveform.fst
