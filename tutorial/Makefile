VERILATE := verilator
VERILATE_FLAGS := --binary --trace-fst

full_adder_struct: src/first_module.sv src/ha.sv tb/tb_first_module.sv
	$(VERILATE) $(VERILATE_FLAGS) $^
	cp obj_dir/Vfirst_module .

full_adder: src/first_module.sv tb/tb_first_module.sv
	$(VERILATE) $(VERILATE_FLAGS) $^
	cp obj_dir/Vfirst_module .

clean:
	rm -rf obj_dir
	rm -rf waveform.fst
	rm -f Vfirst_module
