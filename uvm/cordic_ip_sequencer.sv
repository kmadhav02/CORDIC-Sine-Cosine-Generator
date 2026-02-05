class cordic_ip_sequencer extends uvm_sequencer #(cordic_sequence_item);

	`uvm_component_utils(cordic_ip_sequencer)
	
	extern function new(string name = "cordic_ip_sequencer",uvm_component parent = null);

endclass : cordic_ip_sequencer

function cordic_ip_sequencer::new(string name = "cordic_ip_sequencer",uvm_component parent = null);
	super.new(name,parent);
endfunction	