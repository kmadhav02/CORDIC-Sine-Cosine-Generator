class cordic_sequence_item extends uvm_sequence_item;

   `uvm_object_utils(cordic_sequence_item)
    
    rand logic  [16:0] Input_angle;
    logic signed [15:0] Cos_out, Sin_out;

  constraint valid_angle_0_to_360 {
    Input_angle inside {[0:102944]};
  }
	extern function new(string name = "cordic_sequence_item");
	extern function void do_print(uvm_printer printer);
endclass

function cordic_sequence_item::new(string name = "cordic_sequence_item");
	super.new(name);
endfunction

function void cordic_sequence_item::do_print(uvm_printer printer);  
	printer.print_int("Input_angle", this.Input_angle, $bits(Input_angle), UVM_DEC, "[0:360]");
	printer.print_int("Cos_out", this.Cos_out, $bits(Cos_out), UVM_DEC);
	printer.print_int("Sin_out", this.Sin_out, $bits(Sin_out), UVM_DEC);
	printer.print_string("CORDIC_RESULT",$sformatf("angle=%0d°, cos=%0d, sin=%0d", this.Input_angle, this.Cos_out, this.Sin_out));
endfunction