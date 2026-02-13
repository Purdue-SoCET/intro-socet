VERILATE := verilator
VERILATE_FLAGS := --binary --trace-fst

copier: src/copier_controller.sv src/data_register.sv tb/tb_copier_controller.sv
	$(VERILATE) $(VERILATE_FLAGS) --top-module tb_copier_controller $^
	cp obj_dir/Vtb_copier_controller .

clean:
	rm -rf obj_dir
	rm -f Vtb_copier_controller
	rm -f waveform.fst
